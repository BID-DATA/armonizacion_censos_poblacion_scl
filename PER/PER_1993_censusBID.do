* (Versión Stata 12)
clear
set more off
*________________________________________________________________________________________________________________*

 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: ${censusFolder}
 * Se tiene acceso al servidor únicamente al interior del BID.
 *________________________________________________________________________________________________________________*
 
*Population and Housing Censuses/Harmonized Censuses - IPUMS


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Peru
Año: 1993
Autores: Cesar Lins
Última versión: October, 2021

							SCL - IADB
****************************************************************************/


local PAIS PER
local ANO "1993"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
include "../Base/base.do"


*****************************************************
******* Variables specific for this census **********
*****************************************************

****** REGION *****************
gen region_c=geo1_pe1993
label define region_c ///
1"Amazonas"	          ///
2"Ancash"	          ///
3"Apurimac"	          ///
4"Arequipa"	          ///
5"Ayacucho"	          ///
6"Cajamarca"	      ///
7"Callao"	          ///
8"Cusco"	          ///
9"Huancavelica"	      ///
10"Huanuco"	          ///
11"Ica"	              ///
12"Junin"	          ///
13"La libertad"	      ///
14"Lambayeque"	      ///
15"Lima"	          ///
16"Loreto"	          ///
17"Madre de Dios"	  ///
18"Moquegua"	      ///
19"Pasco"	          ///
20"Piura"	          ///
21"Puno"	          ///
22"San Martín"	      ///
23"Tacna"	          ///
24"Tumbes"	          ///
25"Ucayali"	

*******************************

*** Ingreso ******************
* Peru no tinene ninguna
* variable de ingreso en IPUMS
* se generan únicamrnte las de hog
******************************
gen ylm_ch =.
gen ynlm_ch=.


***** Education **************
* Use educpe
******************************
gen aedu_ci = yrschool 
replace aedu_ci=. if yrschool>=90 & yrschool<100 

**************
***eduno_ci***
**************
gen eduno_ci=(aedu_ci==0) // never attended or pre-school
replace eduno_ci=. if aedu_ci==. // NIU & missing


**************
***edupi_ci***
**************

gen edupi_ci=(aedu_ci>0 & aedu_ci<6) //
replace edupi_ci=. if aedu_ci==. // NIU & missing
replace edupi_ci = 1 if yrschool == 91 // some primary


**************
***edupc_ci***
**************

gen edupc_ci=(aedu_ci==6) 
replace edupc_ci=. if aedu_ci==. // NIU & missing


**************
***edusi_ci***
**************

gen edusi_ci=(aedu_ci>=7 & aedu_ci<11) // 7 a 10 anos de educación
replace edusi_ci=. if aedu_ci==. // NIU & missing
replace edusi_ci = 1 if yrschool == 92 | yrschool ==93 //some technical after primary or some secondary

**************
***edusc_ci***
**************

gen edusc_ci=(aedu_ci==11) // 11 anos de educación
replace edusc_ci=. if aedu_ci==. // NIU & missing

***************
***edus1i_ci***
***************

gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
replace edus1i_ci=. if aedu_ci==. // missing a los NIU & missing


***************
***edus1c_ci***
***************

gen byte edus1c_ci=(aedu_ci==9)
replace edus1c_ci=. if aedu_ci==. // missing a los NIU & missing

***************
***edus2i_ci***
***************

gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<11)
replace edus2i_ci=. if aedu_ci==. // missing a los NIU & missing

***************
***edus2c_ci***
***************

gen byte edus2c_ci=(aedu_ci==11)
replace edus2c_ci=. if aedu_ci==. // missing a los NIU & missing

**************
***eduui_ci***
**************

gen eduui_ci=(aedu_ci>=12 & aedu_ci<16 & edattain != 4) // 12 a 15 anos de educación
replace eduui_ci=. if aedu_ci ==. // NIU & missing
replace eduui_ci = 1 if yrschool == 94 // some terciary

***************
***eduuc_ci***
***************

gen eduuc_ci=(aedu_ci>=16)
replace eduuc_ci=1 if edattain == 4
replace eduuc_ci=. if aedu_ci==. // NIU & missing

***************
***edupre_ci***
***************

gen byte edupre_ci=(educpe==110)
replace edupre_ci=. if aedu_ci==.
*label variable edupre_ci "Educacion preescolar"


***************
***asiste_ci***
***************
gen asiste_ci=.
replace asiste_ci=1 if school==1
replace asiste_ci=0 if school==2
*label variable asiste_ci "Asiste actualmente a la escuela"

***************
***literacy***
***************
gen literacy=. if lit==0
replace literacy=. if lit==9
replace literacy=0 if lit==1
replace literacy=1 if lit==2

*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Cesar Lins & Nathalia Maya - Septiembre 2021	

			
	***************
	***afroind_ci***
	***************
gen afroind_ci=. 

	***************
	***afroind_ch***
	***************
gen afroind_ch=. 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=.		

	*******************
	***dis_ci***
	*******************
gen dis_ci=. 

	*******************
	***dis_ch***
	*******************
gen dis_ch=. 



*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"


compress

save "`base_out'", replace 
log close

