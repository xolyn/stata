use "http://fmwww.bc.edu/ec-p/data/wooldridge/wage2.dta", clear

reg wage educ

reg lwage educ

gen leduc= ln(educ)

reg wage leduc

reg lwage leduc

*------Interaction terms------*
reg wage educ

tab urban 

reg wage educ urban

predict wage2

tw (line wage2 educ if urban==0) (line wage2 educ if urban==1),legend(label(1 "Rural")label(2 "Urban"))


*------------*

gen educ_x_urban= educ*urban

reg wage educ urban educ_x_urban

*						   v:indicator RV
reg wage educ urban c.educ#i.urban
*					^:continunous RV

predict wage3 

tw (line wage3 educ if urban==0) (line wage3 educ if urban==1),legend(label(1 "Rural")label(2 "Urban"))

reg wage c.educ##i.urban

*------Heteroskedasticity------*

reg wage educ
predict resid, residuals
scatter resid educ //Heteroskedastic
*^=rvpplot educ#i

estat hettest 
*P=0<5% -> rejct null ->  have hetero-error

*------OVtest------*
reg lwage age
estat ovtest
gen age2=age^2
gen age3=age^3

reg lwage age age2 age3
estat ovtest
*P~=0.4>5% -> not reject the null -> not omitted (No OVB)
