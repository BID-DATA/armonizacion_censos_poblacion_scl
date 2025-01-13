* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: PERÚ
Año: 2017
Autores: Cesar Lins
Última versión: 30OCT2021
División: SCL/SCL - IADB
*******************************************************************************

********

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
global PAIS PER    				 //cambiar
global ANIO 2017   				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using `"$log_file"', replace  //agregar ,replace si ya está creado el log_file en tu carpeta

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
	gen byte region_BID_c = 3

	**********
	*region_c*   
	**********
	gen region_c=ccdd
	label define region_c ///
	1"Amazonas"	          ///
	2"Ancash"	          ///
	3"Apurimac"	          ///
	4"Arequipa"	          ///
	5"Ayacucho"	          ///
	6"Cajamarca"	      ///
	7"Callao"	          ///
	8"Cusco"	          ///
	9"Huancavelica"	      ///
	10"Huanuco"	          ///
	11"Ica"	              ///
	12"Junin"	          ///
	13"La libertad"	      ///
	14"Lambayeque"	      ///
	15"Lima"	          ///
	16"Loreto"	          ///
	17"Madre de Dios"	  ///
	18"Moquegua"	      ///
	19"Pasco"	          ///
	20"Piura"	          ///
	21"Puno"	          ///
	22"San Martín"	      ///
	23"Tacna"	          ///
	24"Tumbes"	          ///
	25"Ucayali"	

	*********
	*geolev1*
	*********
	destring ccdd, replace
	gen geolev1=.
	replace geolev1 = 604001 if ccdd ==1
	replace geolev1 = 604002 if ccdd ==2
	replace geolev1 = 604003 if ccdd ==3
	replace geolev1 = 604004 if ccdd ==4
	replace geolev1 = 604005 if ccdd ==5
	replace geolev1 = 604006 if ccdd ==6
	replace geolev1 = 604007 if ccdd ==7
	replace geolev1 = 604008 if ccdd ==8
	replace geolev1 = 604009 if ccdd ==9
	replace geolev1 = 604010 if ccdd ==10
	replace geolev1 = 604011 if ccdd ==11
	replace geolev1 = 604012 if ccdd ==12
	replace geolev1 = 604013 if ccdd ==13
	replace geolev1 = 604014 if ccdd ==14
	replace geolev1 = 604015 if ccdd ==15
	replace geolev1 = 604016 if ccdd ==16
	replace geolev1 = 604017 if ccdd ==17
	replace geolev1 = 604018 if ccdd ==18
	replace geolev1 = 604019 if ccdd ==19
	replace geolev1 = 604020 if ccdd ==20
	replace geolev1 = 604021 if ccdd ==21
	replace geolev1 = 604022 if ccdd ==22
	replace geolev1 = 604023 if ccdd ==23
	replace geolev1 = 604024 if ccdd ==24
	replace geolev1 = 604025 if ccdd ==25

	label define geolev1 604001 "Amazonas" 604002 "Ancash" 604003 "Apurímac" 604004 "Arequipa" 604005	"Ayacucho" 604006	"Cajamarca" 604007	"Callao" 604008	"Cusco" 604009	"Huancavelica" 604010	"Huanuco" 604011	"Ica" 604012	"Junin" 604013	"La Libertad" 604014	"Lambayeque" 604015	"Lima" 604016	"Loreto" 604017	"Madre de Dios" 604018	"Moquegua" 604019	"Pasco" 604020	"Piura" 604021	"Puno" 604022	"San Martin" 604023	"Tacna" 604024	"Tumbes" 604025	"Ucayali"
	label value geolev1 geolev1

    *********
	*pais_c*
	*********
	gen str3 pais_c = "PER"

    *********
	*anio_c*
	*********
	gen int anio_c = 2017

    ******************
    *idh_ch (id hogar)*
    ******************
	clonevar idh_ch = id_hog_imp_f
	tostring idh_ch, replace format("%16.0f")

	******************
    *idp_ci (idpersonas)*
    ******************
	clonevar idp_ci = id_pob_imp_f
	tostring idp_ci, replace format("%16.0f")

	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
	gen factor_ci=rk_final
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
	gen factor_ch=1
		
    ***********
	* upm     *
	***********
	gen byte upm=.
	
	***********
	* estrato *
	***********
	gen byte estrato_ci=.

    ***************************
	* Zona urbana (1) o rural (0)
	***************************
	gen byte zona_c=.
	replace zona_c=1 if encarea==1
	replace zona_c=0 if encarea==2
	
	
************************************
*** 2. Demografía (18 variables) ***
************************************

    *********
	*sexo_c*
	*********
	gen byte sexo_ci = c5_p2  

	*********
	*edad_c*
	*********
	gen byte edad_ci= c5_p4_1 

	*************
	*relacion_ci*
	*************
	gen byte relacion_ci=c5_p1
	replace relacion_ci=4 if c5_p1==5 | c5_p1==6 | c5_p1==7 | c5_p1==8
	replace relacion_ci=6 if c5_p1==9 | c5_p1==10
	replace relacion_ci=5 if c5_p1==11

	**********
	*civil_ci*
	**********
	gen	byte civil_ci=.
	replace civil_ci=1 if c5_p24==6
	replace civil_ci=2 if c5_p24==1 | c5_p24==3
	replace civil_ci=3 if c5_p24==2 | c5_p24==5
	replace civil_ci=4 if c5_p24==4
	
    *********
	*jefe_ci*
	*********
	gen byte jefe_ci=(c5_p1==1)
	
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
	
	*************
	*clasehog_ch*
	*************
	gen byte clasehog_ch=0
	**** unipersonal
	replace clasehog_ch=1 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch==0
	**** nuclear (child with or without spouse but without other relatives)
	replace clasehog_ch=2 if nhijos_ch>0 & notropari_ch==0 & notronopari_ch==0
	**** nuclear (spouse with or without children but without other relatives)
	replace clasehog_ch=2 if nhijos_ch==0 & nconyuges_ch>0 & notropari_ch==0 & notronopari_ch==0
	**** ampliado
	replace clasehog_ch=3 if notropari_ch>0 & notronopari_ch==0
	**** compuesto (some relatives plus non relative)
	replace clasehog_ch=4 if ((nconyuges_ch>0 | nhijos_ch>0 | notropari_ch>0) & (notronopari_ch>0))
	**** corresidente
	replace clasehog_ch=5 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch>0
	
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
	gen byte afroind_ci=. 
	replace afroind_ci=1 if c5_p25==1 | c5_p25==2 | c5_p25==3 | c5_p25==4
	replace afroind_ci=2 if c5_p25==5
	replace afroind_ci=3 if c5_p25==6 | c5_p25==7 | c5_p25==8

	*********
	*afro_ch*
	*********
	gen byte afro_ch =.

	********
	*ind_ch*
	********	
	gen byte ind_ch =.

	**************
	*noafroind_ch*
	**************
	gen byte noafroind_ch =.
	
	***************
	***afroind_ch***
	***************
    gen byte afroind_jefe= afroind_ci if jefe_ci==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 	
	drop afroind_jefe 

	*******************
	***dis_ci***
	*******************
	gen byte dis_ci=. 
	replace dis_ci=1 if c5_p9_1==1 | c5_p9_2==1 | c5_p9_3==1 |c5_p9_4==1 | c5_p9_5==1 | c5_p9_6==1
	replace dis_ci=0 if c5_p9_1==0  & c5_p9_2==0 & c5_p9_3==0 & c5_p9_4==0 & c5_p9_5==0 & c5_p9_6==0
	replace dis_ci=0 if c5_p9_7==1

	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	
	************
	***dis_ch***
	************
	egen  byte dis_ch  = sum(dis_ci), by(idh_ch) 
	replace dis_ch=1 if dis_ch>=1 & dis_ch!=.

	
**********************************
*** 4. Migración (3 variables) ***
**********************************	

    *******************
    ****migrante_ci****
    *******************
	gen byte migrante_ci =.  
		
	*******************
    **migrantiguo5_ci**
    *******************
	gen byte migrantiguo5_ci =.
	
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
	gen byte aedu_ci = .
	replace aedu_ci = 0 if c5_p13_niv == 1 | c5_p13_niv ==2
	replace aedu_ci = 1 if (c5_p13_niv == 3 & c5_p13_gra ==1) | (c5_p13_niv == 3 & c5_p13_anio_pri ==1)
	replace aedu_ci = 2 if (c5_p13_niv == 3 & c5_p13_gra ==2) | (c5_p13_niv == 3 & c5_p13_anio_pri ==2)
	replace aedu_ci = 3 if (c5_p13_niv == 3 & c5_p13_gra ==3) | (c5_p13_niv == 3 & c5_p13_anio_pri ==3)
	replace aedu_ci = 4 if (c5_p13_niv == 3 & c5_p13_gra ==4) | (c5_p13_niv == 3 & c5_p13_anio_pri ==4)
	replace aedu_ci = 5 if (c5_p13_niv == 3 & c5_p13_gra ==5) | (c5_p13_niv == 3 & c5_p13_anio_pri ==5)
	replace aedu_ci = 6 if (c5_p13_niv == 3 & c5_p13_gra ==6) | (c5_p13_niv == 3 & c5_p13_anio_pri ==6)
	replace aedu_ci = 7 if (c5_p13_niv == 4 & c5_p13_gra ==1) | (c5_p13_niv == 4 & c5_p13_anio_sec ==1)
	replace aedu_ci = 8 if (c5_p13_niv == 4 & c5_p13_gra ==2) | (c5_p13_niv == 4 & c5_p13_anio_sec ==2)
	replace aedu_ci = 9 if (c5_p13_niv == 4 & c5_p13_gra ==3) | (c5_p13_niv == 4 & c5_p13_anio_sec ==3)
	replace aedu_ci = 10 if (c5_p13_niv == 4 & c5_p13_gra ==4) | (c5_p13_niv == 4 & c5_p13_anio_sec ==4)
	replace aedu_ci = 11 if (c5_p13_niv == 4 & c5_p13_gra ==5) | (c5_p13_niv == 4 & c5_p13_anio_sec ==5)
	replace aedu_ci = 12 if (c5_p13_niv == 4 & c5_p13_gra ==6) | (c5_p13_niv == 4 & c5_p13_anio_sec ==6)
	replace aedu_ci = 13 if c5_p13_niv ==7 | c5_p13_niv== 8 | c5_p13_niv == 9 | c5_p13_niv == 10 


	**************
	***eduno_ci***
	**************
	gen byte eduno_ci=(aedu_ci==0) // never attended or pre-school
	replace eduno_ci=. if aedu_ci==. // NIU & missing

	**************
	***edupi_ci***
	**************
	gen byte edupi_ci=(aedu_ci>0 & aedu_ci<6) //
	replace edupi_ci=. if aedu_ci==. // NIU & missing

	**************
	***edupc_ci***
	**************
	gen byte edupc_ci=(aedu_ci==6) 
	replace edupc_ci=. if aedu_ci==. // NIU & missing

	**************
	***edusi_ci***
	**************
	gen byte edusi_ci=(aedu_ci>=7 & aedu_ci<11) // 7 a 10 anos de educación
	replace edusi_ci=. if aedu_ci==. // NIU & missing

	**************
	***edusc_ci***
	**************
	gen byte edusc_ci=(aedu_ci>=11) // 11 anos de educación
	replace edusc_ci=. if aedu_ci==. // NIU & missing

	***************
	***edus1i_ci***
	***************
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
	replace edus1i_ci=. if aedu_ci==. // missing a los NIU & missing

	***************
	***edus1c_ci***
	***************
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if aedu_ci==. // missing a los NIU & missing

	***************
	***edus2i_ci***
	***************
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<11)
	replace edus2i_ci=. if aedu_ci==. // missing a los NIU & missing

	***************
	***edus2c_ci***
	***************
	gen byte edus2c_ci=(aedu_ci>=11)
	replace edus2c_ci=. if aedu_ci==. // missing a los NIU & missing

	***************
	***edupre_ci***
	***************
	gen byte edupre_ci=(c5_p13_niv==2)
	replace edupre_ci=. if aedu_ci==.
	*label variable edupre_ci "Educacion preescolar"

	***************
	***asiste_ci***
	***************
	gen byte asiste_ci=.
	replace asiste_ci=1 if c5_p14==1
	replace asiste_ci=0 if c5_p14==2
	*label variable asiste_ci "Asiste actualmente a la escuela"

	**************
	***literacy***
	**************
	gen byte literacy=. 
	replace literacy=1 if c5_p12 == 1
	replace literacy=0 if c5_p12 == 2

****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

    *******************
    ****condocup_ci****
    *******************
	gen byte condocup_ci=.
	replace condocup_ci=1 if (c5_p17 >=1 & c5_p17<=5)|c5_p16==1 // trabajó
	replace condocup_ci=2 if (c5_p17==7|c5_p17==6|c5_p16==2)&c5_p18==1 // no trabajó y buscó
	replace condocup_ci=3 if (c5_p17==7|c5_p17==6|c5_p16==2)&c5_p18==2 // no trabajó y no buscó
	replace condocup_ci=4 if edad_ci <15     
	
	************
    ***emp_ci***
    ************
    gen byte emp_ci=.
	replace emp_ci=1 if c5_p17>=1 & c5_p17<=6
	replace emp_ci=0 if c5_p17==7
	
	****************
    ***desemp_ci***
    ****************	
	gen byte desemp_ci=.
	replace desemp_ci=1 if c5_p17==7 & c5_p18==1
	replace desemp_ci=0 if c5_p17<7 | c5_p18==2
	
	*************
    ***pea_ci***
    *************
    gen byte pea_ci=.
	replace pea_ci=1 if condocup_ci==1
	replace pea_ci=1 if condocup_ci==2
	replace pea_ci=0 if condocup_ci==3
	replace pea_ci=0 if condocup_ci==4

	**********
    *rama_ci**
    **********
    gen byte rama_ci = .
	destring c5_p19_cod, replace
	replace rama_ci= 1 if c5_p19_cod>=111 & c5_p19_cod<=500
	replace rama_ci = 2 if c5_p19_cod>=1010 & c5_p19_cod<=1429
	replace rama_ci = 3 if c5_p19_cod>=1511 & c5_p19_cod <= 3700
	replace rama_ci = 4 if c5_p19_cod>=4010 & c5_p19_cod<=4100
	replace rama_ci = 5 if c5_p19_cod>=4510 & c5_p19_cod<=4550
	replace rama_ci = 6 if c5_p19_cod>=5010 & c5_p19_cod<=5260
	replace rama_ci = 7 if c5_p19_cod>=5510 & c5_p19_cod<=5220 
	replace rama_ci = 8 if c5_p19_cod>=6010 & c5_p19_cod<= 6420
	replace rama_ci = 9 if c5_p19_cod>=6511 & c5_p19_cod <= 6720
	replace rama_ci = 11 if c5_p19_cod>=7010 & c5_p19_cod <= 7499
	replace rama_ci = 10 if c5_p19_cod>=7511 & c5_p19_cod<=7530
	replace rama_ci = 12 if c5_p19_cod>=8010 & c5_p19_cod<=8090
	replace rama_ci = 13 if c5_p19_cod>=8511 & c5_p19_cod>=8532
	replace rama_ci = 14 if c5_p19_cod>=9000 & c5_p19_cod>=9309
	replace rama_ci = 15 if c5_p19_cod==9500
	
	*********************
    ****categopri_ci****
    *********************
	*OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.
	 gen byte categopri_ci=.
	 replace categopri_ci=1 if c5_p21==1
	 replace categopri_ci=2 if c5_p21==2
	 replace categopri_ci=3 if c5_p21==3 |c5_p21==4 |c5_p21==5 | c5_p21==6
	 replace categopri_ci=4 if emp_ci==1 & c5_p16==2
	  
	*****************
    ***spublico_ci***
    *****************
    gen byte spublico_ci=.
	replace spublico_ci=1 if emp_ci==1 & rama_ci ==10
	replace spublico_ci=0 if emp_ci==1 & rama_ci ~=10

**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************	

	********
	*luz_ch*
	********
	*En la nueva encuesta no se encontro si se pregunta por instalacion electrica
	gen byte luz_ch=.
	replace luz_ch=1 if c2_p11 ==1 
	replace luz_ch=0 if c2_p11 ==2
		
	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
	replace piso_ch = 0 if c2_p5 == 6
	replace piso_ch = 1 if c2_p5 == 2 | c2_p5 ==3
	replace piso_ch = 2 if c2_p5  == 5 | c2_p5 == 4 | c2_p5==1
	
	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	replace pared_ch=2 if c2_p3 == 1 | c2_p3==2 | c2_p3 ==3 | c2_p3 ==4
	replace pared_ch=1 if c2_p3 >=5 & c2_p3 <=8
	
	**********
	*techo_ch*
	**********
	gen byte techo_ch=.
	replace techo_ch=2 if c2_p5 ==1 | c2_p5 == 2 | c2_p5 == 5 | c2_p5==6
	replace techo_ch=1 if c2_p5 ==2 | c2_p5 == 3 | c2_p5 == 4
	
	**********
	*resid_ch*
	**********
	* Peru no tiene está variable se genera en missing
	gen byte resid_ch=. 

	*********
	*dorm_ch*
	*********
	* Peru no tiene está variable se genera en missing
	gen byte dorm_ch=.
	
	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=c2_p12
	replace cuartos_ch=. if c2_p12==99
	
	***********
	*cocina_ch*
	***********
	* Peru no tiene está variable se genera en missing
	gen byte cocina_ch=.
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch=c3_p2_11
	replace telef_ch=0 if c3_p2_11==2
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=c3_p2_4
	replace refrig_ch=0 if c3_p2_4==2
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=c3_p2_14
	replace auto_ch = 0 if c3_p2_14==2
	
	********
	*compu_ch*
	********
	gen byte compu_ch=c3_p2_9
	replace compu_ch =0 if c3_p2_9==2
	
	*************
	*internet_ch*
	************* 
	gen byte internet_ch=c3_p2_13
	replace internet_ch=0 if c3_p2_13==2
	
	********
	*cel_ch*
	********
	gen byte cel_ch=c3_p2_10
	replace cel_ch=0 if c3_p2_10==2
	
	*************
	*viviprop_ch*
	*************
	*NOTA: aqui se genera una variable parecida, pues no se puede saber si es propia total o parcialmente pagada
	gen byte viviprop_ch=.
	replace viviprop_ch=1 if c2_p13 == 2 | c2_p13 == 3 
	replace viviprop_ch=0 if c2_p13 ==1 | c2_p13 == 4
	
	
***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	
	/* Nota: 
El censo no da la opcion de "no tiene" en cuanto a las instalaciones sanitarias
*/
	*****************
	*aguaentubada_ch*
	*****************
	* se crea conforme las tablas de armonización IPUMS
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch=1 if c2_p6 == 1 | c2_p6 == 2 | c2_p6 == 3
	replace aguaentubada_ch=0 if c2_p6>3 & c2_p6<9
		
	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch = 1 if inlist(c2_p6, 1,2)
	replace aguared_ch = 0 if inlist(c2_p6,3,4,5,6,8)
	
    ***************
	*aguafuente_ch*
	***************
	gen byte aguafuente_ch=.
	replace aguafuente_ch = 1 if inlist(c2_p6, 1,2)
	replace aguafuente_ch = 2 if c2_p6 ==3
	replace aguafuente_ch = 6 if c2_p6 ==4
	replace aguafuente_ch = 8 if inlist(c2_p6, 7)
	replace aguafuente_ch = 10 if inlist(c2_p6, 6,7,8)
		
	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch=.
	replace aguadist_ch = 1 if inlist(c2_p6, 1)
	replace aguadist_ch = 2 if inlist(c2_p6, 2)
	replace aguadist_ch = 3 if inlist(c2_p6, 3)
	replace aguadist_ch = 0 if inlist(c2_p6, 4,5,6,7,8)
	
	**************
	*aguadisp1_ch*
	**************
	gen byte aguadisp1_ch =9 

	**************
	*aguadisp2_ch*
	**************
	gen byte aguadisp2_ch =.
/*		replace aguadisp2_ch = 1 if c2_p7a <12 | (c2_p7c < 12 | c2_p7b<4)
	replace aguadisp2_ch = 2 if (c2_p7a >=12 & c2_p7a<24) | (c2_p7c >= 12 & c2_p7b>=4)
	replace aguadisp2_ch = 3 if c2_p7 ==1 & c2_p7a == 24
*/
	*************
	*aguamide_ch*
	*************
	gen byte aguamide_ch =9
	
	*********
	*bano_ch*
	*********
	gen byte bano_ch = . 
	replace bano_ch = 1 if inlist(c2_p10,1,2)
	replace bano_ch = 2 if c2_p10 == 3
	replace bano_ch = 4 if inlist(c2_p10, 6,7) 
	replace bano_ch = 6 if inlist(c2_p10, 4,5,8)
	
	***********
	*banoex_ch*
	***********
	gen byte banoex_ch =9

	************
	*sinbano_ch*
	************
	gen byte sinbano_ch =.

	*********
	*conbano_ch*
	*********
	gen byte conbano_ch=.
	replace conbano_ch=1 if c2_p10
	replace conbano_ch=1 if c2_p10 >= 1 & c2_p10 <= 4
	replace conbano_ch=0 if c2_p10>4
	
	*****************
	*banoalcantarillado_ch_ch*
	*****************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch=1 if c2_p10 >= 1 & c2_p10 < 4
	replace banoalcantarillado_ch=0 if c2_p10>=4

	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	replace des1_ch=0 if bano_ch ==0
	replace des1_ch=1 if c2_p10 == 3
	replace des1_ch=2 if c2_p10 >=4 & c2_p10<9


*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte PER_m_pared_ch= c2_p3 
	label var PER_m_pared_ch  "Material de las paredes según el censo del país - variable original"

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte PER_m_piso_ch= c2_p5 
	label var PER_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte PER_m_techo_ch= c2_p5
	label var PER_m_techo_ch  "Material del techo según el censo del país - variable original"

	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long PER_ingreso_ci = .
	label var PER_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long PER_ingresolab_ci = .	
	label var PER_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte PER_dis_ci = .
	label var PER_dis_ci  "Individuos con discapacidad según el censo del país - variable original"
   
 
/*******************************************************************************
   III. Incluir variables externas
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
   IV. Revisión de que se hayan creado todas las variables
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
   V. Borrar variables originales con exepción de los identificadores 
*******************************************************************************/
* En "..." agregar la lista de variables de ID originales (por ejemplo los ID de personas, vivienda y hogar)

keep  $lista_variables id_hog_imp_f id_pob_imp_f

* selecciona las 3 lineas y ejecuta (do). Deben quedar 105 variables de las secciones II y III más las 
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
