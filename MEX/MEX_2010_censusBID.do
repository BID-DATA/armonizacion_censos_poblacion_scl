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
País: Mexico
Año: 2010
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS MEX
local ANO "2010"

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
replace region_c=1 if geo1_mx2010==1 //
replace region_c=2 if geo1_mx2010==2 //
replace region_c=3 if geo1_mx2010==3 //
replace region_c=4 if geo1_mx2010==4 //
replace region_c=5 if geo1_mx2010==5 //
replace region_c=6 if geo1_mx2010==6 //
replace region_c=7 if geo1_mx2010==7 //
replace region_c=8 if geo1_mx2010==8 //
replace region_c=9 if geo1_mx2010==9 //
replace region_c=10 if geo1_mx2010==10 //
replace region_c=11 if geo1_mx2010==11 //
replace region_c=12 if geo1_mx2010==12 //
replace region_c=13 if geo1_mx2010==13 //
replace region_c=14 if geo1_mx2010==14 //
replace region_c=15 if geo1_mx2010==15 //
replace region_c=16 if geo1_mx2010==16 //
replace region_c=17 if geo1_mx2010==17 //
replace region_c=18 if geo1_mx2010==18 //
replace region_c=19 if geo1_mx2010==19 //
replace region_c=20 if geo1_mx2010==20 //
replace region_c=21 if geo1_mx2010==21 //
replace region_c=22 if geo1_mx2010==22 //
replace region_c=23 if geo1_mx2010==23 //
replace region_c=24 if geo1_mx2010==24 //
replace region_c=25 if geo1_mx2010==25 //
replace region_c=26 if geo1_mx2010==26 //
replace region_c=27 if geo1_mx2010==27 //
replace region_c=28 if geo1_mx2010==28 //
replace region_c=29 if geo1_mx2010==29 //
replace region_c=30 if geo1_mx2010==30 //
replace region_c=31 if geo1_mx2010==31 //
replace region_c=32 if geo1_mx2010==32 //

label define region_c ///
1 "Aguascalientes" ///
2 "Baja California" ///
3 "Baja California Sur" ///
4 "Campeche" ///
5 "Coahuila de Zaragoza" ///
6 "Colima" ///
7 "Chiapas" ///
8 "Chihuahua" ///
9 "Distrito Federal" ///
10 "Durango" ///
11 "Guanajuato" ///
12 "Guerrero" ///
13 "Hidalgo" ///
14 "Jalisco" ///
15 "México" ///
16 "Michoacán de Ocampo" ///
17 "Morelos" ///
18 "Nayarit" ///
19 "Nuevo León" ///
20 "Oaxaca" ///
21 "Puebla" ///
22 "Querétaro" ///
23 "Quintana Roo" ///
24 "San Luis Potosí" ///
25 "Sinaloa" ///
26 "Sonora" ///
27 "Tabasco" ///
28 "Tamaulipas" ///
29 "Tlaxcala" ///
30 "Veracruz de Ignacio de la Llave" ///
31 "Yucatán" ///
32 "Zacatecas" 
label value region_c region_c
label var region_c "division politico-administrativa, estados"

*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
	gen afroind_ci=. 
	replace afroind_ci=1  if indig==1 
	replace afroind_ci=3 if indig==2


	***************
	***afroind_ch***
	***************
	gen afroind_jefe= afroind_ci if relate==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 
	
	drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
	gen afroind_ano_c=2000


************************
*** Discapacidad (WG)***
************************
/* Identificación de si una persona reporta por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */

gen dis_ci = 0
recode dis_ci nonmiss=. if inlist(9,mx2010a_dissee,mx2010a_dishear,mx2010a_disspk,mx2010a_diswalk,mx2010a_dislrn,mx2010a_discare) //
recode dis_ci nonmiss=. if mx2010a_dissee>=. & mx2010a_dishear>=. & mx2010a_disspk>=. & mx2010a_diswalk>=. & mx2010a_dislrn>=. & mx2010a_discare>=. //
replace dis_ci=1 if mx2010a_dissee==1 | mx2010a_dishear==1 | mx2010a_disspk==1 | mx2010a_diswalk==1 | mx2010a_dislrn==1 | mx2010a_discare==1 


/*Identificación de si un hogar tiene uno o más miembros que reportan por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */		

egen dis_ch  = sum(dis_ci), by(idh_ch) 
replace dis_ch=1 if dis_ch>=1 & dis_ch!=. 



******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************

	replace ylm_ci=incearn
	replace ylm_ci=. if incearn==99999998 | incearn==99999999
	
	replace ynlm_ci=.


    ***********
	**ylm_ch*
	***********
   
   by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
   
    ***********
	**ynlm_ch*
	***********
   by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1, missing
   
****************************
***VARIABLES DE EDUCACION***
****************************
*REVISAR QUE NO DEBERÍAN EXISTIR CAMBIOS POR LOS CODIGOS 90... EN LAS VAR ED

****************
* asiste_ci    * 
**************** 
gen asiste_ci=1 if school==1
replace asiste_ci=. if school==0 // not in universe as missing 
replace asiste_ci=. if school==9 // Unknown/missing as missing
replace asiste_ci=0 if school==2

*********
*aedu_ci* // años de educacion aprobados
*********
*NOTA: Como terciario, universitario y posgrado tienen una duración variable se supone 
*que terciario completo implica 3 años de educacion adicional a la secundaria, universitario 5 años adicionales y 
*postgrado 7. Esto solo se basa en la modas de finalización de estos niveles. ESTO SE DEBE DISCUTIR 

gen aedu_ci=yrschool
replace aedu_ci=. if aedu_ci==98
replace aedu_ci=. if aedu_ci==99
replace aedu_ci=. if yrschool>=90 & yrschool<100 

	
**************
***eduno_ci***
**************
gen byte eduno_ci=0
replace eduno_ci=1 if aedu_ci==0
replace eduno_ci=. if aedu_ci==.
	
*************
***edupi_ci***
**************
gen byte edupi_ci=0
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<6
replace edupi_ci=1 if yrschool==91 // Some primary 
replace edupi_ci=. if aedu_ci==.

**************
***edupc_ci***
**************
gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==6
replace edupc_ci=. if aedu_ci==.

**************
***edusi_ci***
**************
gen byte edusi_ci=0
replace edusi_ci=1 if aedu_ci>6 & aedu_ci<12
replace edusi_ci=1 if yrschool==92 | yrschool==93 // Some techinical after primary and some secondary
replace edusi_ci=. if aedu_ci==.
replace edusi_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

**************
***edusc_ci***
**************
gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==12
replace edusc_ci=1 if yrschool==94 // Some tertiary
replace edusc_ci=. if aedu_ci==.

**************
***eduui_ci***
**************
gen byte eduui_ci=0
replace eduui_ci=1 if aedu_ci>12 & aedu_ci<17
replace edusi_ci=1 if yrschool==94 // Some tertiary
replace eduui_ci=. if aedu_ci==.

***************
***eduuc_ci****
***************
gen byte eduuc_ci=0
replace eduuc_ci=1 if aedu_ci>=17
replace eduuc_ci=. if aedu_ci==.

***************
***edus1i_ci***
***************
gen byte edus1i_ci=0
replace edus1i_ci=1 if aedu_ci>6 & aedu_ci<9
replace edus1i_ci=. if aedu_ci==.

***************
***edus1c_ci***
***************
gen byte edus1c_ci=0
replace edus1c_ci=1 if aedu_ci==9 
replace edus1c_ci=1 if yrschool==94 // Some tertiary
replace edus1c_ci=. if aedu_ci==.

***************
***edus2i_ci***
***************
gen byte edus2i_ci=0
replace edus2i_ci=1 if aedu_ci>9 & aedu_ci<12
replace edus2i_ci=. if aedu_ci==.

***************
***edus2c_ci***
***************
gen byte edus2c_ci=0
replace edus2c_ci=1 if aedu_ci==12
replace edus2c_ci=1 if yrschool==94 // Some tertiary
replace edus2c_ci=. if aedu_ci==.

***************
***edupre_ci***
***************
gen edupre_ci=.

** Other variables 
***************
***literacy***
***************
gen literacy=. if lit==0
replace literacy=. if lit==9
replace literacy=0 if lit==1
replace literacy=1 if lit==2

*****

order region_BID_c region_c pais_c anio_c idh_ch idp_ci factor_ch factor_ci estrato_ci zona_c sexo_ci edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch condocup_ci emp_ci desemp_ci pea_ci rama_ci categopri_ci spublico_ci ylm_ci ynlm_ci ylm_ch ynlm_ch aedu_ci eduno_ci edupre_ci edupi_ci  edupc_ci  edusi_ci edusc_ci  eduui_ci eduuc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci asiste_ci literacy aguared_ch luz_ch bano_ch des1_ch piso_ch banomejorado_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch migrante_ci migrantelac_ci migantiguo5_ci discapacidad_ci  ceguera_ci sordera_ci mudez_ci dismental_ci

*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"


compress

save "`base_out'", replace 
log close

