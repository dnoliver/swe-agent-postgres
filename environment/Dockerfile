FROM python:3.12

# Install PostgreSQL client
RUN apt-get -qq update && \
    apt-get install -qq -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python packages
RUN pip install --quiet --upgrade pip --root-user-action ignore && \
    pip install --quiet mini-swe-agent --root-user-action ignore && \
    pip install --quiet sqlfluff --root-user-action ignore

# Enable TTY and stdin
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /agent

# Keep container running
CMD ["tail", "-f", "/dev/null"]
