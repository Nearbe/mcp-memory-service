# 🚀 MCP Memory Service Deployment Guide for Alfred (Windows RTX 4080)

**Created:** 2026-01-30  
**Target Machine:** Alfred @ 192.168.1.107  
**SSH User:** e@192.168.1.107

---

## 📋 Quick Summary

This guide helps you deploy **MCP Memory Service**, **LangGraph Agents**, and **AutoGen Workers** across your
infrastructure:

| Machine                                 | Role            | GPU             | RAM       | Purpose                        |
|-----------------------------------------|-----------------|-----------------|-----------|--------------------------------|
| **Master** (M4 Max)                     | Dev workstation | 128GB Unified   | macOS     | Development, testing           |
| **Alfred** (RTX 4080)                   | AI Server       | RTX 4080 16GB   | 64GB DDR5 | Production servers, agents     |
| **Galathea** (RTX 4060 Ti)              | Secondary AI    | RTX 4060 Ti 8GB | 32GB DDR4 | Load balancing, parallel tasks |
| **Saint Celestine** (iPhone 16 Pro Max) | Mobile client   | A17 Pro GPU     | 8GB iOS   | Offline mobile access          |

---

## 🎯 What You'll Deploy on Alfred

### 1. MCP Memory Service (Primary)

- **Backend:** SQLite-vec with ONNX embeddings (`all-MiniLM-L6-v2`)
- **Port:** 8000
- **Features:** Semantic search, memory consolidation, quality scoring
- **Performance:** ~5ms embedding generation, <10ms semantic search

### 2. LangGraph Agents (Production)

- **LLM Backend:** Local models via LM Studio or Ollama
- **Memory Integration:** Shared MCP Memory Service for all agents
- **Use Case:** Real-time agent orchestration with persistent memory

### 3. AutoGen Workers (Optional Secondary)

- **Distribution:** Alfred handles primary, Galathea can handle parallel workers
- **Load Balancing:** Split tasks between servers based on capacity

---

## 🛠️ Deployment Options

### Option A: Automated SSH Deployment (Recommended)

**Prerequisites:**

1. SSH key authentication configured (`~/.ssh/id_ed25519`)
2. Public key added to Alfred's `C:\Users\e\.ssh\authorized_keys`
3. Git Bash or WSL installed on Master for running the script

**Steps:**

```bash
# 1. Make script executable (on macOS/Linux)
chmod +x scripts/deploy_alfred.sh

# 2. Fresh installation
./scripts/deploy_alfred.sh install

# 3. Check status
./scripts/deploy_alfred.sh status

# 4. Start server
./scripts/deploy_alfred.sh start

# 5. View logs (follow mode)
./scripts/deploy_alfred.sh logs
```

**What the script does:**

- Creates repository directory on Alfred (`C:\Repositories\mcp-memory-service`)
- Clones your fork from GitHub
- Sets up Python virtual environment
- Installs MCP Memory Service dependencies
- Starts server in background mode

---

### Option B: Manual PowerShell Deployment (If SSH not available)

**Steps:**

1. **Connect to Alfred via RDP or direct console access**

2. **Open PowerShell 7 (`pwsh.exe`)** - NOT legacy PowerShell 5.1!
   ```powershell
   # Verify version
   $PSVersionTable.PSVersion
   # Should show 7.x, not 5.1
   ```

3. **Clone repository**
   ```powershell
   New-Item -ItemType Directory -Force -Path 'C:\Repositories'
   cd C:\Repositories
   git clone https://github.com/Nearbe/mcp-memory-service.git mcp-memory-service
   cd mcp-memory-service
   ```

4. **Install Python 3.12+** (if not already installed)
   ```powershell
   winget install Python.Python.3.12
   python --version
   ```

5. **Create virtual environment**
   ```powershell
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   ```

6. **Install dependencies**
   ```powershell
   pip install -e .
   ```

7. **Configure environment variables** (add to `$PROFILE`)
   ```powershell
   notepad $PROFILE
   ```

   Add:
   ```powershell
   $env:MCP_MEMORY_STORAGE_BACKEND = "sqlite_vec"
   $env:MCP_EMBEDDING_MODEL = "all-MiniLM-L6-v2"
   $env:MCP_MEMORY_USE_ONNX = "true"
   $env:HF_HOME = "C:\Users\nearbe\.cache\huggingface"
   $env:MCP_QUALITY_BOOST_ENABLED = "true"
   ```

8. **Start server**
   ```powershell
   python scripts/server/run_memory_server.py --http --port 8000
   ```

---

## ✅ Verification Tests

After deployment, verify everything is working:

### Test 1: Server Health Check

```bash
# From Master machine
curl http://192.168.1.107:8000/health

# Expected response: {"status": "ok"}
```

### Test 2: Store a Memory

```bash
curl -X POST http://192.168.1.107:8000/api/memories \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Test memory from deployment",
    "tags": ["test", "deployment"],
    "type": "observation"
  }'
```

### Test 3: Semantic Search

```bash
curl -X POST http://192.168.1.107:8000/api/memories/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "deployment test",
    "limit": 5
  }'

# Should return your test memory with high relevance score
```

### Test 4: Web Dashboard (Optional)

Open in browser: `http://192.168.1.107:8000`

Should display the MCP Memory Service dashboard with:

- Memory statistics
- Search interface
- Analytics

---

## 🔧 Configuration Files

### Claude Desktop Integration (On Master)

Create/edit `~/.claude/settings.json`:

```json
{
  "_comment": "MCP Memory Service - Remote connection to Alfred",
  "mcpServers": {
    "memory-http": {
      "transportType": "http",
      "url": "http://192.168.1.107:8000/mcp"
    }
  }
}
```

### PowerShell Profile (On Alfred)

Create/edit `C:\Users\nearbe\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`:

```powershell
# MCP Memory Service environment
$env:MCP_MEMORY_STORAGE_BACKEND = "sqlite_vec"
$env:MCP_EMBEDDING_MODEL = "all-MiniLM-L6-v2"
$env:MCP_MEMORY_USE_ONNX = "true"
$env:HF_HOME = "C:\Users\nearbe\.cache\huggingface"

# Performance optimizations for RTX 4080
$env:PYTORCH_ENABLE_MPS_FALLBACK = "1"
$env:PYTORCH_CUDA_ALLOC_CONF = "max_split_size_mb:128"
```

---

## 📊 Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Development (Master)                      │
│  M4 Max (16-core CPU, 128GB RAM)                           │
│                                                             │
│  ├── LangGraph Agent Orchestration                         │
│  ├── AutoGen Coordinator                                   │
│  └── Document Preprocessing                                │
└─────────────────────┬──────────────────────────────────────┘
                      │ HTTP API (REST)
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  Production Server (Alfred)                  │
│  Ryzen 9 7950X, RTX 4080 16GB, 64GB RAM                    │
│                                                             │
│  ┌──────────────────┬──────────────────────────────────┐   │
│  │ MCP Memory       │ LangGraph Agents                 │   │
│  │ Service          │ - Research Agent                 │   │
│  │ Port: 8000       │ - Code Analysis Agent            │   │
│  │ SQLite-vec +     │ - Planning Agent                 │   │
│  │ ONNX Embeddings  │ - All share MCP Memory           │   │
│  └──────────────────┴──────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────┬──────────────────────────────────┐   │
│  │ AutoGen Workers  │ LM Studio / Ollama               │   │
│  │ Port: 6000       │ - Local LLM inference            │   │
│  │ Parallel tasks   │ - 7B-13B parameter models        │   │
│  └──────────────────┴──────────────────────────────────┘   │
└─────────────────────┬──────────────────────────────────────┘
                      │ WiFi / SSH
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Secondary Server (Galathea)                     │
│  Ryzen 7 5800X, RTX 4060 Ti 8GB, 32GB RAM                  │
│                                                             │
│  └── Additional AutoGen Workers for load balancing         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              Mobile Client (Saint Celestine)                 │
│  iPhone 16 Pro Max, A17 Pro GPU, iOS 19                    │
│                                                             │
│  └── Offline-capable memory client with sync               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Maintenance Commands

### Update to Latest Version

```bash
./scripts/deploy_alfred.sh update
```

### Restart Server (Zero Downtime)

```bash
# Stop gracefully
./scripts/deploy_alfred.sh stop

# Wait 2 seconds for cleanup
sleep 2

# Start fresh
./scripts/deploy_alfred.sh start
```

### View Logs

```bash
# Follow mode (Ctrl+C to exit)
./scripts/deploy_alfred.sh logs

# Or check specific log file on Alfred
ssh e@192.168.1.107 "cat /tmp/mcp-memory.log | tail -50"
```

### Check Resource Usage

```bash
# SSH into Alfred and check resources
ssh e@192.168.1.107 "Get-Process python | Select-Object CPU,WorkingSet,Path"
```

---

## 🎯 Next Steps After Basic Deployment

### Phase 1: MCP Memory Service ✅ (This guide)

- [x] Deploy to Alfred via SSH or manual installation
- [x] Verify server is running and accessible
- [x] Test basic memory operations

### Phase 2: LangGraph Integration

- [ ] Create orchestrator agent with shared memory
- [ ] Implement multi-agent collaboration patterns
- [ ] Add memory-aware decision nodes

### Phase 3: AutoGen Setup (Alfred + Galathea)

- [ ] Install AutoGen on both servers
- [ ] Configure distributed worker groups
- [ ] Set up load balancing between Alfred and Galathea

### Phase 4: RAG Pipeline

- [ ] Implement document ingestion workflow
- [ ] Connect to MCP Memory Service via HTTP API
- [ ] Test end-to-end retrieval and generation

---

## 📚 Additional Documentation

- **Hardware Analysis**: `../../.ai/docs/architecture/hardware-specs-and-deployment-strategy.md`
- **Setup Instructions**: `examples/setup_alfred_windows.md`
- **LM Studio & Embeddings**: See hardware strategy doc for embedding model recommendations
- **Troubleshooting**: Check logs or refer to MCP Memory Service docs

---

## 🆘 Troubleshooting

### Issue: SSH Connection Refused

**Solution:**

```bash
# Check if Alfred is reachable
ping 192.168.1.107

# Verify SSH key permissions
chmod 600 ~/.ssh/id_ed25519
chmod 700 ~/.ssh

# Test connection explicitly
ssh -v e@192.168.1.107 "echo 'Connection successful'"
```

### Issue: Python Not Found on Alfred

**Solution:**

- Install Python via `winget install Python.Python.3.12`
- Or use Windows PowerShell to run commands directly

### Issue: Port 8000 Already in Use

**Solution:**

```powershell
# On Alfred, find and kill process using port 8000
netstat -ano | findstr ":8000"
taskkill /PID <process_id> /F

# Or use different port
python scripts/server/run_memory_server.py --http --port 8001
```

---

## 📞 Support & Resources

- **MCP Memory Service Docs**: https://github.com/Nearbe/mcp-memory-service/tree/main/docs
- **LM Studio**: https://lmstudio.ai/
- **LangGraph**: https://langchain-ai.github.io/langgraph/
- **AutoGen**: https://microsoft.github.io/autogen/

---

*Last updated: 2026-01-30*  
*Maintained by: Nearbe*
