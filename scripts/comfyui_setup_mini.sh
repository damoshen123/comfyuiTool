#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# 先确定 ./config/comfyui_config.sh 文件是否存在。用户自行确认设置是否正确
if [ ! -f "$ROOT_DIR/config/comfyui_config.sh" ]; then
    log_error "未找到 config/comfyui_config.sh 文件"
    exit 1
fi

apt update
apt install -y curl

# 安装 ngrok
log_info "安装 ngrok..."
if command -v ngrok &> /dev/null; then
    log_info "ngrok 已安装"
else
    log_info "ngrok 未安装，开始安装..."
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
        | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
        && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
        | tee /etc/apt/sources.list.d/ngrok.list \
        && apt update \
        && apt install ngrok
fi

# 首先导入初始化脚本和配置文件
source "$ROOT_DIR/utils/init.sh"
source "$ROOT_DIR/config/comfyui_config.sh"

# 初始化环境
init_script

log_info "运行 ComfyUI_setup 脚本..."
log_info "脚本目录: $SCRIPT_DIR"
log_info "根目录: $ROOT_DIR"
log_info "工作目录: $WORK_DIR"

run_installation() {
    # 使用进度跟踪执行安装步骤
    log_info "开始执行安装步骤..."
    
    # 确保进度文件存在且有初始值
    if [ ! -f "$PROGRESS_FILE" ] || [ ! -s "$PROGRESS_FILE" ]; then
        init_progress
    fi
     
    # 创建必要的目录
    log_info "创建工作目录结构..."
    mkdir -p "$WORK_DIR" "$LOG_DIR"
    mkdir -p "$WORK_DIR"/{scripts,utils,config,logs}
    
    # 复制必要文件,如果文件存在，则不进行覆盖
    log_info "复制必要文件..."
    cp -rn "$ROOT_DIR/scripts" "$WORK_DIR/"
    mv "$WORK_DIR/scripts/comfyui/comfyui_install_mini.sh" "$WORK_DIR/scripts/comfyui_install_mini.sh"
    cp -rn "$ROOT_DIR/utils" "$WORK_DIR/"
    cp -rn "$ROOT_DIR/config" "$WORK_DIR/"
    
    # 验证文件复制
    local required_files=(
        "$WORK_DIR/scripts/comfyui_install_mini.sh"
        "$WORK_DIR/utils/init.sh"
        "$WORK_DIR/utils/log_utils.sh"
        "$WORK_DIR/utils/conda_utils.sh"
        "$WORK_DIR/utils/progress.sh"
        "$WORK_DIR/utils/color_vars.sh"
        "$WORK_DIR/config/comfyui_config.sh"
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
     
    # COMFYUI_INSTALL
    bash "$WORK_DIR/scripts/comfyui_install_mini.sh"

}

# 主函数
main() {
    log_info "=== 开始 ComfyUI 安装流程 ==="
    
    # 执行安装
    log_info "执行安装..."
    run_installation
    log_info "=== ComfyUI 安装完成 ==="

    # 安装完成
    echo "================================================"
    echo -e "${BLUE}请使用 python $WORK_DIR/$PROJECT_NAME/main.py 启动ComfyUI程序${NC}"
    echo "================================================"
    echo -e "${PURPLE}可使用 ngrok http 8188 暴露端口 ${NC}"
    echo -e "${PURPLE}以上操作命令请查看 说明文件 ${NC}"
    echo -e "${PURPLE}如果感觉对你有帮助可以请喝咖啡:https://afdian.com/a/cqgnyy 感谢${NC}"
    echo "================================================"
    
}

# 运行主程序
main
