FROM debian:stable-slim

# 安装基础开发工具，按需增减
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 保持容器运行（开发环境常用技巧）
CMD ["tail", "-f", "/dev/null"]

