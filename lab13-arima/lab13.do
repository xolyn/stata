

cd ""
www.census.gov/data/software/x13as.htmlss

//Time Series:
* Stationarity (Forecast)
* Nonstationarity (Avoid)
* Most frequent cases:
** Trend: 
*** Deterministic (y_t=bt+u_t) : add t 
*** Stochastic (Random Walk y_t=y_{t-1}+u_t) : D-F test / Differencing y_t-y_{t-1}
** Break (e.g. Financial Crisis; Pandemic; War...):
*** Known Date: Chow Test
*** Unknown Date: QLR Test

*----------------------------------------------
* Spurious Regression & Monte Carlo 
*----------------------------------------------
// a. Run the algorithm (i) through (iii) once
* i. Generate a sequence of T=100 iid standard normal random variables. Call these variables {e_t}. 
set obs 100
gen t=_n
gen e=rnormal()
hist e 

* Set Y_1 = e_1 and Y_t = Y_(t-1) + e_t for t = 2, 3, ... ,100.
gen y=.
replace y=e if _n==1
replace y=y[_n-1]+e if y==.
tsset t
tsline y

* ii. Generate a sequence {a_t} of T=100 iid standard normal random variables. 
gen a = rnormal()


* Set X_1 = a_1 and X_t = X_(t-1) + a_t for t = 2, 3, ... ,100.
gen x=.
replace x=a if _n==1
replace x=x[_n-1]+a if x==.

* iii. Regress Y_t onto a constant and X_t. Compute the OLS estimator, R2, and the (homoskedasticity-only) t-statistic testing H0:b1=0. 
* Before running the OLS, what values do you expect b0 and b1 to have? 
reg y x
tsline y x



// b. Repeat (a) 1000 times, saving each value of R2 and the t-statistic.
postutil clear
postfile montecarlo r2 t_b1 using mc_results, replace
forval i=1/1000{
	clear
	set obs 100
	gen t=_n
	gen e=rnormal()
	gen y=.
	replace y=e if _n==1
	replace y=y[_n-1]+e if y==.
	gen a = rnormal()
	gen x=.
	replace x=a if _n==1
	replace x=x[_n-1]+a if x==.
	reg y x
	scalar r2=e(r2)
	scalar b1=_b[x]
	scalar se_b1=_se[x]
	scalar t_b1=abs(b1)/se_b1
	post montecarlo (r2) (t_b1)
}
postclose montecarlo

* Construct a histogram of the R2 and t-statistic. 
use mc_results, clear

hist r2
hist t_b1

* What are the 5%, 50%, and 95% percentiles of the distributions of the R2 and the t-statistic? 
sum r2, d
sum t_b1, d


* In what fraction of your 1000 simulated data sets does the t-statistic exceed 1.96 in absolute value?
count if t_b1>1.96

* 5,200
* Portion increases as t increases

*----------------------------------------------
* Time series data and aggregating data
*----------------------------------------------
set fredkey e8275b3385abf281ea7f84279d8afa26 , permanently

// a) GDP data
import fred gdp, clear
freduse GDP, clear

* Set the time variable and graph GDP
tsset daten
tsline GDP
gen yq=yq(year(daten),quarter(daten))
format yq %tq
tsset yq
tsline GDP

* Aggregate data to the annual GDP
g year=year(daten)
collapse (mean) GDP, by(year)
tsset year
tsline GDP


// b) Unemployment data (Monthly)
import fred unrate, clear

* Aggregate data to the quartely unemployment rate
g yq=yq(year(daten),quarter(daten))
collapse(mean) UNRATE, by(yq)
tsset yq
format yq %tq
tsset UNRATE


// c) NASDAQ composite index data (daily)
import fred nasdaqcom, clear

* Aggregate data to the weekly highest closing price
g yw=yw(year(daten),week(daten))
collapse (max) NASDAQCOM, by(yw)
tsset yw
format yw %tw
tsline NASDAQCOM

*----------------------------------------------
* Identifying ARIMA model
*----------------------------------------------
* ARIMA Model
* FORM: ARIMA(p,d,q)
* AR(p): y_t=b_0+b_1*y_{t-1}+...+b_p*y_{t-p}+u_t (Use Partial AutoCorr)
* MA(q): y_t=μ+u_t+θ_1*u_{t-1}+...+θ_q*u_{t-q} (Use AutoCorr)
* I(d): Differencing y_t for d times (Use graph or D-F test)
import fred NASDAQCOM, clear
rename *, lower
gen ym = ym(year(daten), month(daten))
format ym %tm
collapse (mean) nasdaqcom, by(ym)
tsset ym


// Step 1: Detect if a time trend exists (graph & Dickey-Fuller test)
tsline nasdaqcom
dfuller nasdaqcom //look at the p-value, if p>0.05: time trend exists


* See if first-differencing eliminates the time trend
tsline d.nasdaqcom //up and down: seems normal →no trend exists
dfuller d.nasdaqcom //0<5%: no trend exists

* Let's use log transformation
g lnnasdaqcom=ln(nasdaqcom)
tsline d.lnnasdaqcom //up and down: seems normal →no trend exists
dfuller d.lnnasdaqcom //0<5%: no trend exists
// ^^^^ only d=1 will eliminate the trend, OK


// Step 2: Box-Jenkins method
* Partial Autocorrelation Function => AR(p)
pac d.lnnasdaqcom

* Autocorrelation Function => MA(q)
ac d.lnnasdaqcom

// Step 3: Run ARIMA(p,d,q). If q>0, OLS can't be used
arima lnnasdaqcom ,arima(1,1,1)
estat ic 
arima lnnasdaqcom ,arima(2,1,1)
estat ic

