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
País: Jamaica
Año: 1982
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS JAM
local ANO "1982"

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
replace region_c=1 if geo1_jm1982==1 
replace region_c=2 if geo1_jm1982==2 
replace region_c=3 if geo1_jm1982==3 
replace region_c=4 if geo1_jm1982==4 
replace region_c=5 if geo1_jm1982==5 
replace region_c=6 if geo1_jm1982==6 
replace region_c=7 if geo1_jm1982==7 
replace region_c=8 if geo1_jm1982==8 
replace region_c=9 if geo1_jm1982==9
replace region_c=10 if geo1_jm1982==10 
replace region_c=11 if geo1_jm1982==11 
replace region_c=12 if geo1_jm1982==12 
replace region_c=13 if geo1_jm1982==13 
replace region_c=14 if geo1_jm1982==14

label define region_c  ///
           1 "Kingston" ///
           2 "St andrew" ///
           3 "St thomas" ///
           4 "Portland" ///
           5 "St mary" ///
           6 "St ann" ///
           7 "Trelawny" ///
           8 "St james" ///
           9 "Hanover" ///
          10 "Westmoreland" ///
          11 "St elizabeth" ///
          12 "Manchester" ///
          13 "Clarendon" ///
          14 "St catherine"
	    
label value region_c region_c, replace

*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
**Pregunta: 


gen afroind_ci=. 
replace afroind_ci=3 if race == 10 | race == 41 | race == 46 | race == 50 | race == 60 | race == 61 
replace afroind_ci=1  if race >= 30 & race <40
replace afroind_ci=2 if race == 20 | race == 23 | race == 53
replace afroind_ci=. if (race==99) 


	***************
	***afroind_ch***
	***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=1982


********************
*** discapacidad ***
********************
gen dis_ci=.
gen dis_ch=.


******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************

	replace ylm_ci=incwage
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
   
   
*******************************************************
***           VARIABLES DE EDUCACIÓN               ***
*******************************************************

*NOTA: Como terciario, universitario y posgrado tienen una duración variable se supone 
*que terciario completo implica 3 años de educacion adicional a la secundaria, universitario 5 años adicionales y 
*postgrado 7. Esto solo se basa en la modas de finalización de estos niveles. ESTO SE DEBE DISCUTIR 
	*********
	*aedu_ci* // años de educacion aprobados
	*********
	gen aedu_ci=yrschool
	replace aedu_ci=. if yrschool>=90 &  yrschool<=99 // not specific years of schooling or unknown/missing or NIU

	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen eduno_ci=(aedu_ci==0) // never attended or pre-school
	replace eduno_ci=. if aedu_ci==. // NIU & missing

	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=(edujm==10) // pre-school
	replace edupre_ci=. if aedu_ci==. // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) // primary (zero years completed) + grade 1-5 + primary grade unknown
	replace edupi_ci=. if aedu_ci==. // NIU & missing
	replace edupi_ci=1 if yrschool==91
	replace edupi_ci=. if yrschool==90| yrschool==98| yrschool==99

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci ==6) // grade 6 
	replace edupc_ci=. if aedu_ci==. // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<11) // 7 a 11
	replace edusi_ci=. if aedu_ci==. // NIU & missing
	replace edusi_ci=1 if yrschool==92 | yrschool==93 
	replace edusi_ci=. if yrschool==90| yrschool==98| yrschool==99

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==11) // 11
	replace edusc_ci=.  if aedu_ci==. // NIU & missing 
	

	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=12 & aedu_ci<16) // 13 a 16 anos de educación
	replace eduui_ci=.  if aedu_ci==. // NIU & missing
	replace eduui_ci=1 if yrschool==94
	replace eduui_ci=. if yrschool==90| yrschool==98| yrschool==99

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=(aedu_ci>=16) //más de 17
	replace eduuc_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
	replace edus1i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<11)
	replace edus2i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==11)
	replace edus2c_ci=. if aedu_ci==. 
	
	***********
	*asiste_ci*
	***********
	gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
	replace asiste_ci=. if school==0 | school==9 // missing a los NIU & missing

	************
	* literacy *
	************
	gen literacy=. 

	*****************************
	** Include all labels of   **
	**  harmonized variables   **
	*****************************

include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress

save "`base_out'", replace 
log close
