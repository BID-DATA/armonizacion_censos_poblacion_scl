* (Versión Stata 17)

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
País: Nicaragua
Año: 2021
Autores: Agustina Thailinger
Última versión: Noviembre, 2021

							SCL/EDU - IADB
****************************************************************************/

local PAIS NIC
local ANO "1971"

**************************************
** Setup code, load database, ********
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

*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				

***************
***afroind_ci** // Raza o etnia del individuo
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
gen ylm_ci=.
 
gen ynlm_ci=.
   
gen ylm_ch=.

gen ynlm_ch=.

****************************
***VARIABLES DE EDUCACION***
****************************
****************
* asiste_ci    * 
**************** 
gen asiste_ci=1 if school==1
replace asiste_ci=0 if school==2
replace asiste_ci=. if school==0 // NIU
replace asiste_ci=. if school==9 // Unknown/missing 

*********
*aedu_ci* // años de educacion aprobados
*********
*NOTA: Como terciario, universitario y posgrado tienen una duración variable se supone 
*que terciario completo implica 3 años de educacion adicional a la secundaria, universitario 5 años adicionales y 
*postgrado 7. Esto solo se basa en la modas de finalización de estos niveles. 

gen aedu_ci=yrschool
replace aedu_ci=. if aedu_ci==98 // Unknown/missing
replace aedu_ci=. if aedu_ci==99 // NIU
	
**************
***eduno_ci*** // ningún nivel de instrucción
**************
gen byte eduno_ci=0
replace eduno_ci=1 if aedu_ci==0
replace eduno_ci=. if aedu_ci==.

**************
***edupi_ci*** // primaria incompleta
**************
gen byte edupi_ci=0
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<6
replace edupi_ci=. if aedu_ci==.

**************
***edupc_ci*** // primaria completa
**************
gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==6
replace edupc_ci=. if aedu_ci==.

**************
***edusi_ci*** // secundaria incompleta
**************
gen byte edusi_ci=0
replace edusi_ci=1 if aedu_ci>6 & aedu_ci<11
replace edusi_ci=. if aedu_ci==.

**************
***edusc_ci*** // secundaria completa
**************
gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==11
replace edusc_ci=. if aedu_ci==.

**************
***eduui_ci*** // terciaria/universitaria incompleta
**************
gen byte eduui_ci=0
replace eduui_ci=1 if aedu_ci>11 & aedu_ci<16
replace edusi_ci=. if aedu_ci==.

***************
***eduuc_ci**** // terciaria/universitaria completa
***************
gen byte eduuc_ci=0
replace eduuc_ci=1 if aedu_ci>=16
replace eduuc_ci=. if aedu_ci==.

***************
***edus1i_ci*** // primer ciclo de secundaria incompleto
***************
gen byte edus1i_ci=0
replace edus1i_ci=1 if aedu_ci>6 & aedu_ci<9
replace edus1i_ci=. if aedu_ci==.

***************
***edus1c_ci*** // primer ciclo de secundaria completo
***************
gen byte edus1c_ci=0
replace edus1c_ci=1 if aedu_ci==9 
replace edus1c_ci=. if aedu_ci==.

***************
***edus2i_ci*** // segundo ciclo de secundaria incompleto
***************
gen byte edus2i_ci=0
replace edus2i_ci=1 if aedu_ci>9 & aedu_ci<11
replace edus2i_ci=. if aedu_ci==.

***************
***edus2c_ci*** // segundo ciclo de secundaria completo
***************
gen byte edus2c_ci=0
replace edus2c_ci=1 if aedu_ci==11
replace edus2c_ci=. if aedu_ci==.

***************
***edupre_ci*** // preescolar
***************
gen edupre_ci=.

***************
***literacy***
***************
gen literacy=. if lit==0 // NIU
replace literacy=. if lit==9 // Unknown/missing
replace literacy=0 if lit==1
replace literacy=1 if lit==2

order region_BID_c region_c pais_c anio_c idh_ch idp_ci factor_ch factor_ci estrato_ci zona_c sexo_ci edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch condocup_ci emp_ci desemp_ci pea_ci rama_ci categopri_ci spublico_ci ylm_ci ynlm_ci ylm_ch ynlm_ch aedu_ci eduno_ci edupre_ci edupi_ci  edupc_ci  edusi_ci edusc_ci  eduui_ci eduuc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci asiste_ci literacy aguared_ch luz_ch bano_ch des1_ch piso_ch banomejorado_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch migrante_ci migrantelac_ci migantiguo5_ci discapacidad_ci  ceguera_ci sordera_ci mudez_ci dismental_ci

*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

compress

save "`base_out'", replace 
log close