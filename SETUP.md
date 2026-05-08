# Cursor QIMA PM Agent Setup

本文档用于在新电脑上快速配置 PM Agent，确保 `write-prd`、`ticket-breakdown`、`prd-design-assets` 可正常运行。

## 1) 基础环境

- 安装 `git`
- 安装 `python3`（建议 3.10+）
- 安装 `pip`
- 安装并登录 `gh`（GitHub CLI）

验证：

```bash
git --version
python3 --version
gh --version
gh auth status
```

## 2) 克隆仓库

```bash
git clone <your-pm-agent-repo-url>
cd "<your-pm-agent-folder>"
```

## 3) Python 依赖（设计裁切）

`prd-design-assets` 依赖 Pillow：

```bash
python3 -m pip install -r .cursor/skills/prd-design-assets/requirements.txt
```

## 4) Cursor / MCP 准备

需要确保以下 MCP 可用并已登录：

- Atlassian（Confluence/Jira）
- Figma（读设计）

如果没有登录，先在 Cursor 内完成认证，再运行 skill。

## 5) Figma Token 配置

`write-prd/scripts/fetch-figma.sh` 默认从 `~/.config/figma-token` 读取 token。

### 方式 A（推荐）：本机文件，不进仓库

```bash
mkdir -p ~/.config
printf '%s' '<YOUR_FIGMA_TOKEN>' > ~/.config/figma-token
chmod 600 ~/.config/figma-token
```

### 方式 B：直接写在项目里（你提到的方式）

可以在项目根目录创建一个本地文件，比如 `.figma-token.local`，内容就是 token：

```bash
printf '%s' '<YOUR_FIGMA_TOKEN>' > .figma-token.local
chmod 600 .figma-token.local
```

运行前指定：

```bash
export FIGMA_TOKEN_FILE="$PWD/.figma-token.local"
```

然后再调用 `fetch-figma.sh`。

> 注意：如果采用方式 B，**不要把 token 文件提交到 git**。建议加入本地 `.git/info/exclude` 或仓库 `.gitignore`（若团队允许）。

## 6) 设计图片资产仓库

`prd-design-assets` 默认示例 URL 使用：

```text
https://raw.githubusercontent.com/lyonliqima/prd-assets/main/assets/<feature_slug>/figma/crops/<filename>.png
```

给其他同事使用时，请替换为他们自己的 asset repo（或创建新的），避免写入到你的个人仓库。

## 7) 最小自检清单

- `gh auth status` 正常
- Atlassian MCP 可读 Jira/Confluence
- Figma MCP 可读设计
- `python3 -m pip show Pillow` 有输出
- token 文件存在且权限为 `600`

## 8) 常见问题

- **报错 missing ~/.config/figma-token**  
  说明 token 文件不存在，按第 5 节配置。

- **图片导出失败（401/403）**  
  检查 token 是否有效、是否有目标 Figma 文件权限。

- **Jira/Confluence 调用失败**  
  通常是 MCP 未登录或账号权限不足。
