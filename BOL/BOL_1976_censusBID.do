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

local PAIS BOL
local ANO "1976"


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Bolivia
Año:
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


   gen region_c=.
   replace region_c=1 if geo1_bo==68001  
   replace region_c=2 if geo1_bo==68002
   replace region_c=3 if geo1_bo==68003
   replace region_c=4 if geo1_bo==68004
   replace region_c=5 if geo1_bo==68005
   replace region_c=6 if geo1_bo==68006
   replace region_c=7 if geo1_bo==68007
   replace region_c=8 if geo1_bo==68008
   replace region_c=9 if geo1_bo==68009
   
   label define region_c 1 "Chuqisaca" 2 "La paz" 3 "Cochabamba" 4 "Oruro" 5 "Potosá" 6 "Tarija" 7 "Santa Cruz" 8 "Beni" 9 "Pando", add modify 
   label value region_c region_c 
 


********************************
*** Health indicators **********
********************************
	gen discapacidad_ci =.
	label var discapacidad_ci "Discapacidad"

	gen ceguera_ci=.
	label var ceguera_ci "Ciego o con discpacidad visual"
	
	gen sordera_ci  =.
	label var sordera_ci "Sordera o con discpacidad auditiva"

	gen mudez_ci=.
	label var mudez_ci "Mudo o con discpacidad de lenguaje"

	gen dismental_ci=.
	label var dismental_ci "Discapacidad mental"	
	
	***********************************
	***    VARIABLES DE MIGRACIÓN.  ***
	***********************************
			

      *******************
      ****migrante_ci****
      *******************
	gen migrante_ci = (nativity == 2)
	 
      *******************
      **migantiguo5_ci***
      *******************
	gen migantiguo5_ci = (mig1_5_bo == 68097)
	
	
	**********************
	*** migrantelac_ci ***
	**********************
	
	gen migrantelac_ci= 1 if inlist(bplcountry, 21100, 23010, 22060, 23110, 22020, 22040, 23050, 23100, 22030, 23060, 23140, 22050, 23040, 23100, 29999, 23130, 23030, 21250, 21999, 22010, 22070, 22080, 22999)
	replace migrantelac_ci = 0 if migrantelac_ci == . & nativity == 2


compress

save "`base_out'", replace 
log close