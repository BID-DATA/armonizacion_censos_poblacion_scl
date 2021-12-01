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
País: Panamá
Año: 1960
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS PAN
local ANO "1960"

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
   replace region_c=1 if geo1_pa==591002		/*Cocle*/
   replace region_c=2 if geo1_pa==591003		/*Colón, Comarca Kuna Yala (San Blas)*/
   replace region_c=3 if geo1_pa==591004		/*Bocas de Toro, Chiriqui, Comarca Ngabe-Bugle*/
   replace region_c=4 if geo1_pa==591005		/*Comarca Embera, Darien*/
   replace region_c=5 if geo1_pa==591006		/*Herrera*/
   replace region_c=6 if geo1_pa==591007		/*Los Santos*/
   replace region_c=7 if geo1_pa==591008		/*Panama*/

	label define region_c 1"Cocle" 2"Colon, Comarca Kuna Yala (San Blas)" 3"Bocas de Toro, Chiriqui, Comarca Ngabe-Bugle" 4"Comarca Embera, Darien" 5"Herrera" 6"Los Santos" 7"Panama" 
    label value region_c region_c
	label var region_c "division politico-administrativa, provincias"

*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				

	***************
	***afroind_ci***
	***************
**Pregunta: 

gen afroind_ci=. 

	***************
	***afroind_ch***
	***************
gen afroind_jefe=.
gen afroind_ch  =.

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=1990

********************
*** discapacid
********************
gen dis_ci=.
gen dis_ch=.



*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
*PAN 1960 no tiene ingreso, se agrega ingreso por hogar vacio
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

	*********
	*aedu_ci* // años de educacion aprobados
	*********
	gen aedu_ci=yrschool
	replace aedu_ci=. if aedu_ci==98
	replace aedu_ci=. if aedu_ci==99
	replace aedu_ci=. if yrschool>=90 & yrschool<100 // unknown/missing or NIU

	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen eduno_ci=(aedu_ci==0) // never attended or pre-school
	replace eduno_ci=. if aedu_ci==. // NIU & missing

	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=(educpa==03) // pre-school
	replace edupre_ci=. if aedu_ci==. // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) // primary (zero years completed) + grade 1-5 + primary grade unknown
	replace edupi_ci=. if aedu_ci==. // NIU & missing
	replace edupi_ci=1 if yrschool==91

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci ==6) // grade 6 
	replace edupc_ci=. if aedu_ci==. // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<=11) // 7 a 11
	replace edusi_ci=. if aedu_ci==. // NIU & missing
	replace edusi_ci=1 if yrschool==93

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==12) // 12 
	replace edusc_ci=.  if aedu_ci==. // NIU & missing

	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=13 & aedu_ci<=16) // 13 a 16 anos de educación
	replace eduui_ci=.  if aedu_ci==. // NIU & missing
	replace  eduui_ci=1 if yrschool==94

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=(aedu_ci>=17) //más de 16
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
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<12)
	replace edus2i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==12)
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
	replace literacy=1 if lit==2 // literate
	replace literacy=0 if lit==1 // illiterate


*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************

order region_BID_c region_c pais_c anio_c idh_ch idp_ci factor_ch factor_ci estrato_ci zona_c sexo_ci edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch condocup_ci emp_ci desemp_ci pea_ci rama_ci categopri_ci spublico_ci ylm_ci ynlm_ci ylm_ch ynlm_ch aedu_ci eduno_ci edupre_ci edupi_ci  edupc_ci  edusi_ci edusc_ci  eduui_ci eduuc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci asiste_ci literacy aguared_ch luz_ch bano_ch des1_ch piso_ch banomejorado_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch migrante_ci migrantelac_ci migantiguo5_ci discapacidad_ci  ceguera_ci sordera_ci mudez_ci dismental_ci

include "../Base/labels.do"


compress

save "`base_out'", replace 
log close

