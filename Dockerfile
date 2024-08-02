# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PORT 10000

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    python3 \
    && apt-get clean

# Install cloudflared
RUN wget -q -nc https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared \
    && chmod +x /usr/local/bin/cloudflared

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Clone the repository (replace <repository-url> and <branch-name>)
RUN git clone <repository-url> /workspace \
    && cd /workspace \
    && git checkout <branch-name>

# Expose the port for VSCode server
EXPOSE ${PORT}

# Run VSCode server and cloudflared tunnel
CMD code-server --port $PORT --disable-telemetry --auth none & \
    sleep 10 && \
    while true; do \
        cloudflared tunnel --url http://127.0.0.1:$PORT --metrics localhost:45678; \
    done
