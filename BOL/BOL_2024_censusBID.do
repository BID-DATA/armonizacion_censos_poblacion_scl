* (Versión StataNow/MP 19.5)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: BOL
Año: 2024
Autores: Matias Rodriguez (SCL/SCL)
Última versión: December 19, 2025
División: SCL - IADB
*******************************************************************************

INSTRUCCIONES:

	(1) Guarda este script con la estructura ISOalpha3Pais_ANIO_censusBID.do.
		Por ejemplo Ecuador 2017 será: ECU_2017_censusBID.do
	
	(2) Sigue la estructura y estilo de este script, pero ten en cuenta que
		el contenido es referencial y que debes adaptarlo al país que te toque 
		armonizar. 	Cada vez que encuentres "..." debes completar el código con la
		información del país que te toque. Existen variables en las que no debes
		hacer nada, pues se crean a partir de otras variables, como por ejemplo 
		jefe_ci.
		
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

global ruta = "${censusFolder}"
global PAIS BOL
global ANIO 2024

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\Base de datos CSV\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using "$log_file", replace

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
	gen byte region_BID_c = 3

	**********
	*region_c*   
	**********
	clonevar region_c = idep
	label define region_c ///
	1"Chuquisaca"         ///     
	2"La Paz"             ///
	3"Cochabamba"         ///
	4"Oruro"              ///
	5"Potosí"             ///
	6"Tarija"             ///
	7"Santa Cruz"         ///
	8"Beni"               ///
	9"Pando"              
	label value region_c region_c

	*********
	*geolev1*
	*********
	gen long geolev1 =.  
	replace geolev1 = 68001 if idep == 1
	replace geolev1 = 68002 if idep == 2 & iprov!=17
	replace geolev1 = 68003 if idep == 3
	replace geolev1 = 68004 if idep == 4
	replace geolev1 = 68005 if idep == 5
	replace geolev1 = 68006 if idep == 6
	replace geolev1 = 68007 if idep == 7
	replace geolev1 = 68008 if idep == 8
	replace geolev1 = 68009 if idep == 9
	replace geolev1 = 68088 if idep==2 & iprov== 17
	
	label define geolev1	///
	68001 "Chuquisaca" ///
	68002 "La Paz" ///
	68003 "Cochabamba" ///
	68004 "Oruro" ///
	68005 "Potosí" ///
	68006 "Tarija" ///
	68007 "Santa Cruz" ///
	68008 "Beni" ///
	68009 "Pando" ///
	68088 "Lake Titicaca"
	label value geolev1 geolev1
	*tab geolev1 region_c,m // region_c y geolev1 tienen la misma cantidad de registros

    ********
	*pais_c*
	********
	gen str3 pais_c = "BOL"

    ********
	*anio_c*
	********
	gen int anio_c = 2024
	
    *******************
    *idh_ch (ID hogar)*
    *******************
	tostring i00, gen(idh_ch) format("%16.0f")	

	**********************
	*idp_ci (ID personas)*
	sort i00
	gen idp_ci = _n
	tostring idp_ci, replace format ("%16.0f") 
	duplicates report idp_ci // copies = 1
		
	****************************************
	*(factor_ci) factor expansión individio*
	****************************************
	gen factor_ci = .
	
	*******************************************
	*(factor_ch) Factor de expansion del hogar*
	*******************************************
	gen factor_ch = .
		
    ************
	*estrato_ci*
	************
	gen estrato_ci = .

	*****
	*upm*
	*****
	gen upm = .
	
    ********
	*Zona_c*
	********
	gen byte zona_c = . 
	replace zona_c = 1 if urbrur==1
	replace zona_c = 0 if urbrur==2

	
************************************
*** 2. Demografía (18 variables) ***
************************************

    ********
	*sexo_ci*
	********
	gen byte sexo_ci =.
	replace sexo_ci = 1 if p25_sexo==2
	replace sexo_ci = 2 if p25_sexo==1
	
	********
	*edad_ci*
	********
	gen int edad_ci = p26_edad

	*************
	*relacion_ci*
	*************
	gen byte relacion_ci = .
	replace relacion_ci = 1 if p24_parentes==1
	replace relacion_ci = 2 if p24_parentes==2
	replace relacion_ci = 3 if p24_parentes==3|p24_parentes==4
	replace relacion_ci = 4 if p24_parentes>=5 & p24_parentes<=12
	replace relacion_ci = 5 if p24_parentes==14 
	replace relacion_ci = 6 if p24_parentes==13 // empleados y sus familiares

	**********
	*civil_ci*
	**********
	gen	byte civil_ci=.
	replace civil_ci=1 if p53_ecivil==6
	replace civil_ci=2 if p53_ecivil==1 | p53_ecivil==2
	replace civil_ci=3 if p53_ecivil==3|p53_ecivil==4
	replace civil_ci=4 if p53_ecivil==5

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
	gen byte afro_ci = .
	replace afro_ci =1 if p32_pueblo_per == 1 & p32_pueblos==1
	replace afro_ci =0 if p32_pueblos!=1

	*********
	*indi_ci*
	*********	
	gen byte ind_ci = .
	replace ind_ci =1 if p32_pueblo_per == 1 & p32_pueblos!=1 & p32_pueblos!=98 & p32_pueblos!=99
	replace ind_ci =0 if p32_pueblo_per!=1
	
	**************
	*noafroind_ci*
	**************
	gen byte noafroind_ci = .
	replace noafroind_ci =1 if p32_pueblo_per==2
	replace noafroind_ci =0 if p32_pueblos!=2
	
	************
	*afroind_ci*
	************
	gen byte afroind_ci= .
	replace afroind_ci=1 if ind_ci==1 
	replace afroind_ci=2 if afro_ci==1
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
	gen byte dis_ci= . 
	replace dis_ci=1 if inlist(p42a_ver,2,3,4) & p42_discap==1 
	replace dis_ci=1 if inlist(p42b_oir,2,3,4) & p42_discap==1 
	replace dis_ci=1 if inlist(p42c_camina,2,3,4) & p42_discap==1 
	replace dis_ci=1 if inlist(p42d_comuni,2,3,4) & p42_discap==1 
	replace dis_ci=0 if p42_discap==0 | p42a_ver==1 & p42b_oir==1 & p42c_camina==1 & p42d_comuni==1
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	replace disWG_ci=1 if inlist(p42a_ver,3,4) & p42_discap==1 
	replace disWG_ci=1 if inlist(p42b_oir,3,4) & p42_discap==1 
	replace disWG_ci=1 if inlist(p42c_camina,3,4) & p42_discap==1 
	replace disWG_ci=1 if inlist(p42d_comuni,3,4) & p42_discap==1 
	replace disWG_ci=0 if p42_discap==0 | inlist(p42a_ver,1,2) & inlist(p42b_oir,1,2) & inlist(p42c_camina,1,2) & inlist(p42d_comuni,1,2)
	
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
	gen byte migrante_ci = .
	replace migrante_ci = 0 if p35_lugnac!=3 | p35_lugnac!=9
	replace migrante_ci = 1 if p35_lugnac==3

	****************
    *migantiguo5_ci*
    ****************
	gen byte migrantiguo5_ci=0
	replace migrantiguo5_ci=1 if p354_anllega<=2020  & migrante_ci ==1 
	replace migrantiguo5_ci=. if migrante_ci!=1
	
	***********
	*miglac_ci*
	***********
	gen byte miglac_ci=.
	replace miglac_ci=1 if inlist(p353_paisnac_cod,32,44,52,76,84,152,170,188,214,218,222,320,328,332,340,388,484,558,591,600,604,740,780,858,862) & migrante_ci ==1
	replace miglac_ci=0 if migrante_ci!=1

	
***********************************
*** 5. Educación (13 variables) ***
***********************************	
	*********
	*aedu_ci*
	*********
	gen byte aedu_ci= 0 if inlist(p41a_nivel, 1, 2, 3)
	* Calcular año de nacimiento aproximado
	gen anio_nac = 2024 - p26_edad
	gen byte sistema_educativo = .
	* Sistema Antiguo: nacidos antes de 1989 (tenían 6 años antes de 1995)
	replace sistema_educativo = 1 if anio_nac < 1989
	* Sistema Reforma 1995-2010: nacidos entre 1989-2005 (tenían 6 años entre 1995-2011)
	replace sistema_educativo = 2 if anio_nac >= 1989 & anio_nac <= 2005
	* Sistema Actual: nacidos después de 2005 (tenían 6 años después de 2011)
	replace sistema_educativo = 3 if anio_nac > 2005
	* Niveles educativos del sistema antiguo (vigente de 1973 a 1994), organizado de la siguiente forma: Básico, de primero a quinto. Intermedio, de primero a tercero. Medio, de primero a cuarto.
	* Nivel educativo que corresponde a: Sistema anterior (vigente de 1995 a 2010), que comprendía de primero a octavo de primaria. Sistema actual (vigente desde 2011), que comprende de primero a sexto de primaria.
	replace aedu_ci = p41b_curso if p41a_nivel == 4 & inrange(p41b_curso, 1, 5)
	replace aedu_ci = 5 + p41b_curso if p41a_nivel == 5 & inrange(p41b_curso, 1, 3)
	replace aedu_ci = 8 + p41b_curso if p41a_nivel == 6 & inrange(p41b_curso, 1, 4)
	replace aedu_ci = p41b_curso if p41a_nivel == 7 & inrange(p41b_curso, 1, 8) & sistema_educativo <= 2
	replace aedu_ci = p41b_curso if p41a_nivel == 7 & inrange(p41b_curso, 1, 6) & sistema_educativo == 3
	replace aedu_ci = 8 + p41b_curso if p41a_nivel == 8 & inrange(p41b_curso, 1, 4) & sistema_educativo == 2
	replace aedu_ci = 6 + p41b_curso if p41a_nivel == 8 & inrange(p41b_curso, 1, 6) & sistema_educativo == 3
	* Técnico medio
	replace aedu_ci = 12 + p41b_curso if p41a_nivel == 9 & inrange(p41b_curso, 1, 2)
	* Técnico superior
	replace aedu_ci = 12 + p41b_curso if p41a_nivel == 10 & inrange(p41b_curso, 1, 3)
	* Licenciatura
	replace aedu_ci = 12 + p41b_curso if p41a_nivel == 11 & inrange(p41b_curso, 1, 5)
	* Maestria
	replace aedu_ci = 17 + p41b_curso if p41a_nivel == 12 & inrange(p41b_curso, 1, 2)
	* Doctorado
	replace aedu_ci = 19 + p41b_curso if p41a_nivel == 13 & inrange(p41b_curso, 1, 4)
 
	**********
	*eduno_ci*
	**********
	gen byte eduno_ci = (aedu_ci == 0) 
	replace eduno_ci = . if aedu_ci == .
 
	**********
	*edupi_ci*
	**********
	* Sistema Antiguo: Básico (1-5) + Intermedio (1-3) = 8 años para primaria completa
	* Sistema Reforma (1995-2010): Primaria 1-8 años
	* Sistema Actual (desde 2011): Primaria 1-6 años
	gen byte edupi_ci = .
	* Sistema Antiguo: primaria incompleta es 1-7 años (básico + intermedio incompleto)
	replace edupi_ci = (aedu_ci >= 1 & aedu_ci <= 7) if sistema_educativo == 1
	* Sistema Reforma: primaria incompleta es 1-7 años
	replace edupi_ci = (aedu_ci >= 1 & aedu_ci <= 7) if sistema_educativo == 2
	* Sistema Actual: primaria incompleta es 1-5 años
	replace edupi_ci = (aedu_ci >= 1 & aedu_ci <= 5) if sistema_educativo == 3
	replace edupi_ci = . if aedu_ci == .
	**********
	*edupc_ci*
	**********
	gen byte edupc_ci = .
	* Sistema Antiguo: primaria completa = 8 años (5 básico + 3 intermedio)
	replace edupc_ci = (aedu_ci == 8) if sistema_educativo == 1
	* Sistema Reforma: primaria completa = 8 años
	replace edupc_ci = (aedu_ci == 8) if sistema_educativo == 2
	* Sistema Actual: primaria completa = 6 años
	replace edupc_ci = (aedu_ci == 6) if sistema_educativo == 3
	replace edupc_ci = . if aedu_ci == .
 
	**********
	*edusi_ci*
	**********
	gen byte edusi_ci = .
	* Sistema Antiguo: secundaria (medio) va de 9-11 años (incompleta)
	replace edusi_ci = (aedu_ci >= 9 & aedu_ci <= 11) if sistema_educativo == 1
	* Sistema Reforma: secundaria va de 9-11 años (incompleta)
	replace edusi_ci = (aedu_ci >= 9 & aedu_ci <= 11) if sistema_educativo == 2
	* Sistema Actual: secundaria va de 7-11 años (incompleta)
	replace edusi_ci = (aedu_ci >= 7 & aedu_ci <= 11) if sistema_educativo == 3
	replace edusi_ci = . if aedu_ci == .
 
	**********
	*edusc_ci*
	**********
	gen byte edusc_ci = (aedu_ci >= 12)
	replace edusc_ci = . if aedu_ci == .
	***********
	*edus1i_ci*
	***********
	gen byte edus1i_ci = .
	* Sistema Antiguo: 1er ciclo (medio 1-2) incompleto = año 9
	replace edus1i_ci = (aedu_ci == 9) if sistema_educativo == 1
	* Sistema Reforma: 1er ciclo (secundaria 1-2) incompleto = año 9
	replace edus1i_ci = (aedu_ci == 9) if sistema_educativo == 2
	* Sistema Actual: 1er ciclo (secundaria 1-3) incompleto = años 7-8
	replace edus1i_ci = (aedu_ci >= 7 & aedu_ci <= 8) if sistema_educativo == 3
	replace edus1i_ci = . if aedu_ci == .
	***********
	*edus1c_ci*
	***********
	gen byte edus1c_ci = .
	* Sistema Antiguo: 1er ciclo completo = año 10
	replace edus1c_ci = (aedu_ci == 10) if sistema_educativo == 1
	* Sistema Reforma: 1er ciclo completo = año 10
	replace edus1c_ci = (aedu_ci == 10) if sistema_educativo == 2
	* Sistema Actual: 1er ciclo completo = año 9
	replace edus1c_ci = (aedu_ci == 9) if sistema_educativo == 3
	replace edus1c_ci = . if aedu_ci == .
	***********
	*edus2i_ci*
	***********
	gen byte edus2i_ci = .
	* Sistema Antiguo: 2do ciclo (medio 3-4) incompleto = año 11
	replace edus2i_ci = (aedu_ci == 11) if sistema_educativo == 1
	* Sistema Reforma: 2do ciclo (secundaria 3-4) incompleto = año 11
	replace edus2i_ci = (aedu_ci == 11) if sistema_educativo == 2
	* Sistema Actual: 2do ciclo (secundaria 4-6) incompleto = años 10-11
	replace edus2i_ci = (aedu_ci >= 10 & aedu_ci <= 11) if sistema_educativo == 3
	replace edus2i_ci = . if aedu_ci == .
	***********
	*edus2c_ci*
	***********
	gen byte edus2c_ci = (aedu_ci >= 12)
	replace edus2c_ci = . if aedu_ci == .
	***********
	*edupre_ci*
	***********
	* Pregunta es solo último curso/año aprobado no permitiría determinar si quieres aprobaron desde primaria en adelante efectivamente tuvieron años preescolares o no. Se deja como missing.
	gen byte edupre_ci=.
 
    ***********
    *asiste_ci*
    ***********
	gen byte asiste_ci = .
	* Asiste (1): Se incluyen categorías 1, 2, 3, 4, 5, 6 y 7 (educación formal primaria, secundaria y terciaria, alfabetización, CEA, ed. especial, guardería)
	replace asiste_ci = 1 if inlist(p38_asiste, 1, 2, 3, 4, 5, 6, 7)
	* No asiste (0): Se incluye categoría 8 = No asiste
	replace asiste_ci = 0 if inlist(p38_asiste, 8)
	* Sin especificar = missing
	replace asiste_ci = . if p38_asiste == 9
	**********
	*literacy*
	**********
	gen byte literacy = .
	* Sí sabe leer y escribir
	replace literacy = 1 if p40_lee == 1
	* No sabe leer y escribir
	replace literacy = 0 if p40_lee == 2
	* Sin especificar = missing
	replace literacy = . if p40_lee == 9
	
	
****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************	
	
    *************
    *condocup_ci*
    *************
    gen byte condocup_ci=.
	* Ocupados
	replace condocup_ci = 1 if condact_13 == 1
	* Descocupado incluye registros categorizados como desocupado cesante y aspirantes
	replace condocup_ci = 2 if inlist(condact_13, 2, 3)
	* Inactivo
	replace condocup_ci = 3 if condact_13 == 4
	* No se pregunta pues es menor a 7 años (PENT = Población en edad de no trabajar (menor a 7 años)). Se pregunta aunque la edad legal es +14
	replace condocup_ci = 4 if condact_13 == 5
	* Casos "sin especificar"
	replace condocup_ci = . if condact_13 == 9
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
	*********
    *rama_ci*
    *********
	gen rama_ci=.
	* Categoría armonización - Categoría encuesta original
	* Agricultura, pesca y forestal - Agricultura, ganadería, silvicultura y pesca
	replace rama_ci = 1 if act_eco_2d_13 == 1
	* Minería y extracción - Explotación de minas y canteras
	replace rama_ci = 2 if act_eco_2d_13 == 2
	* Industrias manufactureras - Industrias manufactureras
	replace rama_ci = 3 if act_eco_2d_13 == 3
	* Electricidad, gas, agua y manejo de residuos - Suministro de electricidad, gas, vapor y aire acondicionado & Suministro de agua; evacuación de aguas residuales, gestión de desechos y descontaminación
	replace rama_ci = 4 if inlist(act_eco_2d_13, 4, 5)
	* Construcción - Construcción
	replace rama_ci = 5 if act_eco_2d_13 == 6
	* Comercio - Comercio al por mayor y al por menor, reparación de vehículos automotores y motocicletas
	replace rama_ci = 6 if act_eco_2d_13 == 7
	* Hoteles y restaurantes - Actividades de alojamiento y de servicio de comidas
	replace rama_ci = 7 if act_eco_2d_13 == 9
	* Transporte, almacenamiento y comunicaciones - Transporte y almacenamiento & Información y comunicaciones
	replace rama_ci = 8 if inlist(act_eco_2d_13, 8, 10)
	* Servicios financieros y seguros - Actividades financieras y de seguros
	replace rama_ci = 9 if act_eco_2d_13 == 11
	* Administración pública y defensa - Administración pública y defensa; planes de seguridad social de afiliación obligatoria
	replace rama_ci = 10 if act_eco_2d_13 == 15
	* Servicios empresariales e inmobiliarios - Actividades inmobiliarias & Actividades profesionales, científicas y técnicas & Actividades de servicios administrativos y de apoyo
	replace rama_ci = 11 if inlist(act_eco_2d_13, 12, 13, 14)
	* Educación - Enseñanza
	replace rama_ci = 12 if act_eco_2d_13 == 16
	* Salud y trabajo social - Actividades de atención de la salud humana y de asistencia social
	replace rama_ci = 13 if act_eco_2d_13 == 17
	* Otros servicios - Otras actividades de servicios & Actividades artísticas, de entretenimiento y recreativas & Actividades de organizaciones y órganos extraterritoriales
	replace rama_ci = 14 if inlist(act_eco_2d_13, 18, 19, 21)
	* Servicio doméstico & Actividades de los hogares como empleadores; actividades no diferenciadas de los hogares como productores de bienes y servicios como uso propio
	replace rama_ci = 15 if act_eco_2d_13 == 20
	* Sin especificar o descripciones incompletas, se pasan a missing
	replace rama_ci = . if inlist(act_eco_2d_13, 97, 99)
	* Restringir solo a ocupados
	replace rama_ci = . if condocup_ci != 1
	**************
    *categopri_ci*
    **************
	gen byte categopri_ci=.
	* Categoría armonización - Categoría encuesta original
	* Patrón o empleador - Empleadora(or) o socia(o)
	replace categopri_ci = 1 if p50_catocu_13 == 3
	* Cuenta propia o indepedendiente - Trabajadora(or) por cuenta propia
	replace categopri_ci = 2 if p50_catocu_13 == 1
	* Empleado o asalariado - Empleada(o) u obrera(o) & Empleadora(or) o socia(o) & Trabajadora(or) del hogar
	replace categopri_ci = 3 if inlist(p50_catocu_13, 2,5)
	* Trabajador no remunerado - Trabajadora(or) familiar sin renumeración
	replace categopri_ci = 4 if p50_catocu_13 == 4
	* Otra clasficación - Cooperativista de producción
	replace categopri_ci = 0 if p50_catocu_13 == 6
	* Missing para sin especificar
	replace categopri_ci = . if p50_catocu_13 == 9
	* Restringir solo a ocupados
	replace categopri_ci = . if condocup_ci != 1
	*************
    *spublico_ci*
    *************
	gen byte spublico_ci=.
	replace spublico_ci=1 if emp_ci==1 & rama_ci==15
	replace spublico_ci=0 if emp_ci==1 & rama_ci!=15 & rama_ci!=.	
		
		
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************		

	********
	*luz_ch*
	********
	gen byte luz_ch=.
	replace luz_ch=0 if v09_energia==4
	replace luz_ch=1 if inlist(v09_energia,1,2,3)

	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
	replace piso_ch=0 if v06_piso==1
	replace piso_ch=2 if inlist(v06_piso,2,3,4,5,6,7,8)

	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	replace pared_ch=1 if inlist(v03_pared,5,6)
	replace pared_ch=2 if inlist(v03_pared,1,2,3,4,7)

	**********
	*techo_ch*
	**********  
	gen byte techo_ch=.
	replace techo_ch=1 if v05_techo==5
	replace techo_ch=2 if inlist(v05_techo,1,2,3,4)

	**********
	*resid_ch*
	**********
	gen byte resid_ch=. 
	replace resid_ch=0 if inlist(v11_basura,1,2) //1 La depositan en el contenedor o basurero público - MANUAL: Recolectado indirectamente de un contenedor de basura o depósito
	replace resid_ch=1 if inlist(v11_basura,5,6) 
	replace resid_ch=2 if inlist(v11_basura,3,4)
	replace resid_ch=3 if inlist(v11_basura,7)

	*********
	*dorm_ch*
	*********
	gen byte dorm_ch = v14_dormit // 8=8+
	
	************
	*cuartos_ch* 
	************
	gen byte cuartos_ch = v13_habitac // 8=8+
	
	***********
	*cocina_ch*
	***********
	gen byte cocina_ch = .
	replace cocina_ch=0 if v12_cocina==2
	replace cocina_ch=1 if v12_cocina==1
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch = .
	replace telef_ch=0 if v19h_telfijo==2
	replace telef_ch=1 if v19h_telfijo==1
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch = . 
	replace refrig_ch=0 if v18f_refri==2
	replace refrig_ch=1 if v18f_refri==1
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch = .
	replace auto_ch=0 if v18c_auto==2
	replace auto_ch=1 if v18c_auto==1

	**********
	*compu_ch*
	**********
	gen byte compu_ch = .
	replace compu_ch=0 if v19c_compu==2
	replace compu_ch=1 if v19c_compu==1

	*************
	*internet_ch*
	************* 
	gen byte internet_ch = .
	replace internet_ch=0 if v19e_f==2
	replace internet_ch=1 if v19e_f==1
	
	********
	*cel_ch*
	********
	gen byte cel_ch = .
	replace cel_ch=0 if v19d_celular==2
	replace cel_ch=1 if v19d_celular==1
	
	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch1 = .
	replace viviprop_ch1=0 if inlist(v17_tenencia,3,4,5,6)
	replace viviprop_ch1=1 if inlist(v17_tenencia,1,2,7)


***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	************
	*aguaentubada_ch*
	************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch=1 if inlist(v08_aguadist,1,2)
	replace aguaentubada_ch=0 if v08_aguadist==3

	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch=1 if v07_aguapro==1 & inlist(v08_aguadist,1,2)
	replace aguared_ch=0 if v07_aguapro!=1 
	
	************
	*aguafuente_ch*
	************
	gen byte aguafuente_ch=10
	replace aguafuente_ch=1 if v07_aguapro==1
	replace aguafuente_ch=2 if v07_aguapro==2
	*replace aguafuente_ch=3 if v07_aguapro== // no hay agua embotellada
	replace aguafuente_ch=4 if v07_aguapro==4
	replace aguafuente_ch=5 if v07_aguapro==3
	replace aguafuente_ch=6 if v07_aguapro==8
	replace aguafuente_ch=7 if v07_aguapro==6
	replace aguafuente_ch=8 if v07_aguapro==7
	replace aguafuente_ch=9 if v07_aguapro==5
	
	************
	*aguadist_ch*
	************
	gen byte aguadist_ch=0
	replace aguadist_ch=1 if v08_aguadist==1 // Por cañería dentro de la vivienda
	replace aguadist_ch=2 if v08_aguadist==2 //Por cañería fuera de la vivienda, pero dentro del lote o terreno
	
	************
	*aguadisp1_ch*
	************
	gen byte aguadisp1_ch=9
	
	************
	*aguadisp2_ch*
	************
	gen byte aguadisp2_ch=9
	
	************
	*aguamide_ch*
	************
	gen byte aguamide_ch=9
	
	*********
	*bano_ch*
	*********
	gen byte bano_ch=0
	replace bano_ch=0 if v15_servsan==3 // no tiene baño
	replace bano_ch=1 if inlist(v15_servsan,1,2) & v16_desague==1 // red de alcantarillado
	replace bano_ch=2 if inlist(v15_servsan,1,2) & v16_desague==2 // cámara séptica
	replace bano_ch=3 if inlist(v15_servsan,1,2) & v16_desague==6 // Baño ecologico
	replace bano_ch=4 if inlist(v15_servsan,1,2) & v16_desague==5 // Superficie
	replace bano_ch=5 if inlist(v15_servsan,1,2) & v16_desague==3 // pozo ciego, underground pit
	replace bano_ch=6 if inlist(v15_servsan,1,2) & v16_desague==4 // pozo de absorción 

	*********
	*banoex_ch*
	*********
	gen byte banoex_ch=9
	replace banoex_ch=0 if v15_servsan==2
	replace banoex_ch=1 if v15_servsan==1

	*********
	*sinbano_ch*
	*********
	gen byte sinbano_ch=.
	replace sinbano_ch=0 if inlist(v15_servsan,1,2)
	replace sinbano_ch=3 if v15_servsan==3

	*****************
	*conbano_ch*
	*****************
	gen byte conbano_ch=0
	replace conbano_ch=0 if v15_servsan==3
	replace conbano_ch=1 if inlist(v15_servsan,1,2)

	*********
	*banoalcantarillado_ch*
	*********
	gen byte banoalcantarillado_ch=0  
	replace banoalcantarillado_ch=0 if inlist(v16_desague,3,4,5,6) //Pozo ciego & Pozo de absorción & Superfiece & Baño Ecológico
	replace banoalcantarillado_ch=1 if inlist(v16_desague,1,2) // Red de alcantarillado & camara séptica
	
	*********
	*des1_ch*
	*********
	gen byte des1_ch=0
	replace des1_ch=0 if v15_servsan==3
	replace des1_ch=1 if v16_desague==1 // Red de alcantarillado
	replace des1_ch=2 if v16_desague>=2 & v16_desague<=6  //camara séptica & Pozo ciego & Pozo de absorción & Superfiece, Baño Ecológico

	
*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte BOL_m_pared_ch= v03_pared
	label var BOL_m_pared_ch  "Material de las paredes según el censo del país - variable original"
	label def BOL_m_pared_ch  1 "Ladrillo, bloque de cemento, hormigón" 2 "Adobe, tapial" 3 "Tabique, quinche" 4 "Piedra" 5 "Madera" 6 "Caña, palma, tronco" 7 "Otro" //categorías originales del país
	label val BOL_m_pared_ch  BOL_m_pared_ch 

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte BOL_m_piso_ch= v06_piso
	label var BOL_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	label def BOL_m_piso_ch  1 "Tierra" 2 "Tablón de madera" 3 "Machimbre, parquet" 4 "Cerámica, porcelanato" 5 "Cemento" 6 "Mosaico, baldosa" 7 "Ladrillo" 8 "Piso Flotante" 9 "Otro" //categorías originales del país
	label val BOL_m_piso_ch  BOL_m_piso_ch 
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte BOL_m_techo_ch= v05_techo
	label var BOL_m_techo_ch  "Material del techo según el censo del país - variable original"
	label def BOL_m_techo_ch  1 "Calamina o plancha" 2 "Teja (de cemento, arcilla o fibrocemento)" 3 "Losa de hormigón armado" 4 "Paja, palma, caña, barro, jatata, motacú, chuchio" 5 "Otro"  //categorías originales del país
	label val BOL_m_techo_ch BOL_m_techo_ch 
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long BOL_ingreso_ci = .
	label var BOL_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long BOL_ingresolab_ci = .	
	label var BOL_ingreso_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte BOL_dis_ci = p42_discap
	label var BOL_dis_ci  "Individuos con discapacidad según el censo del país - variable original"
	label def BOL_dis_ci 1 "Sí Tiene Discapacidad" 2 "No Tiene Discapacidad"   //categorías originales del país
	label val BOL_dis_ci BOL_dis_ci

	
/*******************************************************************************
   III. Incluir variables externas
*******************************************************************************/
capture drop _merge
merge m:1 pais_c anio_c using "\\sapidbshares.file.core.windows.net\idbshares\SURVEYS\general_documentation\data_externa\poverty\International_Poverty_Lines\5_International_Poverty_Lines_LAC_long_PPP21.dta", keepusing (tc_wdi ppp_wdi ppp_2021 ppp_2017 cpi cpi_2017 cpi2017 cpi_2021 cpi2021 lp365_2017 lp685_2017 lp14_2017 lp81_2017 lp420_2021 lp830_2021)
drop if _merge ==2


/*******************************************************************************
   IV. Revisión de que se hayan creado todas las variables
*******************************************************************************/
* CALIDAD: revisa que hayas creado todas las variables. Si alguna no está
* creada, te apacerá en rojo el nombre. 

global lista_variables region_BID_c region_c geolev1 pais_c anio_c idh_ch idp_ci factor_ci factor_ch estrato_ci upm zona_c sexo_ci edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch miembros_ci clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch afro_ci ind_ci noafroind_ci afroind_ci afro_ch ind_ch noafroind_ch afroind_ch  dis_ci disWG_ci dis_ch migrante_ci migrantiguo5_ci miglac_ci aedu_ci eduno_ci edupi_ci edupc_ci edusi_ci edusc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci edupre_ci asiste_ci literacy condocup_ci emp_ci desemp_ci pea_ci rama_ci  categopri_ci spublico_ci luz_ch piso_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch aguaentubada_ch aguared_ch aguafuente_ch aguadist_ch aguadisp1_ch aguadisp2_ch bano_ch banoex_ch  sinbano_ch conbano_ch banoalcantarillado_ch des1_ch ${PAIS}_ingreso_ci ${PAIS}_ingresolab_ci ${PAIS}_m_pared_ch ${PAIS}_m_piso_ch ${PAIS}_m_techo_ch ${PAIS}_dis_ci tc_wdi ppp_wdi ppp_2021 ppp_2017 cpi cpi_2017 cpi2017 cpi_2021 cpi2021 lp365_2017 lp685_2017 lp14_2017 lp81_2017 lp420_2021 lp830_2021

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

* selecciona las 3 lineas y ejecuta (do). Deben quedar 94 variables de las secciones II y III más las 
* variables originales de ID que hayas mantenido
ds
local varconteo: word count `r(varlist)'
display "Número de variables de la base: `varconteo'"


/*******************************************************************************
   VI. Incluir etiquetas para las variables y categorías
*******************************************************************************/
*include "$ruta\labels.do"


/*******************************************************************************
   VII. Guardar la base armonizada 
*******************************************************************************/
compress
save "$base_out", replace 

log close

********************************************************************************
******************* FIN. Muchas gracias por tu trabajo ;) **********************
