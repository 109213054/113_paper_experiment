FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei

RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    build-essential \
    python3 \
    python3-pip \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    npm install -g snarkjs

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install circom
RUN git clone https://github.com/iden3/circom.git /opt/circom && \
    cd /opt/circom && \
    cargo build --release && \
    cp target/release/circom /usr/local/bin/circom

WORKDIR /workspace

CMD ["/bin/bash"]

