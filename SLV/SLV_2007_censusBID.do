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
País: El Salvador
Año: 2007
Autores: 
Última versión: 05/09/2023

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

global PAIS SLV 				 //cambiar
global ANIO 2007   				 //cambiar

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

include "$gitFolder\armonizacion_censos_poblacion_scl\Base\base.do"

*****************************************************
******* Variables específicas del censo    **********
*****************************************************

 ****************
 *** region_c ***
 ****************

   gen region_c=.   
   replace region_c=1 if geo1_sv==222001				    /*Ahuachapán*/
   replace region_c=2 if geo1_sv==222002		    /*Santa Ana*/
   replace region_c=3 if geo1_sv==222003			    /*Sonsonate*/
   replace region_c=4 if geo1_sv==222004			    /*Chalatenango*/
   replace region_c=5 if geo1_sv==222005			    /*La Libertad*/
   replace region_c=6 if geo1_sv==222006			    /*San Salvador*/
   replace region_c=7 if geo1_sv==222007			    /*Cuscatlán*/
   replace region_c=8 if geo1_sv==222008			    /*La Paz*/
   replace region_c=9 if geo1_sv==222009			    /*Cabañas*/
   replace region_c=10 if geo1_sv==222010			    /*San Vicente*/
   replace region_c=11 if geo1_sv==222011			    /*Usulután*/
   replace region_c=12 if geo1_sv==222012			    /*San Miguel*/
   replace region_c=13 if geo1_sv==222013			    /*Morazán*/
   replace region_c=14 if geo1_sv==222014			    /*La Unión*/

   label define region_c 1"Ahuachapán" 2"Santa Ana" 3"Sonsonate" 4 "Chalatenango" ///
   5 "La Libertad" 6 "San Salvador" 7 "Cuscatlán" 8 "La Paz" 9 "Cabañas" 10 "San Vicente" ///
   11 "Usulután" 12 "San Miguel" 13 "Morazán" 14 "La Unión"

    label value region_c region_c
	label var region_c "division politico-administrativa, estados"
	
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
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
	gen afroind_ano_c=2007


	********************
	*** discapacidad ***
	********************
	gen dis_ci=.
	replace dis_ci=(dismobil==1 | disblnd ==1 | disdeaf==1 | discare==1 | dismute==1 | disuppr==1 )
	replace dis_ci=. if (dismobil==0 | dismobil==9) & (disblnd==0 | disblnd==9) & (disdeaf==0 | disdeaf==9) & (discare==0 | discare==9) & (dismute==0 | dismute==9)	& (disuppr==0 | disuppr==9)
	
	egen dis_ch = sum(dis_ci), by(idh_ch) 
	replace dis_ch=1 if dis_ch>=1 & dis_ch!=. 

	
******************************************************
***           VARIABLES DE EDUCACIÓN               ***
******************************************************
	*********
	*aedu_ci* // años de educacion aprobados
	*********
	gen aedu_ci=yrschool
	replace aedu_ci=. if aedu_ci==98
	replace aedu_ci=. if aedu_ci==99
	replace aedu_ci=. if yrschool>=90 & yrschool<100 

	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen byte eduno_ci=0
	replace eduno_ci=1 if aedu_ci==0
	replace eduno_ci=. if aedu_ci==.

	***********
	*edupre_ci* // preescolar
	***********
	gen edupre_ci=(educsv>=110 & educsv<=114) // pre-school
	replace edupre_ci=. if educsv==0 | educsv==999 // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen byte edupi_ci=0
	replace edupi_ci=1 if aedu_ci>0 & aedu_ci<6
	replace edupi_ci=1 if yrschool==91 // Some primary 
	replace edupi_ci=. if aedu_ci==.

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen byte edupc_ci=0
	replace edupc_ci=1 if aedu_ci==6
	replace edupc_ci=. if aedu_ci==.

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen byte edusi_ci=0
	replace edusi_ci=1 if aedu_ci>6 & aedu_ci<11
	replace edusi_ci=1 if yrschool==92 | yrschool==93 // Some techinical after primary and some secondary
	replace edusi_ci=. if aedu_ci==.
	replace edusi_ci=. if yrschool==90| yrschool==98| yrschool==99 // Se asignan como missing NIU and missing (no asi las otras)
	
	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==11) // 11
	replace edusc_ci=. if aedu_ci==.

	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
	replace edus1i_ci=. if aedu_ci==.

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if aedu_ci==.
	
	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<11)
	replace edus2i_ci=. if aedu_ci==.

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==11)
	replace edus2c_ci=1 if yrschool==94 // Some tertiary
	replace edus2c_ci=. if aedu_ci==.
	
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
 

