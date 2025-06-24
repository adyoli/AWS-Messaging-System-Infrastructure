# syntax=docker/dockerfile:1

# --- Builder stage: install dependencies ---
FROM public.ecr.aws/docker/library/python:3.11-slim AS builder
WORKDIR /app

# Install build dependencies (if needed for native packages)
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

# Copy requirements and install globally in /install
COPY app/requirements.txt .
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

# --- Final stage: minimal runtime image ---
FROM public.ecr.aws/docker/library/python:3.11-slim
WORKDIR /app

# Copy only the installed dependencies from builder
COPY --from=builder /install /usr/local

# Create a dedicated non-root user for security
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# Copy application code
COPY app/app.py .

ENV PYTHONUNBUFFERED=1

EXPOSE 8080
CMD ["python", "app.py"] 