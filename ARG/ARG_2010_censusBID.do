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
País: Argentina
Año: 1970
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

local PAIS ARG
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
   replace region_c=1 if geo1_ar==32002			    /*Ciudad de Buenos Aires*/
   replace region_c=2 if geo1_ar==32006			    /*Provincia de Buenos Aires*/
   replace region_c=3 if geo1_ar==32010			    /*Catamarca*/
   replace region_c=4 if geo1_ar==32014			    /*Córdoba*/
   replace region_c=5 if geo1_ar==32018		     	/*Corrientes*/
   replace region_c=6 if geo1_ar==32022			    /*Chaco*/
   replace region_c=7 if geo1_ar==32026			    /*Chubut*/
   replace region_c=8 if geo1_ar==32030			    /*Entre Rí­os*/
   replace region_c=9 if geo1_ar==32034			    /*Formosa*/
   replace region_c=10 if geo1_ar==32038			/*Jujuy*/
   replace region_c=11 if geo1_ar==32042			/*La Pampa*/
   replace region_c=12 if geo1_ar==32046			/*La Rioja*/
   replace region_c=13 if geo1_ar==32050			/*Mendoza*/
   replace region_c=14 if geo1_ar==32054			/*Misiones*/
   replace region_c=15 if geo1_ar==32058			/*Neuquén*/
   replace region_c=16 if geo1_ar==32062			/*Rio Negro*/
   replace region_c=17 if geo1_ar==32066			/*Salta*/
   replace region_c=18 if geo1_ar==32070			/*San Juan*/
   replace region_c=19 if geo1_ar==32074			/*San Luis*/
   replace region_c=20 if geo1_ar==32078			/*Santa Cruz*/
   replace region_c=21 if geo1_ar==32082			/*Santa Fe*/
   replace region_c=22 if geo1_ar==32086			/*Santiago del Estero*/
   replace region_c=23 if geo1_ar==32090			/*Tucumán*/
   replace region_c=24 if geo1_ar==32094			/*Tierra del Fuego*/
   replace region_c=99 if geo1_ar==32099			/*Unknown*/


	  label define region_c 1"Ciudad de Buenos Aires" 2"Provincia de Buenos Aires" 3"Catamarca" 4"Córdoba" 5"Corrientes" 6"Chaco" 7"Chubut" 8"Entre Ríos" 9"Formosa" 10"Jujuy" 11"La Pampa" 12"La Rioja" 13"Mendoza" 14"Misiones" 15"Neuquén" 16"Río Negro" 17"Salta" 18"San Juan" 19"San Luis" 20"Santa Cruz" 21"Santa Fe" 22"Santiago del Estero" 23"Tucumán" 24"Tierra del Fuego" 99""

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
	if (_rc==0) {
    replace condocup_ci=1 if empstat==1
    replace condocup_ci=2 if empstat==2
    replace condocup_ci=3 if empstat==3
    replace condocup_ci=. if empstat==9
    replace condocup_ci=4 if empstat==0
	}
	
	  ************
      ***emp_ci***
      ************
    gen emp_ci=(condocup_ci==1)

	
      ****************
      ***desemp_ci***
      ****************
    gen desemp_ci=(condocup_ci==2)
	
	  *************
      ***pea_ci***
      *************
    gen pea_ci=(emp_ci==1 | desemp_ci==1)
	
     *************************
     ****rama de actividad****
     *************************
	 *2010 no tiene variable indgen
    gen rama_ci = .
	cap confirm indgen 
	if (_rc==0) {
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
	}
	
	 *********************
     ****categopri_ci****
     *********************
	 *OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.	
    gen categopri_ci=.
	cap confirm variable classwkd
	if (_rc==0) {
    replace categopri_ci=0 if classwkd==400 | classwkd==999
    replace categopri_ci=1 if classwkd==110
    replace categopri_ci=2 if classwkd==120
    replace categopri_ci=3 if classwkd==203 | classwkd==204 | classwkd==216 | classwkd==230 | classwkd == 220 | classwkd == 210 
    replace categopri_ci=4 if classwkd==310 
	}
	
	  *****************
      ***spublico_ci***
      *****************
	gen spublico_ci=.
	if (_rc==0) {
    gen spublico_ci=(indgen==100)
	}
	
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************

	gen afroind_ci=. 
	gen afroind_ch  =.

	***************
	***afroind_ch***
	***************
	gen afroind_jefe=.

	*******************
	***afroind_ano_c***
	*******************
	gen afroind_ano_c=.

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
	*aedu_ci* // años de educacion aprobados
	*********
*NOTA: Como terciario, universitario y posgrado tienen una duración variable se supone 
*que terciario completo implica 3 años de educacion adicional a la secundaria, universitario 5 años adicionales y 
*postgrado 7. Esto solo se basa en la modas de finalización de estos niveles. ESTO SE DEBE DISCUTIR 

	gen aedu_ci=yrschool
	replace aedu_ci=. if yrschool>=90 & yrschool<100 // categorias NIU; missing; + categorias nivel educativo pero pero sin años de escolaridad

	**********
	*eduno_ci* // no ha completado ningún año de educación // Para esta variable no se puede usar aedu_ci porque aedu_ci=0 es none o pre-school
	**********

	gen eduno_ci=(aedu_ci==0) // never attended or pre-school
	replace eduno_ci=. if educar==0 | educar==999 // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	
	gen edupi_ci=(educar==130 | educar==210 | educar==220 | educar==230 | educar==240 | educar==250 | educar==280) // primary (zero years completed) + grade 1-5 + primary grade unknown
	replace edupi_ci=. if educar==0 | educar==999 // NIU & missing

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	
	gen edupc_ci=(educar==260 | educar==270) // grade 6 + grade 7
	replace edupc_ci=. if educar==0 | educar==999 // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	
	gen edusi_ci=(aedu_ci>=8 & aedu_ci<=11) // 8 a 11 anos de educación
	replace edusi_ci=. if educar==0 | educar==999 // NIU & missing

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	
	gen edusc_ci=(aedu_ci==12 | aedu_ci==13) // 12 y 13 anos de educación
	replace edusc_ci=. if educar==0 | educar==999 // NIU & missing

	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	
	gen eduui_ci=(aedu_ci>=14 & aedu_ci<=16) // 14 a 16 anos de educación
	replace eduui_ci=. if educar==0 | educar==999 // NIU & missing

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	
	gen eduuc_ci=(aedu_ci==17 | aedu_ci==18) // 17 y 18 anos de educación
	replace eduuc_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

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