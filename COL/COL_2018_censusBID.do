* (Versión Stata 12)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: COLOMBIA
Año: 2018
Autores: Juan Perdomo
Última versión: 30SET2022
División: SCL/MIG - IADB
*******************************************************************************

INSTRUCCIONES:

	(1) Guarda este script con la estructura Pais_ANIO_censusBID.do.
		Por ejemplo Ecuador 2017 será: ECU_2017_censusBID.do
	
	(2) Sigue la estructura y estilo de este script, pero ten en cuenta que
		el contenido es referencial y que debes adaptarlo al país que te toque 
		armonizar. 	Cada vez que encuentres "..." debes completar el código con 
		la información del país que te toque. Existen variables en las que no 
		debes hacer nada, pues se crean a partir de otras variables, como por 
		ejemplo jefe_ci.
		
	(3) Cambia la información que está en la parte superior. 
		- En País pon el nombre completo, por ejemplo Panamá. 
		- En año coloca un número entero de 4 dígitos, por ejemplo 2024. 
		- En autores pon tu 1er nombre y 1er apellido, por ejemplo Juan Casas.
		- En última versión coloca la fecha en que la termines el script, por
		  ejemplo 22ABR2024
		- En división colola las siglas de tu división en el IADB, por ejemplo 
		  SCL/GDI - IADB
		  
	(4) En la sección I, cambia la ruta de trabajo. Dentro de la ruta 
		selecionada, crea las carpetas raw y clean. Adentro	de esta carpetas, 
		crea la subcarpeta del país que te toque. Recuerda que debes 
		utilizar el código iso-alpha3 del país para crear la subcarpeta
		(por ejemplo, Ecuador es ECU).
		
			censusFolder>raw>ECU
			censusFolder>clean>ECU

    (5) Si la base que vas a correr es muy pesada. De forma temporal
		puedes sacar una muestra con el comando sample en la sección I para que
		sea más fácil que verifiques el trabajo que vas realizando. 
		Cuando ya hayas creado todas las variables, desactiva el sample y 
		corre tu código otra vez para la base completa. Este paso es opcional.
		
	(6) Todas las variables de las secciones II y III deben ser creadas
		sin exepción. En caso no haya información, créala con un missing value (.)
		
	(7) Revisa que idp_ci no tenga duplicados (control de calidad)
	
	(8) Solo colocar las etiquetas o labels en este script cuando se indique.
		Se pondrá las etiquetas a la mayoría de variables en la sección VI a 
		través del script labels.do
		
    (9) En la sección IV, revisa que hayas creado todas las variables (control de
		calidad)
		
   (10) En la sección V, borra todas las variables excepto las variables 
		creadas en las secciones II y III y las variables de ID originales. 
		Corre el código y verificalo. Debes tener 108 variables de las secciones 
		II y III más las variables de ID originales (control de calidad).
		
   (11) En la sección VII, guarda la base con el formato 
		ISOalpha3Pais_ANIO_censusBID.dta. Por ejemplo, Ecuador 2017 será: 
		ECU_2017_censusBID.dta
	
==============================================================================*/


/****************************************************************************
   I. Define las rutas de trabajo y abre la base de datos raw
*****************************************************************************/

clear
set more off

global ruta = "${censusFolder}"  //cambiar ruta seleccionada 
global PAIS COL    				 //cambiar
global ANIO 2018   				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                  
capture log close
log using `"$log_file"', replace  //agregar ,replace si ya está creado el log_file en tu carpeta

use "$base_in", clear

rename *, lower

*sample 10   		// significa muestra de 20% de la base. Activar si se necesita.     

/****************************************************************************
   II. Armonización de variables 
*****************************************************************************/

*************************************
*** Identificación (12 variables) ***
*************************************

	************
	* Region_BID *
	************
	gen byte region_BID_c=.
	replace region_BID_c=3 
	label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
	label value region_BID_c region_BID_c


	***************
	***region_c ***
	***************
	destring u_dpto, replace
	gen byte region_c=u_dpto
	label define region_c       /// 
		5  "Antioquia"	        ///
		8  "Atlantico"	        ///
		11 "Bogota, D.C"	    ///
		13 "Bolivar" 	        ///
		15 "Boyace"	            ///
		17 "Caldas"	            ///
		18 "Caqueta"	        ///
		19 "Cauca"	            ///
		20 "Cesar"	            ///
		23 "Cordoba"	        ///
		25 "Cundinamarca"       ///
		27 "Choco"	            ///
		41 "Huila"	            ///
		44 "La Guajira"	        ///
		47 "Magdalena"	        ///
		50 "Meta"	            ///
		52 "Narino"	            ///
		54 "Norte de Santander"	///
		63 "Quindio"	        ///
		66 "Risaralda"	        ///
		68 "Santander"	        ///
		70 "Sucre"	            ///
		73 "Tolima"	            ///
		76 "Valle del Cauca"	///
		81 "Arauca"	            ///
		85 "Casanare"	        ///
		88 "Archipiélago De San Andrés Y Providencia"	        ///
		86 "Putumayo"	        ///
		91 "Amazonas"	        ///
		94 "Guainía"	        ///
		95 "Guaviare"	        ///
		97 "Vaupés" 	        ///
		99 "Vichada"
	label value region_c region_c

	***************
	**** geolev1 ****
	***************
	gen long geolev1=.
	replace geolev1 = 170005 if u_dpto==5
	replace geolev1 = 170008 if u_dpto==8
	replace geolev1 = 170011 if inlist(u_dpto,11,25)
	replace geolev1 = 170013 if inlist(u_dpto,13,70)
	replace geolev1 = 170015 if inlist(u_dpto,15,85)
	replace geolev1 = 170018 if u_dpto==18
	replace geolev1 = 170019 if u_dpto==19
	replace geolev1 = 170023 if u_dpto==23
	replace geolev1 = 170027 if u_dpto==27
	replace geolev1 = 170041 if u_dpto==41
	replace geolev1 = 170044 if u_dpto==44
	replace geolev1 = 170050 if u_dpto==50
	replace geolev1 = 170052 if u_dpto==52
	replace geolev1 = 170054 if inlist(u_dpto,20,47)
	replace geolev1 = 170066 if inlist(u_dpto,17,63,66)
	replace geolev1 = 170068 if inlist(u_dpto,68,54)
	replace geolev1 = 170073 if u_dpto==73
	replace geolev1 = 170076 if u_dpto==76
	replace geolev1 = 170081 if u_dpto==81
	replace geolev1 = 170086 if u_dpto==86
	replace geolev1 = 170088 if u_dpto==88
	replace geolev1 = 170095 if inlist(u_dpto,91,95,97,99,94)
	label define geolev1 170005 "Antioquia" 170008 "Atlántico" 170011 "Bogotá D.C., Cundinamarca" 170013 "Bolívar, Sucre" 170015 "Boyacá, Casanare" 170018 "Caquetá" 170019 "Cauca" 170023 "Córdoba" 170027 "Chocó" 170041 "Huila" 170044 "La Guajira" 170050 "Meta" 170052 "Nariño" 170054 "Cesar, Norte De Santander, Magdalena" 170066 "Caldas, Quindío, Risaralda" 170068 "Santander" 170073 "Tolima" 170076 "Valle Del Cauca" 170081 "Arauca" 170086 "Putumayo" 170088 "Archipiélago De San Andrés Y Providencia" 170095 "Amazonas, Guaviare, Vaupés, Vichada, Guainía"
	label value geolev1 geolev1

	************
	****pais****
	************
	g str3 pais_c = "COL"

	**********
	***anio***
	**********
	g int anio_c = 2018

	***************
	****idh_ch*****
	***************
	sort u_dpto u_mpio ua_clase cod_encuestas u_vivienda p_nrohog
	egen idh_ch = group(u_dpto u_mpio ua_clase cod_encuestas u_vivienda p_nrohog)
	cap tostring idh_ch, replace

	**************
	****idp_ci****
	**************
	sort idh_ch p_nro_per
	egen idp_ci = group(idh_ch p_nro_per)
	cap tostring idp_ci, replace

	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
	gen byte factor_ci=.
		
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
	gen byte factor_ch=.

	*******************************************
	*Estrato(estrato_ci)*
	*******************************************
	gen byte estrato_ci=.

	*****
	*upm*
	*****
	gen byte upm =.
	
	**********
	***zona***
	**********
	destring ua_clase, replace
	g byte zona_c = (ua_clase == 1)
	replace zona_c = . if ua_clase == .
	la de zona_c 1 "Urbana" 0 "Rural"
	la val zona_c zona_c


************************************
*** 2. Demografía (18 variables) ***
************************************

	**********
	***sexo***
	**********
	g byte sexo_ci = p_sexo
	replace sexo_ci = . if p_sexo == .
	la define sexo_ci 1 "Hombre" 2 "Mujer"
	la val sexo_ci sexo_ci

	**********
	***edad***
	**********
	g int edad_ci = .
	g edad_grupo_ci = p_edadr
	la var edad_grupo_ci "Edad del individuo (años)"
	la de edad_grupo_ci	1 "de 00 A 04 Años" 	///
						2 "de 05 A 09 Años" 	///
						3 "de 10 A 14 Años"	    ///
						4 "de 15 A 19 Años" 	///
						5 "de 20 A 24 Años"		///
						6 "de 25 A 29 Años"		///
						7 "de 30 A 34 Años"		///
						8 "de 35 A 39 Años"		///
						9 "de 40 A 44 Años"		///
						10 "de 45 A 49 Años"	///
						11 "de 50 A 54 Años"	///
						12 "de 55 A 59 Años"	///
						13 "de 60 A 64 Años"	///
						14 "de 65 A 69 Años"	///
						15 "de 70 A 74 Años"	///
						16 "de 75 A 79 Años"	///
						17 "de 80 A 84 Años"	///
						18 "de 85 A 89 Años"	///
						19 "de 90 A 94 Años"	///
						20 "de 95 A 99 Años"	///
						21 "de 100 y más Años"
	la val edad_ci edad_ci
	
	*****************
	***relacion_ci***
	*****************
	g 	byte relacion_ci = 1 if p_parentescor == 1
	replace relacion_ci = 2 if p_parentescor == 2
	replace relacion_ci = 3 if p_parentescor == 3
	replace relacion_ci = 4 if p_parentescor == 4
	replace relacion_ci = 5 if p_parentescor == 5
	replace relacion_ci = . if p_parentescor == .
	la de relacion_ci 	1 "Jefe/a" 				///
						2 "Esposo/a" 			///
						3 "Hijo/a" 				///
						4 "Otros parientes" 	///
						5 "Otros no parientes"
	la val relacion_ci relacion_ci

	*****************
	****civil_ci*****
	*****************
	g 	byte 	civil_ci = .
	replace civil_ci = 1 if p_est_civil == 7
	replace civil_ci = 2 if p_est_civil == 1 | p_est_civil == 2
	replace civil_ci = 3 if p_est_civil == 3 | p_est_civil == 4 | p_est_civil == 5 
	replace civil_ci = 4 if p_est_civil==6
	replace civil_ci = . if p_est_civil==9 | p_est_civil==.
	la var civil_ci "Estado civil"
	la de civil_ci 	1 "Soltero" 				///
					2 "Unión formal o informal" ///
					3 "Divorciado o separado" 	///
					4 "Viudo"
	la val civil_ci civil_ci

	**************
	***jefe_ci***
	*************
	g byte jefe_ci = relacion_ci == 1

	******************
	***nconyuges_ch***
	******************
	bys idh_ch: egen byte nconyuges_ch = sum(relacion_ci == 2)

	***************
	***nhijos_ch***
	***************
	bys idh_ch: egen byte nhijos_ch = sum(relacion_ci == 3)

	******************
	***notropari_ch***
	******************
	bys idh_ch: egen byte notropari_ch = sum(relacion_ci == 4)

	********************
	***notronopari_ch***
	********************
	bys idh_ch: egen byte notronopari_ch = sum(relacion_ci == 5)

	****************
	***nempdom_ch***
	****************
	bys idh_ch: egen byte nempdom_ch = sum(relacion_ci == 6)

	****************
	***miembros_ci***
	****************
	gen byte miembros_ci = (relacion_ci <= 5)
	
	*****************
	***clasehog_ch***
	*****************
	g byte clasehog_ch = 0
	**** unipersonal
	replace clasehog_ch = 1 if nhijos_ch == 0 & nconyuges_ch == 0 & notropari_ch == 0 & notronopari_ch == 0
	**** nuclear (child with or without spouse but without other relatives)
	replace clasehog_ch = 2 if (nhijos_ch > 0 | nconyuges_ch > 0) & (notropari_ch == 0 & notronopari_ch == 0)
	**** ampliado
	replace clasehog_ch = 3 if notropari_ch > 0 & notronopari_ch == 0
	**** compuesto (some relatives plus non relative)
	replace clasehog_ch = 4 if ((nconyuges_ch > 0 | nhijos_ch > 0 | notropari_ch > 0) & (notronopari_ch > 0))
	**** corresidente
	replace clasehog_ch = 5 if nhijos_ch == 0 & nconyuges_ch == 0 & notropari_ch == 0 & notronopari_ch > 0
		
	la variable clasehog_ch "Tipo de hogar"
	la de clasehog_ch 	1 "Unipersonal" 	///
							2 "Nuclear" 		///
							3 "Ampliado" 		///
							4 "Compuesto" 		///
							5 "Corresidente"
	la val clasehog_ch clasehog_ch

	******************
	***nmiembros_ch***
	******************
	egen byte nmiembros_ch = sum(relacion_ci >= 1 & relacion_ci <= 5), by (idh_ch)
		
	*****************
	***nmayor21_ch***
	*****************
	gen byte nmayor21_ch= .

	*****************
	***nmenor21_ch***
	*****************
	gen byte nmenor21_ch= .

	*****************
	***nmayor65_ch***
	*****************
	gen byte nmayor65_ch= .

	****************
	***nmenor6_ch***
	****************
	gen byte nmenor6_ch= .

	****************
	***nmenor1_ch***
	****************
	gen byte nmenor1_ch= .

************************************
*** 3. Diversidad (11 variables) ***
************************************		

	*********
	*afro_ci*
	*********
	gen byte afro_ci = .
	
	*********
	*indi_ci*
	*********	
	gen byte ind_ci =.
	
	**************
	*noafroind_ci*
	**************
	gen byte noafroind_ci =.
	
	***************
	***afroind_ci***
	***************
	**Pregunta: De acuerdo con su cultura, pueblo o rasgos físicos, … es o se reconoce como:(P6080) (1- Indigena 2- Gitano - Rom 3- Raizal del archipiélago de San Andrés y providencia 4- Palenquero de San basilio o descendiente 5- Negro(a), mulato(a), Afrocolombiano(a) o Afrodescendiente 6- Ninguno de los anteriores (mestizo, blanco, etc)) 
	gen byte afroind_ci=. 
	replace afroind_ci=1 if pa1_grp_etnic == 1 
	replace afroind_ci=2 if pa1_grp_etnic == 3 | pa1_grp_etnic == 4 | pa1_grp_etnic == 5
	replace afroind_ci=3 if pa1_grp_etnic == 2 | pa1_grp_etnic == 6
	replace afroind_ci=. if pa1_grp_etnic ==.
	label var afroind_ci "Raza o etnia del individuo"

	*********
	*afro_ch*
	*********
	gen byte afro_ch = .
	
	********
	*ind_ch*
	********
	gen byte ind_ch = .

	**************
	*noafroind_ch*
	**************
	gen byte noafroind_ch = .
	
	***************
	***afroind_ch***
	***************
	gen afroind_jefe= afroind_ci if relacion_ci==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 
	label var afroind_ch "Raza/etnia del hogar en base a raza/etnia del jefe de hogar"
	drop afroind_jefe

	*******************
	***dis_ci***
	*******************
	gen byte dis_ci=. 
	label var dis_ci "Personas con discapacidad"

	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	
	************
	***dis_ch***
	************
	gen byte dis_ch=. 
	lab var dis_ch "Hogares con miembros con discapacidad"

**********************************
*** 4. Migración (3 variables) ***
**********************************	

    *******************
    ****migrante_ci****
    *******************
	gen byte migrante_ci = 0
	replace migrante_ci=1 if pa_lug_nac==3
	replace migrante_ci=. if pa_lug_nac==. | pa_lug_nac==9
	
	*******************
    **migrantiguo5_ci***
    *******************
	gen byte migrantiguo5_ci =0
	replace migrantiguo5_ci=1 if pa_lug_nac==3 | pa_vivia_5anos==4
		
	**********************
	****** miglac_ci *****
	**********************
	gen byte miglac_ci = .

***********************************
*** 5. Educación (13 variables) ***
***********************************

	*************
	***aedu_ci***
	*************
	gen byte aedu_ci =.

	**************
	***eduno_ci***
	**************
	gen byte eduno_ci=(p_nivel_anosr==10) // never attended 
	replace eduno_ci=. if p_nivel_anosr==99 // NIU & missing

	**************
	***edupi_ci***
	**************
	gen byte edupi_ci=(p_nivel_anosr==1) //  pre-school
	replace edupi_ci=. if p_nivel_anosr==99 // NIU & missing

	**************
	***edupc_ci***
	**************
	gen byte edupc_ci=(p_nivel_anosr==2)
	replace edupc_ci=. if p_nivel_anosr==99 // NIU & missing

	**************
	***edusi_ci***
	**************
	gen byte edusi_ci=(p_nivel_anosr==3)
	replace edupc_ci=. if p_nivel_anosr==99 // NIU & missing

	**************
	***edusc_ci***
	**************
	gen byte edusc_ci=(p_nivel_anosr==4 |p_nivel_anosr==5|p_nivel_anosr==6) 
	replace edusc_ci=. if p_nivel_anosr==99 // NIU & missing

	***************
	***edus1i_ci***
	***************
	gen byte edus1i_ci=.

	***************
	***edus1c_ci***
	***************
	gen byte edus1c_ci=(p_nivel_anosr==3)
	replace edus1c_ci=. if aedu_ci==99 // missing a los NIU & missing

	***************
	***edus2i_ci***
	***************
	gen byte edus2i_ci=.

	***************
	***edus2c_ci***
	***************
	gen byte edus2c_ci=(p_nivel_anosr==4 |p_nivel_anosr==5 |p_nivel_anosr==6)
	replace edus2c_ci=. if p_nivel_anosr==99 // missing a los NIU & missing

	***************
	***edupre_ci***
	***************
	gen byte edupre_ci=.

	***************
	***asiste_ci***
	***************
	gen byte asiste_ci=.
	replace asiste_ci=1 if pa_asistencia==1
	replace asiste_ci=0 if pa_asistencia==2
	replace asiste_ci=. if pa_asistencia==.|pa_asistencia==9 |pa_asistencia==4
	*label variable asiste_ci "Asiste actualmente a la escuela"

	**************
	***literacy***
	**************
	gen byte literacy=(p_alfabeta==1)
	replace literacy=. if p_alfabeta==.|p_alfabeta==9

****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

    *******************
    ****condocup_ci****
    *******************
    gen byte condocup_ci=.
	
	************
     ***emp_ci***
     ************
    gen byte emp_ci=(inrange(p_trabajo,1,3))
	
	****************
     ***desemp_ci***
     ****************	
	gen byte desemp_ci=(p_trabajo==4)
	
	*************
    ***pea_ci***
    *************
    gen byte pea_ci=(inrange(p_trabajo,1,4))

	*************
	**rama_ci****
	*************
	gen byte rama_ci=.
	
	*********************
    ****categopri_ci****
    *********************
	 gen byte categopri_ci=.
	  
	*****************
    ***spublico_ci***
    *****************
    gen byte spublico_ci=.
	
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************		
	
    ********
	*luz_ch*
	********
	gen byte luz_ch= 1 if va_ee==1
	replace luz_ch= 0 if va_ee==2
	replace luz_ch=. if va_ee==.
	
	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
	replace piso_ch = 0 if v_mat_piso == 6
	replace piso_ch = 1 if v_mat_piso == 1 | v_mat_piso == 2 | v_mat_piso == 3
	replace piso_ch = 2 if  v_mat_piso == 4 | v_mat_piso == 5
	replace piso_ch = . if v_mat_piso==9 | v_mat_piso==.
	label variable piso_ch "Materiales de construcción del piso"
	label def piso_ch 0"Sin piso o sin terminar (tierra)" 1"Materiales no permanentes" 2 "Materiales permanentes"
	label val piso_ch piso_ch
	
	**********
	*pared_ch*
	**********
	gen byte pared_ch = .
	replace pared_ch = 0 if v_mat_pared == 9
	replace pared_ch = 1 if inrange(v_mat_pared, 4, 8)
	replace pared_ch = 2 if inrange(v_mat_pared, 1, 3)
	label variable pared_ch "Materiales de construcción de las paredes del hogar"
	label def pared_ch 0"No tiene paredes" 1"Materiales no permanentes" 2 "Materiales permanentes"
	label val pared_ch pared_ch
	
	**********
	*techo_ch*
	**********
	gen byte techo_ch=.
	
	**********
	*resid_ch*
	**********
	gen byte resid_ch=. 
	
	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=h_nro_dormit
	
	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=h_nro_cuartos
	
	***********
	*cocina_ch*
	***********
	gen byte cocina_ch=.
	replace cocina_ch=1 if h_donde_prepalim ==1 
	replace cocina_ch=0 if h_donde_prepalim==2 | h_donde_prepalim==3 | h_donde_prepalim==4  | h_donde_prepalim==5 | h_donde_prepalim==6
	
	***********
	*telef_ch*
	***********
	*sin dato
	gen byte telef_ch=.
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=.
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	
	********
	*compu_ch*
	********
	gen byte compu_ch=.
	
	*************
	*internet_ch*
	************* 
	gen byte internet_ch=vf_internet
	replace internet_ch=0 if vf_internet==2
	
	********
	*cel_ch*
	********
	*sin dato
	gen byte cel_ch=.
	
	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch=.
	
***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************		

	*****************
	*aguaentubada_ch*
	*****************
	gen byte aguaentubada_ch=1 if vb_acu==1
	replace aguaentubada_ch=0 if vb_acu==2
	replace aguaentubada_ch=. if vb_acu==.
	
	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch = 1 if inlist(vb_acu, 1)
	replace aguared_ch = 0 if inlist(vb_acu,2)
	
    ***************
	*aguafuente_ch*
	***************
	gen byte aguafuente_ch=.
	replace aguafuente_ch = 1 if inlist(h_agua_cocin, 1,2,3)
	replace aguafuente_ch = 2 if inlist(h_agua_cocin, 8)
	replace aguafuente_ch = 3 if inlist(h_agua_cocin, 11)
	replace aguafuente_ch = 4 if inlist(h_agua_cocin, 4)
	replace aguafuente_ch = 5 if inlist(h_agua_cocin, 6)
	replace aguafuente_ch = 6 if inlist(h_agua_cocin, 9,10)
	replace aguafuente_ch = 8 if inlist(h_agua_cocin, 7)
	replace aguafuente_ch = 10 if inlist(h_agua_cocin, 5)
	
	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch = 0 
	
	**************
	*aguadisp1_ch*
	**************
	gen byte aguadisp1_ch =9 
	
	**************
	*aguadisp2_ch*
	**************
	gen byte aguadisp2_ch =9	
	
	*************
	*aguamide_ch*
	*************
	gen byte aguamide_ch = 9

	*********
	*bano_ch*
	*********
	gen byte bano_ch = . 
	replace bano_ch = 0 if v_tipo_sersa == 6 
	replace bano_ch = 1 if v_tipo_sersa == 1 
	replace bano_ch = 2 if v_tipo_sersa == 2
	replace bano_ch = 4 if v_tipo_sersa == 5
	replace bano_ch = 6 if inlist(v_tipo_sersa,3,4)
	
	***********
	*banoex_ch*
	***********	
	gen byte banoex_ch =.
	replace banoex_ch = 9
		
	************
	*sinbano_ch*
	************
	gen byte sinbano_ch =.
	replace sinbano_ch = 3 if v_tipo_sersa ==6
	replace sinbano_ch = 0 if inlist(v_tipo_sersa,1,2,3,4,5)
	
	************
	*conbano_ch*
	************
	gen byte conbano_ch=(inrange(v_tipo_sersa,1,5))
	replace conbano_ch=. if v_tipo_sersa==9 | v_tipo_sersa==.
	
	***********************
	*banoalcantarillado_ch*
	***********************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch = 1 if vc_alc ==1
	replace banoalcantarillado_ch = 0 if inlist(vc_alc,2,3,4)
	
	*********
	*des1_ch*
	*********
	gen byte des1_ch= 1 if inrange(v_tipo_sersa,1,2)
	replace des1_ch=0 if inrange(v_tipo_sersa,3,6)
	replace des1_ch=. if v_tipo_sersa==9 | v_tipo_sersa==.

*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
*Colombia 2018 no tiene variables de ingreso

	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte COL_m_pared_ch =  v_mat_pared 
	label var COL_m_pared_ch  "Material de las paredes según el censo del país - variable original"

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte COL_m_piso_ch= v_mat_piso
	label var COL_m_piso_ch  "Material de los pisos según el censo del país - variable original"

	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte COL_m_techo_ch = .
	label var COL_m_techo_ch  "Material del techo según el censo del país - variable original"

	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long COL_ingreso_ci = .
	label var  COL_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long COL_ingresolab_ci = .
	label var   COL_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte COL_dis_ci = .
	label var COL_dis_ci  "Individuos con discapacidad según el censo del país - variable original"


/*******************************************************************************
   III. Incluir variables externas (10 variables)
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
   V. Borrar variables originales con exepción de los identificadores 
*******************************************************************************/

keep  $lista_variables u_dpto u_mpio ua_clase cod_encuestas u_vivienda p_nrohog p_nro_per
* selecciona las 3 lineas y ejecuta (do). Deben quedar 115 variables de las secciones II y III más las variables originales de ID que hayas mantenido (108)
ds
local varconteo: word count `r(varlist)'
display "Número de variables de la base: `varconteo'"


/*******************************************************************************
   VI. Incluir etiquetas para las variables y categorías
*******************************************************************************/
include "$gitFolder\armonizacion_censos_poblacion_scl\Base\labels_general.do"


/*******************************************************************************
   VII. Guardar la base armonizada 
*******************************************************************************/
compress
save "$base_out", replace 

log close

********************************************************************************
******************* FIN. Muchas gracias por tu trabajo ;) **********************
********************************************************************************
