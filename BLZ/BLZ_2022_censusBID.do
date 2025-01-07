* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: BLZ
Año: 2022
Autores: Mayte Ysique (maytes@iadb.org / mysique@pucp.pe)
Última versión: 24SEP2024
División: SCL/GDI - IADB
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
global PAIS BLZ    				 //cambiar
global ANIO 2022   				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using "$log_file", replace //agregar ,replace si ya está creado el log_file en tu carpeta

use "$base_in", clear

rename *, lower

/****************************************************************************
   II. Armonización de variables 
*****************************************************************************/

*************************************
*** Identificación (12 variables) ***
*************************************

	**************
	*region_BID_c*
	**************
	gen byte region_BID_c = 2

	**********
	*region_c*   
	**********
	gen byte region_c = district
	label define region_c 1 "Corozal" ///
						  2 "Orange Walk" ///
						  3 "Belize" ///
						  4 "Cayo" ///
						  5 "Stann Creek" ///
						  6 "Toledo"
						  
	label value region_c region_c
	tab region_c
	
	*********
	*geolev1*
	*********
	gen long geolev1 =.  
	replace geolev1= 840001 if region_c==1 
	replace geolev1= 840002 if region_c==2
	replace geolev1= 840003 if region_c==3
	replace geolev1= 840004 if region_c==4
	replace geolev1= 840005 if region_c==5
	replace geolev1= 840006 if region_c==6
	
	label define geolev1  840001 "Corozal" ///
						  840002 "Orange Walk" ///
						  840003 "Belize" ///
						  840004 "Cayo" ///
						  840005 "Stann Creek" ///
						  840006 "Toledo"
						  			
	label value geolev1 geolev1
	tab geolev1
	
    ********
	*pais_c*
	********
	gen str3 pais_c = "BLZ" 

    ********
	*anio_c*
	********
	gen int anio_c = 2022
	
    *******************
    *idh_ch (ID hogar)*
    *******************
	egen  idh_ch =group(dwelling_id hh_id) 
	* revisar número de hogares
	egen unique_tag = tag(idh_ch)
	count if unique_tag == 1
	
	**********************
    *idp_ci (ID personas)*
    **********************
	egen  idp_ci = group(dwelling_id hh_id individual__id) 
	duplicates report idh_ch idp_ci // CALIDAD: revisar que resultado sea copies =1
		
	****************************************
	*(factor_ci) factor expansión individio*
	****************************************
	gen factor_ci=weight
	
	*******************************************
	*(factor_ch) Factor de expansion del hogar*
	*******************************************
	gen factor_ch=weight
		
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
	replace zona_c=1 if area==1
	replace zona_c=0 if area==2
	tab zona_c
	

************************************
*** 2. Demografía (18 variables) ***
************************************

    ********
	*sexo_c*
	********
	gen byte sexo_ci =.
	replace sexo_ci = 1 if hl3a==1
	replace sexo_ci = 2 if hl3a==2
	tab sexo_ci
	
	********
	*edad_c*
	********
	gen int edad_ci = hl3
	*tab edad_ci

	*************
	*relacion_ci*
	*************
	gen byte relacion_ci = .
	replace relacion_ci = 1 if hl1==1
	replace relacion_ci = 2 if hl1==2
	replace relacion_ci = 3 if hl1==3
	replace relacion_ci = 4 if inlist(hl1,4,5,6,7,8,9)
	replace relacion_ci = 5 if hl1==11
	replace relacion_ci = 6 if hl1==10
	tab relacion_ci

	**********
	*civil_ci*
	**********
	gen	byte civil_ci=.

	replace civil_ci=1 if mu1==1
	replace civil_ci=2 if mu1==2
	replace civil_ci=3 if mu1==3 | mu1==5
	replace civil_ci=4 if mu1==4

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
	gen byte miembros_ci=(relacion_ci>=1 & relacion_ci<5) 
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
	egen byte nmiembros_ch=sum(relacion_ci>0 & relacion_ci<=4), by(idh_ch)

	*************
	*nmayor21_ch*
	*************
	egen byte nmayor21_ch=sum((relacion_ci>=1 & relacion_ci<=4) & (edad_ci>=21 & edad_ci!=.)), by(idh_ch) 

	*************
	*nmenor21_ch*
	*************
	egen byte nmenor21_ch=sum((relacion_ci>=1 & relacion_ci<=4) & (edad_ci<21)), by(idh_ch) 

	*************
	*nmayor65_ch*
	*************
	egen byte nmayor65_ch=sum((relacion_ci>=1 & relacion_ci<=4) & (edad_ci>=65 & edad_ci!=.)), by(idh_ch) 

	************
	*nmenor6_ch*
	************
	egen byte nmenor6_ch=sum((relacion_ci>0 & relacion_ci<9) & (edad_ci<6)), by(idh_ch) 

	************
	*nmenor1_ch*
	************
	egen byte nmenor1_ch=sum((relacion_ci>0 & relacion_ci<9) & (edad_ci<1)), by(idh_ch) 


************************************
*** 3. Diversidad (11 variables) ***
************************************		

	*********
	*afro_ci*
	*********
	gen byte afro_ci = . 	  // se queda como missing (.) si no existe la pregunta
	replace afro_ci =1 if inlist(ethnicity_abridged,2,4)
	replace afro_ci =0 if inlist(ethnicity_abridged,1,3,5,6,7,8,9)
	
	*********
	*indi_ci*
	*********	
	gen byte ind_ci =. 		  // se queda como missing (.) si no existe la pregunta
	replace ind_ci =1 if inlist(ethnicity_abridged,3,4)
	replace ind_ci =0 if inlist(ethnicity_abridged,1,2,5,6,7,8,9)

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
	replace afroind_ci=2 if afro_ci==1 //  Garifunas son afros en Belice ////////
	replace afroind_ci=3 if noafroind_ci==1

	
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
	*La encuesta cuenta con las 4 escalas, pero la version de Sep2024 la codifica y genera una dummie binaria que cumple el criterio estricto de WG. Actualizar si se llega a disponer de la data. Por tanto, se calcula disWG_ci
	gen byte dis_ci=. 
	
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	replace disWG_ci=1 if dh1_rec==2 | dh2_rec==2 | dh3_rec==2 | dh4_rec==2 | dh5_rec==2 | dh6_rec==2
	replace disWG_ci=0 if dh1_rec==1 & dh2_rec==1 & dh3_rec==1 & dh4_rec==1 & dh5_rec==1 & dh6_rec==1 
/*	Se calcula en caso tengamos las variables en escala
	replace disWG_ci=1 if ...
	replace disWG_ci=0 if ...
*/
	
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
	gen byte migrante_ci=0 
	replace migrante_ci=1 if inrange(cob,124,907)
	replace migrante_ci=. if inlist(cob,9999)
	 	
	****************
    *migantiguo5_ci*
    ****************
	*El censo fue en el 2022, se toma migrante antiguo hasta el 2017
	gen byte migrantiguo5_ci=0
	replace migrantiguo5_ci=1 if (migrante_ci==1 & mig8a==7) | (migrante_ci==1 & mig9<=4) 
	replace migrantiguo5_ci=. if migrante_ci==0 | inlist(cob,9999) 
	
	***********
	*miglac_ci*
	***********
	gen byte miglac_ci=0
	replace miglac_ci=1 if  migrante_ci==1 & inlist(cob,222,320,340,388,484,558,903,905,906)
	replace miglac_ci=. if migrante_ci!=1

***********************************
*** 5. Educación (13 variables) ***
***********************************
	
	*********
	*aedu_ci*
	*********
	gen byte aedu_ci=.
	/*
	gen byte aedu_ci=0 if ...
	replace aedu_ci=1 if ...
	replace aedu_ci=2 if ...
	replace aedu_ci=3 if ...
	replace aedu_ci=4 if ...
	replace aedu_ci=5 if ...
	replace aedu_ci=6 if ...
	replace aedu_ci=7 if ...
	replace aedu_ci=8 if ...
	replace aedu_ci=9 if ...
	replace aedu_ci=10 if ...
	replace aedu_ci=11 if ...
	replace aedu_ci=12 if ...
	replace aedu_ci=. if ...
	replace aedu_ci=18 if ...
	*/
	
	**********
	*eduno_ci*
	**********
	gen byte eduno_ci=.
	
/*
	replace eduno_ci=(aedu_ci==0) 
	replace eduno_ci=. if aedu_ci==. 
*/

	**********
	*edupi_ci*
	**********
	gen byte edupi_ci=.
/*
	replace edupi_ci=(aedu_ci>=1 & aedu_ci<=...) 
	replace edupi_ci=. if aedu_ci==. 
*/

	**********
	*edupc_ci*
	**********
	gen byte edupc_ci=.
/*
	replace  edupc_ci=(aedu_ci==...) 
	replace edupc_ci=. if aedu_ci==. 
*/

	**********
	*edusi_ci*
	**********
	gen byte edusi_ci=.
/*
	replace edusi_ci=(aedu_ci>=... & aedu_ci<=...) 
	replace edusi_ci=. if aedu_ci==. 
*/

	**********
	*edusc_ci*
	**********
	gen byte edusc_ci=.
/*
	replace edusc_ci=(aedu_ci==...) 
	replace edusc_ci=. if aedu_ci==. 
*/

	***********
	*edus1i_ci*
	***********
	gen byte edus1i_ci=.
/*
	replace edus1i_ci=(aedu_ci>... & aedu_ci<...)
	replace edus1i_ci=. if aedu_ci==. 
*/

	***********
	*edus1c_ci*
	***********
	gen byte edus1c_ci=.
/*
	replace edus1c_ci=(aedu_ci==...)
	replace edus1c_ci=. if aedu_ci==. 
*/

	***********
	*edus2i_ci*
	***********
	gen byte edus2i_ci=.
/*
	replace edus2i_ci=(aedu_ci>... & aedu_ci<...)
	replace edus2i_ci=. if aedu_ci==. 
*/ 

	***********
	*edus2c_ci*
	***********
	gen byte edus2c_ci=.
/*
	replace edus2c_ci=(aedu_ci>=...)
	replace edus2c_ci=. if aedu_ci==. 
*/

	***********
	*edupre_ci*
	***********
	gen byte edupre_ci=.
/*
	replace edupre_ci= ...
	replace edupre_ci=. if aedu_ci==.
*/
	
	***********
	*asiste_ci*
	***********
	*Tomaremos en cuenta la asistencia full time y part-time
	gen byte asiste_ci=.
	replace asiste_ci=1 if inrange(ed1,1,2)
	replace asiste_ci=0 if ed1==3

	**********
	*literacy*
	**********
	gen byte literacy=.
		
****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

    *************
    *condocup_ci*
    *************
    gen byte condocup_ci=.
	
/*
	replace condocup_ci=1 if ...	//ocupados
	replace condocup_ci=2 if ...	//desocupados	
	replace condocup_ci=3 if ...	//inactivos
	replace condocup_ci=4 if ...	//no responde por ser menor de edad
*/
	
	********
    *emp_ci*
    ********
	gen byte emp_ci=.
/*
	replace emp_ci=(condocup_ci==1) if condocup_ci!=.
*/

	***********
    *desemp_ci*
    ***********	
	gen byte desemp_ci=.
/*
	replace desemp_ci=(condocup_ci==2) if condocup_ci!=.
*/

	********
    *pea_ci*
    ********
	gen byte pea_ci=.
/*
	replace pea_ci=1 if inlist(condocup_ci,1,2)
	replace pea_ci=0 if inlist(condocup_ci,3,4)
*/

	*******************
    *rama de actividad*
    *******************
	gen byte rama_ci = . 
/*
    replace rama_ci = 1 if ... & emp_ci==1
    replace rama_ci = 2 if ... & emp_ci==1
    replace rama_ci = 3 if ... & emp_ci==1
    replace rama_ci = 4 if ... & emp_ci==1   
    replace rama_ci = 5 if ... & emp_ci==1 
    replace rama_ci = 6 if ... & emp_ci==1   
    replace rama_ci = 7 if ... & emp_ci==1  
    replace rama_ci = 8 if ... & emp_ci==1   
    replace rama_ci = 9 if ... & emp_ci==1
    replace rama_ci = 10 if ... & emp_ci==1
    replace rama_ci = 11 if ... & emp_ci==1
    replace rama_ci = 12 if ... & emp_ci==1
    replace rama_ci = 13 if ... & emp_ci==1
    replace rama_ci = 14 if ... & emp_ci==1
    replace rama_ci = 15 if ... & emp_ci==1
*/
	
	**************
    *categopri_ci*
    **************
	gen byte categopri_ci=.
/*
	replace categopri_ci=0 if ... & emp_ci==1
	replace categopri_ci=1 if ... & emp_ci==1
	replace categopri_ci=2 if ... & emp_ci==1
	replace categopri_ci=3 if ... & emp_ci==1
	replace categopri_ci=4 if ... & emp_ci==1
*/
	 
	*************
    *spublico_ci*
    *************
	gen byte spublico_ci=.
/*
	replace spublico_ci=1 if emp_ci==1 & rama_ci==10
	replace spublico_ci=0 if emp_ci==1 & rama_ci!=10 & rama_ci!=.
	replace 
*/
		
		
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************		

	********
	*luz_ch*
	********
	gen byte luz_ch=.
	replace luz_ch=1 if inrange(hh18,1,4)
	replace luz_ch=0 if inrange(hh18,5,8)

	*********
	*piso_ch*
	*********
	*Entre las alternativas, esta la opcion "Earth/sand" la colocamos como no permanente
	gen byte piso_ch=.
	replace piso_ch = 1 if inlist(hh9,4,8)
	replace piso_ch = 2 if inlist(hh9,1,2,3,5)
	
	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	replace pared_ch=1 if inlist(hh7,1,2,4,8,10)
	replace pared_ch=2 if inlist(hh7,3,5,6,7,9)

	**********
	*techo_ch*
	**********
	gen byte techo_ch=.
	replace techo_ch=1 if inlist(hh8,9)
	replace techo_ch=2 if inlist(hh8,1,2,3,4,5,6,7,8)

	**********
	*resid_ch*
	**********
	gen byte resid_ch=.
	replace resid_ch=0 if inlist(hh12,7,8)
	replace resid_ch=1 if inlist(hh12,4,6)
	replace resid_ch=2 if inlist(hh12,1,2,5)
	replace resid_ch=3 if inlist(hh12,3,88)

	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=.
	replace dorm_ch=hh5

	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=.
	replace cuartos_ch=hh6 
	
	***********
	*cocina_ch*
	***********
	*Existe una pregunta sobre la instalacion de la cocina, pero no si existe un espacio exclusivo
	gen byte cocina_ch=.
/*
	replace cocina_ch=1 if ...
	replace cocina_ch=0 if ...
*/
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch=.
	replace telef_ch=1 if hh22b==1
	replace telef_ch=0 if hh22b==2
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=.
	replace refrig_ch=1 if hh21b==1
	replace refrig_ch=0 if hh21b==0
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
/*
	replace auto_ch=1 if ...
	replace auto_ch=0 if ...
*/

	**********
	*compu_ch*
	**********
	gen byte compu_ch=.
	replace compu_ch=1 if hh21m==1
	replace compu_ch=0 if hh21m==0

	*************
	*internet_ch*
	************* 
	gen byte internet_ch=.
	replace internet_ch=1 if hh23==1
	replace internet_ch=0 if hh23==2

	********
	*cel_ch*
	********
	gen byte cel_ch=.
	replace cel_ch=1 if hh21l==1
	replace cel_ch=0 if hh21l==0

	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch1=.
	replace viviprop_ch=1 if inlist(hh2,1,2)
	replace viviprop_ch=0 if inlist(hh2,3,4,5,6,7,8)

***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	************
	*aguaentubada_ch*
	************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch=1 if inlist(hh13,1,2,3,4)
	replace aguaentubada_ch=0 if inlist(hh13,5,6,7,8,9,10,88)
		
	************
	*aguared_ch*
	************
	gen aguared_ch=.
	replace aguared_ch = 1 if inlist(hh13,1,2)
	replace aguared_ch = 0 if inlist(hh13,3,4,5,6,7,8,9,10,88)
	
    	***************
	*aguafuente_ch*
	***************
	gen aguafuente_ch=.
	replace aguafuente_ch = 1 if inlist(hh15,2,3,4)
	replace aguafuente_ch = 2 if inlist(hh15,5)
	replace aguafuente_ch = 3 if inlist(hh15,1)
	replace aguafuente_ch = 4 if inlist(hh15,7)
	replace aguafuente_ch = 6 if inlist(hh15,6)
	replace aguafuente_ch = 7 if inlist(hh15,9) | (hh15== 11 & inlist(hh14,1,2,3,4,5,6) )
	replace aguafuente_ch = 8 if inlist(hh15, 10) | (hh15== 11 & hh14==9)
	replace aguafuente_ch = 9 if (hh15== 11 & inlist(hh14,7) )
	replace aguafuente_ch = 10 if inlist(hh15, 12,88) | (hh15== 11 & inlist(hh14,11,88))
		
	*************
	*aguadist_ch*
	*************
	gen aguadist_ch=.
	replace aguadist_ch = 1 if inlist(hh15, 2)
	replace aguadist_ch = 2 if inlist(hh15, 3,4)
	replace aguadist_ch = 3 if inlist(hh15, 5)
	replace aguadist_ch = 0 if inlist(hh15, 1,6,7,8,9,10,11,12)
	
	**************
	*aguadisp1_ch*
	**************
	gen aguadisp1_ch =9 
	
	**************
	*aguadisp2_ch*
	**************
	gen aguadisp2_ch =9
	
	*************
	*aguamide_ch*
	*************
	gen aguamide_ch = 9
		
	*********
	*bano_ch*
	*********
	gen bano_ch = . 
	replace bano_ch = 0 if hh16a == 2 
	replace bano_ch = 1 if  hh16a == 1 & hh16b == 1
	replace bano_ch = 2 if  hh16a == 1 & hh16b == 2
	replace bano_ch = 3 if  hh16a == 1 & inlist(hh16b,3)
	replace bano_ch = 6 if hh16a == 1 & inlist(hh16b,4,5,6,8)
	
	***********
	*banoex_ch*
	***********
	gen banoex_ch =.
	replace banoex_ch = 0 if hh16a == 1
	replace banoex_ch = 1 if hh16d == 2

	************
	*sinbano_ch*
	************
	gen sinbano_ch =.
	replace sinbano_ch = 0 if hh16a == 1
	replace sinbano_ch = 1 if hh16a == 2 & inlist(hh16b,1,2,3,4,5,6,8)
	replace sinbano_ch = 2 if hh16a == 2 & inlist(hh16b,7)
	
	*********
	*conbano_ch*
	*********
	gen byte conbano_ch=.
	replace conbano_ch=1 if hh16a==1 & inrange(hh16b,1,6)
	replace conbano_ch=0 if hh16a==2 | inrange(hh16b,7,8)

	*****************
	*banoalcantarillado_ch*
	*****************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch=1 if inrange(hh16b,1,2)
	replace banoalcantarillado_ch=0 if hh16a==2 | inrange(hh16b,3,8) 
	
	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	replace des1_ch=0 if bano_ch==0
	replace des1_ch=1 if inrange(hh16b,1,1)
	replace des1_ch=2 if inrange(hh16b,2,8)


*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.
   
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte BLZ_m_pared_ch= hh7
	label var BLZ_m_pared_ch  "Material de las paredes según el censo del país - variable original"
	label copy labels8 BLZ_m_pared_ch, replace
	label val BLZ_m_pared_ch  BLZ_m_pared_ch 

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte BLZ_m_piso_ch= hh9
	label var BLZ_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	label copy labels10 BLZ_m_piso_ch, replace
	label val BLZ_m_piso_ch  BLZ_m_piso_ch 
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte BLZ_m_techo_ch= hh8
	label var BLZ_m_techo_ch  "Material del techo según el censo del país - variable original"
	label copy labels9 BLZ_m_techo_ch, replace
	label val BLZ_m_techo_ch BLZ_m_techo_ch 
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long BLZ_ingreso_ci = .
	label var BLZ_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long BLZ_ingresolab_ci = .
	label var BLZ_ingreso_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte BLZ_dis_ci = .
	label var BLZ_dis_ci  "Individuos con discapacidad según el censo del país - variable original"
	label def BLZ_dis_ci 1 "Sí" 0 "No"   //categorías originales del país
	label val BLZ_dis_ci BLZ_dis_ci
	

/*******************************************************************************
   III. Incluir variables externas
*******************************************************************************/
capture drop _merge
merge m:1 pais_c anio_c using "$ruta\5_International_Poverty_Lines_LAC_long.dta", keepusing (ppp_2011 cpi_2011 lp19_2011 lp31_2011 lp5_2011 tc_wdi ppp_wdi2011 lp365_2017 lp685_2017)

drop if _merge ==2

g tc_c     = tc_wdi
g ipc_c    = cpi_2011
g lp19_ci  = lp19_2011 
g lp31_ci  = lp31_2011 
g lp5_ci   = lp5_2011

capture label var tc_c "Tasa de cambio LCU/USD Fuente: WB/WDI"
capture label var ipc_c "Índice de precios al consumidor base 2011=100 Fuente: IMF/WEO"
capture label var lp19_ci  "Línea de pobreza USD1.9 día en moneda local a precios corrientes a PPA 2011"
capture label var lp31_ci  "Línea de pobreza USD3.1 día en moneda local a precios corrientes a PPA 2011"
capture label var lp5_ci "Línea de pobreza USD5 por día en moneda local a precios corrientes a PPA 2011"

drop ppp_2011 cpi_2011 lp19_2011 lp31_2011 lp5_2011 tc_wdi ppp_wdi2011 _merge


/*******************************************************************************
   IV. Revisión de que se hayan creado todas las variables
*******************************************************************************/
* CALIDAD: revisa que hayas creado todas las variables. Si alguna no está
* creada, te apacerá en rojo el nombre. 

global lista_variables region_BID_c region_c geolev1 pais_c anio_c idh_ch idp_ci factor_ci factor_ch estrato_ci upm zona_c sexo_c edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch miembros_ci clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch afro_ci ind_ci noafroind_ci afroind_ci afro_ch ind_ch noafroind_ch afroind_ch  dis_ci disWG_ci dis_ch migrante_ci migrantiguo5_ci miglac_ci aedu_ci eduno_ci edupi_ci edupc_ci edusi_ci edusc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci edupre_ci asiste_ci literacy condocup_ci emp_ci desemp_ci pea_ci rama_ci  categopri_ci spublico_ci luz_ch piso_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch1 aguaentubada_ch aguared_ch aguafuente_ch aguadist_ch aguadisp1_ch aguadisp2_ch aguamide_ch bano_ch banoex_ch banoalcantarillado_ch sinbano_ch conbano_ch des1_ch ${PAIS}_ingreso_ci ${PAIS}_ingresolab_ci ${PAIS}_m_pared_ch ${PAIS}_m_piso_ch ${PAIS}_m_techo_ch ${PAIS}_dis_ci tc_c ipc_c lp19_ci lp31_ci lp5_ci

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

keep  $lista_variables dwelling_id hh_id individual__id

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
