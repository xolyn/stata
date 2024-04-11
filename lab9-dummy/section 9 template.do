

cd D:\OneDrive - UW-Madison\ECON400\lab9" 


ssc install estout
sysuse auto, clear
gen mpg2=mpg^2
gen mpg3=mpg^3
eststo m1: reg price mpg mpg2, r
eststo m2: reg price mpg mpg2 mpg3, r
esttab m1 m2, mtitle("Qudratic" "Cubic") coeflabels(mpg2 "mpg squared")


/*
You will estimate the effect of workplace smoking bans on smoking, 
using data on a sample of 10,000 U.S. indoor workers from 1991 to 1993.

The data set contains information on whether individuals were or were not
subject to a workplace smoking ban, whether the individuals smoked, and
other individual characteristics.
*/

use Smoking, clear
desc
// (a) Estimate the probability of smoking for (i) all workers, (ii) workers affected by workplace smoking bans, and (iii) workers not affected by workplace smoking bans.

sum smoker 
di r(mean) 
bysort smkban: sum smoker //E(Y)=P(Y=1)*1+P(Y=0)*0=P(Y=1)*1
tabstat smoker, by(smkban)

// (b) What is the difference in the probability of smoking between workers affected by a workplace smoking ban and workers not affected by a workplace smoking ban? Use a linear probability model to determine whether this difference is statistically significant.

reg smoker smkban, r 
*^-0.0775583: diff mean(prob) of smoking subj to smkban
*(with smkban：P(smoke)-=0.0775583)

// (c) Estimate a linear probability model with smoker as the dependent variable and the following regressors: female, age, age2, smkban, hsdrop, hsgrad, colsome, colgrad. Compare the estimated effect of a smoking ban from this regression with your answer from (b). Suggest a reason, based on the substance of this regression, explaining the change in the estimated effect of a smoking ban between (b) and (c).

gen age2=age^2
reg smoker smkban female age age2 hsdrop hsgrad colsome colgrad, r
*^ coeff changed due to OVB in (b).

// (d) Test the hypothesis that the coefficient on smkban is zero at the 5% significance level.

* Look at the t or p value in regression table in (c) to check.

// (e) Test the hypothesis that the probability of smoking does not depend on the level of education in the regression in (c). Does the probability of smoking increase or decrease with the level of education?

test hsdrop hsgrad colsome colgrad
*^ Meaning that education do have an impact on smoker

// (f)
// i. Alex is male, 20 years old, a high school dropout and not subject to a smoking ban. Calculate the probability that A smokes.

di _b[_cons] + 20* _b[age]+ 400*_b[age2]+_b[hsdrop]

// ii. Bella is female, 80 years old, a college graduate and not subject to a smoking ban

di _b[_cons] + 1* _b[female]+ 80* _b[age]+ 80^2*_b[age2] +1*_b[colgrad]
*^ Negative, which shows 1 problem of LPM, which is Prob. is not strictly in [0,1]. To solve this problem, we use probit and logit regression model. However, its advantage is it is very easy to interpret

// (g)
// i. What is the effect of the smoking ban on the probability of smoking for Alex?

*Just:
di _b[smkban]

// ii. For Bella?

*Also just:
di _b[smkban]

*--------------------------------------------------
// (h) Repeat (c)–(g) using a probit model.(Probit model uses standard normal dist. as G for P(Y=1|X)=G(β0+β1x))
* (c), (d)

probit smoker smkban female age age2 hsdrop hsgrad colsome colgrad, r
margins, dydx(*)

*To see whether it has a significant effect, still look at p or t value in the table generated in this question.

* (e)

test hsdrop hsgrad colsome colgrad

* (f)-i.

margins, at(age=20 age2=400 female=0 hsdrop=1 hsgrad=0 colsome=0 colgrad=0 smkban=0)

* (f)-ii.

margins, at(age=80 age2=6400 female=1 hsdrop=0 hsgrad=0 colsome=0 colgrad=1 smkban=0)
*^ Note that the probability is now normal, and differs a lot from the result in previous negative answer.

* (g)-i.

margins, at(age=20 age2=400 female=0 hsdrop=1 hsgrad=0 colsome=0 colgrad=0 smkban=1)
margins, at(age=20 age2=400 female=0 hsdrop=1 hsgrad=0 colsome=0 colgrad=0 smkban=0)

*OR:

margins, at(age=20 age2=400 female=0 hsdrop=1 hsgrad=0 colsome=0 colgrad=0) over(smkban)

* (g)-ii.

margins, at(age=80 age2=6400 female=1 hsdrop=0 hsgrad=0 colsome=0 colgrad=1) over(smkban)

*--------------------------------------------------
// (i) Repeat (c)–(g) using a logit model.(Logit model uses logistics dist. as G for P(Y=1|X)=G(β0+β1x))
* (c), (d)

logit smoker smkban female age age2 hsdrop hsgrad colsome colgrad, r
margins, dydx(*)

*To see whether it has a significant effect, still look at p or t value in the table generated in this question.

* (e)

test hsdrop hsgrad colsome colgrad

* (f)-i.

margins, at(age=20 age2=400 female=0 hsdrop=1 hsgrad=0 colsome=0 colgrad=0 smkban=0)

* (f)-ii.

margins, at(age=80 age2=6400 female=1 hsdrop=0 hsgrad=0 colsome=0 colgrad=1 smkban=0)
*^ Note that the probability is now normal, and differs a lot from the result in previous negative answer.

* (g)-i.

margins, at(age=20 age2=400 female=0 hsdrop=1 hsgrad=0 colsome=0 colgrad=0 smkban=1)
margins, at(age=20 age2=400 female=0 hsdrop=1 hsgrad=0 colsome=0 colgrad=0 smkban=0)

*OR:

margins, at(age=20 age2=400 female=0 hsdrop=1 hsgrad=0 colsome=0 colgrad=0) over(smkban)

* (g)-ii.

margins, at(age=80 age2=6400 female=1 hsdrop=0 hsgrad=0 colsome=0 colgrad=1) over(smkban)

*--------------------------------------------------
* Multinomial logit (Familiar)
*--------------------------------------------------
use hsbdemo, clear
desc

tab prog
tab ses
tab math write

mlogit prog math write i.ses, r
margins, dydx(*)

predict p1 p2 p3
list prog math write ses p1 p2 p3 in 1/10
egen p_max = rowmax(p1 p2 p3)
gen pred_prog =1 if p1==p_max
replace pred_prog=2  if p2==p_max
replace pred_prog=3  if p3==p_max

tab prog pred_prog, cell

*--------------------------------------------------
* Acess any value in a cell:
*--------------------------------------------------
di _b[age]
di _se[age]
help reg
mat li e(V)
logit smoker smkban age
margins, at(age=20 smkban=0)
return list
mat lis r(b)
di r(b)[1,1]
scalar p_logit = r(b)[1,1]
di p_logit