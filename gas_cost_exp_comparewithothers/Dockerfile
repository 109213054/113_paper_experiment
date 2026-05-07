FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei

# Base system tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    jq \
    ca-certificates \
    libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install global ZKP tool
RUN npm install -g snarkjs

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install circom
RUN git clone https://github.com/iden3/circom.git /opt/circom && \
    cd /opt/circom && \
    cargo build --release && \
    cp target/release/circom /usr/local/bin/circom

# Python packages for plotting / result processing
RUN pip3 install --no-cache-dir matplotlib numpy pandas

WORKDIR /workspace

CMD ["/bin/bash"]

