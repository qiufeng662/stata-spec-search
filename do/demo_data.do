* ============================================================
*  demo_data.do — 生成演示用合成面板（400 企业 × 8 年 = 3200）
*  运行：do demo_data.do  → 生成 demo.dta
*  预生成：对数 / 增长率 / 缩尾多分位 / 虚拟化 / 滞后 / 平方项 / 交互项
* ============================================================
clear all
set more off
set seed 7

set obs 400
gen firm = _n
gen ind  = mod(firm, 12)
gen ffe  = rnormal(0, 0.04)

expand 8
bysort firm: gen year = 2014 + _n

gen size   = rnormal(9, 1.2)
gen lev    = rbeta(2, 5) * 0.6
gen cash   = 0.15 + 0.10*(size-9) + rnormal(0, 0.05)
gen growth = 0.08 + 0.05*(size-9) + rnormal(0, 0.15)
gen dig    = max(0, 0.40 + 0.25*(size-9) + 0.30*cash + rnormal(0, 0.50))

* 微弱核心效应（约 0.003），噪声较大，制造"需要搜索设定"的场景
gen roa = 0.060 + 0.012*size - 0.035*lev + 0.030*cash + 0.003*dig + ffe + rnormal(0, 0.040)
replace roa = max(0.001, roa)

* ---------- 因变量变换 ----------
gen log_roa = ln(roa)

sort firm year
bysort firm: gen roa_g = (roa - roa[_n-1]) / roa[_n-1]     // 增长率

foreach p in 1 2 5 {                                       // 缩尾 1%/2%/5%
    local hi = 100 - `p'
    _pctile roa, p(`p' `hi')
    gen roa_w`p' = min(max(roa, r(r1)), r(r2))
}
gen roa_pos = (roa > 0)                                     // 虚拟化：是否盈利

* ---------- 核心变量变换 ----------
sum dig
gen dig_z = (dig - r(mean)) / r(sd)                         // 标准化
gen dig_hi = (dig > r(mean))                                // 虚拟化：高/低组

bysort firm: gen dig_lag1 = dig[_n-1]                       // 滞后 1 期
bysort firm: gen dig_lag2 = dig[_n-2]                       // 滞后 2 期

* ---------- 高阶项 ----------
gen size2    = size^2
gen dig_size = dig * size

order firm year ind roa log_roa roa_g roa_w1 roa_w2 roa_w5 roa_pos ///
      dig dig_z dig_hi dig_lag1 dig_lag2 size lev cash growth size2 dig_size
save "demo.dta", replace
di as txt "已生成 demo.dta（" _N " 观测，包含变换/滞后/缩尾/虚拟化/高阶项候选变量）"
