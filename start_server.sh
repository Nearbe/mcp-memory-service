#!/bin/bash
# Start MCP Memory Service locally

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PATH="$SCRIPT_DIR/.venv"
PROJECT_ROOT="$SCRIPT_DIR"

echo "🚀 Starting MCP Memory Service..."
echo ""

# Check if venv exists
if [ ! -d "$VENV_PATH" ]; then
    echo "❌ Virtual environment not found at $VENV_PATH"
    echo "Running: python3 -m venv .venv && pip install -e ."
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -e .
fi

# Activate virtual environment
echo "✅ Activating virtual environment..."
source "$VENV_PATH/bin/activate"

# Check if .env exists
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "⚠️  .env file not found. Creating default configuration..."
    cat > "$SCRIPT_DIR/.env" << 'EOF'
MCP_MEMORY_STORAGE_BACKEND=sqlite_vec
MCP_HTTP_ENABLED=true
MCP_HTTP_PORT=8000
MCP_ALLOW_ANONYMOUS_ACCESS=true
EOF
    echo "✅ Created .env file with default settings"
fi

# Start server
echo ""
echo "🌐 Starting MCP Memory Service on port 8000..."
echo "💻 Dashboard: http://localhost:8000/"
echo "📚 API Docs: http://localhost:8000/api/docs"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Run server with environment variables loaded
set -a  # Automatically export all variables
source "$SCRIPT_DIR/.env"
set +a  # Disable automatic export

"$VENV_PATH/bin/python" -m mcp_memory_service.server --http
