# Team Docs

这个目录是给团队成员看的说明文档。

Cursor 真正自动读取的是隐藏目录：

```text
.cursor/
├── rules/
└── skills/
```

因为 `.cursor/` 在 Finder 里默认隐藏，所以这里放一份可见文档，方便团队理解怎么安装、怎么使用、有哪些限制。

## 文档列表

- [Setup Guide](setup-guide.md): 团队如何安装和启用这套 Cursor PM Agent。
- [Skills Guide](skills-guide.md): 6 个 skill 分别做什么、什么时候用、怎么问。
- [Limitations](limitations.md): 当前限制、依赖、权限和常见问题。

## 一句话说明

- `.cursor/skills/`：给 Cursor Agent 自动发现和调用。
- `.cursor/rules/`：给 Cursor Agent 持久加载团队规则。
- `AGENTS.md`：给 Cursor 读取的总入口说明。
- `docs/`：给团队成员阅读，不负责自动触发。
