# Clinical Dashboard Backend API

FastAPI-based backend for the Clinical Dashboard application with integrated ML pipeline for medical diagnosis.

## Features

- **Firebase Authentication**: Secure authentication using Firebase UID
- **MongoDB Database**: Flexible NoSQL database with Motor (async driver)
- **ML Pipeline Integration**: Complete medical analysis pipeline with:
  - Multimodal input (text, audio, PDF, images)
  - RAG-based diagnosis generation
  - Clinical summarization
  - Differential diagnosis with confidence scores
  - Follow-up Q&A system
- **RESTful API**: Well-documented endpoints for all operations
- **Cloud-Ready**: Designed for cloud deployment (AWS/GCP/Azure)

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── config.py                  # Application configuration
│   ├── database.py                # MongoDB connection management
│   ├── main.py                    # FastAPI application entry point (TO BE CREATED)
│   ├── models/                    # Pydantic models for MongoDB
│   │   ├── doctor.py
│   │   ├── patient.py
│   │   └── analysis.py
│   ├── schemas/                   # API request/response schemas
│   │   ├── auth.py
│   │   ├── patient.py
│   │   └── analysis.py
│   ├── api/                       # API route handlers (TO BE CREATED)
│   │   ├── auth.py
│   │   ├── patients.py
│   │   ├── analysis.py
│   │   ├── followup.py
│   │   └── export.py
│   ├── services/                  # Business logic (TO BE CREATED)
│   │   ├── firebase_service.py
│   │   ├── patient_service.py
│   │   └── analysis_service.py
│   ├── middleware/
│   │   └── firebase_middleware.py # Firebase authentication
│   ├── ml_pipeline/               # ML models (copied from clinical_ml)
│   └── utils/
├── data/                          # FAISS index and medical data
├── uploads/                       # User-uploaded files
├── whisper/                       # Whisper transcription models
├── requirements.txt
├── .env.example
└── README.md
```

## Setup Instructions

### Prerequisites

- Python 3.8+
- MongoDB Atlas account (or local MongoDB)
- Firebase project with Authentication enabled
- OpenAI API key

### 1. Install Dependencies

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure Environment Variables

Create a `.env` file based on `.env.example`:

```bash
cp .env.example .env
```

Edit `.env` and fill in your configuration:

```env
MONGODB_URI=mongodb+srv://your-username:your-password@cluster.mongodb.net/?retryWrites=true&w=majority
MONGODB_DB_NAME=clinical_dashboard
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
OPENAI_API_KEY=sk-your-openai-api-key-here
```

### 3. Setup MongoDB Atlas

1. Create a free MongoDB Atlas cluster at https://www.mongodb.com/cloud/atlas
2. Create a database user with read/write permissions
3. Whitelist your IP address (or use 0.0.0.0/0 for development)
4. Copy the connection string to your `.env` file

### 4. Setup Firebase

1. Go to Firebase Console: https://console.firebase.google.com/
2. Create a new project (or use existing)
3. Enable Authentication → Email/Password
4. Go to Project Settings → Service Accounts
5. Click "Generate new private key"
6. Save the JSON file as `firebase-service-account.json` in the backend directory

### 5. Verify ML Pipeline Setup

The ML pipeline has been copied from `clinical_ml`. Ensure these files exist:

```bash
ls -la app/ml_pipeline/    # Should contain diagnosis.py, rag.py, summarizer.py, etc.
ls -la data/               # Should contain medical_faiss.index, medical_metadata.json
```

## API Endpoints (To Be Implemented)

### Authentication
- `POST /api/auth/verify` - Verify Firebase UID and create/update doctor

### Patients
- `GET /api/patients` - List all patients
- `POST /api/patients` - Create new patient
- `GET /api/patients/{patient_id}` - Get patient details
- `PUT /api/patients/{patient_id}` - Update patient
- `DELETE /api/patients/{patient_id}` - Delete patient

### Analysis
- `POST /api/analysis/create` - Create new analysis (multimodal)
- `GET /api/analysis/{analysis_id}` - Get analysis results
- `POST /api/analysis/{analysis_id}/followup` - Ask follow-up question

### Export
- `GET /api/export/pdf/{analysis_id}` - Export analysis to PDF

### Dashboard
- `GET /api/dashboard/stats` - Get dashboard statistics

## Development Workflow

### Running the Server (After completing implementation)

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Access the API at: http://localhost:8000
API Documentation: http://localhost:8000/docs

### Testing

```bash
pytest tests/
```

## Next Steps

### Remaining Implementation Tasks:

1. **Create Services** (`app/services/`):
   - `firebase_service.py` - Firebase UID verification and doctor management
   - `patient_service.py` - Patient CRUD operations
   - `analysis_service.py` - ML pipeline integration and analysis orchestration

2. **Create API Endpoints** (`app/api/`):
   - `auth.py` - Authentication endpoints
   - `patients.py` - Patient management endpoints
   - `analysis.py` - Analysis creation and retrieval
   - `followup.py` - Follow-up Q&A
   - `export.py` - PDF export

3. **Create Main Application** (`app/main.py`):
   - Initialize FastAPI app
   - Configure CORS
   - Register all routers
   - Setup database connection on startup/shutdown
   - Initialize Firebase Admin SDK

4. **Testing**:
   - Test all endpoints with Postman or Thunder Client
   - Verify MongoDB connections and data persistence
   - Test ML pipeline integration
   - Test file uploads

5. **Deployment**:
   - Create Dockerfile
   - Setup CI/CD pipeline
   - Deploy to cloud platform (AWS ECS, GCP Cloud Run, or Azure)

## MongoDB Collections Schema

### doctors
```python
{
    "firebase_uid": str,  # Unique
    "email": str,         # Unique
    "full_name": str,
    "specialty": str,
    "created_at": datetime,
    "updated_at": datetime
}
```

### patients
```python
{
    "patient_id": str,    # Unique (e.g., "PAT-2025-00001")
    "mrn": str,           # Optional, Medical Record Number
    "full_name": str,
    "age": int,
    "sex": str,
    "contact": {
        "email": str,
        "phone": str
    },
    "created_at": datetime,
    "updated_at": datetime
}
```

### analyses
```python
{
    "analysis_id": str,          # Unique (e.g., "ANA-2025-00001")
    "patient_id": str,
    "doctor_firebase_uid": str,
    "raw_input": {
        "typed_text": str,
        "files": [...]
    },
    "summary": {...},
    "diagnoses": [               # Embedded
        {
            "diagnosis_name": str,
            "confidence": float,
            "evidence": [...]
        }
    ],
    "diagnostic_tests": [...],
    "missing_info": [str],
    "created_at": datetime,
    "updated_at": datetime
}
```

## Security Considerations

- Firebase UID is used for authentication (no password storage)
- All API endpoints (except auth) require Firebase UID in Authorization header
- CORS is configured for specific origins only
- File uploads are size-limited and validated
- MongoDB connection uses authentication

## ML Pipeline Overview

The integrated ML pipeline includes:

1. **Multimodal Ingestion**: Processes text, audio (Whisper), PDFs, and images (OCR)
2. **Text Cleaning**: De-identification and normalization
3. **Summarization**: Rule-based extraction of patient info
4. **RAG System**: FAISS-based semantic search in medical knowledge base
5. **Diagnosis Generation**: Differential diagnoses ranked by confidence
6. **Explainability**: Confidence rationale and symptom traceability
7. **LLM Formatting**: GPT-4 for output beautification
8. **Follow-up Q&A**: Context-aware question answering

## License

Proprietary - All rights reserved

## Support

For issues or questions, please contact the development team.
