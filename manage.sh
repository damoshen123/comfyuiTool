#!/bin/bash

# 定义常量
AIAR2_INSTALL_DIR="/usr/local/bin/aiar2"
MODEL_DIR="/workspace/ComfyUI/models/checkpoints"
LORA_DIR="/workspace/ComfyUI/models/loras"
COMFYUI_DIR="/workspace/ComfyUI"

# 清屏函数
clear_screen() {
    clear
}

# 显示标题
show_title() {
    echo -e "\n欢迎使用 AIar2 管理助手"
    echo "============================"
}

# 显示菜单
show_menu() {
    echo -e "\n请选择操作："
    echo "1) 安装 aiar2"
    echo "2) 卸载 aiar2"
    echo "3) 下载模型"
    echo "4) 下载 Lora"
    echo "5) 启动 ComfyUI"
    echo "6) 退出"
    echo "============================"
}

# 安装 aiar2
install_aiar2() {
    echo "正在安装 aiar2..."
    apt update
    apt install -y aria2
    echo "aiar2 安装完成"
}

# 卸载 aiar2
uninstall_aiar2() {
    echo "正在卸载 aiar2..."
    apt remove --purge -y aria2
    echo "aiar2 卸载完成"
}

# 下载模型
download_model() {
    read -p "请输入模型下载链接: " model_url
    echo "正在下载模型到 $MODEL_DIR..."
    aria2c -x 16 -s 16 -d "$MODEL_DIR" "$model_url"
    echo "模型下载完成"
}

# 下载 Lora
download_lora() {
    read -p "请输入 Lora 下载链接: " lora_url
    echo "正在下载 Lora 到 $LORA_DIR..."
    aria2c -x 16 -s 16 -d "$LORA_DIR" "$lora_url"
    echo "Lora 下载完成"
}

# 启动 ComfyUI
start_comfyui() {
    echo "正在启动 ComfyUI..."
    cd "$COMFYUI_DIR" || { echo "无法进入目录 $COMFYUI_DIR"; return; }
    python main.py
}

# 主程序循环
main() {
    while true; do
        clear_screen
        show_title
        show_menu
        
        read -p "请输入操作编号: " choice
        
        case $choice in
            1)
                install_aiar2
                ;;
            2)
                uninstall_aiar2
                ;;
            3)
                download_model
                ;;
            4)
                download_lora
                ;;
            5)
                start_comfyui
                ;;
            6)
                echo "感谢使用 AIar2 管理助手！"
                exit 0
                ;;
            *)
                echo "无效的选择，请重试"
                ;;
        esac
        
        read -p "按回车键返回主菜单..."
    done
}

# 运行主程序
main
