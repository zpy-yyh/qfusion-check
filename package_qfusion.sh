#!/bin/bash

# QFusion安装前检查脚本打包工具
# 用于打包所有相关文件，方便移动到其他服务器

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_blue() {
    echo -e "${BLUE}[*]${NC} $1"
}

echo ""
echo_blue "=========================================="
echo "     QFusion脚本打包工具"
echo_blue "=========================================="
echo ""
echo_info "此脚本将打包QFusion安装前检查脚本的所有文件"
echo ""

# 设置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QFUSION_DIR="$SCRIPT_DIR/qfusion_package"
PACK_DIR="$SCRIPT_DIR/qfusion_package"
PACKAGE_FILE="qfusion_precheck_script_$(date +%Y%m%d_%H%M%S).tar.gz"
VERSION="1.0"
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)

echo_info "工作目录: $SCRIPT_DIR"
echo_info "QFusion目录: $QFUSION_DIR"
echo ""

# 检查必要文件
echo_blue "检查必要文件..."
echo ""

required_files=(
    "$QFUSION_DIR/qfusion.sh"
    "$QFUSION_DIR/install.sh"
    "$QFUSION_DIR/README.md"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    else
        echo_info "  ✓ $(basename $file)"
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo_error "以下文件缺失："
    for file in "${missing_files[@]}"; do
        echo_error "  ✗ $file"
    done
    exit 1
fi

echo ""

# 创建打包目录
echo_blue "创建打包目录..."
echo ""

TEMP_DIR="/tmp/qfusion_package_$TIMESTAMP"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/qfusion_package"
mkdir -p "$TEMP_DIR/docs"
mkdir -p "$TEMP_DIR/scripts"
mkdir -p "$TEMP_DIR/config"

echo_info "临时目录: $TEMP_DIR"
echo ""

# 复制QFusion核心文件
echo_blue "复制QFusion核心文件..."
echo ""

cp "$QFUSION_DIR/qfusion.sh" "$TEMP_DIR/qfusion_package/"
cp "$QFUSION_DIR/install.sh" "$TEMP_DIR/qfusion_package/"

# 复制README
cp "$QFUSION_DIR/README.md" "$TEMP_DIR/qfusion_package/" 2>/dev/null

echo_info "  ✓ qfusion.sh"
echo_info "  ✓ install.sh"
echo_info "  ✓ README.md"
echo ""

# 复制批量检查脚本
echo_blue "复制批量检查脚本..."
echo ""

cp "$SCRIPT_DIR/batch_check_only.sh" "$TEMP_DIR/scripts/" 2>/dev/null
cp "$SCRIPT_DIR/batch_check_only_expect.sh" "$TEMP_DIR/scripts/" 2>/dev/null
cp "$SCRIPT_DIR/setup_ssh_keys.sh" "$TEMP_DIR/scripts/" 2>/dev/null

echo_info "  ✓ batch_check_only.sh"
echo_info "  ✓ batch_check_only_expect.sh"
echo_info "  ✓ setup_ssh_keys.sh"
echo ""

# 复制配置文件
echo_blue "复制配置文件..."
echo ""

cp "$QFUSION_DIR/nodes.conf" "$TEMP_DIR/config/" 2>/dev/null
cp "$QFUSION_DIR/nodes.conf.example" "$TEMP_DIR/config/" 2>/dev/null

echo_info "  ✓ nodes.conf"
echo_info "  ✓ nodes.conf.example"
echo ""

# 复制文档
echo_blue "复制文档..."
echo ""

docs=(
    "QFusion手动操作指南.md"
    "QFusion安装前检查项-未实现项分析.md"
    "SSH认证方案说明.md"
    "依赖要求说明.md"
)

for doc in "${docs[@]}"; do
    if [ -f "$SCRIPT_DIR/$doc" ]; then
        cp "$SCRIPT_DIR/$doc" "$TEMP_DIR/docs/"
        echo_info "  ✓ $doc"
    else
        echo_warn "  ✗ $doc (不存在)"
    fi
done

# 复制其他有用文档
echo_blue "复制其他文档..."
echo ""

other_docs=(
    "安装前检查项对比.md"
    "功能测试报告.md"
    "更新后的测试报告.md"
    "功能更新总结.md"
)

for doc in "${other_docs[@]}"; do
    if [ -f "$SCRIPT_DIR/$doc" ]; then
        cp "$SCRIPT_DIR/$doc" "$TEMP_DIR/docs/"
        echo_info "  ✓ $doc"
    fi
done

# 创建部署说明
echo_blue "创建部署说明..."
echo ""

cat > "$TEMP_DIR/README.md" << 'README'
# QFusion安装前检查脚本 - 部署说明

> 版本: 1.0
> 打包时间: TIMESTAMP
> 操作系统: RedHat 7.8/7.9, 麒麟V10 SP3

## 📦 包内容

### 核心文件 (qfusion_package/)
- qfusion.sh - 主检查脚本
- install.sh - 安装脚本
- README.md - 使用说明

### 批量检查脚本 (scripts/)
- batch_check_only.sh - SSH密钥认证版本（推荐）
- batch_check_only_expect.sh - expect认证版本（简单）
- setup_ssh_keys.sh - SSH密钥配置辅助脚本

### 配置文件 (config/)
- nodes.conf - 节点配置文件（已配置）
- nodes.conf.example - 节点配置模板

### 文档 (docs/)
- QFusion手动操作指南.md - 手动操作项详细说明
- QFusion安装前检查项-未实现项分析.md - 未实现项分析
- SSH认证方案说明.md - SSH认证方案对比
- 依赖要求说明.md - 依赖和配置要求
- 其他测试报告文档

## 🚀 快速开始

### 1. 解压到目标服务器

```bash
# 上传tar包到目标服务器后
tar -xzf qfusion_precheck_script_TIMESTAMP.tar.gz

# 进入目录
cd qfusion_package
```

### 2. 安装脚本

```bash
bash install.sh
```

### 3. 配置节点列表

```bash
# 编辑节点配置文件
vim config/nodes.conf

# 或使用模板创建
cp config/nodes.conf.example config/nodes.conf
vim config/nodes.conf
```

### 4. 运行检查

#### 单节点检查（本机）
```bash
qfusion --check
```

#### 批量检查（推荐使用expect）
```bash
# 进入scripts目录
cd ../scripts

# 运行expect版本（简单，无需SSH密钥）
bash batch_check_only_expect.sh
```

#### 批量检查（使用SSH密钥）
```bash
# 进入scripts目录
cd ../scripts

# 1. 配置SSH密钥认证（推荐）
bash setup_ssh_keys.sh

# 2. 更新节点配置使用密钥
vim ../config/nodes.conf
# 改为: 10.10.156.97 rds001 master root /root/.ssh/id_rsa

# 3. 运行SSH密钥版本
bash batch_check_only.sh
```

## 📋 节点配置格式

```conf
# 格式: IP地址 主机名 角色 用户名 认证信息

# expect认证（密码）
10.10.156.97 rds001 master root password123
10.10.156.98 rds002 master root password123

# SSH密钥认证（推荐）
10.10.156.97 rds001 master root /root/.ssh/id_rsa
10.10.156.98 rds002 master root /root/.ssh/id_rsa
```

## 🔑 认证方案对比

| 方案 | 需要额外软件 | 配置难度 | 推荐度 |
|------|-------------|----------|--------|
| expect认证 | ❌ 无需 | ⭐⭐⭐⭐⭐ | 测试环境 |
| SSH密钥认证 | ❌ 无需 | ⭐⭐⭐ | 生产环境 |

## 📝 检查项说明

- 总检查项: 26项
- 自动化实现: 23项
- 手动操作指南: 3项

### 自动化检查项
- 时钟同步、网卡速率、DNS配置
- SELinux、Swap、I/O调度
- YUM源、容器软件、主机名
- 等等...

### 手动操作项（详见文档）
- fio压测 - 存储性能测试
- CPU性能模式 - BIOS配置
- NUMA配置 - 内核参数配置
- Dell 750驱动 - 特定型号驱动

## ⚠️ 重要提醒

1. **expect不是必须的** - 可以使用SSH密钥认证
2. **手动操作需谨慎** - BIOS操作有风险，务必备份
3. **生产环境建议** - 使用SSH密钥认证更安全
4. **检查前备份数据** - 虽然是只读模式，但建议备份

## 📞 获取帮助

如有问题请参考：
- 使用说明: qfusion --help
- 手动操作: docs/QFusion手动操作指南.md
- 依赖说明: docs/依赖要求说明.md

## 📊 集群支持

脚本支持：
- 单节点检查
- 批量节点检查
- 远程初始化
- 3master+3node集群

## 🎯 使用场景

1. **开发测试环境** - 使用expect认证，快速方便
2. **生产环境** - 使用SSH密钥认证，更安全
3. **客户现场** - 根据网络情况选择合适方案

---

**打包时间**: TIMESTAMP
**版本**: 1.0
README

echo_info "部署说明已创建"
echo ""

# 创建版本信息文件
cat > "$TEMP_DIR/VERSION" << VERSION
QFusion Pre-check Script
=======================
Version: $VERSION
Package Date: $TIMESTAMP
Package Type: Full Package

Contents:
- Core Scripts: qfusion.sh, install.sh
- Batch Scripts: batch_check_only.sh, batch_check_only_expect.sh
- Config Files: nodes.conf, nodes.conf.example
- Documentation: README.md, manual operation guides

Target OS:
- RedHat 7.8/7.9
- Kylin V10 SP3

Check Items:
- Total: 26
- Automated: 23
- Manual: 3

Usage:
1. Extract to target server
2. Run: bash install.sh
3. Configure: Edit config/nodes.conf
4. Execute: Run batch check scripts

For more information, see README.md
VERSION

echo_info "版本信息已创建"
echo ""

# 打包
echo_blue "创建tar包..."
echo ""

cd /tmp
tar -czf "$SCRIPT_DIR/$PACKAGE_FILE" "qfusion_package_$TIMESTAMP/"

if [ $? -eq 0 ]; then
    PACKAGE_SIZE=$(du -h "$SCRIPT_DIR/$PACKAGE_FILE" | cut -f1)
    
    echo ""
    echo_blue "=========================================="
    echo "        打包完成"
    echo_blue "=========================================="
    echo ""
    echo_info "包文件: $SCRIPT_DIR/$PACKAGE_FILE"
    echo_info "包大小: $PACKAGE_SIZE"
    echo ""
    
    echo_info "包含的文件:"
    echo "----------------------------------------"
    tar -tzf "$SCRIPT_DIR/$PACKAGE_FILE" | head -30
    echo ""
    
    echo_info "文件统计:"
    echo "----------------------------------------"
    echo "  核心文件: 3个"
    echo "  批量脚本: 3个"
    echo "  配置文件: 2个"
    echo "  文档文件: 5+个"
    echo ""
    
    echo_info "下一步操作:"
    echo "----------------------------------------"
    echo "  1. 上传tar包到目标服务器"
    echo "     scp $SCRIPT_DIR/$PACKAGE_FILE user@server:/tmp/"
    echo ""
    echo "  2. 在目标服务器解压"
    echo "     ssh user@server 'cd /tmp && tar -xzf $PACKAGE_FILE'"
    echo ""
    echo "  3. 进入目录并安装"
    echo "     ssh user@server 'cd /tmp/qfusion_package_$TIMESTAMP/qfusion_package && bash install.sh'"
    echo ""
    echo "  4. 配置节点列表"
    echo "     ssh user@server 'vim /tmp/qfusion_package_$TIMESTAMP/config/nodes.conf'"
    echo ""
    echo "  5. 运行检查"
    echo "     ssh user@server 'cd /tmp/qfusion_package_$TIMESTAMP/scripts && bash batch_check_only_expect.sh'"
    echo ""
    
    echo_warn "注意: 节点配置(nodes.conf)包含明文密码，"
    echo_warn "      检查完成后建议删除或清空密码！"
    echo ""
    
    echo_blue "=========================================="
    echo "        打包完成"
    echo_blue "=========================================="
else
    echo_error "打包失败！"
    exit 1
fi

# 清理临时目录（可选）
read -p "是否删除临时目录 $TEMP_DIR? (yes/no): " cleanup

if [ "$cleanup" = "yes" ]; then
    rm -rf "$TEMP_DIR"
    echo_info "临时目录已删除"
else
    echo_info "临时目录保留在: $TEMP_DIR"
    echo_info "可以手动删除: rm -rf $TEMP_DIR"
fi

echo ""
echo_info "打包工具执行完成！"
