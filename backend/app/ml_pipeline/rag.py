import faiss
import json
import numpy as np
from sentence_transformers import SentenceTransformer
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent  # Points to backend/


class MedicalRAG:
    def __init__(self):
        self.index = faiss.read_index(str(BASE_DIR / "data/medical_faiss.index"))

        with open(BASE_DIR / "data/medical_metadata.json", "r") as f:
            self.metadata = json.load(f)

        self.model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

    def retrieve(self, query: str, top_k: int = 8):
        """
        Retrieve relevant medical evidence chunks.
        """
        query_vec = self.model.encode([query]).astype("float32")
        distances, indices = self.index.search(query_vec, top_k)

        results = []
        for i, idx in enumerate(indices[0]):
            meta = self.metadata[idx]
            results.append({
                "disease": meta["disease"],
                "text": meta["text"],
                "url": meta["url"],
                "source": meta.get("source", "MedlinePlus"),
                "score": float(distances[0][i])
            })

        return results
