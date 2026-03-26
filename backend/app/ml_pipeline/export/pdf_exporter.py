from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from textwrap import wrap
from pathlib import Path
from datetime import datetime, timezone, timedelta

# Indian Standard Time (IST) is UTC+5:30
IST = timezone(timedelta(hours=5, minutes=30))


def get_ist_now() -> datetime:
    """Get current datetime in IST"""
    return datetime.now(IST)


def export_summary_to_pdf(
    summary_text: str,
    output_path: str = "clinical_summary.pdf"
):
    """
    Export clinical summary text to a PDF file.
    """

    output_path = Path(output_path)
    c = canvas.Canvas(str(output_path), pagesize=A4)

    width, height = A4
    x_margin = 50
    y_margin = 50
    max_width = width - 2 * x_margin

    # Title
    c.setFont("Helvetica-Bold", 16)
    c.drawString(x_margin, height - y_margin, "Clinical Case Summary")

    # Metadata
    c.setFont("Helvetica", 9)
    c.drawString(
        x_margin,
        height - y_margin - 20,
        f"Generated on: {get_ist_now().strftime('%d %b %Y, %H:%M')} IST"
    )

    # Body text
    y = height - y_margin - 50
    c.setFont("Helvetica", 10)

    for line in summary_text.split("\n"):
        wrapped_lines = wrap(line, 95)
        if not wrapped_lines:
            y -= 12
            continue

        for wline in wrapped_lines:
            if y < y_margin:
                c.showPage()
                c.setFont("Helvetica", 10)
                y = height - y_margin

            c.drawString(x_margin, y, wline)
            y -= 12

    c.save()
    return str(output_path)
