# Setup Guide

这份文档说明团队成员如何在 Cursor 里使用 QIMA PM Agent。

## 推荐使用方式

把以下文件复制到团队项目仓库根目录：

```text
AGENTS.md
.cursor/
docs/
README.md
```

Cursor 会自动识别：

- `AGENTS.md`
- `.cursor/rules/*.mdc`
- `.cursor/skills/*/SKILL.md`

普通 `docs/` 不会自动触发 Agent，它只是给团队成员看的说明文档。

## 打开隐藏目录

Finder 默认看不到 `.cursor/`。需要查看时按：

```text
Cmd + Shift + .
```

也可以在终端查看：

```bash
ls -la
```

## 必要权限

这些 skill 是 Cursor instructions，不自带账号权限。每个成员需要自己具备：

- Jira / Confluence / Atlassian 权限
- Figma 权限
- 相关代码仓库访问权限
- 如果要扫描 Outlook / Teams / SharePoint / Notion，需要对应工具或 MCP 接入

## 建议团队流程

1. 把这个仓库作为 private repo 维护。
2. 通过 PR 更新 `.cursor/skills` 和 `.cursor/rules`。
3. 更新后团队成员 pull 最新版本。
4. 使用时明确点名 skill，例如：

```text
Use write-prd to draft a PRD for Supplier Confirmation.
Use prd-critique to review this PRD.
Use ticket-breakdown, dry run first.
```

## 验证安装

在 Cursor Agent 里问：

```text
What QIMA PM Agent skills are available in this workspace?
```

理想回答应包含：

- `write-prd`
- `codebase-understanding`
- `prd-critique`
- `ticket-breakdown`
- `ui`
- `design-critique`
