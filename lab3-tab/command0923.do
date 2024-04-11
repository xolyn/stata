cd "C:\Users\JselZ\OneDrive - UW-Madison\ECON400\lab3"

import delimited "gradeage.csv", clear rowrange(3:18) colrange(2:15) varnames(noname)

rename v1 grade 

rename v2-v14 prob(#), addnumber(34)

reshape long prob, i(grade) j(age)

tabstat prob, s(sum) by(age)
*table for stat. (conditional prob. dist.)

// egen Pa sum(prob) by(grade)

bysort age: egen Pa= sum(prob)

gen g_times_Pga=grade*prob/Pa

tabstat g_times_Pga, s(sum) by(age)

save grade_age_long, replace

*-------------------------------------------*

collapse (sum) g_times_Pga, by(age)

rename g_times_Pga conditional_mean

scatter conditional_mean age 

use grade_age_long, clear

collapse (sum) g_times_Pga prob, by(age)

rename g_times_Pga conditional_mean

rename prob Pa 

gen conditional_mean_times_Pa = conditional_mean*Pa

tabstat conditional_mean_times_Pa, s(sum)

*-------------------------------------------*
use grade_age_long, clear

gen g2=grade^2 

gen g2_times_p=g2*prob

tabstat g2_times_p, s(sum)
