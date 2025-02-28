// use only community contributed packages from 
// the ado directory local to this project

sysdir set PLUS     "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\ado/plus"
sysdir set PERSONAL "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\ado/personal"
sysdir set OLDPLACE "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\ado"
mata: mata mlib index

capture log close
log using "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\ana\dummy.txt", replace text

version 18
clear all
macro drop _all
use "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\data\dummy_v0-1-0.dta"

rename *, lower

**# missing values
mvdecode *, mv(-99=.d \ -98=.e \ -97=.f \ -96=.n \ -95=.l \ -94=.m) 
foreach lab in sex educ yesno_lb pvoc health_lb book_lb {
	label define `lab' .d "don't know" ///
				       .e "refused" ///
				       .f "filter"  ///
				       .n "data error" ///
				       .l "illegible" ///
				       .m "multiple answers", modify
}

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
note ed: based on v03-v15 \ dummy.do \ MM TS

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

// highest educated parent
egen byte ped = rowmax(med fed)
label values ped ed_lb
label variable ped "highest educated parent"
note ped: based on v16 v17 v18 v19 \ dummy.do \ MM TS

**# mobility
gen byte mobile:yesno_lb = ( ed != ped ) if !missing(ed,ped)
label variable mobile "educationally mobile"
note mobile : based on ed ped \ dummy.do \ MM TS

**# demographics
rename v01 age
note age : based on V01 \ dummy.do \ MM TS

gen byte agecat:agecat_lb = floor(age/25)*25
label variable agecat "age (categorized)"
label define agecat_lb 0  "18-24"  ///
                       25 "25-49"  ///
					   50 "50-74"  ///
					   75 ">75"
note agecat : based on V01 \ dummy.do \ MM TS					   

gen byte female:female_lb = v02 - 1
label define female_lb 0 "male" 1 "female"
label variable female "respondent's sex"
note female : base on V02 \ dummy.do \ MM TS
tab female v02, missing

**# pineapple
rename v20 pineapple
note pineapple : based on v20 \ dummy.do \ MM TS

**# books
rename v23 books
note books : based on v23 \ dummy.do \ MM TS

**# health
rename v21 health
note health : based on v21 \ dummy.do \ MM TS

**# touse
gen byte touse:yesno_lb = !missing(mobile, age, pineapple, books, female)
label variable touse "observations without missing values"

**# descriptives
dtable i.pineapple i.mobile i.agecat i.female i.books if touse
collect style cell border_block[column-header corner], ///
      border(top, width(1pt) color("0 154 209")) 
collect style cell cell_type[column-header], halign(right) font(,bold)	  
collect style cell var[5.books], ///
      border(bottom, width(1pt) color("0 154 209"))
collect style cell var[_N], ///
      border(top, width(1pt) color("0 154 209"))
collect style cell , font(arial)	  
collect export "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\txt/tab1.docx", replace

**# missing values
frame create tograph
frame change tograph
frame default {
	local varl : variable label pineapple
	count if missing(pineapple)
	local n = r(N)
}
set obs 1
gen var = `"`varl'"'
gen nmiss = `n'
local N = 1

foreach var in mobile agecat female books {
	frame default {
		local varl : variable label `var'
		count if missing(`var')
		local n = r(N)
	}
	set obs `++N'
	replace var = `"`varl'"' in l
	replace nmiss = `n' in l
}
frame default {
	count if missing(pineapple, mobile, agecat, female, books) 
	local n = r(N)
}
set obs `++N'
replace var = "total" in l
replace nmiss = `n' in l

gen yaxis = _n
labmask yaxis , values(var)

twoway scatter nmiss yaxis,                         ///
    ylab(1/6, val nogrid) ytitle("")                ///
	recast(dropline) horizontal                     ///
	mlab(nmiss) mlabformat(%9.0gc) mlabcolor(black) ///
	xlab(none) xscale(range(0 1600))                ///
	xtitle("number of missing values")              
graph export "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\txt/gr_missing.emf", replace	
frame change default

**# bivariate relationship
// create empty file to append results to
preserve
drop _all
gen labels = ""
save "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\ana\temp.dta", replace
restore

// fill file with proportions of pineapple by x
foreach var of varlist books female agecat mobile {
	preserve 
	
	// get the proportions
	collapse (mean) pineapple if touse, by(`var')

	// add an empty row with the variable label on top
	set obs `= _N + 1'
	replace `var' = -1 in l
	label define `:value label `var''  ///
	   -1 `"{bf:`:variable label `var''}"', modify
	sort `var'
	
	// make a string variable from the variable
	decode `var', gen(labels)
	drop `var'
	
	// add those rows to `tofill'
	append using "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\ana\temp.dta"
	save "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\ana\temp.dta", replace
	restore
}

preserve
use "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\ana\temp.dta", clear

// add some blank space between the variables
seqvar yaxis = 1/3 5/9 11/13 15/20
labmask yaxis, values(labels)

// turn proportions into percentages
replace pineapple = pineapple * 100

// make the graph
twoway scatter pineapple yaxis ,             ///
    recast(dropline) horizontal              ///
	ylabel(1/3 5/9 11/13 15/20, val noticks) ///
	xlabel(none)                             ///
	yscale(reverse) xscale(range(0 60))      ///
    mlabel(pineapple) mlabformat(%9.0f)      ///
	lcolor("0 154 209") mcolor("0 154 209")  ///
	xtitle("% who find pineapple on pizza acceptable")
graph export "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3\txt/gr01.emf", replace
restore 

**# multivariate analysis
// age linear
logit pineapple i.mobile age i.female i.books, or

coefplot, eform drop(_cons) xline(1) baselevels   ///
     headings(0.mobile = "{bf:mobile}"            ///
	          agecat   = "{bf:age}"               ///
			  0.female = "{bf:respondent's sex}"  ///
			  1.books  = "{bf:Read books}")       ///
	 xtitle("{bf:Odds Ratio}")                    ///
	 mcolor("0 154 209") ciopts(lcolor("0 154 209"))
graph export "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3/txt/gr02a.emf", replace

// age categorized
logit pineapple i.mobile i.agecat i.female i.books, or

coefplot, eform drop(_cons) xline(1) baselevels   ///
     headings(0.mobile = "{bf:mobile}"            ///
	          0.agecat = "{bf:age (categorized)}" ///
			  0.female = "{bf:respondent's sex}"  ///
			  1.books  = "{bf:Read books}")       ///
	 xtitle("{bf:Odds Ratio}")                    ///
	 mcolor("0 154 209") ciopts(lcolor("0 154 209"))
graph export "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3/txt/gr02.emf", replace


// added health
logit pineapple i.mobile i.agecat i.female i.books i.health, or

coefplot, eform drop(_cons) xline(1) baselevels    ///
     headings(0.mobile = "{bf:mobile}"             ///
	          0.agecat = "{bf:age (categorized)}"  ///
			  0.female = "{bf:respondent's sex}"   ///
			  1.books  = "{bf:Read books}"         ///
			  1.health = "{bf:subjective health}") ///
	 xtitle("{bf:Odds Ratio}")                     ///
	 mcolor("0 154 209") ciopts(lcolor("0 154 209"))
graph export "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy_3/txt/gr02b.emf", replace


log close
exit
