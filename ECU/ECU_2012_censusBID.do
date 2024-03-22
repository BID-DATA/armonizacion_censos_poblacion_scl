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
Año: 2012
Autores: Cesar Lins
Última versión: Noviembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS ECU
local ANO "2012"

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

	***************
	***afroind_ci***
	***************

gen afroind_ci=. 
replace afroind_ci=1  if race == 30 | indig == 1 
replace afroind_ci=2 if race == 20 | race == 23 | race == 53
replace afroind_ci=3 if race == 10 | race == 52 | race == 60 | race == 61 
replace afroind_ci=. if (race==90 & indig!=1)


