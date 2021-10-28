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
País: Chile
Año: 1982
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************
local PAIS CHL
local ANO "1982"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

include "../Base/base.do"

     ****************
     *** region_c ***
     ****************
   * Clasificación válida para 1960, 1970 y 1982.
   gen region_c=.   
   replace region_c=1 if geo1_cl==152011			    /*Iquique*/
   replace region_c=2 if geo1_cl==152012			    /*Arica, Parinacota*/
   replace region_c=3 if geo1_cl==152021			    /*Antofagasta*/
   replace region_c=4 if geo1_cl==152022			    /*El Loa*/
   replace region_c=5 if geo1_cl==152023		     	/*Tocopilla*/
   replace region_c=6 if geo1_cl==152031			    /*Copiapo*/
   replace region_c=7 if geo1_cl==152032			    /*Chanaral*/
   replace region_c=8 if geo1_cl==152033			    /*Huasco*/
   replace region_c=9 if geo1_cl==152041			    /*Elqui*/
   replace region_c=10 if geo1_cl==152042			/*Choapa*/
   replace region_c=11 if geo1_cl==152043			/*Limari*/
   replace region_c=12 if geo1_cl==152051			/*Valparaíso, Isla de Pascua*/
   replace region_c=13 if geo1_cl==152053			/*Los Andes*/
   replace region_c=14 if geo1_cl==152054			/*Petorca*/
   replace region_c=15 if geo1_cl==152055			/*Quillota*/
   replace region_c=16 if geo1_cl==152056			/*San Antonio*/
   replace region_c=17 if geo1_cl==152057			/*San Felipe de Aconcagua*/
   replace region_c=18 if geo1_cl==152061			/*Cachapoal*/
   replace region_c=19 if geo1_cl==152062			/*Cardenal Caro*/
   replace region_c=20 if geo1_cl==152063			/*Colchagua*/
   replace region_c=21 if geo1_cl==152071			/*Talca*/
   replace region_c=22 if geo1_cl==152072			/*Cauquenes*/
   replace region_c=23 if geo1_cl==152073			/*Curico*/
   replace region_c=24 if geo1_cl==152074			/*Linares*/
   replace region_c=25 if geo1_cl==152081			/*Concepcion*/
   replace region_c=26 if geo1_cl==152082			/*Arauco*/
   replace region_c=27 if geo1_cl==152083			/*Bio Bio*/
   replace region_c=28 if geo1_cl==152084			/*Nuble*/
   replace region_c=29 if geo1_cl==152091			/*Cautin*/
   replace region_c=30 if geo1_cl==152092			/*Malleco*/
   replace region_c=31 if geo1_cl==152101			/*Llanquihue*/
   replace region_c=32 if geo1_cl==152102			/*Chiloe*/
   replace region_c=33 if geo1_cl==152103			/*Osorno*/
   replace region_c=34 if geo1_cl==152105			/*Valdivia*/
   replace region_c=35 if geo1_cl==152111			/*Coihaique*/
   replace region_c=36 if geo1_cl==152112			/*Aisen, General Carrera, Palena*/
   replace region_c=37 if geo1_cl==152121			/*Magallanes, Tierra del Fuego, Antartica Chilena*/
   replace region_c=38 if geo1_cl==152124			/*Ma. Esperanza, Capitan Prat*/
   replace region_c=39 if geo1_cl==152131			/*Santiago*/
   replace region_c=40 if geo1_cl==152132			/*Cordillera*/
   replace region_c=41 if geo1_cl==152133			/*Chacabuco*/
   replace region_c=42 if geo1_cl==152134			/*Maipo*/
   replace region_c=43 if geo1_cl==152135			/*Melipilla*/
   replace region_c=44 if geo1_cl==152136			/*Talagante*/
   replace region_c=45 if geo1_cl==152888			/*Waterbodies*/
   


	  label define region_c 1"Iquique" 2"Arica, Parinacota" 3"Antofagasta" 4"El Loa" 5"Tocopilla" 6"Copiapo" 7"Chanaral" 8"Huasco" 9"Elqui" 10"Choapa" 11"Limari" 12"Valparaíso, Isla de Pascua" 13"Los Andes" 14"Petorca" 15"Quillota" 16"San Antonio" 17"San Felipe de Aconcagua" 18"Cachapoal" 19"Cardenal Caro" 20"Colchagua" 21"Talca" 22"Cauquenes" 23"Curico" 24"Linares" 25"Concepcion" 26"Arauco" 27 "Bio Bio" 28"Nuble" 29"Cautin" 30"Malleco" 31"Llanquihue" 32"Chiloe" 33"Osorno" 34"Valdivia" 35"Coihaique" 36"Aisen, General Carrera, Palena" 37"Magallanes, Tierra del Fuego, Antartica Chilena" 38"Ma. Esperanza, Capitan Prat" 39"Santiago" 40"Cordillera" 41"Chacabuco" 42"Maipo" 43"Melipilla" 44"Talagante" 45"Waterbodies" 

      label value region_c region_c
      label var region_c "division politico-administrativa, provincia" 

* Enlace regiones: https://international.ipums.org/international-action/variables/GEO1_CL#codes_section


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

****************
* aedu_ci      * 
**************** 

gen aedu_ci=yrschool
replace aedu_ci=. if aedu_ci==98
replace aedu_ci=. if aedu_ci==99

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

**************
***eduui_ci***
**************
gen byte eduui_ci=0
replace eduui_ci=1 if aedu_ci>12 & aedu_ci<17
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

** Other variables 
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
gen afroind_ano_c=.

********************
*** discapacid
********************
gen dis_ci=.
gen dis_ch=.

*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
	
    ***********
	**ylm_ci**
	***********
	
	*gen ylm_ci=.
	
    ***********
	**ynlm_ci**
	***********
 
	*gen ynlm_ci=.

    ***********
	**ylm_ch**
	***********
   
	gen ylm_ch=.
   
    ***********
	**ynlm_ch**
	***********
	gen ynlm_ch=.
	
*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress

save "`base_out'", replace 
log close

