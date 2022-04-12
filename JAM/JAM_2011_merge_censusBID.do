/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Jamaica
Año: 2011
Autores: Nathalia Maya Scarpeta y Cesar Lins
Última versión: Abr, 2022

======================================================
 Script de merge
****************************************************************************/
clear all

global ruta = "${censusFolder}"
global ruta_clean = "$ruta\\clean\\`PAIS'"
global ruta_raw = "$ruta\\raw\\`PAIS'"

local log_file = "$ruta_clean\\log\\`PAIS'_`ANO'_censusBID_merge.log"
capture log close
capture log using "`log_file'", replace

local hh_file "$ruta_raw\\JAM2011 census housing data complete id all users.dta"
local p_file "$ruta_raw\\JAM population census _2011 _four digit private only.dta"
local p_file_dis "$ruta_raw\\JAM2011 census population data complete id statin.dta"


** Crea el id de hogar y salva una copia para el merge
use "`hh_file'", clear
gen str14 idh_ch = string(parish,"%02.0f") + string(constitu,"%02.0f") + string(enumerat,"%03.0f") + string(housing,"%03.0f") + string(dwelling,"%02.0f") + string(househol,"%02.0f")

save "$ruta_raw\\JAM_2011_census_merge_HH.dta", replace

** Crea el id de hogar y de persona y salva un copia para el merge
* PROBLEM: id variables do not uniquely identify observations in this dataset
*use "`p_file_dis'", clear
*gen str14 idh_ch = string(parish,"%02.0f") + string(constitu,"%02.0f") + string(enumerat,"%03.0f") + string(housing,"%03.0f") + string(dwelling,"%02.0f") + string(househol,"%02.0f")

*keep pg_link parish idh_ch individu q1_7seei q1_7hear q1_7walk q1_7memo q1_7lift q1_7self q1_7comm

*save "$ruta_raw\\JAM_2011_census_merge_PDIS.dta", replace

** Crea el id de hogar y hace el merge con las anteriores
use "`p_file'", clear
gen str14 idh_ch = string(parish,"%02.0f") + string(constitu,"%02.0f") + string(enumerat,"%03.0f") + string(housing,"%03.0f") + string(dwelling,"%02.0f") + string(househol,"%02.0f")


* Hace el merge
merge m:1 parish idh_ch using "$ruta_raw\\JAM_2011_census_merge_HH.dta"
drop if _merge<3
drop _merge

save "$ruta_raw\\JAM_2011_NOIPUMS.dta", replace

* Merge con las variables de discapacidad q1_7*
* PROBLEM: id variables do not uniquely identify observations in this dataset
*merge 1:1 parish idh_ch individu using "$ruta_raw\\JAM_2011_census_merge_PDIS.dta"
*drop if _merge<3
*drop _merge

*save "$ruta_raw\\JAM_2011_NOIPUMS.dta", replace

capture log close