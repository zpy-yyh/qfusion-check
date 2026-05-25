# QFusion Ansible 检查脚本

基于 Bash 脚本 `qfusion_package/qfusion.sh` 重构的 Ansible 版本。

## 目录结构

```
ansible-qfusion/
├── ansible.cfg              # Ansible 配置文件
├── README.md                # 本文件
├── inventory/
│   └── hosts.yml            # 节点清单
├── group_vars/
│   └── all.yml              # 全局变量
├── playbooks/
│   ├── check_only.yml       # 只检查（不修改）
│   ├── fix_and_check.yml    # 检查并修复
│   └── remote_init.yml     # 远程初始化
└── roles/
    └── qfusion_check/       # 主角色
        ├── tasks/
        │   └── main.yml     # 主任务文件
        ├── handlers/
        │   └── main.yml     # 处理程序
        ├── vars/
        │   └── main.yml     # 角色变量
        └── files/
            └── check_functions.sh  # 辅助脚本
```

## 快速开始

### 1. 配置节点清单

编辑 `inventory/hosts.yml`，添加你的节点信息：

```yaml
qfusion_masters:
  hosts:
    master1:
      ansible_host: 192.168.1.97
      ansible_user: root
      ansible_ssh_private_key_file: /root/.ssh/id_rsa
```

### 2. 测试连接

```bash
ansible -i inventory/hosts.yml all -m ping
```

### 3. 执行检查

**只检查（不修改配置）：**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml
```

**检查并修复：**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/fix_and_check.yml
```

**远程初始化（包含RAID配置）：**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/remote_init.yml
```

### 4. 查看检查结果

结果会保存在各节点的 `/tmp/qfusion_ansible_reports/` 目录下。

## Playbooks 说明

| Playbook | 说明 | 是否修改系统 |
|----------|------|-------------|
| check_only.yml | 只执行检查，不修改任何配置 | 否 |
| fix_and_check.yml | 检查并自动修复问题 | 是 |
| remote_init.yml | 完整的远程初始化流程 | 是 |

## 支持的检查项

1. ✅ 操作系统检测（RedHat 7.8/7.9、CentOS 7.x、麒麟V10 SP3）
2. ✅ 内核版本检查（要求 > 4.19）
3. ✅ YUM源配置
4. ✅ 硬件时间同步
5. ✅ 网卡速率检查
6. ✅ DNS配置
7. ✅ NetworkManager管理
8. ✅ Swap分区
9. ✅ SELinux状态
10. ✅ I/O调度算法
11. ✅ Auditd服务
12. ✅ 主机名格式
13. ✅ 必需软件包
14. ✅ 容器软件冲突检查
15. ✅ /tmp目录权限
16. ✅ virbr0网卡
17. ✅ CPU AVX指令集
18. ✅ 用户资源限制（ulimit）
19. ✅ lsblk与fstab匹配
20. ✅ IPv6状态
21. ✅ iptables状态
22. ✅ kdump参数
23. ✅ crashkernel内存
24. ✅ 裸盘LVM挂载
25. ✅ 麒麟ARM bpf_jit

## 自定义配置

编辑 `group_vars/all.yml` 来自定义检查参数，例如：

```yaml
# 修改DNS服务器
network:
  dns_servers:
    - "114.114.114.114"
    - "8.8.8.8"

# 修改SELinux目标状态
system:
  selinux_state: "disabled"
```

## 从原Bash脚本迁移

原脚本：`/opt/qfusion-check/qfusion_package/qfusion.sh`

对应关系：
- `qfusion.sh --check` → `ansible-playbook playbooks/check_only.yml`
- `qfusion.sh --remote-init` → `ansible-playbook playbooks/remote_init.yml`

## 注意事项

1. **首次使用前**，确保控制节点可以SSH免密登录到所有目标节点
2. 生产环境使用前，先在测试环境验证
3. `check_only.yml` 是安全的，不会修改系统配置
4. `fix_and_check.yml` 会修改系统配置，请仔细检查变量设置

## 依赖要求

- Ansible 2.9+
- Python 3.6+ (目标节点)
- Bash (目标节点)
- SSH (目标节点)

## 故障排查

### 连接失败
```bash
# 检查SSH连接
ssh root@192.168.1.97

# 使用详细模式运行
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml -vvv
```

### 权限问题
确保Ansible可以提升权限：
```bash
ansible all -i inventory/hosts.yml -m shell -a "whoami" -b
```

## License

本项目基于原QFusion安装前检查脚本重构。
