capture log close
log using dummy_dta02.txt, replace text

// non-education variables
// MM

version 18
clear all
macro drop _all

use ../data/dummy_v0-1-0

rename *, lower
keep id v01 v02 v20 v23

**# missing values
do dummy_missing.do

**# demographics
rename v01 age
note age : based on V01 \ dummy_dta02.do \ MM TS

gen byte agecat:agecat_lb = floor(age/25)*25
label variable agecat "age (categorized)"
label define agecat_lb 0  "18-24"  ///
                       25 "25-49"  ///
					   50 "50-74"  ///
					   75 ">75"
note agecat : based on V01 \ dummy_dta02.do \ MM TS					   

gen byte female:female_lb = v02 - 1
label define female_lb 0 "male" 1 "female"
label variable female "respondent's sex"
note female : base on V02 \ dummy_dta02.do \ MM TS
tab female v02, missing

**# pineapple
rename v20 pineapple
note pineapple : based on v20 \ dummy_dta02.do \ MM TS

**# books
rename v23 books
note books : based on v23 \ dummy_dta02.do \ MM TS
		   
**# clean and save
drop v02 age 
compress
note: dummy02.dta \ non-education variables \ dummy_dta02.do \ MM TS 
label data "non-education variables"
datasignature set, reset
save dummy02.dta, replace

log close
exit
