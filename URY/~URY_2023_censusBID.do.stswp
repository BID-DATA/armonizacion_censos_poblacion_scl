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
		

