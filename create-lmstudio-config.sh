#!/bin/bash
# Скрипт для создания конфигурационного файла LM Studio MCP Bridge

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/lmstudio-mcp-config.json"

echo "🔧 Creating LM Studio MCP Config..."
echo ""

python3 << 'PYTHON_SCRIPT'
import json
import sys

config = {
    "mcpServers": {
        "memory-service": {
            "command": "/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python",
            "args": ["-m", "mcp_memory_service.server"],
            "env": {
                "MCP_MEMORY_STORAGE_BACKEND": "sqlite_vec"
            }
        }
    }
}

try:
    with open("/Users/nearbe/repositories/Chat/ai/mcp/memory-service/lmstudio-mcp-config.json", "w") as f:
        json.dump(config, f, indent=2)
    print("✅ Config created successfully!")
    sys.exit(0)
except Exception as e:
    print(f"❌ Error creating config: {e}")
    sys.exit(1)
PYTHON_SCRIPT

if [ $? -eq 0 ]; then
    echo ""
    echo "📄 Config file location:"
    echo "   $CONFIG_FILE"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Open LM Studio → MCP Server tab"
    echo "   2. Add or edit configuration to use this file"
    echo "   3. Restart LM Studio if needed"
    echo ""
else
    echo ""
    echo "❌ Failed to create config file"
    exit 1
fi
