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

local PAIS BOL
local ANO "1976"


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Bolivia
Año:
Autores: 
Última versión: 
							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

include "../Base/base.do"

****************
 *** region_c ***
 ****************


   gen region_c=.
   replace region_c=1 if geo1_bo==68001  
   replace region_c=2 if geo1_bo==68002
   replace region_c=3 if geo1_bo==68003
   replace region_c=4 if geo1_bo==68004
   replace region_c=5 if geo1_bo==68005
   replace region_c=6 if geo1_bo==68006
   replace region_c=7 if geo1_bo==68007
   replace region_c=8 if geo1_bo==68008
   replace region_c=9 if geo1_bo==68009
   
   label define region_c 1 "Chuqisaca" 2 "La paz" 3 "Cochabamba" 4 "Oruro" 5 "Potosá" 6 "Tarija" 7 "Santa Cruz" 8 "Beni" 9 "Pando", add modify 
   label value region_c region_c 
 


********************************
*** Health indicators **********
********************************
	gen discapacidad_ci =.
	label var discapacidad_ci "Discapacidad"

	gen ceguera_ci=.
	label var ceguera_ci "Ciego o con discpacidad visual"
	
	gen sordera_ci  =.
	label var sordera_ci "Sordera o con discpacidad auditiva"

	gen mudez_ci=.
	label var mudez_ci "Mudo o con discpacidad de lenguaje"

	gen dismental_ci=.
	label var dismental_ci "Discapacidad mental"	
	
	***********************************
	***    VARIABLES DE MIGRACIÓN.  ***
	***********************************
			

      *******************
      ****migrante_ci****
      *******************
	gen migrante_ci = (nativity == 2)
	 
      *******************
      **migantiguo5_ci***
      *******************
	gen migantiguo5_ci = (mig1_5_bo == 68097)
	
	
	**********************
	*** migrantelac_ci ***
	**********************
	
	gen migrantelac_ci= 1 if inlist(bplcountry, 21100, 23010, 22060, 23110, 22020, 22040, 23050, 23100, 22030, 23060, 23140, 22050, 23040, 23100, 29999, 23130, 23030, 21250, 21999, 22010, 22070, 22080, 22999)
	replace migrantelac_ci = 0 if migrantelac_ci == . & nativity == 2

	************************
* VARIABLES EDUCATIVAS *
************************

****************
* asiste_ci    * 
**************** 
gen asiste_ci=1 if school==1
replace asiste_ci=. if school==0 // not in universe as missing 
replace asiste_ci=. if school==9 // Unknown/missing as missing
replace asiste_ci=0 if school==2
label var asiste_ci "Personas que actualmente asisten a centros de enseñanza"

****************
* aedu_ci      * 
**************** 

gen aedu_ci=yrschool
replace aedu_ci=. if yrschool>=90 & yrschool<100 // categorias NIU; missing; + categorias nivel educativo pero pero sin años de escolaridad
label var aedu_ci "Anios de educacion aprobados" 

**************
***eduno_ci***
**************
gen byte eduno_ci=0
replace eduno_ci=1 if aedu_ci==0
replace eduno_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)
label variable eduno_ci "Cero anios de educacion"

**************
***edupi_ci***
**************
gen byte edupi_ci=0
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<5 // se pone menor a 5 porque hay cohortes que tiene completa con 5 
replace edupi_ci=1 if aedu_ci==5 & edattain==1 // se incluyen los de 5 años e primaria incompleta 
replace edupi_ci=1 if yrschool==91 // Some primary
replace edupi_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)
label variable edupi_ci "Primaria incompleta"

**************
***edupc_ci***
**************
gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==6
replace edupc_ci=1 if aedu_ci==5 & edattain==2 // se incluyen los de 5 años con primaria completa 
replace edupc_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)
label variable edupc_ci "Primaria completa"

**************
***edusi_ci***
**************
gen byte edusi_ci=0
replace edusi_ci=1 if aedu_ci>6 & aedu_ci<12
replace edusi_ci=1 if yrschool==92 | yrschool==93 // Some techinical after primary and some secondary
replace edusi_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)
label variable edusi_ci "Secundaria incompleta"

**************
***edusc_ci***
**************
gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==12
replace edusc_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)
label variable edusc_ci "Secundaria completa"

**************
***eduui_ci***
**************
gen byte eduui_ci=0
replace eduui_ci=1 if aedu_ci>12 & aedu_ci<17
replace eduui_ci=1 if yrschool==94 // Some tertiary
replace eduui_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)
label variable eduui_ci "Universitaria incompleta"

***************
***eduuc_ci****
***************
gen byte eduuc_ci=0
replace eduuc_ci=1 if aedu_ci==17| aedu_ci==18
replace eduuc_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)
label variable eduuc_ci "Universitaria completa o mas"

***************
***edus1i_ci***
***************
gen edus1i_ci=.
label variable edus1i_ci "1er ciclo de la secundaria incompleto"

***************
***edus1c_ci***
***************
gen edus1c_ci=.
label variable edus1c_ci "1er ciclo de la secundaria completo"

***************
***edus2i_ci***
***************
gen edus2i_ci=.
label variable edus2i_ci "2do ciclo de la secundaria incompleto"

***************
***edus2c_ci***
***************
gen edus2c_ci=.
label variable edus2c_ci "2do ciclo de la secundaria completo"

***************
***edupre_ci***
***************
gen edupre_ci=.
label variable edupre_ci "Educacion preescolar"

** Other variables 
***************
***literacy***
***************
gen literacy=. if lit==0
replace literacy=0 if lit==1
replace literacy=1 if lit==2

compress

save "`base_out'", replace 
log close