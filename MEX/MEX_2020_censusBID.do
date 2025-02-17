* (Versión Stata 12)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: MEXICO
Año: 2020
Autores: Eric Torres
Última versión: 06ENE2024
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
global PAIS MEX   				 //cambiar
global ANIO 2020  				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                  
capture log close
log using `"$log_file"', replace  //agregar ,replace si ya está creado el log_file en tu carpeta

use "$base_in", clear


/****************************************************************************
   II. Armonización de variables 
*****************************************************************************/

*************************************
*** Identificación (12 variables) ***
*************************************

	****************
	* region_BID_c *
	****************
	gen byte region_BID_c=.
	label var region_BID_c "Regiones BID"
	label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
	label value region_BID_c region_BID_c

	****************
	 *** region_c ***
	****************
	gen byte region_c =.
	replace region_c=ent

	label define region_c ///
	1 "Aguascalientes" ///
	2 "Baja California" ///
	3 "Baja California Sur" ///
	4 "Campeche" ///
	5 "Coahuila de Zaragoza" ///
	6 "Colima" ///
	7 "Chiapas" ///
	8 "Chihuahua" ///
	9 "Distrito Federal" ///
	10 "Durango" ///
	11 "Guanajuato" ///
	12 "Guerrero" ///
	13 "Hidalgo" ///
	14 "Jalisco" ///
	15 "México" ///
	16 "Michoacán de Ocampo" ///
	17 "Morelos" ///
	18 "Nayarit" ///
	19 "Nuevo León" ///
	20 "Oaxaca" ///
	21 "Puebla" ///
	22 "Querétaro" ///
	23 "Quintana Roo" ///
	24 "San Luis Potosí" ///
	25 "Sinaloa" ///
	26 "Sonora" ///
	27 "Tabasco" ///
	28 "Tamaulipas" ///
	29 "Tlaxcala" ///
	30 "Veracruz de Ignacio de la Llave" ///
	31 "Yucatán" ///
	32 "Zacatecas" 
	label value region_c region_c
	label var region_c "division politico-administrativa, estados"

	*********
	*geolev1*
	*********
	gen long geolev1=.
	replace geolev1=484001 if ent==1 //"Aguascalientes" 
	replace geolev1=484002 if ent==2 //"Baja California" 
	replace geolev1=484003 if ent==3 //"Baja California Sur" 
	replace geolev1=484004 if ent==4 //"Campeche" 
	replace geolev1=484005 if ent==5 //"Coahuila de Zaragoza" 
	replace geolev1=484006 if ent==6 //"Colima" 
	replace geolev1=484007 if ent==7 //"Chiapas" 
	replace geolev1=484008 if ent==8 //"Chihuahua" 
	replace geolev1=484009 if ent==9 //"Distrito Federal" 
	replace geolev1=484010 if ent==10 //"Durango" 
	replace geolev1=484011 if ent==11 //"Guanajuato" 
	replace geolev1=484012 if ent==12 //"Guerrero" 
	replace geolev1=484013 if ent==13 //"Hidalgo" 
	replace geolev1=484014 if ent==14 //"Jalisco" 
	replace geolev1=484015 if ent==15 //"México" 
	replace geolev1=484016 if ent==16 //"Michoacán de Ocampo" 
	replace geolev1=484017 if ent==17 //"Morelos" 
	replace geolev1=484018 if ent==18 //"Nayarit" 
	replace geolev1=484019 if ent==19 //"Nuevo León" 
	replace geolev1=484020 if ent==20 //"Oaxaca" 
	replace geolev1=484021 if ent==21 //"Puebla" 
	replace geolev1=484022 if ent==22 //"Querétaro" 
	replace geolev1=484023 if ent==23 //"Quintana Roo" 
	replace geolev1=484024 if ent==24 //"San Luis Potosí" 
	replace geolev1=484025 if ent==25 //"Sinaloa" 
	replace geolev1=484026 if ent==26 //"Sonora" 
	replace geolev1=484027 if ent==27 //"Tabasco" 
	replace geolev1=484028 if ent==28 //"Tamaulipas" 
	replace geolev1=484029 if ent==29 //"Tlaxcala" 
	replace geolev1=484030 if ent==30 //"Veracruz de Ignacio de la Llave" 
	replace geolev1=484031 if ent==31 //"Yucatán" 
	replace geolev1=484032 if ent==32 //"Zacatecas" 

	*********
	*pais_c*
	*********
    gen str3 pais_c="MEX"
	
	*********
	*anio_c*
	*********
	gen int anio_c=2020
	
	******************
    *idh_ch (id hogar)*
    ******************
	tostring id_viv, replace format("%16.0f")
	gen idh_ch =id_viv	
	
	******************
    *idp_ci (id personas)*
    ******************
	cap tostring id_persona, replace format("%16.0f")
	egen idp_ci=concat(idh_ch id_persona numper)

	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
	gen factor_ci=factor
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
	gen factor_ch=factor
	
	***********
	* estrato_ci *
	***********
	gen estrato_ci=estrato
	
	***********
	* 	upm	  *
	***********
	gen upm_ci=upm

    ********
	*Zona_c*
	********
	gen byte zona_c=.
	
************************************
*** 2. Demografía (18 variables) ***
************************************

	*********
	*sexo_c*
	*********
	gen byte sexo_ci =sexo
	replace sexo_ci =2 if sexo_ci == 3
	
	*********
	*edad_c*
	*********
	gen int edad_ci = edad
	replace edad_ci=. if edad_ci==999 /* age=999 corresponde a "unknown" */
	replace edad_ci=98 if edad_ci>=98  /* age=100 corresponde a 100+ */

 	*************
	*relacion_ci*
	*************	
	gen byte relacion_ci=1 if parentesco==101
    replace relacion_ci=2 if parentesco>=201 & parentesco<300
    replace relacion_ci=3 if parentesco>=300 & parentesco <400
    replace relacion_ci=4 if parentesco>=400 & parentesco <500
    replace relacion_ci=5 if (parentesco>=500 & parentesco <600) | (parentesco>=611 & parentesco <613) | parentesco==701
    replace relacion_ci=6 if parentesco==601
	replace relacion_ci=. if parentesco==999
	
	**********
	*civil_ci*
	**********
	*2010 no tiene variable marst
	gen byte civil_ci=.
	replace civil_ci=1 if situa_conyugal==8 //soltero
	replace civil_ci=2 if situa_conyugal==2 | situa_conyugal==5 | situa_conyugal==6 | situa_conyugal==7     //union
	replace civil_ci=3 if situa_conyugal==2 | situa_conyugal==3   //divorciado
	replace civil_ci=4 if situa_conyugal==4 //viudo
	
	
    *********
	*jefe_ci*
	*********
	gen byte jefe_ci=(relacion_ci==1)
	replace jefe_ci=. if relacion_ci == .
	
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
	replace afroind_ci=1  if (perte_indigena == 1)
	replace afroind_ci=2  if (afrodes == 1)
	replace afroind_ci=3 if (perte_indigena !=1 & afrodes!=1)

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
	
	***************
	***afroind_ch***
	***************
	gen afroind_jefe= afroind_ci if relacion_ci==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 
	drop afroind_jefe 

	********
	*dis_ci*
	********
	gen byte dis_ci=.
	replace dis_ci=0 if ( (dis_caminar==1 |dis_caminar==2) & (dis_ver==1 | dis_ver==2) & (dis_recordar==1 |dis_recordar==2) & (dis_oir==1 | dis_oir==2) & (dis_banarse==1 | dis_banarse==2) & (dis_hablar==1|dis_hablar==2) &   dis_mental==6)
	replace dis_ci=1 if dis_ci!=0
	replace dis_ci=. if (dis_caminar==9 & dis_ver==9 & dis_recordar==9 & dis_oir==9 & dis_banarse==9 & dis_hablar==9 & dis_mental ==9)
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=.
	
	********
	*dis_ch*
	********
	egen byte dis_ch = sum(dis_ci), by(idh_ch) 
	replace dis_ch=1 if dis_ch>=1 & dis_ch!=. 

**********************************
*** 4. Migración (3 variables) ***
**********************************	

    *******************
    ****migrante_ci****
    *******************
	gen byte migrante_ci =.
	replace migrante_ci = 1 if ent_pais_nac>99 & ent_pais_nac<536
	replace migrante_ci = 0 if ent_pais_nac>0 & ent_pais_nac<33
	
	*******************
    **migrantiguo5_ci***
    *******************
	gen byte migrantiguo5_ci =.
	
	**********************
	****** miglac_ci *****
	**********************
	gen byte migrantelac_ci = .
	replace migrantelac_ci= 1 if inlist(ent_pais_nac, 204, 206, 207, 208, 210, 211, 214, 215, 217, 219, 220, 225, 226, 228, 229, 230, 234, 235, 236, 237, 239, 244, 245, 250) & migrante_ci == 1
	replace migrantelac_ci = 0 if migrantelac_ci == . & migrante_ci == 1 | migrante_ci == 0
	
	gen miglac_ci = .
	replace miglac_ci= 1 if inlist(ent_pais_nac, 204, 206, 207, 208, 210, 211, 214, 215, 217, 219, 220, 225, 226, 228, 229, 230, 234, 235, 236, 237, 239, 244, 245, 250) & migrante_ci == 1
	replace miglac_ci = 0 if migrantelac_ci != 1 & migrante_ci == 1 

***********************************
*** 5. Educación (13 variables) ***
***********************************

	*************
	***aedu_ci*** // años de educacion aprobados
	*************
	gen byte aedu_ci=.
	replace aedu_ci=escoacum
	replace aedu_ci=. if escoacum==99
	replace aedu_ci=. if aedu_ci==99

	**************
	***eduno_ci***
	**************
	gen byte eduno_ci=0
	replace eduno_ci=1 if aedu_ci==0
	replace eduno_ci=. if aedu_ci==.
		
	**************
	***edupi_ci***
	**************
	gen byte edupi_ci=0
	replace edupi_ci=1 if aedu_ci>0 & aedu_ci<6
	replace edupi_ci=. if aedu_ci==.

	**************
	***edupc_ci***
	**************
	gen byte edupc_ci=0
	replace edupc_ci=1 if aedu_ci==6
	replace edupc_ci=. if aedu_ci==.
	replace edupc_ci=1 if nivacad==6
	
	**************
	***edusi_ci***
	**************
	gen byte edusi_ci=0
	replace edusi_ci=1 if aedu_ci>6 & aedu_ci<12
	replace edusi_ci=. if aedu_ci==.

	**************
	***edusc_ci***
	**************
	gen byte edusc_ci=0
	replace edusc_ci=1 if aedu_ci==12
	replace edusc_ci=. if aedu_ci==.
	replace edusc_ci=1 if nivacad==8  // Some tertiary

	***************
	***edus1i_ci***
	***************
	gen byte edus1i_ci=0
	replace edus1i_ci=1 if aedu_ci>6 & aedu_ci<9
	replace edus1i_ci=. if aedu_ci==.

	***************
	***edus1c_ci***
	***************
	gen byte edus1c_ci=0
	replace edus1c_ci=1 if aedu_ci==9 
	replace edus1c_ci=1 if nivacad==7 // Some tertiary
	replace edus1c_ci=. if aedu_ci==.

	***************
	***edus2i_ci***
	***************
	gen byte edus2i_ci=0
	replace edus2i_ci=1 if aedu_ci>9 & aedu_ci<12
	replace edus2i_ci=. if aedu_ci==.

	***************
	***edus2c_ci***
	***************
	gen byte edus2c_ci=0
	replace edus2c_ci=1 if aedu_ci==12
	replace edus2c_ci=1 if nivacad==8 // Some tertiary
	replace edus2c_ci=. if aedu_ci==.

	***************
	***edupre_ci***
	***************
	gen byte edupre_ci=.

	***************
	***asiste_ci*** 
	***************
	gen byte asiste_ci=1 if asisten==1
	replace asiste_ci=. if asisten==9 //  Unknown/missing as missing
	replace asiste_ci=0 if asisten==2
	
	**************
	***literacy***
	**************
	gen byte literacy=. 
	replace literacy=. if alfabet==9
	replace literacy=0 if alfabet==1
	replace literacy=1 if alfabet==2	

****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

     *******************
     ****condocup_ci****
     ******************* 
    gen byte condocup_ci=.
	replace condocup_ci=1 if conact==10 | conact==16 | conact==17 | conact==18 | conact==19 | conact==20
	replace condocup_ci=2 if conact==13 | conact==30
	replace condocup_ci=3 if conact==14 | conact==15 | conact==40 | conact==50 | conact==60 | conact==70 | conact==80

    ************
    ***emp_ci***
    ************
    gen byte emp_ci=.
	replace emp_ci=(condocup_ci==1) if condocup_ci!=.
	
    ****************
    ***desemp_ci***
    ****************	
	gen byte desemp_ci=.
	cap confirm variable condocup_ci
	if (_rc==0){
		replace desemp_ci=1 if condocup_ci==2 /*1 desempleados*/
		replace desemp_ci=0 if condocup_ci==3 | condocup_ci==1 /*0 cuando están inactivos o empleados*/
	}
	
    *************
    ***pea_ci***
    *************
    gen byte pea_ci=.
	cap confirm variable condocup_ci
	if (_rc==0){
		replace pea_ci=1 if condocup_ci==1
		replace pea_ci=1 if condocup_ci==2
		replace pea_ci=0 if condocup_ci==3
	}
	
     *************************
     ****rama de actividad****
     *************************
	 *2010 no tiene variable indgen
    gen byte rama_ci = . 

    replace rama_ci = 1 if actividades_c>=1110 & actividades_c<2100
    replace rama_ci = 2 if actividades_c>=2110 & actividades_c<2200
    replace rama_ci = 3 if actividades_c>=3110 & actividades_c<3400 
    replace rama_ci = 4 if actividades_c>=2210 & actividades_c<2300  
    replace rama_ci = 5 if actividades_c>=2310 & actividades_c<2400   
    replace rama_ci = 6 if actividades_c>=4310 & actividades_c<4700  
    replace rama_ci = 7 if actividades_c>=7210 & actividades_c< 7300   
    replace rama_ci = 8 if actividades_c>=4810 & actividades_c<   5200
    replace rama_ci = 9 if actividades_c>=5210 & actividades_c< 5300
    replace rama_ci = 10 if actividades_c>=9311 & actividades_c< 9400 
    replace rama_ci = 11 if actividades_c>=5310 & actividades_c<5400 | actividades_c==5510  
    replace rama_ci = 12 if actividades_c>=6111 & actividades_c<6200 
    replace rama_ci = 13 if actividades_c>=6211 & actividades_c<6300 
    replace rama_ci = 14 if (actividades_c>=7111 & actividades_c<7200) | (actividades_c>=8111 & actividades_c<8140) | (actividades_c>=5411 & actividades_c<5500) | (actividades_c>=5611 & actividades_c<5700)
    replace rama_ci = 15 if actividades_c==8140
	

     *********************
     ****categopri_ci****
     *********************
	 *OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.	
    gen byte categopri_ci=.

    replace categopri_ci=0 if sittra==9
    replace categopri_ci=1 if sittra==4
    replace categopri_ci=2 if sittra==5
    replace categopri_ci=3 if sittra>=1 & sittra<=3
    replace categopri_ci=4 if sittra==6
	
    *****************
    ***spublico_ci***
    *****************
    gen byte spublico_ci=.

	replace spublico_ci=1 if rama_ci==10
	replace spublico_ci=0 if emp_ci==1 & rama_ci!=10
	replace spublico_ci=. if rama_ci==.
	
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************		
	
	********
	*luz_ch*
	********
	*En la nueva encuesta no se encontro si se pregunta por instalacion electrica
	gen byte  luz_ch=.
	replace luz_ch=1 if electricidad==1
	replace luz_ch=2 if electricidad==3
	
	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
 	replace piso_ch=2 if pisos==3
	replace piso_ch=0 if pisos==1
	replace piso_ch=1 if pisos==2
	
	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	replace pared_ch=1 if paredes>=1 & paredes<=7
	replace pared_ch=2 if paredes==8

	**********
	*techo_ch*
	**********
	gen byte techo_ch=.
	replace techo_ch=1 if techos>=1 & techos<=8
	replace techo_ch=2 if techos>=9 & techos<=10
	
	**********
	*resid_ch*
	**********
	gen byte resid_ch=.
	replace resid_ch=0 if destino_bas==1 | destino_bas==5
	replace resid_ch=1 if destino_bas==3
	replace resid_ch=2 if destino_bas==6
	replace resid_ch=3 if destino_bas==9 | destino_bas==2	
	
	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=.
	replace dorm_ch=cuadorm if cuadorm!=99
	
	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=.
	replace cuartos_ch=totcuart if totcuart!=99 

	***********
	*cocina_ch*
	***********
	gen byte cocina_ch=.
	replace cocina_ch=1 if cocina==1
	replace cocina_ch=0 if cocina==3
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch=.
	replace telef_ch=1 if telefono==3 
	replace telef_ch=0 if telefono==4

	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=.
	replace refrig_ch=1 if refrigerador==1
	replace refrig_ch=0 if refrigerador==2
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	replace auto_ch=1 if autoprop==7
	replace auto_ch=0 if autoprop==8
	
	********
	*compu_ch*
	********
	gen byte compu_ch=.
	replace compu_ch=1 if computadora==1 
	replace compu_ch=0 if computadora==2

	*************
	*internet_ch*
	************* 
	*pendiente esta variable no es lo que queremos generar
	gen byte internet_ch=.
	replace internet_ch=1 if internet==7
	replace internet_ch=0 if internet==8
	
	********
	*cel_ch*
	********
	gen byte cel_ch=.
	replace cel_ch=1 if celular==5
	replace cel_ch=0 if celular==6

	*************
	*viviprop_ch*
	*************
	*NOTA: aqui se genera una variable parecida, pues no se puede saber si es propia total o parcialmente pagada
	gen byte viviprop_ch=.
	replace viviprop_ch=1 if tenencia==1
	replace viviprop_ch=0 if tenencia>1 & tenencia<=4
	
***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************		
	
	************
	*aguaentubada_ch*
	************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch=1 if agua_entubada==1 | agua_entubada==2
	replace aguaentubada_ch=0 if agua_entubada==3
	
	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch = 1 if aba_agua_entu == 1
	replace aguared_ch = 0 if inlist(aba_agua_entu,2,3,4,5,6,8,9)
	
    ***************
	*aguafuente_ch*
	***************
	gen byte aguafuente_ch=.
	replace aguafuente_ch = 1 if (aba_agua_entu == 1) & (inlist(agua_entubada, 1, 2))
	replace aguafuente_ch = 2 if (inlist(aba_agua_entu,1) & inlist(agua_entubada, 3,4,5)) | inlist(aba_agua_no_entu, 2)
	replace aguafuente_ch = 5 if inlist(aba_agua_entu, 6) | inlist(aba_agua_no_entu,6)
	replace aguafuente_ch = 6 if inlist(aba_agua_entu, 4) | inlist(aba_agua_no_entu,5)
	replace aguafuente_ch = 8 if inlist(aba_agua_no_entu,4)
	replace aguafuente_ch = 10 if inlist(aba_agua_entu, 2,3,5,7,8,9) | inlist(aba_agua_no_entu, 1,3,9) | inlist(agua_entubada, 9)
	
	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch=.
	replace aguadist_ch = 1 if inlist(agua_entubada, 1)
	replace aguadist_ch = 2 if inlist(agua_entubada, 2)
	replace aguadist_ch = 3 if inlist(agua_entubada, 3)
	replace aguadist_ch = 0 if inlist(agua_entubada, 9)
	
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
	replace bano_ch = 0 if sersan == 3 
	replace bano_ch = 1 if sersan == 1 & drenaje == 1
	replace bano_ch = 2 if sersan == 1 & drenaje == 2
	replace bano_ch = 3 if inlist(sersan,2) & inlist(drenaje,1, 2)
	replace bano_ch = 4 if inlist(sersan, 1,2) & inlist(drenaje, 3,4)
	replace bano_ch = 6 if (inlist(sersan,1,2) & inlist(drenaje,5,9)) | sersan == 9 
	
	***********
	*banoex_ch*
	***********
	gen byte banoex_ch =.
	replace banoex_ch = 0 if inlist(usoexc,1)
	replace banoex_ch = 1 if inlist(usoexc,3)
	replace banoex_ch = 9 if inlist(usoexc,9)

	************
	*sinbano_ch*
	************
	gen byte sinbano_ch =.
	replace sinbano_ch = 3 if inlist(sersan,3)
	replace sinbano_ch = 0 if inlist(sersan, 1,2,9)

	*********
	*conbano_ch*
	*********
	gen byte conbano_ch=.
	replace conbano_ch=1 if sersan==1 | sersan==2
	replace conbano_ch=0 if sersan==0
		
	*****************
	*banoalcantarillado_ch*
	*****************
	gen byte banoalcantarillado_ch=.
 	replace banoalcantarillado_ch=0 if drenaje==5 
	replace banoalcantarillado_ch=1 if drenaje>=1 & drenaje<=4

	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	replace des1_ch=0 if bano_ch==0 
	replace des1_ch=1 if sersan==1
	replace des1_ch=2 if sersan==2

*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************

	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************
	gen byte MEX_m_pared_ch = paredes
	label var MEX_m_pared_ch  "Material de las paredes según el censo del país - variable original"

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
gen byte MEX_m_piso_ch= pisos
	label var MEX_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************		
	gen byte MEX_m_techo_ch = techos
	label var MEX_m_techo_ch  "Material del techo según el censo del país - variable original"
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************		
gen long MEX_ingreso_ci = .
	label var  MEX_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************	
	gen long MEX_ingresolab_ci = ingtrmen
	replace MEX_ingresolab_ci=. if ingtrmen==999998 | ingtrmen==999999
	label var   MEX_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte MEX_dis_ci = .
	label var MEX_dis_ci  "Individuos con discapacidad según el censo del país - variable original"
	
/*******************************************************************************
   III. Incluir variables externas (7 variables)
*******************************************************************************/
capture drop _merge
merge m:1 pais_c anio_c using "Z:/general_documentation/data_externa/poverty/International_Poverty_Lines/5_International_Poverty_Lines_LAC_long_PPP17.dta", keepusing (cpi_2017 lp19_2011 lp31_2011 lp5_2011 tc_wdi lp365_2017 lp685_201)
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

keep  $lista_variables id_viv id_persona numper
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

