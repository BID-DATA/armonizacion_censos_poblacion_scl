/***************************************************************************
							CENSOS POBLACIONALES
			 Script de merge - Unión de módulos en una sola base 
País: BHS
Año: 2022
Autores: Matias Rodriguez (SCL/SCL)
Última versión: Octumbre 9, 2025
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

local PAIS BHS 
local ANIO "2022"  

global ruta_raw = "${censusFolder}\\raw\\`PAIS'"

cap log close
local date: di %tdCCYYNNDD daily("$S_DATE", "DMY") 
local log_file ="$ruta_raw\\2022\\`PAIS'_`ANIO'_NOIPUMS_`date'.log"
log using "`log_file'", replace

/****************************************************************************
   II. Unir módulos en una sola base
*****************************************************************************/
* Append de las bases de población //cambia el nombre de las bases.dta
use "$ruta_raw\\2022\\2022 Census of Population and Housing_BAHAMAS_persons.dta" , clear

* Merge de los módulos //cambia el nombre de las bases.dta
merge m:1 hhid  using "$ruta_raw\\2022\\2022 Census of Population and Housing_households BAHAMAS.dta"

/****************************************************************************
  III. Verificar que merge se haya hecho correctamente y no hayan duplicados
*****************************************************************************/

duplicates report    //copies debe ser igual a 1
tab _merge // 1: solo en master, 2: solo en using, 3: en ambos
drop if _merge<3
drop _merge

/***************************************************************************
  IV. Guardar base
****************************************************************************/

compress  
save "$ruta_raw\\2022\\BHS_2022_NOIPUMS.dta", replace

log close
