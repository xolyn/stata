// cd ""

*--------------------------------------------------
* Randomized Controlled Trial 
*--------------------------------------------------

use Names, clear
desc
tab call_back
tab black

// a. What was the call-back rate for whites? For African Americans? Construct a 95% confidence interval for the difference in the call-back rates. Is the difference statistically significant? Is it large in a real-world sense?

reg call_back black,r
*  Yi=b0+b1 Blacki + ui
** b0:E(Yi| Blacki=0)=E(Yi| White)
** b0+b1: E(Yi| Blacki=1)=E(Yi| Black)
** Δ：b1

// b. What is the difference in callback rates for high-quality versus low-quality resumes? What is the high-quality/low-quality difference for white applicants? For black applicants? Is there a significant difference in this high-quality/low-quality difference for whites versus blacks?

tab high
reg call_back high, r
reg call_back high if black==0,r 
reg call_back high if black==1,r 

* Treatment Effect
* Create a model: Yi=b0 + b1 high + b2 blacki + b3 highi × blacki +ui

reg call_back high black i.high#i.black, r

gen highxblack = high * black
reg call_back high black highxblack

/// c. The authors of the study claim that race was assigned randomly to the resumes. Is there any evidence of nonrandom assignment? (Test balance for years of work experience, college and computer skills)

reg yearsexp black ,r
reg college black, r //balanced
reg computerskills black,r 

// d. Re-estimate the difference in the call-back rates for white versus African Americans controlling for years of work experience, college and computer skills.

reg call_back black yearsexp college computerskills, r //stat sign -> not balanced

*--------------------------------------------------
* Regression Discontinuity 
** Wi: Running Var
** Xi=1 if i is treated, Wi>=C
*--------------------------------------------------

use RDsample, clear
desc

// a. Explain what the treatment was in Lee's study and how it was assigned to each observation. 

bysort demwin : sum difdpct
* Running var: difdpct, assignment: demwin (difdpct >=0)
* outcome: dpctnxt


// b. If we want to replicate Lee's analysis using our data, what is the name of our assignment variable? What is the outcome variable in our dataset?  

* LOCAL ATE:
** lim_{e->0+} E(Yi|Wi=C-e)- lim_{e->0+}E(Yi|Wi=C-e)
** Regress Yi=b0+b1Xi+f(Wi)+ui, where b1 is the LATE 


// c. Create a variable with values 1-50, where each number represents a margin of victory. If the Democratic candidate loses by more than 24% of the vote, but less than 25% of the vote, assign the value 1. If the Democratic candidate loses by more than 23% of the vote, but less than 24% of the vote, assign the value 2. And so on. The goal is to assign the variable DifDPct to bins starting from -25% up to 25% in increments of 1%p. Calculate the average value of the outcome variable, DPctNxt, and plot the relationship between that variable and your newly created variable. Characterize the relationship and offer an explanation for what you observe. 
gen difdbin0 = .
forval b=1/50{	
	replace difdbin0=`b' if difdpct>=-25+`b'-1 & difdpct<-24+`b'-1
}
tabstat difdpct, by(difdbin0) s(min max)

gen difdbin = difdbin0-25.5
tabstat difdpct, by(difdbin) s(min max) // difdbin is the median of each bin

bysort difdbin: egen mean_dpctnxt = mean (dpctnxt)
scatter mean_dpctnxt difdbin



// d. Generate square and cubic terms for DifDPct and use those variables to estimate the discontinuity gap. You will need to estimate two models. First regress DPctNxt on the cubic polynomial of DifDPct if DemWin=1. Next, regress DPctNxt on the third-degree polynomial of DifDPct if DemWin=0. Generate a plot of the local averages from (c) and polynomial fits of the outcome variable against the values of the variable you created in part (c). 

gen difdpct2= difdpct ^2 
gen difdpct3= difdpct ^3

reg dpctnxt difdpct  difdpct2 difdpct3 if demwin==0,r
predict dpctnxt0

reg dpctnxt difdpct  difdpct2 difdpct3 if demwin==1,r
predict dpctnxt1

tw (scatter mean_dpctnxt  difdbin) ///
   (line dpctnxt0 difdpct if demwin ==0 ,sort) ///
   (line dpctnxt1 difdpct if demwin ==1 ,sort), ///
   xline(0)

reg dpctnxt demwin i.demwin#(c.difdpct c.difdpct2 c.difdpct3),r 
* 1 vote more will cause 10.61 (_b[demwin]) percent larger success in the election

/// e. Estimate the incumbency effect by regression DPctNxt on DemWin, the third-degree polynomial of DifDPct, and their interactions.  


// f. conduct a parallel regression discontinuity analysis on previous terms served by Democratic candidate. We do this to test for manipulation of the assignment variable. We should not observe any discontinuities in these variables that were determined prior to assignment – is this the case?




