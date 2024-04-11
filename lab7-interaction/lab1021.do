cd "/Users/lingyu/OneDrive - UW-Madison/ECON400/lab7"

use mlb1.dta, clear

desc

scatter salary gamesyr

reg salary gamesyr
*determine whether this↑ is good enough:

*Visually:
predict salaryhat1

tw(scatter salary gamesyr)(line salaryhat1 gamesyr, sort)

rvpplot gamesyr, yline(0)
*↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑*
*E(u|X)=0 violated*****
*Var(u|X)=σ² violated**
***********************

*Do we need additional order(s)?
estat ovtest 
*↑H0: the coefficient of the higher order term=0 (should the higher order terms be omitted)

reg salary gamesyr c.gamesyr#c.gamesyr
*↑OR: reg salary c.gamesyr##c.gamesyr
*c.gamesyr##c.gamesyr is the gamesyr² term in regression
*So, now we have y=β0+β1·X+β2·X²

sum gamesyr

*Since ∂y/∂x=β1+2β2·X, the change at X=90, △X=1 is:
di _b[gamesyr] + 2*90* _b[c.gamesyr#c.gamesyr]

predict salaryhat2

tw(scatter salary gamesyr)(line salaryhat2 gamesyr, sort)

reg salary c.gamesyr##c.gamesyr, robust //safer

*Is marginal effect of gamesyr on salary significant?
* H0: ∂y/∂x=0, ∀X
*→H0: β1=0 and β2=0; H1:β1≠0 or β2≠0:
test gamesyr c.gamesyr#c.gamesyr 
*... is stat. significant

estat ovtest //P>5%, no need to add higher order terms

hist salary
hist lsalary

reg lsalary c.gamesyr##c.gamesyr, robust
*↑this regression is now in form of:
* ln(y)=β0+β1X+β2X²+u

*This is the marginal effect of games/year of 90 games on salary:
di _b[gamesyr]+2*90*_b[c.gamesyr#c.gamesyr] //≈2%







