# ── Stage 1: Builder ──────────────────────────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ── Stage 2: Runtime ──────────────────────────────────────────────────────────
FROM python:3.11-slim

WORKDIR /app

# Copy installed packages from builder stage
COPY --from=builder /install /usr/local

# Copy application source
COPY src/ ./src/
COPY public/ ./public/

# Streamlit server config (no secrets here)
RUN mkdir -p /app/.streamlit && printf '\
[server]\n\
port = 8501\n\
address = "0.0.0.0"\n\
headless = true\n\
enableCORS = false\n\
enableXsrfProtection = true\n\
\n\
[browser]\n\
gatherUsageStats = false\n\
' > /app/.streamlit/config.toml

# ── Secrets via environment variables ─────────────────────────────────────────
# Pass these at runtime — never bake secrets into the image:
#
#   docker run -p 8501:8501 \
#     -e SUPABASE_URL="your-supabase-url" \
#     -e SUPABASE_KEY="your-supabase-key" \
#     -e GROQ_API_KEY="your-groq-api-key" \
#     hia

ENV SUPABASE_URL=""
ENV SUPABASE_KEY=""
ENV GROQ_API_KEY=""

# Write secrets.toml at container startup from environment variables
ENTRYPOINT ["sh", "-c", "\
  mkdir -p /app/.streamlit && \
  printf 'SUPABASE_URL = \"%s\"\\nSUPABASE_KEY = \"%s\"\\nGROQ_API_KEY = \"%s\"\\n' \
    \"$SUPABASE_URL\" \"$SUPABASE_KEY\" \"$GROQ_API_KEY\" \
    > /app/.streamlit/secrets.toml && \
  exec streamlit run src/main.py --server.port=8501 --server.address=0.0.0.0 \
"]

EXPOSE 8501

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:8501/_stcore/health || exit 1