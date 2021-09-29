* (Versión Stata 12)
clear
set more off
*________________________________________________________________________________________________________________*

 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: ${censusFolder}
 * Se tiene acceso al servidor únicamente al interior del BID.
 *________________________________________________________________________________________________________________*
 
*Population and Housing Censuses/Harmonized Censuses - IPUMS

global ruta = "${censusFolder}"
local PAIS ARG
local ANO "1970"

local log_file = "$ruta\harmonized\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID.log"
local base_in  = "$ruta\census\\`PAIS'\\`ANO'\data_merge\\`PAIS'_`ANO'_IPUMS.dta"
local base_out = "$ruta\harmonized\\`PAIS'\data_arm\\`PAIS'_`ANO'_censusBID.dta"
                                                    
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Argentina
Año:
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

use "`base_in'", clear


****************
* region_BID_c *
****************
	
gen region_BID_c=.

label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c

*********
*edad_ci*
*********
	
rename age edad_ci

****************************
***VARIABLES DE EDUCACION***
****************************

*********
*aedu_ci* // años de educacion aprobados
*********
*NOTA: Como terciario, universitario y posgrado tienen una duración variable se supone 
*que terciario completo implica 3 años de educacion adicional a la secundaria, universitario 5 años adicionales y 
*postgrado 7. Esto solo se basa en la modas de finalización de estos niveles. ESTO SE DEBE DISCUTIR 

gen aedu_ci=0 if yrschool==0 // none or pre-school
replace aedu_ci=1 if yrschool==1
replace aedu_ci=2 if yrschool==2
replace aedu_ci=3 if yrschool==3
replace aedu_ci=4 if yrschool==4
replace aedu_ci=5 if yrschool==5
replace aedu_ci=6 if yrschool==6
replace aedu_ci=7 if yrschool==7
replace aedu_ci=8 if yrschool==8
replace aedu_ci=9 if yrschool==9
replace aedu_ci=10 if yrschool==10
replace aedu_ci=11 if yrschool==11
replace aedu_ci=12 if yrschool==12
replace aedu_ci=13 if yrschool==13
replace aedu_ci=14 if yrschool==14
replace aedu_ci=15 if yrschool==15
replace aedu_ci=16 if yrschool==16
replace aedu_ci=17 if yrschool==17
replace aedu_ci=18 if yrschool==18 // 18 or more
replace aedu_ci=. if yrschool==98 | yrschool==99 // unknown/missing or NIU

label var aedu_ci "Años de educacion aprobados"
	
**********
*eduno_ci* // no ha completado ningún año de educación // Para esta variable no se puede usar aedu_ci porque aedu_ci=0 es none o pre-school
**********
	
gen eduno_ci=(educar==110) // never attended
replace eduno_ci=. if educar==0 | educar==999 // NIU & missing
	
**********
*edupi_ci* // no completó la educación primaria
**********
	
gen edupi_ci=(educar==130 | educar==210 | educar==220 | educar==230 | educar==240 | educar==250 | educar=280) // primary (zero years completed) + grade 1-5 + primary grade unknown
replace edupi_ci=. if educar==0 | educar==999 // NIU & missing

********** 
*edupc_ci* // completó la educación primaria
**********
	
gen edupc_ci=(educar==260 | educar==270) // grade 6 + grade 7
replace edupc_ci=. if educar==0 | educar==999 // NIU & missing

**********
*edusi_ci* // no completó la educación secundaria
**********
	
gen edusi_ci=(aedu_ci>=8 & aedu_ci<=11) // 8 a 11 anos de educación
replace edusi_ci=. if educar==0 | educar==999 // NIU & missing

**********
*edusc_ci* // completó la educación secundaria
**********
	
gen edusc_ci=(aedu_ci==12 | aedu_ci==13) // 12 y 13 anos de educación
replace edusc_ci=. if educar==0 | educar==999 // NIU & missing

**********
*eduui_ci* // no completó la educación universitaria o terciaria
**********
	
gen eduui_ci=(aedu_ci>=14 & aedu_ci<=16) // 14 a 16 anos de educación
replace eduui_ci=. if educar==0 | educar==999 // NIU & missing

**********
*eduuc_ci* // completó la educación universitaria o terciaria
**********
	
gen eduuc_ci=(aedu_ci==17 | aedu_ci==18) // 17 y 18 anos de educación
replace eduuc_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

***********
*edus1i_ci* // no completó el primer ciclo de la educación secundaria
***********

gen byte edus1i_ci=(aedu_ci==8)
replace edus1c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

***********
*edus1c_ci* // completó el primer ciclo de la educación secundaria
***********
	
gen byte edus1c_ci=(aedu_ci==9)
replace edus1c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

***********
*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
***********

gen byte edus2i_ci=.

***********
*edus2c_ci* // completó el segundo ciclo de la educación secundaria
***********

gen byte edus2c_ci=.

***********
*asiste_ci*
***********
	
gen asiste_ci=(school==1) // 0 includes NIU (0), attended in the past (3), never attended (4) and unknown/missing (9)
replace asiste_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing
	
*Other variables

************
* literacy *
************

gen literacy=(lit==2) // 0 includes illiterate (1), NIU(0) and unknown/missing (9)
replace literacy=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

compress

save "`base_out'", replace 
log close