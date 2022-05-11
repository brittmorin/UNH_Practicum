. 
. use mediation_alldates, clear

. 
. capture program drop ml_mediation

. program ml_mediation, rclass
  1. *! version .9 -- pbe -- 10/4/11
.   version 11.0
  2.   syntax, dv(varname max=1) iv(varname max=1) mv(varname max=1) ///
>           l2id(varname max=1) l3id(varname max=1) [ cv(varlist fv) mle ]
  3.           
.    local meth "reml"
  4.    if "`mle'"~="" {
  5.      local meth "mle"
  6.    }
  7.           
.   /* is the mv level 2 ? */
.   tempvar mvsd
  8.   egen `mvsd'=sd(`mv'), by(`l2id')
  9.   quietly sum `mvsd'
 10.   local mvl "1"
 11.   if r(max)==0 & r(min)==0 {
 12.     local mvl "2"
 13.   }
 14.   
.   display
 15.   display as res "Equation 1 (c_path): `dv' = `iv' `cv'"
 16.   xtmixed `dv' `iv' `cv' || `l3id': || `l2id':, `meth' iterate(20)
 17.   local c_path = _b[`iv']
 18.   
.   display
 19.   display as res "Equation 2 (a_path): `mv' = `iv' `cv'"  
 20.   
.   if "`mvl'"=="1" {
 21.     xtmixed `mv' `iv' `cv' || `l3id': || `l2id':, `meth' iterate(20)
 22.   }
 23.   if "`mvl'"=="2" {
 24.     xtreg `mv' `iv' `cv', i(`l2id') be
 25.   }
 26.   local a_path = _b[`iv']
 27.   display
 28.   display as res "Equation 3 (b_path & c_prime): `dv' = `mv' `iv' `cv'"
 29.   xtmixed `dv' `mv' `iv' `cv' || `l3id': || `l2id':, `mle' iterate(20)
 30.   local b_path = _b[`mv']
 31.   local c_prime = _b[`iv']
 32.   local ind_eff = `a_path'*`b_path'
 33.   local tot_eff = `ind_eff' + `c_prime'
 34.   
.   display
 35.   display as txt "The mediator, " as res "`mv'" as txt ", is a level `mvl'
>  variable"
 36.   display as txt "c_path  = " as res `c_path'
 37.   display as txt "a_path  = " as res `a_path'
 38.   display as txt "b_path  = " as res `b_path'
 39.   display as txt "c_prime = " as res `c_prime' as txt "  same as dir_eff" 
 40.   display as txt "ind_eff = " as res `ind_eff'
 41.   display as txt "dir_eff = " as res `c_prime'
 42.   display as txt "tot_eff = " as res `tot_eff'
 43.   display
 44.   local ind2tot = `ind_eff'/`tot_eff'
 45.   local ind2dir = `ind_eff'/`c_prime'
 46.   local tot2dir = `tot_eff'/`c_prime'
 47.   display as txt "proportion of total effect mediated = " as res `ind2tot'
 48.   display as txt "ratio of indirect to direct effect  = " as res `ind2dir'
 49.   display as txt "ratio of total to direct effect     = " as res `tot2dir'
 50.   
.   return scalar c_path  = `c_path'
 51.   return scalar a_path  = `a_path'
 52.   return scalar b_path  = `b_path' 
 53.   return scalar ind_eff = `a_path'*`b_path'
 54.   return scalar dir_eff = `c_prime'
 55.   return scalar tot_eff = `tot_eff'
 56. end

. 
. ml_mediation, dv(caseRate) iv(z_trump) mv(z_dist1_lag_wk23) cv(state_policy2 
> demgov2 weekend2 z_median_household_income_2018 z_medianage_county_2018 z_pct
> _age0to17 z_pct_age65to84 z_pct_age85plus z_difflifeexp z_pop_density z_super
> markets z_supermarketsLow region2 region3 region4 z_religion z_percentEmploye
> d z_gini z_avgtimetowork z_perc_black z_perc_asian z_perc_hisplatin) l3id(sta
> te_fips) l2id(county_fips) mle

Equation 1 (c_path): caseRate = z_trump state_policy2 demgov2 weekend2 z_median
> _household_income_2018 z_medianage_county_2018 z_pct_age0to17 z_pct_age65to84
>  z_pct_age85plus z_difflifeexp z_pop_density z_supermarkets z_supermarketsLow
>  region2 region3 region4 z_religion z_percentEmployed z_gini z_avgtimetowork 
> z_perc_black z_perc_asian z_perc_hisplatin