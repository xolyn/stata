
 *------------------------------------------*
 **      Out of sample predictions         **
 *------------------------------------------*

 sysuse nlsw88.dta , clear
 
** Dummy for sample **
g sample = _n<=1800
ta sample
g age2 = age^2

* 1. Example with two models *

** Matrix to store R2, to compare models **
mat r2 = J(2, 2,.)
mat li r2
mat colnames r2 = "R2" "Adj R2"

* model 1 -- predictor: age age2
reg wage age age2 if sample==1, r
di e(r2)
di e(r2_a)
mat r2[1,1]=e(r2)
mat r2[1,2]=e(r2_a)

predict wage1 
g mspe1 = (wage-wage1)^2
tabstat mspe1, by(sample) s(mean)

* model 2 -- predictor: age age2 collgrad industry race
reg wage age age2 collgrad industry race if sample==1, r
mat r2[2,1]=e(r2)
mat r2[2,2]=e(r2_a)

predict wage2
g mspe2 = (wage-wage2)^2

** Compare R2 from both models **
mat li r2

** Compare in-sample and out-of-sample Models **
tabstat mspe1 mspe2, by(sample) s(mean)
//mspe smaller the better


* 1. Example with several models *

** Matrix to store R2, to compare models **
drop wage1 wage2
drop mspe1 mspe2
 
mat r2 = J(5,2,.)
mat colnames r2 = "R2" "Adj R2"

global var1 age age2 race married
global var2 $var1 collgrad industry 
global var3 $var2 tenure south c_city 
global var4 $var3 smsa occupation 
global var5 $var4 ttl_exp union hours 

forval i=1/5{
	reg wage ${var`i'} if sample==1 ,r
	mat r2[`i',1]=e(r2)
	mat r2[`i',2]=e(r2_a)
	predict wage`i'
	gen mspe`i'=(wage-wage`i')^2
}


** Compare R2 from five models **
mat li r2 


** Compare in-sample and out-of-sample Models **
tabstat mspe*, by(sample) s(mean)

** Using vselect to select the best models ** 
* ssc install vselect 
global xvar age age2 race married collgrad industry tenure south c_city smsa occupation ttl_exp union hours
 
vselect wage $xvar if sample==1, best

* Store variable list of predictors from best k predictor model
forval i=1/14{
	global xvarbest`i'=r(best`i')
}
* Store R2 and adjusted R2 for best k predictor models
mat best_r2 = J(14,2,.)
mat colnames best_r2 = "R2" "Adj R2"
forval i=1/14{
	reg wage ${xvarbest`i'} if sample==1,r
	mat best_r2[`i',1]=e(r2)
	mat best_r2[`i',2]=e(r2_a)
}

mat li best_r2


 *------------------------------------------*
 **    Shrinkage estimators: Ridge         **
 *------------------------------------------*
//When n<k, the traditional OLS won't work
//Bias and variance is conflict


 ** Problem 14.9 ** 
/*
You have a sample of size n = 1 with data y1 = 2 and x1 = 1. You are
interested in the value of b in the regression Y = X b + u. (Note there is no intercept)
*/
// ∂[(y-βX)²+λβ²]/∂β = -2X(y-βX)+2λβ=0
//			β_{ridge}=xy/(x²+λ)

** (a) Plot SSR as a function of b **
clear all
set obs 101
egen b = seq(), from(-40) to(60)
replace b = b / 10

g penalty_lam1=1*b^2


** (c) Plot penalty as a function of b, for \lambda_ridge = 1

line penalty_lam1 b , ytitle("Penalty") title("Ridge penalty, with lambda = 1")

** (d) Plot penalized SSR as a function of b, for \lambda_ridge = 1
g SSR=(2-b*1)^2
g PSSR_lam1=SSR+penalty_lam1

line PSSR_lam1 b, ytitle("Penalized SSR") title("Penalized SSR_ridge, with lambda = 1")

** (f) Plot penalized SSR as a function of b, for \lambda_ridge = 0.5
g penalty_lam05=.5*b^2
g PSSR_lam05=SSR+penalty_lam05
line penalty_lam05 b, ytitle("Penalized SSR") title("Penalized SSR_ridge, with lambda = 0.5")

** (g) Plot penalized SSR as a function of b, for \lambda_ridge = 3
g penalty_lam3=3*b^2
g PSSR_lam3=SSR+penalty_lam3
line penalty_lam05 b, ytitle("Penalized SSR") title("Penalized SSR_ridge, with lambda = 3")

** All model together ** 
tw (line SSR b) (line PSSR_lam1 b) (line penalty_lam05 b) (line penalty_lam05 b), legend(order(1 "OLS" 2 "Ridge lanmba=1" 3 "Ridge lanmba=0.5" 4 "Ridge lanmba=3"))







