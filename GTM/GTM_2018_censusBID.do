* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: GUATEMALA
Año: 2018
Autores: Eric Torres
Última versión: 30JUN2022
División: SCL/LMK - IADB
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
global PAIS GTM    				 //cambiar
global ANIO 2018  				 //cambiar

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
	gen byte region_BID_c = 1

	****************
	*** region_c ***
	****************
    gen region_c=departamento
	label define region_c 1 "Guatemala" 2 "El Progreso" 3 "Sacatepéquez" 4 "Chimaltenango" 5 "Escuintla" 6 "Santa Rosa" 7 "Sololá" 8 "Totonicapán" 9 "Quetzaltenango" 10 "Suchitepéquez" 11 "Retalhuleu" 12 "San Marcos" 13 "Huehuetenango" 14 "Quiché" 15 "Baja Verapaz" 16 "Alta Verapaz" 17 "Petén" 18 "	Izabal" 19 "Zacapa" 20 "Chiquimula" 21 "Jalapa" 22 "Jutiapa"
	label value region_c region_c
	
	*********
	*geolev1*
	*********
	gen long geolev1 =.
	replace geolev1=320001 if departamento==1 /*Guatemala*/
	replace geolev1=320002 if departamento==2 /*El Progreso*/
	replace geolev1=320003 if departamento==3 /*Sacatepéquez*/
	replace geolev1=320004 if departamento==4 /*Chimaltenango*/
	replace geolev1=320005 if departamento==5 /*Escuintla*/
	replace geolev1=320006 if departamento==6 /*Santa Rosa*/
	replace geolev1=320007 if departamento==7 /*Sololá*/
	replace geolev1=320008 if departamento==8 /*Totonicapán*/
	replace geolev1=320009 if departamento==9 /*Quetzaltenango*/
	replace geolev1=320010 if departamento==10 /*Suchitepéquez*/
	replace geolev1=320011 if departamento==11 /*Retalhuleu*/
	replace geolev1=320012 if departamento==12 /*San Marcos*/
	replace geolev1=320013 if departamento==13 /*Huehuetenango*/
	replace geolev1=320014 if departamento==14 /*Quiché*/
	replace geolev1=320015 if departamento==15 /*Baja Verapaz*/
	replace geolev1=320016 if departamento==16 /*Alta Verapaz*/
	replace geolev1=320017 if departamento==17 /*Petén*/
	replace geolev1=320018 if departamento==18 /*Izabal*/
	replace geolev1=320019 if departamento==19 /*Zacapa*/
	replace geolev1=320020 if departamento==20 /*Chiquimula*/
	replace geolev1=320021 if departamento==21 /*Jalapa*/
	replace geolev1=320022 if departamento==22 /*Jutiapa*/

    *********
	*pais_c*
	*********
	gen pais_c = "GTM"

    *********
	*anio_c*
	*********
	gen anio_c = 2018

    ******************
    *idh_ch (id hogar)*
    ******************
	gen str14 idh_ch = string(num_vivienda,"%02.0f") + string(num_hogar,"%02.0f") 

	******************
    *idp_ci (idpersonas)*
    ******************
	egen idp_ci = concat(idh_ch pcp1)

	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
	gen byte factor_ci=.
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
	gen byte factor_ch=.

    ***********
	* estrato *
	***********
	gen byte estrato_ci=.

    ********
	* upm  *
	********
	gen byte upm=.
	
    ********
	*zona_c*
	********
	gen byte zona_c=.
	replace zona_c=1 if area==1
	replace zona_c=0 if area==2
		
************************************
*** 2. Demografía (18 variables) ***
************************************

    *********
	*sexo_c *
	*********
	gen byte sexo_ci = pcp6  

	*********
	*edad_c *
	*********
	gen int edad_ci =pcp7 

	*************
	*relacion_ci*
	*************
	*considero hijastro como hijo y no como otro pariente
	gen byte relacion_ci=pcp5
	replace relacion_ci=3 if pcp5==4
	replace relacion_ci=4 if pcp5==5 | pcp5==6 | pcp5==7 | pcp5==8 | pcp5==9 | pcp5==10 | pcp5==11
	replace relacion_ci=5 if pcp5==13 | pcp5==14 | pcp5==15
	replace relacion_ci=6 if pcp5==12

	**********
	*civil_ci*
	**********
	gen	byte civil_ci=pcp34
	replace civil_ci=2 if pcp34==3
	replace civil_ci=3 if pcp34==4 | pcp34==5 | pcp34==6
	replace civil_ci=4 if pcp34==7

    *********
	*jefe_ci*
	*********
	gen byte jefe_ci=(pcp5==1)
	
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
	replace afroind_ci=1 if pcp12==1 | pcp12==2 | pcp12==3 
	replace afroind_ci=2 if pcp12==4
	replace afroind_ci=3 if pcp12==5 | pcp12==6 

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
	/*	
	No, sin dificultad ..................1
	Sí, con algo de dificultad ......... 2
	Sí, con mucha dificultad ........... 3
	No puede ............................4
	*/
	gen dis_ci=.
	replace dis_ci=1 if inrange(pcp16_a,2,4) | inrange(pcp16_b,2,4) | inrange(pcp16_c,2,4) | inrange(pcp16_d,2,4) | inrange(pcp16_e,2,4) | inrange(pcp16_f,2,4)
	replace dis_ci=0 if pcp16_a==1 & pcp16_b==1 & pcp16_c==1 & pcp16_d==1 & pcp16_e==1 & pcp16_f==1

						
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	
	*******************
	***dis_ch***
	*******************
	egen byte dis_ch  = sum(dis_ci), by(idh_ch) 
	replace dis_ch=1 if dis_ch>=1 & dis_ch!=.

**********************************
*** 4. Migración (3 variables) ***
**********************************

    *******************
    ****migrante_ci****
    *******************
	gen byte migrante_ci = 0
	replace migrante_ci=1 if migra_vida==1 | migra_rec==1
		
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
	gen byte aedu_ci =aneduca

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
	gen byte edusi_ci=(aedu_ci>6 & aedu_ci<11) // 7 a 10 anos de educación
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
	gen byte edupre_ci=(nivgrado==2)
	replace edupre_ci=. if aedu_ci==.
	*label variable edupre_ci "Educacion preescolar"

	***************
	***asiste_ci***
	***************
	gen byte asiste_ci=.
	replace asiste_ci=1 if pcp18==1
	replace asiste_ci=0 if pcp18==2
	*label variable asiste_ci "Asiste actualmente a la escuela"

	**************
	***literacy***
	**************
	gen byte literacy=. 

****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

    *******************
    ****condocup_ci****
    *******************
    gen byte condocup_ci=.
	replace condocup_ci=1 if pocupa==1 
	replace condocup_ci=2 if pdesoc==1
	replace condocup_ci=3 if pei==1
	replace condocup_ci=4 if edad_ci<7
	
	************
    ***emp_ci***
    ************
    gen byte emp_ci=0
	replace emp_ci=1 if pocupa==1 
	
	****************
    ***desemp_ci***
    ****************	
	gen byte desemp_ci=0
	replace desemp_ci=1 if pdesoc==1
	
	*************
    ***pea_ci***
    *************
    gen byte pea_ci=.
	replace pea_ci=1 if condocup_ci==1
	replace pea_ci=1 if condocup_ci==2
	replace pea_ci=0 if condocup_ci==3
	replace pea_ci=0 if condocup_ci==4
	
	*************
	**rama_ci****
	*************
	gen rama_ci=.
	replace rama_ci=1 if pcp32_2d>=1 & pcp32_2d<=3
	replace rama_ci=2 if pcp32_2d>=5 & pcp32_2d<=9
	replace rama_ci=3 if pcp32_2d>=10 & pcp32_2d<=33
	replace rama_ci=4 if pcp32_2d>=35 & pcp32_2d<=39
	replace rama_ci=5 if pcp32_2d>=41 & pcp32_2d<=43
	replace rama_ci=6 if (pcp32_2d>=45 & pcp32_2d<=47) | (pcp32_2d>=55 & pcp32_2d<=56)
	replace rama_ci=7 if (pcp32_2d>=49 & pcp32_2d<=53) | pcp32_2d==61 
	replace rama_ci=8 if pcp32_2d>=64 & pcp32_2d<=68
	replace rama_ci=9 if (pcp32_2d>=69 & pcp32_2d<=99) | (pcp32_2d>=58 & pcp32_2d<=60) | (pcp32_2d>=62 & pcp32_2d<=63)

	
	 *********************
     ****categopri_ci****
     *********************
	 *OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.
	 gen byte categopri_ci=.
	 replace categopri_ci=1 if pcp31_d==1
	 replace categopri_ci=2 if pcp31_d==2 | pcp31_d==3
	 replace categopri_ci=3 if pcp31_d==4 | pcp31_d==5 | pcp31_d==6
	 replace categopri_ci=4 if emp_ci==1  & pcp31_d==7
	 
	 *****************
     ***spublico_ci***
     *****************
    gen byte spublico_ci=.
	replace spublico_ci=1 if emp_ci==1 & pcp32_1d ==15
	replace spublico_ci=0 if emp_ci==1 & pcp32_1d ~=15
	
	
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************		

	********
	*luz_ch*
	********
	*En la nueva encuesta no se encontro si se pregunta por instalacion electrica
	gen luz_ch=pch8
	replace luz_ch=0 if pch8>=2 & pch8<=5
	
	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
	replace piso_ch = 0 if pcv5 == 7
	replace piso_ch = 1 if pcv5 == 1 | pcv5 == 2 | pcv5 == 4 | pcv5 == 5 | pcv5 == 6
	replace piso_ch = 2 if pcv5 == 3 | pcv5 == 8
		
	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	replace pared_ch=0 if pcv2 ==9 
	replace pared_ch=1 if pcv2 == 1 | pcv2==2 | pcv2 ==3 | pcv2 ==5
	replace pared_ch=2 if pcv2 == 4 | pcv2==6 | pcv2 ==7 | pcv2 ==8 | pcv2 ==10 | pcv2 ==11

	**********
	*techo_ch*
	**********
	gen byte techo_ch=.
	replace techo_ch=0 if pcv3 ==6
	replace techo_ch=1 if pcv3 ==1 | pcv3 == 2 | pcv3 == 3 | pcv3==4
	replace techo_ch=2 if pcv3 ==5 | pcv3 == 7 | pcv3 == 8
	
	**********
	*resid_ch*
	**********
	gen byte resid_ch=. 
    replace resid_ch=0 if pch10 ==1 | pch10 == 2
	replace resid_ch=1 if pch10 ==3 | pch10 == 4 
	replace resid_ch=2 if pch10 ==5 | pch10 == 6
	
	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=pch12
	
	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=pch11
	
	***********
	*cocina_ch*
	***********
	gen byte cocina_ch=pch13
	replace cocina_ch=0 if pch13==2
	
	***********
	*telef_ch*
	***********
	*sin dato
	gen byte telef_ch=.
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=pch9_e
	replace refrig_ch=0 if pch9_e==2
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=pch9_m
	replace auto_ch = 0 if pch9_m==2
	
	********
	*compu_ch*
	********
	gen byte compu_ch=pch9_h
	replace compu_ch =0 if pch9_h==2
	
	*************
	*internet_ch*
	************* 
	gen byte internet_ch=pch9_i
	replace internet_ch=0 if pch9_i==2
	
	********
	*cel_ch*
	********
	gen byte cel_ch=.
	
	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch=.
	replace viviprop_ch=0 if inlist(pch1, 3,6,4) 
	replace viviprop_ch=1 if  inlist(pch1, 1,2,5) 
	replace viviprop_ch=2 if pch1 == 2 

***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	*****************
	*aguaentubada_ch*
	*****************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch=1 if pch4 == 1 | pch4 == 2 
	replace aguaentubada_ch=0 if pch4>=3 & pch4<=10
		
	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch = 1 if inlist(pch4, 1,2)
	replace aguared_ch = 0 if inlist(pch4,3,4,5,6,8,9,10)
	
    ***************
	*aguafuente_ch*
	***************
	gen byte aguafuente_ch=.
	replace aguafuente_ch = 1 if inlist(pch4, 1,2)
	replace aguafuente_ch = 2 if pch4 ==3
	replace aguafuente_ch = 5 if pch4 ==5
	replace aguafuente_ch = 6 if pch4 ==9
	replace aguafuente_ch = 8 if inlist(pch4, 6,7)
	replace aguafuente_ch = 10 if inlist(pch4, 4,8,10)
	
	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch=.
	replace aguadist_ch = 1 if inlist(pch4, 1)
	replace aguadist_ch = 2 if inlist(pch4, 2)
	replace aguadist_ch = 3 if inlist(pch4, 3)
	replace aguadist_ch = 0 if inlist(pch4, 4,5,6,7,8,9,10)
	
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
	replace bano_ch = 0 if pch5 == 5
	replace bano_ch = 1 if pch5 == 1
	replace bano_ch = 2 if pch5 == 2
	replace bano_ch = 6 if inlist(pch5, 3,4)
	
	***********
	*banoex_ch*
	***********
	gen byte banoex_ch =.
	replace banoex_ch = 0 if inlist(pch6,2)
	replace banoex_ch = 1 if inlist(pch6,1)

	************
	*sinbano_ch*
	************
	gen byte sinbano_ch =.
	replace sinbano_ch = 3 if inlist(pch5,5)
	replace sinbano_ch = 0 if inlist(pch5, 1,2,3,4)
	
	*********
	*conbano_ch*
	*********
	gen byte conbano_ch=.
	replace conbano_ch=1 if pch5>=1 & pch5<=4
	replace conbano_ch=0 if pch5==5
	
	*****************
	*banoalcantarillado_ch*
	*****************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch=1 if pch5 == 1 | pch5==2
	replace banoalcantarillado_ch=0 if pch5 == 3 | pch5==4| pch5==5
	
	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	replace des1_ch=0 if bano_ch ==0
	replace des1_ch=1 if pch5 == 1 | pch5 == 2
	replace des1_ch=2 if pch5 == 3 | pch5 == 4
	


*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte GTM_m_pared_ch= pcv2
	label var GTM_m_pared_ch  "Material de las paredes según el censo del país - variable original"

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte GTM_m_piso_ch= pcv3
	label var GTM_m_piso_ch  "Material de los pisos según el censo del país - variable original"

	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte GTM_m_techo_ch= pcv5
	label var GTM_m_techo_ch  "Material del techo según el censo del país - variable original"

*Guatemala 2018 no tiene variables de ingreso

	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long GTM_ingreso_ci = .
	label var GTM_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long GTM_ingresolab_ci = .	
	label var GTM_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte GTM_dis_ci = .
	label var GTM_dis_ci  "Individuos con discapacidad según el censo del país - variable original"


/*******************************************************************************
   III. Incluir variables externas
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
* En "..." agregar la lista de variables de ID originales (por ejemplo los ID de personas, vivienda y hogar)

keep  $lista_variables num_vivienda num_hogar pcp1

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