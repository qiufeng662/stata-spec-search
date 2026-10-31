# 安装指南（跨 agent）

一个 skill，分发到所有兼容 Agent Skills 的 agent。格式是 Anthropic 标准的
`SKILL.md`（frontmatter `name` + `description` + Markdown 正文），绝大多数 agent 都认。

## 通用方法

把本仓库放到目标 agent 的 skills 目录即可。目录名 = skill 名，须与 frontmatter 的 `name` 一致。

## 各 agent 的安装位置

| Agent | 个人级 skills 目录 | 项目级 skills 目录 |
|---|---|---|
| **Claude Code** | `~/.claude/skills/` | `.claude/skills/` |
| **Codex CLI** | `~/.codex/skills/` | `.codex/skills/` |
| **opencode** | `~/.config/opencode/skills/` | 项目内 `opencode.json` 指定 |
| **Gemini CLI** | `~/.gemini/skills/` | `.gemini/skills/` |
| **DSH** | `~/.dsh/skills/` | — |
| **zcode / 其他** | 各自 skills 目录，通常也遵循 SKILL.md 格式 | 项目级同左 |

`~` 是用户主目录（Windows 为 `C:\Users\<用户名>`）。

## 安装命令

### macOS / Linux（bash）

```bash
# Claude Code
git clone https://github.com/qiufeng662/stata-spec-search ~/.claude/skills/stata-spec-search

# Codex CLI
git clone https://github.com/qiufeng662/stata-spec-search ~/.codex/skills/stata-spec-search

# opencode
git clone https://github.com/qiufeng662/stata-spec-search ~/.config/opencode/skills/stata-spec-search
```

### Windows（PowerShell）

```powershell
$dst = "$env:USERPROFILE\.claude\skills\stata-spec-search"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Copy-Item "SKILL.md" $dst
```

## 验证

装好后问一句触发语，例如：

> 帮我做一下这个面板回归的规格搜索 / 稳健性边界分析

agent 应自动加载本 skill 并开始探测本机 STATA。若没触发，检查：

1. `SKILL.md` 的 frontmatter（`name` / `description`）是否完整、无 YAML 语法错误；
2. 目录名与 `name` 是否一致；
3. agent 版本是否支持 Agent Skills（较老版本可能只认 AGENTS.md 而非 skills 目录）。

## 依赖

- 本机已安装 STATA（任意版本，SE / MP / BE 均可），在常见路径或注册表可探测。
- `reghdfe` + `ftools`（skill 会在缺失时自动 `ssc install`）。
- 数据为 `.dta`，面板结构（个体 × 时间）。

## 触发词参考

- "规格搜索" / "specification search" / "极端边界分析" / "EBA"
- "哪种设定下结果显著" / "排查设定敏感性" / "模型选择"
- "结论对控制变量 / 固定效应 / 标准误稳不稳健"
