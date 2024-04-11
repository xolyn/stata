cd "C:\Users\JselZ\OneDrive - UW-Madison\ECON400\lab5"
use baseball.dta, clear

reg salary hits

reg salary hits runs

scatter runs hits

// corr runs hits
//
// reg runs hits

*exception:
*reg salary hits fa, R^2 is very high, while reg hits fa, R^2 is low


*Are hits are fa jointly significant?

reg salary hits fa
test hits fa 
*if Prob>F > 5%: not sig.

*************************HW**************************
ssc install estout
eststo: reg salary batavg
eststo: reg salary batavg onbase 
eststo: reg salary batavg onbase hits

esttab 
* only beta1
esttab ,cells(b)
* get value
return list 
*
mat li r(coefs)
mat b_mat=r(coefs)
esttab m(b_mat,transpose)
******************************v8numbers in total
esttab m(b_mat,transpose fmt(%8.2f))
********************************^2 digits decimals


*************************twoway**************************
scatter salary hits
tw(scatter salary hits if fa==0)(scatter salary hits if fa==1),legend(label(1 "Non-Fa") label(2 "FA"))
************^first plot graph			^second plot graph       ^legend option

reg salary hits
predict salaryhat
scalar rmse=e(rmse)
gen salary_upper = salaryhat+1.96*rmse
gen salary_lower = salaryhat-1.96*rmse

tw rarea salary_upper salary_lower hits,sort color(grey%50)
tw (rarea salary_upper salary_lower hits,sort color(grey%50))(scatter salary hits)(line salaryhat hits),legend(label(1 "95% CI"))

tw (lfitci salary hits, stdf)(scatter salary hits)






reg salary hits 
predict resid, residual
scatter resid hits