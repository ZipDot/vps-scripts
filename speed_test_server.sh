#!/bin/bash

# 设置变量
FILE_SIZE="5G"
FILE_NAME="speedtest.bin"
PORT=8000

echo "开始创建测速脚本..."

# 步骤1: 生成测速文件
echo "正在生成 ${FILE_SIZE} 大小的测速文件..."
dd if=/dev/zero of=$FILE_NAME bs=1M count=5120 status=progress
echo "测速文件生成完成。"

# 步骤2: 启动HTTP简易服务
echo "正在启动HTTP简易服务..."
python3 -m http.server $PORT &
SERVER_PID=$!
echo "HTTP服务已在端口 $PORT 启动。"

# 步骤3: 生成下载链接
IP=$(hostname -I | awk '{print $1}')
DOWNLOAD_LINK="http://$IP:$PORT/$FILE_NAME"
echo "测速文件下载链接已生成:"
echo $DOWNLOAD_LINK

echo "脚本执行完毕。使用 Ctrl+C 停止HTTP服务。"

# 等待用户中断
trap "kill $SERVER_PID; echo '已停止HTTP服务'; exit" INT
wait
