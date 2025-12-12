# =========================
# Stage 1: Build
# =========================
FROM python:3.11-alpine AS builder

# Install pipenv dependencies (build stage)
WORKDIR /app

# Copy requirements and install in a temporary directory
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy app code
COPY . .

# =========================
# Stage 2: Runtime (slim)
# =========================
FROM python:3.11-alpine

# Set working directory
WORKDIR /app

# Copy Python packages from builder
COPY --from=builder /install /usr/local

# Copy app code from builder
COPY --from=builder /app /app

# OpenShift: make app writable by random UID
RUN chown -R 1001:0 /app && chmod -R g+rw /app

# Use non-root OpenShift user
USER 1001

# Expose FastAPI port
EXPOSE 8080

# Start FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
