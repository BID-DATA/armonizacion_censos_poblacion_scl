
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
País:  República Dominicana
Año: 2010
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************
global PAIS DOM  				 //cambiar
global ANIO 2010   				 //cambiar

*****************************************************
******* Variables específicas del censo    **********
*****************************************************

include "../Base/base.do"

     ****************
     *** region_c ***
     ****************

   gen region_c=.   
   replace region_c=1 if geo1_do==214001			/*Distrito Nacional, Santo Domingo*/
   replace region_c=2 if geo1_do==214002			/*Azua*/
   replace region_c=3 if geo1_do==214003			/*Baoruco, Barahona, Independencia*/
   replace region_c=4 if geo1_do==214005			/*Dajabón*/
   replace region_c=5 if geo1_do==214006		    /*Duarte*/
   replace region_c=6 if geo1_do==214007			/*Elías Piña*/
   replace region_c=7 if geo1_do==214008			/*El Seibo, Hato Mayor*/
   replace region_c=8 if geo1_do==214009			/*Espaillat*/
   replace region_c=9 if geo1_do==214011			/*La Altagracia, La Romana*/
   replace region_c=10 if geo1_do==214013			/*Monseñor Nouel, La Vega*/
   replace region_c=11 if geo1_do==214014			/*María Trinidad Sánchez*/
   replace region_c=12 if geo1_do==214015			/*Monte Cristi*/
   replace region_c=13 if geo1_do==214016			/*Pedernales*/
   replace region_c=14 if geo1_do==214017			/*San José de Ocoa, Peravia*/
   replace region_c=15 if geo1_do==214018			/*Puerto Plata, Santiago*/
   replace region_c=16 if geo1_do==214019			/*Hermanas Mirabal*/
   replace region_c=17 if geo1_do==214020			/*Samaná*/
   replace region_c=18 if geo1_do==214021			/*San Cristóbal, Monte Plata*/
   replace region_c=19 if geo1_do==214022			/*San Juan*/
   replace region_c=20 if geo1_do==214023			/*San Pedro De Macorís*/
   replace region_c=21 if geo1_do==214024			/*Sánchez Ramírez*/
   replace region_c=22 if geo1_do==214026			/*Santiago Rodríguez*/
   replace region_c=23 if geo1_do==214027			/*Valverde*/
   replace region_c=24 if geo1_do==214088			/*Lake Enriquilla*/


	  label define region_c 1"Distrito Nacional, Santo Domingo" 2"Azua" 3"Baoruco, Barahona, Independencia" 4"Dajabón" 5"Duarte" 6"Elías Piña" 7"El Seibo, Hato Mayor" 8"Espaillat" 9"La Altagracia, La Romana" 10"Monseñor Nouel, La Vega" 11"María Trinidad Sánchez" 12"Monte Cristi" 13"Pedernales" 14"San José de Ocoa, Peravia" 15"Puerto Plata, Santiago" 16"Hermanas Mirabal" 17"Samaná" 18"San Cristóbal, Monte Plata" 19"San Juan" 20"San Pedro De Macorís" 21"Sánchez Ramírez" 22"Santiago Rodríguez" 23"Valverde" 24"Lake Enriquilla"

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
	replace eduno_ci=. if edattaind==0 | edattaind==999 // NIU & missing
	
	***********
	*edupre_ci* // preescolar
	***********
	gen edupre_ci=(educdo == 200) // pre-school
	replace edupre_ci=. if educdo==0 | educdo==999 // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=(aedu_ci>0 & aedu_ci<6) //
	replace edupi_ci=. if educdo==0 | educdo==999 // NIU & missing
	replace edupi_ci = 1 if yrschool == 91 // some primary

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=(aedu_ci==6)
	replace edupc_ci=. if edattain==0 | edattain==9 // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<=11) // 7 a 11 anos de educación
	replace edusi_ci=. if edattain==0 |edattain==9 // NIU & missing
	replace edusi_ci = 1 if yrschool == 92 | yrschool ==93 //some technical after primary or some secondary

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==12) // 7 a 11 anos de educación
	replace edusc_ci=. if edattain==0 |edattain==9 // NIU & missing
	
	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<8)
	replace edus1i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==8)
	replace edus1c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>8 & aedu_ci<12)
	replace edus2i_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=(aedu_ci==12)
	replace edus2c_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

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

		***************
		***afroind_ch***
		***************
	gen afroind_jefe=.
	gen afroind_ch  =.

	drop afroind_jefe 

		*******************
		***afroind_ano_c***
		*******************
	gen afroind_ano_c=.

************************
*** Discapacidad (WG)***
************************
/* Identificación de si una persona reporta por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */
gen dis_ci = 0
recode dis_ci nonmiss=. if inlist(9,do2010a_blind,do2010a_deaf,do2010a_dismob,do2010a_disconc) //
recode dis_ci nonmiss=. if do2010a_blind>=. & do2010a_deaf>=. & do2010a_dismob>=. & do2010a_disconc>=. //
replace dis_ci=1 if do2010a_blind ==1 | do2010a_deaf==1 | do2010a_dismob==1 | do2010a_disconc==1 


/*Identificación de si un hogar tiene uno o más miembros que reportan por lo menos alguna dificultad en una o más de las preguntas del Washington Group Questionnaire */		

egen dis_ch  = sum(dis_ci), by(idh_ch) 
replace dis_ch=1 if dis_ch>=1 & dis_ch!=.

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
 