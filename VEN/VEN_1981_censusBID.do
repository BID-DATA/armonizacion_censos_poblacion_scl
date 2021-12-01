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
País: Paraguay
Año: 2000
Autores: Carolina Rivas
Última versión: Nov, 2021

							SCL/LMK - IADB
****************************************************************************/

local PAIS VEN
local ANO "1981"

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
replace region_c=1 if geo1_ve1981==1	/*Federal District */
replace region_c=2 if geo1_ve1981==22	/*San Amazonas*/
replace region_c=3 if geo1_ve1981==2	/*Anzoátegui*/
replace region_c=4 if geo1_ve1981==3	/*Apure*/
replace region_c=5 if geo1_ve1981==4	/*Aragua*/
replace region_c=6 if geo1_ve1981==5	/*Barinas*/
replace region_c=7 if geo1_ve1981==6	/*Bolívar*/
replace region_c=8 if geo1_ve1981==7	/*Carabobo*/
replace region_c=9 if geo1_ve1981==8	/*Cojedes*/
replace region_c=10 if geo1_ve1981==23	/*Delta Amacuro*/
replace region_c=11 if geo1_ve1981==9	/*Falcón*/
replace region_c=12 if geo1_ve1981==10	/*Guárico*/
replace region_c=13 if geo1_ve1981==11	/*Lara*/
replace region_c=14 if geo1_ve1981==12	/*Mérida*/
replace region_c=15 if geo1_ve1981==13	/*Miranda*/
replace region_c=16 if geo1_ve1981==14	/*Monagas*/
replace region_c=17 if geo1_ve1981==15	/*Nueva Esparta*/
replace region_c=18 if geo1_ve1981==16	/*Portuguesa*/
replace region_c=19 if geo1_ve1981==17	/*Sucre*/
replace region_c=20 if geo1_ve1981==18	/*Táchira*/
replace region_c=21 if geo1_ve1981==19	/*Trujillo*/
replace region_c=22 if geo1_ve1981==20	/*Yaracuy*/
replace region_c=23 if geo1_ve1981==21	/*Zulia*/
*	replace region_c=24 if geo1_ve1981==24	/*Vargas*/
		

	label define region_c ///
	 1 "Federal District" ///
	 2 "San Amazonas" ///
	 3	"Anzoátegui" ///
	 4	"Apure" ///
	 5	"Aragua" ///
	 6	"Barinas" ///
	 7	"Bolívar" ///
	 8	"Carabobo" ///
	 9	"Cojedes" ///
	 10	"Delta Amacuro" ///
	 11	"Falcón" ///
	 12	"Guárico" ///
	 13	"Lara" ///
	 14	"Mérida" ///
	 15	"Miranda" ///
	 16	"Monagas" ///
	 17	"Nueva Esparta" ///
	 18 "Portuguesa" ///
	 19 "Sucre" ///
	 20 "Táchira" ///
	 21 "Trujillo" ///
	 22 "Yaracuy" ///
	 23 "Zulia" ///
	 24 "Vargas" ///

	label value region_c region_c
	label var region_c "division politico-administrativa, departamento"

	
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
	gen edupre_ci=(educve==100) // pre-school
	replace edupre_ci=. if aedu_ci==. // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) //
	replace edupi_ci=. if aedu_ci==. // NIU & missing
	replace edupi_ci = 1 if yrschool == 91 // some primary

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci==6) 
	replace edupc_ci=. if aedu_ci==. // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<=10) // 7 a 10 anos de educación
	replace edusi_ci=. if aedu_ci==. // NIU & missing
	replace edusi_ci = 1 if yrschool == 92 | yrschool ==93 //some technical after primary or some secondary

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==11) // 11 anos de educación
	replace edusc_ci=. if aedu_ci==. // NIU & missing
	
	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=12 & aedu_ci<=15) // 14 a 16 anos de educación
	replace eduui_ci=. if aedu_ci==. // NIU & missing
	replace eduui_ci = 1 if yrschool == 94 // some terciary

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=.
	replace eduuc_ci=(aedu_ci>15) // más de 15
	replace eduuc_ci=. if aedu_ci==. // NIU & missing

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
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<11)
	replace edus2i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==11)
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
	*replace afroind_ci=1  if race == 30 | indig == 1
	*replace afroind_ci=2 if race == 20
	*replace afroind_ci=3 if race == 10 | race == 40 | race == 41 | race == 53 | race == 60
	*replace afroind_ci=. if (race == 99 & indig !=1)


		***************
		***afroind_ch***
		***************
	gen afroind_jefe=.
	gen afroind_ch=.
	*replace afroind_ci if relate==1
	*egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

	drop afroind_jefe 

		*******************
		***afroind_ano_c***
		*******************
	gen afroind_ano_c=.


		********************
		*** discapacidad ***
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

