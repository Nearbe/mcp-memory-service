#!/bin/bash
# Install MCP Memory Service on Alfred (macOS/Linux)

set -e

echo "🚀 Installing MCP Memory Service..."
echo ""

# Navigate to project directory
cd /Users/nearbe/repositories/Chat/.ai/mcp/mcp-memory-service

# Check if venv exists, create if not
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate venv and install dependencies
echo "⬇️  Installing dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -e .

echo ""
echo "✅ Installation complete!"
echo ""
echo "📌 To start the server:"
echo "   source venv/bin/activate"
echo "   python scripts/server/run_http_server.py"
echo ""
echo "📌 Or run in background (nohup):"
echo "   nohup source venv/bin/activate && python scripts/server/run_http_server.py > server.log 2>&1 &"
echo ""
echo "📌 Server will be available at:"
echo "   http://localhost:8000"
echo "   https://localhost:8000 (with self-signed certificate)"
