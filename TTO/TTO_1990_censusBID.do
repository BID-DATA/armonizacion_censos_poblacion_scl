
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
País:  Trinidad & Tobago
Año: 1990
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************
local PAIS TTO
local ANO "1990"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

include "../Base/base.do"

     ****************
     *** region_c ***
     ****************

   gen region_c=.   
   replace region_c=1 if geo1_tt1990 == 1			/*Port of Spain*/
   replace region_c=2 if geo1_tt1990 == 2			/*San Fernando*/
   replace region_c=3 if geo1_tt1990 == 3			/*Arima*/
   replace region_c=4 if geo1_tt1990 == 13			/*Saint George*/
   replace region_c=5 if geo1_tt1990 == 14			/*Caroni*/
   replace region_c=6 if geo1_tt1990 == 15		    /*Nariva and Mayaro*/
   replace region_c=7 if geo1_tt1990 == 16			/*Saint Andrew and Saint David*/
   replace region_c=8 if geo1_tt1990 == 17			/*Victoria*/
   replace region_c=9 if geo1_tt1990 == 38			/*Saint Patrick*/
   replace region_c=10 if geo1_tt1990 == 39			/*Tobago*/


	  label define region_c 1"Port of Spain" 2"San Fernando" 3"Arima" 4"Saint George"  5"Caroni" 6"Nariva and Mayaro" 7"Saint Andrew and Saint David" 8"Victoria" 9"Saint Patrick" 10"Tobago" 
      label value region_c region_c
      label var region_c "division politico-administrativa, provincia"

	
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
	replace eduno_ci=. if aedu_ci==. // NIU & missing
	
	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=.
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<7) //
	replace edupi_ci=. if aedu_ci==. // NIU & missing
	replace edupi_ci = 1 if yrschool == 91 // some primary

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci==7)
	replace edupc_ci=. if aedu_ci==. // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<12) // 7 a 11 anos de educación
	replace edusi_ci=. if aedu_ci==. // NIU & missing
	replace edusi_ci = 1 if yrschool == 92 | yrschool ==93 //some technical after primary or some secondary

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==12) // 12 anos de educación
	replace edusc_ci=. if aedu_ci==. // NIU & missing
	
	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=13 & aedu_ci<=16 & edattain != 4) // 14 a 16 anos de educación
	replace eduui_ci=. if aedu_ci ==. // NIU & missing
	replace eduui_ci = 1 if yrschool == 94 // some terciary

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=.
	replace eduuc_ci=(edattain == 4)
	replace eduuc_ci=. if aedu_ci==. // NIU & missing

	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>7 & aedu_ci<10)
	replace edus1i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==10)
	replace edus1c_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>10 & aedu_ci<12)
	replace edus2i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==12)
	replace edus2c_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*asiste_ci*
	***********
	gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
	replace asiste_ci=. if school==0 | school==9 // missing a los NIU & missing

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
	replace afroind_ci = 1 if ethnictt == 4
	replace afroind_ci = 2 if ethnictt == 1
	replace afroind_ci = 3 if ethnictt == 2
	replace afroind_ci = 3 if ethnictt == 3
	replace afroind_ci = 3 if ethnictt == 5
	replace afroind_ci = 3 if ethnictt == 6
	replace afroind_ci = 3 if ethnictt == 8
	replace afroind_ci = 3 if ethnictt == 9
	replace afroind_ci = 3 if ethnictt == 97

		***************
		***afroind_ch***
		***************
	gen afroind_jefe= afroind_ci if relate==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

	drop afroind_jefe 

		*******************
		***afroind_ano_c***
		*******************
	gen afroind_ano_c=1970

	********************
	*** discapacid
	********************
	gen dis_ci=.
	gen dis_ch=.



*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
	
     ***********
	  *ylm_ci*
	 ***********
   cap confirm variable incearn
   if (_rc==0) {
   replace ylm_ci = incearn
   replace ylm_ci =. if incearn==99999999 | incearn==99999998
   }

	 *********
	 *ynlm_ci*
	 *********
   cap confirm variable incwel
   if (_rc==0) {
   replace ynlm_ci=incwel
   replace ynlm_ci=. if incwel== 99999999 | incwel==99999998
   } 
   
     ***********
	  *ylm_ch*
	 ***********
   
   by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
   
    ***********
	  *ynlm_ch*
	 ***********
   by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1, missing
   
   
*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress

save "`base_out'", replace 
log close

