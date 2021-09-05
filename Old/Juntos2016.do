

clear all
set more off
cd "C:\Users\David\Desktop\CV\MacroConsult\Bases de datos\Módulos"

*	Cuadros años de educación promedio 2015-2016
*Año 2016
use modulo300.dta, clear
	keep ubigeo p301a
	rename p301a educacion

gen depa = substr(ubigeo,1,2)
destring depa, replace
label var depa "Departamento"
label define depa_eti 	1 "Amazonas" 2 "Ancash" 3 "Apurímac" 4 "Arequipa" ///
						5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" ///
						9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 "Junín" ///
						13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" ///
						17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" ///
						21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" ///
						25 "Ucayali"
label values depa depa_eti

*Años de educación
	generate años_edu_16 = .
		replace años_edu_16 = 0 if educacion == 1
		replace años_edu_16 = 2 if educacion == 2
		replace años_edu_16 = 5 if educacion == 3
		replace años_edu_16 = 8 if educacion == 4
		replace años_edu_16 = 10.5 if educacion == 5
		replace años_edu_16 = 13 if educacion == 6
		replace años_edu_16 = 14.5 if educacion == 7
		replace años_edu_16 = 16 if educacion == 8
		replace años_edu_16 = 15.5 if educacion == 9
		replace años_edu_16 = 18 if educacion == 10
		replace años_edu_16 = 20 if educacion == 11
label var años_edu_16 "Años de educación"
save años_edu_16.dta, replace

collapse (mean) años_edu_16, by(depa)
save años_promedio_16.dta, replace

*Año 2015
use modulo300_15.dta, clear
	keep ubigeo p301a
	rename p301a educacion

gen depa = substr(ubigeo,1,2)
destring depa, replace
label var depa "Departamento"
label define depa_eti 	1 "Amazonas" 2 "Ancash" 3 "Apurímac" 4 "Arequipa" ///
						5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" ///
						9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 "Junín" ///
						13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" ///
						17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" ///
						21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" ///
						25 "Ucayali"
label values depa depa_eti

*Años de educación
	generate años_edu_15 = .
		replace años_edu_15 = 0 if educacion == 1
		replace años_edu_15 = 2 if educacion == 2
		replace años_edu_15 = 5 if educacion == 3
		replace años_edu_15 = 8 if educacion == 4
		replace años_edu_15 = 10.5 if educacion == 5
		replace años_edu_15 = 13 if educacion == 6
		replace años_edu_15 = 14.5 if educacion == 7
		replace años_edu_15 = 16 if educacion == 8
		replace años_edu_15 = 15.5 if educacion == 9
		replace años_edu_15 = 18 if educacion == 10
		replace años_edu_15 = 20 if educacion == 11
label var años_edu_15 "Años de educación"
save años_edu_15.dta, replace

collapse (mean) años_edu_15, by(depa)
save años_promedio_15.dta, replace

* Crecimiento en años de educación
use años_promedio_16.dta, clear
merge 1:1 depa using años_promedio_15.dta
drop _merge

gen var_años = ((años_edu_16/años_edu_15)-1)*100

*Cuadro en Excel
export excel años_promedio.xls, sheet(años_ed) firstrow(var) sheetreplace

************************************************************
*					Experimento Aleatorio

clear all
use modulo400.dta, clear

*								Variables control

*Necesidades básicas insatisfechas
merge m:m hogar vivienda conglome using modulo100.dta, keepusing(altitud nbi1 nbi2 nbi3 nbi4 nbi5)
drop _merge 
*Educación
merge m:m hogar vivienda conglome using modulo300.dta, keepusing(p301a)
drop _merge
*Condiciones de pobreza, pobreza extrema y el total de miembros del hogar
merge m:m hogar vivienda conglome using sumaria.dta, keepusing(pobreza mieperho)
drop _merge 

*								Programa Juntos

*Programa JUNTOS
merge m:m hogar vivienda conglome using modulo500.dta, keepusing(p5566a)
drop _merge


keep estrato p207 p301a p203 p5566a pobreza p4191 p4192 p4193 p4194 ///
			 p4195 p4196 p4197 p4198 p208a mieperho nbi1 nbi2 nbi3 ///
			 nbi4 nbi5 altitud

*Definimos la variable JUNTOS a partir de si recibe o no transferencias
gen juntos=.
replace juntos=1 if p5566a==1
replace juntos=0 if p5566a==2

label var juntos "Juntos"
label define juntos_eti 1 "Beneficiario" 0 "No Beneficiario"
label values juntos juntos_eti

*Deserción escolar
gen desertor=0
replace desertor=1 if p301a<=5

label var desertor "Deserción"
label define desertor_eti 1 "Sí" 0 "No"
label values desertor desertor_eti			 

save baseinicial.dta, replace
tab juntos if pobreza==1

*Base de datos de solo beneficiarios (tratamiento)
keep if juntos==1 & pobreza==1
save juntos.dta ,replace

*Grupo control
use baseinicial.dta, clear
keep if juntos==0 & pobreza==1

gen random= rnormal(0,1) 
sort random
gen id = _n
*Número de beneficiarios obtenidos de la muestra
keep if id <= 1195
save nojuntos.dta, replace
append using juntos.dta

* Test de diferencia de medias
ttest desertor, by(juntos)

save basemodificada.dta, replace
			 
*****************************************************************
*						Variables instrumentales

use baseinicial.dta, clear
	 
*Área rural o urbana
gen rural=.
replace rural=1 if estrato>=6
replace rural=0 if estrato<=5

label var rural "Procedencia"
label define rural_eti 1 "Sí" 0 "No"
label values rural rural_eti

*Sexo
gen sexo=.
replace sexo=1 if p207==2
replace sexo=0 if p207==1

label var sexo "Sexo"
label define sexo_eti 1 "Mujer" 0 "Hombre"
label values sexo sexo_eti

*Jefe del hogar con primaria completa
gen edupadre=0
replace edupadre=1 if  p301a>=4 & p203==1

label var edupadre "Primaria del Padre"
label define edupadre_eti 1 "Completa" 0 "Incompleta"
label values edupadre edupadre_eti

*Pobre o no pobre
gen pobre=0
replace pobre=1 if pobreza<=2

label var pobre "Pobre"
label define pobre_eti 1 "Pobre" 0 "No Pobre"
label values pobre pobre_eti

*Seguro
gen seguro=0
replace seguro=1 if p4191==1 | p4192==1 | p4193==1 |p4194==1 | p4195==1 | p4196==1 | p4197==1 | p4198==1 

*Condición de pobreza o pobreza extrema
gen cpobreza=.
replace cpobreza=1 if pobreza==1
replace cpobreza=0 if pobreza==2

label var cpobreza "Nivel de Pobreza"
label define cpobreza_eti 1 "Pobre Extremo" 0 "Pobre"
label values cpobreza cpobreza_eti

*Edad
gen edad=p208a

*Tamaño de familia
gen tfamilia=mieperho

*Necesidades básicas insatisfechas
gen nbasica=0
replace nbasica=1 if nbi1==1 | nbi2==1 | nbi3==1 | nbi4==1 | nbi5==1 

label var nbasica "Necesidad Insatisfecha"
label define nbasica_eti 1 "Sí" 0 "No"
label values nbasica nbasica_eti

*Utilizando el método por 2 etapas Por 2SLS, solo para la población en condición de pobreza:
ivregress 2sls desertor cpobreza seguro nbasica tfamilia edad (juntos=altitud) if pobreza==1

save baseinicial2.dta, replace
*****************************************************************
*				Regresión por mínimos cuadrados

use baseinicial2.dta, clear

reg desertor juntos cpobreza seguro nbasica tfamilia edad if pobreza==1

*Detección de heterocedasticidad y autocorrelación
*Test de Breusch-Pagan
hettest
*Test de White
imtest, white

*Matriz robusta
reg  desertor juntos cpobreza seguro nbasica tfamilia edad, robust


*					PROPENSTITY SCORE MATCHING

use baseinicial2.dta, replace
pscore desertor cpobreza seguro tfamilia rural, pscore(ps98)
 
