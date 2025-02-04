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
País: Brasil
Año: 2010
Autores: Cesar Lins
Última versión: Septiembre, 2021
							SCL/LMK - IADB
****************************************************************************/


global PAIS BRA   				 //cambiar
global ANIO 2010   				 //cambiar

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
 replace region_c=1 if geo1_br ==76011  /*Rondônia*/
 replace region_c=2 if geo1_br ==76012  /*Acre*/
 replace region_c=3 if geo1_br ==76013 /*Amazonas*/
 replace region_c=4 if geo1_br ==76014 /*Roraima*/
 replace region_c=5 if geo1_br ==76015 /*Pará*/
 replace region_c=6 if geo1_br ==76016 /*Amapá*/
 replace region_c=7 if geo1_br ==76017 /*Tocantins*/
 replace region_c=8 if geo1_br ==76021 /*Maranhão*/
 replace region_c=9 if geo1_br ==76022 /*Piauí*/
 replace region_c=10 if geo1_br ==76023 /*Ceará*/
 replace region_c=11 if geo1_br ==76024 /*Rio Grande do Norte*/
 replace region_c=12 if geo1_br ==76025 /*Paraíba*/
 replace region_c=13 if geo1_br ==76026 /*Pernambuco*/
 replace region_c=14 if geo1_br ==76027 /*Alagoas*/
 replace region_c=15 if geo1_br ==76028 /*Sergipe*/
 replace region_c=16 if geo1_br ==76029 /*Bahia*/
 replace region_c=17 if geo1_br ==76031 /*Minas Gerais*/
 replace region_c=18 if geo1_br ==76032 /*Espírito Santo*/
 replace region_c=19 if geo1_br ==76033 /*Rio de Janeiro*/
 replace region_c=20 if geo1_br ==76035 /*São Paulo*/
 replace region_c=21 if geo1_br ==76041 /*Paraná*/
 replace region_c=22 if geo1_br ==76042 /*Santa Catarina*/
 replace region_c=23 if geo1_br ==76043 /*Rio Grande do Sul*/
 replace region_c=24 if geo1_br ==76050 /*Mato Grosso do Sul*/
 replace region_c=25 if geo1_br ==76051 /*Mato Grosso*/
 replace region_c=26 if geo1_br ==76052 /*Goiás*/
 replace region_c=27 if geo1_br ==76053 /*Distrito Federal*/

 label define region_c 1"Rondônia" 2"Acre" 3"Amazonas" 4"Roraima" 5"Pará" 6"Amapá" 7"Tocantins" 8"Maranhão" 9"Piauí" 10"Ceará" 11"Rio Grande do Norte" 12"Paraíba" 13"Pernambuco" 14"Alagoas" 15"Sergipe" 16"Bahia" 17"Minas Gerais" 18"Espírito Santo" 19"Rio de Janeiro" 20"São Paulo" 21"Paraná" 22"Santa Catarina" 23"Rio Grande do Sul" 24"Mato Grosso do Sul" 25"Mato Grosso" 26"Goiás" 27"Distrito Federal"
label values region_c region_c 
 
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
**Pregunta: 

gen afroind_ci=. 
replace afroind_ci=1  if race == 30
replace afroind_ci=2 if race == 20 | race == 51 
replace afroind_ci=3 if race == 10 | race == 40 
replace afroind_ci=. if race == 99

	***************
	***afroind_ch***
	***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=1960

************************
*** Discapacidad (WG)***
************************
/* Identificación de si una persona reporta por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */

gen dis_ci = 0
recode dis_ci nonmiss=. if inlist(9,br2010a_dissee,br2010a_dishear,br2010a_dismob) //
recode dis_ci nonmiss=. if br2010a_dissee>=. & br2010a_dishear>=. & br2010a_dismob>=. //
	foreach i in see hear mob {
		forvalues j=1/3 {
		replace dis_ci=1 if br2010a_dis`i'==`j'
		}
		}

/*Identificación de si un hogar tiene uno o más miembros que reportan por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */		

egen dis_ch  = sum(dis_ci), by(idh_ch) 
replace dis_ch=1 if dis_ch>=1 & dis_ch!=. 


****************************
***	VARIABLES EDUCATIVAS ***
****************************
* BRA 2010 no tiene vairables yrschool se contruye a partir de eddatain y educbr

***********
*asiste_ci*
***********
gen asiste_ci=(school==1) // 0 includes attended in the past (3) and never attended (4)
replace asiste_ci=. if school==0 | school==9 | school==. // missing a los NIU & missing
	
*********
*aedu_ci* // años de educacion aprobados
*********
gen aedu_ci=.
replace aedu_ci=0 if educbr<2000
replace aedu_ci=1 if educbr==2110
replace aedu_ci=2 if educbr==2120
replace aedu_ci=3 if educbr==2130
replace aedu_ci=4 if educbr==2141
replace aedu_ci=5 if educbr==2210
replace aedu_ci=6 if educbr==2220
replace aedu_ci=7 if educbr==2230
replace aedu_ci=8 if educbr==2241
replace aedu_ci=9 if educbr==2242
replace aedu_ci=10 if educbr==3100
replace aedu_ci=11 if educbr==3200
replace aedu_ci=12 if educbr==3300
replace aedu_ci=13 if educbr==4170 | educbr==4180
replace aedu_ci=16 if educbr==4190
replace aedu_ci=18 if educbr==4230 | educbr==4240 | educbr==4270 | educbr==4280
replace aedu_ci=20 if educbr==4250 | educbr==4260

**********
*eduno_ci*
**********
gen eduno_ci=(aedu_ci==0) // none
replace eduno_ci=. if aedu_ci==.

***********
*edupre_ci*
***********
gen edupre_ci=.
	
**********
*edupi_ci* // no completó la educación primaria
**********	
gen edupi_ci=(aedu_ci>=1 & aedu_ci<=4) // 1 a 4 anos de educación 
replace edupi_ci=. if aedu_ci==.
	
********** 
*edupc_ci* // completó la educación primaria
**********
gen edupc_ci=(aedu_ci==5) // 5 anos de educación
replace edupc_ci=. if aedu_ci==.

**********
*edusi_ci* // no completó la educación secundaria
**********
gen edusi_ci=(aedu_ci>=6 & aedu_ci<=11) // De 6 a 11 anos de educación
replace edusi_ci=. if aedu_ci==.

**********
*edusc_ci* // completó la educación secundaria
**********	
gen edusc_ci=(aedu_ci==12) // 12 anos de educación
replace edusc_ci=. if aedu_ci==.

***********
*edus1i_ci* // no completó el primer ciclo de la educación secundaria
***********
gen edus1i_ci=(aedu_ci>=6 & aedu_ci<=8) // De 6 a 8 anos de educación
replace edus1i_ci=. if aedu_ci==.

***********
*edus1c_ci* // completó el primer ciclo de la educación secundaria
***********
gen edus1c_ci=(aedu_ci==9) // 9 anos de educación
replace edus1c_ci=. if aedu_ci==.

***********
*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
***********
gen edus2i_ci=(aedu_ci>=10 & aedu_ci<=11) // De 10 a 11 anos de educación
replace edus2i_ci=. if aedu_ci==.

***********
*edus2c_ci* // completó el segundo ciclo de la educación secundaria
***********
gen edus2c_ci=(aedu_ci==12) // 12 anos de educación
replace edus2c_ci=. if aedu_ci==.

************
* literacy *
************
gen literacy=1 if lit==2 // literate
replace literacy=0 if lit==1 // illiterate


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
 

