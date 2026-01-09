FROM debian:stable-slim

# 1. 基础系统工具和依赖
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    wget \
    git \
    vim \
    nano \
    build-essential \
    locales \
    rsync \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    gnupg \
    unzip \
    zip \
    htop \
    jq \
    && rm -rf /var/lib/apt/lists/*

# 2. 设置 Locale (中文支持)
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# 3. 安装中文字体
RUN apt-get update && apt-get install -y \
    fonts-noto-cjk \
    fonts-wqy-microhei \
    fonts-wqy-zenhei \
    && rm -rf /var/lib/apt/lists/*

# 4. 添加第三方源 (Node.js & PHP)
# Node.js v22 (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

# PHP (Ondřej Surý PPA) - 获取最新 PHP 版本
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# 5. 安装语言环境
# Python: python3-full (含 venv), python-is-python3 (映射 python -> python3)
# PHP: 8.4 (最新稳定版), 包含常用扩展。注：PHP 8.5 若发布可直接 apt install php8.5
# Node.js: v22
RUN apt-get update && apt-get install -y \
    nodejs \
    python3-full python3-pip python3-venv python-is-python3 \
    php8.4 php8.4-cli php8.4-common php8.4-curl php8.4-mbstring php8.4-xml php8.4-zip php8.4-mysql php8.4-bcmath php8.4-gd \
    && rm -rf /var/lib/apt/lists/*

# 6. 安装全局包管理器
# Node: 启用 Corepack (自带 Yarn 和 PNPM)
RUN corepack enable

# PHP: 安装 Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 7. SSH 服务配置
RUN mkdir -p /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# 8. 用户与目录配置
# 将 root 的家目录更改为 /app，以便利用 Volume 持久化所有配置
# 直接修改 /etc/passwd 避免 usermod "process 1" 错误
RUN sed -i 's|root:/root|root:/app|' /etc/passwd

# 复制并准备启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 默认进入 /app
WORKDIR /app
EXPOSE 22

# 使用脚本作为入口点
ENTRYPOINT ["/entrypoint.sh"]

