* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: EL SALVADOR
Año: 2024
Autores: David Cornejo
Última versión: ...
División: SCL/Front - IADB
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
global PAIS SLV    				 //cambiar
global ANIO 2024   				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
cap log using `"$log_file"'  //agregar ,replace si ya está creado el log_file en tu carpeta

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
	gen byte region_BID_c = .
	replace region_BID_c = 1

	**********
	*region_c*   
	**********
	destring deptodesc, replace
	gen byte region_c = deptodesc
	replace region_c = .  if deptodesc==15
	
	label define region_c   ///
	1 "Ahuachapán" 			///
	2 "Santa Ana" 			///
	3 "Sonsonate" 			///
	4 "Chalatenango" 			///  
	5 "La Libertad" 			///  
	6 "San Salvador" 			///  
	7 "Cuscatlán" 			///  
	8 "La Paz" 			///  
	9 "Cabañas" 			///  
	10 "San Vicente" 			///  
	11 "Usulután" 			///  
	12 "San Miguel" 			///  
	13 "Morazán" 			///  
	14 "La Unión"
	label value region_c region_c
	tab region_c
	
	*********
	*geolev1*
	*********
	gen long geolev1 = .
	replace geolev1= 222001 if deptodesc ==1
	replace geolev1= 222002 if deptodesc ==2
	replace geolev1= 222003 if deptodesc ==3
	replace geolev1= 222004 if deptodesc ==4
	replace geolev1= 222005 if deptodesc ==5
	replace geolev1= 222006 if deptodesc ==6
	replace geolev1= 222007 if deptodesc ==7
	replace geolev1= 222008 if deptodesc ==8
	replace geolev1= 222009 if deptodesc ==9
	replace geolev1= 222010 if deptodesc ==10
	replace geolev1= 222011 if deptodesc ==11
	replace geolev1= 222012 if deptodesc ==12
	replace geolev1= 222013 if deptodesc ==13
	replace geolev1= 222014 if deptodesc ==14
	label define geolev1	///
	1 "Ahuachapán" 			///
	2 "Santa Ana" 			///
	3 "Sonsonate" 			///
	4 "Chalatenango" 			///  
	5 "La Libertad" 			///  
	6 "San Salvador" 			///  
	7 "Cuscatlán" 			///  
	8 "La Paz" 			///  
	9 "Cabañas" 			///  
	10 "San Vicente" 			///  
	11 "Usulután" 			///  
	12 "San Miguel" 			///  
	13 "Morazán" 			///  
	14 "La Unión"			
	label value geolev1 geolev1
	tab geolev1
	
    ********
	*pais_c*
	********
	gen str3 pais_c = "SLV" 

    ********
	*anio_c*
	********
	gen int anio_c = 2024
	
    *******************
    *idh_ch (ID hogar)*
    *******************
	* generar variable de ID tipo string. cambiar el formato según corresponda.
	* usar comando group para obtener identificador o concat si corresponde
	* group(conglome vivienda hogar)
	* tostring ..., gen(idh_ch) format("%16.0f")	
	egen  idh_ch =concat(cod_prop cod_viv cod_hog)
	* revisar número de hogares
	egen unique_tag = tag(idh_ch)
	count if unique_tag == 1
	
	**********************
    *idp_ci (ID personas)*
    **********************
	* generar variable de ID tipo string. cambiar el formato según corresponda. Revisar que no existan duplicados en idp_ci.
	* tostring ..., gen(idp_ci) format("%16.0f")
	egen  idp_ci = concat(cod_per) 
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
	*Zona_c*
	********
	gen byte zona_c=.
	replace zona_c=1 if area ==1
	replace zona_c=0 if area ==2
	tab zona_c
	

************************************
*** 2. Demografía (18 variables) ***
************************************

    ********
	*sexo_c*
	********
	gen byte sexo_ci =.
	replace sexo_ci = 1 if p02_2_sexo ==1
	replace sexo_ci = 2 if p02_2_sexo ==2
	tab sexo_ci
	
	********
	*edad_c*
	********
	gen int edad_ci = p02_3_edad
	tab edad_ci

	*************
	*relacion_ci*
	*************
	gen byte relacion_ci = .
	replace relacion_ci = 1 if p02_1_parentesco==1
	replace relacion_ci = 2 if p02_1_parentesco==2
	replace relacion_ci = 3 if p02_1_parentesco==3 | p02_1_parentesco==4
	replace relacion_ci = 4 if p02_1_parentesco>=5 & p02_1_parentesco<=11
	replace relacion_ci = 5 if p02_1_parentesco==13 | p02_1_parentesco==14 | p02_1_parentesco==15
	replace relacion_ci = 6 if p02_1_parentesco==12
	tab relacion_ci

	**********
	*civil_ci*
	**********
	gen	byte civil_ci=.
	replace civil_ci=1 if p03_estado_familiar ==6
	replace civil_ci=2 if p03_estado_familiar ==1 | p03_estado_familiar ==2
	replace civil_ci=3 if p03_estado_familiar ==3 | p03_estado_familiar ==4
	replace civil_ci=4 if p03_estado_familiar ==5

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
	replace clasehog_ch=5 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch>0 //corresidente

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
	replace afro_ci = 1 if p08_afrodescendiente ==1
	replace afro_ci = 0 if p08_afrodescendiente ==2

	*********
	*indi_ci*
	*********	
	gen byte ind_ci =. 		  // se queda como missing (.) si no existe la pregunta
	replace ind_ci =1 if p06_indigena ==1
	replace ind_ci =0 if p06_indigena ==2

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
	gen byte dis_ci=. 
	replace dis_ci=1 if p13a_discapacidad==1
	replace dis_ci=0 if p13a_discapacidad==2
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	replace disWG_ci=0 if (p13_1_discap_caminar ==1 | p13_1_discap_caminar ==2) | (p13_2_discap_brazos==1| p13_2_discap_brazos==2) | (p13_3_discap_recordar==1| p13_3_discap_recordar==2)| (p13_4_discap_cuidado_personal==1| p13_4_discap_cuidado_personal==2) | (p13_5_discap_comunicarse==1| p13_5_discap_comunicarse==2) | (p13_6_discap_visual==1| p13_6_discap_visual==2) | (p13_7_discap_oir==1| p13_7_discap_oir==2)	
	replace disWG_ci=1 if (p13_1_discap_caminar ==4 | p13_1_discap_caminar ==3) | (p13_2_discap_brazos==4| p13_2_discap_brazos==3) | (p13_3_discap_recordar==4| p13_3_discap_recordar==3)| (p13_4_discap_cuidado_personal==4| p13_4_discap_cuidado_personal==3) | (p13_5_discap_comunicarse==4| p13_5_discap_comunicarse==3) | (p13_6_discap_visual==4| p13_6_discap_visual==3) | (p13_7_discap_oir==4| p13_7_discap_oir==3)

	********
	*dis_ch*
	********
	egen byte dis_ch = sum(dis_ci), by(idh_ch) 
	replace dis_ch=1 if dis_ch>=1 & dis_ch!=.
	
**********************************
*** 4. Migración (3 variables) ***
**********************************	

    *****************
    *migrante_ci****
    ****************
	gen byte migrante_ci=.
	replace migrante_ci=1 if p04_3_resi_madre_otro_pais>=1 & p04_3_resi_madre_otro_pais <99 & p05_3_resi_anterior_otro_pais!=.
	replace migrante_ci=0 if p04_3_resi_madre_otro_pais==.| p04_3_resi_madre_otro_pais ==99
	 	
	****************
    *migrantiguo5_ci*
    ****************
	gen byte migrantiguo5_ci=.
	replace migrantiguo5_ci=1 if migrante_ci==1 & (p04_3b_anio_llegada_sal!=9999) & (2024 - p04_3b_anio_llegada_sal)>=5
	replace migrantiguo5_ci=0 if migrante_ci==1 & (p04_3b_anio_llegada_sal!=9999) & (2024 - p04_3b_anio_llegada_sal)<5
	
	***********
	*miglac_ci*
	***********
	gen byte miglac_ci=.
	replace miglac_ci=1 if (p04_3_resi_madre_otro_pais>=6 &  p04_3_resi_madre_otro_pais<=10) & migrante_ci ==1 & p04_3_resi_madre_otro_pais!=.
	replace miglac_ci=0 if (p04_3_resi_madre_otro_pais>=1 &  p04_3_resi_madre_otro_pais<=5) & migrante_ci ==1 & p04_3_resi_madre_otro_pais!=.
	replace miglac_ci=. if (p04_3_resi_madre_otro_pais==11| p04_3_resi_madre_otro_pais==99) & p04_3_resi_madre_otro_pais!=.

***********************************
*** 5. Educación (13 variables) ***
***********************************
	
	*********
	*aedu_ci*
	*********
	gen byte aedu_ci=0 if p10_1_grado_aprobado<=10
	replace aedu_ci=1 if p10_1_grado_aprobado == 11
	replace aedu_ci=2 if p10_1_grado_aprobado == 12
	replace aedu_ci=3 if p10_1_grado_aprobado == 13
	replace aedu_ci=4 if p10_1_grado_aprobado == 14
	replace aedu_ci=5 if p10_1_grado_aprobado == 15
	replace aedu_ci=6 if p10_1_grado_aprobado == 16
	replace aedu_ci=7 if p10_1_grado_aprobado == 17
	replace aedu_ci=8 if p10_1_grado_aprobado == 18
	replace aedu_ci=9 if p10_1_grado_aprobado == 19
	replace aedu_ci=10 if p10_1_grado_aprobado == 21 | p10_1_grado_aprobado == 31 
	replace aedu_ci=11 if p10_1_grado_aprobado == 22 | p10_1_grado_aprobado == 32 
	replace aedu_ci=12 if p10_1_grado_aprobado ==23 | p10_1_grado_aprobado == 36 | p10_1_grado_aprobado == 41
	replace aedu_ci=13 if p10_1_grado_aprobado ==24 | p10_1_grado_aprobado == 37 | p10_1_grado_aprobado == 42
	replace aedu_ci=14 if p10_1_grado_aprobado == 38| p10_1_grado_aprobado == 43
	replace aedu_ci=15 if p10_1_grado_aprobado == 44
	replace aedu_ci=16 if p10_1_grado_aprobado == 45
	replace aedu_ci=17 if p10_1_grado_aprobado == 46 | p10_1_grado_aprobado ==51 | p10_1_grado_aprobado ==61
	replace aedu_ci=18 if p10_1_grado_aprobado == 47 | p10_1_grado_aprobado ==52 | p10_1_grado_aprobado ==62
	replace aedu_ci=18 if p10_1_grado_aprobado == 48 | p10_1_grado_aprobado ==53 | p10_1_grado_aprobado ==63
	replace aedu_ci=19 if p10_1_grado_aprobado ==64
	replace aedu_ci=20 if p10_1_grado_aprobado ==65
	replace aedu_ci=. if p10_1_grado_aprobado ==.

	
	**********
	*eduno_ci*
	**********
	gen byte eduno_ci=(aedu_ci==0) 
	replace eduno_ci=. if aedu_ci==. 

	**********
	*edupi_ci*
	**********
	gen byte edupi_ci=(aedu_ci>=1 & aedu_ci<=4) 
	replace edupi_ci=. if aedu_ci==. 

	**********
	*edupc_ci*
	**********
	gen byte edupc_ci=(aedu_ci==5) 
	replace edupc_ci=. if aedu_ci==. 

	**********
	*edusi_ci*
	**********
	gen byte edusi_ci=(aedu_ci>=6 & aedu_ci<=10) 
	replace edusi_ci=. if aedu_ci==. 

	**********
	*edusc_ci*
	**********
	gen byte edusc_ci=(aedu_ci==1) 
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
	gen byte edus2i_ci=(aedu_ci==10)
	replace edus2i_ci=. if aedu_ci==. 

	***********
	*edus2c_ci*
	***********
	gen byte edus2c_ci=(aedu_ci>=11)
	replace edus2c_ci=. if aedu_ci==. 

	***********
	*edupre_ci*
	***********
	gen byte edupre_ci= (aedu_ci>=1)| (aedu_ci<=3)
	replace edupre_ci=. if aedu_ci==.
	
	***********
	*asiste_ci*
	***********
	gen byte asiste_ci=1 if p09_educacion_formal==1
	replace asiste_ci=0 if p09_educacion_formal==2
	replace asiste_ci=. if p09_educacion_formal==9|p09_educacion_formal==.

	**********
	*literacy*
	**********
	gen byte literacy=1 if p12_analfabetismo==1
	replace literacy=0 if p12_analfabetismo==2
	replace literacy=. if p12_analfabetismo==9|p12_analfabetismo==.
		
****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

    *************
    *condocup_ci*
    *************
    gen byte condocup_ci=.
	replace condocup_ci=1 if p15_1_activ_empleo ==1 | p15_1_activ_empleo == 2 | p15_1_activ_empleo==3	//ocupados
	replace condocup_ci=2 if p16_1_cond_activ ==1 |p16_1_cond_activ ==2	//desocupados	
	replace condocup_ci=3 if p16_1_cond_activ ==3	//inactivos
	replace condocup_ci=4 if p16_1_cond_activ==. & p15_1_activ_empleo ==. & edad_ci <=10	//no responde por ser menor de edad
	
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
	replace categopri_ci=0 if p19_activ_cat_ocup==10 & emp_ci==1
	replace categopri_ci=1 if p19_activ_cat_ocup==3 & emp_ci==1
	replace categopri_ci=2 if p19_activ_cat_ocup==4 & emp_ci==1
	replace categopri_ci=3 if (p19_activ_cat_ocup==1 | p19_activ_cat_ocup==2 | p19_activ_cat_ocup==5 | p19_activ_cat_ocup==6 | p19_activ_cat_ocup==7) & emp_ci==1
	replace categopri_ci=4 if (p19_activ_cat_ocup==8 | p19_activ_cat_ocup==9 ) & emp_ci==1
	 
	*************
    *spublico_ci*
    *************
	gen byte spublico_ci=.
	replace spublico_ci=1 if emp_ci==1 & p19_activ_cat_ocup==1
	replace spublico_ci=0 if emp_ci==1 & p19_activ_cat_ocup!=1

		
		
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************		

	********
	*luz_ch*
	********
	gen byte luz_ch=.
	replace luz_ch = 1 if v13_viv_fuente_energia!= 7 & v13_viv_fuente_energia!=8
	replace luz_ch = 0 if v13_viv_fuente_energia== 7

	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
	replace piso_ch = 0 if v05_viv_piso ==7
	replace piso_ch = 1 if (v05_viv_piso >=1) & (v05_viv_piso <=6)
	replace piso_ch = 2 if v05_viv_piso==8
	
	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	replace pared_ch=1 if v03_viv_pared>= 2 & v03_viv_pared<=8
	replace pared_ch=2 if v03_viv_pared==1

	**********
	*techo_ch*
	**********
	gen byte techo_ch=.
	replace techo_ch=1 if v04_viv_techo >= 5 & v04_viv_techo<=7
	replace techo_ch=2 if v04_viv_techo >= 1 & v04_viv_techo<=4

	**********
	*resid_ch*
	**********
	gen byte resid_ch=.
	replace resid_ch=0 if v15_viv_elim_basura == 1
	replace resid_ch=1 if v15_viv_elim_basura ==2 | v15_viv_elim_basura ==3 | v15_viv_elim_basura ==4
	replace resid_ch=2 if v15_viv_elim_basura ==5 | v15_viv_elim_basura ==6
	replace resid_ch=3 if v15_viv_elim_basura ==7

	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=.
	replace dorm_ch=h01_hog_dormitorios 

	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=.
	replace cuartos_ch=v06_viv_cuartos
	
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
	gen byte refrig_ch=.
	replace refrig_ch=1 if h02_1_hog_refri == 1
	replace refrig_ch=0 if h02_1_hog_refri == 2
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	replace auto_ch=1 if h02_13_hog_auto==1
	replace auto_ch=0 if h02_13_hog_auto==2

	**********
	*compu_ch*
	**********
	gen byte compu_ch=.
	replace compu_ch=1 if h02_8_hog_compu==1
	replace compu_ch=0 if h02_8_hog_compu==2

	*************
	*internet_ch*
	************* 
	gen byte internet_ch=.
	replace internet_ch=1 if h02_11_hog_internet==1
	replace internet_ch=0 if h02_11_hog_internet==2

	********
	*cel_ch*
	********
	gen byte cel_ch=.
	replace cel_ch=1 if h02_7_hog_cel==1
	replace cel_ch=0 if h02_7_hog_cel==2

	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch=.
	replace viviprop_ch=1 if (v07_viv_tenencia ==1 |v07_viv_tenencia==2)
	replace viviprop_ch=0 if v07_viv_tenencia>=3 & v07_viv_tenencia<=6

***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	*****************
	*aguaentubada_ch*
	*****************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch= 1 if v11_viv_agua==1 | v11_viv_agua ==2
	replace aguaentubada_ch= 0 if v11_viv_agua==3
	
	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch=1 if v12_viv_proviene_agua ==1 | v12_viv_proviene_agua==2 | v12_viv_proviene_agua==3
	replace aguared_ch=0 if v12_viv_proviene_agua>=4 & v12_viv_proviene_agua<=10

    ***************
	*aguafuente_ch*
	***************
	gen aguafuente_ch = 1 if v12_viv_proviene_agua==1 | v12_viv_proviene_agua==2| v12_viv_proviene_agua==3
	*rainwater
	replace aguafuente_ch = 5 if v12_viv_proviene_agua==10
	replace aguafuente_ch= 6 if v12_viv_proviene_agua==9 
	*Trucked
	replace aguafuente_ch = 8 if v12_viv_proviene_agua==8 
	replace aguafuente_ch= 10 if inlist(v12_viv_proviene_agua,4,5,6,7,11,12) 	
	
	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch= .
	          
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
	gen byte bano_ch = . 
	replace bano_ch = 0 if v08_viv_tipo_sanit==5
	replace bano_ch = 1 if v08_viv_tipo_sanit==1
	replace bano_ch = 2 if v08_viv_tipo_sanit==2
	replace bano_ch = 3 if v08_viv_tipo_sanit==4
	replace bano_ch = 6 if v08_viv_tipo_sanit==6
	
	***********
	*banoex_ch*
	***********
	gen byte banoex_ch = .
	replace banoex_ch = 1 if v09_viv_uso_sanit==1
	replace banoex_ch = 0 if v09_viv_uso_sanit==2
	
	
	************
	*sinbano_ch*
	************
	gen byte sinbano_ch =.


	*********
	*conbano_ch*
	*********
	gen byte conbano_ch=.
	replace conbano_ch=1 if v08_viv_tipo_sanit >=1 & v08_viv_tipo_sanit<=4
	replace conbano_ch=0 if v08_viv_tipo_sanit==5
	
	***********************
	*banoalcantarillado_ch*
	***********************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch=1 if v10_viv_aguas_grises ==1
	replace banoalcantarillado_ch=0 if v10_viv_aguas_grises==2 | v10_viv_aguas_grises==3|v10_viv_aguas_grises==4
		
	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	replace des1_ch=0 if v08_viv_tipo_sanit==5
	replace des1_ch=1 if v08_viv_tipo_sanit ==1
	replace des1_ch=2 if v08_viv_tipo_sanit==2|v08_viv_tipo_sanit==3|v08_viv_tipo_sanit==4


*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte SLV_m_pared_ch= v03_viv_pared
	label var SLV_m_pared_ch  "Material de las paredes según el censo del país - variable original"
	label def SLV_m_pared_ch  1 "Bloque, ladrillo o concreto" 2 " Adobe" 3 "Tablaroca o similares" 4 "Bahareque" 5 "Lámina metálica" 6 "Madera" 7 "Material reciclado (plástico, cartón u otro)" 8 "Paja, palma o similares" 9 "Otro" 10 "No se sabe/No responde" //categorías originales del país
	label val SLV_m_pared_ch  SLV_m_pared_ch 

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte SLV_m_piso_ch= v05_viv_piso
	label var SLV_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	label def SLV_m_piso_ch  1 "Ladrillo de cemento" 2 "Cerámica" 3 "Ladrillo de barro" 4 "Losa de cemento" 5 "Madera" 6 "Cemento" 7 "Tierra" 8 "Otro" 9 "No sabe/No responde"  //categorías originales del país
	label val SLV_m_piso_ch  SLV_m_piso_ch 
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte SLV_m_techo_ch= v04_viv_techo
	label var SLV_m_techo_ch  "Material del techo según el censo del país - variable original"
	label def SLV_m_techo_ch  1 "Lámina de asbesto o fibrocemento (duralita)" 2 "Lámina metálica" 3 "Teja" 4 "Losa de concreto (plafón)" 5 "Lámina de plástico, policarbonato o similares" 6 "Paja, palma o similares" 7 "Material reciclado (plástico, cartón u otro)" 8 "Otro" 9 "No sabe/No responde"   //categorías originales del país
	label val SLV_m_techo_ch SLV_m_techo_ch 
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long SLV_ingreso_ci = .
	label var SLV_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long SLV_ingresolab_ci = .	
	label var SLV_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte SLV_dis_ci = p13a_discapacidad
	label var SLV_dis_ci  "Individuos con discapacidad según el censo del país - variable original"
	label def SLV_dis_ci 1 "Sí" 2 "No"   //categorías originales del país
	label val SLV_dis_ci SLV_dis_ci
	

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

keep  $lista_variables cod_prop cod_viv cod_hog cod_per

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
cap save "$base_out", replace 

cap log close

********************************************************************************
******************* FIN. Muchas gracias por tu trabajo ;) **********************
********************************************************************************
