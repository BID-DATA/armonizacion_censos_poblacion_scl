
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
País:  Trinidad & Tobago
Año: 2011
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************
global PAIS TTO  				 //cambiar
global ANIO 2011   				 //cambiar

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

*****************************************************
******* Variables específicas del censo    **********
*****************************************************

include "../Base/base.do"

     ****************
     *** region_c ***
     ****************

   gen region_c=.   
   replace region_c=1 if geo1_tt2011 == 10			/*Port of Spain*/
   replace region_c=2 if geo1_tt2011 == 11			/*Mayaro*/
   replace region_c=3 if geo1_tt2011 == 12			/*Sangre Grande*/
   replace region_c=4 if geo1_tt2011 == 13			/*Princess Town*/
   replace region_c=5 if geo1_tt2011 == 14			/*Penal/ Debe*/
   replace region_c=6 if geo1_tt2011 == 15		    /*Siparia, Point Fontin*/
   replace region_c=7 if geo1_tt2011 == 20			/*San Fernando*/
   replace region_c=8 if geo1_tt2011 == 30			/*Arima*/
   replace region_c=9 if geo1_tt2011 == 40			/*Chaguanas*/
   replace region_c=10 if geo1_tt2011 == 60			/*Diego Martin*/
   replace region_c=11 if geo1_tt2011 == 70			/*San Juan/ Laventille*/
   replace region_c=12 if geo1_tt2011 == 80			/*Tunapuna*/
   replace region_c=13 if geo1_tt2011 == 90			/*Couva*/
   replace region_c=14 if geo1_tt2011 == 93			/*St. Andrew, St. Patrick*/
   replace region_c=15 if geo1_tt2011 == 95		/*St. John, St. Mary, St. Paul, St. George, St. David*/


	  label define region_c 1"Port of Spain" 2"Mayaro" 3"Sangre Grande" 4"Princess Town"  5"Penal/ Debe" 6"Siparia, Point Fontin" 7"San Fernando" 8"Arima" 9"Chaguanas" 10"Diego Martin" 11"San Juan/ Laventille" 12"Tunapuna" 13"Couva" 14"St. Andrew, St. Patrick" 15"St. John, St. Mary, St. Paul, St. George, St. David"
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
	replace eduno_ci=. if aedu_ci==. // NIU & missing
	
	***********
	*edupre_ci* // preescolar
	***********
	gen edupre_ci=.
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<7) //
	replace edupi_ci=. if aedu_ci==. // NIU & missing
	replace edupi_ci = 1 if yrschool == 91 // some primary

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci==7 | edattain == 2)
	replace edupc_ci=. if aedu_ci==. // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<12) // 7 a 11 anos de educación
	replace edusi_ci=. if aedu_ci==. // NIU & missing
	replace edusi_ci = 1 if yrschool == 92 | yrschool ==93 //some technical after primary or some secondary

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==12) // 12 anos de educación
	replace edusc_ci=. if aedu_ci==. // NIU & missing
	
	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>7 & aedu_ci<10)
	replace edus1i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==10)
	replace edus1c_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>10 & aedu_ci<12)
	replace edus2i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==12)
	replace edus2c_ci=. if aedu_ci==. // missing a los NIU & missing

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
		  
	*******************************************************
	***           VARIABLES DE DIVERSIDAD               ***
	*******************************************************
	* Cesar Lins & Nathalia Maya - Septiembre 2021	

		gen afroind_ci=.
	replace afroind_ci = 1 if ethnictt == 4
	replace afroind_ci = 2 if ethnictt == 1
	replace afroind_ci = 3 if ethnictt == 2
	replace afroind_ci = 3 if ethnictt == 3
	replace afroind_ci = 3 if ethnictt == 5
	replace afroind_ci = 3 if ethnictt == 6
	replace afroind_ci = 3 if ethnictt == 8
	replace afroind_ci = 3 if ethnictt == 9
	replace afroind_ci = 3 if ethnictt == 97

		***************
		***afroind_ch***
		***************
	gen afroind_jefe= afroind_ci if relate==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

	drop afroind_jefe 

		*******************
		***afroind_ano_c***
		*******************
	gen afroind_ano_c=1970

	********************
	*** discapacid
	********************
	gen dis_ci=.
	gen dis_ch=.

   
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
 