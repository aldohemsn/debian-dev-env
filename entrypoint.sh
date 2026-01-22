#!/bin/bash

# 初始化 /app 目录（如果是新挂载的 Volume）
# 复制默认的 shell 配置文件，如果不存在的话
if [ ! -f "/app/.bashrc" ]; then
    echo "初始化 /app 目录配置..."
    cp -r /etc/skel/. /app/
fi

# 确保 .bashrc 中包含正确的 locale 设置（修复 Mac 终端发送错误 LC_CTYPE 的问题）
LOCALE_MARKER="# Locale settings for Chinese support"
if ! grep -q "$LOCALE_MARKER" /app/.bashrc 2>/dev/null; then
    cat >> /app/.bashrc << 'EOF'

# Locale settings for Chinese support
# 修复 Mac 终端发送 LC_CTYPE=UTF-8 导致的警告
export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:zh
export LC_ALL=zh_CN.UTF-8
EOF
    echo "已添加 locale 配置到 .bashrc"
fi

# 检查环境变量是否存在
if [ -n "$SSH_PUB_KEY" ]; then
    mkdir -p /app/.ssh
    chmod 700 /app/.ssh
    echo "$SSH_PUB_KEY" > /app/.ssh/authorized_keys
    chmod 600 /app/.ssh/authorized_keys
    echo "SSH 公钥已成功注入到 /app/.ssh。"
else
    echo "警告：未找到 SSH_PUB_KEY 变量，可能无法登录。"
fi

# 确保 /app 归 root 所有（防止挂载卷权限问题）
chown -R root:root /app/.ssh

# 启动 SSH 服务
exec /usr/sbin/sshd -D
