/***************************************************************************
							CENSOS POBLACIONALES
			 Script de merge - Unión de módulos en una sola base 
País: CHL
Año: 2024
Autores: Matias Rodriguez (SCL/SCL)
Última versión: Enero 12, 2026
División: SCL - IADB
****************************************************************************
INSTRUCCIONES:

	(1) Cambia el nombre de este script a ISOalpha3Pais_Anio_merge_censusBID. 
		Por ejemplo Ecuador 2017 será: ECU_2017_merge_censusBID.do
		
	(2) Sigue la estructura y estilo de este script, pero ten en cuenta que
		el contenido es referencial y que debes adaptarlo al país que te toque 
		armonizar. 
		
	(3) Cambia la información que está en la parte superior. 
		- En País pon el nombre completo, por ejemplo Panamá. 
		- En año coloca un número entero de 4 dígitos, por ejemplo 2024. 
		- En autores pon tu 1er nombre y 1er apellido, por ejemplo Juan Casas.
		- En última versión coloca la fecha en que la termines el script, por
		  ejemplo 22ABR2024
		- En división coloca las siglas de tu división en el IADB, por ejemplo 
		  SCL/GDI - IADB
		  
	(4) en la sección I, cambia la ruta de trabajo ruta_raw. Dentro de la ruta, crea el folder 
		raw y adentro el subfolder con el nombre del país. Recuerda que debes 
		utilizar el código iso-alpha3 para nombrar el país (por ejemplo, Ecuador 
		debe ser ECU)
		
			censusFolder>raw>ECU
		
		En esa ruta pega las bases de datos raw (pueden ser diferentes módulos)
		
	(5) En la sección II, cambia el nombre de los módulos según corresponda. El Append es 
		opcional. Si no es necesario para tus bases, borra esa parte del código 
		y continúa. 
		
	(6) En la sección III, verifica que el merge se haya hecho correctamente. Si hay 
		duplicados, reportarlo al equipo SCL Data para decidir el tratamiento.
		
	(7) En la sección IV, debes guardar la base con esta estructura 
		`ISOalpha3Pais'_`ANO'_NOIPUMS.dta. Por ejemplo Ecuador 2017 debe ser
		ECU_2017_NOIPUMS.dta
		
	(8) Selecciona todo el contenido del do-file y ejecútalo 
	
*****************************************************************************/

clear all
set more off

/****************************************************************************
   I. Definir rutas y log file
****************************************************************************/

local PAIS CHL
local ANIO "2024"

global ruta_raw = "${censusFolder}\\raw\\`PAIS'\\`ANIO'"

cap log close
local date: di %tdCCYYNNDD daily("$S_DATE", "DMY") 
local log_file = "$ruta_raw\\`PAIS'_`ANIO'_NOIPUMS_`date'.log"
log using "`log_file'"

/****************************************************************************
   II. Importar módulos
*****************************************************************************/
* Descarga dataset viviendas
import delimited "$ruta_raw\\data_orig\\viviendas_censo2024\\viviendas_censo2024.csv", delimiter(";") clear
save "$ruta_raw\\data_orig\\viviendas_censo2024.dta", replace

* Descarga dataset hogares
import delimited "$ruta_raw\\data_orig\\hogares_censo2024\\hogares_censo2024.csv", delimiter(";") clear
save "$ruta_raw\\data_orig\\hogares_censo2024.dta", replace

* Descarga dataset personas
import delimited "$ruta_raw\\data_orig\\personas_censo2024\\personas_censo2024.csv", delimiter(";") clear
save "$ruta_raw\\data_orig\\personas_censo2024.dta", replace

/****************************************************************************
  III. Unir módulos en una sola base y verificar que merge se haya hecho 
  correctamente y no hayan duplicados
*****************************************************************************/
use "$ruta_raw\\data_orig\\personas_censo2024.dta", clear

* Left join (merge) with viviendas dataset
merge m:1 id_vivienda region provincia comuna area tipo_operativo ///
    using "$ruta_raw\\data_orig\\viviendas_censo2024.dta"

duplicates report    //copies debe ser igual a 1
tab _merge // 1: solo en master, 2: solo en using, 3: en ambos
drop _merge

merge m:1 id_hogar id_vivienda region provincia comuna area tipo_operativo ///
    using "$ruta_raw\\data_orig\\hogares_censo2024.dta"
	
duplicates report    //copies debe ser igual a 1
tab _merge // 1: solo en master, 2: solo en using, 3: en ambos
drop _merge

/***************************************************************************
  IV. Guardar base
****************************************************************************/

compress  
local PAIS CHL
local ANIO "2024"
save "$ruta_raw\\data_merge\\`PAIS'_`ANIO'_NOIPUMS.dta", replace

log close
