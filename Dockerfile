FROM python:3.11-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY mcp_scheduler/ ./mcp_scheduler/
COPY main.py .

# Create directory for database
RUN mkdir -p /data

# Expose port 8080
EXPOSE 8080

# Run in SSE mode on port 8080
CMD ["python", "main.py", "--transport", "sse", "--port", "8080", "--address", "0.0.0.0", "--db-path", "/data/scheduler.db"]
