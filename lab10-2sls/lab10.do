/*
Notes: 
The Durbin Watson (DW) statistic is a test for autocorrelation in the residuals from a statistical model or regression analysis. 
The Durbin-Watson statistic will always have a value ranging between 0 and 4. A value of 2.0 indicates there is no autocorrelation detected in the sample. 
Values from 0 to less than 2 point to positive autocorrelation and values from 2 to 4 means negative autocorrelation.
Violation of the no autocorrelation assumption on the disturbances, will lead to inefficiency of the least squares estimates, i.e., no longer having the smallest variance among all linear unbiased estimators. It also leads to wrong standard errors for the regression coefficient estimates.
*/


*--------------------------------------------------
* Demand and Supply broiler chicken market 
*--------------------------------------------------

use "newbroiler.dta", clear
des
sum
tab year

* Time series set *
tsset year

foreach var in p pb pcorn pf q qprod y {
	gen l`var' =ln(`var')
}
 
 *----------------------------
 * Demand:lq_t=b0+b_1*lp_t+b2*ly_t
 * Demand side 
 * Qd = b0 + b1p + b2y + v
 *----------------------------
 
 * Basic OLS 
reg lq lp ly
dwstat
predict res_ols1, residuals
scatter res_ols1 l.res_ols1

 * Basic OLS + substitutes price (beef)
reg lq lp ly lpb
dwstat
predict res_ols2, residuals
scatter res_ols2 l.res_ols2

 * First differences --> delta(Qd) = delta(p) + delta(y) + delta(pb)
gen dlq=lq-l.lq
gen dlp=lp-l.lp
gen dly=ly-l.ly
gen dlpb=lpb-l.lpb
reg dlq dlp dly dlpb, nocons
dwstat //in [1.5,2.5]

/*
┌────────┬──────┬──────┬─────────┐
│ Desire │ OLS1 │ OLS2 │ 1stDiff │
├────────┼──────┼──────┼─────────┤
│ β1<0   │ √    │ √    │ √       │
│ β2>0   │ √    │ √    │ √       │
│ β3>0   │ -    │ ×    │ √       │
│ d=2    │ ×    │ ×    │ √       │
└────────┴──────┴──────┴─────────┘
*/

 *----------------------------
 * Supply side 
 * Qs = a0 + a1p + a2w + u
 * Qt= q_t*Pop_t
 *----------------------------
 
tsline qprod

 * Basis OLS 

reg lqprod lp lpcorn
dwstat

 * Basic OLS + trend and lagQ

reg lqprod lp lpcorn year l.lqprod
dwstat

 * Basic OLS + trend and lagQ, alternative input price

reg lqprod lp lpf year l.lqprod
 
 *-------------------------------
 * Simultaneous Equations 
 * IV - two stage least squares
 *-------------------------------
 
/*
┌────────┬──────┬──────┬─────────┐
│ Desire │ OLS1 │ OLS2 │ 1stDiff │
├────────┼──────┼──────┼─────────┤
│ α1>0   │ ×    │ ×    │ ∆       │
│ α2<0   │ √    │ √    │ √       │
│ d=2    │ ×    │ √    │ √       │
└────────┴──────┴──────┴─────────┘
 ∆: Not statistically significant	
*/
 
/* 
Two-stage least squares estimation yields statistically signicant estimates 
of all structural parameters each of which is of the appropriate sign and is 
plausible in magnitude 

1st Stage: Run a regression of X on Z, get X_hat=f(Z)
2nd Stage: Run a regression of y on X, get y=f(X)
*/

/*
OLS Assumption: Corr(X,u)=0 <= E(u|X)=0 
Corr(Pt,Ut)=0
*/

** Demand side -- using supply equation to explain the price **


** Supply side -- using demand equation to explain the price **

* ∆lq_t=b1∆lp_t+b2∆ly_t+b3∆lpb_t+∆ut

ivregress 2sls lqprod lpf year l.lqprod (lp=l.lp dly dlpb),r
dwstat
// dlq dlp dly dlpb