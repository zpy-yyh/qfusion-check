# YUM检查日志存档

## 📁 目录说明

本目录包含YUM源配置检查的日志文件。

## 📊 日志文件

- `172.30.30.101_yum_check.log` - 节点172.30.30.101的YUM检查日志
- `172.30.30.102_yum_check.log` - 节点172.30.30.102的YUM检查日志
- `172.30.30.103_yum_check.log` - 节点172.30.30.103的YUM检查日志

## 🔍 查看日志

### 查看单个节点日志
```bash
cat 172.30.30.101_yum_check.log
```

### 查看所有节点错误
```bash
grep -i "error\|fail\|异常" *.log
```

### 查看所有节点YUM源数量
```bash
grep -E "repo.*enabled" *.log
```

## 📋 检查内容

YUM检查脚本验证以下内容：
1. YUM服务是否可用
2. YUM源是否配置正确
3. YUM源是否可访问
4. 软件包是否可安装
5. 依赖关系是否正确

## 🔧 相关工具

- `../check_yum.sh` - YUM检查脚本
- `../check_yum_config.sh` - YUM配置检查
- `../test_yum_on_cluster.sh` - YUM集群测试

## 🔗 相关文档

- [../../README.md](../../README.md) - 项目总览
- [../../QFusion安装前后检查项.docx](../../QFusion安装前后检查项.docx) - 完整检查项说明

## ⚠️ 注意事项

- 日志文件包含详细的YUM检查信息
- 如发现问题，请根据日志内容进行修复
- 建议定期清理旧日志文件

## 📅 归档说明

此目录为历史日志存档，如需重新检查YUM配置：
```bash
cd /root/zpy
./check_yum.sh
```
