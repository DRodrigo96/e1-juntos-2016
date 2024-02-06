* main.do
* ==================================================
* SETTINGS
* --------------------------------------------------
* encoding
* --------------------------------------------------
clear all
set more off
global cwd "/path/to/working/directory/e1-juntos-2016/"

cd "$cwd/data"
quietly {
  foreach x in enaho01a-2015-300 enaho01a-2016-300 enaho01-2016-700 sumaria-2016 {
    unicode analyze "`x'.dta"
    unicode encoding set "ISO-8859-1"
    unicode translate "`x'.dta"
  }
}
* references
* --------------------------------------------------
clear all
set more off

global a "scripts"
global b "data"
global c "temp"
global d "resources"

cd "$cwd"
* --------------------------------------------------


* MAIN SCRIPT
* ==================================================
* DATASETS & FEATURES
* --------------------------------------------------
* appended dataset for education 2015-2016
* --------------------------------------------------
foreach x in 15 16 {
  use "$b/enaho01a-20`x'-300.dta", clear
  gen year = 20`x'
  keep year conglome vivienda hogar codperso ubigeo dominio estrato codinfor p208a p301a p306 p301c p301b fac*
  save "$c/mod300_20`x'.dta", replace
}

use "$c/mod300_2015.dta", clear
append using "$c/mod300_2016.dta"

save "$c/mod300_15_16.dta", replace
erase "$c/mod300_2015.dta"
erase "$c/mod300_2016.dta"

* average years of education per year
* --------------------------------------------------
use "$c/mod300_15_16.dta", clear
gen depa = substr(ubigeo,1,2)
destring depa, replace

quietly {
  #delimit;
    label define depa_eti
    1  "Amazonas"
    2  "Ancash"
    3  "Apurímac"
    4  "Arequipa"
    5  "Ayacucho"
    6  "Cajamarca"
    7  "Callao"
    8  "Cusco"
    9  "Huancavelica"
    10 "Huánuco"
    11 "Ica"
    12 "Junín"
    13 "La Libertad"
    14 "Lambayeque"
    15 "Lima"
    16 "Loreto"
    17 "Madre de Dios"
    18 "Moquegua"
    19 "Pasco"
    20 "Piura"
    21 "Puno"
    22 "San Martín"
    23 "Tacna"
    24 "Tumbes"
    25 "Ucayali";
  #delimit cr
  
  label values depa depa_eti
  
  replace p301c = 0 if p301a == 3 | p301b ~= . | p301c == .
  
  capture gen a_edu = 0                 if p301a == 1
  replace a_edu = 1                     if p301a == 2
  replace a_edu = p301b + p301c         if p301a == 3
  replace a_edu = 1 + 6                 if p301a == 4
  replace a_edu = 1 + 6 + p301b         if p301a == 5
  replace a_edu = 1 + 6 + 5             if p301a == 6
  replace a_edu = 1 + 6 + 5 + p301b     if p301a > 6 & p301a < 11
  replace a_edu = 1 + 6 + 5 + 5 + p301b if p301a == 11
}

preserve
collapse (mean) a_edu [iw = factora07], by(year depa)
reshape wide a_edu, i(depa) j(year)
gen variation = ((a_edu2016/a_edu2015)-1)*100
export excel using "$d/mean_ye.xls", sheet("results") sheetreplace firstrow(var)
restore

save "$c/mod300_15_16.dta", replace

* dataset for access to social programme
* --------------------------------------------------
use "$b/enaho01-2016-700.dta", clear
keep conglome vivienda hogar ubigeo dominio estrato p710_04

merge 1:1 conglome vivienda hogar ubigeo dominio estrato using "$b/sumaria-2016.dta", keepusing(factor07 pobreza mieperho)
drop _merge

gen year = 2016
merge 1:m year conglome vivienda hogar ubigeo dominio estrato using "$c/mod300_15_16.dta"
keep if _merge == 3
drop _merge

* treatment variable
* --------------------------------------------------
gen juntos = p710_04 == 1
label var juntos "Juntos"
label define juntos_eti 1 "Beneficiario" 0 "No Beneficiario"
label values juntos juntos_eti

* desertion variable
* --------------------------------------------------
gen desertor = (p306 == 2 & (p208a >= 5 & p208a <= 18))
replace desertor = . if (p208a < 5 | p208a > 18)

label var desertor "Condición"
label define desertor_eti 1 "Desertor" 0 "No desertor"
label values desertor desertor_eti

gen pobre = (pobreza == 1 | pobreza == 2)

sum desertor if (pobreza == 1 & juntos == 0)
sum desertor if (pobreza == 1 & juntos == 1)
sum desertor if (pobreza == 2 & juntos == 0)
sum desertor if (pobreza == 2 & juntos == 1)
sum desertor if (pobre == 1 & juntos == 0)
sum desertor if (pobre == 1 & juntos == 1)

tab juntos if pobreza == 1 & (p208a >= 5 & p208a <= 18)
tab juntos if pobreza == 2 & (p208a >= 5 & p208a <= 18)
tab juntos if pobre == 1 & (p208a >= 5 & p208a <= 18)

* random numbers
* --------------------------------------------------
merge 1:1 conglome vivienda hogar ubigeo dominio estrato codperso using "$b/random.dta"
sort random


* EXPERIMENT GROUPS
* --------------------------------------------------
* treatment group
* --------------------------------------------------
quietly {
  preserve
  keep if (p208a >= 5 & p208a <= 18)
  sum desertor if (pobreza == 1 & juntos == 0)
  keep if (juntos == 1 & pobreza == 1)
  gen num_id = _n
  keep if num_id <= 700
  drop random num_id
  save "$c/T_PE.dta", replace
  restore
  
  preserve
  keep if (p208a >= 5 & p208a <= 18)
  sum desertor if (pobre == 1 & juntos == 0)
  keep if (juntos == 1 & pobre == 1)
  gen num_id = _n
  keep if num_id <= 4000
  drop random num_id
  save "$c/T_PT.dta", replace
  restore
}

* control group
* --------------------------------------------------
quietly {
  preserve
  keep if (p208a >= 5 & p208a <= 18)
  sum desertor if (pobreza == 1 & juntos == 0)
  keep if (juntos == 0 & pobreza == 1)
  gen num_id = _n
  keep if num_id <= 700
  drop random num_id
  save "$c/C_PE.dta", replace
  restore
  
  preserve
  keep if (p208a >= 5 & p208a <= 18)
  sum desertor if (pobre == 1 & juntos == 0)
  keep if (juntos == 0 & pobre == 1)
  gen num_id = _n
  keep if num_id <= 4000
  drop random num_id
  save "$c/C_PT.dta", replace
  restore
}

* test for mean difference on extreme poverty
* --------------------------------------------------
preserve
quietly use "$c/T_PE.dta", clear
quietly append using "$c/C_PE.dta"
ttest desertor, by(juntos)
quietly {
  matrix AAA = (r(N_1), r(mu_1), r(sd_1) / r(N_2), r(mu_2), r(sd_2))
  matrix BBB = (r(p), r(mu_1) - r(mu_2), r(sd))
  putexcel set "$d/test_pt.xls", sheet("pe_results", replace) modify
  putexcel A2 = "No beneficiario"
  putexcel A3 = "Beneficiario"
  putexcel B1 = "N"
  putexcel C1 = "Mean"
  putexcel D1 = "SD"
  putexcel B4 = "p-value"
  putexcel C4 = "Diff."
  putexcel D4 = "Combined SD"
  putexcel B2 = matrix(AAA)
  putexcel B5 = matrix(BBB)
}
restore

* test for mean difference on total poverty
* --------------------------------------------------
preserve
quietly use "$c/T_PT.dta", clear
quietly append using "$c/C_PT.dta"
ttest desertor, by(juntos)
quietly {
  matrix AAA = (r(N_1), r(mu_1), r(sd_1) / r(N_2), r(mu_2), r(sd_2))
  matrix BBB = (r(p), r(mu_1) - r(mu_2), r(sd))
  putexcel set "$d/test_pt.xls", sheet("pt_results", replace) modify
  putexcel A2 = "No beneficiario"
  putexcel A3 = "Beneficiario"
  putexcel B1 = "N"
  putexcel C1 = "Mean"
  putexcel D1 = "SD"
  putexcel B4 = "p-value"
  putexcel C4 = "Diff."
  putexcel D4 = "Combined SD"
  putexcel B2 = matrix(AAA)
  putexcel B5 = matrix(BBB)
}
restore
