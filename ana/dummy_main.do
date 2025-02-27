version 18
clear all
macro drop _all

// use only community contributed packages from 
// the ado directory local to this project
*cd "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy\"
*cd "h:\open_science\dummy\"
cd "c:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy\"

sysdir set PLUS     "`c(pwd)'/ado/plus"
sysdir set PERSONAL "`c(pwd)'/ado/personal"
sysdir set OLDPLACE "`c(pwd)'/ado"
mata: mata mlib index

// set the working directory
cd ana

do dummy_dta01.do // education variables
do dummy_dta02.do // non-education variables
do dummy_dta03.do // combine sub-datasets into analysis dataset
do dummy_ana01.do // descriptives
do dummy_ana02.do // multivariate

exit
