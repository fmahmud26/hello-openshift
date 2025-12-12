# =========================
# Stage 1: Build
# =========================
FROM python:3.11-alpine AS builder

# Install build dependencies
RUN apk add --no-cache gcc musl-dev libffi-dev

WORKDIR /app

# Install Python dependencies into /install
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy app code
COPY . .

# =========================
# Stage 2: Runtime (slim)
# =========================
FROM python:3.11-alpine

WORKDIR /app

# Copy Python packages from builder
COPY --from=builder /install /usr/local

# Copy app code
COPY --from=builder /app /app

# OpenShift: make app writable by random UID
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

USER appuser

# Expose FastAPI port
EXPOSE 8080

# Start FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
