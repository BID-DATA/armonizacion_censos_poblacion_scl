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

local PAIS CHL
local ANO "1970"

/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Chile
Año: 1970
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

include "../Base/base.do"


     ****************
     *** region_c ***
     ****************
   * Clasificación válida para 1960 y 1970

   gen region_c=.   
   replace region_c=1 if geo1alt_cl==152001			    /*Tarapacá*/
   replace region_c=2 if geo1alt_cl==152002			    /*Antofagasta*/
   replace region_c=3 if geo1alt_cl==152003			    /*Atacama*/
   replace region_c=4 if geo1alt_cl==152004			    /*Coquimbo*/
   replace region_c=5 if geo1alt_cl==152005		     	/*Aconcagua*/
   replace region_c=6 if geo1alt_cl==152006			    /*Valparaiso*/
   replace region_c=7 if geo1alt_cl==152007			    /*Santiago*/
   replace region_c=8 if geo1alt_cl==152008			    /*Ohiggins*/
   replace region_c=9 if geo1alt_cl==152009			    /*Colchagua*/
   replace region_c=10 if geo1alt_cl==152010			/*Curico*/
   replace region_c=11 if geo1alt_cl==152011			/*Talca*/
   replace region_c=12 if geo1alt_cl==152012			/*Maule*/
   replace region_c=13 if geo1alt_cl==152013			/*Linares*/
   replace region_c=14 if geo1alt_cl==152014			/*Nuble*/
   replace region_c=15 if geo1alt_cl==152015			/*Concepción*/
   replace region_c=16 if geo1alt_cl==152016			/*Arauco*/
   replace region_c=17 if geo1alt_cl==152017			/*Bio Bio*/
   replace region_c=18 if geo1alt_cl==152018			/*Malleco*/
   replace region_c=19 if geo1alt_cl==152019			/*Cautin*/
   replace region_c=20 if geo1alt_cl==152020			/*Valdivia*/
   replace region_c=21 if geo1alt_cl==152021			/*Osorno*/
   replace region_c=22 if geo1alt_cl==152022			/*Llanquihue*/
   replace region_c=23 if geo1alt_cl==152023			/*Chiloe*/
   replace region_c=24 if geo1alt_cl==152024			/*Aysen*/
   replace region_c=25 if geo1alt_cl==152025			/*Magallanes*/
   replace region_c=99 if geo1alt_cl==152099			/*Unknown*/


	  label define region_c 1"Tarapacá" 2"Antofagasta" 3"Atacama" 4"Coquimbo" 5"Aconcagua" 6"Valparaíso" 7"Santiago" 8"Ohiggins" 9"Colchagua" 10"Curico" 11"Talca" 12"Maule" 13"Linares" 14"Nuble" 15"Concepción" 16"Arauco" 17"Bio Bio" 18"Malleco" 19"Cautin" 20"Valdivia" 21"Osorno" 22"Llanquihue" 23"Chiloe" 24"Aysen" 25"Magallanes" 99""

      label value region_c region_c
      label var region_c "division politico-administrativa, provincia"


************************
* VARIABLES EDUCATIVAS *
************************

****************
* asiste_ci    * 
**************** 
gen asiste_ci=1 if school==1
replace asiste_ci=. if school==0 // not in universe as missing 
replace asiste_ci=. if school==9 // Unknown/missing as missing
replace asiste_ci=0 if school==2

****************
* aedu_ci      * 
**************** 

gen aedu_ci=yrschool
replace aedu_ci=. if aedu_ci==98
replace aedu_ci=. if aedu_ci==99

**************
***eduno_ci***
**************
gen byte eduno_ci=0
replace eduno_ci=1 if aedu_ci==0
replace eduno_ci=. if aedu_ci==.

**************
***edupi_ci***
**************
gen byte edupi_ci=0
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<6
replace edupi_ci=. if aedu_ci==.

**************
***edupc_ci***
**************
gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==6
replace edupc_ci=. if aedu_ci==.

**************
***edusi_ci***
**************
gen byte edusi_ci=0
replace edusi_ci=1 if aedu_ci>6 & aedu_ci<12
replace edusi_ci=. if aedu_ci==.

**************
***edusc_ci***
**************
gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==12
replace edusc_ci=. if aedu_ci==.

**************
***eduui_ci***
**************
gen byte eduui_ci=0
replace eduui_ci=1 if aedu_ci>12 & aedu_ci<17
replace eduui_ci=. if aedu_ci==.

***************
***eduuc_ci****
***************
gen byte eduuc_ci=0
replace eduuc_ci=1 if aedu_ci>=17
replace eduuc_ci=. if aedu_ci==.

***************
***edus1i_ci***
***************
gen byte edus1i_ci=0
replace edus1i_ci=1 if aedu_ci>6 & aedu_ci<9
replace edus1i_ci=. if aedu_ci==.

***************
***edus1c_ci***
***************
gen byte edus1c_ci=0
replace edus1c_ci=1 if aedu_ci==9 
replace edus1c_ci=. if aedu_ci==.

***************
***edus2i_ci***
***************
gen byte edus2i_ci=0
replace edus2i_ci=1 if aedu_ci>9 & aedu_ci<12
replace edus2i_ci=. if aedu_ci==.

***************
***edus2c_ci***
***************
gen byte edus2c_ci=0
replace edus2c_ci=1 if aedu_ci==12
replace edus2c_ci=. if aedu_ci==.

***************
***edupre_ci***
***************
gen edupre_ci=.

** Other variables 
***************
***literacy***
***************
gen literacy=. if lit==0
replace literacy=. if lit==9
replace literacy=0 if lit==1
replace literacy=1 if lit==2
	  
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************
* Cesar Lins & Nathalia Maya - Septiembre 2021	

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
gen afroind_ano_c=.

********************
*** discapacid
********************
gen dis_ci=.
gen dis_ch=.



*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
	
    ***********
	**ylm_ci**
	***********
	
	*gen ylm_ci=.
	
    ***********
	**ynlm_ci**
	***********
 
	*gen ynlm_ci=.

    ***********
	**ylm_ch**
	***********
   
   gen ylm_ch=.
   
    ***********
	**ynlm_ch**
	***********
   gen ynlm_ch=.

*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

	
compress

save "`base_out'", replace 
log close

