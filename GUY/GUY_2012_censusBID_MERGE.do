* (Versión Stata 17)

clear
set more off

 *________________________________________________________________________________________________________________*
 
 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: ${censusFolder}
 * Se tiene acceso al servidor únicamente al interior del BID.
 *________________________________________________________________________________________________________________*
 
*Population and Housing Censuses/ Not Harmonized by IPUMS

/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Guyana
Año: 2012
Autores: Agustina Thailinger SCL/EDU 
Última versión: 2022

							SCL/EDU - IADB
****************************************************************************/
****************************************************************************

local PAIS GUY
local ANO "2012"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

global ruta = "${censusFolder}"

use "\\sdssrv03\surveys\census\GUY\c12hhall.dta", clear

drop if serialno==""

sort serialno
quietly by serialno: gen dup=cond(_N==1,0,_n)
drop if dup==2 | dup==3
drop dup

sort serialno
quietly by serialno: gen dup=cond(_N==1,0,_n)
drop dup

save "\\sdssrv03\surveys\census\GUY\c12hhall_1.dta", replace

use "\\sdssrv03\surveys\census\GUY\c12ppall.dta", clear

merge m:1 serialno using "\\sdssrv03\surveys\census\GUY\c12hhall_1.dta", force

save "\\sdssrv03\surveys\census\GUY\GUY_2012_censusBID.dta", replace