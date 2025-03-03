#!/bin/bash

# 导入工具脚本
if [ -f "$(dirname "$0")/log_utils.sh" ]; then
    source "$(dirname "$0")/log_utils.sh"
fi

# 检查 conda 是否可用
check_conda_available() {
    if ! command -v conda &> /dev/null; then
        log_error "未找到 conda 命令"
        log_info "请先安装 Miniconda 或 Anaconda"
        return 1
    fi
    return 0
}

# 检查环境是否存在
check_env_exists() {
    local env_name="$1"
    if conda env list | grep -q "^$env_name "; then
        return 0
    fi
    return 1
}

# 激活环境
activate_env() {
    local env_name="$1"
    
    # 初始化 conda
    eval "$(conda shell.bash hook)"
    
    # 尝试激活环境
    if ! conda activate "$env_name" 2>/dev/null; then
        log_error "无法激活环境: $env_name"
        return 1
    fi
    
    # 验证环境
    if [ "$CONDA_DEFAULT_ENV" != "$env_name" ]; then
        log_error "环境激活验证失败"
        return 1
    fi
    
    return 0
}

# 确保在指定的 conda 环境中
ensure_conda_env() {
    local env_name="comfyui_env"
    
    # 检查 conda 是否可用
    if ! check_conda_available; then
        exit 1
    fi
    
    # 如果不在目标环境中
    if [ "$CONDA_DEFAULT_ENV" != "$env_name" ]; then
        log_info "切换到 $env_name 环境..."
        
        # 检查环境是否存在
        if ! check_env_exists "$env_name"; then
            log_error "环境 $env_name 不存在"
            log_info "请先运行安装脚本创建环境"
            exit 1
        fi
        
        # 激活环境
        if ! activate_env "$env_name"; then
            exit 1
        fi
    fi
    
    log_info "当前环境: $env_name"
}

# 创建新环境
create_conda_env() {
    local env_name="$1"
    local python_version="${2:-3.12}"
    
    if check_env_exists "$env_name"; then
        log_warning "环境 $env_name 已存在"
        read -p "是否重新创建？(y/n): " recreate
        if [ "$recreate" = "y" ]; then
            log_info "删除现有环境..."
            conda deactivate 2>/dev/null || true
            conda env remove -n "$env_name" -y
        else
            return 0
        fi
    fi
    
    log_info "创建新环境: $env_name (Python $python_version)"
    if ! conda create -n "$env_name" "python=$python_version" -y -c conda-forge; then
        log_error "环境创建失败"
        return 1
    fi
    
    log_info "环境创建成功"
    return 0
}

# 更新环境
update_conda_env() {
    local env_name="$1"
    
    if ! check_env_exists "$env_name"; then
        log_error "环境 $env_name 不存在"
        return 1
    fi
    
    log_info "更新环境: $env_name"
    if ! conda update -n "$env_name" --all -y; then
        log_warning "环境更新失败"
        return 1
    fi
    
    log_info "环境更新成功"
    return 0
}