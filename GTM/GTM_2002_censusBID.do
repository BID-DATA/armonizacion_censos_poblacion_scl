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
País: Guatemala
Año: 2002
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS GTM
local ANO "2002"

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
	replace region_c=1 if geo1_gt==320001 /*Guatemala*/
	replace region_c=2 if geo1_gt==320002 /*El Progreso*/
	replace region_c=3 if geo1_gt==320003 /*Sacatepéquez*/
	replace region_c=4 if geo1_gt==320004 /*Chimaltenango*/
	replace region_c=5 if geo1_gt==320005 /*Escuintla*/
	replace region_c=6 if geo1_gt==320006 /*Santa Rosa*/
	replace region_c=7 if geo1_gt==320007 /*Sololá*/
	replace region_c=8 if geo1_gt==320008 /*Totonicapán*/
	replace region_c=9 if geo1_gt==320009 /*Quetzaltenango*/
	replace region_c=10 if geo1_gt==320010 /*Suchitepéquez*/
	replace region_c=11 if geo1_gt==320011 /*Retalhuleu*/
	replace region_c=12 if geo1_gt==320012 /*San Marcos*/
	replace region_c=13 if geo1_gt==320013 /*Huehuetenango*/
	replace region_c=14 if geo1_gt==320014 /*Quiché*/
	replace region_c=15 if geo1_gt==320015 /*Baja Verapaz*/
	replace region_c=16 if geo1_gt==320016 /*Alta Verapaz*/
	replace region_c=17 if geo1_gt==320017 /*Petén*/
	replace region_c=18 if geo1_gt==320018 /*Izabal*/
	replace region_c=19 if geo1_gt==320019 /*Zacapa*/
	replace region_c=20 if geo1_gt==320020 /*Chiquimula*/
	replace region_c=21 if geo1_gt==320021 /*Jalapa*/
	replace region_c=22 if geo1_gt==320022 /*Jutiapa*/
	replace region_c=23 if geo1_gt==320088 /*Waterbodies*/
	
	label define region_c 1 "Guatemala" 2 "El Progreso" 3 "Sacatepéquez" 4 "Chimaltenango" 5 "Escuintla" 6 "Santa Rosa" 7 "Sololá" 8 "Totonicapán" 9 "Quetzaltenango" 10 "Suchitepéquez" 11 "Retalhuleu" 12 "San Marcos" 13 "Huehuetenango" 14 "Quiché" 15 "Baja Verapaz" 16 "Alta Verapaz" 17 "Petén" 18 "	Izabal" 19 "Zacapa" 20 "Chiquimula" 21 "Jalapa" 22 "Jutiapa" 23 "Cuerpos de agua"
	
	 label value region_c region_c
	
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
	**Pregunta: 

	gen afroind_ci=. 
	replace afroind_ci=1  if indig==1 /* Garifuna included here */
	replace afroind_ci=3 if indig==2


	***************
	***afroind_ch***
	***************
	gen afroind_jefe= afroind_ci if relate==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

	drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
	gen afroind_ano_c=1964


	********************
	*** discapacidad ***
	********************
	gen dis_ci=.
	gen dis_ch=.

*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
/*Argentina no tiene vars de ingreso pero se incluyen las 
variables de ingreso por hogar porque no están en el do Base*/	

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
	*aedu_ci* // 
	*********
	gen aedu_ci = yrschool 
	replace aedu_ci=. if yrschool>=90 & yrschool<100 
 
	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen eduno_ci=(aedu_ci==0) // never attended or pre-school
	replace eduno_ci=. if edattaind==0 | edattaind==999 // NIU & missing
	
	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=(educgt==110) // pre-school
	replace edupre_ci=. if educgt==0 | educgt==999 // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) //
	replace edupi_ci=. if educgt==0 | educgt==999 // NIU & missing
	replace edupi_ci = 1 if yrschool == 91 // some primary

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci==6) 
	replace edupc_ci=. if edattain==0 | edattain==9 // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<=11) // 7 a 11 anos de educación
	replace edusi_ci=. if edattain==0 |edattain==9 // NIU & missing
	replace edusi_ci = 1 if yrschool == 92 | yrschool ==93 //some technical after primary or some secondary

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==12) // 7 a 11 anos de educación
	replace edusc_ci=. if edattain==0 |edattain==9 // NIU & missing
	
	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=14 & aedu_ci<=16 & edattain != 4) // 14 a 16 anos de educación y no completo universidad
	replace eduui_ci=. if edattain==0 | edattain==9 // NIU & missing
	replace eduui_ci = 1 if yrschool == 94 // some terciary

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=.
	replace eduuc_ci=1 if edattain == 4
	replace eduuc_ci=0 if edattain == 1 | edattain == 2 | edattain ==3  
	// 12 y 13 anos de educación
	replace eduuc_ci=. if edattain==0 | edattain==9 // NIU & missing

	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
	replace edus1i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<12)
	replace edus2i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==12)
	replace edus2c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

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
include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress

save "`base_out'", replace 
log close

