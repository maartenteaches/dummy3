version 18
clear all
macro drop _all

// use only community contributed packages from 
// the ado directory local to this project
cd "d:\mijn documenten\onderwijs\konstanz\stata\open_science\dummy\"
sysdir set PLUS     "`c(pwd)'/ado/plus"
sysdir set PERSONAL "`c(pwd)'/ado/personal"
sysdir set OLDPLACE "`c(pwd)'/ado"
mata: mata mlib index

// set the working directory
cd ana

do dummy_dta01.do // some comment
do dummy_ana01.do // some comment

exit
