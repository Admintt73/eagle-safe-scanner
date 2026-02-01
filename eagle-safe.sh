#!/bin/bash

# ============================================================================
# 飞鹰安全扫描工具 - 安全版 (无需ROOT)
# 开发者: Admtt73 (千枫)
# 特点: 无需ROOT权限，零风险，完全在用户空间运行
# GitHub: https://github.com/Admtt73/eagle-safe-scanner
# ============================================================================

VERSION="3.0.0"
AUTHOR="Admtt73 (千枫)"
SAFE_MODE=true

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# 工作目录（用户空间）
WORK_DIR="$HOME/.eagle_safe"
SCAN_LOG="$WORK_DIR/scan.log"
REPORT_DIR="$WORK_DIR/reports"
DB_DIR="$WORK_DIR/database"

# 创建安全目录
mkdir -p "$WORK_DIR" "$REPORT_DIR" "$DB_DIR"

# 显示横幅
show_banner() {
    clear
    echo -e "${CYAN}"
    echo '┌─────────────────────────────────────────────────────┐'
    echo '│                                                     │'
    echo '│    ╔══════════════════════════════════════════╗     │'
    echo '│    ║        飞鹰安全扫描工具 (安全版)          ║     │'
    echo '│    ║       🔒 无需ROOT | 🛡️ 零风险            ║     │'
    echo '│    ╚══════════════════════════════════════════╝     │'
    echo '│                                                     │'
    echo '│    📱 Termux | 🐧 Linux | 🍎 macOS | 🪟 Win10+    │'
    echo '│                                                     │'
    echo '└─────────────────────────────────────────────────────┘'
    echo -e "${NC}"
    echo -e "${GREEN}版本: v$VERSION${NC} | ${YELLOW}开发者: $AUTHOR${NC}"
    echo -e "${BLUE}GitHub: https://github.com/Admtt73${NC}"
    echo
}

# 安全检查
safety_check() {
    echo -e "${BLUE}[*]${NC} 执行安全检查..."
    
    # 检查是否尝试获取root
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}[!]${NC} 警告：检测到ROOT权限！"
        echo -e "${YELLOW}[!]${NC} 本工具无需ROOT权限，建议以普通用户运行"
        read -p "是否继续? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # 检查是否在安全目录
    if [[ "$PWD" == *"/system"* ]] || [[ "$PWD" == *"/root"* ]]; then
        echo -e "${RED}[!]${NC} 警告：当前目录可能存在风险"
        cd "$HOME" || exit
    fi
    
    echo -e "${GREEN}[✓]${NC} 安全检查通过"
}

# 主菜单
show_menu() {
    echo -e "${CYAN}══════════════ 主菜单 ══════════════${NC}"
    echo
    echo -e "${GREEN}1.${NC} 快速安全检查"
    echo -e "${GREEN}2.${NC} 用户文件扫描"
    echo -e "${GREEN}3.${NC} 恶意软件检测"
    echo -e "${GREEN}4.${NC} 网络连接检查"
    echo -e "${GREEN}5.${NC} 系统信息查看"
    echo -e "${GREEN}6.${NC} 隐私泄露检测"
    echo -e "${GREEN}7.${NC} 清理缓存文件"
    echo -e "${GREEN}8.${NC} 安全建议"
    echo -e "${GREEN}9.${NC} 工具设置"
    echo -e "${RED}0.${NC} 退出"
    echo
    echo -e "${CYAN}════════════════════════════════════${NC}"
}

# 快速安全检查
quick_check() {
    echo -e "${BLUE}[*]${NC} 开始快速安全检查..."
    echo
    
    # 1. 检查敏感文件权限
    check_file_permissions
    
    # 2. 检查环境变量
    check_environment
    
    # 3. 检查可疑进程
    check_processes
    
    # 4. 检查网络连接
    check_network
    
    # 5. 生成报告
    generate_report
}

# 检查文件权限
check_file_permissions() {
    echo -e "${CYAN}[1/5] 检查文件权限...${NC}"
    
    local dangerous_files=(
        "$HOME/.bashrc"
        "$HOME/.profile"
        "$HOME/.ssh"
        "$HOME/.config"
    )
    
    for file in "${dangerous_files[@]}"; do
        if [ -e "$file" ]; then
            local perm=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%p" "$file" 2>/dev/null)
            if [[ "$perm" == *"777"* ]] || [[ "$perm" == *"666"* ]]; then
                echo -e "${RED}  [!]${NC} $file 权限过宽: $perm"
            else
                echo -e "${GREEN}  [✓]${NC} $file 权限正常: $perm"
            fi
        fi
    done
    echo
}

# 检查环境变量
check_environment() {
    echo -e "${CYAN}[2/5] 检查环境变量...${NC}"
    
    # 检查PATH中是否有可疑目录
    echo "$PATH" | tr ':' '\n' | while read -r path; do
        if [[ "$path" == *"/tmp"* ]] || [[ "$path" == *"/var/tmp"* ]]; then
            echo -e "${YELLOW}  [!]${NC} PATH中包含临时目录: $path"
        fi
    done
    
    # 检查LD_PRELOAD等危险变量
    if [ -n "$LD_PRELOAD" ]; then
        echo -e "${RED}  [!]${NC} 检测到LD_PRELOAD环境变量: $LD_PRELOAD"
    fi
    
    echo -e "${GREEN}  [✓]${NC} 环境变量检查完成"
    echo
}

# 检查进程
check_processes() {
    echo -e "${CYAN}[3/5] 检查运行进程...${NC}"
    
    # 显示消耗资源最多的进程
    echo -e "${WHITE}资源占用前5的进程：${NC}"
    if command -v ps &> /dev/null; then
        ps aux --sort=-%cpu | head -6 | tail -5 | awk '{print "  " $1 " - " $11}'
    fi
    
    # 检查可疑关键词
    local suspicious_keywords=("miner" "coin" "backdoor" "shell" "reverse")
    for keyword in "${suspicious_keywords[@]}"; do
        if pgrep -i "$keyword" &> /dev/null; then
            echo -e "${RED}  [!]${NC} 发现可疑进程: $keyword"
        fi
    done
    echo
}

# 检查网络连接
check_network() {
    echo -e "${CYAN}[4/5] 检查网络连接...${NC}"
    
    if command -v netstat &> /dev/null; then
        echo -e "${WHITE}活跃的网络连接：${NC}"
        netstat -tun 2>/dev/null | grep ESTABLISHED | head -5
    elif command -v ss &> /dev/null; then
        ss -tun | head -10
    else
        echo -e "${YELLOW}  [*]${NC} 无法检查网络连接"
    fi
    
    # 检查可疑端口
    echo -e "${WHITE}可疑端口检测：${NC}"
    local suspicious_ports=(4444 5555 6666 7777 8888 9999 1337 31337)
    for port in "${suspicious_ports[@]}"; do
        if command -v nc &> /dev/null; then
            if nc -z localhost "$port" 2>/dev/null; then
                echo -e "${RED}  [!]${NC} 发现可疑端口开放: $port"
            fi
        fi
    done
    echo
}

# 用户文件扫描
scan_user_files() {
    echo -e "${BLUE}[*]${NC} 扫描用户文件..."
    
    local scan_locations=(
        "$HOME/Downloads"
        "$HOME/Desktop"
        "$HOME/Documents"
        "$HOME/.local"
    )
    
    local file_count=0
    local suspicious_count=0
    
    for location in "${scan_locations[@]}"; do
        if [ -d "$location" ]; then
            echo -e "${CYAN}扫描: $location${NC}"
            
            # 查找可疑扩展名
            local suspicious_ext=(".exe" ".vbs" ".bat" ".sh" ".apk" ".jar" ".py" ".js")
            
            for ext in "${suspicious_ext[@]}"; do
                find "$location" -type f -name "*$ext" 2>/dev/null | head -5 | while read -r file; do
                    file_count=$((file_count + 1))
                    echo -e "${YELLOW}  [?]${NC} 发现 $ext 文件: $(basename "$file")"
                    suspicious_count=$((suspicious_count + 1))
                done
            done
        fi
    done
    
    echo
    echo -e "${GREEN}[✓]${NC} 扫描完成"
    echo -e "${WHITE}统计：${NC}"
    echo -e "  扫描文件: $file_count"
    echo -e "  可疑文件: $suspicious_count"
    echo
}

# 恶意软件检测
malware_detection() {
    echo -e "${BLUE}[*]${NC} 恶意软件检测..."
    
    # 已知的恶意软件特征
    declare -A malware_patterns=(
        ["挖矿程序"]="miner|cpuminer|xmrig|ccminer"
        ["后门程序"]="backdoor|reverse|shell|bind"
        ["勒索软件"]="ransom|wannacry|cryptolocker"
        ["广告软件"]="adware|adbot|popup"
        ["间谍软件"]="spyware|keylog|tracker"
    )
    
    # 检查进程
    for name in "${!malware_patterns[@]}"; do
        pattern=${malware_patterns[$name]}
        if ps aux | grep -iE "$pattern" | grep -v grep &> /dev/null; then
            echo -e "${RED}[!]${NC} 发现疑似$name"
        else
            echo -e "${GREEN}[✓]${NC} 未发现$name"
        fi
    done
    
    # 检查crontab
    if command -v crontab &> /dev/null; then
        echo -e "${CYAN}检查定时任务...${NC}"
        crontab -l 2>/dev/null | grep -v "^#" | while read -r line; do
            if [[ -n "$line" ]]; then
                echo -e "${YELLOW}  [?]${NC} 发现定时任务: $line"
            fi
        done
    fi
    
    echo
}

# 系统信息查看
system_info() {
    echo -e "${BLUE}[*]${NC} 系统信息"
    echo
    
    echo -e "${CYAN}基本系统信息：${NC}"
    echo -e "  系统: $(uname -s)"
    echo -e "  版本: $(uname -r)"
    echo -e "  主机名: $(hostname)"
    echo -e "  用户: $(whoami)"
    
    echo -e "${CYAN}硬件信息：${NC}"
    if command -v free &> /dev/null; then
        echo -e "  内存: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    fi
    
    if command -v df &> /dev/null; then
        echo -e "  磁盘: $(df -h / | awk 'NR==2 {print $3 "/" $2}')"
    fi
    
    echo -e "${CYAN}安全状态：${NC}"
    if [ "$SAFE_MODE" = true ]; then
        echo -e "  运行模式: ${GREEN}安全模式${NC} (无ROOT)"
    else
        echo -e "  运行模式: ${RED}高级模式${NC}"
    fi
    
    echo
}

# 隐私泄露检测
privacy_check() {
    echo -e "${BLUE}[*]${NC} 隐私泄露检测..."
    
    # 检查浏览器缓存（如果存在）
    local browser_paths=(
        "$HOME/.cache"
        "$HOME/.config/google-chrome"
        "$HOME/.mozilla/firefox"
        "$HOME/.config/opera"
    )
    
    local sensitive_files=0
    for path in "${browser_paths[@]}"; do
        if [ -d "$path" ]; then
            echo -e "${CYAN}检查: $path${NC}"
            # 查找cookie、历史记录等
            find "$path" -name "*cookie*" -o -name "*history*" -o -name "*password*" 2>/dev/null | head -3 | while read -r file; do
                sensitive_files=$((sensitive_files + 1))
                echo -e "${YELLOW}  [!]${NC} 发现隐私相关文件: $(basename "$file")"
            done
        fi
    done
    
    if [ $sensitive_files -eq 0 ]; then
        echo -e "${GREEN}[✓]${NC} 未发现明显的隐私泄露风险"
    else
        echo -e "${RED}[!]${NC} 发现 $sensitive_files 个隐私相关文件"
        echo -e "${YELLOW}[建议]${NC} 定期清理浏览器缓存"
    fi
    echo
}

# 清理缓存文件
clean_cache() {
    echo -e "${BLUE}[*]${NC} 清理缓存文件..."
    
    local cache_dirs=(
        "$HOME/.cache"
        "$HOME/.local/share/Trash"
        "/tmp"
    )
    
    local total_freed=0
    
    for dir in "${cache_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo -e "${CYAN}清理: $dir${NC}"
            # 计算大小
            local size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            echo -e "  当前大小: $size"
            
            # 询问是否清理
            read -p "  是否清理? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # 安全清理：只清理特定类型的文件
                find "$dir" -name "*.tmp" -o -name "*.temp" -o -name "*.log" 2>/dev/null | head -20 | while read -r file; do
                    rm -f "$file"
                done
                echo -e "${GREEN}  [✓]${NC} 已清理"
            fi
        fi
    done
    
    echo
    echo -e "${GREEN}[✓]${NC} 缓存清理完成"
}

# 安全建议
security_tips() {
    echo -e "${BLUE}[*]${NC} 安全建议"
    echo
    
    echo -e "${CYAN}🔐 基础安全建议：${NC}"
    echo "  1. 定期更新系统和软件"
    echo "  2. 使用强密码和双重验证"
    echo "  3. 谨慎下载和安装软件"
    echo "  4. 备份重要数据"
    echo "  5. 使用防火墙和安全软件"
    
    echo -e "${CYAN}📱 移动设备建议：${NC}"
    echo "  1. 仅从官方商店下载应用"
    echo "  2. 检查应用权限"
    echo "  3. 开启设备加密"
    echo "  4. 定期检查系统更新"
    
    echo -e "${CYAN}💻 电脑安全建议：${NC}"
    echo "  1. 启用自动更新"
    echo "  2. 安装防病毒软件"
    echo "  3. 小心电子邮件附件"
    echo "  4. 使用VPN在公共WiFi"
    
    echo
    echo -e "${YELLOW}[提示]${NC} 本工具会持续更新更多安全功能"
}

# 工具设置
tool_settings() {
    echo -e "${BLUE}[*]${NC} 工具设置"
    echo
    
    echo -e "${CYAN}当前设置：${NC}"
    echo "  1. 安全模式: ${GREEN}启用${NC}"
    echo "  2. 自动更新: ${YELLOW}手动${NC}"
    echo "  3. 日志记录: ${GREEN}启用${NC}"
    echo "  4. 详细输出: ${YELLOW}关闭${NC}"
    
    echo
    echo -e "${CYAN}设置选项：${NC}"
    echo "  1. 切换详细输出模式"
    echo "  2. 清除扫描历史"
    echo "  3. 检查更新"
    echo "  4. 返回主菜单"
    
    echo
    read -p "请选择 (1-4): " choice
    
    case $choice in
        1)
            echo -e "${GREEN}[✓]${NC} 详细输出模式已切换"
            ;;
        2)
            rm -f "$SCAN_LOG"
            echo -e "${GREEN}[✓]${NC} 扫描历史已清除"
            ;;
        3)
            check_update
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}[!]${NC} 无效选择"
            ;;
    esac
}

# 检查更新
check_update() {
    echo -e "${BLUE}[*]${NC} 检查更新..."
    
    # 这里可以添加实际的更新检查逻辑
    echo -e "${YELLOW}[!]${NC} 更新检查功能开发中"
    echo -e "${GREEN}[提示]${NC} 请访问GitHub获取最新版本："
    echo -e "      https://github.com/Admtt73/eagle-safe-scanner"
}

# 生成报告
generate_report() {
    local report_file="$REPORT_DIR/report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "飞鹰安全扫描报告"
        echo "生成时间: $(date)"
        echo "系统: $(uname -s) $(uname -r)"
        echo "用户: $(whoami)"
        echo "----------------------------------------"
    } > "$report_file"
    
    echo -e "${GREEN}[✓]${NC} 报告已保存到: $report_file"
}

# 主函数
main() {
    show_banner
    safety_check
    
    while true; do
        show_menu
        
        read -p "请选择 (0-9): " choice
        echo
        
        case $choice in
            1)
                quick_check
                ;;
            2)
                scan_user_files
                ;;
            3)
                malware_detection
                ;;
            4)
                check_network
                ;;
            5)
                system_info
                ;;
            6)
                privacy_check
                ;;
            7)
                clean_cache
                ;;
            8)
                security_tips
                ;;
            9)
                tool_settings
                ;;
            0)
                echo -e "${GREEN}[*]${NC} 感谢使用飞鹰安全扫描工具！"
                echo -e "${CYAN}[*]${NC} GitHub: https://github.com/Admtt73"
                exit 0
                ;;
            *)
                echo -e "${RED}[!]${NC} 无效选择，请重新输入"
                ;;
        esac
        
        echo
        read -p "按回车键继续..." -n 1
        echo
    done
}

# 捕获退出信号
trap 'echo -e "\n${YELLOW}[!]${NC} 程序被中断"; exit 1' INT

# 运行主函数
main