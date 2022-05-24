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
Año: 2006
Autores: Cesar Lins y Nathalia Maya 
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS URY
local ANO "2006"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
include "../Base/base.do"


*****************************************************
******* Variables specific for this census **********
*****************************************************
****** REGION *****************
gen region_c=geo1_uy2006
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

******************************

	replace ylm_ci=incwage  //
	replace ylm_ci=. if incwage==9999998 | incwage==9999999
	
	replace ynlm_ci=.

    ***********
	**ylm_ch*
	***********
   
   by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
   
    ***********
	**ynlm_ch*
	***********
   by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1, missing

***********************************************
****************** Educacion ******************
***********************************************

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
replace aedu_ci=18 if yrschool==18 // 18 or more
replace aedu_ci=. if yrschool==91 | yrschool==94 // Unknown

**********
*eduno_ci*
**********
gen eduno_ci=(aedu_ci==0) // none (incluye preescolar)
replace eduno_ci=. if aedu_ci==. // NIU

***********
*edupre_ci*
***********
gen byte edupre_ci=(educuy>=200 & educuy<=214) // pre-school complete or incomplete
replace edupre_ci=. if aedu_ci==. // NIU

**********
*edupi_ci* // no completó la educación primaria
**********
gen edupi_ci=(aedu_ci>=1 & aedu_ci<=5) // 1-5 anos de educación
replace edupi_ci=. if aedu_ci==. // NIU
replace edupi_ci=1 if yrschool==91 // Some primary 

**********
*edupc_ci* // completó la educación primaria
**********
gen edupc_ci=(aedu_ci==6) // 6 anos de educación
replace edupc_ci=. if aedu_ci==. // NIU

**********
*edusi_ci* // no completó la educación secundaria
**********
gen edusi_ci=(aedu_ci>=7 & aedu_ci<=11) // 7 a 11 anos de educación 
replace edusi_ci=. if aedu_ci==. // NIU
replace edusi_ci=1 if yrschool==92 | yrschool==93 // Some techinical after primary and some secondary

**********
*edusc_ci* // completó la educación secundaria
**********
gen edusc_ci=(aedu_ci==12) // 12 anos de educación
replace edusc_ci=. if aedu_ci==. // NIU

***********
*edus1i_ci* // no completó el primer ciclo de la educación secundaria
***********
gen byte edus1i_ci=(aedu_ci>=7 & aedu_ci<9)
replace edus1i_ci=. if aedu_ci==. // NIU

***********
*edus1c_ci* // completó el primer ciclo de la educación secundaria
***********
gen byte edus1c_ci=(aedu_ci==9)
replace edus1c_ci=. if aedu_ci==. // NIU

***********
*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
***********
gen byte edus2i_ci=(aedu_ci==10 | aedu_ci==11)
replace edus2i_ci=. if aedu_ci==. // NIU

***********
*edus2c_ci* // completó el segundo ciclo de la educación secundaria
***********
gen byte edus2c_ci=(aedu_ci==12)
replace edus2c_ci=. if aedu_ci==. // NIU

***********
*asiste_ci* 
***********
gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
replace asiste_ci=. if school==9 // missing a los NIU & missing

**********
*literacy*
**********
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

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress

save "`base_out'", replace 
log close

