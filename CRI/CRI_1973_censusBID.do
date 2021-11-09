
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
País: Costa Rica
Año:
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

*Population and Housing Censuses/Harmonized Censuses - IPUMS

local PAIS CRI
local ANO "1973"

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
	gen region_c=.   
	replace region_c=1 if geo1_cr1973==1	/*San Jose*/
	replace region_c=2 if geo1_cr1973==2	/*Alajuela*/
	replace region_c=3 if geo1_cr1973==3	/*Cartago*/
	replace region_c=4 if geo1_cr1973==4	/*Heredia*/
	replace region_c=5 if geo1_cr1973==5	/*Guanacaste*/
	replace region_c=6 if geo1_cr1973==6	/*Puntarenas*/
	replace region_c=7 if geo1_cr1973==7	/*Limon*/

	label define region_c 1"San Jose" 2"Alajuela" 3"Cartago" 4"Heredia" 5"Guanacaste" 6"Puntarenas" 7"Limon" 
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
	gen edupre_ci=(educcr==110) // pre-school
	replace edupre_ci=. if educcr==0 | educcr==999 // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) //
	replace edupi_ci=. if educcr==0 | educcr==999 // NIU & missing
	replace edupi_ci = 1 if yrschool == 91 // some primary

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci==6) 
	replace edupc_ci=. if edattain==0 | edattain==9 // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<=10) // 7 a 10 anos de educación
	replace edusi_ci=. if edattain==0 |edattain==9 // NIU & missing
	replace edusi_ci = 1 if yrschool == 92 | yrschool ==93 //some technical after primary or some secondary

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==11) // 11 anos de educación
	replace edusc_ci=. if edattain==0 |edattain==9 // NIU & missing
	
	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=12 & aedu_ci<=15 & edattain != 4) // 14 a 16 anos de educación y no univ completa
	replace eduui_ci=. if edattain==0 | edattain==9 // NIU & missing
	replace eduui_ci = 1 if yrschool == 94 // some terciary

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=.
	replace eduuc_ci=1 if edattain == 4 | aedu_ci>=15
	replace eduuc_ci=0 if edattain == 1 | edattain == 2 | edattain ==3  
	// 12 y 13 anos de educación
	replace eduuc_ci=. if edattain==0 | edattain==9 // NIU & missing

	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
	replace edus1i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<11)
	replace edus2i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==11)
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
	***afroind_ci**
	***************
	**Pregunta: 

	gen afroind_ci=. 

	***************
	***afroind_ch**
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

