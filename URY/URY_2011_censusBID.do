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
País: Uruguay
Año: 2011
Autores: Cesar Lins y Nathalia Maya
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/


global PAIS URY 				 //cambiar
global ANIO 2011   				 //cambiar

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
include "../Base/base.do"


*****************************************************
******* Variables específicas del censo    **********
*****************************************************

****** REGION *****************
gen region_c=geo1_uy2011
label define region_c ///
           1 "Montevideo" ///
           2 "Artigas" /// 
           3 "Canelones" /// 
           4 "Cerro Largo" /// 
           5 "Colonia" /// 
           6 "Durazno" /// 
           7 "Flores" /// 
           8 "Florida" /// 
           9 "Lavalleja" /// 
          10 "Maldonado" /// 
          11 "Paysandú" /// 
          12 "Río Negro" /// 
          13 "Rivera" /// 
          14 "Rocha" /// 
          15 "Salto" /// 
          16 "San José" /// 
          17 "Soriano" /// 
          18 "Tacuarembó" ///
          19 "Treinta y Tres" 
label values region_c region_c



***********************************************
****************** Educacion ******************
***********************************************
*Para el resto de los años se trabaja con la variable yrschool y se crea aedu_ci. Para 2011 esta informacion no esta disponible.

*************
***aedu_ci*** // años de educacion aprobados
*************
gen aedu_ci=.

**************
***eduno_ci***
**************
gen eduno_ci=(educuy==100 | educuy==200)
replace eduno_ci=. if educuy==0 | educuy==998

***************
***edupre_ci***
***************
gen edupre_ci=(educuy==200)
replace edupre_ci=. if educuy==0 | educuy==998

**************
***edupi_ci*** // no completó la educación primaria
**************
gen edupi_ci=(educuy==300 & edattaind==120) // educuy==300 por si solo incluye individuos con primaria completa.
replace edupi_ci=. if educuy==0 | educuy==998

**************
***edupc_ci*** // completó la educación primaria
**************
gen edupc_ci=(edattaind==212 & educuy==300) // edattaind==212 por si solo incluye individuos con sec incompleta y educuy==300 por si solo incluye individuos con algo de primaria completa.
replace edupc_ci=. if educuy==0 | educuy==998

**************
***edusi_ci*** // no completó la educación secundaria
**************
gen edusi_ci=(educuy==400)
replace edusi_ci=. if educuy==0 | educuy==998

**************
***edusc_ci*** // completó la educación secundaria
**************
gen edusc_ci=(educuy==410)
replace edusc_ci=. if educuy==0 | educuy==998

***************
***edus1i_ci*** // no completó el primer ciclo de la educación secundaria
***************
gen edus1i_ci=.

***************
***edus1c_ci*** // completó el primer ciclo de la educación secundaria
***************
gen edus1c_ci=(educuy==400)
replace edus1c_ci=. if educuy==0 | educuy==998

***************
***edus2i_ci*** // no completó el segundo ciclo de la educación secundaria
***************
gen edus2i_ci=.

***************
***edus2c_ci*** // completó el segundo ciclo de la educación secundaria
***************
gen edus2c_ci=(educuy==410)
replace edus2c_ci=. if educuy==0 | educuy==998

***************
***asiste_ci***
***************
gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
replace asiste_ci=. if school==9 // missing a los NIU & missing

**************
***literacy***
**************
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
replace afroind_ci=1  if race == 30 | race==52
replace afroind_ci=2 if race == 20 | race == 56 /* two or more races */
replace afroind_ci=3 if race == 10 | race == 40 | race == 60


	***************
	***afroind_ch***
	***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=2006

************************
*** Discapacidad (WG)***
************************
/* Identificación de si una persona reporta por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */


gen dis_ci = 0
recode dis_ci nonmiss=. if inlist(9,uy2011a_disdev,uy2011a_dishear,uy2011a_dismob,uy2011a_dissee) //
recode dis_ci nonmiss=. if uy2011a_disdev>=. & uy2011a_dishear>=. & uy2011a_dismob>=. & uy2011a_dissee>=. //
	foreach i in dev hear mob see {
		forvalues j=2/4 {
		replace dis_ci=1 if uy2011a_dis`i'==`j'
		}
		}

/*Identificación de si un hogar tiene uno o más miembros que reportan por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */		

egen dis_ch  = sum(dis_ci), by(idh_ch) 
replace dis_ch=1 if dis_ch>=1 & dis_ch!=. 


/*******************************************************************************
   Incluir variables externas
*******************************************************************************/
capture drop _merge
merge m:1 pais_c anio_c using "Z:/general_documentation/data_externa/poverty/International_Poverty_Lines/5_International_Poverty_Lines_LAC_long_PPP17.dta", keepusing (lp19_2011 lp31_2011 lp5_2011 tc_wdi lp365_2017 lp685_201 cpi_2017)
drop if _merge ==2

g tc_c     = tc_wdi
g ipc_c    = cpi_2017
g lp19_ci  = lp19_2011 
g lp31_ci  = lp31_2011 
g lp5_ci   = lp5_2011

capture label var tc_c "Tasa de cambio LCU/USD Fuente: WB/WDI"
capture label var ipc_c "Índice de precios al consumidor base 2017=100 Fuente: IMF/WEO"
capture label var lp19_ci  "Línea de pobreza USD1.9 día en moneda local a precios corrientes a PPA 2011"
capture label var lp31_ci  "Línea de pobreza USD3.1 día en moneda local a precios corrientes a PPA 2011"
capture label var lp5_ci "Línea de pobreza USD5 por día en moneda local a precios corrientes a PPA 2011"
capture label var lp365_2017  "Línea de pobreza USD3.65 día en moneda local a precios corrientes a PPA 2017"
capture label var lp685_2017 "Línea de pobreza USD6.85 por día en moneda local a precios corrientes a PPA 2017"

drop  cpi_2017 lp19_2011 lp31_2011 lp5_2011 tc_wdi _merge

/*******************************************************************************
   Revisión de que se hayan creado todas las variables
*******************************************************************************/
* CALIDAD: revisa que hayas creado todas las variables. Si alguna no está
* creada, te apacerá en rojo el nombre. 

global lista_variables region_BID_c region_c geolev1 pais_c anio_c idh_ch idp_ci factor_ci factor_ch estrato_ci upm zona_c sexo_c edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch miembros_ci clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch afro_ci ind_ci noafroind_ci afroind_ci afro_ch ind_ch noafroind_ch afroind_ch  dis_ci disWG_ci dis_ch migrante_ci migrantiguo5_ci miglac_ci aedu_ci eduno_ci edupi_ci edupc_ci edusi_ci edusc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci edupre_ci asiste_ci literacy condocup_ci emp_ci desemp_ci pea_ci rama_ci  categopri_ci spublico_ci luz_ch piso_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch aguaentubada_ch aguared_ch aguafuente_ch aguadist_ch aguadisp1_ch aguadisp2_ch aguamide_ch bano_ch banoex_ch banoalcantarillado_ch sinbano_ch conbano_ch des1_ch ${PAIS}_ingreso_ci ${PAIS}_ingresolab_ci ${PAIS}_m_pared_ch ${PAIS}_m_piso_ch ${PAIS}_m_techo_ch ${PAIS}_dis_ci tc_c ipc_c lp19_ci lp31_ci lp5_ci lp365_2017  lp685_2017

* selecciona las siguientes 6 líneas y ejecuta (do)
foreach v of global lista_variables {
	cap confirm variable `v'
	if _rc == 111 {
		display in red "variable `v' NO existe."
	}
}


/*******************************************************************************
   Borrar variables originales con exepción de los identificadores 
*******************************************************************************/
* En "..." agregar la lista de variables de ID originales (por ejemplo los ID de personas, vivienda y hogar)

keep  $lista_variables serial pernum
* selecciona las 3 lineas y ejecuta (do). Deben quedar 105 variables de las secciones II y III más las 
* variables originales de ID que hayas mantenido
ds
local varconteo: word count `r(varlist)'
display "Número de variables de la base: `varconteo'"


/*******************************************************************************
   Incluir etiquetas para las variables y categorías
*******************************************************************************/
include "$gitFolder\armonizacion_censos_poblacion_scl\Base\labels_general.do"


/*******************************************************************************
   Guardar la base armonizada 
*******************************************************************************/
compress
save "$base_out", replace 

log close

********************************************************************************
******************* FIN. Muchas gracias por tu trabajo ;) **********************
********************************************************************************
 