#!/bin/bash
# Quick status check for MCP Memory Service

echo "🔍 Checking MCP Memory Service Status..."
echo ""

# Check if server is running on port 8000
if lsof -i :8000 > /dev/null 2>&1; then
    echo "✅ Server is RUNNING on port 8000"
    echo ""
    
    # Get health status via API
    echo "🏥 Health Check:"
    curl -s http://localhost:8000/api/health | python3 -m json.tool 2>/dev/null || curl -s http://localhost:8000/api/health
    
    echo ""
    echo "🌐 Access points:"
    echo "   Dashboard:     http://localhost:8000/"
    echo "   API Docs:      http://localhost:8000/api/docs"
    echo "   OpenAPI JSON:  http://localhost:8000/openapi.json"
    
    echo ""
    echo "📊 Active processes:"
    lsof -i :8000 | grep LISTEN || true
    
else
    echo "❌ Server is NOT running on port 8000"
    echo ""
    echo "💡 To start the server, run one of these commands:"
    echo ""
    echo "   # Option 1: Using venv directly"
    echo "   cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service"
    echo "   source .venv/bin/activate"
    echo "   python -m mcp_memory_service.server --http"
    echo ""
    echo "   # Option 2: Using run_http_server.py"
    echo "   cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service"
    echo "   .venv/bin/python scripts/server/run_http_server.py"
    echo ""
    echo "   # Option 3: Using start script (if executable)"
    echo "   ./start_server.sh"
fi
