# Ansible QFusion 1.0.2 使用指南

## 快速开始

### 1. 解压文件
```bash
cd /root
tar -xzf ansible-qfusion-1.0.2.tar.gz
cd ansible-qfusion
```

### 2. 配置目标节点

编辑 `inventory/hosts.yml`，修改节点信息：

```yaml
qfusion_masters:
  hosts:
    master1:
      ansible_host: 10.10.156.87
      ansible_user: root
      ansible_ssh_pass: "your_password"
    master2:
      ansible_host: 10.10.156.99
      ansible_user: root
      ansible_ssh_pass: "your_password"
```

### 3. 运行检查

**方式1: 只检查（不修改配置）**
```bash
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml \
  -e "ansible_ssh_pass=your_password"
```

**方式2: 检查并修复**
```bash
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory/hosts.yml playbooks/fix_and_check.yml \
  -e "ansible_ssh_pass=your_password"
```

**方式3: 完整初始化**
```bash
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory/hosts.yml playbooks/remote_init.yml \
  -e "ansible_ssh_pass=your_password"
```

## 测试检查清单

### 基础功能测试
- [ ] check_only.yml 能否正常运行
- [ ] fix_and_check.yml 能否正常运行
- [ ] remote_init.yml 能否正常运行

### 检查项验证
- [ ] 操作系统检测正确
- [ ] 内核版本检查正确
- [ ] YUM源配置检查正确
- [ ] 网卡速率检查正确
- [ ] DNS配置检查正确
- [ ] SELinux检查正确
- [ ] Swap分区检查正确
- [ ] 必需软件包检查正确

### 修复功能验证
- [ ] 自动修复SELinux配置
- [ ] 自动修复Swap配置
- [ ] 自动修复DNS配置
- [ ] 自动修复系统参数

### 报告生成
- [ ] 检查报告是否生成在 /tmp/qfusion_ansible_reports/
- [ ] 报告内容是否完整
- [ ] 报告格式是否易读

## 常见问题

### Q1: 如何跳过SSH主机密钥检查？
```bash
export ANSIBLE_HOST_KEY_CHECKING=False
```

### Q2: 如何使用SSH密钥认证？
```bash
# 生成SSH密钥
ssh-keygen -t rsa -b 4096

# 复制密钥到目标节点
ssh-copy-id root@10.10.156.87
ssh-copy-id root@10.10.156.99

# 修改inventory/hosts.yml，删除ansible_ssh_pass行
```

### Q3: 如何只检查特定项目？
```bash
# 使用tags
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml \
  -e "ansible_ssh_pass=your_password" --tags "check_kernel"
```

### Q4: 如何查看详细输出？
```bash
ansible-playbook -i inventory/hosts.yml playbooks/check_only.yml \
  -e "ansible_ssh_pass=your_password" -vvv
```

## 测试建议

1. **先在测试环境验证**: 在非生产环境先测试所有功能
2. **备份数据**: 运行修复playbook前备份重要配置
3. **逐步测试**: 先运行check_only，确认无误后再运行fix_and_check
4. **查看报告**: 检查生成的报告文件，确认所有检查项
5. **记录问题**: 遇到问题记录详细信息，便于排查

## 技术支持

- 查看详细测试报告: `TEST_SUMMARY_1.0.2.md`
- 查看更新日志: `CHANGELOG.md`
- 查看版本信息: `VERSION.txt`

## 版本信息

- 版本: 1.0.2
- 打包时间: 2026-04-03
- 测试环境: 麒麟V10 SP3
- 测试节点: 2台master节点
- 测试结果: ✅ 全部通过
