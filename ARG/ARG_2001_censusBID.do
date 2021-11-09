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
local ANO "2001"

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
	label var region_c "division politico-administrativa, provincias"
	
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************

	gen afroind_ci=. 

	***************
	***afroind_ch***
	***************
	gen afroind_ch=.

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

*NOTA: Como terciario, universitario y posgrado tienen una duración variable se supone 
*que terciario completo implica 3 años de educacion adicional a la secundaria, universitario 5 años adicionales y 
*postgrado 7. Esto solo se basa en la modas de finalización de estos niveles. ESTO SE DEBE DISCUTIR 
	*********
	*aedu_ci* // años de educacion aprobados
	*********
	gen aedu_ci=yrschool
	replace aedu_ci=. if aedu_ci==98
	replace aedu_ci=. if aedu_ci==99
	replace aedu_ci=. if yrschool==90 // unknown/missing or NIU

	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen eduno_ci=(aedu_ci==0) // never attended or pre-school
	replace eduno_ci=. if aedu_ci==. // NIU & missing

	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=(educar==120) // pre-school
	replace edupre_ci=. if aedu_ci==. // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) // primary (zero years completed) + grade 1-5 + primary grade unknown
	replace edupi_ci=. if aedu_ci==. // NIU & missing

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

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=(aedu_ci>=17) //más de 17
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
include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress

save "`base_out'", replace 
log close