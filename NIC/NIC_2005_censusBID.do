* (Versión Stata 17)
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
País: Nicaragua
Año: 2005
Autores: Cesar Lins, Nathalia Maya, Agustina Thailinger
Última versión: Noviembre, 2021

							SCL/LMK/EDU - IADB
****************************************************************************/

global PAIS NIC   				 //cambiar
global ANIO 2005   				 //cambiar

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
include "../Base/base.do"

*****************************************************
******* Variables específicas del censo    **********
*****************************************************

****************
*** region_c ***
****************
gen region_c=.
replace region_c=1 if geo1_ni==558005 // Nueva Segovia, Jinotega
replace region_c=2 if geo1_ni==558020 // Madriz
replace region_c=3 if geo1_ni==558025 // Esteli, Leon
replace region_c=4 if geo1_ni==558030 // Chinandega
replace region_c=5 if geo1_ni==558040 // Matagalpa, Atlantico Norte, Atlantico Sur, Zelaya
replace region_c=6 if geo1_ni==558050 // Boaco
replace region_c=7 if geo1_ni==558055 // Managua, Masaya
replace region_c=8 if geo1_ni==558065 // Chontales
replace region_c=9 if geo1_ni==558070 // Granada
replace region_c=10 if geo1_ni==558075 // Carazo
replace region_c=11 if geo1_ni==558080 // Rivas
replace region_c=12 if geo1_ni==558085 // Rio San Juan

label define region_c ///
	1 "Nueva Segovia, Jinotega" ///
	2 "Madriz" ///
	3 "Esteli. Leon" ///
	4 "Chinandega" ///
	5 "Matagalpa, Atlantico Norte, Atlantico Sur, Zelaya" ///
	6 "Boaco" ///
	7 "Managua, Masaya" ///
	8 "Chontales" ///
	9 "Granada" ///
	10 "Carazo" ///
	11 "Rivas" ///
	12 "Rio San Juan" ///
	
***************************************************
***           VARIABLES DE DIVERSIDAD           ***
***************************************************				

***************
***afroind_ci***
***************
gen afroind_ci=. 
replace afroind_ci=1  if indig==1 
replace afroind_ci=3 if indig==2


***************
***afroind_ch**
***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 
drop afroind_jefe 

*******************
***afroind_ano_c***
*******************
gen afroind_ano_c=2005

********************
*** discapacidad ***
********************
gen dis_ci=.
gen dis_ch=.

****************************
***VARIABLES DE EDUCACION***
****************************

***************
***asiste_ci*** 
*************** 
gen asiste_ci=1 if school==1
replace asiste_ci=0 if school==2
replace asiste_ci=. if school==0 // NIU
replace asiste_ci=. if school==9 // Unknown/missing 

*************
***aedu_ci*** // años de educacion aprobados
*************
gen aedu_ci=yrschool
replace aedu_ci=. if aedu_ci==98 // Unknown/missing
replace aedu_ci=. if aedu_ci==99 // NIU
replace aedu_ci=. if yrschool>=90 & yrschool<100 
	
**************
***eduno_ci*** // ningún nivel de instrucción
**************
gen byte eduno_ci=0
replace eduno_ci=1 if aedu_ci==0
replace eduno_ci=. if aedu_ci==.

**************
***edupi_ci*** // primaria incompleta
**************
gen byte edupi_ci=0
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<6
replace edupi_ci=. if aedu_ci==.
replace edupi_ci = 1 if yrschool == 91 // some primary

**************
***edupc_ci*** // primaria completa
**************
gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==6
replace edupc_ci=. if aedu_ci==.

**************
***edusi_ci*** // secundaria incompleta
**************
gen byte edusi_ci=0
replace edusi_ci=1 if aedu_ci>6 & aedu_ci<11
replace edusi_ci=. if aedu_ci==.
replace edusi_ci = 1 if yrschool ==92 | yrschool ==93 // some secondary

**************
***edusc_ci*** // secundaria completa
**************
gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==11
replace edusc_ci=. if aedu_ci==.

***************
***edus1i_ci*** // primer ciclo de secundaria incompleto
***************
gen byte edus1i_ci=0
replace edus1i_ci=1 if aedu_ci>6 & aedu_ci<9
replace edus1i_ci=. if aedu_ci==.

***************
***edus1c_ci*** // primer ciclo de secundaria completo
***************
gen byte edus1c_ci=0
replace edus1c_ci=1 if aedu_ci==9 
replace edus1c_ci=. if aedu_ci==.

***************
***edus2i_ci*** // segundo ciclo de secundaria incompleto
***************
gen byte edus2i_ci=0
replace edus2i_ci=1 if aedu_ci>9 & aedu_ci<11
replace edus2i_ci=. if aedu_ci==.

***************
***edus2c_ci*** // segundo ciclo de secundaria completo
***************
gen byte edus2c_ci=0
replace edus2c_ci=1 if aedu_ci==11
replace edus2c_ci=. if aedu_ci==.

***************
***edupre_ci*** // preescolar
***************
gen edupre_ci=(educni==121 | educni==123 | educni == 123) // pre-school
replace edupre_ci=. if educni==0 | educni==999 // NIU & missing
replace edupre_ci= . if aedu_ci==.

**************
***literacy***
**************
gen literacy=. if lit==0 // NIU
replace literacy=. if lit==9 // Unknown/missing
replace literacy=0 if lit==1
replace literacy=1 if lit==2


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
 

