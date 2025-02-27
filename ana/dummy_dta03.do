capture log close
log using dummy_dta03.txt, replace text

// combine sub-datasets into analysis dataset
// MM

version 18
clear all
macro drop _all

use dummy02
datasignature confirm, strict 

use dummy01
datasignature confirm, strict

merge 1:1 id using dummy02
assert _merge == 3
drop _merge

gen byte touse:yesno_lb = !missing(mobile, age, pineapple, books, female)
label variable touse "observations without missing values"

compress
note: dummy03.dta \ analysis \ dummy_dta03.do \ MM TS 
label data "analysis"
datasignature set, reset
save dummy03.dta, replace

log close
exit
