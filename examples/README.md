# 示例

## 交互方式

用户**不需要写代码、不需要做预处理**。在 agent 里只需说：

> 数据在 `mydata.dta`，因变量是 roa，核心变量是 dig，想要正向显著。

agent 会自动：

1. 读数据、识别变量
2. 生成候选变量（对数 / 增长率 / 缩尾 / 滞后 / 虚拟化 / 交互项）
3. 按 `do/spec_search.do` 的格式展开全部组合（每条 = `quietly reghdfe` + `di "RESULT|..."`）
4. 调用本机 STATA 批处理跑
5. 解析 log 里的 `RESULT|` 行
6. 输出达标规格排序表

## 手动跑一下（看格式）

```stata
cd "本仓库路径"
do do/demo_data.do        // 生成 demo.dta（含候选变量）
do do/spec_search.do      // 跑 3 个示范规格
```

打开 STATA 的 log（或 Results 窗口）能看到 `RESULT|...` 行，这就是 agent 解析的结果格式：

```
RESULT|roa|dig|size lev|firm year|cluster firm|0.003|0.0021|0.18|3200
RESULT|log_roa|dig|size lev|firm year|cluster firm|0.006|0.0041|0.14|3200
```

`|` 分隔的字段依次是：因变量 | 核心变量 | 控制变量 | 固定效应 | 标准误 | beta | se | p | N。

## 如果你已有实证 do 文件

直接把它发给 agent（或说文件路径），agent 会读它识别因变量 / 核心变量 / 控制变量 / 固定效应 / 标准误，在此基础上扩展规格搜索——你原来的回归设定原样保留，只是在它周围展开更多组合。
