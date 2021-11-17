
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
País:  República Dominicana
Año: 1970
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************
local PAIS DOM
local ANO "1970"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

include "../Base/base.do"

     ****************
     *** region_c ***
     ****************

   gen region_c=.   
   replace region_c=1 if geo1_do==214001			/*Distrito Nacional, Santo Domingo*/
   replace region_c=2 if geo1_do==214002			/*Azua*/
   replace region_c=3 if geo1_do==214003			/*Baoruco, Barahona, Independencia*/
   replace region_c=4 if geo1_do==214005			/*Dajabón*/
   replace region_c=5 if geo1_do==214006		    /*Duarte*/
   replace region_c=6 if geo1_do==214007			/*Elías Piña*/
   replace region_c=7 if geo1_do==214008			/*El Seibo, Hato Mayor*/
   replace region_c=8 if geo1_do==214009			/*Espaillat*/
   replace region_c=9 if geo1_do==214011			/*La Altagracia, La Romana*/
   replace region_c=10 if geo1_do==214013			/*Monseñor Nouel, La Vega*/
   replace region_c=11 if geo1_do==214014			/*María Trinidad Sánchez*/
   replace region_c=12 if geo1_do==214015			/*Monte Cristi*/
   replace region_c=13 if geo1_do==214016			/*Pedernales*/
   replace region_c=14 if geo1_do==214017			/*San José de Ocoa, Peravia*/
   replace region_c=15 if geo1_do==214018			/*Puerto Plata, Santiago*/
   replace region_c=16 if geo1_do==214019			/*Hermanas Mirabal*/
   replace region_c=17 if geo1_do==214020			/*Samaná*/
   replace region_c=18 if geo1_do==214021			/*San Cristóbal, Monte Plata*/
   replace region_c=19 if geo1_do==214022			/*San Juan*/
   replace region_c=20 if geo1_do==214023			/*San Pedro De Macorís*/
   replace region_c=21 if geo1_do==214024			/*Sánchez Ramírez*/
   replace region_c=22 if geo1_do==214026			/*Santiago Rodríguez*/
   replace region_c=23 if geo1_do==214027			/*Valverde*/
   replace region_c=24 if geo1_do==214088			/*Lake Enriquilla*/


	  label define region_c 1"Distrito Nacional, Santo Domingo" 2"Azua" 3"Baoruco, Barahona, Independencia" 4"Dajabón" 5"Duarte" 6"Elías Piña" 7"El Seibo, Hato Mayor" 8"Espaillat" 9"La Altagracia, La Romana" 10"Monseñor Nouel, La Vega" 11"María Trinidad Sánchez" 12"Monte Cristi" 13"Pedernales" 14"San José de Ocoa, Peravia" 15"Puerto Plata, Santiago" 16"Hermanas Mirabal" 17"Samaná" 18"San Cristóbal, Monte Plata" 19"San Juan" 20"San Pedro De Macorís" 21"Sánchez Ramírez" 22"Santiago Rodríguez" 23"Valverde" 24"Lake Enriquilla"

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
	replace eduno_ci=. if edattaind==0 | edattaind==999 // NIU & missing
	
	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=(educdo==200) // pre-school
	*replace edupre_ci=. if educdo==0 | educdo==999 // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) //
	replace edupi_ci=. if educdo==0 | educdo==999 // NIU & missing
	replace edupi_ci = 1 if yrschool == 91 // some primary

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci==6)
	replace edupc_ci=. if edattain==0 | edattain==9 // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<=11) // 7 a 11 anos de educación
	replace edusi_ci=. if edattain==0 |edattain==9 // NIU & missing
	replace edusi_ci = 1 if yrschool == 92 | yrschool ==93 //some technical after primary or some secondary

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==12) // 7 a 11 anos de educación
	replace edusc_ci=. if edattain==0 |edattain==9 // NIU & missing
	
	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=13 & aedu_ci<=16 & edattain != 4) // 14 a 16 anos de educación
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
	gen byte edus2i_ci=(aedu_ci>8 & aedu_ci<12)
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

