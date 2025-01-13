capture log close
log using dummy_ana01.txt, replace text

// What this .do file does
// Who wrote it

version 18
clear all
macro drop _all

*use dummy##.dta
*datasignature confirm
*codebook, compact

// do your analysis

log close
exit
