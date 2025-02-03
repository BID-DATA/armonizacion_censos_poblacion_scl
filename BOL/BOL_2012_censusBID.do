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

global PAIS BOL  				 //cambiar
global ANIO 2012   				 //cambiar


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Bolivia
Año:
Autores: 
Última versión: 
							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

*****************************************************
******* Variables específicas del censo    **********
*****************************************************
include "../Base/base.do"

****************
 *** region_c ***
 ****************


   gen region_c=.
   replace region_c=1 if geo1_bo==68001  
   replace region_c=2 if geo1_bo==68002
   replace region_c=3 if geo1_bo==68003
   replace region_c=4 if geo1_bo==68004
   replace region_c=5 if geo1_bo==68005
   replace region_c=6 if geo1_bo==68006
   replace region_c=7 if geo1_bo==68007
   replace region_c=8 if geo1_bo==68008
   replace region_c=9 if geo1_bo==68009
   
   label define region_c 1 "Chuqisaca" 2 "La paz" 3 "Cochabamba" 4 "Oruro" 5 "Potosá" 6 "Tarija" 7 "Santa Cruz" 8 "Beni" 9 "Pando", add modify 
   label value region_c region_c 

	

*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
**Pregunta: 

gen afroind_ci=. 
replace afroind_ci=1 if indig == 1
replace afroind_ci=2 if ethnicbo == 6
replace afroind_ci=3 if indig == 2 & ethnicbo!=6
replace afroind_ci=. if ethnicbo == 98 // Unknown


	***************
	***afroind_ch***
	***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

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


************************
* VARIABLES EDUCATIVAS *
************************

***************
***asiste_ci*** 
***************
gen asiste_ci=1 if school==1
replace asiste_ci=. if school==0 // not in universe as missing 
replace asiste_ci=. if school==9 // Unknown/missing as missing
replace asiste_ci=0 if school==2

*************
***aedu_ci*** 
************* 
gen aedu_ci=yrschool
replace aedu_ci=. if yrschool>=90 & yrschool<100 // categorias NIU; missing; + categorias nivel educativo pero pero sin años de escolaridad

**************
***eduno_ci*** // no ha completado ningún año de educación
**************
gen byte eduno_ci=0
replace eduno_ci=1 if aedu_ci==0
replace eduno_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

**************
***edupi_ci*** // no completó la educación primaria
**************
gen byte edupi_ci=0
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<5 // se pone menor a 5 porque hay cohortes que tiene completa con 5 
replace edupi_ci=1 if yrschool==91 // Some primary
replace edupi_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

**************
***edupc_ci***
**************
gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==6
replace edupc_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

**************
***edusi_ci***
**************
gen byte edusi_ci=0
replace edusi_ci=1 if aedu_ci>6 & aedu_ci<12
replace edusi_ci=1 if yrschool==92 | yrschool==93 // Some techinical after primary and some secondary
replace edusi_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

**************
***edusc_ci***
**************
gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==12
replace edusc_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)

***************
***edus1i_ci***
***************
gen edus1i_ci=(aedu_ci==7)
replace edus1i_ci=. if aedu_ci==. // NIU

***************
***edus1c_ci***
***************
gen edus1c_ci=(aedu_ci==8)
replace edus1c_ci=. if aedu_ci==. // NIU

***************
***edus2i_ci***
***************
gen edus2i_ci=(aedu_ci>=9 & aedu_ci<12)
replace edus2i_ci=. if aedu_ci==. // NIU

***************
***edus2c_ci***
***************
gen edus2c_ci=(aedu_ci==12)
replace edus2c_ci=. if aedu_ci==. // NIU

***************
***edupre_ci***
***************
gen edupre_ci=(educbo==120) // pre-school
replace edupre_ci=. if aedu_ci==. // NIU & missing

**************
***literacy***
**************
gen literacy=. if lit==0
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
 

