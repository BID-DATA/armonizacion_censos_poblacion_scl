* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: PARAGUAY
Año: 2012
Autores: Cecilia y Olga
Última versión: 24AGO2024
División: SCL/EDU - IADB
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
global PAIS PRY    				 //cambiar
global ANIO 2012				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using `"$log_file"', replace  //agregar ,replace si ya está creado el log_file en tu carpeta

use "$base_in", clear

*rename *, lower

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

	****************
    *** region_c ***
    ****************
	gen region_c=.   
	replace region_c=1 if DPTOD==1	/*Concepción*/
	replace region_c=2 if DPTOD==2	/*San Pedro*/
	replace region_c=3 if DPTOD==3	/*Cordillera*/
	replace region_c=4 if DPTOD==4	/*Guaira*/
	replace region_c=5 if DPTOD==5	/*Caaguazú*/
	replace region_c=6 if DPTOD==6	/*Caazapá*/
	replace region_c=7 if DPTOD==7	/*Itapúa*/
	replace region_c=8 if DPTOD==8	/*Misiones*/
	replace region_c=9 if DPTOD==9	/*Paraguarí*/
	replace region_c=10 if DPTOD==10	/*Alto Paraná*/
	replace region_c=11 if DPTOD==11	/*Central*/
	replace region_c=12 if DPTOD==12	/*Ñembuccú*/
	replace region_c=13 if DPTOD==13	/*Amambay*/
	replace region_c=14 if DPTOD==14	/*Canindeyú*/
	replace region_c=15 if DPTOD==15	/*Presidente Hayes*/
	replace region_c=16 if DPTOD==16	 /*Boquerón*/
	replace region_c=17 if DPTOD==17	/*Alto Paraguay*/
	replace region_c=18 if DPTOD==18	/*Asunción*/ 

	label define region_c ///
	 1	"Concepción" ///
	 2 "San Pedro" ///
	 3	"Cordillera" ///
	 4	"Guaira" ///
	 5	"Caaguazú" ///
	 6	"Caazapá" ///
	 7	"Itapúa" ///
	 8	"Misiones" ///
	 9	"Paraguarí" ///
	 10	"Alto Paraná" ///
	 11	"Central" ///
	 12	"Ñembuccú" ///
	 13	"Amambay" ///
	 14	"Canindeyú" ///
	 15	"Presidente Hayes" ///
	 16	"Boquerón" ///
	 17	"Alto Paraguay" ///
	 18 "Asunción"

	label value region_c region_c
	label var region_c "division politico-administrativa, departamento"
	
	***************
	**** geolev1 ****
	***************
	gen long geolev1=. 
	replace geolev1=600001 if DPTOD==1	/*Concepción*/
	replace geolev1=600002 if DPTOD==2	/*San Pedro*/
	replace geolev1=600003 if DPTOD==3	/*Cordillera*/
	replace geolev1=600004 if DPTOD==4	/*Guaira*/
	replace geolev1=600005 if inlist(DPTOD,5,10,14)	/*Caaguazú, Canindeyú, Alto Paraná*/
	replace geolev1=600006 if DPTOD==6	/*Caazapá*/
	replace geolev1=600007 if DPTOD==7	/*Itapúa*/
	replace geolev1=600008 if inlist(DPTOD,8,12)	/*Misiones*/
	replace geolev1=600009 if DPTOD==9	/*Paraguarí*/
	replace geolev1=600011 if DPTOD==11	/*Central*/
	replace geolev1=600013 if DPTOD==13	/*Amambay*/
	replace geolev1=600015 if inlist(DPTOD,15,16,17)	/*Alto Paraguay, Boquerón, Presidente Hayes*/
	replace geolev1=600019 if DPTOD==18	/*Asunción*/ 
	
	*********
	*pais_c*
	*********
    gen str3 pais_c="PRY"
	
	*********
	*anio_c*
	*********
	gen anio_c=2012
	
	******************
    *idh_ch (id hogar)*
    ******************
	gen idh_ch = ""
	
	******************
    *idp_ci (idpersonas)*
    ******************
	gen idp_ci = ""
	
	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
	gen factor_ci = FEX
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
	gen factor_ch = FEX
	
	***********
	* estrato *
	***********
	gen estrato_ci=.

	*****
	*upm*
	*****
	gen byte upm =.
	
	***************************
	* Zona urbana (1) o rural (0)
	***************************
	gen zona_c=.
	replace zona_c = 1 if inlist(AREA, 1, 3) // tomo suburbana como urbana 
	replace zona_c = 0 if AREA == 6
	

************************************
*** 2. Demografía (18 variables) ***
************************************
	
	*********
	*sexo_c*
	*********
    gen byte sexo_ci = .
	replace sexo_ci = 1 if P03 == 1
	replace sexo_ci = 2 if P03 == 6
	
	*********
	*edad_c*
	*********
	gen int edad_ci = P04A 

 	*************
	*relacion_ci*
	*************
	gen byte relacion_ci = . 
	replace relacion_ci = 1 if P02 == 1 // Jefe
    replace relacion_ci = 2 if P02 == 2 // Cónyugue/esposo/a/compañero/a
    replace relacion_ci = 3 if inlist(P02, 3, 4) // Hijo/a
    replace relacion_ci = 4 if inlist(P02, 5, 7, 8, 6, 9) //  Otros parientes
    replace relacion_ci = 5 if P02 ==10  // Otros no parientes
	replace relacion_ci = 6 if inlist(P02, 11, 12) // Domestic employee or family member of domestic employee 
	
	**************
	*Estado Civil*
	**************
	gen byte civil_ci = . 
	replace civil_ci = 1 if P24 == 6 // Soltero
	replace civil_ci = 2 if P24 == 2 // Union formal o infomral 
	replace civil_ci = 3 if inlist(P24, 4, 5) // Divorciado o separado
	replace civil_ci = 4 if P24 == 3 // Viudo
	
    *********
	*jefe_ci*
	*********
	gen byte jefe_ci=(relacion_ci==1)
	replace jefe_ci=. if relacion_ci == .
	
	**************
	*nconyuges_ch*
	**************
	gen byte nconyuges_ch=.
	
	***********
	*nhijos_ch*
	***********
	gen byte nhijos_ch=.
	
	**************
	*notropari_ch*
	**************
	gen byte notropari_ch=.
	
	****************
	*notronopari_ch*
	****************
	gen byte notronopari_ch=.
	
	************
	*nempdom_ch*
	************
	gen byte nempdom_ch=.

	****************
	***miembros_ci***
	****************
	gen byte miembros_ci = (relacion_ci <= 5)
		
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
	
	******************
	***nmiembros_ch***
	******************
	gen byte nmiembros_ch = .

	*****************
	***nmayor21_ch***
	*****************
	gen byte nmayor21_ch= .

	*****************
	***nmenor21_ch***
	*****************
	gen byte nmenor21_ch= .

	*****************
	***nmayor65_ch***
	*****************
	gen byte nmayor65_ch= .

	****************
	***nmenor6_ch***
	****************
	gen byte nmenor6_ch= .

	****************
	***nmenor1_ch***
	****************
	gen byte nmenor1_ch= .


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
	replace afroind_ci = 1 if P42A == 1
	replace afroind_ci = 3 if P42A == 6 
	replace afroind_ci = 2 if P43 == 1

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
	gen byte afroind_jefe= afroind_ci if relacion_ci==1
	gen afroind_ch  = . 
	label var afroind_ch "Raza/etnia del hogar en base a raza/etnia del jefe de hogar"
	drop afroind_jefe

	********
	*dis_ci*
	********
	gen byte dis_ci = . 
	replace dis_ci = 1 if (inrange(P09, 1, 3) | inrange(P10, 1, 3) ///
	| inrange(P11, 1, 3) | inrange(P12, 1, 3) | inrange(P13, 1, 3))
	replace dis_ci = 0 if (P09 == 4 | P10 == 4 | P11 == 4 | P12 == 4 ///
	| P13 == 4)
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 

	********
	*dis_ch*
	********
	gen byte dis_ch = . 

	
**********************************
*** 4. Migración (3 variables) ***
**********************************		

    *******************
    ****migrante_ci****
    *******************
	gen byte migrante_ci =.
	replace migrante_ci = 1 if P14A == 3
	replace migrante_ci = 0 if inlist(P14A, 1, 2)
   
	*******************
    **migrantiguo5_ci**
    *******************
	gen byte migrantiguo5_ci =.
	
	**********************
	****** miglac_ci *****
	**********************
	gen byte miglac_ci = .
	replace miglac_ci = 1 if inlist(P14CPAIS, 32, 68, 76, 152, 170, 188, 192, 214, 218, 222, 484, 604, 858, 862)
	replace miglac_ci = 0 if !inlist(P14CPAIS, 32, 68, 76, 152, 170, 188, 192, 214, 218, 222, 484, 604, 858, 862, 999)
	
***********************************
*** 5. Educación (13 variables) ***
***********************************

	replace P18B_GRA = . if P18B_GRA == 9
	
	/*	
		  18a- ¿Cuál es el último nivel más |
							 alto aprobado? |     Código 
	----------------------------------------+--------------
									Ninguno |       0
							 Grado Especial |       1
				Programas de alfabetización |       2
							   Pre-primario |       3
		  EEB (1° y 2° Ciclo) / Ex Primaria |       4
	  EEB (3° Ciclo) / Ex Secundaria Básica |       5 
		  Educación Media / Ex Bachillerato |       6
	Superior No Universitario  o Universita |       7
										 NR |       9
	*/


	*********
	*aedu_ci* // 
	*********
	gen byte aedu_ci = .	
	replace aedu_ci = 0 if inrange(P18A_NIV, 0, 3) // Ninguno, Grado especial, Programas de alfabetizacion. 
	replace aedu_ci = P18B_GRA if inrange(P18A_NIV, 4, 5) // EEB (1° y 2° Ciclo y  EEB (3° Ciclo)
	replace aedu_ci = P18B_GRA + 9 if P18A_NIV == 6 // Educación media.
	replace aedu_ci = P18B_GRA + 12 if P18A_NIV == 7 // Superior (univ o no univ)
 
	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen byte eduno_ci = (aedu_ci == 0) // never attended or pre-school
	replace eduno_ci =. if aedu_ci == . // NIU & missing
		
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen byte edupi_ci = (aedu_ci > 0 & aedu_ci < 6)
	replace edupi_ci = . if aedu_ci == . 

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen byte edupc_ci = (aedu_ci == 6) 
	replace edupc_ci = . if aedu_ci == . // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen byte edusi_ci = (aedu_ci > 6 & aedu_ci <= 11)
	replace edusi_ci = . if aedu_ci == . 

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen byte edusc_ci = (aedu_ci == 12) // 
	replace edusc_ci = . if aedu_ci == . // NIU & missing
	
	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci = (aedu_ci > 6 & aedu_ci < 9)
	replace edus1i_c = . if aedu_ci == .
	
	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci = (aedu_ci == 9)
	replace edus1c_ci = . if aedu_ci == . 

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci = (aedu_ci > 9 & aedu_ci < 12)
	replace edus2i_ci = . if aedu_ci == . 

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci = (aedu_ci == 12)
	replace edus2c_ci = . if aedu_ci == . 

	***********
	*edupre_ci* // preescolar
	***********
	gen byte edupre_ci=(P18A_NIV==3) // pre-school
	replace edupre_ci=. if P18A_NIV==. // NIU & missing
	
	***********
	*asiste_ci*
	***********
	gen byte asiste_ci = . 
	replace asiste_ci = 1 if P16 == 1
	replace asiste_ci = 0 if P16 == 6

	**********
	*literacy*
	**********
	gen byte literacy = . 
	replace literacy = 1 if P15 == 1 // literate
	replace literacy = 0 if P15 == 6 // illiterate
	
****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

    *******************
    ****condocup_ci****
    *******************
    gen byte condocup_ci=.
	replace condocup_ci = 1 if P25 == 1 | P26 == 1 // ocupado
	replace condocup_ci = 2 if P29 == 1 // desempleo abierto
	replace condocup_ci = 3 if P29 == 6 // inactivos

    ************
    ***emp_ci***
    ************
    gen byte emp_ci=.
	replace emp_ci = 1 if condocup_ci == 1 // empleados
	replace emp_ci = 0 if inlist(condocup_ci, 2, 3) // desempleados e inactivos

    ****************
    ***desemp_ci***
    ****************	
	gen byte desemp_ci=.
	replace desemp_ci=1 if condocup_ci==2 /*1 desempleados*/
	replace desemp_ci=0 if condocup_ci==3 | condocup_ci==1 /*0 cuando están inactivos o empleados*/

    *************
    ***pea_ci***
    *************
    gen byte pea_ci=.
	replace pea_ci=1 if condocup_ci == 1 | condocup_ci == 2
	replace pea_ci=0 if condocup_ci == 3
	
    *************************
    ****rama de actividad****
    *************************
    gen byte rama_ci = . //  VER: Esta la variable P33_A se usa rama de actividad a 2 digitos. el detalle no se presenta an la documentacion del censo. 
	
    *********************
    ****categopri_ci****
    *********************
	gen byte categopri_ci=.
	replace categopri_ci = 1 if P34 == 3 & condocup_ci == 1 // patron o empleador 
	replace categopri_ci = 2 if P34 == 1 & condocup_ci == 1 // cuenta propia o indep 
	replace categopri_ci = 3 if inlist(P34, 4, 5) & condocup_ci == 1 // empleado u obrero
	replace categopri_ci = 4 if P34 == 2 & condocup_ci == 1 // empleado no remunerado

    *****************
    ***spublico_ci***
    *****************
    gen byte spublico_ci=.
	replace spublico_ci = 1 if categopri_ci != . & P35 == 1 // sector publico
	replace spublico_ci = 0 if categopri_ci != . & P35 == 6 
	
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************	

	********
	*luz_ch*
	********
	gen byte luz_ch = .
	replace luz_ch = 1 if V07 == 1
	replace luz_ch = 0 if V07 == 6
	
	*********
	*piso_ch*
	*********
	* Se utiliza la metodologia de encustas de hogares.
	gen byte piso_ch = .
	replace piso_ch = 0 if V04 == 1 // materiales no permanentes
	replace piso_ch = 1 if inrange(V04, 2, 8) // materiales permanentes
	replace piso_ch = 2 if V04 == 9 // otros
	
	**********
	*pared_ch*
	**********
	gen byte pared_ch = .
	replace pared_ch = 0 if inlist(V03, 3, 7) // no permanentes
	replace pared_ch = 1 if inlist(V03, 1, 5) // permanentes 
	replace pared_ch = 2 if inlist(V03, 2, 6, 9) // otros
	
	**********
	*techo_ch*
	**********
	gen byte techo_ch = .
	replace techo_ch = 0 if inlist(V05, 2, 3, 8) // no permanentes
	replace techo_ch = 1 if inlist(V05, 1, 4, 5, 6, 7) // permanentes 
	replace techo_ch = 2 if V05 == 9 // otros
	
	**********
	*resid_ch*
	**********
	gen byte resid_ch = .
	replace resid_ch = 0 if V06 == 2 // recolección pública o privada
	replace resid_ch = 1 if inlist(V06, 1, 3) // quemados o enterrados
	replace resid_ch = 2 if inlist(V06, 4, 5, 6, 7) // espacio abiertos
	
	*********
	*dorm_ch*
	*********
	gen byte dorm_ch = .
	replace dorm_ch = V15B if V15B != 99
	
	************
	*cuartos_ch*
	************
	gen byte cuartos_ch = .
	replace cuartos_ch = V15A if V15A != 88

	***********
	*cocina_ch*
	***********
	gen byte cocina_ch = .
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch = .
	replace telef_ch = 1 if V1604 == 4 
	replace telef_ch = 0 if V1604 == .
	replace telef_ch = . if V1604 == 99
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=.
	replace refrig_ch = 1 if V1603 == 3 
	replace refrig_ch = 0 if V1603 == .
	replace refrig_ch = . if V1603 == 99

	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	replace auto_ch = 1 if V1611 == 11
	replace auto_ch = 0 if V1611 == .
	replace auto_ch = . if V1611 == 99

	********
	*compu_ch*
	********
	gen byte compu_ch=.
	replace compu_ch = 1 if V1616 == 16 
	replace compu_ch = 0 if V1616 == .
	replace compu_ch = . if V1616 == 99

	*************
	*internet_ch*
	************* 
	gen byte internet_ch=.
	replace internet_ch = 1 if V1617 == 17
	replace internet_ch = 0 if V1617 == .
	replace internet_ch = . if V1617 == 99
	
	********
	*cel_ch*
	********
	gen byte cel_ch=.
	replace cel_ch = 1 if V1605 == 5 
	replace cel_ch = 0 if V1605 == .
	replace cel_ch = . if V1605 == 99

	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch = .
	replace viviprop_ch = 0 if V11 == 4 // alquilada 
	replace viviprop_ch = 1 if V11 == 1 // propia y totalmente pagada
	replace viviprop_ch = 1 if V11 == 2 // en proceso de pago
	replace viviprop_ch = 1 if V11 == 6 // ocupada de hecho

***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	*****************
	*aguaentubada_ch*
	************
	gen aguaentubada_ch=.
	replace aguaentubada_ch = 1 if inrange(V08, 1, 2)
	replace aguaentubada_ch = 0 if inrange(V08, 3, 9)

	
	************
	*aguared_ch*
	************
	gen aguared_ch=.
	replace aguared_ch = 1 if inlist(V09, 1,2,3)
	replace aguared_ch = 0 if inrange(V09,4,99)
		
    ***************
	*aguafuente_ch*
	***************
	gen aguafuente_ch=.
	replace aguafuente_ch = 1 if inlist(V10, 1,2,3) & inlist(V08, 1,2)
	replace aguafuente_ch = 2 if inlist(V10, 1,2,3) & inlist(V08, 3)
	replace aguafuente_ch = 3 if V10 == 10
	replace aguafuente_ch = 4 if inlist(V10, 5,6)
	replace aguafuente_ch = 6 if inlist(V10, 11)
	replace aguafuente_ch = 7 if inlist(V10, 4)
	replace aguafuente_ch = 8 if inlist(V10, 11)
	replace aguafuente_ch = 9 if inlist(V10, 7)
	replace aguafuente_ch = 10 if inlist(V10, 8,9,12,99)
	
	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch=.
	replace aguadist_ch = 1 if inlist(V08, 1)
	replace aguadist_ch = 2 if inlist(V08, 2)
	replace aguadist_ch = 3 if inlist(V08, 3)
	replace aguadist_ch = 0 if inlist(V08, 4,5,6,9)
	
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
	gen byte aguamide_ch =9
	
	*********
	*bano_ch*
	*********
	gen byte bano_ch = . 
	replace bano_ch = 0 if V20 == 8
	replace bano_ch = 1 if inlist(V20,1)
	replace bano_ch = 2 if inlist(V20,2)
	replace bano_ch = 4 if inlist(V20, 6,7) 
	replace bano_ch = 6 if inlist(V20, 3,4,5)
	
	***********
	*banoex_ch*
	***********
	gen byte banoex_ch =.
	replace bano_ch = 1 if V18 ==1
	replace bano_ch = 0 if inlist(V18, 2,6)
	replace bano_ch = 9 if inlist(V18, 3,9)

	************
	*sinbano_ch*
	************
	gen byte sinbano_ch =.
	replace sinbano_ch = 3 if V20 == 8
	replace sinbano_ch = 0 if inlist(V20, 1,2,3,4,5,6,9)
	
	************
	*conbano_ch*
	************
	gen conbano_ch =.
	replace conbano_ch = 0 if V20 == 8
	replace sinbano_ch = 1 if inlist(V20, 1,2,3,4,5,6,9)

	*********
	*banoalcantarillado_ch_ch*
	*********
	gen byte banoalcantarillado_ch_ch=.
	replace banoalcantarillado_ch_ch = 1 if inrange(V18, 1, 3)
	replace banoalcantarillado_ch_ch = 0 if V18 == 6
	
	*********
	*des1_ch*
	*********
	gen byte des1_ch = . 
	replace des1_ch = 0 if V20 == 8 
	replace des1_ch = 1 if V20 == 1
	replace des1_ch = 2 if inrange(V20, 2, 6)
	


*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte PRY_m_pared_ch= V03
	label var PRY_m_pared_ch  "Material de las paredes según el censo del país - variable original"

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte PRY_m_piso_ch= V04
	label var PRY_m_piso_ch  "Material de los pisos según el censo del país - variable original"

	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte PRY_m_techo_ch= V05
	label var PRY_m_techo_ch  "Material del techo según el censo del país - variable original"
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen byte PRY_ingreso_ci = .
	label var PRY_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen byte PRY_ingresolab_ci = .	
	label var PRY_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte PRY_dis_ci = .
	label var PRY_dis_ci  "Individuos con discapacidad según el censo del país - variable original"


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

keep  $lista_variables 

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

