/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Jamaica
Año: 2011
Autores: Nathalia Maya Scarpeta y Cesar Lins
Última versión: Abr, 2022

======================================================
 Script de merge
****************************************************************************/


global ruta = "${censusFolder}"


local log_file = "$ruta\\clean\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID_merge.log"
capture log close
capture log using "`log_file'", replace

local hh_file "$ruta\\raw\\`PAIS'\\JAM2011 census housing data complete id all users.dta"
local p_file "$ruta\\raw\\`PAIS'\\JAM population census _2011 _four digit private only.dta"


** Crea el id de hogar y salva una copia para el merge
use "`hh_file'", clear
gen str14 idh_ch = string(parish,"%02.0f") + string(constitu,"%02.0f") + string(enumerat,"%03.0f") + string(housing,"%03.0f") + string(dwelling,"%02.0f") + string(househol,"%02.0f")

save "$ruta\\raw\\`PAIS'\\JAM_2011_census_merge_HH.dta", replace


** Crea el id de hogar y de persona y salva un copia para el merge
use "`p_file'", clear
gen str14 idh_ch = string(parish,"%02.0f") + string(constitu,"%02.0f") + string(enumerat,"%03.0f") + string(housing,"%03.0f") + string(dwelling,"%02.0f") + string(househol,"%02.0f")


* Hace el merge
merge m:1 idh_ch using "$ruta\\raw\\`PAIS'\\JAM_2011_census_merge_HH.dta"
drop if _merge<3
drop _merge

save "$ruta\\raw\\`PAIS'\\JAM_2011_NOIPUMS.dta", replace
capture log close