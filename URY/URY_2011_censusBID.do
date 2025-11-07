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
***************************************************************************
*/


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

	*********
	*afro_ci*
	*********
	gen byte afro_ci = . 	  // se queda como missing (.) si no existe la pregunta
	replace afro_ci =1 if uy2011a_ethnbl==1
	replace afro_ci =0 if uy2011a_ethnbl==2
	
	*********
	*indi_ci*
	*********	
	gen byte ind_ci =. 		  // se queda como missing (.) si no existe la pregunta
	replace ind_ci =1 if uy2011a_ethnid==1
	replace ind_ci =0 if uy2011a_ethnid==2

	**************
	*noafroind_ci*
	**************
	gen byte noafroind_ci =.   // se queda como missing (.) si no existe la pregunta
	replace noafroind_ci =1 if (afro_ci==0 & ind_ci==0)
	replace noafroind_ci =0 if (afro_ci==1 | ind_ci==1)
	replace noafroind_ci =. if (afro_ci==. | ind_ci==.) //Esto solo en el caso que se tenga ambas opciones no disponibles. 
	ta noafroind_ci,m

	************
	*afroind_ci*
	************
	*En este caso, vamos  a tomar en cuenta la principal etnicidad (uy2011a_ancestry)
	gen byte afroind_ci=. 
	replace afroind_ci=1 if uy2011a_ancestry==4
	replace afroind_ci=2 if uy2011a_ancestry==1
	replace afroind_ci=3 if inlist(uy2011a_ancestry,2,3,5,6)
	ta afroind_ci,m
	
	*********
	*afro_ch*
	*********
	gen byte afro_jefe = afro_ci if relacion_ci==1
	egen afro_ch  = max(afro_jefe), by(idh_ch) 
	drop afro_jefe
	
	********
	*ind_ch*
	********	
	gen byte ind_jefe = ind_ci if relacion_ci==1
	egen ind_ch = max(ind_jefe), by(idh_ch) 
	drop ind_jefe

	**************
	*noafroind_ch*
	**************
	gen byte noafroind_jefe = noafroind_ci if relacion_ci==1
	egen noafroind_ch = max(noafroind_jefe), by(idh_ch) 
	drop noafroind_jefe

	************
	*afroind_ch*
	************
    gen byte afroind_jefe = afroind_ci if jefe_ci==1
	egen afroind_ch = min(afroind_jefe), by(idh_ch) 
	drop afroind_jefe 

	********
	*dis_ci*
	********
	gen byte dis_ci=.
	replace dis_ci=1 if inrange(uy2011a_dissee,2,4) | inrange( uy2011a_dishear,2,4) | inrange(uy2011a_dismob,2,4) | inrange(uy2011a_disdev,2,4)
	replace dis_ci=0 if uy2011a_dissee==1 & uy2011a_dishear==1 & uy2011a_dismob==1 & uy2011a_disdev==1 
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=.
	replace disWG_ci=1 if inrange(uy2011a_dissee,3,4) | inrange( uy2011a_dishear,3,4) | inrange(uy2011a_dismob,3,4) | inrange(uy2011a_disdev,3,4)
	replace disWG_ci=0 if inrange(uy2011a_dissee,1,2) & inrange( uy2011a_dishear,1,2) & inrange(uy2011a_dismob,1,2) & inrange(uy2011a_disdev,1,2)
	
	********
	*dis_ch*
	********
	egen byte dis_ch = max(dis_ci), by(idh_ch) 
	
	******************
	*URY_dis_ci*
	******************
	gen byte URY_dis_ci = dis_ci


/*******************************************************************************
   Incluir variables externas
*******************************************************************************/
capture drop _merge
merge m:1 pais_c anio_c using "Z:/general_documentation/data_externa/poverty/International_Poverty_Lines/5_International_Poverty_Lines_LAC_long_PPP17.dta", keepusing(tc_wdi ppp_wdi ppp_2017 cpi cpi2017 cpi_2017 lp365_2017 lp685_2017 lp14_2017 lp81_2017 )
drop if _merge ==2

g tc_c     = tc_wdi
g ppp_c    = ppp_wdi
g cpi_c    = cpi
g ratio_cpi2017 = cpi_2017

cap label var tc_c     "Tipo de cambio oficial (año de la encuesta)"
cap label var ppp_c    "Poder de paridad adquisitivo (año de la encuesta)"
cap label var ppp_2017 "Poder de paridad adquisitivo (PPP) 2017"
cap label var cpi_c   "Índice de precios al consumidor (año de la encuesta)"
cap label var cpi2017 "Índice de precios al consumidor (2017)"
cap label var ratio_cpi2017 "Tasa de índice de precios al consumidor (CPI_actual/CPI_2017)"
cap label var lp365_2017 "Línea de pobreza extrema USD 3.1 per capita, moneda local PPP 2017"
cap label var lp685_2017 "Línea de pobreza moderada USD 6.85 per capita, moneda local PPP 2017"
cap label var lp14_2017  "Línea de vulnerabilidad USD 14.15 per capita, moneda local PPP 2017"
cap label var lp81_2017  "Línea de clase media USD 81.22 per capita, moneda local PPP 2017"

drop  cpi_2017 tc_wdi _merge

/*******************************************************************************
   Revisión de que se hayan creado todas las variables
*******************************************************************************/
* CALIDAD: revisa que hayas creado todas las variables. Si alguna no está
* creada, te apacerá en rojo el nombre. 

global lista_variables region_BID_c region_c geolev1 pais_c anio_c idh_ch idp_ci factor_ci factor_ch estrato_ci upm zona_c sexo_c edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch miembros_ci clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch afro_ci ind_ci noafroind_ci afroind_ci afro_ch ind_ch noafroind_ch afroind_ch  dis_ci disWG_ci dis_ch migrante_ci migrantiguo5_ci miglac_ci aedu_ci eduno_ci edupi_ci edupc_ci edusi_ci edusc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci edupre_ci asiste_ci literacy condocup_ci emp_ci desemp_ci pea_ci rama_ci  categopri_ci spublico_ci luz_ch piso_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch aguaentubada_ch aguared_ch aguafuente_ch aguadist_ch aguadisp1_ch aguadisp2_ch aguamide_ch bano_ch banoex_ch banoalcantarillado_ch sinbano_ch conbano_ch des1_ch ${PAIS}_ingreso_ci ${PAIS}_ingresolab_ci ${PAIS}_m_pared_ch ${PAIS}_m_piso_ch ${PAIS}_m_techo_ch ${PAIS}_dis_ci tc_c ppp_c ppp_2017 cpi_c cpi2017 ratio_cpi2017 lp365_2017 lp685_2017 lp14_2017  lp81_2017

* selecciona las siguientes 6 líneas y ejecuta (do)
foreach v of global lista_variables {
	cap confirm variable `v'
	if _rc == 111 {
		display in red "variable `v' NO existe."
		gen `v' = .
	}
}



/*******************************************************************************
   Borrar variables originales con exepción de los identificadores 
*******************************************************************************/
* En "..." agregar la lista de variables de ID originales (por ejemplo los ID de personas, vivienda y hogar)

keep  $lista_variables serial pernum
* selecciona las 3 lineas y ejecuta (do). Deben quedar 108 variables de las secciones II y III más las 
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
 