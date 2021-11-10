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
País: Ecuador
Año: 1974
Autores: Cesar Lins
Última versión: Noviembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS ECU
local ANO "1974"

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
   replace region_c=1 if geo1_ec==218001			    /*Azuay*/
   replace region_c=2 if geo1_ec==218002			    /*Bolivar*/
   replace region_c=3 if geo1_ec==218004			    /*Carchi*/
   replace region_c=4 if geo1_ec==218005			    /*Cotopaxi*/
   replace region_c=5 if geo1_ec==218006		     	/*Chimborazo*/
   replace region_c=6 if geo1_ec==218007			    /*El Oro*/
   replace region_c=7 if geo1_ec==218009			    /*Cañar, Esmeraldas, Guayas, Manabi, Manga del Cura*/
   replace region_c=8 if geo1_ec==218010			    /*Imbabura, Las Golondrinas*/
   replace region_c=9 if geo1_ec==218011			    /*Loja*/
   replace region_c=10 if geo1_ec==218014			/*Morona Santiago*/
   replace region_c=11 if geo1_ec==218016			/*Pastaza*/
   replace region_c=12 if geo1_ec==218018			/*Tungurahua*/
   replace region_c=13 if geo1_ec==218019			/*Zamora Chinchipe*/
   replace region_c=14 if geo1_ec==218021			/*Napo, Orellana, Sucumbios*/
   replace region_c=99 if geo1_ec==218099			/*Unknown*/

	label define region_c 1"Azuay" 2"Bolivar" 3"Carchi" 4"Cotopaxi" 5"Chimborazo" 6"El Oro" 7"Cañar, Esmeraldas, Guayas, Manabi, Manga del Cura" 8"Imbabura, Las Golondrinas" 9"Loja" 10"Morona Santiago" 11"Pastaza" 12"Tungurahua" 13"Zamora Chinchipe" 14"Napo, Orellana, Sucumbios" 99 ""
    label value region_c region_c
	label var region_c "division politico-administrativa, provincias"
	
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
/*Argentina no tiene vars de ingreso, pero se incluyen las 
variables de ingreso por hogar porque no están en el do Base*/	

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
	replace aedu_ci=. if yrschool==90 // unknown/missing or NIU

	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen eduno_ci=(aedu_ci==0) // never attended or pre-school
	replace eduno_ci=. if aedu_ci==. // NIU & missing

	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=(educec==120) // pre-school
	replace edupre_ci=. if aedu_ci==. // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) // primary (zero years completed) + grade 1-5 + primary grade unknown
	replace edupi_ci=. if aedu_ci==. // NIU & missing

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

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=(aedu_ci>=17) //más de 17
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

