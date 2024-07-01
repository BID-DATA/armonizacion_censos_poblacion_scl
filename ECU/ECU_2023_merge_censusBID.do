/***************************************************************************
							CENSOS POBLACIONALES
			 Script de merge - Unión de módulos en una sola base 
País: Ecuador
Año: 2023
Autores: María Isabel García
Última versión: 15 Mayo 2024
División: GDI - IADB
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

local PAIS ECU //cambia el país
local ANIO "2022"  // cambia el año

global ruta_raw = "C:\Users\maytes\OneDrive - Inter-American Development Bank Group\Documents\Censos\raw\\`PAIS'" //cambia la ruta 
global ruta_clean = "C:\Users\maytes\OneDrive - Inter-American Development Bank Group\Documents\Censos\clean\\`PAIS'" //cambia la ruta 


/****************************************************************************
   II. Unir módulos en una sola base
*****************************************************************************/


/* Union de todos los módulos.
use "$ruta_raw\\censo_viv_2022.dta" , clear
* Merge de los módulos //cambia el nombre de las bases.dta
merge 1:m id_viv using "$ruta_raw\\censo_hog_2022.dta"
tab v0201 _merge, m
keep if _merge==3
rename _merge _mergevh

merge 1:m id_hog using "$ruta_raw\\censo_mort_2022.dta"
*keep if _merge==3
rename _merge _mergevhn


merge m:m id_hog using "$ruta_raw\\censo_emig_2022.dta"
*keep if _merge==3
rename _merge _mergevhme


merge m:m id_hog using "$ruta_raw\\censo_pob_2022.dta"
keep if _merge==3
*/



* Union  vivienda, hogar y persona
use "$ruta_raw\\CPV_Vivienda_2022_Nacional.dta" , clear

* Merge de los módulos //cambia el nombre de las bases.dta
merge 1:m ID_VIV using "$ruta_raw\\CPV_Hogar_2022_Nacional.dta"

tab V0201 _merge, m
keep if _merge==3


rename _merge _mergevh

rename *, lower
merge 1:m id_hog using "$ruta_raw\\CPV_Población_2022_Nacional.dta"
keep if _merge==3

/****************************************************************************
  III. Verificar que merge se haya hecho correctamente y no hayan duplicados
*****************************************************************************/

duplicates report    //copies debe ser igual a 1
tab _merge // 1: solo en master, 2: solo en using, 3: en ambos
*drop if _merge<3
*drop _merge

/***************************************************************************
  IV. Guardar la base
****************************************************************************/

compress  
save "$ruta_raw\\`PAIS'_`ANIO'_NOIPUMS.dta", replace
