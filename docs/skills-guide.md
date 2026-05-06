# Skills Guide

QIMA PM Agent for Cursor 当前包含 6 个 skill。

## 1. write-prd

用于从分散材料起草 Confluence PRD。

适合：

- 从一个 feature idea 开始写正式 PRD
- 需要整合 Figma、Confluence、会议纪要、本地文件、Jira 背景
- 需要 PRD review loop

示例：

```text
Use write-prd to draft a PRD for Supplier Confirmation.
```

输出：

- Confluence PRD draft
- source ledger
- open questions
- review-loop findings or fixes

## 2. codebase-understanding

用于梳理一个 feature 在系统里的位置。

适合：

- 写 PRD 前想知道涉及哪些 repo / service / team
- 找相关 Tech Design、PRD、Jira epic
- 功能跨多个系统

示例：

```text
Use codebase-understanding to map the repos and teams for Interactive Report.
```

输出：

- codebase brief
- repo / service / API / team 表
- 相关 Confluence / Jira 链接

## 3. prd-critique

用于评审已有 PRD。

适合：

- 检查 PRD 是否 ready for PM review
- 检查 QIMA 模板、格式、voice/register
- 找 High / Medium / Low 问题

示例：

```text
Use prd-critique to review this Confluence PRD.
```

输出：

- High / Medium / Low findings
- missing sections
- voice and format check
- ready verdict

## 4. ticket-breakdown

用于把已确认 PRD 拆成 Jira Epic 和 tickets。

适合：

- PRD 已 review 完，需要进入开发排期
- 需要 Epic + FE / BE / API / QA tickets
- 需要把 Jira 链接回写 PRD

示例：

```text
Use ticket-breakdown on this PRD, project key SP, dry run first.
```

重要安全规则：

- 必须先展示创建计划
- 用户明确确认后才能写 Jira
- 初始请求不算确认

## 5. ui

统一 UI 工作入口。

适合：

- UI 规划、实现、评审、审计
- polish、layout、responsive、typography、animation
- harden empty/error/loading states

示例：

```text
Use ui to critique this page design.
Use ui to make this component responsive.
```

## 6. design-critique

用于证据型设计评审。

适合：

- Figma 设计需要业务规则验证
- 需要对照 PRD、代码实现、Jira 历史
- 需要输出带证据链接的设计评审报告

示例：

```text
Use design-critique with this Figma URL, PRD page, and repo path.
```

输出：

- HTML critique report
- severity-grouped findings
- Figma / PRD / code / Jira evidence
- recommendations
