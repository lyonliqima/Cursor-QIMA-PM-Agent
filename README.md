# Cursor QIMA PM Agent

这是给团队在 Cursor 里使用的 QIMA PM Agent 专用分发版本。

它不是 Claude Code marketplace plugin，而是 Cursor 项目级 instructions + skills 包。

## 目录结构

```text
Cursor QIMA PM Agent/
├── AGENTS.md
├── .cursor-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── docs/
│   ├── README.md
│   ├── setup-guide.md
│   ├── skills-guide.md
│   └── limitations.md
├── .cursor/
│   ├── rules/
│   │   ├── qima-pm-agent.mdc
│   │   ├── atlassian-safety.mdc
│   │   └── design-evidence.mdc
│   └── skills/
│       ├── write-prd/
│       ├── codebase-understanding/
│       ├── prd-critique/
│       ├── ticket-breakdown/
│       ├── ui/
│       └── design-critique/
└── README.md
```

## 为什么有隐藏目录和 docs

- `.cursor/` 是给 Cursor 读取的隐藏目录，包含自动生效的 rules 和 skills。
- `.cursor-plugin/` 是给 Cursor Plugin / Team Marketplace 读取的 manifest 元数据。
- `docs/` 是给团队成员看的可见文档，方便在 Finder / GitHub 里浏览。

如果 Finder 看不到 `.cursor/`，按 `Cmd + Shift + .` 显示隐藏文件。

## 六个 Skills

- `write-prd`: 从分散上下文起草 Confluence PRD。
- `codebase-understanding`: 梳理 feature 涉及的 repo、service、API、团队和文档。
- `prd-critique`: 评审 PRD 是否满足 QIMA 模板、语气、完整性和可交付标准。
- `ticket-breakdown`: 在用户确认后，把 PRD 拆成 Jira Epic 和开发 tickets。
- `ui`: 统一处理 UI 规划、实现、评审、审计、打磨、响应式、性能和文案。
- `design-critique`: 基于 Figma、PRD、代码和 Jira 历史做证据型设计评审。

## 团队使用方式

1. 先读 `docs/setup-guide.md`。
2. 把这个文件夹作为一个 Cursor workspace 打开，或把 `.cursor/`、`AGENTS.md`、`docs/` 复制进团队项目仓库。
3. 在 Cursor Agent 里直接描述任务，例如：
   - `Use write-prd to draft a PRD for Supplier Confirmation.`
   - `Run prd-critique on this Confluence PRD.`
   - `Use ticket-breakdown to create a Jira plan from this PRD, dry run first.`
   - `Run design-critique with this Figma URL and PRD page.`
4. 如果 Cursor 没有自动触发 skill，可以明确点名 skill 名称。

## Team Marketplace 分发

这个 repo 已包含 Cursor plugin metadata：

```text
.cursor-plugin/plugin.json
.cursor-plugin/marketplace.json
```

如果团队有 Cursor Team Marketplace 权限，建议把这个 repo 设为 private，然后由团队管理员在 Cursor Dashboard 里导入这个 GitHub repo。团队成员之后可以从 Team Marketplace 安装，或由管理员设为 required。

## 必要依赖

这些 skill 是工作流说明，不自带权限或 MCP 连接。团队成员需要自己在 Cursor 环境中配置：

- Jira / Confluence / Atlassian 权限。
- Figma 权限。
- 需要代码证据时的本地 repo 访问权限。
- 如果要扫 Outlook / Teams / SharePoint / Notion，需要对应 MCP 或工具接入。

如果缺少工具，Agent 应该说明无法验证的范围，并给出 fallback。

## 重要限制

- 普通 `agent.md` 不会被 Cursor 稳定自动识别；这里使用 `AGENTS.md`。
- `.cursor/skills` 是 Cursor 项目级 skills，更适合团队随仓库分发。
- `.cursor/rules` 是团队长期规则，会持续影响 Agent 行为。
- 创建 Jira、更新 Confluence、修改 Figma 前必须先展示计划并等待明确确认。

## 建议分发方式

如果给整个团队使用，建议把这个仓库设为 private，并把 `.cursor/`、`AGENTS.md`、`README.md` 作为团队标准模板维护。每次更新 skill 后，通过 PR review 合入，避免不同成员本地版本漂移。
