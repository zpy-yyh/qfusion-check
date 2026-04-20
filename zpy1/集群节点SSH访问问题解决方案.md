# 集群节点SSH访问问题解决方案

## 一、环境信息

| 项目 | 内容 |
|------|------|
| 集群规模 | 4个节点 |
| 节点IP范围 | 10.204.1.97 - 10.204.1.100 |
| 用途 | 集群通信 + 业务访问 |
| 问题 | 安全加固后节点间无法SSH访问 |

---

## 二、问题原因

安全加固方案中配置了iptables规则，仅允许特定IP访问SSH端口（22），**未包含集群节点自身IP（10.204.1.97-100）**，导致节点间无法互访。

---

## 三、解决方案

### 3.1 整体策略

在现有iptables规则基础上，**在DROP规则之前**插入集群节点间的SSH放行规则。

### 3.2 规则添加位置

```bash
# 在DROP规则之前插入（使用-I参数）
iptables -I INPUT <规则位置> ...
```

---

## 四、具体操作步骤

### 4.1 查看当前规则

在所有节点执行：

```bash
# 查看当前iptables规则及编号
iptables -nvL INPUT --line-numbers
```

输出示例：
```
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     tcp  --  10.73.73.10          0.0.0.0/0            multiport dports 22,21080,21081
2    ACCEPT     tcp  --  10.203.1.102         0.0.0.0/0            multiport dports 22,21080,21081
...
N    DROP       tcp  --  0.0.0.0/0            0.0.0.0/0            multiport dports 22,21080,21081
```

### 4.2 备份当前规则

```bash
# 在所有节点执行备份
mkdir -p /root/tmp
iptables-save > /root/tmp/iptables-$(date +%Y%m%d).bak
cp /etc/sysconfig/iptables-config /root/tmp/iptables-config-$(date +%Y%m%d).bak
```

### 4.3 添加集群节点SSH放行规则

#### 方法一：逐个添加节点IP（精确控制）

```bash
# 在所有节点执行以下规则
# 规则1: 放行10.204.1.97
iptables -I INPUT -p tcp -s 10.204.1.97 --dport 22 -j ACCEPT

# 规则2: 放行10.204.1.98
iptables -I INPUT -p tcp -s 10.204.1.98 --dport 22 -j ACCEPT

# 规则3: 放行10.204.1.99
iptables -I INPUT -p tcp -s 10.204.1.99 --dport 22 -j ACCEPT

# 规则4: 放行10.204.1.100
iptables -I INPUT -p tcp -s 10.204.1.100 --dport 22 -j ACCEPT
```

#### 方法二：使用网段（推荐，简洁高效）

```bash
# 10.204.1.97-100 属于 10.204.1.0/24 网段
# 在所有节点执行
iptables -I INPUT -p tcp -s 10.204.1.0/24 --dport 22 -j ACCEPT
```

### 4.4 管理节点额外配置

如果该节点是**管理节点**，还需要放行21080和21081端口：

```bash
# 仅在管理节点执行
iptables -I INPUT -p tcp -s 10.204.1.0/24 -m multiport --dports 22,21080,21081 -j ACCEPT
```

---

## 五、验证配置

### 5.1 检查规则是否生效

```bash
# 在所有节点执行
iptables -nvL INPUT --line-numbers | grep 10.204
```

预期输出应包含类似以下内容：
```
ACCEPT     tcp  --  10.204.1.0/24        0.0.0.0/0            tcp dpt:22
```

### 5.2 测试SSH连通性

```bash
# 在节点1 (10.204.1.97) 测试连接其他节点
ssh root@10.204.1.98 "hostname"
ssh root@10.204.1.99 "hostname"
ssh root@10.204.1.100 "hostname"

# 预期输出：各节点主机名
```

---

## 六、持久化保存

### 6.1 保存iptables规则

```bash
# 在所有节点执行
iptables-save > /etc/sysconfig/iptables
```

### 6.2 更新rc.local（按原方案方式）

编辑 `/etc/rc.d/rc.local` 文件：

```bash
vi /etc/rc.d/rc.local
```

在文件中**添加以下内容**（放在其他iptables规则之前）：

```bash
# ===== 集群节点SSH放行规则 =====
# 放行集群网段访问SSH端口
iptables -I INPUT -p tcp -s 10.204.1.0/24 --dport 22 -j ACCEPT

# 如果是管理节点，取消注释下面这行
# iptables -I INPUT -p tcp -s 10.204.1.0/24 -m multiport --dports 22,21080,21081 -j ACCEPT
```

确保rc.local有执行权限：

```bash
chmod +x /etc/rc.d/rc.local
```

---

## 七、完整部署脚本

### 7.1 工作节点脚本

```bash
#!/bin/bash
# 工作节点SSH放行配置脚本
# 文件名: config_worker_node.sh

echo "开始配置工作节点SSH规则..."

# 备份当前规则
mkdir -p /root/tmp
iptables-save > /root/tmp/iptables-$(date +%Y%m%d-%H%M%S).bak

# 添加集群节点SSH放行规则
iptables -I INPUT -p tcp -s 10.204.1.97 --dport 22 -j ACCEPT
iptables -I INPUT -p tcp -s 10.204.1.98 --dport 22 -j ACCEPT
iptables -I INPUT -p tcp -s 10.204.1.99 --dport 22 -j ACCEPT
iptables -I INPUT -p tcp -s 10.204.1.100 --dport 22 -j ACCEPT

# 或者使用网段方式（二选一）
# iptables -I INPUT -p tcp -s 10.204.1.0/24 --dport 22 -j ACCEPT

# 保存规则
iptables-save > /etc/sysconfig/iptables

# 显示当前规则
echo "当前iptables INPUT链规则："
iptables -nvL INPUT --line-numbers

echo "配置完成！"
```

### 7.2 管理节点脚本

```bash
#!/bin/bash
# 管理节点SSH放行配置脚本
# 文件名: config_master_node.sh

echo "开始配置管理节点SSH规则..."

# 备份当前规则
mkdir -p /root/tmp
iptables-save > /root/tmp/iptables-$(date +%Y%m%d-%H%M%S).bak

# 添加集群节点SSH放行规则（包含21080、21081端口）
iptables -I INPUT -p tcp -s 10.204.1.97 -m multiport --dports 22,21080,21081 -j ACCEPT
iptables -I INPUT -p tcp -s 10.204.1.98 -m multiport --dports 22,21080,21081 -j ACCEPT
iptables -I INPUT -p tcp -s 10.204.1.99 -m multiport --dports 22,21080,21081 -j ACCEPT
iptables -I INPUT -p tcp -s 10.204.1.100 -m multiport --dports 22,21080,21081 -j ACCEPT

# 或者使用网段方式（二选一）
# iptables -I INPUT -p tcp -s 10.204.1.0/24 -m multiport --dports 22,21080,21081 -j ACCEPT

# 保存规则
iptables-save > /etc/sysconfig/iptables

# 显示当前规则
echo "当前iptables INPUT链规则："
iptables -nvL INPUT --line-numbers

echo "配置完成！"
```

### 7.3 批量部署脚本

```bash
#!/bin/bash
# 在管理节点执行，批量配置所有节点
# 文件名: deploy_all_nodes.sh

# 定义节点列表
NODES=(
"10.204.1.97"
"10.204.1.98"
"10.204.1.99"
"10.204.1.100"
)

# 判断是否为管理节点
MASTER_NODE="10.204.1.97"  # 假设第一个节点是管理节点

for node in "${NODES[@]}"; do
    echo "正在配置节点: $node"

    if [ "$node" == "$MASTER_NODE" ]; then
        # 管理节点配置
        ssh root@$node "iptables -I INPUT -p tcp -s 10.204.1.0/24 -m multiport --dports 22,21080,21081 -j ACCEPT"
    else
        # 工作节点配置
        ssh root@$node "iptables -I INPUT -p tcp -s 10.204.1.0/24 --dport 22 -j ACCEPT"
    fi

    # 保存规则
    ssh root@$node "iptables-save > /etc/sysconfig/iptables"

    echo "节点 $node 配置完成"
    echo "--------------------------------"
done

echo "所有节点配置完成！"
```

---

## 八、应急回退方案

### 8.1 删除新添加的规则

```bash
# 查看规则编号
iptables -nvL INPUT --line-numbers

# 删除指定规则（将<N>替换为实际编号）
iptables -D INPUT <N>
```

### 8.2 恢复备份

```bash
# 恢复备份文件
iptables-restore < /root/tmp/iptables-YYYYMMDD.bak

# 保存
iptables-save > /etc/sysconfig/iptables
```

### 8.3 临时关闭防火墙（紧急情况）

```bash
# 仅用于紧急故障恢复
systemctl stop iptables
# 或
iptables -F
```

---

## 九、节点IP对应表

| 节点名称 | IP地址 | 节点类型 | 需要放行端口 |
|---------|--------|---------|-------------|
| 节点1 | 10.204.1.97 | 管理节点 | 22, 21080, 21081 |
| 节点2 | 10.204.1.98 | 工作节点 | 22 |
| 节点3 | 10.204.1.99 | 工作节点 | 22 |
| 节点4 | 10.204.1.100 | 工作节点 | 22 |

---

## 十、操作检查清单

- [ ] 在所有节点备份当前iptables规则
- [ ] 在所有节点添加集群网段SSH放行规则
- [ ] 管理节点额外添加21080、21081端口放行
- [ ] 验证iptables规则生效
- [ ] 测试节点间SSH连通性
- [ ] 保存规则到配置文件
- [ ] 更新rc.local确保持久化
- [ ] 记录操作日志

---

## 十一、注意事项

| 注意项 | 说明 |
|-------|------|
| **规则顺序** | 使用 `-I` 参数确保规则在DROP规则之前生效 |
| **测试验证** | 建议先在单个节点测试，确认无误后再批量部署 |
| **网段选择** | 使用 `/24` 网段比单个IP更灵活，便于后续扩展 |
| **权限问题** | 确保rc.local有执行权限：`chmod +x /etc/rc.d/rc.local` |
| **重启验证** | 配置完成后建议重启节点验证规则持久化 |

---

## 十二、快速操作命令（复制即用）

```bash
# === 在所有节点执行 ===
# 1. 备份
iptables-save > /root/tmp/iptables-backup-$(date +%Y%m%d).bak

# 2. 添加规则（工作节点）
iptables -I INPUT -p tcp -s 10.204.1.0/24 --dport 22 -j ACCEPT

# 3. 添加规则（管理节点）
# iptables -I INPUT -p tcp -s 10.204.1.0/24 -m multiport --dports 22,21080,21081 -j ACCEPT

# 4. 保存
iptables-save > /etc/sysconfig/iptables

# 5. 验证
iptables -nvL INPUT --line-numbers | grep 10.204

# 6. 测试SSH
ssh 10.204.1.98 "hostname"
```

---

**文档版本**: v1.0
**创建日期**: 2026-04-02
**适用环境**: 4节点集群 (10.204.1.97-100)
