/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Guatemala
Año: 2018
Autores: Eric Torres
Última versión: May, 2022

======================================================
 Script de merge
****************************************************************************
*/

clear all
local PAIS GTM

global ruta = "${censusFolder}"
global ruta_clean = "$ruta\\clean\\`PAIS'"
global ruta_raw = "$ruta\\raw\\`PAIS'\2018\data_orig\GTM2018_original"

local log_file = "$ruta_clean\\log\\`PAIS'_`ANO'_censusBID_merge.log"

capture log using "`log_file'", replace

*****************************************************************************

/**from sav to dta: Solo correr una vez

	foreach x in HOGAR MIGRACION PERSONA VIVIENDA {
	clear
	import spss using "$ruta_raw\\`x'_BDP.sav", case(lower) clear
	save "$ruta_raw\\`x'_BDP.dta", replace
	}

*/

ssc install elabel

*merge
use "$ruta_raw\VIVIENDA_BDP.dta", clear
	elabel rename (*) (*_viv)
	drop if inrange(pcv4,2,4) // Solo nos quedamos con las viviendas ocupadas y censadas
merge 1:m num_vivienda using "$ruta_raw\PERSONA_BDP.dta"
	elabel rename (*) (*_pob)
	drop _merge
merge m:1 num_vivienda num_hogar using "$ruta_raw\HOGAR_BDP.dta"
	elabel rename (*) (*_hog)
	drop _merge
*merge m:m num_vivienda using "$ruta_raw\MIGRACION_BDP.dta", nolabel // No es necesario, pues son para los emigrantes
count // 14,901,286 obs -> corresponde a los registros oficiales

order departamento municipio cod_municipio zona area num_vivienda pcv1 pcv2 pcv3 pcv4 pcv5 num_hogar pch*

save "$ruta\\raw\\`PAIS'\2018\data_orig\GTM_2018_NOIPUMS.dta", replace

log close

