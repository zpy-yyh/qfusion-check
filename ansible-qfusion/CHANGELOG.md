# 更新日志

## [1.0.2] - 2026-04-03

### 修复
- 修复网卡速率检查中的类型比较错误（int与str比较）
- 修复fstab检查中的命令失败问题（添加|| true）
- 修复playbook中的run_once参数错误（per_host改为布尔值）
- 修复remote_init.yml中的include_tasks错误（改为include_role）

### 测试
- 在麒麟V10 SP3系统上测试通过
- 测试2台master节点（192.168.1.87, 192.168.1.99）
- 所有playbook测试通过：check_only.yml, fix_and_check.yml, remote_init.yml

## [1.0.0] - 2026-04-03

### 初始版本
- 基于qfusion_package/qfusion.sh重构的Ansible版本
- 支持21项环境检查
- 支持自动修复功能
- 支持批量远程部署
