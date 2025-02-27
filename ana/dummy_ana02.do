capture log close
log using dummy_ana02.txt, replace text

// Multivariate analysis
// MM

version 18
clear all
macro drop _all

use dummy03.dta
datasignature confirm, strict
codebook, compact

// do your analysis
logit pineapple i.mobile i.agecat i.female i.books, or

coefplot, eform drop(_cons) xline(1) baselevels   ///
     headings(0.mobile = "{bf:mobile}"            ///
	          0.agecat = "{bf:age (categorized)}" ///
			  0.female = "{bf:respondent's sex}"  ///
			  1.books  = "{bf:Read books}")       ///
	 xtitle("{bf:Odds Ratio}")                    ///
	 mcolor("0 154 209") ciopts(lcolor("0 154 209"))
graph export ../txt/gr02.emf, replace
log close
exit
