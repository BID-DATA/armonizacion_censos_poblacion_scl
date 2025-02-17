* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: ...
Año: ...
Autores: ...
Última versión: ...
División: ... - IADB
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
global PAIS PER    				 //cambiar
global ANIO 2017   				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using `"$log_file"'  //agregar ,replace si ya está creado el log_file en tu carpeta

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
	gen byte region_BID_c = ...

	**********
	*region_c*   
	**********
	destring ..., replace
	gen byte region_c = ...
	label define region_c   ///
	1 "..." 			///  
	2 "..."	 			
	label value region_c region_c
	tab region_c
	
	*********
	*geolev1*
	*********
	gen long geolev1 =.  
	replace geolev1= ... if ... 
	replace geolev1= ... if ...   
	label define geolev1	///
	... "..." 			///
	... "..." 			
	label value geolev1 geolev1
	tab geolev1
	
    ********
	*pais_c*
	********
	gen str3 pais_c = "..." 

    ********
	*anio_c*
	********
	gen int anio_c = ...
	
    *******************
    *idh_ch (ID hogar)*
    *******************
	* generar variable de ID tipo string. cambiar el formato según corresponda.
	* usar comando group para obtener identificador o concat si corresponde
	* group(conglome vivienda hogar)
	* tostring ..., gen(idh_ch) format("%16.0f")	
	egen  idh_ch =concat(... ...) 	
	* revisar número de hogares
	egen unique_tag = tag(idh_ch)
	count if unique_tag == 1
	
	**********************
    *idp_ci (ID personas)*
    **********************
	* generar variable de ID tipo string. cambiar el formato según corresponda. Revisar que no existan duplicados en idp_ci.
	* tostring ..., gen(idp_ci) format("%16.0f")
	egen  idp_ci = concat(... ... ...) 
	duplicates report idh_ch idp_ci // CALIDAD: revisar que resultado sea copies =1
		
	****************************************
	*(factor_ci) factor expansión individio*
	****************************************
	gen factor_ci=...
	
	*******************************************
	*(factor_ch) Factor de expansion del hogar*
	*******************************************
	gen factor_ch=...
		
    ************
	*estrato_ci*
	************
	gen estrato_ci =...

	*****
	*upm*
	*****
	gen upm =...
	
    ********
	*Zona_c*
	********
	gen byte zona_c=.
	replace zona_c=1 if ...
	replace zona_c=0 if ...
	tab zona_c
	

************************************
*** 2. Demografía (18 variables) ***
************************************

    ********
	*sexo_c*
	********
	gen byte sexo_ci =.
	replace sexo_ci = 1 if ...
	replace sexo_ci = 2 if ...
	tab sexo_ci
	
	********
	*edad_c*
	********
	gen int edad_ci = ...
	replace edad_ci=. if ...
	tab edad_ci

	*************
	*relacion_ci*
	*************
	gen byte relacion_ci = .
	replace relacion_ci = 1 if ...
	replace relacion_ci = 2 if ...
	replace relacion_ci = 3 if ...
	replace relacion_ci = 4 if ...
	replace relacion_ci = 5 if ...
	replace relacion_ci = 6 if ...
	tab relacion_ci

	**********
	*civil_ci*
	**********
	gen	byte civil_ci=.
	replace civil_ci=1 if ...
	replace civil_ci=2 if ...
	replace civil_ci=3 if ...
	replace civil_ci=4 if ...

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
	replace afro_ci =1 if ...
	replace afro_ci =0 if ...
	
	*********
	*indi_ci*
	*********	
	gen byte ind_ci =. 		  // se queda como missing (.) si no existe la pregunta
	replace ind_ci =1 if ...
	replace ind_ci =0 if ...

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
	replace afroind_ci=3 if noafroind_ci = 1

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
	replace dis_ci=1 if ...
	replace dis_ci=0 if ...
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	replace disWG_ci=1 if ...
	replace disWG_ci=0 if ...
	
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
	replace migrante_ci=1 if ...
	replace migrante_ci=. if ...
	 	
	****************
    *migrantiguo5_ci*
    ****************
	gen byte migrantiguo5_ci=0
	replace migrantiguo5_ci=1 if ... 
	replace migrantiguo5_ci=. if ...
	
	***********
	*miglac_ci*
	***********
	gen byte miglac_ci=0
	replace miglac_ci=1 if ...  & migrante_ci ==1
	replace miglac_ci=. if migrante_ci!=1

***********************************
*** 5. Educación (13 variables) ***
***********************************
	
	*********
	*aedu_ci*
	*********
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

	
	**********
	*eduno_ci*
	**********
	gen byte eduno_ci=(aedu_ci==0) 
	replace eduno_ci=. if aedu_ci==. 

	**********
	*edupi_ci*
	**********
	gen byte edupi_ci=(aedu_ci>=1 & aedu_ci<=...) 
	replace edupi_ci=. if aedu_ci==. 

	**********
	*edupc_ci*
	**********
	gen byte edupc_ci=(aedu_ci==...) 
	replace edupc_ci=. if aedu_ci==. 

	**********
	*edusi_ci*
	**********
	gen byte edusi_ci=(aedu_ci>=... & aedu_ci<=...) 
	replace edusi_ci=. if aedu_ci==. 

	**********
	*edusc_ci*
	**********
	gen byte edusc_ci=(aedu_ci==...) 
	replace edusc_ci=. if aedu_ci==. 

	***********
	*edus1i_ci*
	***********
	gen byte edus1i_ci=(aedu_ci>... & aedu_ci<...)
	replace edus1i_ci=. if aedu_ci==. 

	***********
	*edus1c_ci*
	***********
	gen byte edus1c_ci=(aedu_ci==...)
	replace edus1c_ci=. if aedu_ci==. 

	***********
	*edus2i_ci*
	***********
	gen byte edus2i_ci=(aedu_ci>... & aedu_ci<...)
	replace edus2i_ci=. if aedu_ci==. 

	***********
	*edus2c_ci*
	***********
	gen byte edus2c_ci=(aedu_ci>=...)
	replace edus2c_ci=. if aedu_ci==. 

	***********
	*edupre_ci*
	***********
	gen byte edupre_ci= ...
	replace edupre_ci=. if aedu_ci==.
	
	***********
	*asiste_ci*
	***********
	gen byte asiste_ci=1 if ...
	replace asiste_ci=0 if ...
	replace asiste_ci=. if ...

	**********
	*literacy*
	**********
	gen byte literacy=1 if ...
	replace literacy=0 if ...
	replace literacy=. if ...
		
****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

    *************
    *condocup_ci*
    *************
    gen byte condocup_ci=.
	replace condocup_ci=1 if ...	//ocupados
	replace condocup_ci=2 if ...	//desocupados	
	replace condocup_ci=3 if ...	//inactivos
	replace condocup_ci=4 if ...	//no responde por ser menor de edad
	
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
	
	**************
    *categopri_ci*
    **************
	gen byte categopri_ci=.
	replace categopri_ci=0 if ... & emp_ci==1
	replace categopri_ci=1 if ... & emp_ci==1
	replace categopri_ci=2 if ... & emp_ci==1
	replace categopri_ci=3 if ... & emp_ci==1
	replace categopri_ci=4 if ... & emp_ci==1
	 
	*************
    *spublico_ci*
    *************
	gen byte spublico_ci=.
	replace spublico_ci=1 if emp_ci==1 & rama_ci==10
	replace spublico_ci=0 if emp_ci==1 & rama_ci!=10 & rama_ci!=.

		
		
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************		

	********
	*luz_ch*
	********
	gen byte luz_ch=.
	replace luz_ch=1 if ...
	replace luz_ch=0 if ...

	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
	replace piso_ch = 0 if ...
	replace piso_ch = 1 if ...
	replace piso_ch = 2 if ...
	
	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	replace pared_ch=1 if ...
	replace pared_ch=2 if ...

	**********
	*techo_ch*
	**********
	gen byte techo_ch=.
	replace techo_ch=0 if ...
	replace techo_ch=1 if ...
	replace techo_ch=2 if ...

	**********
	*resid_ch*
	**********
	gen byte resid_ch=.
	replace resid_ch=0 if ...
	replace resid_ch=1 if ...
	replace resid_ch=2 if ...
	replace resid_ch=3 if ...

	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=.
	replace dorm_ch=... 

	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=.
	replace cuartos_ch=... 
	
	***********
	*cocina_ch*
	***********
	gen byte cocina_ch=.
	replace cocina_ch=1 if ...
	replace cocina_ch=0 if ...
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch=.
	replace telef_ch=1 if ...
	replace telef_ch=0 if ...
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=.
	replace refrig_ch=1 if ...
	replace refrig_ch=0 if ...
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	replace auto_ch=1 if ...
	replace auto_ch=0 if ...

	**********
	*compu_ch*
	**********
	gen byte compu_ch=.
	replace compu_ch=1 if ...
	replace compu_ch=0 if ...

	*************
	*internet_ch*
	************* 
	gen byte internet_ch=.
	replace internet_ch=1 if ...
	replace internet_ch=0 if ...

	********
	*cel_ch*
	********
	gen byte cel_ch=.
	replace cel_ch=1 if ...
	replace cel_ch=0 if ...

	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch=.
	replace viviprop_ch=1 if ...
	replace viviprop_ch=0 if ...

***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	*****************
	*aguaentubada_ch*
	*****************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch= 1 if...
	replace aguaentubada_ch= 0 if...
	
	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch=1 if ...
	replace aguared_ch=0 if ...

    ***************
	*aguafuente_ch*
	***************
 	gen byte aguafuente_ch=.
	replace aguafuente_ch=1 if ...
	replace aguafuente_ch=2 if ...	
	replace aguafuente_ch=3 if ...	
	replace aguafuente_ch=4 if ...	
	replace aguafuente_ch=5 if ...	
	replace aguafuente_ch=6 if ...	
	replace aguafuente_ch=7 if ...	
	replace aguafuente_ch=8 if ...	
	replace aguafuente_ch=9 if ...	
	replace aguafuente_ch=10 if ...	
	
	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch= ...
	          
	**************
	*aguadisp1_ch*
	**************
	gen byte aguadisp1_ch = ...
		
	**************
	*aguadisp2_ch*
	**************
	gen byte aguadisp2_ch = ...
	
	*************
	*aguamide_ch*
	*************
	gen byte aguamide_ch = ...
	
	*********
	*bano_ch*
	*********
	gen byte bano_ch = . 
	replace bano_ch = 0 if ...
	replace bano_ch = 1 if ...
	replace bano_ch = 2 if ...
	replace bano_ch = 3 if ...
	replace bano_ch = 4 if ...
	replace bano_ch = 5 if ...
	replace bano_ch = 6 if ...
	
	***********
	*banoex_ch*
	***********
	gen byte banoex_ch = ...
	
	************
	*sinbano_ch*
	************
	gen byte sinbano_ch =.
	replace sinbano_ch = 0 if ...
	replace sinbano_ch = 1 if ...
	replace sinbano_ch = 2 if ...
	replace sinbano_ch = 3 if ...

	*********
	*conbano_ch*
	*********
	gen byte conbano_ch=.
	replace conbano_ch=1 if ...
	replace conbano_ch=0 if ...
	
	***********************
	*banoalcantarillado_ch*
	***********************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch=1 if ...
	replace banoalcantarillado_ch=0 if ...
		
	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	replace des1_ch=0 if ...
	replace des1_ch=1 if ...
	replace des1_ch=2 if ...


*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte ..._m_pared_ch= ...
	label var ..._m_pared_ch  "Material de las paredes según el censo del país - variable original"
	label def ..._m_pared_ch  1 "..." 2 "..." 3 "..."   //categorías originales del país
	lavel val ..._m_pared_ch  ..._m_pared_ch 

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte ..._m_piso_ch= ...
	label var ..._m_piso_ch  "Material de los pisos según el censo del país - variable original"
	label def ..._m_piso_ch  1 "..." 2 "..." 3 "..."   //categorías originales del país
	lavel val ..._m_piso_ch  ..._m_piso_ch 
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte ..._m_techo_ch= ...
	label var ..._m_techo_ch  "Material del techo según el censo del país - variable original"
	label def ..._m_techo_ch  1 "..." 2 "..." 3 "..."   //categorías originales del país
	lavel val ..._m_techo_ch ..._m_techo_ch 
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long ..._ingreso_ci = ...
	label var ..._ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long ..._ingresolab_ci = ...	
	label var ..._ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte ..._dis_ci = ...
	label var ..._dis_ci  "Individuos con discapacidad según el censo del país - variable original"
	label def ..._dis_ci 1 "Sí" 0 "No"   //categorías originales del país
	lavel val ..._dis_ci ..._dis_ci
	

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

keep  $lista_variables ... ... ...

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
