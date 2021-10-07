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
Año: 2000
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS BRA
local ANO "2000"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
include "../Base/base.do"


*****************************************************
******* Variables specific for this census **********
*****************************************************

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
gen afroind_ano_c=1990

********************
*** discapacidad ***
********************
gen dis_ci=.
gen dis_ch=.

*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

*********
*edad_ci*
*********
	
rename age edad_ci

****************************
***	VARIABLES EDUCATIVAS ***
****************************

*********
*aedu_ci* // años de educacion aprobados
*********

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
replace aedu_ci=. if yrschool==98 | yrschool==99 | yrschool==95 // unknown/missing or NIU + 95=adult literacy (de acuerdo a los documentos de EDU primaria completa es 4 anos en BRA y según la base if yrschool==95, then edattaind==Some primary complete; however, we don't know how many).
replace aedu_ci==. if educbr==3900 // secondary, grade unspecified

label var aedu_ci "Años de educacion aprobados"

**********
*eduno_ci* // no ha completado ningún año de educación // Para esta variable no se puede usar aedu_ci porque aedu_ci=0 es none o pre-school
**********
	
gen eduno_ci=(aedu_ci==0 & educbr!=1200 & educbr!=1700 & educbr!=4130 & educbr!=2900) // none

***************
***edupre_ci***
***************
gen byte edupre_ci=(educbr==1200) // pre-school
label variable edupre_ci "Educacion preescolar"
	
**********
*edupi_ci* // no completó la educación primaria
**********
	
gen edupi_ci=(aedu_ci>=1 & aedu_ci<=7 | educbr==1700 | educbr==2900) // 1 a 7 anos de educación + attending first grade + primary grade unspecified

********** 
*edupc_ci* // completó la educación primaria
**********
	
gen edupc_ci=(aedu_ci==8) // 8 anos de educación

**********
*edusi_ci* // no completó la educación secundaria
**********
	
gen edusi_ci=(aedu_ci==9 | aedu_ci==10) // 9 y 10 anos de educación

**********
*edusc_ci* // completó la educación secundaria
**********
	
gen edusc_ci=(aedu_ci==11) // 11 anos de educación

**********
*eduui_ci* // no completó la educación universitaria o terciaria
**********
	
gen eduui_ci=(aedu_ci>=12 & aedu_ci<=14) // some college completed + anos 15 de educación que aparece como universitario completo pero no lo sería

**********
*eduuc_ci* // completó la educación universitaria o terciaria
**********
	
gen eduuc_ci=(aedu_ci==15 | aedu_ci==16 | aedu_ci==17) // 15 a 17 anos de educación

***********
*edus1i_ci* // no completó el primer ciclo de la educación secundaria
***********

gen byte edus1c_ci=.

***********
*edus1c_ci* // completó el primer ciclo de la educación secundaria
***********
	
gen byte edus1c_ci=.

***********
*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
***********

gen byte edus2i_ci=.

***********
*edus2c_ci* // completó el segundo ciclo de la educación secundaria
***********

gen byte edus2c_ci=.

**************
**asiste_ci***
**************

gen asiste_ci=(school==1) // 0 includes NIU (0), attended in the past (3), never attended (4) and unknown/missing (9)
replace asiste_ci=. if edattaind==0 // missing a los NIU & missing
label var asiste_ci "Personas que actualmente asisten a un centro de enseñanza"
	
*Other variables

************
* literacy *
************

gen literacy=(lit==2) // 0 includes illiterate (1), NIU(0) and unknown/missing (9)
replace literacy=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

compress

save "`base_out'", replace 
log close
