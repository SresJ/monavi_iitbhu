from pdfminer.high_level import extract_text

def extract_text_from_pdf(pdf_path: str) -> str:
    try:
        return extract_text(pdf_path).strip()
    except Exception:
        return ""
