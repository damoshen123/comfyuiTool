#!/bin/bash

# 导入测试框架
source "$(dirname "$0")/../utils/test_framework.sh"

# 测试初始化函数
test_init_script() {
    # 设置测试环境
    setup_test_env
    
    # 运行初始化
    init_script
    
    # 验证结果
    assert_dir_exists "$ROOT_DIR/config"
    assert_dir_exists "$ROOT_DIR/utils"
    assert_file_exists "$LOG_FILE"
    assert_var_not_empty "CONDA_ENV_NAME"
    
    # 清理测试环境
    cleanup_test_env
}

# 测试错误处理
test_error_handling() {
    # 模拟错误
    (set -e; false) 2>/dev/null
    
    # 验证错误处理
    assert_last_command_failed
    assert_log_contains "错误发生在"
}

# 运行所有测试
run_all_tests() {
    test_init_script
    test_error_handling
    
    report_test_results
}

# 执行测试
run_all_tests 