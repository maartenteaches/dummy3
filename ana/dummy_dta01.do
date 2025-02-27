capture log close
log using dummy_dta01.txt, replace text

// prepare education variables
// MM

**# Open data and select variables
version 18
clear all
macro drop _all

use ../data/dummy_v0-1-0

rename *, lower
keep id v03-v19

**# missing values
do dummy_missing.do

**# respondent's education
gen byte school = 1 if inlist(v03,1,2)
replace  school = 2 if inlist(v03,3,6)
replace  school = 3 if inlist(v03,4,5) | v11 == 1

gen byte voc = 1 if inlist(1, v04, v05, v08, v14, v15)
replace  voc = 2 if inlist(1, v06, v07, v09, v10, v11)
replace  voc = 3 if inlist(1, v12, v13)

gen byte ed:ed_lb = 1 if inlist(school,1,2) & voc == 1
replace  ed       = 2 if school == 1 & voc == 2
replace  ed       = 3 if school == 2 & voc == 2
replace  ed       = 4 if school == 3 & voc <  3
replace  ed       = 5 if voc == 3
label define ed_lb 1 "lower or middle secondary & no vocational"     ///
                   2 "lower secondary & vocational"                  ///
                   3 "middle secondary & vocational"                 ///
                   4 "higher secondary & with or without vocational" ///
                   5 "university"
label var ed "respondent's education"
note ed: based on v03-v15 \ dummy_dta01.do \ MM TS
drop school voc

**# parents' education
// father
gen byte fschool = 1 if inlist(v16,1,2)
replace  fschool = 2 if inlist(v16,3,6)
replace  fschool = 3 if inlist(v16,4,5) | v17 == 9

gen byte fvoc = 1 if inlist(v17, 1,50)
replace  fvoc = 2 if inlist(v17, 5,6,9)
replace  fvoc = 3 if inlist(v17, 10,11)

gen byte fed:ed_lb = 1 if inlist(fschool,1,2) & fvoc == 1
replace  fed       = 2 if fschool == 1 & fvoc == 2
replace  fed       = 3 if fschool == 2 & fvoc == 2
replace  fed       = 4 if fschool == 3 & fvoc <  3
replace  fed       = 5 if fvoc == 3
label variable fed "father's education"
drop fschool fvoc

// mother
gen byte mschool = 1 if inlist(v18,1,2)
replace  mschool = 2 if inlist(v18,3,6)
replace  mschool = 3 if inlist(v18,4,5) | v19 == 9

gen byte mvoc = 1 if inlist(v19, 1,50)
replace  mvoc = 2 if inlist(v19, 5,6,9)
replace  mvoc = 3 if inlist(v19, 10,11)

gen byte med:ed_lb = 1 if inlist(mschool,1,2) & mvoc == 1
replace  med       = 2 if mschool == 1 & mvoc == 2
replace  med       = 3 if mschool == 2 & mvoc == 2
replace  med       = 4 if mschool == 3 & mvoc <  3
replace  med       = 5 if mvoc == 3
label variable med "mother's education"
drop mschool mvoc

// highest educated parent
egen byte ped = rowmax(med fed)
label values ped ed_lb
label variable ped "highest educated parent"
note ped: based on v16 v17 v18 v19 \ dummy_dta01.do \ MM TS
drop med fed

**# mobility
gen byte mobile:yesno_lb = ( ed != ped ) if !missing(ed,ped)
label variable mobile "educationally mobile"
note mobile : based on ed ped \ dummy_dta01.do \ MM TS

**# clean up and save
keep id mobile
compress
note: dummy01.dta \ education variables \ dummy_dta01.do \ MM TS 
label data "education variables"
datasignature set, reset
save dummy01.dta, replace

log close
exit
