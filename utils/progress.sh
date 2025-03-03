#!/bin/bash

# 导入工具脚本
if [ -f "$(dirname "$0")/log_utils.sh" ]; then
    source "$(dirname "$0")/log_utils.sh"
fi

# 进度状态常量
declare -A PROGRESS_STATES=(
    ["INIT"]="0"
    ["CONDA_SETUP"]="1"
    ["CUDA_PYTORCH"]="2"
    ["COMFYUI_INSTALL"]="3"
    ["MODEL_DOWNLOAD"]="4"
    ["SERVICE_START"]="5"
    ["COMPLETE"]="6"
)

# 进度文件路径
PROGRESS_FILE="${WORK_DIR}/logs/.install_progress"

# 初始化进度文件
init_progress() {
    # 确保目录存在
    mkdir -p "$(dirname "$PROGRESS_FILE")"
    # 写入初始状态
    echo "INIT" > "$PROGRESS_FILE"
    log_info "初始化安装进度: INIT"
}

# 保存进度
save_progress() {
    local state="$1"
    
    # 确保目录存在
    mkdir -p "$(dirname "$PROGRESS_FILE")"
    
    # 检查状态是否有效
    if [ -n "${PROGRESS_STATES[$state]}" ]; then
        echo "$state" > "$PROGRESS_FILE"
        log_info "保存进度: $state (${PROGRESS_STATES[$state]})"
        return 0
    else
        log_error "无效的进度状态: $state"
        return 1
    fi
}

# 获取当前进度
get_progress() {
    if [ ! -f "$PROGRESS_FILE" ]; then
        init_progress
    fi
    cat "$PROGRESS_FILE"
}

# 检查是否需要执行某个步骤
should_execute_step() {
    local step="$1"
    local current_progress=$(get_progress)
    
    # 如果是 INIT 状态，所有步骤都需要执行
    if [ "$current_progress" = "INIT" ]; then
        return 0
    fi
    
    # 获取当前进度值和步骤值
    local current_value="${PROGRESS_STATES[$current_progress]}"
    local step_value="${PROGRESS_STATES[$step]}"
    
    # 如果任一值不存在，返回错误
    if [ -z "$current_value" ] || [ -z "$step_value" ]; then
        log_error "无效的进度状态比较: $current_progress -> $step"
        return 1
    fi
    
    # 如果当前值小于步骤值，则需要执行
    [ "$current_value" -lt "$step_value" ]
}

# 清除进度
clear_progress() {
    if [[ -f "$PROGRESS_FILE" ]]; then
        rm -f "$PROGRESS_FILE"
        log_info "清除安装进度"
    fi
} 