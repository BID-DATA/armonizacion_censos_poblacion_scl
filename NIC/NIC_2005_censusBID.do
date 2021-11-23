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
Año: 2005
Autores: Cesar Lins, Nathalia Maya, Agustina Thailinger
Última versión: Noviembre, 2021

							SCL/LMK/EDU - IADB
****************************************************************************/

local PAIS NIC
local ANO "2005"

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
replace region_c=1 if geo1_ni==558005 // Nueva Segovia, Jinotega
replace region_c=2 if geo1_ni==558020 // Madriz
replace region_c=3 if geo1_ni==558025 // Esteli, Leon
replace region_c=4 if geo1_ni==558030 // Chinandega
replace region_c=5 if geo1_ni==558040 // Matagalpa, Atlantico Norte, Atlantico Sur, Zelaya
replace region_c=6 if geo1_ni==558050 // Boaco
replace region_c=7 if geo1_ni==558055 // Managua, Masaya
replace region_c=8 if geo1_ni==558065 // Chontales
replace region_c=9 if geo1_ni==558070 // Granada
replace region_c=10 if geo1_ni==558075 // Carazo
replace region_c=11 if geo1_ni==558080 // Rivas
replace region_c=12 if geo1_ni==558085 // Rio San Juan

label define region_c ///
	1 "Nueva Segovia, Jinotega" ///
	2 "Madriz" ///
	3 "Esteli. Leon" ///
	4 "Chinandega" ///
	5 "Matagalpa, Atlantico Norte, Atlantico Sur, Zelaya" ///
	6 "Boaco" ///
	7 "Managua, Masaya" ///
	8 "Chontales" ///
	9 "Granada" ///
	10 "Carazo" ///
	11 "Rivas" ///
	12 "Rio San Juan" ///
	
***************************************************
***           VARIABLES DE DIVERSIDAD           ***
***************************************************				

***************
***afroind_ci***
***************
gen afroind_ci=. 
replace afroind_ci=1  if indig==1 
replace afroind_ci=3 if indig==2


***************
***afroind_ch**
***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 
drop afroind_jefe 

*******************
***afroind_ano_c***
*******************
gen afroind_ano_c=2005

********************
*** discapacidad ***
********************
gen dis_ci=.
gen dis_ch=.

*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
* NIC no tiene variables de ingreso se genera por hogar vacia
   
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
replace aedu_ci=. if yrschool>=90 & yrschool<100 
	
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
replace edupi_ci = 1 if yrschool == 91 // some primary

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
replace edusi_ci = 1 if yrschool ==93 // some secondary

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
replace eduui_ci = 1 if yrschool == 94 // some terciary

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
gen edupre_ci=(educni==121 | educni==123 | educni == 123) // pre-school
replace edupre_ci=. if educni==0 | educni==999 // NIU & missing
replace edupre_ci= . if aedu_ci==.

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
