* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: BARBADOS
Año: 2010
Autores: Mayte Ysique
Última versión: 30DIC2023
División: GDI/SCL - IADB
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
global PAIS BRB    				 //cambiar
global ANIO 2010   				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using `"$log_file"' , replace  //agregar ,replace si ya está creado el log_file en tu carpeta

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
	gen byte region_BID_c = 2
	
	*********
	*region_c
	*********
	gen region_c = parish

	***************
	*** geolev1 ***
	***************
	/*
	PARISH:
           1 St. Michael
           2 Christ Church
           3 St. George
           4 St. Philip
           5 St. John
           6 St. James
           7 St. Thomas
           8 St. Joseph
           9 St. Andrew
          10 St. Peter
          11 St. Lucy 
	Nuevo código: creado por SCLData, pues IPUMS no tiene código para BRB*/
	gen long geolev1=. 
	replace geolev1=520001 if parish==1
	replace geolev1=520002 if parish==2
	replace geolev1=520003 if parish==3
	replace geolev1=520004 if parish==4
	replace geolev1=520005 if parish==5
	replace geolev1=520006 if parish==6
	replace geolev1=520007 if parish==7
	replace geolev1=520008 if parish==8
	replace geolev1=520009 if parish==9
	replace geolev1=520010 if parish==10
	replace geolev1=520011 if parish==11
	
    *********
	*pais_c*
	*********
	gen str3 pais_c = "BRB"

    *********
	*anio_c*
	*********
	gen int anio_c = 2010

    ******************
    *idh_ch (id hogar)*
    ******************
	egen idh_ch = group(ed building dwelling_unit household) 
	tostring idh_ch, replace

	*********************
    *idp_ci (idpersonas)*
    *********************
	egen idp_ci = group(ed building dwelling_unit household id_person) 
	tostring idp_ci, replace

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
	
	*****
	*upm*
	*****
	gen byte upm =.
	
    ********
	*Zona_c*
	********
	gen byte zona_c=.
	

************************************
*** 2. Demografía (18 variables) ***
************************************
	
    ********
	*sexo_c*
	********
	gen byte sexo_ci = sex
	
	*********
	*edad_c*
	*********
	gen int edad_ci = age

 	*************
	*relacion_ci*
	*************	
	gen byte relacion_ci=. 
	replace relacion_ci=1 if rth==0 // Jefe
	replace relacion_ci=2 if rth==1 // Conyuge, esposa, companero
	replace relacion_ci=3 if rth==3  // Hijo/a
	replace relacion_ci=4 if rth==4 | rth==5 | rth==6 // Otros parientes
	replace relacion_ci=5 if rth==7 | rth==8 // Otros no parientes
			
	**********
	*civil_ci*
	**********
	gen byte civil_ci=.
	replace civil_ci=1 if p9==5
	replace civil_ci=2 if p9==1
	replace civil_ci=3 if p9==2 | p9==3
	replace civil_ci=4 if p9==3
	replace civil_ci=. if p9==9

    *********
	*jefe_ci*
	*********
	gen byte jefe_ci=(relacion_ci==1)           
	replace jefe_ci=. if relacion_ci == 99
	
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
	replace afroind_ci=2 if p10==1
	replace afroind_ci=3 if inrange(p10,2,9)

	*********
	*afro_ch*
	*********
	gen byte afro_ch =.
	
	********
	*ind_ch*
	********	
	gen byte ind_ch = .

	**************
	*noafroind_ch*
	**************
	gen byte noafroind_ch =.
	
	***************
	***afroind_ch**
	***************
    gen byte afroind_jefe= afroind_ci if jefe_ci==1
	egen byte afroind_ch  = min(afroind_jefe), by(idh_ch) 
	drop afroind_jefe 

	************
	***dis_ci***
	************
	gen byte dis_ci=. 

	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	
	************
	***dis_ch***
	************
	bysort idh_ch: egen byte dis_ch  = max(dis_ci)

**********************************
*** 4. Migración (3 variables) ***
**********************************	

    *******************
    ****migrante_ci****
    *******************
	gen byte migrante_ci =(p15a==2)
	
	*******************
    **migrantiguo5_ci**
    *******************
	gen byte migrantiguo5_ci =(p16b<=2005) if p16b!=9999
	replace migrantiguo5_ci=. if migrante_ci==0
	
	**********************
	****** miglac_ci *****
	**********************
	gen byte miglac_ci = (inlist(p16a_country,24,35,28,26,27,25,994,29,55,34,992) | inrange(p16a_country,3,22)) if migrante_ci==1
	
***********************************
*** 5. Educación (13 variables) ***
***********************************

	*************
	***aedu_ci***
	*************
	gen byte aedu_ci = .

	**************
	***eduno_ci***
	**************
	gen byte eduno_ci=(p22==8) if edad_ci>=3 // never attended or pre-school
	replace eduno_ci=. if  p22==9 | p22==. // NIU & missing

	**************
	***edupi_ci***
	**************
	gen byte edupi_ci=.

	**************
	***edupc_ci***
	**************
	gen byte edupc_ci=(p22==2) if edad_ci>=3 //
	replace eduno_ci=. if  p22==9 | p22==. // NIU & missing

	**************
	***edusi_ci***
	**************
	gen byte edusi_ci=.
	
	**************
	***edusc_ci***
	**************
	gen byte edusc_ci=(p22==3) if edad_ci>=3 //
	replace eduno_ci=. if  p22==9 | p22==. // NIU & missing

	***************
	***edus1i_ci***
	***************
	gen byte edus1i_ci=.

	***************
	***edus1c_ci***
	***************
	gen byte edus1c_ci=.

	***************
	***edus2i_ci***
	***************
	gen byte edus2i_ci=.

	***************
	***edus2c_ci***
	***************
	gen byte edus2c_ci=.

	**************
	***edupre_ci**
	**************
	gen byte edupre_ci=(p22==1) if edad_ci>=3 //
	replace edupre_ci=. if  p22==9 | p22==. // NIU & missing
	
	***************
	***asiste_ci***
	***************
	gen byte asiste_ci=(p20a==1)
		replace asiste_ci=. if p20a==9
	label variable asiste_ci "Asiste actualmente a la escuela"

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
	replace condocup_ci=1 if inlist(p34,1,2)
	replace condocup_ci=2 if p34==3
	replace condocup_ci=3 if inrange(p34,6,8)
	replace condocup_ci=4 if edad_ci<14
	
	************
    ***emp_ci***
    ************
    gen byte emp_ci=.
	replace emp_ci=1 if condocup_ci==1
	replace emp_ci=0 if condocup_ci==2
	
	****************
    ***desemp_ci***
    ****************	
	gen byte desemp_ci=.
	replace desemp_ci=1 if condocup_ci==2
	replace desemp_ci=0 if condocup_ci==1 | condocup_ci==3
	
	*************
    ***pea_ci***
    *************
    gen byte pea_ci=.
	replace pea_ci=1 if condocup_ci==1
	replace pea_ci=1 if condocup_ci==2
	replace pea_ci=0 if condocup_ci==3
	replace pea_ci=0 if condocup_ci==4
	
	*************************
    ****rama de actividad****
    *************************
	*p37_occupationcode (ISIC Rev 4)
    gen byte rama_ci = .
	replace rama_ci= 1 if p38_industrycode>=110 & p38_industrycode<=490
	replace rama_ci = 2 if p38_industrycode>=510 & p38_industrycode<=990
	replace rama_ci = 3 if p38_industrycode>=1010 & p38_industrycode <=3390
	replace rama_ci = 4 if p38_industrycode>=3510 & p38_industrycode<=3900
	replace rama_ci = 5 if p38_industrycode>=4100 & p38_industrycode<=4390
	replace rama_ci = 6 if p38_industrycode>=4510 & p38_industrycode<=4799
	replace rama_ci = 7 if p38_industrycode>=5510 & p38_industrycode<=5630 
	replace rama_ci = 8 if (p38_industrycode>=4911 & p38_industrycode<= 5320) | (p38_industrycode>=5811 & p38_industrycode<= 6399) 
	replace rama_ci = 9 if p38_industrycode>=6411 & p38_industrycode<= 6630
	replace rama_ci = 10 if p38_industrycode>=8400 & p38_industrycode<=8499
	replace rama_ci = 11 if p38_industrycode>=6800 & p38_industrycode <=7599
	replace rama_ci = 12 if p38_industrycode>=8500 & p38_industrycode<=8599
	replace rama_ci = 13 if p38_industrycode>=9000 & p38_industrycode<=9399
	replace rama_ci = 14 if (p38_industrycode>=7700 & p38_industrycode<=829999) | (p38_industrycode>=9400 & p38_industrycode<=9699) | p38_industrycode>=9900
	replace rama_ci = 15 if p38_industrycode>=9700 & p38_industrycode<=9899
/*
El codigo se encuentra en CIIU Rev 4. Se armonizo los grandes grupos de industrias

1	Agricultura, pesca y forestal - Agriculture, hunting, forestry and fishing
2	Minería y extracción - Exploitation of mines and quarries
3	Industrias manufactureras - Manufacturing industries
4	Electricidad, gas, agua y manejo de residuos - Electricity, gas and water
5	Construcción - Construction
6	Comercio - Commerce
7	Hoteles y restaurantes - Restaurants and hotels
8	Transporte, almacenamiento y comunicaciones - Transportation, storage and communications
9	Servicios financieros y seguros - Financial and insurance establishments
10	Administración pública y defensa - Public administration and defense
11	Servicios empresariales e inmobiliarios - Business and real estate services
12	Educación - Education
13	Salud y trabajo social - Social, community and personal services
14	Otros servicios - Other services
15	Servicio doméstico - Domestic work
*/
	** REVISAR **
/*

*/
	label var rama_ci "Economic Sector"
	label define rama_ci 							///
	1"Agriculture, hunting, forestry and fishing"	///
	2"Exploitation of mines and quarries"	        ///
	3"Manufacturing industries"	          	  		///
	4"Electricity, gas and water"	          		///
	5"Construction"	          						///
	6"Commerce"	      								///
	7"Restaurants and hotels"	          			///
	8"Transportation, storage and communications"   ///
	9"Financial and insurance establishments"	    ///
	10"Public administration and defense"	        ///
	11"Business and real estate services"	        ///
	12"Education"	          						///
	13"Social, community and personal services"	    ///
	14"Other services"	      						///
	15"Domestic work", replace
	label val rama_ci rama_ci
	
		
	*********************
    ****categopri_ci****
    *********************
	*
	/*
OBSERVACIONES: 
- El censo no distingue entre actividad principal o secundaria, asigno por default principal.
- No se tomo en cuenta por las categorias, la opcion "Patron o empleador"
- Para la categoria "Cuenta propia o independiente", se tomo en cuenta: 
	*With Paid Help (6)
	*With Unpaid Help (7)
- Para la categoria "Empleado o Asalariado", se tomo en cuenta: 
	*Government (1)
	*Private Enterprise (2)
	*Private Household (3)
	*Other (4)
- Para la categoria "Trabajador no remunerado", se tomo en cuenta: 
	*Unpaid Worker (5)
- Tener en cuenta que existe la opcion "Did not work" (8) que no se tomo en cuenta (y a veces no se condice con la variable p34)
	*/
	gen byte categopri_ci=.
	replace categopri_ci=0 if p35==9 | p35==99
	replace categopri_ci=2 if p35==6 | p35==7
	replace categopri_ci=3 if p35<=4
	replace categopri_ci=4 if emp_ci==1 & p35==5
	replace categopri_ci=. if emp_ci==0 | emp_ci==.
	 
	 
	*****************
    ***spublico_ci***
    *****************
    gen byte spublico_ci=(p35==1) if emp_ci==1


**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************		
	
	********
	*luz_ch*
	********
	gen byte luz_ch=(h20a==1) if h20a!=9

	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
		
	**********
	*pared_ch*
	**********
	gen byte pared_ch=(inrange(h9,1,6)) if h9!=9
	
	**********
	*techo_ch*
	**********
	gen byte techo_ch=inrange(h10,1,6) if h10!=9
	
	**********
	*resid_ch*
	**********
	gen byte resid_ch=. 

	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=h13 if h13!=99
	
	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=.
	
	***********
	*cocina_ch*
	***********
	gen byte cocina_ch=.
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch=(h21a1_fixed_line_telephone==1 | h21a2_fixed_line_telephone==1 )
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=(h21a1_refrigerator==1 | h21a2_refrigerator==1 )
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	
	********
	*compu_ch*
	********
	gen byte compu_ch=(h21a1_computer==1 | h21a2_computer==1 )
	
	*************
	*internet_ch*
	************* 
	gen byte internet_ch=(h21b1==1)
	
	********
	*cel_ch*
	********
	bysort idh_ch: egen byte cel_ch=max(p26_cellularphone)
	
	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch=(h15a==1) if h15a!=9

***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	
		
	*****************
	*aguaentubada_ch*
	*****************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch =1 if inlist(h18,1,2)
	
	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	


	***************
	*aguafuente_ch*
	***************
	gen byte aguafuente_ch = .
	replace aguafuente_ch=2 if inlist(h18,4)
	replace aguafuente_ch=10 if inlist(h18,1,2,3,5,6,7)
	
	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch=.
	replace aguadist_ch =1 if h18==1
	replace aguadist_ch =2 if h18==2
	replace aguadist_ch = 3 if h18==4
	replace aguadist_ch = 0 if inlist(h18, 3,5,6)
	
	**************
	*aguadisp1_ch*
	**************
	gen byte aguadisp1_ch= 9
	
	**************
	*aguadisp2_ch*
	**************
	gen byte aguadisp2_ch= 9
	
	*************
	*aguamide_ch*
	*************
	gen byte aguamide_ch= 9
	
    *********
	*bano_ch*
	*********
	gen byte bano_ch= .
	replace bano_ch = 0 if h19a ==4
	replace bano_ch = 1 if h19a ==1
	replace bano_ch = 6 if inlist(h19a, 2,3,5,6)
	
	***********
	*banoex_ch*
	***********
	gen byte banoex_ch=.
	replace banoex_ch = 1 if h19b == 2
	replace banoex_ch = 0 if h19b == 1
	
	**************
	*sinbano_ch*
	**************
	gen byte sinbano_ch =.
	replace sinbano_ch =0 if inlist(h19a, 1,2,3,5,6)
	replace sinbano_ch =3 if inlist(h19a, 4)
	
	*********
	*conbano_ch*
	*********
	gen byte conbano_ch=.
	replace conbano_ch=1 if inlist(h19a,1,2,3,5,6)
	replace conbano_ch=0 if inlist(h19a, 4)
	
	***********************
	*banoalcantarillado_ch*
	***********************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch = 1 if h19a ==1
	
	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	

*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.

	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte BRB_m_pared_ch= h9
	label var BRB_m_pared_ch  "Material de las paredes según el censo del país - variable original"

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte BRB_m_piso_ch= .
	label var BRB_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte BRB_m_techo_ch= h10
	label var BRB_m_techo_ch  "Material del techo según el censo del país - variable original"
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long BRB_ingreso_ci = .
	label var BRB_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	*Ingreso donde el periodo de pago es "Other", se considerara como missing
	gen ylm_ci=p40b if p40a==3
	replace ylm_ci=p40b*2 if p40a==2
	replace ylm_ci=p40b*4 if p40a==1
	replace ylm_ci=. if emp_ci!=1 | p40b==900999
	*gen ynlm_ci=.
	gen long BRB_ingresolab_ci = ylm_ci	
	label var BRB_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte BRB_dis_ci = .
	label var BRB_dis_ci  "Individuos con discapacidad según el censo del país - variable original"

/*******************************************************************************
   III. Incluir variables externas
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

drop  lp19_2011 lp31_2011 lp5_2011 tc_wdi _merge

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

keep  $lista_variables ed building dwelling_unit household id_person

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