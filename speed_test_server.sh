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
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

# 进度条函数
show_progress() {
    local duration=$1
    local sleep_interval=0.1
    local progress=0
    local bar_size=40

    while [ $progress -lt 100 ]; do
        local filled=$(($progress * $bar_size / 100))
        local empty=$(($bar_size - $filled))
        printf "\r[${YELLOW}%-${filled}s${NC}${RED}%-${empty}s${NC}] ${BLUE}%d%%${NC}" '' '' $progress
        progress=$((progress + 1))
        sleep $sleep_interval
    done
    echo
}

print_divider
echo -e "${BLUE}开始创建测速脚本...${NC}"
print_divider

# 步骤1: 生成测速文件
echo -e "${YELLOW}正在生成 ${FILE_SIZE} 大小的测速文件...${NC}"
dd if=/dev/zero of=$FILE_NAME bs=1M count=5120 status=none &
DD_PID=$!
show_progress 10  # 假设文件生成大约需要10秒
wait $DD_PID
echo -e "${GREEN}测速文件生成完成。${NC}"

print_divider

# 步骤2: 启动HTTP简易服务
echo -e "${YELLOW}正在启动HTTP简易服务...${NC}"
python3 -m http.server $PORT &
SERVER_PID=$!
echo -e "${GREEN}HTTP服务已在端口 $PORT 启动。${NC}"

print_divider

# 步骤3: 生成下载链接
IP=$(hostname -I | awk '{print $1}')
DOWNLOAD_LINK="http://$IP:$PORT/$FILE_NAME"
echo -e "${GREEN}测速文件下载链接已生成:${NC}"
echo -e "${BLUE}$DOWNLOAD_LINK${NC}"

print_divider

echo -e "${YELLOW}脚本执行完毕。测试完成可使用 Ctrl+C 停止HTTP服务。${NC}"

print_divider

# 等待用户中断
trap "echo -e '${RED}正在停止HTTP服务...${NC}'; kill $SERVER_PID; echo -e '${GREEN}已停止HTTP服务${NC}'; print_divider; exit" INT
wait
