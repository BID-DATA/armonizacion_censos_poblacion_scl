/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Mexico
Año: 2020
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

global censusFolder "\\sdssrv03\surveys\census"
global ruta = "${censusFolder}"
local PAIS MEX
local ANO "2020"

import delimited "$ruta/`PAIS'/`ANO'/raw/Viviendas00.csv", clear
save "$ruta/`PAIS'/`ANO'/raw/Viviendas00.dta", replace

import delimited "$ruta/`PAIS'/`ANO'/raw/Personas00.csv", clear
save "$ruta/`PAIS'/`ANO'/raw/Personas00.dta", replace

import delimited "$ruta/`PAIS'/`ANO'/raw/Migrantes00.csv", clear
save "$ruta/`PAIS'/`ANO'/raw/Migrantes00.dta", replace

use "$ruta/`PAIS'/`ANO'/raw/Personas00.dta", clear
merge m:1 id_viv using "$ruta/`PAIS'/`ANO'/raw/Viviendas00.dta"
drop _merge
save "$ruta/`PAIS'/`ANO'/raw/`PAIS'_`ANO'.dta", replace