# 🩺 HIA — Health Insights Agent

> Upload a blood report. Get a detailed AI-powered health analysis. Ask follow-up questions. All in one place.


<p align="center">
  <a href="#features">Features</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#docker">Docker</a> •
  <a href="#project-structure">Project Structure</a> •
  <a href="#contributing">Contributing</a>
</p>

<p align="center">
  <img src="/public/HIA_demo.gif" alt="HIA Demo" width="80%">
</p>

---

## What is HIA?

HIA is an AI agent that reads your blood test reports and turns raw lab numbers into clear, actionable health insights. It uses a multi-agent architecture — one agent specializes in deep report analysis, another powers a RAG-based Q&A chat so you can ask anything about your results.

No medical jargon overwhelm. No guessing what your numbers mean.

---

## Features

### 🤖 Dual-Agent Architecture
- **Analysis Agent** — Performs in-depth report analysis using in-context learning from prior analyses and a built-in medical knowledge base
- **Chat Agent** — RAG-powered Q&A (FAISS + HuggingFace embeddings) so you can ask natural-language follow-up questions about your report

### ⚡ Multi-Model Cascade via Groq
Automatically falls back across models if one is unavailable:
`llama-4-maverick-17b` → `llama-3.3-70b` → `llama-3.1-8b` → `llama3-70b`

### 🗂️ Session Management
- Create and switch between multiple analysis sessions
- Each session stores the report, full analysis, and follow-up chat messages in Supabase
- Report text is persisted so the chat agent works even after page reload

### 📄 Flexible Report Input
- Upload your own PDF (up to 20MB, max 50 pages)
- Or use the built-in sample blood report for a quick demo

### 🔐 Secure Auth
- Supabase Auth (sign up / sign in)
- Configurable session timeout
- Daily analysis cap (default: 15/day) with a live countdown in the sidebar

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Streamlit 1.42+ |
| LLM / Analysis | Groq (multi-model cascade) |
| Follow-up Chat | LangChain + FAISS + HuggingFace (`all-MiniLM-L6-v2`) |
| Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth / Gotrue |
| PDF Parsing | PDFPlumber + filetype |

---

## Getting Started

### Prerequisites

- Python 3.8+
- A [Supabase](https://supabase.com) account
- A [Groq](https://console.groq.com) API key

### 1. Clone the repo

```bash
git clone https://github.com/aneklavya/Health-Insights-Agent-Hia.git
cd Health-Insights-Agent-Hia
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure secrets

Create `.streamlit/secrets.toml`:

```toml
SUPABASE_URL = "your-supabase-url"
SUPABASE_KEY = "your-supabase-key"
GROQ_API_KEY  = "your-groq-api-key"
```

### 4. Set up the database

Run the SQL script in Supabase's SQL editor:

```
public/db/script.sql
```

This creates three tables: `users`, `chat_sessions`, and `chat_messages`.

> **Tip:** To skip email confirmation during development, go to **Supabase → Authentication → Providers → Email** and disable "Confirm email".

![Database Schema](/public/db/schema.png)

### 5. Run the app

```bash
streamlit run src/main.py
```

---

## Docker

You can also run HIA in a container. See [`Dockerfile`](./Dockerfile) in the repo.

### Build the image

```bash
docker build -t hia .
```

### Run with environment variables

```bash
docker run -p 8501:8501 \
  -e SUPABASE_URL="your-supabase-url" \
  -e SUPABASE_KEY="your-supabase-key" \
  -e GROQ_API_KEY="your-groq-api-key" \
  hia
```

Then open [http://localhost:8501](http://localhost:8501).

> The container reads `SUPABASE_URL`, `SUPABASE_KEY`, and `GROQ_API_KEY` directly from environment variables — no config file needed.

---

## Project Structure

```
hia/
├── Dockerfile
├── requirements.txt
├── src/
│   ├── main.py                  # App entry point — chat UI and session flow
│   ├── agents/
│   │   ├── analysis_agent.py    # Report analysis, knowledge base, in-context learning
│   │   ├── chat_agent.py        # RAG pipeline: embeddings, FAISS, query contextualization
│   │   └── model_manager.py     # Groq multi-model cascade and fallback logic
│   ├── auth/
│   │   ├── auth_service.py      # Supabase auth, session validation, message persistence
│   │   └── session_manager.py   # Session init, timeout, create/delete chat sessions
│   ├── components/
│   │   ├── analysis_form.py     # Report source picker, patient form, analysis trigger
│   │   ├── auth_pages.py        # Login / signup pages
│   │   ├── sidebar.py           # Session list, daily limit counter, logout
│   │   ├── header.py            # User greeting
│   │   └── footer.py            # Footer component
│   ├── config/
│   │   ├── app_config.py        # Limits: upload size, pages, daily analyses, timeout
│   │   ├── prompts.py           # Specialist prompts for report analysis
│   │   └── sample_data.py       # Sample blood report for quick testing
│   ├── services/
│   │   └── ai_service.py        # Analysis + chat entry points; vector store caching
│   └── utils/
│       ├── validators.py        # Email, password, PDF file and content validation
│       └── pdf_extractor.py     # PDF text extraction and page validation
└── public/
    └── db/
        ├── script.sql           # Supabase schema
        └── schema.png           # Schema diagram
```

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow, coding standards, and how to submit a pull request.

---

## License

MIT — see [LICENSE](https://github.com/harshhh28/hia/blob/main/LICENSE) for details.

---

<p align="center">Built by <a href="https://harshgajjar.vercel.app">Harsh Gajjar</a></p>