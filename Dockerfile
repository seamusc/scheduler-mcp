FROM python:3.11-slim

WORKDIR /app

# Install Node.js for Claude Code CLI
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g @anthropic-ai/claude-code && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
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
