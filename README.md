

## 快速开始【免费版】
### 只 ComfyUI 的安装示范
### 包含 ComfyUI + ComfyUI Manager + Ngrok + 国内环境可安装

1. **克隆仓库**：
    只需运行命令：
    ```bash
    git clone https://github.com/aigem/aitools.git
    ```
    国内环境可用：
    ```bash
    git clone https://openi.pcl.ac.cn/niubi/aitools.git
    ```
    ```bash
    git clone https://gitee.com/fuliai/aitools.git
    ```

    ```bash
    cd aitools && git pull
    ```
    

2. **运行安装脚本**：
    ```bash
    bash aitools.sh
    ```
    在菜单中选择选项 1 (ComfyUI) 开始自动安装

3. **程序运行说明**： 

    - 启动ComfyUI服务
    `cd /workspace/ComfyUI/ && python main.py`

    - 启动 Ngrok 隧道服务
    新开一个终端(命令行)运行 Ngrok 隧道服务
     `ngrok http 8188` 

    - 访问 Ngrok 隧道服务生成的网址

