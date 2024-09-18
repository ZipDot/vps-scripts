#!/bin/bash

# 设置颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 设置变量
FILE_SIZE="5G"
FILE_NAME="speedtest.bin"
PORT=8000

# 分割线函数
print_divider() {
    printf '%*s\n' "70" '' | tr ' ' -
}

# 检测系统类型和包管理器
detect_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        if command -v apt-get >/dev/null 2>&1; then
            PKG_MANAGER="apt-get"
        elif command -v dnf >/dev/null 2>&1; then
            PKG_MANAGER="dnf"
        elif command -v yum >/dev/null 2>&1; then
            PKG_MANAGER="yum"
        elif command -v pacman >/dev/null 2>&1; then
            PKG_MANAGER="pacman"
        elif command -v apk >/dev/null 2>&1; then
            PKG_MANAGER="apk"
        else
            echo "未能识别包管理器，请手动安装Python3。"
            exit 1
        fi
    else
        echo "无法确定操作系统类型。"
        exit 1
    fi
}

# 安装Python3（如果需要）
install_python3() {
    if ! command -v python3 >/dev/null 2>&1; then
        echo -e "${YELLOW}正在安装Python3...${NC}"
        case $PKG_MANAGER in
            apt-get)
                sudo apt-get update && sudo apt-get install -y python3
                ;;
            dnf|yum)
                sudo $PKG_MANAGER install -y python3
                ;;
            pacman)
                sudo pacman -Sy --noconfirm python
                ;;
            apk)
                sudo apk add --no-cache python3
                ;;
        esac
    fi
}

# 获取IP地址
get_ip() {
    if command -v hostname >/dev/null 2>&1; then
        IP=$(hostname -I | awk '{print $1}')
    elif command -v ip >/dev/null 2>&1; then
        IP=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n1)
    else
        IP="127.0.0.1"
        echo -e "${YELLOW}警告：无法获取IP地址，使用localhost。${NC}"
    fi
}

# 清理函数
cleanup() {
    echo -e "\n${RED}正在停止HTTP服务...${NC}"
    kill $SERVER_PID 2>/dev/null
    wait $SERVER_PID 2>/dev/null
    echo -e "${GREEN}已停止HTTP服务${NC}"
    print_divider
    
    echo -e "${YELLOW}是否删除测速文件 ${FILE_NAME}? [Y/n] ${NC}"
    read -t 10 -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${BLUE}保留测速文件。${NC}"
    else
        rm -f $FILE_NAME
        echo -e "${GREEN}测速文件已删除。${NC}"
    fi
    print_divider
    exit 0
}

# 主函数
main() {
    detect_system
    install_python3
    
    trap cleanup SIGINT SIGTERM

    print_divider
    echo -e "${BLUE}开始创建测速脚本...${NC}"
    print_divider

    echo -e "${YELLOW}正在生成 ${FILE_SIZE} 大小的测速文件...${NC}"
    dd if=/dev/zero of=$FILE_NAME bs=1M count=5120 status=progress
    echo -e "${GREEN}测速文件生成完成。${NC}"

    print_divider

    echo -e "${YELLOW}正在启动HTTP简易服务...${NC}"
    python3 -m http.server $PORT &
    SERVER_PID=$!
    echo -e "${GREEN}HTTP服务已在端口 $PORT 启动。${NC}"

    print_divider

    get_ip
    DOWNLOAD_LINK="http://$IP:$PORT/$FILE_NAME"
    echo -e "${GREEN}测速文件下载链接已生成，使用浏览器打开下方链接:${NC}"
    echo -e "${BLUE}$DOWNLOAD_LINK${NC}"

    print_divider

    echo -e "${YELLOW}使用 Ctrl+C 停止HTTP服务。${NC}"

    print_divider

    wait $SERVER_PID
}

main
