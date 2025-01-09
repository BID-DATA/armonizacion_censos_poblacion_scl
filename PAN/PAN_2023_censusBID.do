* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: PANAMÁ
Año: 2023
Autores: Pablo Cortez
Última versión: 23MAY2023 
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
		Corre el código y verificalo. Debes tener 94 variables de las secciones 
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
global PAIS PAN    				 //cambiar
global ANIO 2023   				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                  
capture log close
log using "$log_file", replace  //agregar ,replace si ya está creado el log_file en tu carpeta

use "$base_in", clear

rename *, lower

*sample 20   		// significa muestra de 20% de la base. Activar si se necesita.     

/****************************************************************************
   II. Armonización de variables 
*****************************************************************************/

*************************************
*** Identificación (12 variables) ***
*************************************

	**************
	*region_BID_c*
	**************
	gen region_BID_c=.
	replace region_BID_c=1
	label var region_BID_c "Regiones BID"
	label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
	label value region_BID_c region_BID_c

	**********
	*region_c*   
	**********
	destring provincia, replace
	gen byte region_c = provincia
	label define region_c   ///
	1 "Bocas del Toro" 			///  
	2 "Coclé" /// 
	3 "Colón" /// 
	4 "Chiriquí" /// 
	5 "Darién" /// 
	6 "Herrera" /// 
	7 "Los Santos" /// 
	8 "Panamá" /// 
	9 "Veraguas" /// 
	10 "Comarca Kuna Yala" /// 
	11 "Comarca Emberá" /// 
	12 "Comarca Ngäbe-Buglé" /// 
	13 "Panamá Oeste" 
	label value region_c region_c
	tab region_c
		
	*********
	*geolev1*
	*********
	gen long geolev1 =.   
	replace geolev1=591002 if provincia==2 
	replace geolev1=591003 if inlist(provincia,3,10)  
	replace geolev1=591004 if inlist(provincia,1,4,9,12) 
	replace geolev1=591005 if inlist(provincia,11,5)  
	replace geolev1=591006 if provincia==6 
	replace geolev1=591007 if provincia==7  
	replace geolev1=591008 if inlist(provincia,8,13)  
	label define geolev1 591002 "Coclé" ///
	591003 "Colón, Comarca Kuna Yala (San Blas)" ///
	591004 "Bocas de Toro,  Chiriquí, Comarca Ngäbe Buglé, Veraguas" ///
	591005 "Comarca Emberá, Darién" ///
	591006 "Herrera" ///
	591007 "Los Santos" ///
	591008 "Panamá"  
	label value geolev1 geolev1
	tab geolev1
	
    ********
	*pais_c*
	********
	gen str3 pais_c = "PAN" 

    ********
	*anio_c*
	********
	gen int anio_c = 2023
	
    *******************
    *idh_ch (ID hogar)*
    *******************
	egen  idh_ch =concat(llaveviv hogar) 	
	
	** revisar número de hogares
	egen unique_tag = tag(idh_ch)
	count if unique_tag == 1

	**********************
    *idp_ci (ID personas)*
    **********************
	egen  idp_ci = concat(llaveviv hogar npersona) 	
	duplicates report idp_ci // copies =1
	duplicates report idh_ch idp_ci
		
	****************************************
	*(factor_ci) factor expansión individio*
	****************************************
	gen byte factor_ci=.
	
	*******************************************
	*(factor_ch) Factor de expansion del hogar*
	*******************************************
	gen byte factor_ch=.
		
    ************
	*estrato_ci*
	************
	gen byte estrato_ci =.

	*****
	*upm*
	*****
	gen byte upm =.
	
    ********
	*Zona_c*
	********
	gen byte zona_c=.
	replace zona_c= 1 if area == "1"
	replace zona_c= 0 if area == "2"
	tab zona_c,m 
	
	
************************************
*** 2. Demografía (18 variables) ***
************************************

    ********
	*sexo_c*
	********
	gen byte sexo_ci =.
	replace sexo_ci = 1 if  p02_sexo == 1
	replace sexo_ci = 2 if  p02_sexo == 2
	
	********
	*edad_c*
	********
	gen int edad_ci = p03_edad
	replace edad_ci=. if edad_ci > 160 | edad_ci <= 0
	tab edad_ci

	*************
	*relacion_ci*
	*************
	gen byte relacion_ci = .
	replace relacion_ci = 1 if p01_rela == 1
	replace relacion_ci = 2 if p01_rela == 2
	replace relacion_ci = 3 if inlist(p01_rela, 3, 4)
	replace relacion_ci = 4 if inlist(p01_rela, 5,6,7,8,9,10,11,12)
	replace relacion_ci = 5 if inlist(p01_rela, 13)
	replace relacion_ci = 6 if inlist(p01_rela, 14)
	tab relacion_ci,m
	
	**********
	*civil_ci*
	**********
	gen	byte civil_ci=.
	replace civil_ci=1 if inlist(p04_estc,7)
	replace civil_ci=2 if inlist(p04_estc,1,4)
	replace civil_ci=3 if inlist(p04_estc,2, 3, 6)
	replace civil_ci=4 if  inlist(p04_estc,5)
	
    *********
	*jefe_ci*
	*********
	gen byte jefe_ci= (relacion_ci==1)
	
	**************
	*nconyuges_ch*
	**************
	egen byte nconyuges_ch=sum(relacion_ci==2), by (idh_ch)
	
	***********
	*nhijos_ch*
	***********
	egen byte nhijos_ch=sum(relacion_ci==3), by(idh_ch)

	**************
	*notropari_ch*
	**************
	egen byte notropari_ch=sum(relacion_ci==4), by(idh_ch)
	
	****************
	*notronopari_ch*
	****************
	egen byte notronopari_ch=sum(relacion_ci==5), by(idh_ch)
	
	************
	*nempdom_ch*
	************
	egen byte nempdom_ch=sum(relacion_ci==6), by(idh_ch)

	************
	*miembros_ci
	************
	gen byte miembros_ci=(relacion_ci>=1 & relacion_ci<=5) 
	tab miembros_ci	
	
	*************
	*clasehog_ch*
	*************
	gen byte clasehog_ch=0
	replace clasehog_ch=1 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch==0 //unipersonal  
	replace clasehog_ch=2 if (nhijos_ch>0| nconyuges_ch>0) & (notropari_ch==0 & notronopari_ch==0) //nuclear 
	replace clasehog_ch=3 if notropari_ch>0 & notronopari_ch==0 //ampliado
	replace clasehog_ch=4 if ((nconyuges_ch>0 | nhijos_ch>0 | notropari_ch>0) & (notronopari_ch>0)) //compuesto  
	replace clasehog_ch=5 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch>0 //corresident
	ta clasehog_ch,m 
	
	**************
	*nmiembros_ch*
	**************
	egen byte nmiembros_ch=sum(relacion_ci>0 & relacion_ci<=5), by(idh_ch)

	*************
	*nmayor21_ch*
	*************
	egen byte nmayor21_ch=sum((relacion_ci>=1 & relacion_ci<=5) & (edad_ci>=21 & edad_ci!=.)), by(idh_ch) 

	*************
	*nmenor21_ch*
	*************
	egen byte nmenor21_ch=sum((relacion_ci>=1 & relacion_ci<=5) & (edad_ci<21)), by(idh_ch) 

	*************
	*nmayor65_ch*
	*************
	egen byte nmayor65_ch=sum((relacion_ci>=1 & relacion_ci<=5) & (edad_ci>=65 & edad_ci!=.)), by(idh_ch) 

	************
	*nmenor6_ch*
	************
	egen byte nmenor6_ch=sum((relacion_ci>0 & relacion_ci<=5) & (edad_ci<6)), by(idh_ch) 

	************
	*nmenor1_ch*
	************
	egen byte nmenor1_ch=sum((relacion_ci>0 & relacion_ci<=5) & (edad_ci<1)), by(idh_ch) 

************************************
*** 3. Diversidad (11 variables) ***
************************************		

	*********
	*afro_ci*
	*********
	gen byte afro_ci = . 	  // se queda como missing (.) si no existe la pregunta
	replace afro_ci =1 if  inlist(p09_afrod, 1,2,3,4,5,6,7)
	replace afro_ci =0 if inlist(p09_afrod, 8)
	
	ta p09_afrod,m 
	ta afro_ci,m
	des afro_ci
	
	*********
	*indi_ci*
	*********	
	gen byte ind_ci =. 		  // se queda como missing (.) si no existe la pregunta
	replace ind_ci =1 if  inlist(p08_indig, 1,2,3,4,5,6,7,8, 9, 10)
	replace ind_ci =0 if inlist(p08_indig, 11)
	
	ta p08_indig,m 
	ta ind_ci,m
	des ind_ci

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
	gen byte afroind_ci=. 
	replace afroind_ci=1 if ind_ci==1 
	replace afroind_ci=2 if afro_ci==1
	replace afroind_ci=3 if noafroind_ci == 1
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
	gen byte dis_ci=0
	replace dis_ci=1 if (inlist(p11b1_cami, 2,3,4))  | ///
						(inlist(p11b3_habl, 2,3,4))  | /// según wg no se incluyé específicamente usar los brazos
						(inlist(p11b4_enten,2,3,4))  | ///
						(inlist(p11b5_cuid, 2,3,4))  | ///
						(inlist(p11b6_ver,  2,3,4))  | ///
						(inlist(p11b7_oir,  2,3,4))
	replace dis_ci=. if p11_disca == 3
	
	tab dis_ci,m
	ta p11_disca,m
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=0 
	replace disWG_ci=1 if   (inlist(p11b1_cami,3,4))    | ///
							(inlist(p11b3_habl,3,4))    | /// según wg no se incluyé específicamente usar los brazos
							(inlist(p11b4_enten,3,4))   | ///
							(inlist(p11b5_cuid,3,4))    | ///
							(inlist(p11b6_ver, 3,4))    | ///
							(inlist(p11b7_oir, 3,4))
	
	replace disWG_ci=. if p11_disca == 3
	tab disWG_ci
	
	********
	*dis_ch*
	********
	egen byte dis_ch = sum(dis_ci), by(idh_ch) 
	replace dis_ch=1 if dis_ch>=1 & dis_ch!=.
	
**********************************
*** 4. Migración (3 variables) ***
**********************************	
ta p05_nacio
ta p03b_reg_civil
* p05a_anio1
ta p05_nacio p03b_reg_civil

    *****************
    *migrante_ci****
    ****************
	gen byte migrante_ci=0 
	replace migrante_ci=1 if p05_nacio == 3
	replace migrante_ci=. if p05_nacio == 4
	ta migrante_ci,m
	 	
	****************
    *migrantiguo5_ci*
    ****************
	gen antiguedad = 2024 - p05a_anio1 
	gen byte migrantiguo5_ci=0
	replace migrantiguo5_ci=1 if antiguedad >= 5 & migrante_ci==1
	replace migrantiguo5_ci=. if migrante_ci == 0
	ta migrantiguo5_ci,m 
	
	***********
	*miglac_ci*
	***********
	destring p05_naci_cod, gen(pais_naci)
	tab pais_naci if migrante_ci == 1
	gen byte miglac_ci=0 if migrante_ci == 1
	replace miglac_ci=1 if inrange(pais_naci,211,381)  & migrante_ci ==1
	replace miglac_ci=. if migrante_ci == 0
	ta miglac_ci
	
***********************************
*** 5. Educación (13 variables) ***
***********************************
	
	*********
	*aedu_ci*
	*********
	ta p15_grado,m
	
	gen byte aedu_ci=0 if inlist(p15_grado,1,2,3,4)
	replace aedu_ci=1 if p15_grado == 11
	replace aedu_ci=2 if p15_grado == 12
	replace aedu_ci=3 if p15_grado == 13
	replace aedu_ci=4 if p15_grado == 14
	replace aedu_ci=5 if p15_grado == 15
	replace aedu_ci=6 if p15_grado == 16
	
	replace aedu_ci=7 if p15_grado == 21
	replace aedu_ci=8 if p15_grado == 22
	replace aedu_ci=9 if p15_grado == 23
		 
	replace aedu_ci=7 if p15_grado == 31
	replace aedu_ci=8 if p15_grado == 32
	replace aedu_ci=9 if p15_grado == 33
	replace aedu_ci=10 if p15_grado == 34
	replace aedu_ci=11 if p15_grado == 35
					
	replace aedu_ci=12 if p15_grado == 36
	replace aedu_ci=12 if p15_grado == 41
	replace aedu_ci=12 if p15_grado == 42
 
	replace aedu_ci=12+1 if p15_grado == 51
	replace aedu_ci=12+2 if p15_grado == 52
	replace aedu_ci=12+3 if p15_grado == 53
	replace aedu_ci=12+4 if p15_grado == 54
	replace aedu_ci=12+5 if p15_grado == 55
	replace aedu_ci=12+6 if p15_grado == 56
						
	replace aedu_ci=16+1 if p15_grado == 61
	
	replace aedu_ci=16+1 if p15_grado == 71
	replace aedu_ci=16+2 if p15_grado == 72
		
	replace aedu_ci=16+1 if p15_grado == 81
	replace aedu_ci=16+2 if p15_grado == 82
	replace aedu_ci=16+3 if p15_grado == 83
	replace aedu_ci=16+4 if p15_grado == 84
				
	replace aedu_ci=18 if aedu_ci>=18 
	
	replace aedu_ci=. if p15_grado == .
	replace aedu_ci=. if p15_grado == 99
		
	**********
	*eduno_ci*
	**********
	gen byte eduno_ci=(aedu_ci==0) 
	replace eduno_ci=. if aedu_ci==. 

	**********
	*edupi_ci*
	**********
	gen byte edupi_ci=(aedu_ci>=1 & aedu_ci<=5) 
	replace edupi_ci=. if aedu_ci==. 
	ta edupi_ci

	**********
	*edupc_ci*
	**********
	gen byte edupc_ci=(aedu_ci==6) 
	replace edupc_ci=. if aedu_ci==. 

	**********
	*edusi_ci*
	**********
	gen byte edusi_ci=(aedu_ci>= 7 & aedu_ci<=11) 
	replace edusi_ci=. if aedu_ci==. 

	**********
	*edusc_ci*
	**********
	gen byte edusc_ci=(aedu_ci==12) 
	replace edusc_ci=. if aedu_ci==. 

	***********
	*edus1i_ci*
	***********
	gen byte edus1i_ci=(aedu_ci>=7 & aedu_ci<=8)
	replace edus1i_ci=. if aedu_ci==. 

	***********
	*edus1c_ci*
	***********
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if aedu_ci==. 

	***********
	*edus2i_ci*
	***********
	gen byte edus2i_ci=(aedu_ci>=10 & aedu_ci<=11)
	replace edus2i_ci=. if aedu_ci==. 

	***********
	*edus2c_ci*
	***********
	gen byte edus2c_ci=(aedu_ci>=12)
	replace edus2c_ci=. if aedu_ci==. 

	***********
	*edupre_ci*
	***********
	gen byte edupre_ci= 0
	replace edupre_ci = 1 if aedu_ci >= 3
	replace edupre_ci=. if aedu_ci==. 
	
	***********
	*asiste_ci*
	***********
	gen byte asiste_ci=1 if p14_escu == 1
	replace asiste_ci=0 if p14_escu == 2
	replace asiste_ci=. if p14_escu == 3 |p14_escu == .

	**********
	*literacy*
	**********
	gen byte literacy=1 if p13_slye == 1
	replace literacy=0 if p13_slye == 2
	replace literacy=. if p13_slye == . | p13_slye == 3
		
****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

    *************
    *condocup_ci*
    *************
	ta p17_trab,m
	ta p17a_trabaus,m
	ta p17b_algtra,m
	ta p17c_algfam,m 
	
    gen byte condocup_ci =.
	replace condocup_ci = 1 if p17_trab == 1 | p17a_trabaus == 1  | p17b_algtra == 1 | p17c_algfam == 1  //ocupados
	replace condocup_ci = 2 if (p17_trab == 2 & p17a_trabaus == 2 & p17b_algtra == 2 & p17c_algfam == 2) & (p17d_bsem == 1)	// desocupados	
	ta p17d_bsem,m 
	replace condocup_ci = 3 if (p17_trab == 2 & p17a_trabaus == 2 & p17b_algtra == 2 & p17c_algfam == 2) & (p17d_bsem == 2 ) //inactivos
	replace condocup_ci = 4 if edad_ci < 15	//no responde por ser menor de edad
	ta condocup_ci,m

	********
    *emp_ci*
    ********
	gen byte emp_ci=.
	replace emp_ci=(condocup_ci==1) if condocup_ci!=.
	sum emp_ci if emp_ci == 1

	***********
    *desemp_ci*
    ***********	
	gen byte desemp_ci=.
	replace desemp_ci=(condocup_ci==2) if condocup_ci!=.

	********
    *pea_ci*
    ********
	gen byte pea_ci=.
	replace pea_ci=1 if inlist(condocup_ci,1,2)
	replace pea_ci=0 if inlist(condocup_ci,3,4)
	
	sum desemp_ci if desemp_ci == 1
	local dese = r(N)

	sum pea_ci if pea_ci == 1
	local pea = r(N)
	
	di (`dese'/`pea')*100
	
	*******************
    *rama de actividad*
    *******************
	destring  p18_ocup_cod4, gen(rama_temp)
	ta p18_ocup_cod4,m
	
	gen byte rama_ci = . 
    replace rama_ci = 1 if rama_temp < 500 & emp_ci==1
    replace rama_ci = 2 if  (rama_temp >= 500 &  rama_temp < 1000) & emp_ci==1
    replace rama_ci = 3 if  (rama_temp >= 1000 & rama_temp < 3321) & emp_ci==1
    replace rama_ci = 4 if  (rama_temp >= 3500 & rama_temp < 3990) & emp_ci==1   
    replace rama_ci = 5 if  (rama_temp >= 4100 & rama_temp < 4399) & emp_ci==1 
    replace rama_ci = 6 if  (rama_temp >= 4500 & rama_temp < 4899) & emp_ci==1   
    replace rama_ci = 8 if  (rama_temp >= 4900 & rama_temp < 5390) & emp_ci==1  
    replace rama_ci = 7 if  (rama_temp >= 5500 & rama_temp < 6400) & emp_ci==1 
    replace rama_ci = 9 if  (rama_temp >= 6400 & rama_temp < 6639) & emp_ci==1
    replace rama_ci = 11 if (rama_temp >= 6800 & rama_temp < 8300) & emp_ci==1
    replace rama_ci = 10 if (rama_temp >= 8400 & rama_temp < 8431) & emp_ci==1
    replace rama_ci = 12 if (rama_temp >= 8500 & rama_temp < 8599) & emp_ci==1
    replace rama_ci = 13 if (rama_temp >= 8600 & rama_temp < 8899) & emp_ci==1
    replace rama_ci = 14 if (rama_temp >= 9000 & rama_temp < 9610) & emp_ci==1
    replace rama_ci = 15 if (rama_temp >= 9700) & emp_ci==1
	ta rama_ci,m
	
	**************
    *categopri_ci*
    **************
	gen byte categopri_ci=.
	replace categopri_ci=0 if p21_categ == 6 & emp_ci==1
	replace categopri_ci=1 if p21_categ == 5 & emp_ci==1
	replace categopri_ci=2 if p21_categ == 4 & emp_ci==1
	replace categopri_ci=3 if (p21_categ == 1 | p21_categ == 2 | p21_categ == 3)  & emp_ci==1
	replace categopri_ci=4 if p21_categ == 7 & emp_ci==1
	 
	*************
    *spublico_ci*
    *************
	gen byte spublico_ci=.
	replace spublico_ci=1 if p21_categ ==1 & emp_ci == 1
	replace spublico_ci=0 if p21_categ != 1 & emp_ci == 1
		
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************		

	********
	*luz_ch*
	********
	gen byte luz_ch=.
	replace luz_ch=1 if inlist(v14_luz,1,2,3,4)
	replace luz_ch=0 if inlist(v14_luz,4,6,7,8)

	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
	replace piso_ch = 0 if v06_piso == 4
	replace piso_ch = 1 if v06_piso == 6
	replace piso_ch = 2 if v06_piso == 1 | v06_piso == 2 | v06_piso == 3 | v06_piso == 5
	
	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	replace pared_ch = 0 if v04_pared == 7
	replace pared_ch=1 if v04_pared == 2 | v04_pared == 3 | v04_pared == 4 | v04_pared == 5 | v04_pared == 6
	replace pared_ch=2 if v04_pared == 1

	**********
	*techo_ch*
	**********
	gen byte techo_ch=.
	*replace techo_ch=0 if .
	replace techo_ch=1 if inlist(v05_techo,6,7)
	replace techo_ch=2 if inlist(v05_techo,1,2,3,4,5)

	**********
	*resid_ch*
	**********
	gen byte resid_ch=.
	replace resid_ch=0 if inlist(v15_basu,1,2)
	replace resid_ch=1 if inlist(v15_basu,3,5)
	replace resid_ch=2 if inlist(v15_basu,4,6)
	replace resid_ch=3 if inlist(v15_basu,7)

	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=.
	replace dorm_ch= v07a_dorm

	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=.
	replace cuartos_ch= v07_cuar 
	
	***********
	*cocina_ch*
	***********
	gen byte cocina_ch=.
	*replace cocina_ch=1 if ...
	*replace cocina_ch=0 if ...
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch=.
	replace telef_ch=1 if  h18h_tres == 1
	replace telef_ch=0 if h18h_tres == 2
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=.
	replace refrig_ch=1 if h18b_refr == 1
	replace refrig_ch=0 if h18b_refr == 2
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	replace auto_ch=1 if h18m_auto == 1
	replace auto_ch=0 if h18m_auto == 2
	
	**********
	*compu_ch*
	**********
	gen byte compu_ch=.
	replace compu_ch=1 if h18k_comp == 1
	replace compu_ch=0 if h18k_comp == 2

	*************
	*internet_ch*
	************* 
	gen byte internet_ch=.
	replace internet_ch=1 if  h18l_inter == 1
	replace internet_ch=0 if  h18l_inter == 2

	********
	*cel_ch*
	********
	gen byte cel_ch=.
	replace cel_ch=1 if h18i_tcel == 1
	replace cel_ch=0 if h18i_tcel == 2

	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch1=.
	replace viviprop_ch=1 if inlist(v03_tene,1,3,4,5)
	replace viviprop_ch=0 if inlist(v03_tene,2,6)

***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************

	************
	*aguaentubada_ch*
	************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch=1 if inlist(v08_agua, 1,2,3)
	replace aguaentubada_ch=0 if inlist(v08_agua, 4,5,6,7,8,11)
	replace aguaentubada_ch = 1 if (inlist(v08_agua, 9,10)) & v11_sanit == 1
	replace aguaentubada_ch = 0 if (inlist(v08_agua, 9,10)) & v11_sanit != 1

	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch = 1 if inlist(v08_agua,1,2)
	replace aguared_ch = 0 if inlist(v08_agua, 3,4,5,6,7,8,9,10,11,12)
  	
    ***************
	*aguafuente_ch*
	***************
 	gen byte aguafuente_ch=.
	replace aguafuente_ch = 1 if inlist(v08_agua,1,2) & v09_inst == 1
	replace aguafuente_ch = 2 if inlist(v08_agua,1,2) & v09_inst == 2
	replace aguafuente_ch = 3 if inlist(v08_agua,10) 
	replace aguafuente_ch = 4 if inlist(v08_agua,4) 
	replace aguafuente_ch = 5 if inlist(v08_agua,7) 
	replace aguafuente_ch = 6 if inlist(v08_agua,9) 
	replace aguafuente_ch = 7 if inlist(v08_agua,3) 
	replace aguafuente_ch = 8 if inlist(v08_agua,8) 
	replace aguafuente_ch = 9 if inlist(v08_agua,5) 
	replace aguafuente_ch = 10 if inlist(v08_agua,6,11,12)

	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch=0 
	
	**************
	*aguadisp1_ch*
	**************
	gen byte aguadisp1_ch =9
		
	**************
	*aguadisp2_ch*
	**************
	gen byte aguadisp2_ch =.
	replace aguadisp2 = 1 if (v10b_diasel<4 | v10b_regel<12) | (v10a_diases<4 | v10a_reges<12)
	replace aguadisp2 = 2 if (v10b_diasel>=4 | v10b_regel>=12) & (v10a_diases>=4 | v10a_reges>=12)
	replace aguadisp2 = 3 if (v10b_diasel==7 | v10b_regel==24) & (v10a_diases ==7 | v10a_reges==24)

	*************
	*aguamide_ch*
	*************
	gen byte aguamide_ch = 9
	
	*********
	*bano_ch*
	*********
	gen byte bano_ch = . 
	replace bano_ch = 0 if v11_sanit == 4
	replace bano_ch = 1 if v11_sanit == 1
	replace bano_ch = 2 if v11_sanit == 2
	replace bano_ch = 6 if v11_sanit == 3
	
	***********
	*banoex_ch*
	***********
	gen byte banoex_ch =.
	replace banoex_ch = 1 if v12_suso ==1
	replace banoex_ch = 0 if v12_suso ==2

	************
	*sinbano_ch*
	************
	gen byte sinbano_ch =.
	replace sinbano_ch = 0 if inlist(v11_sanit, 1,2,3)
	replace sinbano_ch = 1 if v13_excr ==4
	replace sinbano_ch = 2 if inlist(v13_excr, 1,2,3)
	replace sinbano_ch = 3 if inlist(v13_excr,5)
	
	*********
	*conbano_ch*
	*********
	gen byte conbano_ch=.
	replace conbano_ch=1 if inlist(v11_sanit,1,2,3)
	replace conbano_ch=0 if inlist(v11_sanit,4)
	
	*****************
	*banoalcantarillado_ch*
	*****************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch=1 if inlist(v11_sanit,1,2)
	replace banoalcantarillado_ch=0 if inlist(v11_sanit,3,4)
	
	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	replace des1_ch=0 if inlist(v11_sanit,4)
	replace des1_ch=1 if inlist(v11_sanit,1)
	replace des1_ch=2 if inlist(v11_sanit,2,3)

*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte PAN_m_pared_ch = v04_pared
	label var PAN_m_pared_ch  "Material de las paredes según el censo del país - variable original"
	label def PAN_m_pared_ch  1 "Bloque, ladrillo, piedra, concreto" 2 " Madera (tablas o troza)" 3 "Quincha o adobe"  ///
	4 " Metal (zinc, aluminio, otros)" 5 "Palma, paja, penca, ca aza, bamb  o pal" 6 "Otros materiales" 7 "Sin paredes" //categorías originales del país
	label val PAN_m_pared_ch  PAN_m_pared_ch 

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte PAN_m_piso_ch= v06_piso
	label var PAN_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	label def PAN_m_piso_ch  1 "Mosaico o baldosa, m rmol o parqu " 2 "Pavimentado (concreto)" 3 "Ladrillo" 4 "Tierra" 5 "Madera" 6 "Otros materiales (ca a, palos, desechos"  //categorías originales del país
	label val PAN_m_piso_ch  PAN_m_piso_ch 
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte PAN_m_techo_ch = v05_techo
	label var PAN_m_techo_ch  "Material del techo según el censo del país - variable original"
	label def PAN_m_techo_ch  1 "Metal (zinc, aluminio, entre otros)" 2 "Teja" 3 "Otro tipo de tejas (tejalit, panalit, techolit, entre otras)" 4 "Losa de concreto" ///
           5 "Madera" ///
           6 "Palma, paja o penca" ///
           7 "Otros materiales" ///
  //categorías originales del país
	label val PAN_m_techo_ch PAN_m_techo_ch 
	ta PAN_m_techo_ch
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long PAN_ingreso_ci = p22a_ingr
	label var  PAN_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long PAN_ingresolab_ci = p221_suel	
	label var   PAN_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte PAN_dis_ci = p11_disca
	label var PAN_dis_ci  "Individuos con discapacidad según el censo del país - variable original"
	label def PAN_dis_ci 1 "Sí" 2 "No"   //categorías originales del país
	label val PAN_dis_ci PAN_dis_ci
	tab PAN_dis_ci

/*******************************************************************************
   III. Incluir variables externas (7 variables)
*******************************************************************************/
capture drop _merge
merge m:1 pais_c anio_c using "Z:/general_documentation/data_externa/poverty/International_Poverty_Lines/5_International_Poverty_Lines_LAC_long_PPP17.dta", keepusing ( lp19_2011 lp31_2011 lp5_2011 tc_wdi cpi_2017 lp365_2017 lp685_201)
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

drop cpi_2017 lp19_2011 lp31_2011 lp5_2011 tc_wdi _merge

/*******************************************************************************
   IV. Revisión de que se hayan creado todas las variables
*******************************************************************************/
* CALIDAD: revisa que hayas creado todas las variables. Si alguna no está
* creada, te apacerá en rojo el nombre. 

global lista_variables region_BID_c region_c geolev1 pais_c anio_c idh_ch idp_ci factor_ci factor_ch estrato_ci upm zona_c sexo_c edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch miembros_ci clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch afro_ci ind_ci noafroind_ci afroind_ci afro_ch ind_ch noafroind_ch afroind_ch  dis_ci disWG_ci dis_ch migrante_ci migrantiguo5_ci miglac_ci aedu_ci eduno_ci edupi_ci edupc_ci edusi_ci edusc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci edupre_ci asiste_ci literacy condocup_ci emp_ci desemp_ci pea_ci rama_ci  categopri_ci spublico_ci luz_ch piso_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch1 aguaentubada_ch aguared_ch aguafuente_ch aguadist_ch aguadisp1_ch aguadisp2_ch aguamide_ch bano_ch banoex_ch banoalcantarillado_ch sinbano_ch conbano_ch des1_ch ${PAIS}_ingreso_ci ${PAIS}_ingresolab_ci ${PAIS}_m_pared_ch ${PAIS}_m_piso_ch ${PAIS}_m_techo_ch ${PAIS}_dis_ci tc_c ipc_c lp19_ci lp31_ci lp5_ci lp365_2017  lp685_2017

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

keep  $lista_variables llaveviv hogar npersona 
* selecciona las 3 lineas y ejecuta (do). Deben quedar 105 variables de las secciones II y III más las variables originales de ID que hayas mantenido (108)
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
