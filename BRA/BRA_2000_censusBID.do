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
País: Brasil
Año: 2000
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS BRA
local ANO "2000"

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
 
 gen region_c=.
 replace region_c=1 if geo1_br2000 ==11  /*Rondônia*/
 replace region_c=2 if geo1_br2000 ==12  /*Acre*/
 replace region_c=3 if geo1_br2000 ==13 /*Amazonas*/
 replace region_c=4 if geo1_br2000 ==14 /*Roraima*/
 replace region_c=5 if geo1_br2000 ==15 /*Pará*/
 replace region_c=6 if geo1_br2000 ==16 /*Amapá*/
 replace region_c=7 if geo1_br2000 ==17 /*Tocantins*/
 replace region_c=8 if geo1_br2000 ==21 /*Maranhão*/
 replace region_c=9 if geo1_br2000 ==22 /*Piauí*/
 replace region_c=10 if geo1_br2000 ==23 /*Ceará*/
 replace region_c=11 if geo1_br2000 ==24 /*Rio Grande do Norte*/
 replace region_c=12 if geo1_br2000 ==25 /*Paraíba*/
 replace region_c=13 if geo1_br2000 ==26 /*Pernambuco*/
 replace region_c=14 if geo1_br2000 ==27 /*Alagoas*/
 replace region_c=15 if geo1_br2000 ==28 /*Sergipe*/
 replace region_c=16 if geo1_br2000 ==29 /*Bahia*/
 replace region_c=17 if geo1_br2000 ==31 /*Minas Gerais*/
 replace region_c=18 if geo1_br2000 ==32 /*Espírito Santo*/
 replace region_c=19 if geo1_br2000 ==33 /*Rio de Janeiro*/
 replace region_c=20 if geo1_br2000 ==35 /*São Paulo*/
 replace region_c=21 if geo1_br2000 ==41 /*Paraná*/
 replace region_c=22 if geo1_br2000 ==42 /*Santa Catarina*/
 replace region_c=23 if geo1_br2000 ==43 /*Rio Grande do Sul*/
 replace region_c=24 if geo1_br2000 ==50 /*Mato Grosso do Sul*/
 replace region_c=25 if geo1_br2000 ==51 /*Mato Grosso*/
 replace region_c=26 if geo1_br2000 ==52 /*Goiás*/
 replace region_c=27 if geo1_br2000 ==53 /*Distrito Federal*/

 label define region_c 1"Rondônia" 2"Acre" 3"Amazonas" 4"Roraima" 5"Pará" 6"Amapá" 7"Tocantins" 8"Maranhão" 9"Piauí" 10"Ceará" 11"Rio Grande do Norte" 12"Paraíba" 13"Pernambuco" 14"Alagoas" 15"Sergipe" 16"Bahia" 17"Minas Gerais" 18"Espírito Santo" 19"Rio de Janeiro" 20"São Paulo" 21"Paraná" 22"Santa Catarina" 23"Rio Grande do Sul" 24"Mato Grosso do Sul" 25"Mato Grosso" 26"Goiás" 27"Distrito Federal"
 
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
replace afroind_ci=2 if race == 20 | race == 51 
replace afroind_ci=3 if race == 10 | race == 40 
replace afroind_ci=. if race == 99

	***************
	***afroind_ch***
	***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=1990

********************
*** discapacidad ***
********************
gen dis_ci=.
gen dis_ch=.


*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

compress

save "`base_out'", replace 
log close

