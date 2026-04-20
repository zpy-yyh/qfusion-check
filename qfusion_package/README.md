# QFusion 统一管理脚本

## 功能特性

- 自动检查系统环境配置
- 一键修复常见配置问题
- 支持单节点和批量节点管理
- 支持本地ISO YUM源配置
- 支持远程节点初始化

## 安装方法

### 方法1: 使用安装脚本（推荐）
```bash
tar -xzf qfusion_package.tar.gz
cd qfusion_package
bash install.sh
```

### 方法2: 手动安装
```bash
tar -xzf qfusion_package.tar.gz
cd qfusion_package
cp qfusion.sh /usr/local/bin/qfusion
chmod +x /usr/local/bin/qfusion
```

## 使用方法

### 基本命令
```bash
qfusion                 # 显示交互式菜单
qfusion --check        # 只检查不修复
qfusion --remote-init  # 远程初始化模式（用于批量部署）
qfusion --help         # 显示帮助信息
```

### 检查项目
脚本会自动检查以下项目：

1. **YUM源配置** - 检查并配置本地或在线YUM源
2. **硬件时间同步** - 确保系统时间与硬件时间同步
3. **网卡速率** - 检查网卡速率是否符合要求
4. **DNS配置** - 检查DNS服务器可达性
5. **网络服务** - 检查NetworkManager状态（CentOS/RHEL 7）
6. **Swap分区** - 确保Swap分区已关闭
7. **SELinux** - 确保SELinux已禁用
8. **I/O调度算法** - 配置合适的磁盘调度算法
9. **透明大页** - 禁用透明大页
10. **文件系统** - 检查挂载参数是否正确
11. **用户和组** - 检查qfusion用户和组是否存在
12. **防火墙** - 配置必要的防火墙规则
13. **SSH服务** - 确保SSH服务正常运行

### 远程批量部署
脚本支持批量部署到多台服务器：

1. 创建节点列表文件 `nodes.conf`，格式：
   ```
   10.10.156.211 root password123
   10.10.156.212 root password456
   ```

2. 运行远程初始化：
   ```bash
   qfusion  # 选择批量节点管理功能
   ```

## 注意事项

- 脚本需要在 root 权限下运行
- 远程部署需要配置 SSH 免密登录或提供密码
- 建议在正式环境使用前先在测试环境验证

## 版本信息
- 版本: 1.0
- 更新日期: 2025-10-29