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
local PAIS JAM

global ruta = "${censusFolder}"
global ruta_clean = "$ruta\\clean\\`PAIS'"
global ruta_raw = "$ruta\\raw\\`PAIS'"

local log_file = "$ruta_clean\\log\\`PAIS'_`ANO'_censusBID_merge.log"
capture log close
capture log using "`log_file'", replace

local hh_file "$ruta_raw\2011\data_orig\2011 census housing data complete id all users"
local p_file "$ruta_raw\\JAM population census _2011 _four digit private only.dta"
local p_file_dis "$ruta_raw\2011\data_orig\\JAM2011_census_population_data_complete_id_statin.dta"


** Crea el id de hogar y hace el merge con las anteriores
use "`hh_file'", clear

gen str14 idh_ch = string(parish,"%02.0f") + string(constitu,"%02.0f") + string(enumerat,"%03.0f") + string(housing,"%03.0f") + string(dwelling,"%02.0f") + string(househol,"%02.0f")

save "$ruta_raw\\2011\data_orig\\JAM_2011_census_merge_HH.dta", replace

use "`p_file_dis'", clear
gen str14 idh_ch = string(parish,"%02.0f") + string(constitu,"%02.0f") + string(enumerat,"%03.0f") + string(housing,"%03.0f") + string(dwelling,"%02.0f") + string(househol,"%02.0f")

* Hace el merge
merge m:1 parish idh_ch using "$ruta_raw\\JAM_2011_census_merge_HH.dta"
tab _merge
drop if _merge==2
drop _merge

save "$ruta_raw\\2011\data_orig\\JAM_2011_NOIPUMS.dta", replace

 
capture log close