from collections import defaultdict

def generate_differential_diagnosis(evidence_chunks, max_diagnoses=5):
    """
    Generate ranked diagnoses with smooth confidence distribution.
    """

    disease_score = defaultdict(float)
    disease_evidence = defaultdict(list)
    disease_urls = defaultdict(set)

    # Aggregate scores
    for item in evidence_chunks:
        disease = item["disease"]

        # distance-weighted score
        score = 1 / (1 + item["score"])
        disease_score[disease] += score

        # Store evidence with source info together
        disease_evidence[disease].append({
            "text": item["text"],
            "url": item["url"],
            "source": item.get("source", "MedlinePlus")
        })
        disease_urls[disease].add(item["url"])

    if not disease_score:
        return [{
            "diagnosis": "Insufficient evidence",
            "confidence": 0.0,
            "evidence_text": [],
            "sources": [],
            "note": "No relevant medical evidence retrieved"
        }]

    # Rank diseases
    ranked = sorted(
        disease_score.items(),
        key=lambda x: x[1],
        reverse=True
    )[:max_diagnoses]

    # Total score for normalization
    total_score = sum(score for _, score in ranked)

    results = []
    for disease, score in ranked:
        confidence = round(score / total_score, 2)  # relative confidence

        results.append({
            "diagnosis": disease,
            "confidence": confidence,
            "evidence": disease_evidence[disease],  # Return all evidence with paired sources
            "sources": list(disease_urls[disease])  # Keep for backward compatibility
        })

    return results
