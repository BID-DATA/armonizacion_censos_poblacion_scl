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
Año: 1960
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS MEX
local ANO "1960"

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
replace region_c=1 if geo1_mx1960==1 //
replace region_c=2 if geo1_mx1960==2 //
replace region_c=3 if geo1_mx1960==3 //
replace region_c=4 if geo1_mx1960==4 //
replace region_c=5 if geo1_mx1960==5 //
replace region_c=6 if geo1_mx1960==6 //
replace region_c=7 if geo1_mx1960==7 //
replace region_c=8 if geo1_mx1960==8 //
replace region_c=9 if geo1_mx1960==9 //
replace region_c=10 if geo1_mx1960==10 //
replace region_c=11 if geo1_mx1960==11 //
replace region_c=12 if geo1_mx1960==12 //
replace region_c=13 if geo1_mx1960==13 //
replace region_c=14 if geo1_mx1960==14 //
replace region_c=15 if geo1_mx1960==15 //
replace region_c=16 if geo1_mx1960==16 //
replace region_c=17 if geo1_mx1960==17 //
replace region_c=18 if geo1_mx1960==18 //
replace region_c=19 if geo1_mx1960==19 //
replace region_c=20 if geo1_mx1960==20 //
replace region_c=21 if geo1_mx1960==21 //
replace region_c=22 if geo1_mx1960==22 //
replace region_c=23 if geo1_mx1960==23 //
replace region_c=24 if geo1_mx1960==24 //
replace region_c=25 if geo1_mx1960==25 //
replace region_c=26 if geo1_mx1960==26 //
replace region_c=27 if geo1_mx1960==27 //
replace region_c=28 if geo1_mx1960==28 //
replace region_c=29 if geo1_mx1960==29 //
replace region_c=30 if geo1_mx1960==30 //
replace region_c=31 if geo1_mx1960==31 //
replace region_c=32 if geo1_mx1960==32 //

label define region_c ///
1 "Aguascalientes" ///
2 "Baja California Norte" ///
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
25 "Sinalca" ///
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
**Pregunta: 

gen afroind_ci=. 


	***************
	***afroind_ch***
	***************
gen afroind_ch  = .

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=.


********************
*** discapacidad ***
********************
gen dis_ci=.
gen dis_ch=.

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

***************
***asiste_ci*** 
*************** 
gen asiste_ci=.

*********
*aedu_ci* // años de educacion aprobados
*********
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
	
**************
***edupi_ci***
**************
gen byte edupi_ci=0
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<6
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
replace edusi_ci=. if aedu_ci==.

**************
***edusc_ci***
**************
gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==12
replace edusc_ci=. if aedu_ci==.

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
replace edus2c_ci=. if aedu_ci==.

***************
***edupre_ci***
***************
gen edupre_ci=.

**************
***literacy***
**************
gen literacy=. if lit==0
replace literacy=. if lit==9
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

