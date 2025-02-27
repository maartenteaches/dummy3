capture log close
log using dummy_ana01.txt, replace text

// descriptives
// MM

version 18
clear all
macro drop _all
set scheme stmono1 

use dummy03.dta
datasignature confirm, strict
codebook, compact

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
collect export ../txt/tab1.docx, replace

**# bivariate relationship
// create empty file to append results to
tempfile tofill
preserve
drop _all
gen labels = ""
save `tofill', replace
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
	append using `tofill'
	save `tofill', replace
	restore
}

use `tofill', clear

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
graph export ../txt/gr01.emf, replace

log close
exit
