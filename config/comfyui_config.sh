#!/bin/bash

# 基础配置
export WORK_DIR="/workspace"
export PROJECT_NAME="ComfyUI"
export CONDA_ENV_NAME="comfyui_env"
export PYTHON_VERSION="3.12"

# ngrok token
export NGROK_TOKEN=""

# CUDA 和 PyTorch 更新开关
export CUDA_PYTORCH=false

# 模型下载配置
export DOWNLOAD_MODELS=true

# 模型平台配置
export USE_HUGGINGFACE=true
export USE_MODELSCOPE=true
export HF_TOKEN=""          # HuggingFace token
export MODELSCOPE_TOKEN=""  # ModelScope token

# 目录配置
export LOG_DIR="$WORK_DIR/logs"
export MODELS_DIR="$WORK_DIR/$PROJECT_NAME/models"
export TMP_DIR="$WORK_DIR/tmp"
export BACKUP_DIR="$WORK_DIR/backups"

# 日志配置
export LOG_FILE="$LOG_DIR/install.log"
export LOG_LEVEL="INFO"  # DEBUG, INFO, WARNING, ERROR
export MAX_LOG_SIZE="10M"
export LOG_BACKUP_COUNT=5

# 网络配置
export DEFAULT_PORT=8188
export TIMEOUT=30
export MAX_RETRIES=3
export DOWNLOAD_THREADS=4

# 仓库配置
export REPO_URLS=(
    ["comfyui"]="https://github.com/comfyanonymous/ComfyUI.git"
    ["manager"]="https://github.com/ltdrdata/ComfyUI-Manager.git"
)

# 模型配置
export MODEL_SOURCES=(
    # HuggingFace模型
    ["sd_v15_hf"]="huggingface:runwayml/stable-diffusion-v1-5:v1-5-pruned-emaonly.safetensors:checkpoints"
    ["vae_hf"]="huggingface:stabilityai/sd-vae-ft-mse:vae-ft-mse-840000-ema-pruned.safetensors:vae"
    
    # ModelScope模型
    ["sd_v15_ms"]="modelscope:AI-ModelScope/stable-diffusion-v1-5:v1-5-pruned-emaonly.safetensors:checkpoints"
    ["controlnet_ms"]="modelscope:damo/cv_controlnet_canny:control_v11p_sd15_canny.pth:controlnet"
)

# 系统要求
export MIN_DISK_SPACE=20  # GB
export MIN_MEMORY=8       # GB
export REQUIRED_CUDA="11.8"

# 功能开关
export ENABLE_AUTO_UPDATE=true
export ENABLE_BACKUP=true
export ENABLE_MONITORING=true
