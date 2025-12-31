FROM debian:stable-slim

RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    wget \
    git \
    vim \
    build-essential \
    locales \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# 生成常用 Locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

RUN mkdir -p /var/run/sshd

# 基础 SSH 配置
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# 将 root 的家目录更改为 /app，以便利用 Volume 持久化所有配置
RUN usermod -d /app root

# 复制并准备启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /app
EXPOSE 22

# 使用脚本作为入口点
ENTRYPOINT ["/entrypoint.sh"]

