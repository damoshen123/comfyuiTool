#!/bin/bash

# 初始化脚本环境和依赖
init_script() {
    # 防止重复初始化
    if [ "${INIT_DONE:-}" = "true" ]; then
        return 0
    fi
    
    # 1. 路径处理
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    ROOT_DIR="$(dirname "$SCRIPT_DIR")"
    
    # 2. 检查必要的目录
    check_required_dirs
    
    # 3. 按顺序加载依赖
    load_dependencies
    
    # 4. 初始化日志
    init_logging
    
    # 5. 设置错误处理
    setup_error_handling
    
    # 6. 设置环境变量
    setup_environment
    
    # 标记初始化完成
    INIT_DONE="true"
}

# 设置环境变量
setup_environment() {
    # 添加脚本目录到 PATH
    export PATH="$ROOT_DIR/scripts:$PATH"
    
    # 设置工作目录
    if [ -d "$WORK_DIR" ]; then
        export PATH="$WORK_DIR/scripts:$PATH"
    fi
}

# 检查必要的目录结构
check_required_dirs() {
    local required_dirs=(
        "$ROOT_DIR/config"
        "$ROOT_DIR/utils"
        "$ROOT_DIR/scripts"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "错误: 缺少必要目录 $dir"
            echo "当前 ROOT_DIR: $ROOT_DIR"
            exit 1
        fi
    done
}

# 统一的依赖加载顺序
load_dependencies() {
    # 1. 加载配置 - 应该最先加载配置文件
    if [ ! -f "$ROOT_DIR/config/comfyui_config.sh" ]; then
        echo "错误: 配置文件不存在 $ROOT_DIR/config/comfyui_config.sh"
        exit 1
    fi
    source "$ROOT_DIR/config/comfyui_config.sh"
    
    # 2. 加载基础工具
    source "$ROOT_DIR/utils/color_vars.sh"
    source "$ROOT_DIR/utils/log_utils.sh"
    
    # 3. 加载功能模块
    source "$ROOT_DIR/utils/conda_utils.sh"
    source "$ROOT_DIR/utils/progress.sh"
}

# 统一的错误处理设置
setup_error_handling() {
    set -e  # 遇到错误立即退出
    
    trap 'handle_error $? $LINENO ${FUNCNAME[@]}' ERR
    trap 'cleanup_before_exit' EXIT
}

# 增强的错误处理函数
handle_error() {
    local exit_code=$1
    local line_number=$2
    shift 2
    local function_stack=("$@")
    
    log_error "错误发生在:"
    log_error "- 退出码: $exit_code"
    log_error "- 行号: $line_number"
    log_error "- 函数调用栈: ${function_stack[*]}"
    
    cleanup_before_exit
    exit $exit_code
}

# 退出前清理
cleanup_before_exit() {
    # 清理临时文件
    if [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"/*
    fi
    
    # 重置 trap
    trap - EXIT ERR
} 