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
País: Uruguay
Año: 2011
Autores: Cesar Lins y Nathalia Maya
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS URY
local ANO "2011"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
include "../Base/base.do"


*****************************************************
******* Variables specific for this census **********
*****************************************************
****** REGION *****************
gen region_c=geo1_uy2011
label define region_c ///
           1 "Montevideo" ///
           2 "Artigas" /// 
           3 "Canelones" /// 
           4 "Cerro Largo" /// 
           5 "Colonia" /// 
           6 "Durazno" /// 
           7 "Flores" /// 
           8 "Florida" /// 
           9 "Lavalleja" /// 
          10 "Maldonado" /// 
          11 "Paysandú" /// 
          12 "Río Negro" /// 
          13 "Rivera" /// 
          14 "Rocha" /// 
          15 "Salto" /// 
          16 "San José" /// 
          17 "Soriano" /// 
          18 "Tacuarembó" ///
          19 "Treinta y Tres" 
label values region_c region_c
*******************************

*** Ingreso ******************
* Uruguay no tiene ninguna
* variable de ingreso en IPUMS
******************************

***** Education **************
* Use educuy. No está yrschool
******************************
*La variable de educuy solo reporta los ciclos completos. Algunas variables 
*no se pueden calcular. Se crean con missings.

*********
*aedu_ci* // años de educacion aprobados
*********
gen aedu_ci=.

**************
***eduno_ci***
**************


gen eduno_ci=(educuy==100 | educuy==200)
replace eduno_ci=. if educuy==0 | educuy==998

***************
***edupre_ci***
***************

gen edupre_ci=(educuy==200)
replace edupre_ci=. if educuy==0 | educuy==998


**************
***edupi_ci***
**************

gen edupi_ci=.

**************
***edupc_ci***
**************

gen edupc_ci=(educuy==300)
replace edupc_ci=. if educuy==0 | educuy==998


**************
***edusi_ci***
**************

gen edusi_ci=.


**************
***edusc_ci***
**************

gen edusc_ci=(educuy==410)
replace edusc_ci=. if educuy==0 | educuy==998


**************
***eduui_ci***
**************

gen eduui_ci=.

***************
***eduuc_ci***
***************

gen eduuc_ci= (educuy>=500 & educuy<=800)
replace eduuc_ci=. if educuy==0 | educuy==998


***************
***edus1i_ci***
***************

gen edus1i_ci=.

***************
***edus1c_ci***
***************

gen edus1c_ci=(educuy==400)
replace edus1c_ci=. if educuy==0 | educuy==998

***************
***edus2i_ci***
***************

gen edus2i_ci=.


***************
***edus2c_ci***
***************

gen edus2c_ci=(educuy==410)
replace edus2c_ci=. if educuy==0 | educuy==998


***********
*asiste_ci*
***********
gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
replace asiste_ci=. if school==9 // missing a los NIU & missing

************
* literacy *
************
gen literacy=. 
replace literacy=1 if lit==2 // literate
replace literacy=0 if lit==1 // illiterate


*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Cesar Lins & Nathalia Maya - Septiembre 2021	

			
	***************
	***afroind_ci***
	***************
**Pregunta: 

gen afroind_ci=. 
replace afroind_ci=1  if race == 30 | race==52
replace afroind_ci=2 if race == 20 | race == 56 /* two or more races */
replace afroind_ci=3 if race == 10 | race == 40 | race == 60


	***************
	***afroind_ch***
	***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=2006

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


compress

save "`base_out'", replace 
log close

