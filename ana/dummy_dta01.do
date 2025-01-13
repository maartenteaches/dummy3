capture log close
log using dummy_dta01.txt, replace text

// What this .do file does
// Who wrote it

version 18
clear all
macro drop _all

*use ../data/[original_data_file.dta]

*rename *, lower
*keep

// prepare data

*gen some_var = ...
*note some_var: based on [original vars] \ dummy_dta01.do \ [author] TS

*compress
*note: dummy##.dta \ [description] \ dummy_dta01.do \ [author] TS 
*label data [description]
*datasignature set, reset
*save dummy##.dta, replace

log close
exit
