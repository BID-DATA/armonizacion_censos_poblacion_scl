
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
Año: 2000
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************
local PAIS TTO
local ANO "2000"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

include "../Base/base.do"

     ****************
     *** region_c ***
     ****************

   gen region_c=.   
   replace region_c=1 if geo1_tt2000 == 10			/*Port of Spain*/
   replace region_c=2 if geo1_tt2000 == 11			/*Mayaro*/
   replace region_c=3 if geo1_tt2000 == 12			/*Sangre Grande*/
   replace region_c=4 if geo1_tt2000 == 13			/*Princess Town*/
   replace region_c=5 if geo1_tt2000 == 14			/*Penal/ Debe*/
   replace region_c=6 if geo1_tt2000 == 15		    /*Siparia, Point Fontin*/
   replace region_c=7 if geo1_tt2000 == 20			/*San Fernando*/
   replace region_c=8 if geo1_tt2000 == 30			/*Arima*/
   replace region_c=9 if geo1_tt2000 == 40			/*Chaguanas*/
   replace region_c=10 if geo1_tt2000 == 60			/*Diego Martin*/
   replace region_c=11 if geo1_tt2000 == 70			/*San Juan/ Laventille*/
   replace region_c=12 if geo1_tt2000 == 80			/*Tunapuna*/
   replace region_c=13 if geo1_tt2000 == 90			/*Couva*/
   replace region_c=14 if geo1_tt2000 == 93			/*St. Andrew, St. Patrick*/
   replace region_c=15 if geo1_tt2000 == 95		/*St. John, St. Mary, St. Paul, St. George, St. David*/


	  label define region_c 1"Port of Spain" 2"Mayaro" 3"Sangre Grande" 4"Princess Town"  5"Penal/ Debe" 6"Siparia, Point Fontin" 7"San Fernando" 8"Arima" 9"Chaguanas" 10"Diego Martin" 11"San Juan/ Laventille" 12"Tunapuna" 13"Couva" 14"St. Andrew, St. Patrick" 15"St. John, St. Mary, St. Paul, St. George, St. David"
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
	*gen edupre_ci=(educcl==100) // pre-school
	*replace edupre_ci=. if aedu_ci==. // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<7) //
	replace edupi_ci=. if aedu_ci==. // NIU & missing
	replace edupi_ci = 1 if yrschool == 91 // some primary

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci==7 | edattain == 2)
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
	gen edusc_ci=(aedu_ci==12 | edattain == 3) // 12 anos de educación
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
	replace edus1i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==10)
	replace edus1c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>10 & aedu_ci<12)
	replace edus2i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==12)
	replace edus2c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

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

