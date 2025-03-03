#!/bin/bash

# 确保日志目录存在
init_logging() {
    if [ -z "$LOG_DIR" ] || [ -z "$LOG_FILE" ]; then
        echo "错误：LOG_DIR 或 LOG_FILE 未定义"
        exit 1
    fi
    
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"
    echo "=== 安装日志开始于 $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"
}

log_info() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
    echo -e "$message" | tee -a "$LOG_FILE"
}

log_error() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1"
    echo -e "${RED}$message${NC}" | tee -a "$LOG_FILE"
}

log_warning() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1"
    echo -e "${YELLOW}$message${NC}" | tee -a "$LOG_FILE"
}

log_debug() {
    if [ "${DEBUG:-false}" = "true" ]; then
        local message="[$(date '+%Y-%m-%d %H:%M:%S')] [DEBUG] $1"
        echo -e "${CYAN}$message${NC}" | tee -a "$LOG_FILE"
    fi
}

show_progress() {
    local current=$1
    local total=$2
    local prefix=$3
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r%s [%s%s] %d%%" "$prefix" \
           "$(printf '#%.0s' $(seq 1 $completed))" \
           "$(printf '.%.0s' $(seq 1 $remaining))" \
           "$percentage"
} 