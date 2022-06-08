/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Guatemala
Año: 2018
Autores: Eric Torres
Última versión: May, 2022

======================================================
 Script de merge
****************************************************************************/
clear all
local PAIS GTM

global ruta = "${censusFolder}"
global ruta_clean = "$ruta\\clean\\`PAIS'"
global ruta_raw = "Z:\census\\`PAIS'\2018\"

local log_file = "$ruta_clean\\log\\`PAIS'_`ANO'_censusBID_merge.log"
capture log close
capture log using "`log_file'", replace

*****************************************************************************/

*from sav to dta
foreach x in HOGAR MIGRACION PERSONA VIVIENDA {
clear
import spss using "$ruta_raw\`x'_BDP.sav", case(lower) clear
save "$ruta_raw\`x'_BDP.dta", replace
}

*sorting
foreach x in HOGAR MIGRACION PERSONA VIVIENDA {
use "$ruta_raw\`x'_BDP.dta", clear
sort num_vivienda
save "$ruta_raw\`x'_BDP.dta", replace
}

*merge
use "$ruta_raw\HOGAR_BDP.dta", clear
merge m:1 num_vivienda using "$ruta_raw\vivienda_BDP.dta"
drop _merge
merge 1:m num_vivienda num_hogar using "$ruta_raw\PERSONA_BDP.dta"
drop _merge
merge m:m num_vivienda using "$ruta_raw\MIGRACION_BDP.dta"

save "$ruta_raw\\GTM_2018_NOIPUMS.dta", replace

log close


