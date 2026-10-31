# stata-spec-search

> 让 AI 编程代理帮你做 STATA 实证的**规格搜索（Specification Search）**与**极端边界分析（Extreme Bounds Analysis, EBA）**。

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 它解决什么

实证回归的结论对分析设定高度敏感：换一个因变量口径、换一个核心变量代理、
加减一个控制变量、换一套固定效应或标准误层级，p 值就可能翻个跟头。

- **结果不显著**时，想知道"换个合理设定能不能出来"，但手工试几十上百个组合很痛苦；
- **审稿人质疑**"结论是不是挑出来的"，需要系统遍历设定来回应；
- 与其一个个手试，不如让 agent 自动遍历全部组合、调用本机 STATA 真实跑回归、把结果摆出来。

## 它是什么

一个 **Agent Skill**（兼容 Claude Code / Codex CLI / opencode / Gemini CLI / DSH / zcode 等），
加载后 agent 会自动：

1. 探测本机 STATA（Windows / macOS / Linux）
2. 缺失时自动安装 `reghdfe` / `ftools`
3. 按规格空间枚举所有设定组合
4. 调用 STATA 批处理真实回归，收集每个规格的 β / SE / p / N / 聚类数
5. 标出达到统计显著性且方向与假设一致的规格，按 p 排序输出
6. 出错了自己排查（`r(111)` / `r(198)` / `r(2000)` …），修复后重跑

## 快速开始

### 1. 安装 skill

把本仓库放入对应 agent 的 skills 目录（各 agent 具体路径见 [INSTALL.md](INSTALL.md)）：

```bash
# Claude Code 示例
git clone https://github.com/qiufeng662/stata-spec-search ~/.claude/skills/stata-spec-search

# 或只复制 SKILL.md
mkdir -p ~/.claude/skills/stata-spec-search
cp SKILL.md ~/.claude/skills/stata-spec-search/
```

### 2. 触发

> 帮我做一下这个面板回归的规格搜索，数据在 `mydata.dta`，核心变量是 dig，假设方向为正。

agent 会加载 skill，探测 STATA，然后自动跑完整个搜索。

## 规格空间（六个自由度，样本固定不动）

| 维度 | 覆盖 |
|---|---|
| 因变量 | 多口径（roa / 托宾Q / 收益率）+ 变换（对数/增长率/差分/标准化）+ 缩尾（1%/2%/5%）+ 虚拟化 |
| 核心解释变量 | 多代理 + 滞后（0/1/2 期）+ 变换 + 高-低组虚拟化 |
| 控制变量 | 多套组合 + 高阶项（平方项 / 交互项） |
| 固定效应 | 无 / `firm` / `year` / `firm year` / `ind year` |
| 标准误 | OLS / robust / cluster(firm) / cluster2(firm, year) |
| 推断选择 | 单尾 / 双尾 + 显著性阈值 α（0.01 / 0.05 / 0.10） |

组合数 = 各维度候选数量的乘积。变换 / 滞后 / 缩尾 / 虚拟化 / 高阶项在数据准备阶段
**预生成成候选变量列**再进枚举——样本不剔除、不截尾。

## 输出示例（演示数据）

```
规格总数: 720   达标: 128   达标率: 17.8%
Bonferroni 校正后仍达标(方向一致): 36

==== 达标规格（按 p 升序，前 20） ====
y    x    ctrl                 fe         se              beta     p
roa  dig  size lev cash        firm year  cluster2(...)  0.0063  0.0008
roa  dig  size lev cash growth firm year  cluster2(...)  0.0063  0.0008
...
```

## 目录结构

```
stata-spec-search/
├── README.md
├── LICENSE
├── INSTALL.md            # 各 agent 安装说明
├── SKILL.md              # 核心 skill（Agent Skills 格式）
├── do/
│   ├── spec_search.do    # 简单格式模板（reghdfe + RESULT 行）
│   └── demo_data.do      # 生成演示合成面板
└── examples/
    └── README.md
```

## 独立使用（不用 agent）

核心用法是让 agent 自动完成（见 [SKILL.md](SKILL.md)），用户只需说目标 + 给数据。
`do/spec_search.do` 是**格式模板**——每条规格一行 `quietly reghdfe` + 一行 `di "RESULT|..."`，
agent 按此格式展开全部组合。`do/demo_data.do` 生成演示数据：

```stata
do do/demo_data.do        // 生成 demo.dta
do do/spec_search.do      // 跑 3 个示范规格，看 RESULT 行格式
```

agent 会读 STATA log 里所有 `RESULT|` 行来收集结果，不需要中间 dta 文件。

## 依赖

- 本机 STATA（任意版本，SE / MP / BE）
- `reghdfe` + `ftools`（skill 会在缺失时自动 `ssc install`）
- 数据为 `.dta`，面板结构（个体 × 时间）

## 学术规范

本工具属于模型选择（model selection）与极端边界分析（EBA），
Leamer (1983) 以来计量经济学的标准方法——它遍历并**报告所有规格**，
而不是帮你隐藏不显著的结果。

显著规格只是模型选择的候选，最终需结合理论与研究设计判断。
报告时建议附：搜索空间规模、specification curve、多重检验校正
（Bonferroni / Romano-Wolf），避免过度拟合。

## License

[MIT](LICENSE)
