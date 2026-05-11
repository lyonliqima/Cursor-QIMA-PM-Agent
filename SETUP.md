# Cursor QIMA PM Agent Setup

This guide helps a teammate set up the QIMA PM Agent on a new machine so the main workflows can run in Cursor:

- `write-prd`
- `prd-critique`
- `ticket-breakdown`
- `codebase-understanding`
- `prd-design-assets` as an internal helper for Figma screenshots and cropped design references

The repository contains Cursor rules, project skills, helper scripts, and setup documentation. It does not include user credentials, MCP authentication, Jira/Confluence permissions, Figma permissions, or GitHub write access.

## 1. System Requirements

Install and verify:

```bash
git --version
python3 --version
python3 -m pip --version
gh --version
gh auth status
```

Required tools:

- `git`
- `python3` 3.10 or newer recommended
- `pip`
- GitHub CLI `gh`, logged in with access to the asset repository when image upload is needed
- Cursor Desktop with the required MCP integrations enabled

## 2. Clone the PM Agent Repository

```bash
git clone <your-pm-agent-repo-url>
cd "<your-pm-agent-folder>"
```

For the shared QIMA PM Agent repository, replace `<your-pm-agent-repo-url>` with the team GitHub URL.

## 3. Choose How Cursor Will Load the Skills

Use one of the options below.

### Option A: Open this repository directly in Cursor

Open the cloned folder as the Cursor workspace.

Cursor should detect:

- `AGENTS.md`
- `.cursor/rules/*.mdc`
- `.cursor/skills/*/SKILL.md`

This is the simplest way to test the PM Agent as distributed.

### Option B: Copy the PM Agent into another project

Copy these files and folders to the target project root:

```text
AGENTS.md
.cursor/
.cursor-plugin/
docs/
README.md
SETUP.md
```

Then open that target project in Cursor.

### Option C: Install the skills as personal Cursor skills

Use this when the teammate wants these skills available across many workspaces:

```bash
mkdir -p "$HOME/.cursor/skills"
rsync -a .cursor/skills/ "$HOME/.cursor/skills/"
```

This installs the skills under `~/.cursor/skills`. Project-level rules from `.cursor/rules` and `AGENTS.md` do not automatically follow this personal-skill installation, so Option A or B is preferred for the full team behavior.

### Option D: Cursor Team Marketplace

If the team has Cursor Team Marketplace / plugin distribution enabled, an admin can import this repository using:

```text
.cursor-plugin/plugin.json
.cursor-plugin/marketplace.json
```

Teammates can then install the PM Agent from the team marketplace, or the admin can set it as required.

## 4. Install Python Dependencies

`prd-design-assets` uses Pillow for image cropping.

From the repository root:

```bash
python3 -m pip install -r .cursor/skills/prd-design-assets/requirements.txt
python3 -m pip show Pillow
```

Expected: `python3 -m pip show Pillow` prints package details.

## 5. Configure Cursor MCP Access

Each teammate must authenticate the MCP integrations they need. The skills cannot bypass missing account access.

Required for PRD and ticket workflows:

- Atlassian MCP: Confluence and Jira read/write access
- Figma MCP: design read access

Often needed depending on the task:

- Browser MCP for web interaction or visual checks
- GitHub CLI for asset repository updates
- Local source-code repositories for `codebase-understanding` and evidence-based PRD critique
- Outlook, Teams, SharePoint, OneDrive, or Notion MCP/tools if those sources are part of the PRD inputs

If a tool is not available, the agent should state what cannot be verified and continue with a limited, source-aware plan.

## 6. Configure the Figma REST API Token

The helper script `.cursor/skills/write-prd/scripts/fetch-figma.sh` reads the token from:

```text
${FIGMA_TOKEN_FILE:-$HOME/.config/figma-token}
```

### Recommended: local user token file

```bash
mkdir -p "$HOME/.config"
printf '%s' '<YOUR_FIGMA_TOKEN>' > "$HOME/.config/figma-token"
chmod 600 "$HOME/.config/figma-token"
```

### Project-local token file

This is useful when the team intentionally shares one Figma token or wants a project-local setup.

From the repository root:

```bash
printf '%s' '<YOUR_FIGMA_TOKEN>' > .figma-token.local
chmod 600 .figma-token.local
export FIGMA_TOKEN_FILE="$PWD/.figma-token.local"
```

`.figma-token.local` is ignored by git in this repository. Do not commit real tokens.

### Token permissions

The token must have access to the target Figma file. If Figma export returns `401` or `403`, check:

- the token is valid;
- the user or shared token has access to the file;
- the file key and node ID were copied from the correct Figma URL.

## 7. Configure the Design Asset Repository

The `prd-design-assets` workflow publishes cropped screenshots to a stable raw GitHub URL, for example:

```text
https://raw.githubusercontent.com/lyonliqima/prd-assets/main/assets/<feature_slug>/figma/crops/<filename>.png
```

Before teammates use this workflow, decide which asset repository they should use:

- a shared team repository, such as `prd-assets`;
- an individual repository owned by the PM;
- another public or internally accessible static-asset host.

Minimum requirements:

- The repository must be reachable by Confluence and Jira image renderers.
- The teammate must have `git push` access.
- The repository should not store secrets, token files, or temporary API responses.
- Images should be kept well below GitHub's 100 MB per-file limit.

Verify GitHub access:

```bash
gh auth status
git ls-remote <asset-repo-git-url>
```

## 8. Verify the Figma Export and Crop Scripts

The Figma export script:

```bash
bash .cursor/skills/write-prd/scripts/fetch-figma.sh <FILE_KEY> <OUT_DIR> "<NODE_IDS>" 2
```

Example argument shape:

```bash
bash .cursor/skills/write-prd/scripts/fetch-figma.sh rISHYzh2BlJbfbXrOaSwB2 /tmp/figma-export "10380:17767" 2
```

The crop script:

```bash
python3 .cursor/skills/prd-design-assets/scripts/crop-figma-regions.py \
  --image <exported-full-image.png> \
  --plan <crop-plan.json> \
  --out-dir <asset-repo>/assets/<feature_slug>/figma/crops \
  --scale 2
```

The `--scale` value must match the export scale. If `fetch-figma.sh` uses scale `2`, use `--scale 2` for crop coordinates based on Figma frame pixels.

## 9. Minimal Smoke Test in Cursor

Open Cursor and ask:

```text
What QIMA PM Agent skills are available in this workspace?
```

Expected skills include:

- `write-prd`
- `prd-critique`
- `ticket-breakdown`
- `codebase-understanding`
- `prd-design-assets` as an internal helper, not a user-facing workflow
- `mermaid-chart`
- `ui`
- `design-critique`

Then test the integrations with read-only prompts:

```text
Use write-prd planning mode only. Do not create or update Confluence. Tell me what inputs are required for a PRD.
```

```text
Use prd-critique read-only on a sample local markdown PRD and report only the findings.
```

For Jira/Confluence/Figma workflows, run a real end-to-end task only after the agent shows the plan and the user explicitly approves write actions.

## 10. Expected Readiness Checklist

A teammate can use the PM Agent directly when all items below are true:

- Cursor opens the repository or the skills have been copied to `~/.cursor/skills`.
- `write-prd`, `prd-critique`, and `ticket-breakdown` appear in Cursor's available skills.
- `python3 -m pip show Pillow` works.
- Figma token file exists and is readable.
- Atlassian MCP can read Confluence and Jira.
- Figma MCP can read the target design.
- `gh auth status` works if the teammate needs to publish cropped design assets.
- The chosen asset repository is configured and writable.
- The teammate has access to any local code repositories needed for codebase research.

## 11. Troubleshooting

### `missing ~/.config/figma-token`

Create the token file using Section 6, or export `FIGMA_TOKEN_FILE` to a project-local token file.

### Figma export fails with `401` or `403`

The token is missing, expired, invalid, or does not have access to the file. Confirm both the token and Figma file permissions.

### Jira or Confluence calls fail

The Atlassian MCP is probably not authenticated, or the account does not have permission for that space, page, project, or issue.

### Skills do not appear in Cursor

Check the installation mode:

- If using project skills, open the repository root in Cursor.
- If using personal skills, confirm files exist under `~/.cursor/skills/<skill-name>/SKILL.md`.
- Restart Cursor if the skill list does not refresh.

### Cropped images do not render in Confluence or Jira

Check that the raw GitHub URL is public or reachable to the viewer, and that the file was pushed to the asset repository.

## 12. Final Notes

The PM Agent is ready for teammates when the setup above passes. The remaining limitations are permission-related, not repository-related: each teammate still needs the right Atlassian, Figma, GitHub, and source-code access for the workflow they ask the agent to perform.
