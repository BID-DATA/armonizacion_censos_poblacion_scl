* (Versión Stata 12)
clear
set more off
*________________________________________________________________________________________________________________*

 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: ${censusFolder}
 * Se tiene acceso al servidor únicamente al interior del BID.
 *________________________________________________________________________________________________________________*

/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Chile
Año: 2002
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************
local PAIS CHL
local ANO "2002"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

include "../Base/base.do"


     ****************
     *** region_c ***
     ****************
   * Clasificación válida para 1960 y 1970
   gen geo1alt_cl=geolev1
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
/*la variable school no está presente en chile 1992 y 2002: construir con otra
****************
* asiste_ci    * 
**************** 
gen asiste_ci=1 if school==1
replace asiste_ci=. if school==0 // not in universe as missing 
replace asiste_ci=. if school==9 // Unknown/missing as missing
replace asiste_ci=0 if school==2
*/
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
	  
	
			***********************************
			***** VARIABLES DE MIGRACIÓN ******
			**********************************

      *******************
      ****migrante_ci****
      *******************
	gen migrante_ci = (nativity == 2)
	label var migrante_ci "=1 si es migrante"

      *******************
      **migantiguo5_ci***
      *******************
	gen migantiguo5_ci = (yrsimm > 5) & migrante_ci == 1
	replace migantiguo5_ci = . if (yrsimm == 99 | yrsimm == 98)
	label var migantiguo5_ci "=1 si es migrante antiguo (5 anos o mas)"

	**********************
	*** migrantelac_ci ***
	**********************
	gen migrantelac_ci= .
	label var migrantelac_ci "=1 si es migrante proveniente de un pais LAC"



	
compress

save "`base_out'", replace 
log close

