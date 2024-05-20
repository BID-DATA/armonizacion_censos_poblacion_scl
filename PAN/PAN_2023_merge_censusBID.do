/***************************************************************************
							CENSOS POBLACIONALES
			 Script de merge - Unión de módulos en una sola base 
País: Panamá
Año: 2023
Autores: Pablo Cortés
Última versión: 13/05/2024
División: MIG - IADB
****************************************************************************
INSTRUCCIONES:

	(1) Cambia el nombre de este script a Pais_Anio_merge_censusBID. 
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
		  
	(4) en la sección I, cambia la ruta de trabajo ruta_raw. Dentro de la ruta, 
		crea el folder raw y adentro el subfolder con el nombre del país. 
		Recuerda que debes utilizar el código iso-alpha3 para nombrar el país }
		(por ejemplo, Ecuador debe ser ECU)
		
			censusFolder>raw>ECU
		
		En esa ruta pega las bases de datos raw (pueden ser diferentes módulos)
		
	(5) En la sección II, cambia el nombre de los módulos según corresponda. 
		El Append es opcional. Si no es necesario para tus bases, borra esa 
		parte del código y continúa. 
		
	(6) En la sección III, verifica que el merge se haya hecho correctamente. 
		Si hay duplicados o missings en los ID, reportarlo al equipo SCL Data 
		para decidir el tratamiento.
		
	(7) En la sección IV, debes guardar la base con esta estructura 
		`Pais'_`ANO'_NOIPUMS.dta. Por ejemplo Ecuador 2017 debe ser
		ECU_2017_NOIPUMS.dta
		
	(8) Selecciona todo el contenido del do-file y ejecútalo 
	
*****************************************************************************/

clear all
set more off

/****************************************************************************
   I. Definir rutas y log file
****************************************************************************/

local PAIS PAN //cambia el país
local ANIO "2023"  // cambia el año

global ruta_raw = "${censusFolder}\\raw\\`PAIS'" //cambia la ruta 

cap log close
local date: di %tdCCYYNNDD daily("$S_DATE", "DMY") 
local log_file ="$ruta_raw\\`PAIS'_`ANIO'_NOIPUMS_`date'.log"
log using "`log_file'", replace

/****************************************************************************
   II. Unir módulos en una sola base
*****************************************************************************/

* Append de las bases de población //cambia el nombre de las bases.dta
use "$ruta_raw\\CEN2023_PERSONA.dta" , clear


* Merge de los módulos //cambia el nombre de las bases.dta
merge m:1 LLAVEVIV HOGAR using "$ruta_raw\\CEN2023_HOGAR.dta"
tab _merge
drop _merge
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                         4,064,780  (_merge==3)

*/

merge m:1  LLAVEVIV using "$ruta_raw\\CEN2023_VIVIENDA.dta"
tab _merge

/*
   Matching result from |
                  merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
         Using only (2) |    387,209        8.70        8.70
            Matched (3) |  4,064,780       91.30      100.00
------------------------+------------------------------
*/

/****************************************************************************
  III. Verificar que merge se haya hecho correctamente y no hayan duplicados
*****************************************************************************/
rename *, lower 
duplicates report llaveviv hogar npersona //copies debe ser igual a 1

/*

--------------------------------------
   Copies | Observations       Surplus
----------+---------------------------
        1 |      4451989             0
--------------------------------------

*/


tab _merge // 1: solo en master, 2: solo en using, 3: en ambos
drop if _merge<3
*drop _merge


* (387,209 observations deleted) observaciones de viviendas que no están en base de personas 
/***************************************************************************
  IV. Guardar la base
****************************************************************************/

compress  
save "$ruta_raw\\`PAIS'_`ANIO'_NOIPUMS.dta", replace

log close
