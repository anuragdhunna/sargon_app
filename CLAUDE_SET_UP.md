# 🚀 Claude Code Setup (Sargon App)

This project uses **Free Claude Code (FCC)** to route AI requests through a local proxy, allowing you to use high-speed models like Google Gemini and NVIDIA NIM for free.

## 🛠️ Quick Links
- **Proxy Admin UI**: [http://127.0.0.1:8082/admin](http://127.0.0.1:8082/admin)
- **Local Proxy URL**: `http://localhost:8082`
- **Auth Token**: `freecc`

## ⚡ Performance Optimization (Speed Up Claude)
If Claude is feeling slow, follow these steps:

### 1. Change the Model (The "Flash" Secret)
The current NVIDIA NIM models can be slow. For the fastest experience:
1. Go to the [Admin UI Settings](http://127.0.0.1:8082/admin).
2. Set `MODEL_SONNET` to: `gemini/models/gemini-2.0-flash-exp`
3. Ensure you have a **Google AI Studio Key** added in the "Providers" section.

### 2. Restart the Proxy
If the server has been running for days, restart it:
```bash
# Kill old server and start fresh
pkill -f fcc-server
fcc-server
```

## ⚙️ environment Variables
These are configured in your VS Code `settings.json` under `claudeCode.environmentVariables`:
- `ANTHROPIC_BASE_URL`: `http://localhost:8082`
- `ANTHROPIC_AUTH_TOKEN`: `freecc`

## 🧩 ECC Skills
The project is integrated with **Everything Claude Code (ECC)**. You can invoke skills like:
- `flutter-dart-code-review`
- `frontend-patterns`
- `backend-patterns`

To use a skill:
`"Review this file using the flutter-dart-code-review skill"`
