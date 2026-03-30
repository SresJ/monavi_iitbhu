<div align="center">
  <!-- SPACE FOR LOGO -->
  <img src="frontend/assets/logo.jpeg" alt="Logo" width="375" height="150" style="border-radius: 50%;">
  
  <h1 align="center">Clinical AI Dashboard</h1>
  <p align="center">
    <strong>An advanced, multimodal AI-powered platform for clinical analysis, medical diagnosis, and patient management.</strong>
  </p>
</div>

---

## 🛑 Problem Statement

In modern healthcare, medical professionals are often overwhelmed by fragmented patient data coming from various sources—consultation audio, handwritten notes, printed lab results (PDFs), and medical imagery. Consolidating this multimodal data to accurately formulate differential diagnoses and comprehensive clinical summaries is a time-consuming, labor-intensive process that can be prone to human oversight.

## 💡 Our Solution

The **Clinical AI Dashboard** is an end-to-end platform designed to streamline medical diagnosis and patient management. 

By utilizing a cutting-edge **Machine Learning Pipeline (RAG-based + LLM)** on our Python FastAPI backend, we allow doctors to ingest multimodal patient data (text, whisper-transcribed audio, PDFs, and images) effortlessly. The system automatically processes this data, references a medical FAISS knowledge base, and outputs highly accurate differential diagnoses along with explainable confidence scores.

Our sleek, cross-platform **Flutter Frontend** wraps this powerful AI in an intuitive, responsive interface, allowing healthcare providers to manage patient profiles, trigger AI analyses, visualize statistical data, and export comprehensive PDF reports—all secured by Firebase Authentication and MongoDB.

---

## ✨ Key Features

### 🧠 AI & Machine Learning Pipeline
- **Multimodal Ingestion:** Handles text, audio (OpenAI Whisper transcription), scanned PDFs, and forms via OCR.
- **RAG-based Diagnosis Engine:** Semantic search against a rich medical knowledge base (FAISS) to generate accurate differential diagnoses.
- **AI Clinical Summarization:** Rule-based extraction and GPT-4 powered formatting for concise clinical summaries and rationale.
- **Context-Aware Follow-up Q&A:** Chat seamlessly with the AI to ask questions specific to the generated analysis.

### 📱 Frontend & User Experience
- **Cross-Platform Readiness:** Runs natively on Web, Android, iOS, Windows, macOS, and Linux.
- **Patient Management App:** Create, track, and manage complex patient records and historical analyses.
- **Interactive Dashboards:** Real-time metrics and dynamic data visualization (using `fl_chart`).
- **Formatted PDF Exporting:** One-click PDF report generation to easily print or share diagnosis results.
- **Premium Aesthetics:** Dark mode enabled by default with shimmer loading effects and tailored animations.

### 🔒 Security & Architecture
- **Firebase Authentication:** Secure, industry-standard authentication (UID verification) for medical staff.
- **MongoDB Atlas Backend:** A robust, NoSQL database structure for managing Doctors, Patients, and intricate Analysis data.
- **RESTful FastAPI:** Modern, fast, and scalable Python API architecture ready for loud deployment (AWS/GCP/Azure).

---

## 📂 Repository Structure

The project is structured as a monorepo containing both the frontend application and the backend API architecture.

```text
clinical-dashboard/
├── backend/               # FastAPI Python Backend and ML Pipeline
│   ├── app/               # Main API logic (Auth, Patients, Analysis)
│   ├── data/              # FAISS index and medical knowledge data
│   ├── ml_pipeline/       # AI Models (RAG, Summarizer, Whisper Integration)
│   ├── requirements.txt   # Python Dependencies
│   └── README.md          # Backend configuration and deployment documentation
│
├── frontend/              # Flutter Cross-Platform Frontend
│   ├── assets/            # UI Graphics, images, and logos
│   ├── lib/               # Dart Source Code (Screens, Models, Providers, Services)
│   ├── pubspec.yaml       # Flutter Dependencies
│   └── README.md          # Frontend setup and native compilation docs
│
└── README.md              # Project Overview (You are here)
```

---

## 🚀 Getting Started

To get the Clinical AI Dashboard running locally, you must run both the backend API and the frontend client. 

* Please refer to the [Backend Setup Guide](./backend/README.md) for instructions on activating the Python environment, setting up MongoDB, configuring Firebase, and launching the FastAPI server.
* Please refer to the [Frontend Setup Guide](./frontend/README.md) for instructions on installing dependencies, connecting Firebase, and running the Flutter app.

---

<div align="center">
  <!-- SPACE FOR ARCHITECTURE DIAGRAM OR OTHER GRAPHICS -->
  <br/>
  <p><i>Insert your system architecture diagram or platform banner here.</i></p>
  <br/>
</div>
