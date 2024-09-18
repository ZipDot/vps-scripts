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

echo -e "${BLUE}开始创建测速脚本...${NC}"

# 步骤1: 生成测速文件
echo -e "${YELLOW}正在生成 ${FILE_SIZE} 大小的测速文件...${NC}"
dd if=/dev/zero of=$FILE_NAME bs=1M count=5120 status=progress
echo -e "${GREEN}测速文件生成完成。${NC}"

# 步骤2: 启动HTTP简易服务
echo -e "${YELLOW}正在启动HTTP简易服务...${NC}"
python3 -m http.server $PORT &
SERVER_PID=$!
echo -e "${GREEN}HTTP服务已在端口 $PORT 启动。${NC}"

# 步骤3: 生成下载链接
IP=$(hostname -I | awk '{print $1}')
DOWNLOAD_LINK="http://$IP:$PORT/$FILE_NAME"
echo -e "${GREEN}测速文件下载链接已生成 可点击一下链接在浏览器中打开${NC}"
echo -e "${BLUE}$DOWNLOAD_LINK${NC}"

echo -e "${YELLOW}脚本执行完毕。使用 Ctrl+C 停止HTTP服务。${NC}"

# 等待用户中断
trap "echo -e '${RED}正在停止HTTP服务...${NC}'; kill $SERVER_PID; echo -e '${GREEN}已停止HTTP服务${NC}'; exit" INT
wait
