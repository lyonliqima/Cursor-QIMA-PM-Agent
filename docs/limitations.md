# Limitations

这份 Cursor 分发版可以让团队共享 PM Agent 的工作流，但它不是完整后端服务，也不自带权限。

## 1. Cursor 只能读取项目配置

Cursor 会读取：

- `AGENTS.md`
- `.cursor/rules/*.mdc`
- `.cursor/skills/*/SKILL.md`

Cursor 不会因为 `docs/` 里的说明自动触发 skill。

## 2. Skill 不等于工具权限

Skill 只是告诉 Agent 怎么做。实际执行还取决于每个成员的 Cursor 环境是否有：

- Jira / Confluence 工具
- Figma 工具
- repo 访问权限
- Teams / Outlook / SharePoint / Notion 工具

如果缺少工具，Agent 应该说明缺口并给出 fallback，而不是假装已经检查过。

## 3. Jira / Confluence 写入需要确认

任何写操作都必须先展示计划并等待明确确认：

- 创建 Epic
- 创建 tickets
- link issues
- 更新 PRD 页面
- 写入 Confluence draft

用户最开始说“帮我创建 ticket”不算最终确认。

## 4. 中文触发可能较弱

当前 6 个 skill 内容已整理成英文，利于标准化和团队分发。

如果中文自然语言触发不稳定，建议用户明确点名 skill：

```text
Use write-prd ...
Use prd-critique ...
Use ticket-breakdown ...
```

## 5. 不是 Claude plugin

这个目录没有：

- `.claude-plugin/`
- `marketplace.json`
- Claude slash command 文件

这是 Cursor 专用结构。不要用 Claude plugin marketplace 的方式安装。

## 6. 内部信息安全

建议把这个 repo 设为 private。原因：

- skill 里包含 QIMA 内部流程
- 可能引用内部系统、团队、PRD/Jira 习惯
- 团队规则和工作流不适合公开发布

## 7. 更新方式

建议维护一个中心 private repo。

更新流程：

1. 修改 `.cursor/skills` 或 `.cursor/rules`
2. 提 PR
3. Review 后 merge
4. 团队 pull 最新版本

避免每个人本地单独改，导致 skill 行为不一致。
