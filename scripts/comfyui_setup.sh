#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# 首先导入初始化脚本和配置文件
source "$ROOT_DIR/utils/init.sh"
source "$ROOT_DIR/config/comfyui_config.sh"

# 初始化环境
init_script

log_info "运行 ComfyUI_setup 脚本..."
log_info "脚本目录: $SCRIPT_DIR"
log_info "根目录: $ROOT_DIR"
log_info "工作目录: $WORK_DIR"

# 添加恢复机制
recover_from_error() {
    local failed_step=$1
    log_warning "在步骤 $failed_step 发生错误"
    
    # 保存失败状态
    echo "FAILED_AT_${failed_step}" > "$PROGRESS_FILE"
    
    # 询问用户是否重试
    read -p "是否要重试此步骤？(y/n): " retry
    if [ "$retry" = "y" ]; then
        log_info "重试步骤 $failed_step"
        return 0
    fi
    
    return 1
}

run_installation() {
    # 使用进度跟踪执行安装步骤
    log_info "开始执行安装步骤..."
    
    # 确保进度文件存在且有初始值
    if [ ! -f "$PROGRESS_FILE" ] || [ ! -s "$PROGRESS_FILE" ]; then
        init_progress
    fi
    
    # 显示当前进度
    local current_progress=$(get_progress)
    log_info "当前安装进度: $current_progress"
    
    # 创建必要的目录
    log_info "创建工作目录结构..."
    mkdir -p "$WORK_DIR" "$LOG_DIR"
    mkdir -p "$WORK_DIR"/{scripts,utils,config,logs}
    
    # 复制必要文件,如果文件存在，则不进行覆盖
    log_info "复制必要文件..."
    cp -rn "$ROOT_DIR/scripts" "$WORK_DIR/"
    cp -rn "$ROOT_DIR/utils" "$WORK_DIR/"
    cp -rn "$ROOT_DIR/config" "$WORK_DIR/"
    
    # 设置脚本文件
    chmod +x "$WORK_DIR/scripts"/*.sh
    chmod +x "$WORK_DIR/utils"/*.sh
    chmod +x "$WORK_DIR/config"/*.sh
    
    # 验证文件复制
    local required_files=(
        "$WORK_DIR/scripts/conda.sh"
        "$WORK_DIR/scripts/cuda-pytorch_update.sh"
        "$WORK_DIR/scripts/comfyui_install.sh"
        "$WORK_DIR/scripts/download.sh"
        "$WORK_DIR/scripts/run.sh"
        "$WORK_DIR/utils/init.sh"
        "$WORK_DIR/utils/log_utils.sh"
        "$WORK_DIR/utils/conda_utils.sh"
        "$WORK_DIR/utils/progress.sh"
        "$WORK_DIR/utils/color_vars.sh"
        "$WORK_DIR/config/comfyui_config.sh"
        "$WORK_DIR/config/supervisord.conf"
        "$WORK_DIR/scripts/cloudstudio_init.sh"
        "$WORK_DIR/scripts/ngrok.sh"
    )
    
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -ne 0 ]; then
        log_error "以下必要文件缺失:"
        printf '%s\n' "${missing_files[@]}"
        return 1
    fi
    
    echo -e "${GREEN}文件复制完成${NC}"
    echo -e "${BLUE}工作目录: ${NC}${WORK_DIR}"
    echo ""
 
    # CONDA_SETUP
    if should_execute_step "CONDA_SETUP"; then
        log_info "开始设置 Conda 环境"
        if bash "$WORK_DIR/scripts/conda.sh"; then
            save_progress "CONDA_SETUP"
            log_info "Conda 环境设置完成"
        else
            log_error "Conda 环境设置失败"
            return 1
        fi
    fi
    
    # CUDA_PYTORCH
    if should_execute_step "CUDA_PYTORCH"; then
        log_info "开始更新 CUDA 和 PyTorch"
        if bash "$WORK_DIR/scripts/cuda-pytorch_update.sh"; then
            save_progress "CUDA_PYTORCH"
            log_info "CUDA 和 PyTorch 步骤完成"
        else
            log_error "CUDA 和 PyTorch 更新失败"
            return 1
        fi
    fi
    
    # COMFYUI_INSTALL
    if should_execute_step "COMFYUI_INSTALL"; then
        log_info "开始安装 ComfyUI"
        if bash "$WORK_DIR/scripts/comfyui_install.sh"; then
            save_progress "COMFYUI_INSTALL"
            log_info "ComfyUI 安装完成"
        else
            log_error "ComfyUI 安装失败"
            return 1
        fi
    fi
    
    # MODEL_DOWNLOAD
    if should_execute_step "MODEL_DOWNLOAD"; then
        log_info "开始下载模型"
        if bash "$WORK_DIR/scripts/download.sh"; then
            if [ "$DOWNLOAD_MODELS" = "true" ]; then
                save_progress "MODEL_DOWNLOAD"
            fi
            log_info "模型下载完成"
        else
            log_error "模型下载失败"
            return 0  # 继续执行，不中断安装流程
        fi
    fi
    
    # SERVICE_START
    if should_execute_step "SERVICE_START"; then
        log_info "准备启动服务"
        if bash "$WORK_DIR/scripts/run.sh"; then
            save_progress "SERVICE_START"
            log_info "服务启动完成"
        else
            log_error "服务启动失败"
            return 1
        fi
    fi
    
    # 初始化 CloudStudio 环境
    log_info "初始化 CloudStudio 环境..."
    bash "$WORK_DIR/scripts/cloudstudio_init.sh"

    # 最后一步使用 COMPLETE 状态
    if should_execute_step "COMPLETE"; then
        save_progress "COMPLETE"
        log_info "安装完成"
    fi
    
    return 0
}

# 主函数
main() {
    log_info "=== 开始 ComfyUI 安装流程 ==="
    
    # 执行安装
    if run_installation; then
        if [ "$(get_progress)" = "COMPLETE" ]; then
            log_info "=== ComfyUI 安装完成 ==="
            return 0
        else
            log_error "=== ComfyUI 安装未完成 ==="
            return 1
        fi
    else
        log_error "=== ComfyUI 安装失败 ==="
        return 1
    fi
}

# 运行主程序
main

check_prerequisites() {
    log_info "检查安装前提条件..."
    
    # 检查磁盘空间
    local required_space=20000000  # 20GB in KB
    local available_space=$(df -k "$WORK_DIR" | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt "$required_space" ]; then
        log_error "磁盘空间不足，需要至少 20GB"
        return 1
    fi
    
    # 检查内存
    local required_memory=8000000  # 8GB in KB
    local available_memory=$(free -k | awk '/^Mem:/ {print $2}')
    if [ "$available_memory" -lt "$required_memory" ]; then
        log_error "内存不足，需要至少 8GB"
        return 1
    fi
    
    return 0
}