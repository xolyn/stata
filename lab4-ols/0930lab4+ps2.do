cd "C:\Users\JselZ\OneDrive - UW-Madison\ECON400\lab4"

sysuse auto, clear

keep in 1/5
keep price trunk

*!:br as browse

scatter price trunk

*@:yi=β0+β1*xi+ui

*#:beta 1 hat:
sum price 
di r(mean)
scalar pricebar=r(mean)


sum trunk
di r(mean)
scalar trunkbar=r(mean)

gen dT_dP=(price-pricebar)*(trunk-trunkbar)

sum dT_dP 
scalar covTP=r(mean)
di covTP

gen dT2=(trunk-trunkbar)^2
sum dT2
scalar varT=r(mean)

scalar beta1hat=covTP/varT
di beta1hat

corr trunk price, cov

mat li r(C)

di r(C)[2,1]

*#:beta 0 hat:

scalar beta0hat= pricebar - beta1hat*trunkbar

di beta0hat

gen pricehat=beta0hat+beta1hat*trunk-trunkbar

scatter price trunk || line pricehat trunk 
*!:|| to combine 2 graphs               
*?: trunk ?


*#:reality method:

reg price trunk
predict pricehat1
br

*******************************PS2-Q5:*******************************

use Earnings_and_Height.dta, clear

*a)
sum height, d
*!:d for detail

*b)
**i-ii).
*@:1 for short, 0 for not short
gen short = height <= 67 

bysort short: sum earnings

**iii).
ttest earnings, by(short)

*c).
scatter earnings height

*d).
**i).
reg earnings height
*?: which one is slope

**ii).
*@: β0:
di _b[height]
*@: β1:
di _b[_cons]
*@: Calculate the predicted value at x=67:
di _b[_cons]+67*_b[height]

*e).
**i-iv).
gen height_cm =height*2.54
reg earnings height_cm
*@: note that β0 is the same but β1 changed to 278.6109
*@: root mse=standard error of the reg
di e(mss)
di e(rss)
*tss=mss+rss

*f).
tab sex
*@ reg on female
reg earnings height if sex==0

predict resid, residual 

*g).
reg earnings height if sex==1








