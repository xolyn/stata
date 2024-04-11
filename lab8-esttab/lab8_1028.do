use "https://stats.idre.ucla.edu/stat/stata/notes/hsb2",clear

desc

sum *

tab prog

*generate 3 vars that indicate whether each option of prog is true or not:
tab prog, gen(progcat) 

ssc install estout
eststo model1: regress read write female math progcat1 progcat2, robust

//Missing data:
use "https://stats.idre.ucla.edu/wp-content/uploads/2017/05/hsb2_mar.dta", clear

sum *

tab prog, gen(progcat)

eststo model2: regress read write female math progcat1 progcat2, r

esttab model1 model2

//Imputation:

misstable sum read write female math progcat1 progcat2

misstable sum read write female math progcat1 progcat2, gen(missing)

sum read write female math progcat1 progcat2

corr read write female math progcat1 progcat2

pwcorr read write female math progcat1 progcat2

//1. Mean imputation (Use mean to assume the mean of the missing data)
sum read //mean of reading score is 52.28796

replace read = r(mean) if read==. //"." is for missing data

foreach var of varlist read write female math progcat1 progcat2{
	sum `var'
	replace `var' =r(mean) if `var'==.
}

/*
tw (hist read if missread==0, start(25) width(5) color (red%30)) ///
(hist read, start(25) width(5) color (green%30)),
legend(order(1 "Non-missing" 2 "Imputed" ))
tw (scatter read write if missread==0 & misswrite==0, color (red%70)) ///
(scatter read write if missread==1 | misswrite==1, color (green%70)), ///
legend(order (1 "Non-missing" 2 "Imputed" ))
*/

eststo model3: regress read write female math progcat1 progcat2,r

esttab model1 model2 model3

//2. Multiple Imputation:
use "https://stats.idre.ucla.edu/wp-content/uploads/2017/05/hsb2_mar.dta", clear

tab prog, gen(progcat)

* These 3 command genereate the multiple imputation dataset:
mi set flong 
mi register impute read write female math progcat1 progcat2
mi impute mvn read write female math progcat1 progcat2, add(10) rseed(114514)

sort id _mi_m

sum read write female math progcat1 progcat2 if _mi_m==0 //original
sum read write female math progcat1 progcat2 if _mi_m>0 //imputed

pwcorr read write female math progcat1 progcat2 if _mi_m==0
pwcorr read write female math progcat1 progcat2 if _mi_m>0

mi estimate, post: regress read write female math progcat1 progcat2, r
eststo model4

esttab model1 model2 model3 model4

//Panel data:
use "http://fmwww.bc.edu/ec-p/data/stockwatson/fatality.dta", clear

*v set which is item vars. and which is time vars. (order)
xtset state year 

sum mrall

xtsum mrall

// xtline mrall 
//^ cost too much time

xtline mrall if inlist(state, 55, 6, 36), overlay

labelbook //legends
