from motor.motor_asyncio import AsyncIOMotorDatabase
from app.models.analysis import (
    Analysis, RawInput, Summary, Diagnosis, Evidence,
    DiagnosticTest, FollowupConversation, FollowupQA
)
from datetime import datetime, timedelta
from typing import List, Optional
import re
from app.utils import get_ist_now

# ML Pipeline imports
from app.ml_pipeline.multimodal.multimodal_ingest import ingest_patient_inputs
from app.ml_pipeline.utils.cleaning import clean_patient_text
from app.ml_pipeline.summarizer import summarize_case
from app.ml_pipeline.rag import MedicalRAG
from app.ml_pipeline.diagnosis import generate_differential_diagnosis
from app.ml_pipeline.explainability.traceability import find_triggering_sentences
from app.ml_pipeline.explainability.confidence_explainer import explain_confidence
from app.ml_pipeline.llm.followup_qa import answer_followup_question


class AnalysisService:
    """
    Service for managing clinical analyses with ML pipeline integration
    """

    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
        self.collection = db.analyses
        self.followup_collection = db.followup_conversations

        # Initialize RAG system
        self.rag = MedicalRAG()

    async def generate_analysis_id(self) -> str:
        """
        Generate unique analysis ID in format ANA-YYYY-NNNNN

        Returns:
            str: Unique analysis ID
        """
        year = get_ist_now().year
        pattern = f"ANA-{year}-"

        last_analysis = await self.collection.find_one(
            {"analysis_id": {"$regex": f"^{pattern}"}},
            sort=[("analysis_id", -1)]
        )

        if last_analysis:
            match = re.search(r'-(\d+)$', last_analysis["analysis_id"])
            next_num = int(match.group(1)) + 1 if match else 1
        else:
            next_num = 1

        return f"ANA-{year}-{next_num:05d}"

    async def create_analysis(
        self,
        patient_id: str,
        doctor_firebase_uid: str,
        typed_text: str,
        uploaded_files: List[dict]
    ) -> dict:
        """
        Create new analysis using ML pipeline

        Args:
            patient_id: Patient ID
            doctor_firebase_uid: Doctor's Firebase UID
            typed_text: Clinical notes typed by doctor
            uploaded_files: List of uploaded file metadata

        Returns:
            dict: Created analysis document
        """
        # 1. Generate analysis ID
        analysis_id = await self.generate_analysis_id()

        # 2. Fetch patient information from database
        patient = await self.db.patients.find_one({"patient_id": patient_id})
        if not patient:
            raise ValueError(f"Patient {patient_id} not found")

        # 3. Format patient demographic information for ML model
        patient_context = self._format_patient_context(patient)

        # 4. Prepend patient context to clinical notes
        full_clinical_text = f"{patient_context}\n\n{typed_text}" if typed_text else patient_context

        # 5. Extract file paths by type
        audio_paths = [f["stored_path"] for f in uploaded_files if f["file_type"] == "audio"]
        pdf_paths = [f["stored_path"] for f in uploaded_files if f["file_type"] == "pdf"]
        image_paths = [f["stored_path"] for f in uploaded_files if f["file_type"] == "image"]

        # 6. Multimodal ingestion - combine all inputs
        combined_text = ingest_patient_inputs(
            typed_text=full_clinical_text,
            pdf_paths=pdf_paths,
            image_paths=image_paths,
            audio_paths=audio_paths
        )

        # 7. Clean and de-identify text
        clean_text = clean_patient_text(combined_text)
        patient_sentences = clean_text.split('. ')

        # 8. Generate clinical summary
        summary_text = summarize_case(clean_text)

        # 9. Retrieve evidence using RAG
        evidence_results = self.rag.retrieve(summary_text, top_k=8)

        # 10. Generate differential diagnoses
        diagnoses_raw = generate_differential_diagnosis(evidence_results)

        # 11. Add explainability (traceability and confidence rationale)
        diagnoses_enhanced = []
        for diag in diagnoses_raw:
            # Find triggering symptoms
            triggering = find_triggering_sentences(
                diag["diagnosis"],
                patient_sentences
            )

            # Generate confidence rationale
            rationale = explain_confidence(
                diag["confidence"],
                len(diag.get("evidence", []))
            )

            # Build evidence list from the new structure
            evidence_list = []
            evidence_items = diag.get("evidence", [])

            # Handle new evidence structure (dict with text, url, source)
            for evidence_item in evidence_items:
                if isinstance(evidence_item, dict):
                    evidence_list.append(Evidence(
                        evidence_text=evidence_item.get("text", ""),
                        source_url=evidence_item.get("url", ""),
                        source_name=evidence_item.get("source", "MedlinePlus")
                    ))
                # Fallback for old structure (if any)
                elif isinstance(evidence_item, str):
                    evidence_list.append(Evidence(
                        evidence_text=evidence_item,
                        source_url="",
                        source_name="MedlinePlus"
                    ))

            # Determine confidence level
            if diag["confidence"] >= 0.75:
                conf_level = "high"
            elif diag["confidence"] >= 0.45:
                conf_level = "medium"
            else:
                conf_level = "low"

            diagnoses_enhanced.append(Diagnosis(
                diagnosis_name=diag["diagnosis"],
                confidence=diag["confidence"],
                confidence_level=conf_level,
                triggering_symptoms=triggering,
                confidence_rationale=rationale,
                evidence=evidence_list
            ))

        # 12. Parse summary for structured data
        summary_obj = self._parse_summary(summary_text)

        # 13. Extract diagnostic tests and missing info from summary
        diagnostic_tests = self._extract_diagnostic_tests(summary_text)
        missing_info = self._extract_missing_info(summary_text)

        # 14. Create analysis document
        analysis = Analysis(
            analysis_id=analysis_id,
            patient_id=patient_id,
            doctor_firebase_uid=doctor_firebase_uid,
            raw_input=RawInput(
                typed_text=typed_text,
                files=uploaded_files
            ),
            summary=summary_obj,
            diagnoses=diagnoses_enhanced,
            diagnostic_tests=diagnostic_tests,
            missing_info=missing_info
        )

        # 15. Save to database
        await self.collection.insert_one(analysis.model_dump())

        return await self.collection.find_one({"analysis_id": analysis_id})

    def _format_patient_context(self, patient: dict) -> str:
        """
        Format patient demographic information for ML model input

        Args:
            patient: Patient document from database

        Returns:
            str: Formatted patient context string
        """
        context_parts = []

        # Patient ID and Name
        if patient.get("full_name"):
            context_parts.append(f"Patient Name: {patient['full_name']}")

        if patient.get("patient_id"):
            context_parts.append(f"Patient ID: {patient['patient_id']}")

        if patient.get("mrn"):
            context_parts.append(f"MRN: {patient['mrn']}")

        # Demographics
        demographics = []
        if patient.get("age") is not None:
            demographics.append(f"{patient['age']} years old")

        if patient.get("sex"):
            demographics.append(patient["sex"])

        if demographics:
            context_parts.append("Demographics: " + ", ".join(demographics))

        # Contact Information
        contact = patient.get("contact")
        if contact:
            contact_info = []
            if contact.get("email"):
                contact_info.append(f"Email: {contact['email']}")
            if contact.get("phone"):
                contact_info.append(f"Phone: {contact['phone']}")
            if contact_info:
                context_parts.append("Contact: " + ", ".join(contact_info))

        # Format as structured text
        formatted_context = "\n".join(context_parts)

        return f"PATIENT INFORMATION:\n{formatted_context}\n\nCLINICAL NOTES:"

    def _parse_summary(self, summary_text: str) -> Summary:
        """
        Parse summary text to extract structured data

        Args:
            summary_text: Formatted summary text

        Returns:
            Summary: Structured summary object
        """
        # Extract age
        age_match = re.search(r'Age.*?(\d+)', summary_text)
        age = int(age_match.group(1)) if age_match else None

        # Extract sex
        sex_match = re.search(r'Sex.*?(male|female)', summary_text, re.IGNORECASE)
        sex = sex_match.group(1).lower() if sex_match else None

        # Extract chief complaint
        complaint_match = re.search(r'Chief Complaint.*?[•●]\s*(.+)', summary_text)
        chief_complaint = complaint_match.group(1).strip() if complaint_match else None

        # Extract duration
        duration_match = re.search(r'Duration.*?[•●]\s*(.+)', summary_text)
        duration = duration_match.group(1).strip() if duration_match else None

        # Extract associated symptoms
        symptoms_match = re.search(r'Associated Symptoms.*?[•●]\s*(.+)', summary_text)
        symptoms_text = symptoms_match.group(1).strip() if symptoms_match else ""
        associated_symptoms = [s.strip() for s in symptoms_text.split(',') if s.strip() and s.strip().lower() != 'none']

        return Summary(
            age=age,
            sex=sex,
            chief_complaint=chief_complaint,
            associated_symptoms=associated_symptoms,
            duration=duration,
            formatted_summary=summary_text
        )

    def _extract_diagnostic_tests(self, summary_text: str) -> List[DiagnosticTest]:
        """
        Extract diagnostic tests from summary

        Args:
            summary_text: Summary text

        Returns:
            list: List of DiagnosticTest objects
        """
        tests = []
        # Find tests section
        tests_match = re.search(r'Suggested Diagnostic Tests.*?([•●].+?)(?:\n\n|⚠️|$)', summary_text, re.DOTALL)

        if tests_match:
            tests_text = tests_match.group(1)
            test_items = re.findall(r'[•●]\s*(.+)', tests_text)

            for test_name in test_items:
                tests.append(DiagnosticTest(
                    test_name=test_name.strip(),
                    rationale="Suggested based on symptoms"
                ))

        return tests

    def _extract_missing_info(self, summary_text: str) -> List[str]:
        """
        Extract missing information from summary

        Args:
            summary_text: Summary text

        Returns:
            list: List of missing information items
        """
        missing = []
        # Find missing/unknown section
        missing_match = re.search(r'Missing / Unknown.*?[•●]\s*(.+)', summary_text)

        if missing_match:
            missing_text = missing_match.group(1).strip()
            missing = [item.strip() for item in missing_text.split('\n') if item.strip()]

        return missing

    async def get_analysis(self, analysis_id: str) -> Optional[dict]:
        """
        Get analysis by ID

        Args:
            analysis_id: Analysis ID

        Returns:
            dict: Analysis document or None if not found
        """
        return await self.collection.find_one({"analysis_id": analysis_id})

    async def ask_followup_question(
        self,
        analysis_id: str,
        question: str
    ) -> tuple[str, datetime]:
        """
        Ask follow-up question about an analysis

        Args:
            analysis_id: Analysis ID
            question: Follow-up question

        Returns:
            tuple: (answer, timestamp)
        """
        # Get analysis
        analysis = await self.get_analysis(analysis_id)
        if not analysis:
            raise ValueError("Analysis not found")

        # Get or create followup conversation
        conversation = await self.followup_collection.find_one({"analysis_id": analysis_id})

        # Prepare context for Q&A
        summary_text = analysis["summary"]["formatted_summary"]
        diagnoses = analysis["diagnoses"]
        evidence = []

        for diag in diagnoses:
            for ev in diag.get("evidence", []):
                evidence.append({
                    "disease": diag["diagnosis_name"],
                    "text": ev["evidence_text"],
                    "url": ev["source_url"],
                    "source": ev["source_name"]
                })

        # Get answer using ML pipeline
        answer = answer_followup_question(
            question=question,
            summary=summary_text,
            diagnoses=diagnoses,
            evidence=evidence
        )

        # Create Q&A pair
        asked_at = get_ist_now()
        qa_pair = FollowupQA(
            question=question,
            answer=answer,
            asked_at=asked_at
        )

        if conversation:
            # Update existing conversation
            await self.followup_collection.update_one(
                {"analysis_id": analysis_id},
                {
                    "$push": {"qa_pairs": qa_pair.model_dump()},
                    "$set": {"updated_at": get_ist_now()}
                }
            )
        else:
            # Create new conversation
            new_conversation = FollowupConversation(
                analysis_id=analysis_id,
                qa_pairs=[qa_pair]
            )
            await self.followup_collection.insert_one(new_conversation.model_dump())

        return answer, asked_at

    async def get_dashboard_stats(self, doctor_firebase_uid: str) -> dict:
        """
        Get dashboard statistics for a doctor

        Args:
            doctor_firebase_uid: Doctor's Firebase UID

        Returns:
            dict: Statistics
        """
        # Count total patients (this would need to be scoped by doctor in production)
        total_patients = await self.db.patients.count_documents({})

        # Count total analyses by this doctor
        total_analyses = await self.collection.count_documents(
            {"doctor_firebase_uid": doctor_firebase_uid}
        )

        # Count recent analyses (last 7 days)
        seven_days_ago = get_ist_now() - timedelta(days=7)
        recent_analyses = await self.collection.count_documents({
            "doctor_firebase_uid": doctor_firebase_uid,
            "created_at": {"$gte": seven_days_ago}
        })

        return {
            "total_patients": total_patients,
            "total_analyses": total_analyses,
            "recent_analyses_count": recent_analyses
        }
