from PIL import Image
import pytesseract

def extract_text_from_image(image_path: str) -> str:
    """
    OCR text from medical images (reports, scans).
    """
    img = Image.open(image_path)
    text = pytesseract.image_to_string(img)
    return text.strip()
