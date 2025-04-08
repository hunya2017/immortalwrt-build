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
          - 'aarch64'
          - 'x86_64'
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
      uses: actions/checkout@v4

    - name: Setup environment
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential git wget curl

    - name: Download ImmortalWrt source
      run: |
        git clone -b "${{ github.event.inputs.REPO_BRANCH }}" --single-branch https://github.com/immortalwrt/immortalwrt.git
        cd immortalwrt
        ./scripts/feeds update -a
        ./scripts/feeds install -a

    - name: Load custom settings
      run: |
        echo "CONFIG_FILE=${{ github.event.inputs.CONFIG_FILE }}" > .config
        # Add any additional configuration settings here

    - name: Compile ImmortalWrt
      run: |
        cd immortalwrt
        make -j$(nproc)

    - name: Upload firmware
      if: ${{ github.event.inputs.UPLOAD_FIRMWARE }}
      uses: actions/upload-artifact@v2
      with:
        name: immortalwrt-firmware
        path: path/to/firmware/files