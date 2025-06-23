# syntax=docker/dockerfile:1

# --- Builder stage: install dependencies ---
FROM python:3.11-slim AS builder
WORKDIR /app
# Copy requirements and install with pinned versions for security and reproducibility
COPY app/requirements.txt .
RUN pip install --user -r requirements.txt

# --- Final stage: minimal runtime image ---
FROM python:3.11-slim
WORKDIR /app
# Copy only installed dependencies from builder to keep image small
COPY --from=builder /root/.local /root/.local
# Ensure Python output is not buffered (for logging in containers)
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

# Create a dedicated non-root user for security
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# Copy application code
COPY app/app.py .

EXPOSE 8080
# Run the app as the dedicated user
CMD ["python", "app.py"] 