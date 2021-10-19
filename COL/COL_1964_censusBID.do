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
País: Colombia
Año:
Autores: 
Última versión: 
							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

local PAIS COL
local ANO "1964"

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

gen region_c =.
replace region_c=1 if geo1_co1964 ==5 /*Antioquia*/ 
replace region_c=2 if geo1_co1964 ==8 /*Atlántico*/ 
replace region_c=3 if geo1_co1964 ==11 /*Bogotá*/ 
replace region_c=4 if geo1_co1964 ==13 /*Bolívar*/ 
replace region_c=5 if geo1_co1964 ==15 /*Boyacá*/ 
replace region_c=6 if geo1_co1964 ==17 /*Caldas*/ 
replace region_c=7 if geo1_co1964 ==18 /*Caquetá*/ 
replace region_c=8 if geo1_co1964 ==19 /*Cauca*/ 
replace region_c=9 if geo1_co1964 ==20 /*Cesar*/ 
replace region_c=10 if geo1_co1964 ==23 /*Córdoba*/ 
replace region_c=11 if geo1_co1964 ==25 /*Cundinamarca*/ 
replace region_c=12 if geo1_co1964 ==27 /*Chocó*/ 
replace region_c=13 if geo1_co1964 ==41 /*Huila*/ 
replace region_c=14 if geo1_co1964 ==44 /*La Guajira*/
replace region_c=15 if geo1_co1964 ==47 /*Magdalena*/ 
replace region_c=16 if geo1_co1964 ==50 /*Meta*/ 
replace region_c=17 if geo1_co1964 ==52 /*Nariño*/ 
replace region_c=18 if geo1_co1964 ==54/*Norte de Santander*/ 
replace region_c=19 if geo1_co1964 ==63 /*Quindío*/ 
replace region_c=20 if geo1_co1964 ==66 /*Risaralda*/ 
replace region_c=21 if geo1_co1964 ==68 /*Santander*/ 
replace region_c=22 if geo1_co1964 ==70 /*Sucre*/ 
replace region_c=23 if geo1_co1964 ==73 /*Tolima*/ 
replace region_c=24 if geo1_co1964 ==76 /*Valle*/ 
replace region_c=25 if geo1_co1964 ==81 /*Arauca*/ 
replace region_c=26 if geo1_co1964 ==85 /*Casanare*/ 
replace region_c=27 if geo1_co1964 ==86 /*Putumayo*/ 
replace region_c=28 if geo1_co1964 ==88 /*San Andrés*/ 
replace region_c=29 if geo1_co1964 ==95 /*Amazonas, Guaviare, Vaupes, Vichada, Guania*/ 

label define region_c 1"Antioquia" 2"Atlántico" 3"Bogotá" 4"Bolívar" 5"Boyacá" 6"Caldas" 7"Caquetá" 8"Cauca" 9"Cesár" 10"Córdoba" 11"Cundinamarca" 12"Chocó" 13"Huila" 14"La Guajira" 15"Magdalena" 16"Meta" 17"Nariño" 18"Norte de Santander" 19"Quindío" 20"Risaralda" 21"Santander" 22"Sucre" 23"Tolima" 24"Valle" 25"Arauca" 26"Casanare" 27"Putumayo" 28"San Andrés" 29"Amazonas, Guaviare, Vaupes, Vichada, Guania"	
label value region_c region_c

********************************
*** Health indicators **********
********************************
	gen discapacidad_ci =.
	label var discapacidad_ci "Discapacidad"

	gen ceguera_ci=.
	label var ceguera_ci "Ciego o con discpacidad visual"
	
	gen sordera_ci  =.
	label var sordera_ci "Sordera o con discpacidad auditiva"

	gen mudez_ci=.
	label var mudez_ci "Mudo o con discpacidad de lenguaje"

	gen dismental_ci=.
	label var dismental_ci "Discapacidad mental"

	***********************************
	***    VARIABLES DE MIGRACIÓN.  ***
	***********************************	

      *******************
      ****migrante_ci****
      *******************
	gen migrante_ci = (nativity == 2)
	 
      *******************
      **migantiguo5_ci***
      *******************
	gen migantiguo5_ci = (migyrs1 >= 5) & migrante_ci == 1
	replace migantiguo5_ci = . if migantiguo5_ci == 0 & nativity != 2
	
	**********************
	*** migrantelac_ci ***
	**********************
	
	gen migrantelac_ci= 1 if inlist(bplcountry, 21100, 23010, 22060, 23110, 22020, 22040, 23100, 22030, 23060, 23140, 22050, 23040, 23100, 29999, 23130, 23030, 21250, 21999, 22010, 22070, 22080, 22999)
	replace migrantelac_ci = 0 if migrantelac_ci == . & nativity == 2

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
replace aedu_ci=5 if yrschool==5 | yrschool==92 // 92=some technical after primary; primary son 5 anos y sabemos que al menos tienen 5 anos.
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
replace aedu_ci=. if yrschool==99 // NIU

**********
*eduno_ci* // no ha completado ningún año de educación
**********
	
gen eduno_ci=(aedu_ci==0) // none (incluye preescolar)
replace eduno_ci=. if aedu_ci==. // NIU

***************
***edupre_ci***
***************

gen byte edupre_ci=(educco==110) // pre-school
replace edupre_ci=. if aedu_ci==. // NIU
	
**********
*edupi_ci* // no completó la educación primaria
**********
	
gen edupi_ci=(aedu_ci>=1 & aedu_ci<=4) // 1-4 anos de educación
replace edupi_ci=. if aedu_ci==. // NIU

********** 
*edupc_ci* // completó la educación primaria
**********
	
gen edupc_ci=(aedu_ci==5) // 5 anos de educación
replace edupc_ci=. if aedu_ci==. // NIU

**********
*edusi_ci* // no completó la educación secundaria
**********
	
gen edusi_ci=(aedu_ci>=6 & aedu_ci<=10 | educco==380) // 6 a 10 anos de educación + secundaria con anos no especificados
replace edusi_ci=. if aedu_ci==. // NIU

**********
*edusc_ci* // completó la educación secundaria
**********
	
gen edusc_ci=(aedu_ci==11) // 11 anos de educación
replace edusc_ci=. if aedu_ci==. // NIU

**********
*eduui_ci* // no completó la educación universitaria o terciaria
**********
	
gen eduui_ci=(aedu_ci>=12 & aedu_ci<=14) // 12 a 14 anos de educación
replace eduui_ci=. if aedu_ci==. // NIU

**********
*eduuc_ci* // completó la educación universitaria o terciaria
**********
	
gen eduuc_ci=(aedu_ci>=15 & aedu_ci<=17) // 15 a 17 anos de educación
replace eduuc_ci=. if aedu_ci==. // NIU

***********
*edus1i_ci* // no completó el primer ciclo de la educación secundaria
***********

gen byte edus1i_ci=(aedu_ci>=6 & aedu_ci<9)
replace edus1i_ci=. if aedu_ci==. // NIU

***********
*edus1c_ci* // completó el primer ciclo de la educación secundaria
***********
	
gen byte edus1c_ci=(aedu_ci==9)
replace edus1c_ci=. if aedu_ci==. // NIU

***********
*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
***********

gen byte edus2i_ci=(aedu_ci==10)
replace edus2i_ci=. if aedu_ci==. // NIU

***********
*edus2c_ci* // completó el segundo ciclo de la educación secundaria
***********

gen byte edus2c_ci=(aedu_ci==11)
replace edus2c_ci=. if aedu_ci==. // NIU

***********
*asiste_ci* // la variable school no está disponible para 1964 (si para 1973, 1985 y 1993). Dejo el código armado para el resto de los años
***********

gen asiste_ci=.
	
/*
gen asiste_ci=(school==1) // 0 attended in the past (3) and never attended (4)
replace asiste_ci=. if school==0 | school==9 // missing a los NIU & missing
*/
	
*Other variables

************
* literacy *
************

gen literacy=1 if lit==2 // literate
replace literacy=0 if lit==1 // illiterate

compress

save "`base_out'", replace 
log close
