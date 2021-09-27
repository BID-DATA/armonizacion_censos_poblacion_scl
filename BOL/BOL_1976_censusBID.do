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

global ruta = "${censusFolder}"
local PAIS BOL
local ANO "1976"

local log_file = "$ruta\harmonized\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID.log"
local base_in  = "$ruta\census\\`PAIS'\\`ANO'\data_merge\\`PAIS'_`ANO'_IPUMS.dta"
local base_out = "$ruta\harmonized\\`PAIS'\data_arm\\`PAIS'_`ANO'_censusBID.dta"
                                                    
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Bolivia
Año:
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

use "`base_in'", clear


****************
* region_BID_c *
****************
	
gen region_BID_c=.

label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c



    *********
	*pais_c*
	*********
    gen str3 pais_c="BOL"
	
    ****************************************
    * Variables comunes a todos los países *
    ****************************************
    include "../Base/base.do"

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

