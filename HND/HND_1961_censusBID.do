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
País: Honduras
Año: 1961
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS HND
local ANO "1961"

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
   replace region_c=1 if geo1_hn==340001			    /*Atlantida*/
   replace region_c=2 if geo1_hn==340002			    /*Colon*/
   replace region_c=3 if geo1_hn==340003			    /*Comayagua*/
   replace region_c=4 if geo1_hn==340004			    /*Copan*/
   replace region_c=5 if geo1_hn==340005		     	/*Cortes*/
   replace region_c=6 if geo1_hn==340006			    /*Choluteca*/
   replace region_c=7 if geo1_hn==340007			    /*El Paraiso*/
   replace region_c=8 if geo1_hn==340008			    /*Francisco Morazan*/
   replace region_c=9 if geo1_hn==340009			    /*Gracias a Dios*/
   replace region_c=10 if geo1_hn==340010			/*Intibuca*/
   replace region_c=11 if geo1_hn==340011			/*Islas de Bahia*/
   replace region_c=12 if geo1_hn==340012			/*La Paz*/
   replace region_c=13 if geo1_hn==340013			/*Lempira*/
   replace region_c=14 if geo1_hn==340014			/*Ocotepeque*/
   replace region_c=11 if geo1_hn==340015			/*Olancho*/
   replace region_c=12 if geo1_hn==340016			/*Santa Barbara*/
   replace region_c=13 if geo1_hn==340017			/*Valle*/
   replace region_c=14 if geo1_hn==340018			/*Yoro*/
   replace region_c=99 if geo1_hn==340099			/*Unknown*/

	label define region_c 1"Atlantida" 2"Colon" 3"Comayagua" 4"Copan" 5"Cortes" 6"Choluteca" 7"EL Paraiso" 8"Francisco Morazan" 9"Gracias a Dios" 10"Intibuca" 11"Islas de Bahia" 12"La Paz" 13"Lempira" 14"Ocotepeque" 15"Olancho" 16"Santa Barbara" 17"Valle" 18"Yoro" 99 ""
    label value region_c region_c
	label var region_c "division politico-administrativa, Departamentos"

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

    ***********
	**ylm_ch*
	***********
   
   by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
   
    ***********
	**ynlm_ch*
	***********
   by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1, missing
   
*******************************************************
***           VARIABLES DE EDUCACIÓN               ***
*******************************************************

	*********
	*aedu_ci* // años de educacion aprobados
	*********
	gen aedu_ci=yrschool
	replace aedu_ci=. if aedu_ci==98
	replace aedu_ci=. if aedu_ci==99
	replace aedu_ci=. if yrschool>=90 & yrschool<100 // unknown/missing or NIU

	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen eduno_ci=(aedu_ci==0) // never attended or pre-school
	replace eduno_ci=. if aedu_ci==. // NIU & missing

	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=(educhn==1010) // pre-school
	replace edupre_ci=. if aedu_ci==. // NIU & missing

	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) // primary (zero years completed) + grade 1-5 + primary grade unknown
	replace edupi_ci=. if aedu_ci==. // NIU & missing
	replace edupi_ci=1 if yrschool==91

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci ==6) // grade 6 
	replace edupc_ci=. if aedu_ci==. // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<=11) // 7 a 11
	replace edusi_ci=. if aedu_ci==. // NIU & missing
	replace edusi_ci=1 if yrschool==93

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==12) // 12 
	replace edusc_ci=.  if aedu_ci==. // NIU & missing

	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=13 & aedu_ci<=16) // 13 a 16 anos de educación
	replace eduui_ci=.  if aedu_ci==. // NIU & missing
	replace  eduui_ci=1 if yrschool==94

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=(aedu_ci>=16) //más de 16
	replace eduuc_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
	replace edus1i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<12)
	replace edus2i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==12)
	replace edus2c_ci=. if aedu_ci==. 
	
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

*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"


compress

save "`base_out'", replace 
log close

