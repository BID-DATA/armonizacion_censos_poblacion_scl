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
local PAIS MEX
local ANO "2020"

local log_file = "$ruta\harmonized\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID.log"
local base_in  = "$ruta\census\\`PAIS'\\`ANO'\data_merge\\`PAIS'_`ANO'_IPUMS.dta"
local base_out = "$ruta\harmonized\\`PAIS'\data_arm\\`PAIS'_`ANO'_censusBID.dta"
                                                    
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Mexico
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
    gen str3 pais_c="MEX"
	
    ****************************************
    * Variables comunes a todos los países *
    ****************************************
    include "../Base/base.do"


********************************
*** Health indicators **********
********************************

	gen discapacidad_ci =.
	replace discapacidad_ci =1 if disabled ==1
	label var discapacidad_ci "Discapacidad"

	gen ceguera_ci=.
	replace ceguera_ci=1 if disblnd==1
	label var ceguera_ci "Ciego o con discpacidad visual"
	
	gen sordera_ci  =.
	replace sordera_ci  =1 if disdeaf ==1
	label var sordera_ci "Sordera o con discpacidad auditiva"

	gen mudez_ci=.
	replace mudez_ci=1 if dismute==1
	label var mudez_ci "Mudo o con discpacidad de lenguaje"

	gen dismental_ci=.
	replace dismental_ci=1 if dismntl==1
	label var dismental_ci "Discapacidad mental"



compress

save "`base_out'", replace 
log close

