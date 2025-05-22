/***************************************************************************
							CENSOS POBLACIONALES
			 Script de merge - Unión de módulos en una sola base 
País: SLV
Año: 2024
Autores: Jillie Chang
Última versión: 01MAY2025
División: SCL/SCL - IADB
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

local PAIS SLV //cambia el país
local ANIO "2024"  // cambia el año

global ruta_raw = "${censusFolder}\\raw\\`PAIS'\\`ANIO'\\data_orig" //cambia la ruta 

cap log close
local date: di %tdCCYYNNDD daily("$S_DATE", "DMY") 
local log_file ="$ruta_raw\\`PAIS'_`ANIO'_NOIPUMS_`date'.log"
log using "`log_file'", replace

/****************************************************************************
   II. Unir módulos en una sola base
*****************************************************************************/

use "$ruta_raw\\Población.dta" , clear
duplicates report cod_per
/*
--------------------------------------
   Copies | Observations       Surplus
----------+---------------------------
        1 |      6029976             0
-------------------------------------- */

merge m:1 cod_hog using "$ruta_raw\\Hogares.dta"
tab _merge
/* 115,539 personas no tiene  información de hogar. Se mantienen.
   Matching result from |
                  merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        Master only (1) |    115,539        1.92        1.92
            Matched (3) |  5,914,437       98.08      100.00
------------------------+-----------------------------------
                  Total |  6,029,976      100.00 */
drop _merge	
egen unique_tag = tag(cod_hog)
count if unique_tag ==  1  //  1,922,427 hogares
* Luego de hacer el merge hay 1,922,427 hogares. Según el Excel del folder docs son 1 890 571. Este número es diferente en otras publicaciones. Estas diferencias se deben a que el Banco Central hace estimados sobre la base de las consideraciones descritas en la p. 12 de Uso_de_la_Base_de_Datos_del_Censo_2024.pdf
drop unique_tag 
 
merge m:1 cod_viv using "$ruta_raw\\Viviendas.dta"
tab _merge
/* 418,945 registros que no está en la base de personas (hay viviendas pero no hay personas residiendo en ellas). Según el  protocolo de SCL, se mantienen en el merge.
   Matching result from |
                  merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
         Using only (2) |    428,945        6.64        6.64
            Matched (3) |  6,029,976       93.36      100.00
------------------------+-----------------------------------
                  Total |  6,458,921      100.00 */
egen unique_tag = tag(cod_viv)
count if unique_tag ==  1  //  2,270,026 vivienda
drop unique_tag 

/****************************************************************************
  III. Verificar que merge se haya hecho correctamente y no hayan duplicados
*****************************************************************************/
duplicates report cod_viv cod_hog cod_per //copies debe ser igual a 1
tab _merge // 1: solo en master, 2: solo en using, 3: en ambos
*drop if _merge<3  //(428,945 observations deleted)
drop _merge

/***************************************************************************
  IV. Guardar la base
****************************************************************************/
compress  
save "$ruta_raw\\`PAIS'_`ANIO'_NOIPUMS.dta", replace

log close