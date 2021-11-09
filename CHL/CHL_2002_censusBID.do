* (Versión Stata 12)
clear
set more off
*________________________________________________________________________________________________________________*

 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: ${censusFolder}
 * Se tiene acceso al servidor únicamente al interior del BID.
 *________________________________________________________________________________________________________________*

/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Chile
Año: 2002
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************
local PAIS CHL
local ANO "2002"

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

	*********
	*aedu_ci* // 
	*********
	gen aedu_ci = yrschool 
	replace aedu_ci=. if yrschool>=90 & yrschool<100 
 
	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen eduno_ci=(aedu_ci==0) // never attended or pre-school
	replace eduno_ci=. if edattaind==0 | edattaind==999 // NIU & missing
	
	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=(educcl==110) // pre-school
	replace edupre_ci=. if educcl==0 | educcl==999 // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) //
	replace edupi_ci=. if educcl==0 | educcl==999 // NIU & missing
	replace edupi_ci = 1 if yrschool == 91 // some primary

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci==6) 
	replace edupc_ci=. if edattain==0 | edattain==9 // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<12) // 7 a 11 anos de educación
	replace edusi_ci=. if edattain==0 |edattain==9 // NIU & missing
	replace edusi_ci = 1 if yrschool == 92 | yrschool ==93 //some technical after primary or some secondary

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==12) // 12 anos de educación
	replace edusc_ci=. if edattain==0 |edattain==9 // NIU & missing
	
	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=14 & aedu_ci<=16 & edattain != 4) // 14 a 16 anos de educación
	replace eduui_ci=. if edattain==0 | edattain==9 // NIU & missing
	replace eduui_ci = 1 if yrschool == 94 // some terciary

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=.
	replace eduuc_ci=1 if edattain == 4
	replace eduuc_ci=0 if edattain == 1 | edattain == 2 | edattain ==3  
	// cualquier otro nivel de educación
	replace eduuc_ci=. if edattain==0 | edattain==9 // NIU & missing

	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<8)
	replace edus1i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==8)
	replace edus1c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<12)
	replace edus2i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==12)
	replace edus2c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*asiste_ci*
	***********
	gen asiste_ci=.
	*gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
	*replace asiste_ci=. if school==0 | school==9 // missing a los NIU & missing

	************
	* literacy *
	************
	gen literacy=. 
	replace literacy=1 if lit==2 // literate
	replace literacy=0 if lit==1 // illiterate

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

	*******************************************************
	***           VARIABLES DE DIVERSIDAD               ***
	*******************************************************
	* Cesar Lins & Nathalia Maya - Septiembre 2021	

		***************
		***afroind_ci***
		***************
		**Pregunta: 

		gen afroind_ci=. 
		replace afroind_ci=1  if indig==1 /* Garifuna included here */
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
		gen afroind_ano_c=2002

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