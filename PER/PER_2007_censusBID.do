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
Año: 2007
Autores: Cesar Lins
Última versión: October, 2021

							SCL - IADB
****************************************************************************/


local PAIS PER
local ANO "2007"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
include "../Base/base.do"


*****************************************************
******* Variables specific for this census **********
*****************************************************

****** REGION *****************
gen region_c=geo1_pe2017
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
******************************

***** Education **************
* Use educpe
******************************
gen byte aedu_ci=.
replace aedu_ci=0  if educpe==100 | educpe==110 // Sin nivel o preescolar
replace aedu_ci=educpe-200  if educpe>200 & educpe<300 //primary 201--206 (6 years)
replace aedu_ci=6 + educpe-300  if educpe>300 & educpe<400 //secondary 301--306 (6 years)
replace aedu_ci=13 if educpe==611 | educpe==621 //tertiary incomplete
replace aedu_ci=14 if educpe==612 //non-universitary complete
replace aedu_ci=16 if educpe==622 //universitary complete

**************
***eduno_ci***
**************

gen byte eduno_ci=.
replace eduno_ci=0 if aedu_ci!=. & aedu_ci>0
replace eduno_ci=1 if aedu_ci==0


**************
***edupi_ci***
**************

gen byte edupi_ci=.
replace edupi_ci=1 if aedu_ci!=. & aedu_ci>0 & aedu_ci<6
replace edupi_ci=0 if aedu_ci!=. & edupi_ci!=1


**************
***edupc_ci***
**************

gen byte edupc_ci=.
replace edupc_ci=1 if aedu_ci!=. & aedu_ci>=6
replace edupc_ci=0 if aedu_ci!=. & edupc_ci!=1


**************
***edusi_ci***
**************

gen byte edusi_ci=.
replace edusi_ci=1 if aedu_ci!=. & aedu_ci>6 & aedu_ci<12
replace edusi_ci=0 if aedu_ci!=. & edusi_ci!=1


**************
***edusc_ci***
**************

gen byte edusc_ci=.
replace edusc_ci=1 if aedu_ci!=. & aedu_ci>=12
replace edusc_ci=0 if aedu_ci!=. & edusc_ci!=1

***************
***edus1i_ci***
***************

gen byte edus1i_ci=.
replace edus1i_ci=1 if edusi_ci==1 & aedu_ci<=8
replace edus1i_ci=0 if aedu_ci!=. & edus1i_ci!=1
*label variable edus1i_ci "1er ciclo de la secundaria incompleto"

***************
***edus1c_ci***
***************

gen byte edus1c_ci=.
replace edus1c_ci=1 if edusi_ci==1 & aedu_ci==9
replace edus1c_ci=0 if aedu_ci!=. & edus1c_ci!=1
*label variable edus1c_ci "1er ciclo de la secundaria completo"

***************
***edus2i_ci***
***************

gen byte edus2i_ci=.
replace edus2i_ci=1 if edusi_ci==1 & aedu_ci==10
replace edus2i_ci=0 if aedu_ci!=. & edus2i_ci!=1
*label variable edus2i_ci "2do ciclo de la secundaria incompleto"

***************
***edus2c_ci***
***************

gen byte edus2c_ci=(edusc_ci==1)
replace edus2c_ci=. if aedu_ci==.
*label variable edus2c_ci "2do ciclo de la secundaria completo"

**************
***eduui_ci***
**************

gen byte eduui_ci=(educpe==611)
replace eduui_ci=. if aedu_ci==.
*label variable eduui_ci "Universitaria incompleta"

***************
***eduuc_ci***
***************

gen byte eduuc_ci=(educpe==621 | educpe==622)
replace eduuc_ci=. if aedu_ci==.
*label variable eduuc_ci "Universitaria incompleta o mas"


***************
***edupre_ci***
***************

gen byte edupre_ci=(educpe==110)
replace edupre_ci=. if aedu_ci==.
*label variable edupre_ci "Educacion preescolar"


**************
***eduac_ci***
**************
gen byte eduac_ci=.
replace eduac_ci=1 if eduuc_ci==1
replace eduac_ci=0 if (educpe==611 | educpe==612)
label variable eduac_ci "Superior universitario vs superior no universitario"

****************
* tecnica_ci  **
****************
gen tecnica_ci=(eduac_ci==0)
replace tecnica_ci=. if aedu_ci==.

****************
***asispre_ci***
****************
gen asispre_ci=.
*la var asispre_ci "Asiste a educacion prescolar"

***************
***asiste_ci***
***************
gen asiste_ci=.
replace asiste_ci=1 if school==1
replace asiste_ci=0 if school==2
*label variable asiste_ci "Asiste actualmente a la escuela"


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

