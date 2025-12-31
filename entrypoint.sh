#!/bin/bash

# 检查环境变量是否存在
if [ -n "$SSH_PUB_KEY" ]; then
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    echo "$SSH_PUB_KEY" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo "SSH 公钥已成功注入。"
else
    echo "警告：未找到 SSH_PUB_KEY 变量，可能无法登录。"
fi

# 启动 SSH 服务
exec /usr/sbin/sshd -D
