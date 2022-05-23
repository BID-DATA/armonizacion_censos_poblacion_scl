/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Perú
Año: 2017
Autores: María Reyes Retana
Última versión: May, 2022

======================================================
 Script de merge
****************************************************************************/
clear all
local PAIS PER

global ruta = "${censusFolder}"
global ruta_clean = "$ruta\\clean\\`PAIS'"
global ruta_raw = "Z:\census\\`PAIS'\2017\1_Bases de datos\CPV2017"

local log_file = "$ruta_clean\\log\\`PAIS'_`ANO'_censusBID_merge.log"
capture log close
capture log using "`log_file'", replace

global filepath "$ruta_raw\\pob\"

use "${filepath}\censo_pob_Peru_2017_1.dta" 

append using "${filepath}\censo_pob_Peru_2017_2.dta"
append using "${filepath}\censo_pob_Peru_2017_3.dta"

* merge

* Hace el merge
merge m:1 id_hog_imp_f id_viv_imp_f using "$ruta_raw\\censo_hog_viv_Peru_2017.dta", keepusing(id_hog_imp_f id_viv_imp_f c2_p6 c2_p11 c2_p10 c2_p5 c2_p3 c2_p5 c2_p12 c3_p2_11 c3_p2_4 c3_p2_14 c3_p2_9 c3_p2_13 c3_p2_10 c2_p13)
*drop if _merge<3
*drop _merge

save "$ruta_raw\\PER_2017_NOIPUMS.dta", replace
