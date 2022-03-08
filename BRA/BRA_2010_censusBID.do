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
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=1960

************************
*** Discapacidad (WG)***
************************
/* Identificación de si una persona reporta por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */

gen dis_ci = 0
recode dis_ci nonmiss=. if inlist(9,br2010a_dissee,br2010a_dishear,br2010a_dismob) //
recode dis_ci nonmiss=. if br2010a_dissee>=. & br2010a_dishear>=. & br2010a_dismob>=. //
	foreach i in see hear mob {
		forvalues j=1/3 {
		replace dis_ci=1 if br2010a_dis`i'==`j'
		}
		}

/*Identificación de si un hogar tiene uno o más miembros que reportan por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */		

egen dis_ch  = sum(dis_ci), by(idh_ch) 
replace dis_ch=1 if dis_ch>=1 & dis_ch!=. 


****************************
***	VARIABLES EDUCATIVAS ***
****************************
* BRA 2010 no tiene vairables yrschool se contruye a partir de eddatain y educbr

**************
**asiste_ci***
**************

gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
replace asiste_ci=. if school==0 | school==9 | school==. // missing a los NIU & missing
	
*********
*aedu_ci* // años de educacion aprobados
*********
gen aedu_ci=.

**************
***eduno_ci***
**************

gen eduno_ci=(educbr==0000 | educbr==1100 | educbr==1200 | educbr==1300)
replace eduno_ci=. if educbr==8000 | educbr==9000

***************
***edupre_ci***
***************
gen edupre_ci=(educbr==1200) // pre-school
replace edupre_ci=. if educbr==8000 | educbr==9000
	
**********
*edupi_ci* // no completó la educación primaria
**********	
gen edupi_ci=(educbr>=1700 & educbr<=2200) // primaria incompleta
replace edupi_ci=. if educbr==8000 | educbr==9000
	
********** 
*edupc_ci* // completó la educación primaria
**********
	
gen edupc_ci=(educbr>=2200 & educbr<=2220) // primaria completa
replace edupc_ci=. if educbr==8000 | educbr==9000

**********
*edusi_ci* // no completó la educación secundaria
**********
	
gen edusi_ci=(educbr>=2230 & educbr<=3200) // más de primaria menos sec completa
replace edusi_ci=. if educbr==8000 | educbr==9000

**********
*edusc_ci* // completó la educación secundaria
**********	
gen edusc_ci=(educbr==3300) // completo sec
replace edusc_ci=. if educbr==8000 | educbr==9000

**********
*eduui_ci* // no completó la educación universitaria o terciaria
**********
	
gen eduui_ci=(educbr==4180 & edattain!=4) // asistió pero no terminó 
replace eduui_ci=. if educbr==8000 | educbr==9000

**********
*eduuc_ci* // completó la educación universitaria o terciaria
**********
	
gen eduuc_ci=((educbr>=4190 & educbr<=4280) | edattain==4) // terminó
replace eduuc_ci=. if educbr==8000 | educbr==9000

***********
*edus1i_ci* // no completó el primer ciclo de la educación secundaria
***********

gen edus1i_ci=.

***********
*edus1c_ci* // completó el primer ciclo de la educación secundaria
***********

gen edus1c_ci=.

***********
*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
***********

gen edus2i_ci=.

***********
*edus2c_ci* // completó el segundo ciclo de la educación secundaria
***********

gen edus2c_ci=(educbr==3300) // completó secundaria
replace edus2c_ci=.  if educbr==8000 | educbr==9000


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
