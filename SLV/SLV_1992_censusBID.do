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

local PAIS SLV
local ANO "1992"

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
   replace region_c=1 if geo1_sv==222001				    /*Ahuachapán*/
   replace region_c=2 if geo1_sv==222002		    /*Santa Ana*/
   replace region_c=3 if geo1_sv==222003			    /*Sonsonate*/
   replace region_c=4 if geo1_sv==222004			    /*Chalatenango*/
   replace region_c=5 if geo1_sv==222005			    /*La Libertad*/
   replace region_c=6 if geo1_sv==222006			    /*San Salvador*/
   replace region_c=7 if geo1_sv==222007			    /*Cuscatlán*/
   replace region_c=8 if geo1_sv==222008			    /*La Paz*/
   replace region_c=9 if geo1_sv==222009			    /*Cabañas*/
   replace region_c=10 if geo1_sv==222010			    /*San Vicente*/
   replace region_c=11 if geo1_sv==222011			    /*Usulután*/
   replace region_c=12 if geo1_sv==222012			    /*San Miguel*/
   replace region_c=13 if geo1_sv==222013			    /*Morazán*/
   replace region_c=14 if geo1_sv==222014			    /*La Unión*/

   label define region_c 1"Ahuachapán" 2"Santa Ana" 3"Sonsonate" 4 "Chalatenango" ///
   5 "La Libertad" 6 "San Salvador" 7 "Cuscatlán" 8 "La Paz" 9 "Cabañas" 10 "San Vicente" ///
   11 "Usulután" 12 "San Miguel" 13 "Morazán" 14 "La Unión"

    label value region_c region_c
	label var region_c "division politico-administrativa, estados"
	
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
	gen afroind_ch  = .

	*******************
	***afroind_ano_c***
	*******************
	gen afroind_ano_c=2007


	********************
	*** discapacidad ***
	********************
	gen dis_ci=.
	gen dis_ch=.

	
*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
/*El Salvador no tiene vars de ingreso pero se incluyen las 
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
	replace aedu_ci=. if aedu_ci==98
	replace aedu_ci=. if aedu_ci==99
	replace aedu_ci=. if yrschool>=90 & yrschool<100 

	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen byte eduno_ci=0
	replace eduno_ci=1 if aedu_ci==0
	replace eduno_ci=. if aedu_ci==.

	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=(educsv>=110 & educsv<=114) // pre-school
	replace edupre_ci=. if educsv==0 | educsv==999 // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen byte edupi_ci=0
	replace edupi_ci=1 if aedu_ci>0 & aedu_ci<6
	replace edupi_ci=1 if yrschool==91 // Some primary 
	replace edupi_ci=. if aedu_ci==.

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen byte edupc_ci=0
	replace edupc_ci=1 if aedu_ci==6
	replace edupc_ci=. if aedu_ci==.

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen byte edusi_ci=0
	replace edusi_ci=1 if aedu_ci>6 & aedu_ci<12
	replace edusi_ci=1 if yrschool==92 | yrschool==93 // Some techinical after primary and some secondary
	replace edusi_ci=. if aedu_ci==.
	replace edusi_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)
	
	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==12) // 12 
	replace edusc_ci=. if aedu_ci==.

	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=14 & aedu_ci<16)
	replace eduui_ci=. if aedu_ci==.

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=(aedu_ci>=16) // 
	replace eduuc_ci=. if aedu_ci==.
	
	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
	replace edus1i_ci=. if aedu_ci==.

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if aedu_ci==.
	
	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<12)
	replace edus2i_ci=. if aedu_ci==.

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==12)
	replace edus2c_ci=1 if yrschool==94 // Some tertiary
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