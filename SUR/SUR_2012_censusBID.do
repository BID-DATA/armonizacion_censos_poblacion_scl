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
País: Surinam
Año: 2012
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


local PAIS SUR
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
   replace region_c=1 if geo1_sr==740001		/*Paramaribo*/
   replace region_c=2 if geo1_sr==740002		/*Wanica*/
   replace region_c=3 if geo1_sr==740003		/*Nickerie*/
   replace region_c=4 if geo1_sr==740005		/*Saramacca, Coronie*/
   replace region_c=5 if geo1_sr==740006		/*Marowijne, Commewijne*/
   replace region_c=6 if geo1_sr==740008		/*Brokopondo, Para*/
   replace region_c=7 if geo1_sr==740010		/*Sipaliwini*/

	label define region_c 1"Paramaribo" 2"Wanica" 3"Nickerie" 4"Saramacca, Coronie" 5"Marowijne, Commewijne" 6"Brokopondo, Para" 7"Sipaliwini" 
    label value region_c region_c
	label var region_c "division politico-administrativa, Distritos"

*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				

	***************
	***afroind_ci***
	***************
**Pregunta: 
/* IPUMS does not keep the afro question */
gen afroind_ci=. 
replace afroind_ci=1  if indig==1 
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
gen afroind_ano_c=2004

************************
*** Discapacidad (WG)***
************************
/* Identificación de si una persona reporta por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */


gen dis_ci = 0
recode dis_ci nonmiss=. if inlist(9,sr2012a_dissight,sr2012a_dishear,sr2012a_dismobil,sr2012a_dismntl,sr2012a_discare,sr2012a_dislift,sr2012a_discomm) 
recode dis_ci nonmiss=. if sr2012a_dissight>=. & sr2012a_dishear>=. & sr2012a_dismobil>=. & sr2012a_dismntl>=. & sr2012a_discare>=. & sr2012a_dislift >=. & sr2012a_discomm>=. 

foreach x in sight hear mobil mntl care lift comm {
	forvalue j=2/4 {
		replace dis_ci=1 if sr2012a_dis`x'==`j'
	}
}

/*Identificación de si un hogar tiene uno o más miembros que reportan por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */		

egen dis_ch  = sum(dis_ci), by(idh_ch) 
replace dis_ch=1 if dis_ch>=1 & dis_ch!=. 


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
   
******************************************************
***           VARIABLES DE EDUCACIÓN               ***
******************************************************
    * SUR no tiene años, se generan las categorías a partir de educsr
    gen yrschool=.
	
	*********
	*aedu_ci* // años de educacion aprobados
	*********
	gen aedu_ci=yrschool

	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen eduno_ci=(educsr==1 | educsr==2) // never attended or pre-school
	replace eduno_ci=. if educsr==0 | educsr==99 // NIU & unknown
	
	***********
	*edupre_ci* // preescolar
	***********
	gen edupre_ci=(educsr==3) // pre-school
	replace edupre_ci=. if educsr==0 | educsr==99 // NIU & unknown
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=.

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(educsr==10) // primary
	replace edupc_ci=. if educsr==0 | educsr==99 // NIU & unknown

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(educsr==20)
	replace edusi_ci=. if educsr==0 | educsr==99 // NIU & unknown

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(educsr==31 | educsr==32) // senior secondary
	replace edusc_ci=.  if educsr==0 | educsr==99 // NIU & unknown

	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen edus1i_ci=.

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(educsr==20)
	replace edus1c_ci=. if educsr==0 | educsr==99 // NIU & unknown

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen edus2i_ci=.
	
	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(educsr ==31 | educsr ==32)
	replace edus2c_ci=. if educsr==0 | educsr==99 // NIU & unknown
	
	***********
	*asiste_ci*
	***********
	gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
	replace asiste_ci=. if school==0 | school==9 // missing a los NIU & missing

	**********
	*literacy*
	**********
	gen literacy=. 
	replace literacy=1 if lit==2 // literate
	replace literacy=0 if lit==1 // illiterate

*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************

order region_BID_c region_c pais_c anio_c idh_ch idp_ci factor_ch factor_ci estrato_ci zona_c sexo_ci edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch condocup_ci emp_ci desemp_ci pea_ci rama_ci categopri_ci spublico_ci ylm_ci ynlm_ci ylm_ch ynlm_ch aedu_ci eduno_ci edupre_ci edupi_ci  edupc_ci  edusi_ci edusc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci asiste_ci literacy aguared_ch luz_ch bano_ch des1_ch piso_ch banomejorado_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch migrante_ci migrantelac_ci migantiguo5_ci dis_ci dis_ch

include "../Base/labels.do"

compress

save "`base_out'", replace 
log close

