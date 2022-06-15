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
local ANO "1992"


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

	
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
**Pregunta: 

gen afroind_ci=. 

	***************
	***afroind_ch***
	***************
gen afroind_jefe=.
gen afroind_ch  =.

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=2001

********************
*** discapacid
********************
gen dis_ci=.
gen dis_ch=.

*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
/*Argentina no tiene vars de ingreso pero se incluyen las 
variables de ingreso por hogar porque no están en el do Base*/	

    ***********
	**ylm_ch*
	***********
   
   by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
   
    ***********
	**ynlm_ch*
	***********
   by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1, missing


************************
* VARIABLES EDUCATIVAS *
************************

***************
***asiste_ci*** 
*************** 
gen asiste_ci=1 if school==1
replace asiste_ci=. if school==0 // not in universe as missing 
replace asiste_ci=. if school==9 // Unknown/missing as missing
replace asiste_ci=0 if school==2

*************
***aedu_ci*** 
************* 
gen aedu_ci=yrschool
replace aedu_ci=. if yrschool>=90 & yrschool<100 // categorias NIU; missing; + categorias nivel educativo pero pero sin años de escolaridad

**************
***eduno_ci***
**************
gen byte eduno_ci=0
replace eduno_ci=1 if aedu_ci==0
replace eduno_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

**************
***edupi_ci***
**************
gen byte edupi_ci=0
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<5 // se pone menor a 5 porque hay cohortes que tiene completa con 5 
replace edupi_ci=1 if yrschool==91 // Some primary
replace edupi_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

**************
***edupc_ci***
**************
gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==6
replace edupc_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

**************
***edusi_ci***
**************
gen byte edusi_ci=0
replace edusi_ci=1 if aedu_ci>6 & aedu_ci<12
replace edusi_ci=1 if yrschool==92 | yrschool==93 // Some techinical after primary and some secondary
replace edusi_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

**************
***edusc_ci***
**************
gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==12
replace edusc_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

***************
***edus1i_ci***
***************
gen edus1i_ci=(aedu_ci==7)
replace edus1i_ci=. if aedu_ci==. // NIU

***************
***edus1c_ci***
***************
gen edus1c_ci=(aedu_ci==8)
replace edus1c_ci=. if aedu_ci==. // NIU

***************
***edus2i_ci***
***************
gen edus2i_ci=(aedu_ci>=9 & aedu_ci<12)
replace edus2i_ci=. if aedu_ci==. // NIU

***************
***edus2c_ci***
***************
gen edus2c_ci=(aedu_ci==12)
replace edus2c_ci=. if aedu_ci==. // NIU

***************
***edupre_ci*** *No hay referencias de esta categoria en educbo
***************
gen edupre_ci=.

**************
***literacy***
**************
gen literacy=. if lit==0
replace literacy=0 if lit==1
replace literacy=1 if lit==2

order region_BID_c region_c pais_c anio_c idh_ch idp_ci factor_ch factor_ci estrato_ci zona_c sexo_ci edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch condocup_ci emp_ci desemp_ci pea_ci rama_ci categopri_ci spublico_ci ylm_ci ynlm_ci ylm_ch ynlm_ch aedu_ci eduno_ci edupre_ci edupi_ci  edupc_ci  edusi_ci edusc_ci  eduui_ci eduuc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci asiste_ci literacy aguared_ch luz_ch bano_ch des1_ch piso_ch banomejorado_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch migrante_ci migrantelac_ci migantiguo5_ci discapacidad_ci  ceguera_ci sordera_ci mudez_ci dismental_ci

*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

compress

save "`base_out'", replace 
log close
