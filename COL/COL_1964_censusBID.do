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
País: Colombia
Año:
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

local PAIS COL
local ANO "1964"

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
 
gen region_c =.
replace region_c=1 if geo1_co1964 ==5 /*Antioquia*/ 
replace region_c=2 if geo1_co1964 ==8 /*Atlántico*/ 
replace region_c=3 if geo1_co1964 ==11 /*Bogotá*/ 
replace region_c=4 if geo1_co1964 ==13 /*Bolívar*/ 
replace region_c=5 if geo1_co1964 ==15 /*Boyacá*/ 
replace region_c=6 if geo1_co1964 ==17 /*Caldas*/ 
replace region_c=7 if geo1_co1964 ==18 /*Caquetá*/ 
replace region_c=8 if geo1_co1964 ==19 /*Cauca*/ 
replace region_c=9 if geo1_co1964 ==20 /*Cesar*/ 
replace region_c=10 if geo1_co1964 ==23 /*Córdoba*/ 
replace region_c=11 if geo1_co1964 ==25 /*Cundinamarca*/ 
replace region_c=12 if geo1_co1964 ==27 /*Chocó*/ 
replace region_c=13 if geo1_co1964 ==41 /*Huila*/ 
replace region_c=14 if geo1_co1964 ==44 /*La Guajira*/
replace region_c=15 if geo1_co1964 ==47 /*Magdalena*/ 
replace region_c=16 if geo1_co1964 ==50 /*Meta*/ 
replace region_c=17 if geo1_co1964 ==52 /*Nariño*/ 
replace region_c=18 if geo1_co1964 ==54/*Norte de Santander*/ 
replace region_c=19 if geo1_co1964 ==63 /*Quindío*/ 
replace region_c=20 if geo1_co1964 ==66 /*Risaralda*/ 
replace region_c=21 if geo1_co1964 ==68 /*Santander*/ 
replace region_c=22 if geo1_co1964 ==70 /*Sucre*/ 
replace region_c=23 if geo1_co1964 ==73 /*Tolima*/ 
replace region_c=24 if geo1_co1964 ==76 /*Valle*/ 
replace region_c=25 if geo1_co1964 ==81 /*Arauca*/ 
replace region_c=26 if geo1_co1964 ==85 /*Casanare*/ 
replace region_c=27 if geo1_co1964 ==86 /*Putumayo*/ 
replace region_c=28 if geo1_co1964 ==88 /*San Andrés*/ 
replace region_c=29 if geo1_co1964 ==95 /*Amazonas, Guaviare, Vaupes, Vichada, Guania*/ 

label define region_c 1"Antioquia" 2"Atlántico" 3"Bogotá" 4"Bolívar" 5"Boyacá" 6"Caldas" 7"Caquetá" 8"Cauca" 9"Cesár" 10"Córdoba" 11"Cundinamarca" 12"Chocó" 13"Huila" 14"La Guajira" 15"Magdalena" 16"Meta" 17"Nariño" 18"Norte de Santander" 19"Quindío" 20"Risaralda" 21"Santander" 22"Sucre" 23"Tolima" 24"Valle" 25"Arauca" 26"Casanare" 27"Putumayo" 28"San Andrés" 29"Amazonas, Guaviare, Vaupes, Vichada, Guania"	
label value region_c region_c
	
	***********************************
	***    VARIABLES DE MIGRACIÓN.  ***
	***********************************	

      *******************
      ****migrante_ci****
 ylm_ch      *******************
	gen migrante_ci = (nativity == 2)
	 
      *******************
      **migantiguo5_ci***
      *******************
	gen migantiguo5_ci = (migyrs1 >= 5) & migrante_ci == 1
	replace migantiguo5_ci = . if migantiguo5_ci == 0 & nativity != 2
	
	**********************
	*** migrantelac_ci ***
	**********************
	
	gen migrantelac_ci= 1 if inlist(bplcountry, 21100, 23010, 22060, 23110, 22020, 22040, 23100, 22030, 23060, 23140, 22050, 23040, 23100, 29999, 23130, 23030, 21250, 21999, 22010, 22070, 22080, 22999)
	replace migrantelac_ci = 0 if migrantelac_ci == . & nativity == 2


compress

save "`base_out'", replace 
log close

