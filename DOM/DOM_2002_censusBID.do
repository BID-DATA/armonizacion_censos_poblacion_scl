
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
País: República Dominicana
Año: 2002
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************
local PAIS DOM
local ANO "2002"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

include "../Base/base.do"

     ****************
     *** region_c ***
     ****************

   gen region_c=.   
   replace region_c=1 if geo1_do2002==1			/*National district*/
   replace region_c=2 if geo1_do2002==2			/*Azua*/
   replace region_c=3 if geo1_do2002==3			/*Baoruco*/
   replace region_c=4 if geo1_do2002==4			/*Barahona*/
   replace region_c=5 if geo1_do2002==5		    /*Dajabón*/
   replace region_c=6 if geo1_do2002==6			/*Duarte*/
   replace region_c=7 if geo1_do2002==7			/*Elías Piña*/
   replace region_c=8 if geo1_do2002==8			/*El Seibo*/
   replace region_c=9 if geo1_do2002==9 		/*Espaillat*/
   replace region_c=10 if geo1_do2002==10		/*Independencia*/
   replace region_c=11 if geo1_do2002==11		/*La Altagracia*/
   replace region_c=12 if geo1_do2002==12		/*La Romana*/
   replace region_c=13 if geo1_do2002==13		/*La Vega*/
   replace region_c=14 if geo1_do2002==14		/*María Trinidad Sánchez*/
   replace region_c=15 if geo1_do2002==15		/*Monte Cristi*/
   replace region_c=16 if geo1_do2002==16		/*Pedernales*/
   replace region_c=17 if geo1_do2002==17		/*Peravia*/
   replace region_c=18 if geo1_do2002==18		/*Puerto Plata*/
   replace region_c=19 if geo1_do2002==19		/*Salcedo*/
   replace region_c=20 if geo1_do2002==20		/*Samana*/
   replace region_c=21 if geo1_do2002==21		/*San Cristóbal*/
   replace region_c=22 if geo1_do2002==22		/*San Juan*/
   replace region_c=23 if geo1_do2002==23		/*San Pedro de Macorís*/
   replace region_c=24 if geo1_do2002==24		/*Sánchez Ramírez*/
   replace region_c=25 if geo1_do2002==25		/*Santiago*/
   replace region_c=26 if geo1_do2002==26		/*Santiago Rodríguez*/
   replace region_c=27 if geo1_do2002==27		/*Valverde*/
   replace region_c=28 if geo1_do2002==28		/*Monseñor Nouel*/
   replace region_c=29 if geo1_do2002==29		/*Monte Plata*/
   replace region_c=30 if geo1_do2002==30		/*Hato Mayor*/
   replace region_c=31 if geo1_do2002==31		/*San José de Ocoa*/
   replace region_c=32 if geo1_do2002==32		/*Santo Domingo*/


	  label define region_c 1"Distrito Nacional, Santo Domingo" 2"Azua" 3"Baoruco" 4"Barahona" 5"Dajabón" 6"Duarte" 7"Elías Piña" 8"El Seibo" 9"Espaillat" 10"Independencia" 11"La Altagracia" 12"La Romana" 13"La Vega" 14"María Trinidad Sánchez" 15"Monte Cristi" 16"Pedernales" 17"Peravia" 18"Puerto Plata" 19"Puerto Plata" 20"Samana" 21"San Cristóbal" 22"San Juan" 23"San Pedro de Macorís" 24"Sánchez Ramírez" 23"Santiago Rodríguez" 24"Valverde" 25"Santiago" 26"Santiago Rodríguez" 27"Valverde" 28"Monseñor Nouel" 29"Monte Plata" 30"Hato Mayor" 31"San José de Ocoa" 32"Santo Domingo"

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
	
	***********
	*edupre_ci* // preescolar
	***********
	gen edupre_ci=(educdo == 201 | educdo == 202 | educdo == 203) // pre-school
	replace edupre_ci=. if educdo==0 | educdo==999 // NIU & missing
	
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
	
    replace ylm_ci=inctot  //no necesariamente es laboral pero se contruye así en este caso
	replace ylm_ci=. if inctot==9999998 | inctot==9999999 
 
	replace ynlm_ci=.


    ***********
	**ylm_ch*
	***********
   
   by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
   
	***********
	**ynlm_ch*
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

