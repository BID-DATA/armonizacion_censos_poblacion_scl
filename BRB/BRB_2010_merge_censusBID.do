/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Barbados
Año: 2010
Autores: Mayte Ysique
Última versión: Octubre, 2023

======================================================
 Script de merge
****************************************************************************/
clear all
local PAIS BRB
local ANO "2010"

global ruta = "${censusFolder}"
global ruta_clean = "$ruta\\clean\\`PAIS'"
global ruta_raw = "$ruta\\raw\\`PAIS'"

local log_file = "$ruta_clean\\log\\`PAIS'_`ANO'_censusBID_merge.log"
capture log close
capture log using "`log_file'", replace


use "$ruta_raw\\`ANO'\Data\Housing.dta" 

duplicates report ed building dwelling_unit household
/*

Duplicates in terms of ed building dwelling_unit household

--------------------------------------
   Copies | Observations       Surplus
----------+---------------------------
        1 |        94171             0
        2 |            2             1
--------------------------------------

There is one duplicated observation, but it is unoccupied, so it will be erased when we merge with the database of population

*/

duplicates drop  ed building dwelling_unit household, force

*Merging
merge 1:m ed building dwelling_unit household using "$ruta_raw\\`ANO'\Data\\Population.dta"
keep if _merge==3
drop _merge

*Genereting a person ID
sort ed building dwelling_unit household rth
bysort ed building dwelling_unit household: gen id_person = _n

save "$ruta_raw\\`PAIS'_`ANO'_NOIPUMS.dta", replace
