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
País: VENEZUELA
Año: 2001
Autores: Carolina Rivas
Última versión: Nov, 2021

							SCL/LMK - IADB
****************************************************************************/

global PAIS VEN 				 //cambiar
global ANIO 2001   				 //cambiar

*****************************************************
******* Variables específicas del censo    **********
*****************************************************


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
	replace region_c=1 if geo1_ve2001==1	/*Federal District */
	replace region_c=2 if geo1_ve2001==2	/*San Amazonas*/
	replace region_c=3 if geo1_ve2001==3	/*Anzoátegui*/
	replace region_c=4 if geo1_ve2001==4	/*Apure*/
	replace region_c=5 if geo1_ve2001==5	/*Aragua*/
	replace region_c=6 if geo1_ve2001==6	/*Barinas*/
	replace region_c=7 if geo1_ve2001==7	/*Bolívar*/
	replace region_c=8 if geo1_ve2001==8	/*Carabobo*/
	replace region_c=9 if geo1_ve2001==9	/*Cojedes*/
	replace region_c=10 if geo1_ve2001==10	/*Delta Amacuro*/
	replace region_c=11 if geo1_ve2001==11	/*Falcón*/
	replace region_c=12 if geo1_ve2001==12	/*Guárico*/
	replace region_c=13 if geo1_ve2001==13	/*Lara*/
	replace region_c=14 if geo1_ve2001==14	/*Mérida*/
	replace region_c=15 if geo1_ve2001==15	/*Miranda*/
	replace region_c=16 if geo1_ve2001==16	/*Monagas*/
	replace region_c=17 if geo1_ve2001==17	/*Nueva Esparta*/
	replace region_c=18 if geo1_ve2001==18	/*Portuguesa*/
	replace region_c=19 if geo1_ve2001==19	/*Sucre*/
	replace region_c=20 if geo1_ve2001==20	/*Táchira*/
	replace region_c=21 if geo1_ve2001==21	/*Trujillo*/
	replace region_c=22 if geo1_ve2001==22	/*Yaracuy*/
	replace region_c=23 if geo1_ve2001==23	/*Zulia*/
	replace region_c=24 if geo1_ve2001==24	/*Vargas*/
		

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
	
	***********
	*edupre_ci* // preescolar
	***********
	gen edupre_ci=(educve==101 | educve == 102 | educve == 103 |educve == 104) // pre-school
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
 