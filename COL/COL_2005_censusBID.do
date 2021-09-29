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
País: Colombia
Año: 2005
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS COL
local ANO "2005"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
include "../Base/base.do"

*****************************************************
******* Variables specific for this census **********
*****************************************************

****************
 *** region_c ***
 ****************
gen region_c =.
replace region_c=1 if geo1_co2005 ==5 /*Antioquia*/ 
replace region_c=2 if geo1_co2005 ==8 /*Atlántico*/ 
replace region_c=3 if geo1_co2005 ==11 /*Bogotá*/ 
replace region_c=4 if geo1_co2005 ==13 /*Bolívar*/ 
replace region_c=5 if geo1_co2005 ==15 /*Boyacá*/ 
replace region_c=6 if geo1_co2005 ==17 /*Caldas*/ 
replace region_c=7 if geo1_co2005 ==18 /*Caquetá*/ 
replace region_c=8 if geo1_co2005 ==19 /*Cauca*/ 
replace region_c=9 if geo1_co2005 ==20 /*Cesar*/ 
replace region_c=10 if geo1_co2005 ==23 /*Córdoba*/ 
replace region_c=11 if geo1_co2005 ==25 /*Cundinamarca*/ 
replace region_c=12 if geo1_co2005 ==27 /*Chocó*/ 
replace region_c=13 if geo1_co2005 ==41 /*Huila*/ 
replace region_c=14 if geo1_co2005 ==44 /*La Guajira*/
replace region_c=15 if geo1_co2005 ==47 /*Magdalena*/ 
replace region_c=16 if geo1_co2005 ==50 /*Meta*/ 
replace region_c=17 if geo1_co2005 ==52 /*Nariño*/ 
replace region_c=18 if geo1_co2005 ==54/*Norte de Santander*/ 
replace region_c=19 if geo1_co2005 ==63 /*Quindío*/ 
replace region_c=20 if geo1_co2005 ==66 /*Risaralda*/ 
replace region_c=21 if geo1_co2005 ==68 /*Santander*/ 
replace region_c=22 if geo1_co2005 ==70 /*Sucre*/ 
replace region_c=23 if geo1_co2005 ==73 /*Tolima*/ 
replace region_c=24 if geo1_co2005 ==76 /*Valle*/ 
replace region_c=25 if geo1_co2005 ==81 /*Arauca*/ 
replace region_c=26 if geo1_co2005 ==85 /*Casanare*/ 
replace region_c=27 if geo1_co2005 ==86 /*Putumayo*/ 
replace region_c=28 if geo1_co2005 ==88 /*San Andrés*/ 
replace region_c=29 if geo1_co2005 ==95 /*Amazonas, Guaviare, Vaupes, Vichada, Guania*/ 

label define region_c 1"Antioquia" 2"Atlántico" 3"Bogotá" 4"Bolívar" 5"Boyacá" 6"Caldas" 7"Caquetá" 8"Cauca" 9"Cesár" 10"Córdoba" 11"Cundinamarca" 12"Chocó" 13"Huila" 14"La Guajira" 15"Magdalena" 16"Meta" 17"Nariño" 18"Norte de Santander" 19"Quindío" 20"Risaralda" 21"Santander" 22"Sucre" 23"Tolima" 24"Valle" 25"Arauca" 26"Casanare" 27"Putumayo" 28"San Andrés" 29"Amazonas, Guaviare, Vaupes, Vichada, Guania"	
label value region_c region_c

**********************************
**** VARIABLES DE INGRESO ****
**********************************
	
	 ***********
	  *ylm_ci*
	 ***********
   gen ylm_ci=.
   cap confirm variable incearn
   if (_rc==0) {
   replace ylm_ci = incearn
   replace ylm_ci =. if incearn==99999999 | incearn==99999998
   }

	 *********
	 *ynlm_ci*
	 *********
   gen ynlm_ci=.
   cap confirm variable incwel
   if (_rc==0) {
   replace ynlm_ci=incwel
   replace ynlm_ci=. if incwel== 99999999 | incearn==99999998
   } 
   
     ***********
	  *ylm_ch*
	 ***********
   by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1
   
   /*variables que faltan generar
   gen ylmho_ci=ylm_ci/(horaspri_ci*4.3)
   replace ylmho_ci=. if ylmho_ci<=0
   gen nrylm_ci=(ylm_ci=. & emp_ci==1)
   replace nrylm_ci=. if emp_ci!=1
   sort idh_ch: egen nrylm_ch=max(nrylm_ci) if miembros_ci==1
   by idh_ch, sort: egen ylmnr_ch=sum(ylm_ci) if miembros_ci==1
   replace ylmnr_ch=. if nrylm_ch==1 
   gen tcylm_ci=.
   gen tcylm_ch=.*/

*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
**Pregunta: 

gen afroind_ci=. 
replace afroind_ci=1  if race == 30
replace afroind_ci=2 if race == 20
replace afroind_ci=3 if race == 10 | race == 60 


	***************
	***afroind_ch***
	***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=2005


********************
*** discapacidad ***
********************
gen dis_ci=.
gen dis_ch=.

********************************
*** Variables de migracion *****
********************************
	gen migrante_ci =.
	

	gen migantiguo5_ci=.
	
	
	gen migrantelac_ci  =.

*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

compress

save "`base_out'", replace 
log close

