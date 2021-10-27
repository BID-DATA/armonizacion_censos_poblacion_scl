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
local ANO "1994"

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
	 
**********************************************
***      VARIABLES DEL MERCADO LABORAL     ***
**********************************************	

     *******************
     ****condocup_ci****
     *******************
	 *2010 no tiene variable empstat
	 
    gen condocup_ci=.
	cap confirm variable empstat
	if (_rc==0){
    replace condocup_ci=1 if empstat==1
    replace condocup_ci=2 if empstat==2
    replace condocup_ci=3 if empstat==3
    replace condocup_ci=. if empstat==9 /*unkown/missing as missing*/ 
    replace condocup_ci=. if empstat==0 /*NIU as missing*/
	}
	
      ************
      ***emp_ci***
      ************
    gen emp_ci=.
	cap confirm variable empstat
	if (_rc==0){
		replace emp_ci=0 if empstat==2
		replace emp_ci=0 if empstat==3
		replace emp_ci=1 if empstat==1
		replace emp_ci=. if empstat==0 /*NIU as missing*/
		replace emp_ci=. if empstat==9 /*unkown/missing as missing*/
	}
	
	
      ****************
      ***desemp_ci***
      ****************	
	gen desemp_ci=.
	cap confirm variable condocup_ci
	if (_rc==0){
		replace desemp_ci=1 if condocup_ci==2 /*1 desempleados*/
		replace desemp_ci=0 if condocup_ci==3 /*0 cuando están inactivos*/
	}
	
      *************
      ***pea_ci***
      *************
    gen pea_ci=.
	cap confirm variable condocup_ci
	if (_rc==0){
		replace pea_ci=1 if condocup_ci==1
		replace pea_ci=1 if condocup_ci==2
		replace pea_ci=0 if condocup_ci==3
	}
	
     *************************
     ****rama de actividad****
     *************************
	 *2010 no tiene variable indgen
    gen rama_ci = .
    replace rama_ci = 1 if indgen==10
    replace rama_ci = 2 if indgen==20  
    replace rama_ci = 3 if indgen==30   
    replace rama_ci = 4 if indgen==40    
    replace rama_ci = 5 if indgen==50    
    replace rama_ci = 6 if indgen==60    
    replace rama_ci = 7 if indgen==70    
    replace rama_ci = 8 if indgen==80    
    replace rama_ci = 9 if indgen==90
    replace rama_ci = 10 if indgen==100  
    replace rama_ci = 11 if indgen==111  
    replace rama_ci = 12 if indgen==112
    replace rama_ci = 13 if indgen==113 
    replace rama_ci = 14 if indgen==114 
    replace rama_ci = 15 if indgen==120 
	
     *********************
     ****categopri_ci****
     *********************
	 *OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.	
    gen categopri_ci=.
	cap confirm variable classwkd
	if (_rc==0) {
    replace categopri_ci=0 if classwkd==400 
    replace categopri_ci=1 if classwkd==110
    replace categopri_ci=2 if classwkd==120
    replace categopri_ci=3 if classwkd==210 | classwkd==220
    replace categopri_ci=4 if classwkd==310
	}
	
      *****************
      ***spublico_ci***
      *****************
    gen spublico_ci=.
	cap confirm variable indgen
	if (_rc==0){
		replace spublico_ci=1 if indgen==100
		replace spublico_ci=0 if emp_ci==1 & indgen!=100
		replace spublico_ci=. if indgen == 998 | indgen == 999 | indgen == 000
	}
	  
	
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
	gen afroind_ano_c=2002


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
	replace aedu=. if yrschool==98 | yrschool==99
 
	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen eduno_ci=(aedu_ci==0) // never attended or pre-school
	replace eduno_ci=. if edattain==0 | edattain==999 // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	
	gen edupi_ci=.
	replace edupi_ci=1 if edattain == 1
	replace edupi_ci=0 if edattain == 2 | edattain == 3 | edattain == 4
	replace edupi_ci=. if edattain==0 | edattain== 9 // NIU & missing

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	
	gen edupc_ci=.
	replace edupc_ci=1 if edattain == 2
	replace edupc_ci=0 if edattain == 1 | edattain == 3 | edattain == 4
	replace edupc_ci=. if edattain==0 | edattain==9 // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	
	gen edusi_ci=(aedu_ci>=8 & aedu_ci<=11) // 8 a 11 anos de educación
	replace edusi_ci=. if edattain==0 |edattain==9 // NIU & missing

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	
	gen edusc_ci=.
	replace edusc_ci=1 if edattain == 3
	replace edusc_ci=0 if edattain == 1 | edattain == 2 | edattain == 4
	// 12 y 13 anos de educación
	replace edusc_ci=. if edattain==0 | edattain==9 // NIU & missing
	
	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	
	gen eduui_ci=(aedu_ci>=14 & aedu_ci<=16) // 14 a 16 anos de educación
	replace eduui_ci=. if edattain==0 | edattain==9 // NIU & missing

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	
	gen eduuc_ci=.
	replace eduuc_ci=1 if edattain == 4
	replace eduuc_ci=0 if edattain == 1 | edattain == 2 | edattain ==3  
	// 12 y 13 anos de educación
	replace edusc_ci=. if edattain==0 | edattain==9 // NIU & missing

	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********

	gen byte edus1i_ci=(aedu_ci==8)
	replace edus1i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********

	gen byte edus2i_ci=.

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********

	gen byte edus2c_ci=.

	***********
	*asiste_ci*
	***********
	
	gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
	replace asiste_ci=. if school==0 | school==9 // missing a los NIU & missing
	
*Other variables

	************
	* literacy *
	************

	gen literacy=. 
	replace literacy=1 if lit==2 // literate
	replace literacy=0 if lit==1 // illiterate
	
*******************************************************
***           VARIABLES DE MIGRACIÓN              ***
*******************************************************

      *******************
      ****migrante_ci****
      *******************
	gen migrante_ci =.
	replace migrante_ci = 1 if nativity == 2
	replace migrante_ci = 0 if nativity == 1 

      *******************
      **migantiguo5_ci***
      *******************
	gen migantiguo5_ci =.
	cap confirm migyrs1 
	if (_rc==0) {
	gen migantiguo5_ci = (migyrs1 >= 5) & migrante_ci == 1
	}
	replace migantiguo5_ci = . if migantiguo5_ci == 0 & nativity != 2
	
	**********************
	*** migrantelac_ci ***
	**********************

	gen migrantelac_ci = .
	replace migrantelac_ci= 1 if inlist(bplcountry, 21100, 23010, 22060, 23110, 22040, 23100, 22030, 23060, 23140, 22050, 23050, 23040, 23100, 29999, 23130, 23020, 22020, 21250, 21999, 22010, 22070, 22080, 22999) & migrante_ci == 1
	replace migrantelac_ci = 0 if migrantelac_ci == . & migrante_ci == 1
	
*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress

save "`base_out'", replace 
log close

