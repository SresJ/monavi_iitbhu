import os
os.environ["TOKENIZERS_PARALLELISM"] = "false"

from app.ml_pipeline.rag import MedicalRAG
from app.ml_pipeline.utils.cleaning import clean_patient_text
from app.ml_pipeline.summarizer import summarize_case
from app.ml_pipeline.diagnosis import generate_differential_diagnosis
from app.ml_pipeline.multimodal.multimodal_ingest import ingest_patient_inputs
from app.ml_pipeline.export.pdf_exporter import export_summary_to_pdf
from app.ml_pipeline.llm.llm_processor import format_output_with_llm
from app.ml_pipeline.llm.followup_qa import answer_followup_question
from app.ml_pipeline.explainability.traceability import find_triggering_sentences
from app.ml_pipeline.explainability.confidence_explainer import explain_confidence

# -------------------------------------------------
# CLI input helpers (UI responsibility later)
# -------------------------------------------------
def collect_typed_input():
    """
    Collect multiline typed clinical notes.
    End input with empty line.
    """
    print("\nEnter patient notes (press Enter on empty line to finish):\n")
    lines = []
    while True:
        line = input()
        if not line.strip():
            break
        lines.append(line)
    return "\n".join(lines)

def collect_file_paths(label: str):
    """
    Collect multiple file paths from CLI.
    (PDF / image / audio)
    """
    paths = []
    choice = input(f"\nDo you want to add {label}? (y/n): ").strip().lower()
    if choice != "y":
        return paths

    while True:
        path = input(f"Enter {label} file path (or press Enter to finish): ").strip()
        if not path:
            break
        paths.append(path)

    return paths

# -------------------------------------------------
# Main pipeline
# -------------------------------------------------
def main():
    print("\n🩺 GenAI Clinical Co-Pilot (CLI)\n")

    # Initialize RAG system
    rag = MedicalRAG()

    # -----------------------------
    # 1️⃣ Collect inputs
    # -----------------------------
    typed_text = collect_typed_input()
    pdf_paths = collect_file_paths("PDF")
    image_paths = collect_file_paths("image")
    audio_paths = collect_file_paths("audio")

    # -----------------------------
    # 2️⃣ Multimodal ingestion
    # -----------------------------
    patient_text = ingest_patient_inputs(
        typed_text=typed_text,
        pdf_paths=pdf_paths,
        image_paths=image_paths,
        audio_paths=audio_paths
    )

    patient_sentences = [
        s.strip()
        for s in patient_text.split(".")
        if len(s.strip()) > 5
    ]

    if not patient_text.strip():
        print("\n❌ No patient data provided.")
        return

    # -----------------------------
    # 3️⃣ Rule-based text cleaning
    # -----------------------------
    clean_input = clean_patient_text(patient_text)

    # -----------------------------
    # 4️⃣ Summarization
    # -----------------------------
    summary = summarize_case(clean_input)

    print("\n📄 Clinical Summary:\n")
    print(summary)

    # Optional PDF export
    choice = input("\nDo you want to export this summary as PDF? (y/n): ").strip().lower()
    if choice == "y":
        output_file = export_summary_to_pdf(summary, "clinical_summary.pdf")
        print(f"\n📄 Summary exported to: {output_file}")

    # -----------------------------
    # 5️⃣ RAG retrieval
    # -----------------------------
    evidence = rag.retrieve(summary, top_k=8)

    # -----------------------------
    # 6️⃣ Differential diagnosis
    # -----------------------------
    diagnoses = generate_differential_diagnosis(evidence)

    # -----------------------------
    # 7️⃣ Build raw output
    # -----------------------------
    raw_output = summary + "\n\n🧠 Differential Diagnosis (Evidence-Based):\n"

    for i, d in enumerate(diagnoses, start=1):
        raw_output += f"\n{i}. {d['diagnosis']} (confidence: {d['confidence']})\n"

        # 1️⃣ Input-text traceability
        triggers = find_triggering_sentences(
            d["diagnosis"],
            patient_sentences
        )

        if triggers:
            raw_output += "Triggering Patient Text:\n"
            for t in triggers:
                raw_output += f"- \"{t}\"\n"

        # Supporting evidence
        if d.get("evidence_text"):
            raw_output += "Supporting Evidence:\n"
            for line in d["evidence_text"]:
                raw_output += f"- {line}\n"

        # Source links
        if d.get("sources"):
            raw_output += "Source:\n"
            for src in d["sources"]:
                raw_output += f"- {src}\n"

        # 2️⃣ Confidence explanation
        confidence_notes = explain_confidence(
            d["confidence"],
            len(d.get("evidence_text", []))
        )

        raw_output += "Confidence Rationale:\n"
        for note in confidence_notes:
            raw_output += f"- {note}\n"

    # -----------------------------
    # 8️⃣ LLM output formatting
    # -----------------------------
    final_output = format_output_with_llm(raw_output)

    print("\n📊 Final Clinical Output:\n")
    print(final_output)

    # -----------------------------
    # 9️⃣ Doctor follow-up Q&A
    # -----------------------------
    while True:
        followup = input(
            "\n💬 Ask a follow-up question (or press Enter to exit): "
        ).strip()

        if not followup:
            break

        answer = answer_followup_question(
            question=followup,
            summary=summary,
            diagnoses=diagnoses,
            evidence=evidence
        )

        print("\n🩺 Follow-up Answer:\n")
        print(answer)


if __name__ == "__main__":
    main()
