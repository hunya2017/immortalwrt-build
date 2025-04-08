### 1. `compile-immortalwrt.yml`

```yaml
name: Compile ImmortalWrt

on:
  workflow_dispatch:
    inputs:
      REPO_BRANCH:
        description: '选择分支'
        required: true
        default: 'openwrt-23.05'
        type: choice
        options:
          - 'master'
          - 'openwrt-23.05'
      CONFIG_FILE:
        description: '选择配置文件'
        required: true
        default: 'x86_64'
        type: choice
        options:
          - 'x86_64'
          - 'aarch64'
      UPLOAD_FIRMWARE:
        description: '上传固件到 GitHub Artifacts'
        required: false
        default: 'true'
        type: boolean

env:
  GITHUB_LINK: https://github.com/${{ github.repository }}
  REPO_TOKEN: ${{ secrets.REPO_TOKEN }}
  TZ: Asia/Shanghai

jobs:
  build:
    runs-on: ubuntu-22.04

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up environment
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential git wget curl

    - name: Download ImmortalWrt source code
      run: |
        git clone -b ${{ github.event.inputs.REPO_BRANCH }} --single-branch https://github.com/immortalwrt/immortalwrt.git
        cd immortalwrt
        ./scripts/feeds update -a
        ./scripts/feeds install -a

    - name: Load custom settings
      run: |
        echo "CONFIG_TARGET_x86_64=y" >> .config
        echo "CONFIG_PACKAGE_luci=y" >> .config
        echo "CONFIG_PACKAGE_luci-app-<your-package>=y" >> .config  # Replace <your-package> with the actual package name
        make defconfig

    - name: Compile ImmortalWrt
      run: |
        cd immortalwrt
        make -j$(nproc)

    - name: Upload firmware
      if: ${{ github.event.inputs.UPLOAD_FIRMWARE }}
      uses: actions/upload-artifact@v2
      with:
        name: immortalwrt-firmware
        path: immortalwrt/bin/targets/x86/64/*.bin  # Adjust the path as necessary
```

### 2. `diy-part.sh`

在 `diy-part.sh` 中，您可以根据需要添加自定义设置。以下是一个简单的示例：

```bash
#!/bin/bash

# 设置后台IP地址
export Ipv4_ipaddr="192.168.10.1"
export Netmask_netm="255.255.255.0"
export Op_name="ImmortalWrt"

# 默认主题设置
export Mandatory_theme="argon"
export Default_theme="argon"

# 其他自定义设置
export Password_free_login="1"  # 设置免密码登录
```

### 3. 使用说明

1. 将 `compile-immortalwrt.yml` 文件放置在 `.github/workflows/` 目录下。
2. 将 `diy-part.sh` 文件放置在您的项目根目录或适当的位置。
3. 在 GitHub 上，您可以手动触发此工作流，并选择所需的分支和配置文件。
4. 确保您在 GitHub Secrets 中设置了 `REPO_TOKEN`。

### 注意事项

- 根据您的需求，您可能需要调整 `diy-part.sh` 中的设置。
- 确保您在 `compile-immortalwrt.yml` 中的路径和包名称是正确的。
- 该脚本假设您已经具备编译 ImmortalWrt 的基本知识和环境配置。