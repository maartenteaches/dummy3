// prepare missing values

mvdecode *, mv(-99=.d \ -98=.e \ -97=.f \ -96=.n \ -95=.l \ -94=.m) 
foreach lab in sex educ yesno_lb pvoc health_lb book_lb {
	label define `lab' .d "don't know" ///
				       .e "refused" ///
				       .f "filter"  ///
				       .n "data error" ///
				       .l "illegible" ///
				       .m "multiple answers", modify
}