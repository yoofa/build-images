FROM ubuntu:22.04

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV TEMP=/tmp

# 1. 设置临时目录权限与基础工具安装
RUN chmod a+rwx /tmp && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        file \
        locales \
        lsb-release \
        python2 \
        python-dbus-dev \
        python-setuptools \
        python3-pip \
        sudo \
        wget \
        lsof \
        libfuse2 \
        software-properties-common \
        ninja-build && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 30 && \
    echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >>/etc/sudoers.d/env_keep

# 2. 拷贝并配置 Chromium 依赖安装脚本，随后运行安装
ADD tools/install-build-deps.sh /setup/
ADD tools/install-build-deps.py /setup/
RUN sed -i 's/packages.append("snapcraft")/print("skipping snapcraft")/g' /setup/install-build-deps.py && \
    chmod +x /setup/install-build-deps.sh /setup/install-build-deps.py && \
    bash /setup/install-build-deps.sh --syms --no-prompt --no-chromeos-fonts --no-nacl


# 3. 安装 depot_tools 并设置环境变量
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /opt/depot_tools
ENV PATH=/opt/depot_tools:$PATH

# 4. install chromium build tools
ADD tools/chromium_tools.py /opt/depot_tools/fetch_configs/
RUN mkdir -p /opt/chromium_build_tools && \
    cd /opt/chromium_build_tools && \
    fetch chromium_tools && \
    gclient sync

ENV CHROMIUM_BUILDTOOLS_PATH=/opt/chromium_build_tools/buildtools

# 4. 清理 apt 缓存
RUN rm -rf /var/lib/apt/lists/* /setup
