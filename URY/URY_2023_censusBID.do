* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: Uruguay
Año: 2023
Autores: CarolinaRivas/Jillie Chang
Última versión: 24JUN2025
División: SCL/SCL - IADB
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

global ruta = "${censusFolder}"  
global PAIS URY    				 
global ANIO 2023   				 

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using `"$log_file"', replace  

use "$base_in", clear

rename *, lower

* sample 20   		// significa muestra de 20% de la base. Activar si se necesita.     

/****************************************************************************
   II. Armonización de variables 
*****************************************************************************/

*************************************
*** Identificación (12 variables) ***
*************************************

	**************
	*region_BID_c*
	**************
	gen byte region_BID_c = 4

	**********
	*region_c*   
	**********
	destring departamento, replace
	gen byte region_c = departamento
	label define region_c   ///
	1 "Montevideo" 		///  
	2 "Artigas" 		///  
	3 "Canelones" 		///  
	4 "Cerro Largo" 	///  
	5 "Colonia" 		///  
	6 "Durazno" 		///  
	7 "Flores" 			///  
	8 "Florida" 		///  
	9 "Lavalleja" 		///  
	10 "Maldonado" 		///  
	11 "Paysandú" 		///  
	12 "Río Negro" 		///  
	13 "Rivera" 		///  
	14 "Rocha" 			///  
	15 "Salto" 			///  
	16 "San José" 		///  
	17 "Soriano" 		///  
	18 "Tacuarembó" 	///  
	19 "Treinta y Tres" 			

	label value region_c region_c
	tab region_c
	
	*********
	*geolev1*
	*********
	gen long geolev1 =.  
	replace geolev1=858001 if region_c==1 
	replace geolev1=858002 if region_c==2 
	replace geolev1=858003 if region_c==3 
	replace geolev1=858004 if region_c==4 
	replace geolev1=858005 if region_c==5 
	replace geolev1=858006 if region_c==6 
	replace geolev1=858007 if region_c==7 
	replace geolev1=858008 if region_c==8 
	replace geolev1=858009 if region_c==9 
	replace geolev1=858010 if region_c==10 
	replace geolev1=858011 if region_c==11
	replace geolev1=858012 if region_c==12 
	replace geolev1=858013 if region_c==13 
	replace geolev1=858014 if region_c==14 
	replace geolev1=858015 if region_c==15 
	replace geolev1=858016 if region_c==16 
	replace geolev1=858017 if region_c==17 
	replace geolev1=858018 if region_c==18 
	replace geolev1=858019 if region_c==19 
	replace geolev1=858999 if region_c==.

	label define geolev1	///
	858001 "Montevideo" 	///  
	858002 "Artigas" 		///  
	858003 "Canelones" 		///  
	858004 "Cerro Largo" 	///  
	858005 "Colonia" 		///  
	858006 "Durazno" 		///  
	858007 "Flores" 		///  
	858008 "Florida" 		///  
	858009 "Lavalleja" 		///  
	858010 "Maldonado" 		///  
	858011 "Paysandú" 		///  
	858012 "Río Negro" 		///  
	858013 "Rivera" 		///  
	858014 "Rocha" 			///  
	858015 "Salto" 			///  
	858016 "San José" 		///  
	858017 "Soriano" 		///  
	858018 "Tacuarembó" 	///  
	858019 "Treinta y Tres"   ///  
	858999 "No se conoce"
	
	label value geolev1 geolev1
	tab geolev1
	
    ********
	*pais_c*
	********
	gen str3 pais_c = "URY" 

    ********
	*anio_c*
	********
	gen int anio_c = 2023
	
    *******************
    *idh_ch (ID hogar)*
    *******************
	egen  idh_ch =concat(direccion_id departamento localidad vivid hogid) 	
	replace  idh_ch="" if hogid=="NA"
	* revisar número de hogares
	egen unique_tag = tag(idh_ch)
	count if unique_tag == 1
	
	**********************
    *idp_ci (ID personas)*
    **********************
	tostring id_censo, gen(idp_ci) format("%16.0f")
	duplicates report idh_ch idp_ci // CALIDAD: revisar que resultado sea copies =1

	****************************************
	*(factor_ci) factor expansión individio*
	****************************************
	gen factor_ci=.
	
	*******************************************
	*(factor_ch) Factor de expansion del hogar*
	*******************************************
	gen factor_ch=.
		
    ************
	*estrato_ci*
	************
	gen estrato_ci =.

	*****
	*upm*
	*****
	gen upm =.
	
    ********
	*zona_c*
	********
	gen byte zona_c=.
	replace zona_c=1 if area==1
	replace zona_c=0 if area==2
	replace zona_c=. if area== 9898
	tab zona_c

************************************
*** 2. Demografía (18 variables) ***
************************************

    ********
	*sexo_c*
	********
	gen byte sexo_ci =.
	replace sexo_ci = 1 if perph02==1
	replace sexo_ci = 2 if perph02==2
	tab sexo_ci
	
	********
	*edad_c*
	********
	gen int edad_ci = perna01
	replace edad_ci=. if perna01==5555
	tab edad_ci

	*************
	*relacion_ci*
	*************
	gen byte relacion_ci = .
	replace relacion_ci = 1 if perpa01==1   //jefea
	replace relacion_ci = 2 if perpa01==2    //conyuge
	replace relacion_ci = 3 if perpa01==3 | perpa01==4 | perpa01==5  //hijoa
	replace relacion_ci = 4 if perpa01>=6 & perpa01<=12   //otro pariente
	replace relacion_ci = 5 if perpa01==13 |  perpa01==15   //otro no pariente
	replace relacion_ci = 6 if perpa01==14   //empleado
	replace relacion_ci = . if perpa01==8888 | perpa01==9898 | perpa01==16
	tab perpa01, mi
	tab relacion_ci, mi
	tab perpa01 relacion_ci , mi
	
	**********
	*civil_ci*
	**********
	gen	byte civil_ci=.
	replace civil_ci=1 if perec01==7777 // "7777 significa no corresponde". Es el Menor de 14 años.
	replace civil_ci=1 if perec01==2 & (perec04==6)
	replace civil_ci=2 if perec01==1	
	replace civil_ci=3 if perec01==2 & (perec04==2 | perec04==7 | perec04==1)
	replace civil_ci=4 if perec01==2 & (perec04==4 | perec04==5)
	tab civil_ci, m
	
    *********
	*jefe_ci*
	*********
	gen byte jefe_ci= (relacion_ci==1)
	replace jefe_ci=. if idh_ch==""
	
	**************
	*nconyuges_ch*
	**************
	egen byte nconyuges_ch=sum(relacion_ci==2), by (idh_ch)
	replace nconyuges_ch=. if idh_ch==""
	
	***********
	*nhijos_ch*
	***********
	egen byte nhijos_ch=sum(relacion_ci==3), by(idh_ch)
	replace nhijos_ch=. if idh_ch==""

	**************
	*notropari_ch*
	**************
	egen byte notropari_ch=sum(relacion_ci==4), by(idh_ch)
	replace notropari_ch=. if idh_ch==""
	
	****************
	*notronopari_ch*
	****************
	egen byte notronopari_ch=sum(relacion_ci==5), by(idh_ch)
	replace notronopari_ch=. if idh_ch==""
	
	************
	*nempdom_ch*
	************
	egen byte nempdom_ch=sum(relacion_ci==6), by(idh_ch)
	replace nempdom_ch=. if idh_ch==""

	************
	*miembros_ci
	************
	gen byte miembros_ci=(relacion_ci>=1 & relacion_ci<=5) 
	replace miembros_ci=. if relacion_ci==.
	tab miembros_ci
	
	*************
	*clasehog_ch*
	*************
	gen byte clasehog_ch=0
	replace clasehog_ch=1 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch==0 //unipersonal  
	replace clasehog_ch=2 if (nhijos_ch>0| nconyuges_ch>0) & (notropari_ch==0 & notronopari_ch==0) //nuclear 
	replace clasehog_ch=3 if notropari_ch>0 & notronopari_ch==0 //ampliado
	replace clasehog_ch=4 if ((nconyuges_ch>0 | nhijos_ch>0 | notropari_ch>0) & (notronopari_ch>0)) //compuesto  
	replace clasehog_ch=5 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch>0 //corresidente
	replace clasehog_ch=. if idh_ch==""
	
	**************
	*nmiembros_ch*
	**************
	egen byte nmiembros_ch=sum(relacion_ci>0 & relacion_ci<=5), by(idh_ch)
	replace nmiembros_ch=. if idh_ch==""

	*************
	*nmayor21_ch*
	*************
	egen byte nmayor21_ch=sum((relacion_ci>=1 & relacion_ci<=5) & (edad_ci>=21 & edad_ci!=.)), by(idh_ch) 
	replace nmayor21_ch=. if idh_ch==""

	*************
	*nmenor21_ch*
	*************
	egen byte nmenor21_ch=sum((relacion_ci>=1 & relacion_ci<=5) & (edad_ci<21)), by(idh_ch) 
	replace nmenor21_ch=. if idh_ch==""

	*************
	*nmayor65_ch*
	*************
	egen byte nmayor65_ch=sum((relacion_ci>=1 & relacion_ci<=5) & (edad_ci>=65 & edad_ci!=.)), by(idh_ch) 
	replace nmayor65_ch=. if idh_ch==""

	************
	*nmenor6_ch*
	************
	egen byte nmenor6_ch=sum((relacion_ci>0 & relacion_ci<=5) & (edad_ci<6)), by(idh_ch) 
	replace nmenor6_ch=. if idh_ch==""

	************
	*nmenor1_ch*
	************
	egen byte nmenor1_ch=sum((relacion_ci>0 & relacion_ci<=5) & (edad_ci<1)), by(idh_ch) 
	replace nmenor1_ch=. if idh_ch==""

************************************
*** 3. Diversidad (11 variables) ***
************************************		

	*********
	*afro_ci*
	*********
	gen byte afro_ci =. 	  // se queda como missing (.) si no existe la pregunta
	replace afro_ci =1 if perer01_1==1
	replace afro_ci =0 if perer01_1==2
	tab afro_ci
	
	*********
	*indi_ci*
	*********	
	gen byte ind_ci =. 		  // se queda como missing (.) si no existe la pregunta
	replace ind_ci =1 if perer01_4==1
	replace ind_ci =0 if perer01_4==2
	tab ind_ci

	**************
	*noafroind_ci*
	**************
	gen byte noafroind_ci =.   // se queda como missing (.) si no existe la pregunta
	replace noafroind_ci =1 if afro_ci==0 & ind_ci==0
	replace noafroind_ci =0 if afro_ci==1 | ind_ci==1
	replace noafroind_ci =. if afro_ci==. | ind_ci==. //Esto solo en el caso que se tenga ambas opciones no disponibles. 

	************
	*afroind_ci*
	************
	gen byte afroind_ci=. 
	replace afroind_ci=1 if ind_ci==1 
	replace afroind_ci=2 if afro_ci==1
	replace afroind_ci=3 if noafroind_ci == 1

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
	local variables perdi01 perdi07 perdi02 perdi03 perdi04 perdi06
	foreach v of local variables {
		gen _`v' = 0
		replace _`v'=1 if `v'>1
		replace _`v'=. if  `v'==8888 | `v'==9898 
	}
	egen _tempdis=rowtotal(_perdi01 _perdi02 _perdi03 _perdi04 _perdi06 _perdi07), mi
	gen byte dis_ci=. 
	replace dis_ci=0 if _tempdis==0
	replace dis_ci=1 if _tempdis>=1 &_tempdis!=.
	drop  _tempdis _perdi0*
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=0 if dis_ci!=.
	replace disWG_ci=1 if ///
		perdi01>=3 & perdi01<=4 | ///
		perdi02>=3 & perdi02<=4 | ///
		perdi03>=3 & perdi03<=4 | ///
		perdi04>=3 & perdi04<=4 | ///
		perdi06>=3 & perdi06<=4 | ///
		perdi07>=3 & perdi07<=4 
	*sort idh_ch idp_ci 
	*br perdi0* _perdi0* _tempdis dis_ci disWG_ci* dis_ch idp_ci idh_ch direccion_id departamento localidad vivid hogid relacion_ci
	
	********
	*dis_ch*
	********
	egen byte dis_ch = sum(dis_ci), by(idh_ch) 
	replace dis_ch=1 if dis_ch>=1 & dis_ch!=.
	replace  dis_ch=. if idh_ch==""
	br if idh_ch==""

	
**********************************
*** 4. Migración (3 variables) ***
**********************************	

    *****************
    *migrante_ci****
    ****************
	gen byte migrante_ci=. 
	replace migrante_ci=1 if permi01==4
	replace migrante_ci=0 if permi01==1 | permi01==3
	 
	****************
    *migrantiguo5_ci*
    ****************
	gen byte migrantiguo5_ci=.
	replace migrantiguo5_ci=1 if permi02<=2018 
	replace migrantiguo5_ci=0 if permi02>2018 & permi02<=2023
	
	***********
	*miglac_ci*
	***********
	gen byte miglac_ci=0

	replace miglac_ci = 1 if migrante_ci == 1 & ///
		(permi01_4 == 32  /* Argentina */             | ///
		 permi01_4 == 44  /* Bahamas */               | ///
		 permi01_4 == 52  /* Barbados */              | ///
		 permi01_4 == 68  /* Bolivia */               | ///
		 permi01_4 == 76  /* Brasil */                | ///
		 permi01_4 == 84  /* Belice */                | ///
		 permi01_4 == 152 /* Chile */                 | ///
		 permi01_4 == 170 /* Colombia */              | ///
		 permi01_4 == 188 /* Costa Rica */            | ///
		 permi01_4 == 192 /* Cuba */                  | ///
		 permi01_4 == 212 /* Dominica */              | ///
		 permi01_4 == 214 /* República Dominicana */  | ///
		 permi01_4 == 218 /* Ecuador */               | ///
		 permi01_4 == 222 /* El Salvador */           | ///
		 permi01_4 == 308 /* Granada */               | ///
		 permi01_4 == 320 /* Guatemala */             | ///
		 permi01_4 == 332 /* Haití */                 | ///
		 permi01_4 == 340 /* Honduras */              | ///
		 permi01_4 == 388 /* Jamaica */               | ///
		 permi01_4 == 484 /* México */                | ///
		 permi01_4 == 591 /* Panamá */                | ///
		 permi01_4 == 600 /* Paraguay */              | ///
		 permi01_4 == 604 /* Perú */                  | ///
		 permi01_4 == 659 /* San Cristóbal y Nieves */| ///
		 permi01_4 == 662 /* Santa Lucía */           | ///
		 permi01_4 == 670 /* San Vicente, Granadinas */  | ///
		 permi01_4 == 740 /* Surinam */               | ///
		 permi01_4 == 780 /* Trinidad y Tobago */     | ///
		 permi01_4 == 858 /* Uruguay */               | ///
		 permi01_4 == 862 /* Venezuela */)
	 
	replace miglac_ci=. if migrante_ci!=1

***********************************
*** 5. Educación (13 variables) ***
***********************************
/* son dos preguntas. ambas son útiles para armar aedu_ci
pered03 NIVEL EDUCATIVO CURSANDO ACTUALMENTE	
		1	Educación Inicial o Educación Preescolar (aedu_ci = 0)
		2	Primaria común (>= 1 & < 6) --> 6 completa
		3	Primaria especial (no se considera)
		13	Educación media básica o Ciclo Básico (Liceo o UTU) (>= 6 & <= 9)
		14	Educación media superior o Bachillerato (Liceo o UTU) (> 9 & <= 12)
		15	Capacitaciones o cursos de UTU que NO acreditan Ciclo Básico NI Bachillerato  (no se considera)
		9	Magisterio o profesorado (12)
		10	Terciario no universitario  (12)
		11	Universidad o similar (Carrera de grado o Licenciatura) 
		12	Posgrado (diploma, maestría, doctorado) 
pered05_1  AÑOS APROBADOS EN ESE NIVEL	
	1	Sí, tiene años aprobados
	2	No tiene años aprobados
pered05_1_1 numero de años
---------------
pered03_1	 NIVEL MÁS ALTO QUE CURSÓ	
		1	Educación Inicial o Educación Preescolar
		2	Primaria común
		3	Primaria especial
		13	Educación media básica o Ciclo Básico (Liceo o UTU)
		14	Educación media superior o Bachillerato (Liceo o UTU)
		15	Capacitaciones o cursos de UTU que NO acreditan Ciclo Básico NI Bachillerato 
		9	Magisterio o profesorado
		10	Terciario no universitario
		11	Universidad o similar (Carrera de grado o Licenciatura)
		12	Posgrado (diploma, maestría, doctorado)	
pered04	FINALIZÓ ESE NIVEL	
		1	Sí 
		2	No	
PERED05_2 AÑOS APROBADOS EN ESE NIVEL	
		1	Sí, tiene años aprobados
		2	No tiene años aprobados
pered05_2_1 AÑOS APROBADOS EN ESE NIVEL		
*/

	*********
	*aedu_ci*
	*********
	gen byte aedu_ci=.
	replace aedu_ci=0 if pered03==1 | pered03_1==1  //cursando o nivel más alto preescolar (complete o incompleta)
	
	*primaria (1-6 años)
	
		replace aedu_ci=1 if   pered03==2 & pered05_1==1 & pered05_1_1==1
		replace aedu_ci=1 if pered03_1==2 & pered05_2==1 & pered05_2_1==1 	

		replace aedu_ci=2 if   pered03==2 & pered05_1==1 & pered05_1_1==2
		replace aedu_ci=2 if pered03_1==2 & pered05_2==1 & pered05_2_1==2 	

		replace aedu_ci=3 if   pered03==2 & pered05_1==1 & pered05_1_1==3
		replace aedu_ci=3 if pered03_1==2 & pered05_2==1 & pered05_2_1==3 	
		
		replace aedu_ci=4 if   pered03==2 & pered05_1==1 & pered05_1_1==4
		replace aedu_ci=4 if pered03_1==2 & pered05_2==1 & pered05_2_1==4 	
		
		replace aedu_ci=5 if   pered03==2 & pered05_1==1 & pered05_1_1==5
		replace aedu_ci=5 if pered03_1==2 & pered05_2==1 & pered05_2_1==5 		
		
		replace aedu_ci=6 if   pered03==2 & pered05_1==1 & (pered05_1_1>=6 & pered05_1_1<99)     
		replace aedu_ci=6 if pered03_1==2 & pered05_2==1 & (pered05_2_1>=6 & pered05_2_1<99)		
	
	*secundaria o media básica (7-9 años)
	
		replace aedu_ci=7 if   pered03==13 & pered05_1==1 & pered05_1_1==1
		replace aedu_ci=7 if pered03_1==13 & pered05_2==1 & pered05_2_1==1
		
		replace aedu_ci=8 if   pered03==13 & pered05_1==1 & pered05_1_1==2
		replace aedu_ci=8 if pered03_1==13 & pered05_2==1 & pered05_2_1==2

		replace aedu_ci=9 if   pered03==13 & pered05_1==1 & (pered05_1_1>=3 & pered05_1_1<99 )
		replace aedu_ci=9 if pered03_1==13 & pered05_2==1 & (pered05_2_1>=3 & pered05_2_1<99)	

	*secundaria o media superior (10-12 años)
	
		replace aedu_ci=10 if   pered03==14 & pered05_1==1 & pered05_1_1==1
		replace aedu_ci=10 if pered03_1==14 & pered05_2==1 & pered05_2_1==1	
		
		replace aedu_ci=11 if   pered03==14 & pered05_1==1 & pered05_1_1==2
		replace aedu_ci=11 if pered03_1==14 & pered05_2==1 & pered05_2_1==2

		replace aedu_ci=12 if   pered03==14 & pered05_1==1 & pered05_1_1>=3 & pered05_1_1<99 
		replace aedu_ci=12 if pered03_1==14 & pered05_2==1 & pered05_2_1>=3 & pered05_2_1<99	
	
	*Superior no uniersitaria // 	* Se hizo la consulta a EDU/ Olga Dulce y confirmó que Magisterio o profesorado  equivale a superior no universitaria
	
		*Magisterio o profesorado  
		replace aedu_ci=12 if   pered03==9 & pered05_1==1 
		replace aedu_ci=12 if pered03_1==9 & pered05_2==1 	
		*Terciario no universitario 
		replace aedu_ci=12 if   pered03==10 & pered05_1==1 
		replace aedu_ci=12 if pered03_1==10 & pered05_2==1 	
	
	
	*Superior
	tab pered03 pered05_2 if pered03==9 | pered03==11 | pered03==12  //no repórtan  pered05_2. No contestan 
	tab pered03 pered05_2 if pered03==9 | pered03==11 | pered03==12  //no repórtan  pered05_2. No contestan 

		* universitario
		replace aedu_ci=12 + pered05_1_1 if pered03==11 
		replace aedu_ci=12 + pered05_1_1 if pered03_1==11 
		* postgrado
		replace aedu_ci=16 + pered05_1_1 if pered03==12 
		replace aedu_ci=16 + pered05_1_1 if pered03_1==12 
	
	replace aedu_ci=18 if aedu_ci>18
	
	**********
	*eduno_ci*
	**********
	gen byte eduno_ci=(aedu_ci==0) 
	replace eduno_ci=. if aedu_ci==. 

	**********
	*edupi_ci*
	**********
	gen byte edupi_ci=(aedu_ci>=1 & aedu_ci<6) 
	replace edupi_ci=. if aedu_ci==. 

	**********
	*edupc_ci*
	**********
	gen byte edupc_ci=(aedu_ci==6) 
	replace edupc_ci=. if aedu_ci==. 

	**********
	*edusi_ci*
	**********
	gen byte edusi_ci=(aedu_ci>=6 & aedu_ci<=12) 
	replace edusi_ci=. if aedu_ci==. 

	**********
	*edusc_ci*
	**********
	gen byte edusc_ci=(aedu_ci==12) 
	replace edusc_ci=. if aedu_ci==. 

	***********
	*edus1i_ci*
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
	replace edus1i_ci=. if aedu_ci==. 

	***********
	*edus1c_ci*
	***********
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if aedu_ci==. 

	***********
	*edus2i_ci*
	***********
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<12)
	replace edus2i_ci=. if aedu_ci==. 

	***********
	*edus2c_ci*
	***********
	gen byte edus2c_ci=(aedu_ci>=12)
	replace edus2c_ci=. if aedu_ci==. 

	***********
	*edupre_ci*
	***********
	gen byte edupre_ci= .
	
	***********
	*asiste_ci*
	***********
	gen byte asiste_ci=.
	replace asiste_ci=1 if pered00<=3 // Menores de 3 años
	replace asiste_ci=1 if pered01<=2  // Personas de 4 años y mayores
	replace asiste_ci=0 if pered00==4
	replace asiste_ci=0 if pered01==3 | pered01==4
	
	**********
	*literacy*
	**********
	* Aplica para Para personas >= 10 años que nunca asistieron a un centro educativo,
	* que cursan/cursaron Primaria especial o Primaria común con hasta 3 años aprobados.
	gen byte literacy=.
	replace literacy=1 if pered08==1
	replace literacy=0 if pered08==2
		

****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************
/*POBPCOAC
1	Menor de 12 años
2	Ocupados
3	Desocupados propiamente dichos
4	Inactivos, jubilados o pensionistas
5	Inactivos, otras causas */

    *************
    *condocup_ci*
    *************
	*se considera menor de 12 años en la base, mientras que en el manual es 15
    gen byte condocup_ci=.
	replace condocup_ci=1 if pobpcoac==2	//ocupados
	replace condocup_ci=2 if pobpcoac==3	//desocupados	
	replace condocup_ci=3 if pobpcoac==4| pobpcoac==5	//inactivos
	replace condocup_ci=4 if pobpcoac==1	//no responde por ser menor de edad
		
	********
    *emp_ci*
    ********
	gen byte emp_ci=.
	replace emp_ci=(condocup_ci==1) if condocup_ci!=.

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

	**********
    *rama_ci**
    **********
	gen byte rama_ci = . 
	
	**************
    *categopri_ci*
    **************
	gen byte categopri_ci=.
	replace categopri_ci=0 if (peral08==7 |peral08==11) & emp_ci==1
	replace categopri_ci=1 if peral08==4 & emp_ci==1 //patrón
	replace categopri_ci=2 if peral08==5 & emp_ci==1 //Cuenta Propia o independiente
	replace categopri_ci=3 if peral08==1 | emp_ci==2 //Empleado o asalariado
	replace categopri_ci=4 if peral08==6 & emp_ci==1  //Trabajador no remunerado
	 
	*************
    *spublico_ci*
    *************
	gen byte spublico_ci=.	
		
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************		

	* se usa esta variable agregada del ONE para complementar algunas preguntas de vivienda de de pared, techo y piso
	encode materialidad, gen(_materialidad)
	
	/* se usa esta variable 
                       47,266         1  7777
                       12,303         2  8888
                           87         3  9898
                        3,756         4  Materiales de desecho en
                                         paredes o techos
                        3,890         5  Materiales livianos en paredes
                                         y techos y piso no resistente
                      117,702         6  Materiales livianos en paredes
                                         y techos y piso resistente
                          236         7  Materiales pesados en paredes y
                                         techos y piso no resistente
                    1,665,516         8  Materiales pesados en paredes y
                                         techos y piso resistente
                        1,720         9  Materiales pesados en paredes,
                                         techo liviano y piso no
                                         resistente
                    1,168,015        10  Materiales pesados en paredes,
                                         techo liviano y piso resistente
                      351,837        11  NA
                      123,679        12  Otras combinaciones de
                                         materiales
                           58        13  Paredes de barro o adobe, techo
                                         liviano y piso no resistente
                        3,386        14  Paredes de barro o adobe, techo
                                         liviano y piso resistente */

	********
	*luz_ch*
	*******
	destring vivdv07, replace force
	gen byte luz_ch=.
	replace luz_ch=1 if vivdv07<=5
	replace luz_ch=0 if vivdv07==6
	replace luz_ch=. if idh_ch==""
	tab luz_ch
	
	*********
	*piso_ch*
	*********
	destring vivdv03, replace force
	gen byte piso_ch=.
	replace piso_ch = 0 if vivdv03 == 4 | vivdv03 == 3
	replace piso_ch = 1 if vivdv03 == 2   //no permamentes 
	replace piso_ch = 2 if vivdv03 == 1   // permanentes	
	replace piso_ch = 2 if inlist(_materialidad,8,10,14) 
	replace piso_ch=. if idh_ch==""
	tab piso_ch 
	
	**********
	*pared_ch*
	**********
	destring vivdv01, replace force
	gen byte pared_ch=.
	replace pared_ch=1 if inlist(vivdv01, 5, 6,4,9)       //no permamentes 
	replace pared_ch=2 if inlist(vivdv01,1,2,3,8)   // permanentes	
	replace pared_ch=2 if inlist(_materialidad,8,10,7,9) 
	replace pared_ch=. if idh_ch==""
	tab pared_ch

	**********
	*techo_ch*
	**********
	destring vivdv02, replace force
	gen byte techo_ch=.
	replace techo_ch=1 if inlist(vivdv02,5,4)    //no permanentes
	replace techo_ch=2 if inlist(vivdv02,2,7,9,3,10,8)    //permanentes  
	replace techo_ch=2 if inlist(_materialidad,7,8) 
	replace techo_ch=. if idh_ch==""
	tab techo_ch

	**********
	*resid_ch*
	**********
	destring hogrs01, replace force
	gen byte resid_ch=.
	replace resid_ch=0 if inlist(hogrs01,1,2) //servicio de recolección pública o privada
	replace resid_ch=1 if inlist(hogrs01,3,4)  //Servicio de quemados o enterrados
	replace resid_ch=2 if inlist(hogrs01,5,6)  //Servicio de tirado a un espacio abierto
	replace resid_ch=3 if hogrs01 ==7  //Otro método
	replace resid_ch=. if idh_ch==""
	tab resid_ch

	*********
	*dorm_ch*
	*********
	destring hoghd01, replace force
	gen byte dorm_ch=hoghd01
	replace dorm_ch=. if inlist(hoghd01,8888,9898)
	replace dorm_ch=. if idh_ch==""
	tab dorm_ch
	*revisar br if dorm_ch >20

	************
	*cuartos_ch*
	************
	destring hoghd00, replace force
	gen byte cuartos_ch=hoghd00
	replace cuartos_ch =. if inlist(hoghd00,8888,9898)
	replace cuartos_ch=. if idh_ch==""

	***********
	*cocina_ch*
	***********
	gen byte cocina_ch=.
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch=.
	
	***********
	*refrig_ch*
	***********
	destring hogce03, replace force
	gen byte refrig_ch=.
	replace refrig_ch=1 if hogce03==1
	replace refrig_ch=0 if hogce03==2
	replace refrig_ch=. if idh_ch==""
	
	*********
	*auto_ch*
	*********
	destring hogce13, replace force
	gen byte auto_ch=.
	replace auto_ch=1 if hogce13>=1
	replace auto_ch=0 if hogce13==0
	replace auto_ch=. if inlist(hogce13,99,8888,9898)
	replace auto_ch=. if idh_ch==""

	**********
	*compu_ch*
	**********
	*no se puede distinguir pues la pregunta agrupa computadora, notebook, tablet, etc
	gen byte compu_ch=.

	*************
	*internet_ch*
	************* 
	destring hogce11, replace force
	gen byte internet_ch=.
	replace internet_ch=1 if hogce11==1
	replace internet_ch=0 if hogce11==2
	tab internet_ch
	replace internet_ch=. if idh_ch==""

	********
	*cel_ch*
	********
	gen byte cel_ch=.

	*************
	*viviprop_ch*
	*************
	*se asume que "integrante de una cooperativa de vivienda (incluye copperativas de propietarios y de usuarios) No pertenece a a los habitantes del hogar"
	destring hogte01, replace force
	gen byte viviprop_ch=.
	replace viviprop_ch=1 if hogte01 ==1 
	replace viviprop_ch=0 if inlist(hogte01,2,3,4)
	replace viviprop_ch=. if idh_ch==""

***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	*****************
	*aguaentubada_ch*
	*****************
	destring vivdv06, replace force
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch= 1 if inlist(vivdv06,1,2,3)
	replace aguaentubada_ch= 0 if vivdv06==4
	replace aguaentubada_ch=. if idh_ch==""
	tab aguaentubada_ch
	
	************
	*aguared_ch*
	************
	destring vivdv05, replace force
	gen byte aguared_ch=.
	replace aguared_ch=1 if vivdv05==1
	replace aguared_ch=0 if vivdv05>1&vivdv05<=7
	replace aguared_ch=. if idh_ch==""
	tab aguared_ch

    ***************
	*aguafuente_ch*
	***************
 	gen byte aguafuente_ch=.
	replace aguafuente_ch=2 if vivdv05==1	
	replace aguafuente_ch=4 if vivdv05==2
	replace aguafuente_ch=8 if vivdv05==6
	replace aguafuente_ch=10 if  inlist(vivdv05,3,4,5,7)
	replace aguafuente_c=. if idh_ch==""

	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch=0
	replace aguadist_ch=1 if vivdv05==1	
	replace aguadist_ch=2 if vivdv05==2	
	replace aguadist_ch=3 if vivdv05==3
	replace aguadist_ch=. if idh_ch==""
	          
	**************
	*aguadisp1_ch*
	**************
	gen byte aguadisp1_ch = .
		
	**************
	*aguadisp2_ch*
	**************
	gen byte aguadisp2_ch = .
	
	*************
	*aguamide_ch*
	*************
	gen byte aguamide_ch = .
	
	*********
	*bano_ch*
	*********
	destring hogsh01 hogsh03, replace force
	gen byte bano_ch = . 
	replace bano_ch = 0 if hogsh01==3 
	replace bano_ch = 1 if (hogsh01==1 |hogsh01==2) & hogsh03==1 
	replace bano_ch = 2 if (hogsh01==1 |hogsh01==2) & hogsh03==2
	replace bano_ch = 4 if (hogsh01==1 |hogsh01==2) & (hogsh03==3| hogsh03==4)
	replace bano_ch=. if idh_ch==""
	
	***********
	*banoex_ch*
	***********
	destring hogsh02, replace force
	gen byte banoex_ch = .
	replace banoex_ch = 1 if hogsh02 ==1 
	replace banoex_ch = 0 if hogsh02 ==2
	replace banoex_ch=. if idh_ch==""
	
	************
	*sinbano_ch*
	************
	gen byte sinbano_ch =.

	*********
	*conbano_ch*
	*********
	gen byte conbano_ch=.
	
	***********************
	*banoalcantarillado_ch*
	***********************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch=1 if hogsh03 ==1
	replace banoalcantarillado_ch=0 if inlist(hogsh03,2,3,4)
	replace banoalcantarillado_ch=. if idh_ch==""
		
	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	replace des1_ch=0 if hogsh01==3 
	replace des1_ch=1 if (hogsh01==1 |hogsh01==2) & hogsh03==1
	replace des1_ch=2 if (hogsh01==1 |hogsh01==2) & inlist(hogsh03,2,3,4)
	replace des1_ch=. if idh_ch==""

	
*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	clonevar URY_m_pared_ch= vivdv01
	label var URY_m_pared_ch  "Material de las paredes según el censo del país - variable original"
	label def URY_m_pared_ch  1 "Ladrillos, ticholos, piedras o bloques CON terminación" 2 "Ladrillos, ticholos, piedras o bloques SIN terminación" 3 "Materiales livianos (madera o chapa) CON revestimiento" 4 "Materiales livianos (madera o chapa) SIN revestimiento" 8 "Sistema constructivo no tradicional de tipo construcción en seco (isopanel, steel frame, wood frame, etc) CON terminación" 9 "Sistema constructivo no tradicional de tipo construcción en seco (isopanel, steel frame, wood frame, etc) SIN terminación" 5 "Barro (terrón, adobe o fajina)" 6 "Materiales de desecho" 7 "Otro material"  8888 "No relevado" 9898 "Ignorado" //categorías originales del país
	label val URY_m_pared_ch  URY_m_pared_ch 
	replace URY_m_pared_ch=. if idh_ch==""


	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	clonevar URY_m_piso_ch= vivdv03 
	label var URY_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	label def URY_m_piso_ch  1 "Cerámica, baldosas, piedra laja, madera, moqueta, linóleo, vinílico" 2 "Arena y portland" 3 "Sólo contrapiso sin piso" 4 "Tierra sin piso ni contrapiso" 5 "Otro material" 6 "No relevado" 7 "Ignorado"  8888 "No relevado" 9898 "Ignorado" //categorías originales del país
	label val URY_m_piso_ch  URY_m_piso_ch 
	replace URY_m_piso_ch=. if idh_ch==""

	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	clonevar URY_m_techo_ch= vivdv02 
	label var URY_m_techo_ch  "Material del techo según el censo del país - variable original"
	label def URY_m_techo_ch  7 "Planchada de hormigón  o bovedilla CON protección (tejas u otros)" 8 "Planchada de hormigón o bovedilla SIN protección" 2 "Liviano CON cielo raso"  3 "Liviano SIN cielo raso" 9 "Sistema constructivo no tradicional (isopanel, techo verde, steel frame) CON cielo raso" 10 "Sistema constructivo no tradicional (isopanel, techo verde, steel frame) SIN cielo raso" 4 "Quincha"  5 "Materiales de desecho" 6 "Otro material" 8888 "No relevado" 9898 "Ignorado" //categorías originales del país
	label val URY_m_techo_ch URY_m_techo_ch 
	replace URY_m_techo_ch=. if idh_ch==""

	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long URY_ingreso_ci = .
	label var URY_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long URY_ingresolab_ci = .	
	label var URY_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte URY_dis_ci = dis_ci
	label var URY_dis_ci  "Individuos con discapacidad según el censo del país - variable original"
	label def URY_dis_ci 1 "Sí" 0 "No"   //categorías originales del país
	label val URY_dis_ci URY_dis_ci
 

/*******************************************************************************
   III. Incluir variables externas
*******************************************************************************/
capture drop _merge
merge m:1 pais_c anio_c using "Z:/general_documentation/data_externa/poverty/International_Poverty_Lines/5_International_Poverty_Lines_LAC_long_PPP17.dta", keepusing (tc_wdi ppp_wdi ppp_2017 cpi cpi2017 cpi_2017 lp365_2017 lp685_2017 lp14_2017 lp81_2017 )
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
   IV. Revisión de que se hayan creado todas las variables
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
* En "..." agregar la lista de variables de ID originales (por ejemplo los ID de personas, vivienda y hogar)

keep  $lista_variables id_censo direccion_id departamento localidad vivid hogid


* selecciona las 3 lineas y ejecuta (do). Deben quedar 108 variables de las secciones II y III más las 
* variables originales de ID que hayas mantenido
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