# LM Studio MCP Bridge - Конфигурация Memory Service

## 📋 Конфиг для `mcp.json`

Скопируйте этот конфиг в ваш файл конфигурации LM Studio:

### Путь к файлу конфигурации (обычно):
```bash
/Users/nearbe/Library/Application Support/lmstudio-mcp/mcp-config.json
```

Или создайте свой собственный файл:
```bash
/Users/nearbe/repositories/Chat/ai/mcp/memory-service/lmstudio-mcp-config.json
```

### Конфигурация (JSON):

```json
{
  "mcpServers": {
    "memory-service": {
      "command": "/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python",
      "args": ["-m", "mcp_memory_service.server"],
      "env": {
        "MCP_MEMORY_STORAGE_BACKEND": "sqlite_vec",
        "MCP_HTTP_ENABLED": "true",
        "MCP_ALLOW_ANONYMOUS_ACCESS": "true"
      }
    }
  }
}
```

### Использование в LM Studio:

1. **Откройте LM Studio** → вкладка MCP Server
2. Нажмите **"Add MCP Server"** или редактируйте `mcp-config.json`
3. Вставьте конфигурацию выше
4. Сохраните и перезапустите LM Studio (если требуется)

---

## 🔧 Альтернативный вариант - через CLI

Если у вас есть CLI инструмент для управления MCP в LM Studio:

```bash
# Установить Memory Service как MCP сервер
lmstudio mcp install memory-service \
  --command /Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python \
  --args "-m,mcp_memory_service.server" \
  --env MCP_MEMORY_STORAGE_BACKEND=sqlite_vec

# Или через скрипт установки
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service
source .venv/bin/activate
python scripts/installation/install.py --quick
```

---

## 📍 Компоненты конфигурации

| Параметр | Значение | Описание |
|----------|----------|----------|
| `command` | `/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python` | Python интерпретатор из venv |
| `args` | `-m mcp_memory_service.server` | Запуск модуля server.py |
| `MCP_MEMORY_STORAGE_BACKEND` | `sqlite_vec` | Локальное SQLite хранилище с векторами |
| `MCP_HTTP_ENABLED` | `true` | Включить веб-дашборд |
| `MCP_ALLOW_ANONYMOUS_ACCESS` | `true` | Разрешить доступ без аутентификации (локально) |

---

## ✅ Проверка подключения

После добавления конфигурации:

1. **Проверьте что сервер запущен:**
   ```bash
   curl http://localhost:8000/api/health
   # {"status":"healthy","version":"10.18.1",...}
   ```

2. **Откройте LM Studio** и проверьте статус MCP серверов

3. **Протестируйте подключение:**
   - Откройте DevTools в LM Studio (если есть)
   - Проверьте что Memory Service отображается как активный
   - Попробуйте использовать инструменты Memory Service

---

## 🐛 Решение проблем

### Сервер не запускается

```bash
# Проверьте путь к venv
ls -la /Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python

# Активируйте venv вручную и запустите сервер
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service
source .venv/bin/activate
python -m mcp_memory_service.server --http

# Проверьте ошибки в логах
```

### LM Studio не видит MCP сервер

1. Перезапустите LM Studio после изменения конфигурации
2. Проверьте путь к файлу `mcp-config.json` (может отличаться)
3. Убедитесь что JSON синтаксически корректен:
   ```bash
   python -c "import json; json.load(open('lmstudio-mcp-config.json'))"
   ```

### Ошибка при запуске Python модуля

```bash
# Проверьте установку зависимостей
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service
.venv/bin/pip show mcp-memory-service

# Если не установлен, установите заново:
.venv/bin/pip install -e .
```

---

## 📚 Дополнительные ресурсы

- **Полная документация**: https://github.com/doobidoo/mcp-memory-service/wiki
- **Web Dashboard**: http://localhost:8000/
- **API Docs**: http://localhost:8000/api/docs
