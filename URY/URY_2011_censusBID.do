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
* ingreso por hogar se genera vacia
******************************

	***********
	**ylm_ch*
	***********
    gen ylm_ch=.
   
    ***********
	**ynlm_ch*
	***********
    gen ynlm_ch=.

***********************************************
****************** Educacion ******************
***********************************************
*Para el resto de los años se trabaja con la variable yrschool y se crea aedu_ci. Para 2011 esta informacion no esta disponible.

*************
***aedu_ci*** // años de educacion aprobados
*************
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
***edupi_ci*** // no completó la educación primaria
**************
gen edupi_ci=(educuy==300 & edattaind==120) // educuy==300 por si solo incluye individuos con primaria completa.
replace edupi_ci=. if educuy==0 | educuy==998

**************
***edupc_ci*** // completó la educación primaria
**************
gen edupc_ci=(edattaind==212 & educuy==300) // edattaind==212 por si solo incluye individuos con sec incompleta y educuy==300 por si solo incluye individuos con algo de primaria completa.
replace edupc_ci=. if educuy==0 | educuy==998

**************
***edusi_ci*** // no completó la educación secundaria
**************
gen edusi_ci=(educuy==400)
replace edusi_ci=. if educuy==0 | educuy==998

**************
***edusc_ci*** // completó la educación secundaria
**************
gen edusc_ci=(educuy==410)
replace edusc_ci=. if educuy==0 | educuy==998

***************
***edus1i_ci*** // no completó el primer ciclo de la educación secundaria
***************
gen edus1i_ci=.

***************
***edus1c_ci*** // completó el primer ciclo de la educación secundaria
***************
gen edus1c_ci=(educuy==400)
replace edus1c_ci=. if educuy==0 | educuy==998

***************
***edus2i_ci*** // no completó el segundo ciclo de la educación secundaria
***************
gen edus2i_ci=.

***************
***edus2c_ci*** // completó el segundo ciclo de la educación secundaria
***************
gen edus2c_ci=(educuy==410)
replace edus2c_ci=. if educuy==0 | educuy==998

***************
***asiste_ci***
***************
gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
replace asiste_ci=. if school==9 // missing a los NIU & missing

**************
***literacy***
**************
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

************************
*** Discapacidad (WG)***
************************
/* Identificación de si una persona reporta por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */


gen dis_ci = 0
recode dis_ci nonmiss=. if inlist(9,uy2011a_disdev,uy2011a_dishear,uy2011a_dismob,uy2011a_dissee) //
recode dis_ci nonmiss=. if uy2011a_disdev>=. & uy2011a_dishear>=. & uy2011a_dismob>=. & uy2011a_dissee>=. //
	foreach i in dev hear mob see {
		forvalues j=2/4 {
		replace dis_ci=1 if uy2011a_dis`i'==`j'
		}
		}

/*Identificación de si un hogar tiene uno o más miembros que reportan por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */		

egen dis_ch  = sum(dis_ci), by(idh_ch) 
replace dis_ch=1 if dis_ch>=1 & dis_ch!=. 


*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress

save "`base_out'", replace 
log close

