#!/bin/bash

# 飞鹰安全扫描工具一键运行脚本
# 如果未安装，会自动下载运行

TEMP_FILE="/tmp/eagle-safe-$(date +%s).sh"

echo "正在获取最新版本..."
curl -s -o "$TEMP_FILE" \
  https://raw.githubusercontent.com/Admtt73/eagle-safe-scanner/main/eagle-safe.sh

if [ -f "$TEMP_FILE" ]; then
    chmod +x "$TEMP_FILE"
    echo "开始运行飞鹰安全扫描工具..."
    echo "========================================"
    bash "$TEMP_FILE"
else
    echo "下载失败，请检查网络连接"
    exit 1
fi