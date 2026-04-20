# QFusion安装前手动操作指南

> 版本: 1.0
> 更新时间: 2026-03-06
> 适用场景: 需要人工操作的QFusion安装前检查项

## 📋 目录

1. [fio压测](#1-fio压测)
2. [CPU性能模式配置](#2-cpu性能模式配置)
3. [NUMA配置](#3-numa配置)
4. [Dell 750驱动安装](#4-dell-750驱动安装)

---

## 1. fio压测

### 1.1 目的
- 验证数据盘和系统盘的I/O性能
- 确保存储性能满足QFusion要求
- 提前发现存储瓶颈

### 1.2 安装fio工具

#### 检查fio是否已安装
```bash
which fio
```

#### 安装fio
```bash
# 使用YUM安装
yum install -y fio

# 验证安装
fio --version
```

### 1.3 系统盘压测（随机读）

#### 压测命令
```bash
fio --name=sys_randread \
    --filename=/dev/sda \
    --rw=randread \
    --bs=1M \
    --iodepth=32 \
    --numjobs=4 \
    --runtime=300 \
    --time_based \
    --group_reporting \
    --output-format=json \
    --output=sys_randread.json
```

#### 参数说明
- `--filename`: 设备路径（请根据实际情况修改）
- `--rw=randread`: 随机读
- `--bs=1M`: 块大小1MB
- `--iodepth=32`: I/O队列深度
- `--numjobs=4`: 并发任务数
- `--runtime=300`: 运行300秒（5分钟）
- `--time_based`: 基于时间运行
- `--group_reporting`: 汇总报告
- `--output-format=json`: 输出JSON格式

#### 预期结果
```json
{
  "jobs": [
    {
      "jobname": "sys_randread",
      "read": {
        "iops": 1234.56,
        "bw": 12345678.0,
        "lat": {
          "avg": 0.123
        }
      }
    }
  ]
}
```

#### 性能指标
- **IOPS**: 每秒I/O操作数
- **BW**: 带宽（字节/秒）
- **Lat**: 延迟（秒）

#### QFusion最低要求
- **系统盘IOPS**: 建议 > 1000
- **系统盘带宽**: 建议 > 100MB/s

### 1.4 数据盘压测（随机写）

#### 压测命令
```bash
fio --name=data_randwrite \
    --filename=/dev/sdb \
    --rw=randwrite \
    --bs=1M \
    --iodepth=32 \
    --numjobs=4 \
    --runtime=300 \
    --time_based \
    --group_reporting \
    --output-format=json \
    --output=data_randwrite.json
```

#### 性能指标
- **IOPS**: 每秒I/O操作数
- **BW**: 写入带宽（字节/秒）

#### QFusion最低要求
- **数据盘IOPS**: 建议 > 5000
- **数据盘带宽**: 建议 > 500MB/s

### 1.5 数据盘压测（顺序读写）

#### 顺序读写压测
```bash
# 顺序读
fio --name=data_seqread \
    --filename=/dev/sdb \
    --rw=read \
    --bs=1M \
    --iodepth=32 \
    --numjobs=4 \
    --runtime=300 \
    --time_based \
    --group_reporting

# 顺序写
fio --name=data_seqwrite \
    --filename=/dev/sdb \
    --rw=write \
    --bs=1M \
    --iodepth=32 \
    --numjobs=4 \
    --runtime=300 \
    --time_based \
    --group_reporting
```

### 1.6 查看压测结果

#### 简单查看
```bash
# 查看JSON结果
cat sys_randread.json | python3 -m json.tool

# 或直接查看fio输出
```

#### 详细分析
```bash
# 提取关键指标
fio ... | grep -E "IOPS|BW|lat"
```

#### 判断标准

| 性能指标 | 优秀 | 良好 | 需要优化 |
|----------|------|------|----------|
| IOPS | >10000 | 5000-10000 | <5000 |
| 带宽(MB/s) | >500 | 200-500 | <200 |
| 延迟(ms) | <10 | 10-50 | >50 |

### 1.7 故障排查

#### 问题1: Permission denied
```bash
# 解决：添加执行权限
chmod +x /dev/sda /dev/sdb

# 或使用sudo
sudo fio ...
```

#### 问题2: 设备忙
```bash
# 解���：停止使用设备的进程
lsof /dev/sda

# 或使用flock
fio --flock=/tmp/fio.lock ...
```

#### 问题3: 性能异常低
```bash
# 检查设备状态
lsblk -f

# 检查RAID状态
cat /proc/mdstat

# 检查磁盘健康
smartctl -a /dev/sda
```

### 1.8 完整压测脚本

```bash
#!/bin/bash
# QFusion存储性能压测脚本

DISKS=("/dev/sda" "/dev/sdb")  # 修改为实际设备路径
TIME=300  # 压测时间（秒）

echo "QFusion存储性能压测"
echo "=========================================="
echo ""

for disk in "${DISKS[@]}"; do
    echo "测试设备: $disk"
    echo "----------------------------------------"

    # 随机读测试
    echo "随机读测试..."
    fio --name=${disk}_randread \
        --filename=$disk \
        --rw=randread \
        --bs=1M \
        --iodepth=32 \
        --numjobs=4 \
        --runtime=$TIME \
        --time_based \
        --group_reporting | grep -E "IOPS|BW"

    # 随机写测试
    echo "随机写测试..."
    fio --name=${disk}_randwrite \
        --filename=$disk \
        --rw=randwrite \
        --bs=1M \
        --iodepth=32 \
        --numjobs=4 \
        --runtime=$TIME \
        --time_based \
        --group_reporting | grep -E "IOPS|BW"

    echo ""
done

echo "=========================================="
echo "压测完成！"
```

---

## 2. CPU性能模式配置

### 2.1 检查当前CPU性能模式

#### 检查CPU频率调节器
```bash
# 查看所有CPU的频率调节器
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 查看当前CPU频率
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
```

#### 常见的CPU调节器
| 调节器 | 说明 | 性能 | 功耗 |
|--------|------|------|------|
| performance | 始终使用最高频率 | ⭐⭐⭐⭐⭐ | ⭐ |
| ondemand | 按需调整 | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| powersave | 节能模式 | ⭐⭐ | ⭐⭐⭐⭐⭐ |

#### 期望输出
- 所有CPU的 `scaling_governor` 应该是 `performance`

### 2.2 临时修改（无需重启）

#### 设置为performance模式
```bash
# 对所有CPU设置为performance
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo performance > $cpu/cpufreq/scaling_governor
done

# 验证设置
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

#### 恢复默认设置
```bash
# 恢复为ondemand模式
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo ondemand > $cpu/cpufreq/scaling_governor
done
```

### 2.3 永久修改（需要重启）

#### 方法1: 修改grub配置

**备份配置**
```bash
cp /etc/default/grub /etc/default/grub.backup.$(date +%Y%m%d)
```

**编辑grub配置**
```bash
vim /etc/default/grub
```

添加以下参数到 `GRUB_CMDLINE_LINUX_DEFAULT`:
```bash
# 添加intel_pstate=active和max_perf_pct=100
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_pstate=active max_perf_pct=100"
```

**重新生成grub**
```bash
# BIOS启动模式
grub2-mkconfig -o /boot/grub2/grub.cfg

# UEFI启动模式（检查 /sys/firmware/efi 存在）
grub2-mkconfig -o /boot/efi/EFI/kylin/grub.cfg
```

**重启生效**
```bash
reboot
```

**验证配置**
```bash
# 查看启动参数
cat /proc/cmdline

# 检查CPU频率
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
```

#### 方法2: 使用cpupower工具

**安装cpupower**
```bash
yum install -y cpupowerutils
```

**设置CPU性能模式**
```bash
# 设置所有CPU为performance模式
cpupower frequency-set -g performance

# 验证设置
cpupower frequency-info
```

### 2.4 BIOS配置（推荐）

#### Dell服务器
1. 重启服务器，按F2进入BIOS
2. 找到 `Processor Settings` 或 `CPU Configuration`
3. 设置 `Performance Profile` 为 `Maximum Performance`
4. 保存并退出

#### HPE服务器
1. 重启服务器，按F10进入BIOS
2. 找到 `Power Management` 设置
3. 设置 `Performance Mode` 为 `Maximum Performance`
4. 禁用 `C-States` 和 `P-States`
5. 保存并退出

#### 其他品牌
- Lenovo: 按 F1 或 Enter 进入BIOS
- Huawei: 按 F12 或 Del 进入BIOS
- Inspur: 按 F11 或 Del 进入BIOS

### 2.5 验证CPU性能

#### 查看CPU频率
```bash
# 查看当前频率
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq

# 查看最大频率
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
```

#### 查看CPU使用率
```bash
# 实时监控CPU频率
watch -n 1 "cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq"

# 查看CPU利用率
top -bn1 | grep "Cpu(s)"
```

#### 性能对比测试
```bash
# 压力测试
stress --cpu 4 --timeout 60s

# 观察CPU频率是否稳定在最高频率
```

### 2.6 故障排查

#### 问题1: 无法修改governor
```bash
# 检查文件权限
ls -la /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 检查是否被锁定
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_driver
```

#### 问题2: 设置后立即恢复
```bash
# 检查是否有电源管理服务
systemctl status power-profiles-daemon
systemctl status tuned

# 可能需要禁用冲突的服务
systemctl stop power-profiles-daemon
systemctl stop tuned
```

---

## 3. NUMA配置

### 3.1 检查NUMA状态

#### 查看NUMA配置
```bash
# 查看启动参数
cat /proc/cmdline | grep -o numa=[^ ]*

# 查看NUMA节点
numactl --hardware

# 查看NUMA策略
numactl --show
```

#### 预期输出
- 启动参数中应该有 `numa=off` 或没有 `numa=on`
- 如果显示多个NUMA节点，说明NUMA已启用

### 3.2 临时禁用NUMA（无需重启）

#### 方法1: 使用numactl运行进程
```bash
# 为单次操作禁用NUMA
numactl --interleave=all --cpunodebind=0,1,2,3 <command>

# 示例：在所有NUMA节点上分配内存
numactl --interleave-all <your_program>
```

#### 方法2: 使用numad守护进程
```bash
# 启动numad（自动NUMA平衡）
numad -d

# 验证
ps aux | grep numad
```

### 3.3 永久禁用NUMA（需要重启）

#### 方法1: 修改grub配置

**备份配置**
```bash
cp /etc/default/grub /etc/default/grub.backup.$(date +%Y%m%d)
```

**编辑grub配置**
```bash
vim /etc/default/grub
```

添加或修改 `GRUB_CMDLINE_LINUX_DEFAULT`:
```bash
# 添加numa=off
GRUB_CMDLINE_LINUX_DEFAULT="quiet numa=off"
```

**重新生成grub**
```bash
# BIOS启动模式
grub2-mkconfig -o /boot/grub2/grub.cfg

# UEFI启动模式
grub2-mkconfig -o /boot/efi/EFI/kylin/grub.cfg
```

**重启生效**
```bash
reboot
```

**验证配置**
```bash
# 查看启动参数
cat /proc/cmdline | grep numa

# 应该输出 numa=off 或没有numa=on
```

#### 方法2: BIOS禁用NUMA

**Dell服务器**
1. 进入BIOS
2. 找到 `Processor Settings`
3. 禁用 `Node Interleaving` 或 `NUMA`
4. 保存并退出

**HPE服务器**
1. 进入BIOS
2. 找到 `Advanced Options` -> `Processor Options`
3. 禁用 `Non-Uniform Memory Access (NUMA)`
4. 保存并退出

### 3.4 验证NUMA配置

#### 查看NUMA状态
```bash
# 查看NUMA节点数
numactl --hardware | grep "available:" | grep -oP 'available: \K[0-9]+'

# 应该显示1个节点
```

#### 查看内存分配
```bash
# 查看每个NUMA节点的内存
numactl --hardware

# 禁用NUMA后，应该只显示一个节点
```

#### 查看进程NUMA策略
```bash
# 查看当前进程的NUMA策略
numactl --show

# 查看特定进程
numactl --pid <pid>
```

### 3.5 NUMA性能优化

#### 内存分配策略
```bash
# 统一内存访问（减少NUMA性能损失）
numactl --preferred=0 <program>

# 禁用NUMA运行
numactl --cpunodebind=0 <program>
```

#### BIOS内存映射
```
Dell服务器BIOS设置建议：
1. Memory Mode: Flat
2. Node Interleaving: Disabled
3. NUMA: Disabled
```

### 3.6 故障排查

#### 问题1: 无法禁用NUMA
```bash
# 检查硬件是否支持
cat /proc/cmdline | grep intel_iommu

# 某些硬件架构不支持禁用NUMA
lscpu | grep NUMA
```

#### 问题2: 禁用后性能下降
```bash
# 检查内存带宽
numactl --hardware

# 可能需要平衡NUMA和性能
# 考虑使用 interleave-all 而不是完全禁用
```

---

## 4. Dell 750驱动安装

### 4.1 检测服务器型号

#### 检查服务器型号
```bash
# 查看产品名称
dmidecode -s system-product-name

# 查看制造商
dmidecode -s system-manufacturer

# 查看BIOS信息
dmidecode -s bios-vendor
dmidecode -s bios-version
```

#### Dell PowerEdge 750特征
- 产品名称: PowerEdge R750
- 制造商: Dell Inc.
- BIOS版本: 2.x.x 或更高

### 4.2 检查内核版本

#### 查看当前内核
```bash
uname -r
```

#### 兼容性说明
- **内核 < 4.19**: 可能需要更新驱动
- **内核 >= 4.19**: 推荐使用最新版本的Megaraid驱动
- **问题**: 某些版本的Megaraid驱动与4.19内核存在兼容问题

### 4.3 检查当前RAID卡

#### 查看RAID卡型号
```bash
lspci | grep -i raid
```

#### 查看RAID卡详细信息
```bash
# 使用lspci详细查看
lspci -vvv -s | grep -A 20 "RAID"

# 查看当前驱动
lsmod | grep megasas
```

#### 期望输出
```
xx:00:00.0 RAID bus controller: Dell PERC H750P Adapter
```

### 4.4 下载驱动

#### 方法1: Dell官网下载
1. 访问: https://www.dell.com/support
2. 输入服务标签（Service Tag）
3. 选择服务器型号: PowerEdge R750
4. 选择操作系统: Linux
5. 选择内核版本: 4.19 或更高
6. 下载: "Dell PERC H750P Adapter"
7. 选择驱动包: megaraid_sas-07.xxx.xx-1.el7_7.noarch.rpm

#### 方法2: Dell OpenManage
```bash
# 安装OpenManage
yum install -y srvadmin-all

# 使用omsa下载驱动
omsa driver download
```

### 4.5 安装驱动

#### 卸载旧驱动
```bash
# 查看当前驱动版本
modinfo megasas | grep version

# 卸载旧驱动
modprobe -r megasas

# 卸载旧驱动包
rpm -e megasas-* --nodeps
```

#### 安装新驱动
```bash
# 进入驱动目录
cd /path/to/driver

# 安装驱动
rpm -ivh megasas-07.xxx.xx-1.el7_7.noarch.rpm

# 或强制安装（如果有依赖问题）
rpm -ivh megasas-07.xxx.xx-1.el7_7.noarch.rpm --force --nodeps
```

#### 验证安装
```bash
# 检查驱动模块
lsmod | grep megasas

# 查看驱动版本
modinfo megasas | grep version

# 查看驱动信息
cat /proc/megaraid/*/adapter_info
```

### 4.6 配置RAID卡

#### 使用MegaCLI配置
```bash
# 安装MegaCLI
yum install -y MegaCli

# 查看RAID卡信息
MegaCli -AdpAllInfo -a0

# 查看虚拟磁盘
MegaCli -LdInfo -Lall -a0
```

#### 使用storcli配置
```bash
# 安装storcli（Dell推荐）
yum install -y storcli

# 查看RAID卡状态
storcli /c0 show
```

### 4.7 重启并验证

#### 重启服务器
```bash
# 同步文件系统
sync

# 重启
reboot
```

#### 重启后验证
```bash
# 检查驱动加载
lsmod | grep megasas

# 检查RAID卡识别
lspci | grep -i raid

# 查看RAID配置
cat /proc/megaraid/*/adapter_info

# 查看虚拟磁盘
lsblk
```

### 4.8 性能验证

#### 查看驱动统计
```bash
# 查看驱动I/O统计
cat /proc/megaraid/*/adapter_info | grep -i performance

# 监控I/O性能
iostat -x 1 5
```

#### 测试RAID性能
```bash
# 使用fio测试RAID性能
fio --name=raid_test \
    --filename=/dev/sda \
    --rw=randread \
    --bs=1M \
    --iodepth=32 \
    --numjobs=4 \
    --runtime=300 \
    --group_reporting
```

### 4.9 故障排查

#### 问题1: 驱动安装失败
```bash
# 检查依赖
rpm -ivh driver.rpm --test

# 查看详细错误
rpm -ivh driver.rpm 2>&1 | tail -20
```

#### 问题2: 驱动加载失败
```bash
# 查看内核日志
dmesg | grep -i megasas

# 手动加载驱动
modprobe megasas

# 查看错误信息
cat /var/log/messages | grep -i megasas
```

#### 问题3: RAID卡不识别
```bash
# 检查PCI设备
lspci -vvv -s | grep -i raid

# 检查BIOS设置
dmidecode | grep -A 10 "System Information"

# 可能需要在BIOS中启用RAID卡
```

---

## 📝 完整操作流程

### 场景1: 新服务器首次部署

```bash
# 1. 检查硬件型号
dmidecode -s system-product-name

# 2. 检查内核版本
uname -r

# 3. 如果是Dell 750，安装驱动
rpm -ivh megasas-*.rpm

# 4. 设置CPU性能模式
echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 5. 禁用NUMA
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*/& numa=off/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# 6. 重启
reboot

# 7. 验证配置
cat /proc/cmdline | grep numa
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
lsmod | grep megasas

# 8. 运行fio压测
fio --name=io_test --filename=/dev/sdb --runtime=300
```

### 场景2: 现有服务器优化

```bash
# 1. 检查当前配置
cat /proc/cmdline
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
numactl --hardware

# 2. 临时优化（无需重启）
echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 3. 运行fio压测验证性能
fio --name=io_test --filename=/dev/sdb --runtime=300

# 4. 如果性能提升明显，考虑永久优化
# 修改grub配置并重启
```

---

## 🔧 辅助脚本

### CPU优化脚本
```bash
#!/bin/bash
# CPU性能优化脚本

echo "CPU性能模式优化"
echo "=========================================="

# 设置CPU为performance模式
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo "设置 $cpu 为 performance 模式"
    echo performance > $cpu/cpufreq/scaling_governor
done

# 显示当前设置
echo ""
echo "当前CPU性能模式:"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

echo ""
echo "当前CPU频率:"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq

echo ""
echo "最大CPU频率:"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq

echo "=========================================="
echo "CPU性能模式已优化！"
```

### fio压测脚本
```bash
#!/bin/bash
# QFusion fio压测脚本

DISK=$1  # 第一个参数：设备路径
TEST_TIME=${2:-300}  # 第二个参数：测试时间（默认300秒）

if [ -z "$DISK" ]; then
    echo "用法: $0 <设备路径> [测试时间秒]"
    echo "示例: $0 /dev/sdb 600"
    exit 1
fi

echo "QFusion fio性能压测"
echo "=========================================="
echo "设备: $DISK"
echo "测试时间: ${TEST_TIME}秒"
echo "=========================================="
echo ""

# 随机读测试
echo "1. 随机读测试..."
fio --name=${DISK}_randread \
    --filename=$DISK \
    --rw=randread \
    --bs=1M \
    --iodepth=32 \
    --numjobs=4 \
    --runtime=$TEST_TIME \
    --time_based \
    --group_reporting

echo ""

# 随机写测试
echo "2. 随机写测试..."
fio --name=${DISK}_randwrite \
    --filename=$DISK \
    --rw=randwrite \
    --bs=1M \
    --iodepth=32 \
    --numjobs=4 \
    --runtime=$TEST_TIME \
    --time_based \
    --group_reporting

echo ""

# 顺序读写测试
echo "3. 顺序读写测试..."
fio --name=${DISK}_seqrw \
    --filename=$DISK \
    --rw=rw \
    --bs=1M \
    --iodepth=32 \
    --numjobs=4 \
    --runtime=$TEST_TIME \
    --time_based \
    --group_reporting

echo ""
echo "=========================================="
echo "压测完成！"
echo ""
echo "查看结果:"
echo "ls -lh ${DISK}_*.json ${DISK}_*.log"
```

---

## ⚠️ 注意事项

### 安全警告
1. **BIOS操作**: BIOS配置错误可能导致系统无法启动
2. **驱动安装**: 旧的驱动卸载后，如果新驱动安装失败可能需要进入救援模式
3. **压测测试**: fio压测会消耗大量I/O，避免在生产环境高峰期执行
4. **备份重要**: 在进行任何修改前，务必备份重要数据

### 建议操作顺序
1. **备份**: 备份重要数据和配置
2. **测试**: 在测试环境先验证
3. **非高峰**: 选择业务低峰期执行
4. **验证**: 每一步骤后验证配置
5. **监控**: 执行后持续监控系统状态

### 回滚方案
```bash
# 恢复grub配置
cp /etc/default/grub.backup.* /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# 恢复CPU性能模式
echo ondemand > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 恢复旧驱动（如果需要）
modprobe -r megasas
modprobe megasas_old_version
```

---

## 📚 参考资源

### 官方文档
- QFusion安装文档: 内部wiki
- Dell PowerEdge R750: https://www.dell.com/support/manuals
- fio官方文档: https://fio.readthedocs.io/
- NUMA优化: https://www.kernel.org/doc/html/latest/vm/numa.html

### 在线资源
- QFusion发布: http://qfusion-publish.gitlab-pages.woqutech.com/
- 沃趣科技wiki: http://wiki.woqutech.com/

---

**文档版本**: 1.0
**最后更新**: 2026-03-06
**维护者**: QFusion技术支持团队
