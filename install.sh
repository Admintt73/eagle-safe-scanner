#!/bin/bash

# 飞鹰安全扫描工具安装脚本
# 无需root权限，完全用户空间安装

echo "开始安装飞鹰安全扫描工具..."
echo

# 创建安装目录
INSTALL_DIR="$HOME/.local/eagle_scanner"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# 下载主脚本
echo "下载主脚本..."
curl -s -o "$INSTALL_DIR/eagle-safe.sh" \
  https://raw.githubusercontent.com/Admtt73/eagle-safe-scanner/main/eagle-safe.sh

# 设置执行权限
chmod +x "$INSTALL_DIR/eagle-safe.sh"

# 创建符号链接
ln -sf "$INSTALL_DIR/eagle-safe.sh" "$BIN_DIR/eagle-scan"

# 添加到PATH（如果尚未添加）
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    echo "已将 ~/.local/bin 添加到PATH"
fi

echo
echo "安装完成！"
echo
echo "使用方法："
echo "  1. 重新打开终端或运行: source ~/.bashrc"
echo "  2. 输入命令: eagle-scan"
echo
echo "GitHub: https://github.com/Admtt73"
echo "开发者: Admtt73 (千枫)"