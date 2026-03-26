#!/bin/bash
# Backend Setup Script

echo "🚀 Clinical Dashboard Backend Setup"
echo "===================================="

# Install dependencies
echo ""
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt

# Clear Python cache
echo ""
echo "🧹 Clearing Python cache..."
find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Create .env file with your configuration"
echo "2. Run: uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
echo "3. Access Swagger UI at: http://localhost:8000/docs"
