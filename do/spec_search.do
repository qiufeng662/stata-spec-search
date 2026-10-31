* ============================================================
*  spec_search.do — 简单规格搜索模板
*
*  原则：每条规格 = 一行 quietly reghdfe + 一行 di "RESULT|..."
*  不用 postfile / program / 动态宏 / 字符串解析，保持最简直白。
*  agent 会按下面格式展开全部组合；这里只给 3 个规格做示范。
*
*  RESULT 行格式（用 | 分隔）：
*    RESULT|<因变量>|<核心变量>|<控制变量>|<固定效应>|<标准误>|<beta>|<se>|<p>|<N>
* ============================================================
use "demo.dta", clear

* ---------- 预处理：候选变量（agent 根据数据自动生成）----------
gen log_roa = ln(roa)

* ---------- 规格 1：控制变量 size lev，双向 FE，企业聚类（双尾 p）----------
foreach y in roa log_roa {
    quietly reghdfe `y' dig size lev, absorb(firm year) vce(cluster firm)
    di "RESULT|`y'|dig|size lev|firm year|cluster firm|" _b[dig] "|" _se[dig] "|" 2*normal(-abs(_b[dig]/_se[dig])) "|" e(N)
}

* ---------- 规格 2：控制变量 size lev cash，双向 FE，企业聚类 ----------
foreach y in roa log_roa {
    quietly reghdfe `y' dig size lev cash, absorb(firm year) vce(cluster firm)
    di "RESULT|`y'|dig|size lev cash|firm year|cluster firm|" _b[dig] "|" _se[dig] "|" 2*normal(-abs(_b[dig]/_se[dig])) "|" e(N)
}

* ---------- 规格 3：企业 FE，稳健标准误，单尾 p（方向为正）----------
foreach y in roa log_roa {
    quietly reghdfe `y' dig size lev, absorb(firm) vce(robust)
    di "RESULT|`y'|dig|size lev|firm|robust|" _b[dig] "|" _se[dig] "|" normal(-_b[dig]/_se[dig]) "|" e(N)
}

* ... agent 会按同样格式，把 因变量 × 核心变量 × 控制变量 × 固定效应 × 标准误
*     的全部组合展开成更多这样的块。
