# MCP Memory Service - Локальный Сервер

## ✅ Статус развертывания

Сервер успешно запущен и работает локально!

### 📊 Активные сервисы

1. **MCP Server** (Python)
   - Порт: 8000
   - Хранилище: SQLite-vec (локальное)
   - Статус: ✅ Работает
   
2. **HTTP Dashboard** (FastAPI + Web UI)
   - URL: http://localhost:8000/
   - API Docs: http://localhost:8000/api/docs
   - OpenAPI JSON: http://localhost:8000/openapi.json
   - Статус: ✅ Работает

---

## 🚀 Управление сервером

### Запуск MCP сервера (если остановлен)

```bash
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service
source .venv/bin/activate
python -m mcp_memory_service.server --http
```

Или через run_http_server.py:

```bash
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service
.venv/bin/python scripts/server/run_http_server.py
```

### Остановка сервера

Найдите процесс и завершите его:

```bash
# Найти PID процесса на порту 8000
lsof -i :8000 | grep LISTEN

# Завершить процесс (замените PID)
kill <PID>
```

---

## 🔧 Конфигурация

### Переменные окружения (.env)

Файл: `ai/mcp/memory-service/.env`

Основные настройки:
- `MCP_MEMORY_STORAGE_BACKEND=sqlite_vec` - локальное хранилище
- `MCP_HTTP_ENABLED=true` - веб-интерфейс включен
- `MCP_HTTP_PORT=8000` - порт HTTP сервера
- `MCP_ALLOW_ANONYMOUS_ACCESS=true` - доступ без аутентификации (локально)

### Виртуальное окружение

Путь: `/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv`

Установка зависимостей:
```bash
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service
.venv/bin/pip install -e .
```

---

## 📡 API Интерфейс

### Основные эндпоинты

#### Хранение памяти
```bash
POST http://localhost:8000/api/memories
{
  "content": "Текст памяти",
  "tags": ["тег1", "тег2"],
  "metadata": {"key": "value"}
}
```

#### Поиск памяти
```bash
POST http://localhost:8000/api/memories/search
{
  "query": "поисковый запрос",
  "tags": ["tag"],
  "limit": 10
}
```

#### Получение API документации
- Swagger UI: http://localhost:8000/api/docs
- OpenAPI JSON: http://localhost:8000/openapi.json

---

## 🔗 Интеграция с IDE/Инструментами

### Claude Desktop Configuration

Файл конфигурации (macOS):
`~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "memory": {
      "command": "/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python",
      "args": ["-m", "mcp_memory_service.server"],
      "env": {
        "MCP_MEMORY_STORAGE_BACKEND": "sqlite_vec"
      }
    }
  }
}
```

### Cursor / VS Code

Используйте ту же конфигурацию, что и для Claude Desktop.

### JetBrains IDE (IntelliJ IDEA)

Для JetBrains IDE с поддержкой MCP:
1. Откройте настройки IDE
2. Найдите раздел "MCP Clients" или "AI Tools"
3. Добавьте MCP сервер с командой:
   ```
   /Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python -m mcp_memory_service.server
   ```

### HTTP API (любое приложение)

```python
import httpx

BASE_URL = "http://localhost:8000"

# Store memory
async with httpx.AsyncClient() as client:
    response = await client.post(
        f"{BASE_URL}/api/memories",
        json={
            "content": "Новая память",
            "tags": ["test"]
        }
    )
    print(response.json())

# Search memories
async with httpx.AsyncClient() as client:
    response = await client.post(
        f"{BASE_URL}/api/memories/search",
        json={
            "query": "поиск памяти",
            "limit": 10
        }
    )
    print(response.json())
```

---

## 📁 Структура проекта

```
/Users/nearbe/repositories/Chat/ai/mcp/memory-service/
├── .env                          # Конфигурация окружения
├── .venv/                        # Виртуальное окружение Python
├── src/mcp_memory_service/       # Исходный код сервера
│   ├── mcp_server.py             # MCP сервер (для Claude, Cursor)
│   ├── server.py                 # Основной модуль сервера
│   └── web/app.py                # FastAPI веб-интерфейс
├── scripts/server/
│   ├── run_memory_server.py      # Скрипт запуска MCP сервера
│   └── run_http_server.py        # Скрипт запуска HTTP сервера
└── tests/                        # Тесты
```

---

## 🧪 Тестирование API

### Проверка здоровья сервера
```bash
curl http://localhost:8000/api/health
# {"status":"healthy","version":"10.18.1",...}
```

### Добавить память через API
```bash
curl -X POST http://localhost:8000/api/memories \
  -H "Content-Type: application/json" \
  -d '{"content": "Test memory", "tags": ["test"]}'
```

### Поиск памяти
```bash
curl -X POST http://localhost:8000/api/memories/search \
  -H "Content-Type: application/json" \
  -d '{"query": "test"}'
```

---

## 📊 Web Dashboard Features

Доступны следующие разделы в веб-интерфейсе (http://localhost:8000/):

1. **Dashboard** - Общий обзор и статистика
2. **Search** - Поиск по памяти с семантическим поиском
3. **Browse** - Просмотр всех сохраненных воспоминаний
4. **Documents** - Управление загруженными документами (PDF, MD, TXT)
5. **Manage** - Настройки и конфигурация
6. **Analytics** - Аналитика и метрики
7. **Knowledge Graph** (v9.2.0+) - Интерактивная визуализация связей между памятью

### Знаниеграф Dashboard

- D3.js force-directed graph visualization
- 6 типов отношений: causes, fixes, contradicts, supports, follows, related
- Многоязычная поддержка (7 языков)
- Темная тема

---

## 🔒 Безопасность

В локальной разработке отключена аутентификация (`MCP_ALLOW_ANONYMOUS_ACCESS=true`).

Для продакшена:
1. Включите API ключ авторизацию: `MCP_API_KEY=your-secret-key`
2. Или используйте OAuth 2.1: `MCP_OAUTH_ENABLED=true`
3. Настройте обратный прокси (Nginx/Caddy) с SSL

---

## 📖 Документация

- [Полная документация](https://github.com/doobidoo/mcp-memory-service/wiki)
- [API Reference](docs/api.md)
- [Архитектура](docs/architecture.md)
- [CHANGELOG.md](CHANGELOG.md)

---

## 🐛 Troubleshooting

### Сервер не запускается

1. Проверьте, что venv активирован:
   ```bash
   cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service
   source .venv/bin/activate
   python -m mcp_memory_service.server --http
   ```

2. Проверьте порты:
   ```bash
   lsof -i :8000
   ```

3. Перезапустите сервер:
   ```bash
   killall python  # Осторожно! Завершит все Python процессы
   ```

### SQLite-vec проблемы на macOS

Если возникают ошибки с `enable_load_extension`:
```bash
# Используйте Homebrew Python вместо системного
brew install python@3.12
```

Или используйте Cloudflare backend:
```bash
MCP_MEMORY_STORAGE_BACKEND=cloudflare
```

---

## 🎯 Следующие шаги

1. **Проверить интеграцию с IDE** - Добавьте MCP сервер в вашу IDE
2. **Начать использовать Web Dashboard** - http://localhost:8000/
3. **Изучить API документацию** - http://localhost:8000/api/docs
4. **Настроить автоматический запуск** - Используйте systemd, launchd или Task Scheduler

---

**Сервер готов к использованию! 🎉**
