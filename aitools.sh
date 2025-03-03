#!/bin/bash
#

# 导入初始化脚本
source "./utils/init.sh"

# 初始化环境
init_script

# 清屏函数
clear_screen() {
    clear
}

# 显示标题
show_title() {
    echo -e "${CYAN}"
    echo -e "${BLUE}                欢迎使用安装comfyui助手 "
    echo -e "${PURPLE}================================================${NC}"
}

# 显示菜单
show_menu() {
    echo -e "\n${GREEN}请选择要安装的 AI 工具：${NC}"
    echo "----------------------------------------"
    echo "1) ComfyUI   "
    echo "2) 检查安装状态"
    echo "3) 清理安装"
    echo "4) 退出"
    echo "----------------------------------------"
}

# 检查安装状态
check_installation_status() {
    log_info "检查安装状态..."
    
    # 检查 ComfyUI
    if [ -d "$WORK_DIR/$PROJECT_NAME" ]; then
        echo -e "${GREEN}ComfyUI 已安装${NC}"
        echo "安装位置: $WORK_DIR/$PROJECT_NAME"
        
        # 检查环境
        if conda env list | grep -q "^comfyui_env "; then
            echo -e "${GREEN}Conda 环境已创建${NC}"
        else
            echo -e "${RED}Conda 环境未创建${NC}"
        fi
        
        # 检查模型
        if [ -d "$MODELS_DIR/checkpoints" ] && [ "$(ls -A $MODELS_DIR/checkpoints)" ]; then
            echo -e "${GREEN}模型已下载${NC}"
            echo "模型位置: $MODELS_DIR"
        else
            echo -e "${YELLOW}未找到模型文件${NC}"
        fi
    else
        echo -e "${RED}ComfyUI 未安装${NC}"
    fi
}

# 找不到安装脚本提示
not_found_script() {
    log_error "未找到安装脚本: $1"
}

# 清理安装
cleanup_installation() {
    log_warning "此操作将删除所有安装文件和配置"
    read -p "是否继续？(y/n): " confirm
    
    if [ "$confirm" = "y" ]; then
        log_info "开始清理..."
        
        # 删除 conda 环境
        if conda env list | grep -q "^comfyui_env "; then
            conda deactivate
            conda env remove -n comfyui_env -y
        fi
        
        # 删除安装目录
        if [ -d "$WORK_DIR" ]; then
            rm -rf "$WORK_DIR"
        fi
        
        # 删除配置文件
        rm -f "$SCRIPT_DIR/config/comfyui_config.sh"
        
        log_info "清理完成"
    else
        log_info "取消清理"
    fi
}

# 执行选择的操作
execute_choice() {
    case $1 in
        1)
            install_1="comfyui_setup_mini.sh"
            log_info "启动 ComfyUI 安装程序..."
            if [ -f "./scripts/$install_1" ]; then
                log_info "$install_1 已找到"
                bash "./scripts/$install_1"
            else
                not_found_script "$install_1"
            fi
            ;;
        2)
            check_installation_status
            ;;
        3)
            cleanup_installation
            ;;
        4)
            log_info "感谢使用 AI For U 安装助手！"
            exit 0
            ;;
        *)
            log_error "无效的选择，请重试"
            ;;
    esac
}

# 主程序循环
main() {
    # 初始化日志
    init_logging
    
    while true; do
        clear_screen
        show_title
        show_menu
        
        echo -e "\n${GREEN}请输入安装编号：${NC}"
        read choice
        
        execute_choice $choice
        
        if [ "$choice" != "6" ]; then
            echo -e "\n${BLUE}按回车键返回主菜单...${NC}"
            read
        fi
    done
}

# 运行主程序
main
