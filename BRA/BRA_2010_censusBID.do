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


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Brasil
Año: 2010
Autores: Cesar Lins
Última versión: Septiembre, 2021
							SCL/LMK - IADB
****************************************************************************/


local PAIS BRA
local ANO "2010"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
include "../Base/base.do"


*****************************************************
******* Variables specific for this census **********
*****************************************************

****************
 *** region_c ***
 ****************
 
 gen region_c=.
 replace region_c=1 if geo1_br ==76011  /*Rondônia*/
 replace region_c=2 if geo1_br ==76012  /*Acre*/
 replace region_c=3 if geo1_br ==76013 /*Amazonas*/
 replace region_c=4 if geo1_br ==76014 /*Roraima*/
 replace region_c=5 if geo1_br ==76015 /*Pará*/
 replace region_c=6 if geo1_br ==76016 /*Amapá*/
 replace region_c=7 if geo1_br ==76017 /*Tocantins*/
 replace region_c=8 if geo1_br ==76021 /*Maranhão*/
 replace region_c=9 if geo1_br ==76022 /*Piauí*/
 replace region_c=10 if geo1_br ==76023 /*Ceará*/
 replace region_c=11 if geo1_br ==76024 /*Rio Grande do Norte*/
 replace region_c=12 if geo1_br ==76025 /*Paraíba*/
 replace region_c=13 if geo1_br ==76026 /*Pernambuco*/
 replace region_c=14 if geo1_br ==76027 /*Alagoas*/
 replace region_c=15 if geo1_br ==76028 /*Sergipe*/
 replace region_c=16 if geo1_br ==76029 /*Bahia*/
 replace region_c=17 if geo1_br ==76031 /*Minas Gerais*/
 replace region_c=18 if geo1_br ==76032 /*Espírito Santo*/
 replace region_c=19 if geo1_br ==76033 /*Rio de Janeiro*/
 replace region_c=20 if geo1_br ==76035 /*São Paulo*/
 replace region_c=21 if geo1_br ==76041 /*Paraná*/
 replace region_c=22 if geo1_br ==76042 /*Santa Catarina*/
 replace region_c=23 if geo1_br ==76043 /*Rio Grande do Sul*/
 replace region_c=24 if geo1_br ==76050 /*Mato Grosso do Sul*/
 replace region_c=25 if geo1_br ==76051 /*Mato Grosso*/
 replace region_c=26 if geo1_br ==76052 /*Goiás*/
 replace region_c=27 if geo1_br ==76053 /*Distrito Federal*/

 label define region_c 1"Rondônia" 2"Acre" 3"Amazonas" 4"Roraima" 5"Pará" 6"Amapá" 7"Tocantins" 8"Maranhão" 9"Piauí" 10"Ceará" 11"Rio Grande do Norte" 12"Paraíba" 13"Pernambuco" 14"Alagoas" 15"Sergipe" 16"Bahia" 17"Minas Gerais" 18"Espírito Santo" 19"Rio de Janeiro" 20"São Paulo" 21"Paraná" 22"Santa Catarina" 23"Rio Grande do Sul" 24"Mato Grosso do Sul" 25"Mato Grosso" 26"Goiás" 27"Distrito Federal"
label values region_c region_c 
 
**********************************
**** VARIABLES DE INGRESO ****
**********************************
	
     ***********
	  *ylm_ci*
	 ***********
   cap confirm variable incearn
   if (_rc==0) {
   replace ylm_ci = incearn
   replace ylm_ci =. if incearn==99999999 | incearn==99999998
   }

	 *********
	 *ynlm_ci*
	 *********
   replace ynlm_ci=.
   
     ***********
	  *ylm_ch*
	 ***********
   
   by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
   
    ***********
	  *ynlm_ch*
	 ***********
   gen ynlm_ch=.
   
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
**Pregunta: 

gen afroind_ci=. 
replace afroind_ci=1  if race == 30
replace afroind_ci=2 if race == 20 | race == 51 
replace afroind_ci=3 if race == 10 | race == 40 
replace afroind_ci=. if race == 99

	***************
	***afroind_ch***
	***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(serial) 

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=1960

********************
*** discapacidad ***
********************
gen dis_ci=.
gen dis_ch=.

****************************
***	VARIABLES EDUCATIVAS ***
****************************

**************
**asiste_ci***
**************

gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
replace asiste_ci=. if school==0 | school==9 | school==. // missing a los NIU & missing
	
*********
*aedu_ci* // años de educacion aprobados
*********
gen aedu_ci=yrschool
replace aedu_ci=. if yrschool>=90 
// unknown/missing or NIU + other (we don't know how many years).

**********
*eduno_ci* // no ha completado ningún año de educación
**********
gen eduno_ci=(aedu_ci==0) // none
replace eduno_ci=. if aedu_ci==.

***************
***edupre_ci***
***************
gen byte edupre_ci=. // pre-school
	
**********
*edupi_ci* // no completó la educación primaria
**********	
gen edupi_ci=(aedu_ci>=1 & aedu_ci<=4) // 1 a 4 anos de educación 
replace edupi_ci=. if aedu_ci==.

********** 
*edupc_ci* // completó la educación primaria
**********
	
gen edupc_ci=(aedu_ci==5) // 5 anos de educación
replace edupc_ci=. if aedu_ci==.

**********
*edusi_ci* // no completó la educación secundaria
**********
	
gen edusi_ci=(aedu_ci>=6 & aedu_ci<=11) // De 6 a 11 anos de educación
replace edusi_ci=. if aedu_ci==.

**********
*edusc_ci* // completó la educación secundaria
**********	
gen edusc_ci=(aedu_ci==12) // 12 anos de educación
replace edusc_ci=. if aedu_ci==.

**********
*eduui_ci* // no completó la educación universitaria o terciaria
**********
	
gen eduui_ci=(aedu_ci>=13 & aedu_ci<=15) // Entre 13 y 15 años 
replace eduui_ci=. if aedu_ci==.

**********
*eduuc_ci* // completó la educación universitaria o terciaria
**********
	
gen eduuc_ci=(aedu_ci>=16) // +15 anos de educación
replace eduuc_ci=. if aedu_ci==.

***********
*edus1i_ci* // no completó el primer ciclo de la educación secundaria
***********

gen edus1i_ci=(aedu_ci>=6 & aedu_ci<=8) // De 6 a 8 anos de educación
replace edus1i_ci=. if aedu_ci==.

***********
*edus1c_ci* // completó el primer ciclo de la educación secundaria
***********

gen edus1c_ci=(aedu_ci==9) // 9 anos de educación
replace edus1c_ci=. if aedu_ci==.

***********
*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
***********

gen edus2i_ci=(aedu_ci>=10 & aedu_ci<=11) // De 10 a 11 anos de educación
replace edus2i_ci=. if aedu_ci==.

***********
*edus2c_ci* // completó el segundo ciclo de la educación secundaria
***********

gen edus2c_ci=(aedu_ci==12) // 12 anos de educación
replace edus2c_ci=. if aedu_ci==.


*Other variables

************
* literacy *
************

gen literacy=1 if lit==2 // literate
replace literacy=0 if lit==1 // illiterate



*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"


compress

save "`base_out'", replace 
log close