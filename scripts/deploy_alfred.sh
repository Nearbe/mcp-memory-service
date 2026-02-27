#!/bin/bash
# MCP Memory Service Deployment Script for Alfred (Windows via SSH)
# Usage: ./deploy_alfred.sh [options]
# Options:
#   --install     Install fresh copy
#   --update      Pull latest changes and update dependencies
#   --start       Start the server
#   --stop        Stop the server
#   --restart     Restart the server
#   --status      Check if server is running

set -e

# Configuration
ALFRED_HOST="192.168.1.107"
ALFRED_USER="e"
REPO_PATH="/c/Repositories/mcp-memory-service"  # Git Bash path format on Windows
PYTHON_CMD="${REPO_PATH}/.venv/Scripts/python.exe"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS/Linux with SSH key authentication
check_ssh_access() {
    log_info "Checking SSH access to Alfred ($ALFRED_USER@$ALFRED_HOST)..."
    
    # Test connection
    if ssh -o ConnectTimeout=5 -o BatchMode=yes "$ALFRED_USER@$ALFRED_HOST" "echo 'Connection successful'" > /dev/null 2>&1; then
        log_info "✅ SSH access confirmed"
        return 0
    else
        log_error "❌ Cannot connect to Alfred via SSH"
        log_error "Please ensure:"
        log_error "  1. SSH key is configured (~/.ssh/id_ed25519)"
        log_error "  2. Public key is added to Alfred's authorized_keys"
        log_error "  3. Alfred is reachable at $ALFRED_HOST"
        return 1
    fi
}

# Deploy fresh installation
deploy_fresh() {
    log_info "🚀 Starting fresh deployment on Alfred..."
    
    # Create repository directory (using Git Bash path format for Windows)
    ssh "$ALFRED_USER@$ALFRED_HOST" "if not exist \"C:\\Repositories\" mkdir C:\\Repositories"
    
    # Clone repository using Git over SSH
    log_info "📦 Cloning mcp-memory-service..."
    ssh "$ALFRED_USER@$ALFRED_HOST" <<EOF
cd /c/Repositories || exit 1
if [ ! -d "mcp-memory-service" ]; then
    git clone https://github.com/Nearbe/mcp-memory-service.git
else
    log_warn "Repository already exists, skipping clone"
fi
EOF
    
    # Create virtual environment if not exists
    ssh "$ALFRED_USER@$ALFRED_HOST" <<EOF
cd /c/Repositories/mcp-memory-service || exit 1
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python -m venv .venv
else
    log_warn "Virtual environment already exists"
fi
EOF
    
    # Install dependencies
    log_info "📦 Installing dependencies..."
    ssh "$ALFRED_USER@$ALFRED_HOST" <<EOF
cd /c/Repositories/mcp-memory-service || exit 1
source .venv/Scripts/activate || { .venv/Scripts/Activate.ps1; }
pip install -e . --quiet
echo "Installation complete"
EOF
    
    log_info "✅ Fresh deployment completed!"
}

# Update existing installation
update_installation() {
    log_info "🔄 Updating mcp-memory-service on Alfred..."
    
    ssh "$ALFRED_USER@$ALFRED_HOST" <<EOF
cd /c/Repositories/mcp-memory-service || exit 1

# Pull latest changes
git pull origin main --quiet

# Update dependencies
source .venv/Scripts/activate || { .venv/Scripts/Activate.ps1; }
pip install -e . --upgrade --quiet

echo "Update complete"
EOF
    
    log_info "✅ Update completed!"
}

# Start the server
start_server() {
    log_info "🚀 Starting MCP Memory Service on Alfred..."
    
    # Kill any existing instances first
    stop_server quiet
    
    # Start in background using nohup or PowerShell job
    ssh "$ALFRED_USER@$ALFRED_HOST" <<EOF
cd /c/Repositories/mcp-memory-service || exit 1

# Try to start as a background process
nohup bash -c 'source .venv/Scripts/activate; python scripts/server/run_memory_server.py --http --port 8000 > /tmp/mcp-memory.log 2>&1 &' > /dev/null 2>&1 || \
    pwsh.exe -NoProfile -Command "cd '${REPO_PATH}'; .\\.venv\\Scripts\\python.exe scripts/server/run_memory_server.py --http --port 8000" > /tmp/mcp-memory.log 2>&1 &

sleep 2

# Check if server started
if curl -s http://localhost:8000/health | grep -q '"status":"ok"'; then
    echo "Server started successfully"
else
    log_warn "Server may not have started, check logs at /tmp/mcp-memory.log"
fi
EOF
    
    log_info "✅ Server started (check with --status)"
}

# Stop the server
stop_server() {
    local quiet=${1:-""}
    
    if [ "$quiet" != "quiet" ]; then
        log_info "⏹️  Stopping MCP Memory Service on Alfred..."
    fi
    
    # Kill Python processes running mcp-memory-server
    ssh "$ALFRED_USER@$ALFRED_HOST" <<EOF
# Try multiple methods to stop the server
pkill -f "run_memory_server.py" || true
taskkill /F /IM python.exe /FI "WINDOWTITLE eq *mcp*" 2>nul || true

sleep 1

# Verify it's stopped
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "Warning: Server still running, forcing shutdown"
    pkill -9 -f "run_memory_server.py"
fi
EOF
    
    if [ "$quiet" != "quiet" ]; then
        log_info "✅ Server stopped"
    fi
}

# Check server status
check_status() {
    log_info "📊 Checking MCP Memory Service status on Alfred..."
    
    ssh "$ALFRED_USER@$ALFRED_HOST" <<EOF
# Check if port 8000 is listening
if netstat -ano | findstr ":8000" >nul 2>&1; then
    echo "✅ Server is RUNNING on port 8000"
    
    # Try to get health status
    curl -s http://localhost:8000/health 2>/dev/null || echo "Health check failed, but server appears running"
else
    echo "❌ Server is NOT running (port 8000 not listening)"
fi

# Show Python processes related to MCP Memory Service
echo ""
echo "Python processes:"
ps aux | grep -i "memory_server" || tasklist | findstr python.exe || echo "No matching processes found"
EOF
}

# Tail server logs
tail_logs() {
    log_info "📋 Tailing MCP Memory Service logs..."
    
    ssh "$ALFRED_USER@$ALFRED_HOST" <<EOF
cd /c/Repositories/mcp-memory-service || exit 1

if [ -f "/tmp/mcp-memory.log" ]; then
    tail -f /tmp/mcp-memory.log
elif [ -f "logs/mcp-memory.log" ]; then
    tail -f logs/mcp-memory.log
else
    echo "No log file found. Server output goes to stdout/stderr."
fi
EOF
}

# Show usage
show_usage() {
    cat <<EOF
MCP Memory Service Deployment Script for Alfred (Windows)

Usage: $0 [command] [options]

Commands:
  install       Deploy fresh installation
  update        Pull latest changes and update dependencies
  start         Start the server
  stop          Stop the server
  restart       Restart the server (stop + start)
  status        Check if server is running
  logs          Tail server logs (follow mode)

Options:
  --help        Show this help message

Examples:
  $0 install      # Fresh deployment
  $0 update       # Update to latest version
  $0 restart      # Restart the service
  $0 status       # Check current status

SSH Configuration:
- Host: ${ALFRED_USER}@${ALFRED_HOST}
- Repository: https://github.com/Nearbe/mcp-memory-service.git
- Install Path: C:\\Repositories\\mcp-memory-service
- Server Port: 8000

EOF
}

# Main script logic
main() {
    local command="${1:-help}"
    
    case "$command" in
        install)
            check_ssh_access || exit 1
            deploy_fresh
            ;;
        update)
            check_ssh_access || exit 1
            update_installation
            ;;
        start)
            check_ssh_access || exit 1
            start_server
            ;;
        stop)
            check_ssh_access || exit 1
            stop_server
            ;;
        restart)
            check_ssh_access || exit 1
            stop_server
            sleep 2
            start_server
            ;;
        status)
            check_status
            ;;
        logs)
            tail_logs
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
