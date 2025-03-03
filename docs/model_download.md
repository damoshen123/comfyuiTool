# 模型下载指南

本文档介绍如何使用我们的下载脚本从HuggingFace和ModelScope下载模型。

## HuggingFace和ModelScope模型下载

### 1. 配置文件设置

在`config/comfyui_config.sh`中设置以下配置：

```bash
# 启用模型下载
export DOWNLOAD_MODELS=true

# 选择下载平台
export USE_HUGGINGFACE=true  # 是否使用HuggingFace
export USE_MODELSCOPE=true   # 是否使用ModelScope

# 设置平台Token（如需要）
export HF_TOKEN=""          # HuggingFace token
export MODELSCOPE_TOKEN=""  # ModelScope token

# 设置模型存储路径
export MODELS_DIR="/path/to/your/models"
```

### 2. 添加新模型

在配置文件的`MODEL_SOURCES`数组中添加新的模型。格式为：
`[模型别名]="平台:模型ID:文件名:目标子目录"`

```bash
export MODEL_SOURCES=(
    # HuggingFace模型
    ["sd_v15_hf"]="huggingface:runwayml/stable-diffusion-v1-5:v1-5-pruned-emaonly.safetensors:checkpoints"
    ["vae_hf"]="huggingface:stabilityai/sd-vae-ft-mse:vae-ft-mse-840000-ema-pruned.safetensors:vae"
    
    # ModelScope模型
    ["sd_v15_ms"]="modelscope:AI-ModelScope/stable-diffusion-v1-5:v1-5-pruned-emaonly.safetensors:checkpoints"
    ["controlnet_ms"]="modelscope:damo/cv_controlnet_canny:control_v11p_sd15_canny.pth:controlnet"
)
```

### 3. 执行下载

运行下载脚本：
```bash
bash scripts/download.sh
```

### 4. 自定义下载

#### HuggingFace模型
```bash
download_huggingface_model \
    "模型ID" \           # 例如 "runwayml/stable-diffusion-v1-5"
    "文件名.safetensors" \ # 要下载的具体文件
    "$MODELS_DIR/目标文件夹"  # 存储位置
```

#### ModelScope模型
```bash
download_modelscope_model \
    "模型ID" \           # 例如 "AI-ModelScope/stable-diffusion-v1-5"
    "文件名.safetensors" \ # 要下载的具体文件
    "$MODELS_DIR/目标文件夹"  # 存储位置
```

### 注意事项

1. 两个平台可以同时启用或单独使用
2. 每个平台都有独立的开关和Token配置
3. 下载时会自动跳过已存在的文件
4. HuggingFace使用镜像站点(hf-mirror.com)加速下载
5. 支持断点续传

### 示例

1. **只使用HuggingFace**
```bash
export USE_HUGGINGFACE=true
export USE_MODELSCOPE=false
```

2. **只使用ModelScope**
```bash
export USE_HUGGINGFACE=false
export USE_MODELSCOPE=true
```

3. **同时使用两个平台**
```bash
export USE_HUGGINGFACE=true
export USE_MODELSCOPE=true
```

## 常见问题

1. **下载失败**
   - 检查网络连接
   - 确认模型ID和文件名是否正确
   - 验证平台Token是否正确设置
   - 尝试使用VPN或代理

2. **存储空间不足**
   - 检查`MIN_DISK_SPACE`配置
   - 清理不需要的模型文件
   - 确保目标目录有足够空间

3. **权限问题**
   - 确保有目标目录的写入权限
   - 检查用户权限设置

4. **平台特定问题**
   - HuggingFace：检查`HF_TOKEN`是否正确设置
   - ModelScope：确认`MODELSCOPE_TOKEN`是否有效
