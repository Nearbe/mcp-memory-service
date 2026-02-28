#!/bin/bash
# Stop MCP Memory Service

echo "🛑 Stopping MCP Memory Service..."

# Find and kill processes on port 8000
PID=$(lsof -t -i:8000)

if [ ! -z "$PID" ]; then
    echo "Found process(es) on port 8000:"
    lsof -i :8000
    echo ""
    echo "Terminating..."
    kill -9 $PID 2>/dev/null || true
    echo "✅ Stopped processes on port 8000"
else
    echo "No process found running on port 8000"
fi
