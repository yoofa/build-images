# AVE CI & Build Images

本仓库包含用于 AVE 项目的 Docker 镜像构建配置以及可复用的 GitHub Actions 自动化工作流。

---

## 🛠 Docker 开发与镜像构建

仓库中提供了准备好的 Dockerfile 和 Docker Compose 配置文件，包含预装好的 `depot_tools` 以及 Chromium 依赖工具链。

### 1. 本地构建与验证

可以通过 Docker Compose 快速构建镜像并启动测试容器：

```bash
# 1. 构建 Docker 镜像
docker compose build

# 2. 启动容器并进入交互式 Bash 终端
docker compose run --rm build-test bash
```

### 2. 目录挂载配置

默认的 [`docker-compose.yml`](file:///home/youfa/work/github.com/yoofa/act_test/build-images/docker-compose.yml) 已配置将项目根目录映射至容器内 `/work/base`：

```yaml
services:
  build-test:
    build:
      context: .
      dockerfile: Dockerfile
    image: build-images:test
    container_name: build-images-test-container
    stdin_open: true
    tty: true
    volumes:
      - /home/youfa/work/github.com/yoofa/act_test/base:/work/base
```

---

## 🚀 组合 Actions (`actions/`)

仓库提供可在各业务代码库中引用的 GitHub Composite Actions。

### 1. 格式检查 Action (`actions/format-check`)

基于 `git cl format` 的通用代码格式检查 Action。支持 C++、Java、JS/TS 以及 `BUILD.gn` 文件的格式自动校验。

#### 核心特性：
- **通用性**：支持 Pull Request、Push 提交以及本地 `act` 调试，无固定硬编码分支。
- **多 Commit 支持**：在一次 Push 多笔 Patch 时，能精确与推送前的起点 Commit 进行对比检查。
- **清晰排错**：失败时清晰打印需格式化的文件列表以及完整的代码格式 `git diff`。

#### 使用示例

在业务仓库的 `.github/workflows/format-check.yml` 中添加以下配置：

```yaml
name: Format Check

on:
  push:
    branches: [ master, main, dev ]
  pull_request:
    branches: [ master, main, dev ]
  workflow_dispatch:

jobs:
  check-format:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/yoofa/ave-ci:latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run Format Check
        uses: yoofa/build-images/actions/format-check@main
        with:
          base_ref: ${{ github.base_ref }}
          event_before: ${{ github.event.before }}
```

---

## ⚙️ 自动化构建工作流

在修改 [`Dockerfile`](file:///home/youfa/work/github.com/yoofa/act_test/build-images/Dockerfile) 或 [`tools/`](file:///home/youfa/work/github.com/yoofa/act_test/build-images/tools) 中的构建脚本并推送到 `master` 分支时，GitHub Actions 会自动构建并发布新的 CI 镜像至 GHCR (`ghcr.io/yoofa/ave-ci:latest`)。修改 `actions/` 目录下的 GitHub Actions 规则时不会触发 Docker 镜像的重复构建。
