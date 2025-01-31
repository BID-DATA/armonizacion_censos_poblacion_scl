* (Versión Stata 12)
clear
set more off
*________________________________________________________________________________________________________________*

 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: ${censusFolder}
 * Se tiene acceso al servidor únicamente al interior del BID.
 *________________________________________________________________________________________________________________*

/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Chile
Año: 2017
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************
global PAIS CHL   				 //cambiar
global ANIO 2017   				 //cambiar

*****************************************************
******* Variables específicas del censo    **********
*****************************************************

include "../Base/base.do"


     ****************
     *** region_c ***
     ****************
   * Clasificación válida para 2017.
   gen region_c=.   
   replace region_c=1 if geo1_cl==152011			    /*Iquique*/
   replace region_c=2 if geo1_cl==152014			    /*Tamarugal*/
   replace region_c=3 if geo1_cl==152021			    /*Antofagasta*/
   replace region_c=4 if geo1_cl==152022			    /*El Loa*/
   replace region_c=5 if geo1_cl==152023		     	/*Tocopilla*/
   replace region_c=6 if geo1_cl==152031			    /*Copiapo*/
   replace region_c=7 if geo1_cl==152032			    /*Chanaral*/
   replace region_c=8 if geo1_cl==152033			    /*Huasco*/
   replace region_c=9 if geo1_cl==152041			    /*Elqui*/
   replace region_c=10 if geo1_cl==152042				/*Choapa*/
   replace region_c=11 if geo1_cl==152043				/*Limari*/
   replace region_c=12 if geo1_cl==152051				/*Valparaíso, Isla de Pascua*/
   replace region_c=13 if geo1_cl==152053				/*Los Andes*/
   replace region_c=14 if geo1_cl==152054				/*Petorca*/
   replace region_c=15 if geo1_cl==152055				/*Quillota*/
   replace region_c=16 if geo1_cl==152056				/*San Antonio*/
   replace region_c=17 if geo1_cl==152057				/*San Felipe de Aconcagua*/
   replace region_c=18 if geo1_cl==152058				/*Marga Marga*/   
   replace region_c=19 if geo1_cl==152061				/*Cachapoal*/
   replace region_c=20 if geo1_cl==152062				/*Cardenal Caro*/
   replace region_c=21 if geo1_cl==152063				/*Colchagua*/
   replace region_c=22 if geo1_cl==152071				/*Talca*/
   replace region_c=23 if geo1_cl==152072				/*Cauquenes*/
   replace region_c=24 if geo1_cl==152073				/*Curico*/
   replace region_c=25 if geo1_cl==152074				/*Linares*/
   replace region_c=26 if geo1_cl==152081				/*Concepcion*/
   replace region_c=27 if geo1_cl==152082				/*Arauco*/
   replace region_c=28 if geo1_cl==152083				/*Bio Bio*/
   replace region_c=29 if geo1_cl==152091				/*Cautin*/
   replace region_c=30 if geo1_cl==152092				/*Malleco*/
   replace region_c=31 if geo1_cl==152101				/*Llanquihue*/
   replace region_c=32 if geo1_cl==152102				/*Chiloe*/
   replace region_c=33 if geo1_cl==152103				/*Osorno*/
   replace region_c=34 if geo1_cl==152111				/*Coihaique*/
   replace region_c=35 if geo1_cl==152112				/*Aisen, General Carrera, Palena*/
   replace region_c=36 if geo1_cl==152121				/*Magallanes, Tierra del Fuego, Antartica Chilena*/
   replace region_c=37 if geo1_cl==152124				/*Ultima Esperanza*/
   replace region_c=38 if geo1_cl==152131				/*Santiago*/
   replace region_c=39 if geo1_cl==152132				/*Cordillera*/
   replace region_c=40 if geo1_cl==152133				/*Chacabuco*/
   replace region_c=41 if geo1_cl==152134				/*Maipo*/
   replace region_c=42 if geo1_cl==152135				/*Melipilla*/
   replace region_c=43 if geo1_cl==152136				/*Talagante*/
   replace region_c=44 if geo1_cl==152141				/*Valdivia*/
   replace region_c=45 if geo1_cl==152142				/*Ranco*/
   replace region_c=46 if geo1_cl==152151				/*Arica, Parinacota*/
   replace region_c=47 if geo1_cl==152161				/*Diguillin*/
   replace region_c=48 if geo1_cl==152162				/*Itata*/
   replace region_c=49 if geo1_cl==152163				/*Punilla*/
   


	  label define region_c 1"Iquique" 2"Tamarugal" 3"Antofagasta" 4"El Loa" 5"Tocopilla" 6"Copiapo" 7"Chanaral" 8"Huasco" 9"Elqui" 10"Choapa" 11"Limari" 12"Valparaíso, Isla de Pascua" 13"Los Andes" 14"Petorca" 15"Quillota" 16"San Antonio" 17"San Felipe de Aconcagua" 18"Marga Marga" 19"Cachapoal" 20"Cardenal Caro" 21"Colchagua" 22"Talca" 23"Cauquenes" 24"Curico" 25"Linares" 26"Concepcion" 27"Arauco" 28 "Bio Bio" 29"Cautin" 30"Malleco" 31"Llanquihue" 32"Chiloe" 33"Osorno" 34"Coihaique" 35"Aisen, General Carrera, Palena" 36"Magallanes, Tierra del Fuego, Antartica Chilena" 37"Ultima Esperanza" 38"Santiago" 39"Cordillera" 40"Chacabuco" 41"Maipo" 42"Melipilla" 43"Talagante" 44"Valdivia" 45"Ranco" 46"Arica, Parinacota" 47"Diguillin" 48"Itata" 49"Punilla"  

      label value region_c region_c
      label var region_c "division politico-administrativa, provincia" 

* Enlace regiones: https://international.ipums.org/international-action/variables/GEO1_CL#codes_section


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
	
	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=(educcl==100) // pre-school
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
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<12) // 7 a 11 anos de educación
	replace edusi_ci=. if aedu_ci==. // NIU & missing
	replace edusi_ci = 1 if yrschool == 92 | yrschool ==93 //some technical after primary or some secondary

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=(aedu_ci==12) // 12 anos de educación
	replace edusc_ci=. if aedu_ci==. // NIU & missing
	
	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=(aedu_ci>=13 & aedu_ci<=16 & edattain != 4) // 14 a 16 anos de educación
	replace eduui_ci=. if aedu_ci ==. // NIU & missing
	replace eduui_ci = 1 if yrschool == 94 // some terciary

	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=.
	replace eduuc_ci=1 if aedu_ci>=17
	replace eduuc_ci=0 if edattain == 1 | edattain == 2 | edattain ==3  
	// cualquier otro nivel de educación
	replace eduuc_ci=. if aedu_ci==. // NIU & missing

	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<8)
	replace edus1i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=(aedu_ci==8)
	replace edus1c_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=(aedu_ci>8 & aedu_ci<12)
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
	replace afroind_ci=1  if indig==1 
	replace afroind_ci=3 if indig==2


	***************
	**afroind_ch***
	***************
	gen afroind_jefe= afroind_ci if relate==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

	drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
	gen afroind_ano_c=2002

	********************
	*** discapacid
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
 

