* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: ECUADOR
Año: 2022
Autores: Maria Isabel Garcia
Última versión: 19MAY2024
División:SCL/GDI - IADB
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
global PAIS ECU    				 //cambiar
global ANIO 2022 				 //cambiar


global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using "$log_file", replace  //agregar ,replace si ya está creado el log_file en tu carpeta

use "$base_in", clear

rename *, lower
*sample 20   		// significa muestra de 20% de la base. Activar si se necesita.     

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
	destring i01, gen(id_prov_aux)
	gen byte region_c = id_prov_aux
	label define region_c   ///
	1	"Azuay" ///
	2	"Bolívar" ///
	3	"Cañar" ///
	4	"Carchi" ///
	5	"Cotopaxi" ///
	6	"Chimborazo" ///
	7	"El Oro" ///
	8	"Esmeraldas" ///
	9	"Guayas" ///
	10	"Imbabura" ///
	11	"Loja" ///
	12	"Los Ríos" ///
	13	"Manabí" ///
	14	"Morona Santiago" ///
	15	"Napo" ///
	16	"Pastaza" ///
	17	"Pichincha" ///
	18	"Tungurahua" ///
	19	"Zamora Chinchipe" ///
	20	"Galápagos" ///
	21	"Sucumbíos" ///
	22	"Orellana" ///
	23	"Santo Domingo De Los Tsáchilas" ///
	24	"Santa Elena" ///
	90	"Zona En Estudio" 
				
	label value region_c region_c
	tab region_c

	cap drop id_prov_aux
		
	*********
	*geolev1*
	*********
	gen long geolev1 =.  
	replace geolev1 = 218001 if i01 == "01"
	replace geolev1 = 218002 if i01 == "02"
	replace geolev1 = 218009 if i01 == "03"
	replace geolev1 = 218004 if i01 == "04"
	replace geolev1 = 218005 if i01 == "05"
	replace geolev1 = 218006 if i01 == "06"
	replace geolev1 = 218007 if i01 == "07"
	replace geolev1 = 218009 if i01 == "08"
	replace geolev1 = 218009 if i01 == "09"
	replace geolev1 = 218010 if i01 == "10"
	replace geolev1 = 218011 if i01 == "11"
	replace geolev1 = 218009 if i01 == "12"
	replace geolev1 = 218009 if i01 == "13"
	replace geolev1 = 218014 if i01 == "14"
	replace geolev1 = 218021 if i01 == "15"
	replace geolev1 = 218016 if i01 == "16"
	replace geolev1 = 218009 if i01 == "17"
	replace geolev1 = 218018 if i01 == "18"
	replace geolev1 = 218019 if i01 == "19"
	replace geolev1 = 218009 if i01 == "20"
	replace geolev1 = 218021 if i01 == "21"
	replace geolev1 = 218021 if i01 == "22"
	replace geolev1 = 218009 if i01 == "23"
	replace geolev1 = 218009 if i01 == "24"
	replace geolev1 = 218099 if i01 == "90"
	   
	label define geolev1	///
	218001 "Azuay" ///
	218002 "Bolívar" ///
	218004 "Carchi" ///
	218005 "Cotopaxi" ///
	218006 "Chimborazo" ///
	218007 "El Oro" ///
	218009 "Cañar, Esmeraldas, Guayas, Manabí, Pichincha, Los Ríos, Santa Elena, Santo Domingo de los Tsáchilas, Galápagos" ///
	218010 "Imbabura" ///
	218011 "Loja" ///
	218014 "Morona Santiago" ///
	218016 "Pastaza" ///
	218018 "Tungurahua" ///
	218019 "Zamora Chinchipe" ///
	218021 "Napo, Orellana, Sucumbíos" ///
	218099 "Unknown"			
	label value geolev1 geolev1

	*¡ATENCIÓN! Confirmar que region_c y geolev1 tienen la misma cantidad de registros.
	tab geolev1 region_c,m 

    ********
	*pais_c*
	********
	gen str3 pais_c = "ECU" 

    ********
	*anio_c*
	********
	gen int anio_c = 2022
	
    *******************
    *idh_ch (ID hogar)*
    *******************
	* generar variable de ID tipo string. cambiar el formato según corresponda.	
	*MIG: Ya está en tostring, cambio a clonevar
	*tostring id_hog, gen(idh_ch) format("%16.0f")
	clonevar idh_ch = id_hog
	
	
	**********************
    *idp_ci (ID personas)*
    **********************
	* generar variable de ID tipo string. cambiar el formato según corresponda.
	* Revisar que no existan duplicados en idp_ci.
	**Si ya está en tostring, cambio a clonevar. Para Ecuador: ID_PER: Es la variable identificadora a nivel de persona, mediante la concatenación de las variables: I01, I02, I03, I04, I05, I10, INH, P00 
	*tostring id_per, gen(idp_ci) format("%16.0f")	
	clonevar idp_ci = id_per
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
	gen estrato_ci = . 

	*****
	*upm*
	*****
	gen upm = .
	
    ********
	*Zona_c*
	********
	gen byte zona_c=.
	replace zona_c=1 if aur == 1 
	replace zona_c=0 if aur == 2
	tab zona_c
	

************************************
*** 2. Demografía (18 variables) ***
************************************

    ********
	*sexo_c*
	********
	gen byte sexo_ci =.
	replace sexo_ci = 1 if p02==1
	replace sexo_ci = 2 if p02==2
	tab sexo_ci

	
	********
	*edad_c*
	********
	gen int edad_ci = p03
	tab edad_ci

	*************
	*relacion_ci*
	*************
	*MIG: falta clasificar 12 y 13, para ECU, Miembro vivienda colectiva y persona sin vivienda. 
	gen byte relacion_ci = .
	replace relacion_ci = 1 if p01 == 1
	replace relacion_ci = 2 if p01 == 2
	replace relacion_ci = 3 if inlist(p01,3,4)
	replace relacion_ci = 4 if inlist(p01,5,6,7,8,9)
	replace relacion_ci = 5 if p01 == 10
	replace relacion_ci = 6 if p01 == 11
	replace relacion_ci = 0 if inlist(p01,12,13)
	tab relacion_ci

	**********
	*civil_ci*
	**********
	gen	byte civil_ci=.
	replace civil_ci=1 if p31==6
	replace civil_ci=2 if inlist(p31,1,5) 
	replace civil_ci=3 if inlist(p31,2,3)
	replace civil_ci=4 if p31==4

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
	replace afro_ci =1 if p11r == 2
	replace afro_ci =0 if inlist(p11r,1,3,4,5,6)
	
	*********
	*indi_ci*
	*********	
	gen byte ind_ci =. 		  // se queda como missing (.) si no existe la pregunta
	replace ind_ci =1 if p11r==1
	replace ind_ci =0 if inlist(p11r,2,3,4,5,6)

	**************
	*noafroind_ci*
	**************
	gen byte noafroind_ci =.   // se queda como missing (.) si no existe la pregunta
	replace noafroind_ci =1 if afro_ci==0 & ind_ci==0
	replace noafroind_ci =0 if afro_ci==1 | ind_ci==1
******Montuvio en otro.

	************
	*afroind_ci*
	************
	gen byte afroind_ci=. 
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
	gen byte dis_ci=. 
	replace dis_ci=1 if inlist(p0701,2,3,4)
	replace dis_ci=1 if inlist(p0702,2,3,4)
	replace dis_ci=1 if inlist(p0703,2,3,4)
	replace dis_ci=1 if inlist(p0704,2,3,4)
	replace dis_ci=1 if inlist(p0705,2,3,4)
	replace dis_ci=1 if inlist(p0706,2,3,4)
	replace dis_ci=0 if (p0701==1 & p0702==1 & p0703==1 & p0704==1 & p0705==1 & p0706==1)
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	replace disWG_ci=1 if inlist(p0701,3,4)
	replace disWG_ci=1 if inlist(p0702,3,4) 
	replace disWG_ci=1 if inlist(p0703,3,4) 
	replace disWG_ci=1 if inlist(p0704,3,4) 
	replace disWG_ci=1 if inlist(p0705,3,4) 
	replace disWG_ci=1 if inlist(p0706,3,4) 
	replace disWG_ci=0 if inlist(p0701,1,2) & inlist(p0702,1,2) & inlist(p0703,1,2) & inlist(p0704,1,2) & inlist(p0705,1,2) & inlist(p0706,1,2)
	
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
	replace migrante_ci=1 if p08==3
	replace migrante_ci=. if p08==.
	 	
	****************
    *migrantiguo5_ci*
    ****************

	gen byte migrantiguo5_ci=0
	replace migrantiguo5_ci=1 if migrante_ci==1 & inlist(p09,1,2) 
	replace migrantiguo5_ci=. if migrante_ci==0
	
	
	***********
	*miglac_ci*
	***********
	gen byte miglac_ci=0
	replace miglac_ci=1 if p08c=="8810" & migrante_ci ==1
	replace miglac_ci=. if migrante_ci!=1

	
***********************************
*** 5. Educación (13 variables) ***
***********************************
	
	
	*********
	*aedu_ci*
	*********
	gen byte aedu_ci=0 if p17r==1
	replace aedu_ci=0 if p17r==2
	replace aedu_ci=0 if p17r==3
	replace aedu_ci=0 if p17r==4 & p18r==0
	replace aedu_ci=0 if p17r==4 & p18r==1
	replace aedu_ci=3 if p17r==4 & p18r==2
	replace aedu_ci=3 if p17r==4 & p18r==3
	replace aedu_ci=5 if p17r==4 & p18r==5
	replace aedu_ci=5 if p17r==4 & p18r==5
	replace aedu_ci=7 if p17r==4 & p18r==6
	replace aedu_ci=. if p17r==4 & inrange(p18r,7,10)
	replace aedu_ci=0+p18r 	if p17r==5 & p18r!=.
	replace aedu_ci=10+p18r if p17r==6 & p18r!=.
	replace aedu_ci=13+p18r if p17r==8 & p18r!=.
	replace aedu_ci=13+p18r if p17r==9 & p18r!=.
	replace aedu_ci=18+p18r if p17r==10 & p18r!=.
	replace aedu_ci=20+p18r if p17r==11 & p18r!=.
	replace aedu_ci=. if p17r==. | p18r==.

	**********
	*eduno_ci*
	**********
	gen byte eduno_ci=(aedu_ci==0) 
	replace eduno_ci=. if aedu_ci==. 

	**********
	*edupi_ci*
	**********
	gen byte edupi_ci=(aedu_ci>=0 & aedu_ci<=5) 
	replace edupi_ci=. if aedu_ci==. 

	**********
	*edupc_ci*
	**********
	gen byte edupc_ci=(aedu_ci==6) 
	replace edupc_ci=. if aedu_ci==. 
	
	*secundaria?
	
	**********
	*edusi_ci*
	**********
	gen byte edusi_ci=(aedu_ci>=7 & aedu_ci<=11) 
	replace edusi_ci=. if aedu_ci==. 

	**********
	*edusc_ci*
	**********
	gen byte edusc_ci=(aedu_ci==12) 
	replace edusc_ci=. if aedu_ci==. 

	***********
	*edus1i_ci*
	***********
	gen byte edus1i_ci=(aedu_ci>7 & aedu_ci<9)
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
	gen byte edus2c_ci=(aedu_ci==12)
	replace edus2c_ci=. if aedu_ci==. 

	***********
	*edupre_ci*
	***********
	gen byte edupre_ci= p17r==3 & p18r==2
	replace edupre_ci=. if aedu_ci==.
	
	***********
	*asiste_ci*
	***********
	gen byte asiste_ci=1 if p15==1
	replace asiste_ci=0 if p15==2
	replace asiste_ci=. if p15==.

	**********
	*literacy*
	**********
	gen byte literacy=1 if p19==1
	replace literacy=0 if p19==2
	replace literacy=. if p19==.
		
****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

    *************
    *condocup_ci_INEC_inec*
    *************
	gen byte condocup_ci_INEC=.
	replace condocup_ci_INEC=1 if p22==1		 //trabajo por ingreso
	replace condocup_ci_INEC=1 if inlist(p22,2,3,4,5) & p23==1 & inlist(p24,1,2)		 //recuperación ocupados (agricultura mayor parte para la venta)	
	replace condocup_ci_INEC=1 if inlist(p22,2,3,4,5) & p23==2	//recuperación ocupados (no agrícolas)
	replace condocup_ci_INEC=1 if p22==6 & inlist(p24,1,2)	//recuperación ocupados (agricultura mayor parte venta)
	replace condocup_ci_INEC=2 if p22==7 & p25==1 //desocupados: no trabajo y busca trabajo
	replace condocup_ci_INEC=2 if p22==6 & inlist(p24,3,4) & p25==1	//recuperados desocupados por el flujo agricultura/autoconsumo y busca trabajo
	replace condocup_ci_INEC=2 if inlist(p22,2,3,4,5) & p23==1 & inlist(p24,3,4) & p25==1		 // recuperados desocupados (autoconsumo, busca trabajo)
	replace condocup_ci_INEC=3 if p22==7 & p25==2 //Fuera FT
	replace condocup_ci_INEC=3 if p22==6 & inlist(p24,3,4) & p25==2	//Fuera FT, labores agricolas, autoconsumo, no busca trabajo.
	replace condocup_ci_INEC=3 if inlist(p22,2,3,4,5) & p23==1 & inlist(p24,3,4) & p25==2  //Fuera FT,autoconsumo, no busca trabajo
	replace condocup_ci_INEC=4 if p03<15	//no responde por ser menor de edad
	
	
	*************
    *condocup_ci*
    *************
	gen byte condocup_ci=.
	replace condocup_ci=1 if p22==1		 //trabajo por ingreso
	replace condocup_ci=1 if inlist(p22,2,3,4,5) & p23==1 & inlist(p24,1,2)		 //recuperación ocupados (agricultura mayor parte para la venta)	
	replace condocup_ci=1 if inlist(p22,2,3,4,5) & p23==2	//recuperación ocupados (no agrícolas)
	replace condocup_ci=1 if p22==6 & inlist(p24,1,2)	//recuperación ocupados (agricultura mayor parte venta)
	replace condocup_ci=2 if p22==7 & p25==1 //desocupados: no trabajo y busca trabajo
	replace condocup_ci=1 if p22==6 & inlist(p24,3,4) & p25==1	//recuperados desocupados por el flujo agricultura/autoconsumo y busca trabajo
	replace condocup_ci=1 if inlist(p22,2,3,4,5) & p23==1 & inlist(p24,3,4) & p25==1		 // recuperados desocupados (autoconsumo, busca trabajo)
	replace condocup_ci=3 if p22==7 & p25==2 //Fuera FT
	replace condocup_ci=1 if p22==6 & inlist(p24,3,4) & p25==2	//Fuera FT, labores agricolas, autoconsumo, no busca trabajo.
	replace condocup_ci=1 if inlist(p22,2,3,4,5) & p23==1 & inlist(p24,3,4) & p25==2  //Fuera FT,autoconsumo, no busca trabajo
	replace condocup_ci=4 if p03<15	//no responde por ser menor de edad
	
	
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

	*******************
    *rama de actividad* 
	*A que clasificación del CIIU corresponde la que se encuentra en el manual de censos?
	*No corresponde a IPUMS: https://international.ipums.org/international-action/variables/EC2010A_0493#codes_section
	*No corresponde al de las encuestas de hogares:https://idbg.sharepoint.com/:w:/r/sites/DataGovernance-SCL/Shared%20Documents/General/D.%20Collections/D.1%20-%20Household%20Socio-Economic%20Surveys/D.1.1%20armonizaci%C3%B3n_microdatos/D.1.1%20Manual%20de%20armonizaci%C3%B3n%20microdatos%20encuestas%20de%20hogares.docx?d=wcecd566b9bf24a4f8553b7efc1a45782&csf=1&web=1&e=Roe2hW 
	    *******************

	destring p28, replace
	gen byte rama_ci=.
	replace rama_ci = 1 if (p28>=111 & p28<=322) & emp_ci==1
	replace rama_ci = 2 if (p28>=510 & p28<=990) & emp_ci==1
	replace rama_ci = 3 if (p28>=1010 & p28<=3320) & emp_ci==1
	replace rama_ci = 4 if (p28>=3510 & p28<=3900) & emp_ci==1
	replace rama_ci = 5 if (p28>=4100 & p28<=4390) & emp_ci==1
	replace rama_ci = 6 if (p28>=4510 & p28<=4799) & emp_ci==1
	replace rama_ci = 7 if (p28>=5510 & p28<=5630) & emp_ci==1
	replace rama_ci = 8 if ((p28>=4911 & p28<=5320) | (p28>=6110 & p28<=6190)) & emp_ci==1
	replace rama_ci = 9 if (p28>=6411 & p28<=6630) & emp_ci==1
	replace rama_ci = 10 if (p28>=8411 & p28<=8430) & emp_ci==1
	replace rama_ci = 11 if ((p28>=6810 & p28<=6820) | (p28>=6910 & p28<=8292)) & emp_ci==1	
  replace rama_ci = 12 if (p28>=8510 & p28<=8550) & emp_ci==1
 replace rama_ci = 13 if (p28>=8610 & p28<=8890) & emp_ci==1	
  replace rama_ci = 14 if ((p28>=5811 & p28<=6020) | (p28>=6201 & p28<=6399) | (p28>=9000 & p28<=9900)) & emp_ci==1 
 replace rama_ci = 15 if (p28>=9700 & p28<=9820) & emp_ci==1	

	
	**************
    *categopri_ci*
    **************
	*Recodifico a missing se ignora
	gen byte categopri_ci=.
	replace categopri_ci=0 if emp_ci==1
	replace categopri_ci=1 if inlist(p29,5,7) & emp_ci==1
	replace categopri_ci=2 if p29==6 & emp_ci==1
	replace categopri_ci=3 if inlist(p29,1,2,3,4) & emp_ci==1
	replace categopri_ci=4 if p29==8 & emp_ci==1

	
	*************
    *spublico_ci* Lo construyo con la variable de categoría de ocupación (no con rama como está en el template)
    *************
	
	gen byte spublico_ci=.
	replace spublico_ci=0 if emp_ci==1
	replace spublico_ci=1 if emp_ci==1 & p29==2

		
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************	
*MIG donde clasifico ötro material?	

	********
	*luz_ch*
	********
	*MIG la pregunta es diferente/ acceso a red pública energía.
	gen byte luz_ch=.
	replace luz_ch=1 if v12==1
	replace luz_ch=0 if v12==2

	*********
	*piso_ch*
	*********
	*MIG en que clasificación va la tierra, tabla sin tratar y cania sin tratar?
	gen byte piso_ch=.
	replace piso_ch = 0 if v07==7
	replace piso_ch = 1 if inlist(v07,5,6)
 	replace piso_ch = 2 if inlist(v07,1,2,3,4)
	
	**********
	*pared_ch*
	**********
	*MIG donde clasifico otro material?
	gen byte pared_ch=.
	replace pared_ch=1 if inlist(v05,5,6,7)
	replace pared_ch=2 if inlist(v05,1,2,3,4)

	**********
	*techo_ch*
	**********
	*MIG revisar el documento manual, no concuerda con los labels.
	*borre el no tiene techo
	gen byte techo_ch=.
	replace techo_ch=1 if inlist(v03,5,6)
	replace techo_ch=2 if inlist(v03,1,2,3,4)

	**********
	*resid_ch*
	**********
	gen byte resid_ch=.
	replace resid_ch=0 if inlist(v14,1,2)
	replace resid_ch=1 if inlist(v14,4,5)
	replace resid_ch=2 if inlist(v14,3,6)
	replace resid_ch=3 if v14==7

	*********
	*dorm_ch*
	*********
	*MIG
	gen byte dorm_ch=.
	replace dorm_ch=h01

	************
	*cuartos_ch*
	************
	*MIG
	gen byte cuartos_ch=.
	replace cuartos_ch=v15
	
	***********
	*cocina_ch*
	***********
	gen byte cocina_ch=.
	replace cocina_ch=1 if h02==1
	replace cocina_ch=0 if h02==2
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch=.
	replace telef_ch=1 if h1001==1
	replace telef_ch=0 if h1001==0
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=.
	replace refrig_ch=1 if h1006==1
	replace refrig_ch=0 if h1006==0
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	replace auto_ch=1 if h1011==1
	replace auto_ch=0 if h1011==0

	**********
	*compu_ch*
	**********
	gen byte compu_ch=.
	replace compu_ch=1 if h1005==1
	replace compu_ch=0 if h1005==0

	*************
	*internet_ch*
	************* 
	gen byte internet_ch=.
	replace internet_ch=1 if h1004==1
	replace internet_ch=0 if h1004==0

	********
	*cel_ch*
	********
	gen byte cel_ch=.
	replace cel_ch=1 if h1002==1
	replace cel_ch=0 if h1002==0

	*************
	*viviprop_ch*
	*************
	*MIG: ver clasificación.
	gen byte viviprop_ch1=.
	replace viviprop_ch=1 if inlist(h09,1,2,3)
	replace viviprop_ch=0 if inlist(h09,4,5,6)

***************************************************
*** 7.2 Vivienda - variables Wash (4 variables) ***
***************************************************	

	************
	*aguaentubada_ch*
	************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch=1 if inlist(v09,1,2,3)
	replace aguaentubada_ch=0 if v09==4
	
	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch=1 if inlist(v10,1)
	replace aguared_ch=0 if inlist(v10,2,3,4,5)
	
	************
	*aguafuente_ch*
	************
	gen aguafuente_ch=.
	replace aguafuente_ch=1 if inlist(v10, 1,2) & inlist(v09,1,2)
	replace aguafuente_ch=2 if inlist(v10, 1,2) & inlist(v09,3,4)
	replace aguafuente_ch=6 if inlist(v10, 4)
	replace aguafuente_ch=10 if inlist(v10,3,5)
	
	************
	*aguadist_ch*
	************
	gen aguadist_ch=.
	replace aguadist_ch = 1 if inlist(v09, 1)
	replace aguadist_ch = 2 if inlist(v09, 2)
	replace aguadist_ch = 3 if inlist(v09, 3)
	replace aguadist_ch = 0 if inlist(v09, 4)
	
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
	replace bano_ch = 0 if v11 == 7
	replace bano_ch = 1 if v11 == 1
	replace bano_ch = 2 if v11 == 2
	replace bano_ch = 3 if inlist(v11,3,4) 
	replace bano_ch = 4 if v11 == 5
	replace bano_ch = 6 if v11 == 6
	
	***********
	*banoex_ch*
	***********
	gen banoex_ch =.
	replace banoex_ch = 0 if inlist(h03,2)
	replace banoex_ch = 1 if inlist(h03,1,3)
	
	************
	*sinbano_ch*
	************
	gen sinbano_ch =.
	replace sinbano_ch = 3 if inlist(v11,7)
	replace sinbano_ch = 0 if inlist(v11,1,2,3,4,5,6)

	************
	*conbano_ch*
	************
	gen byte conbano_ch=.
	replace conbano_ch=1 if inlist(v11,1,2,3,4,5,6)
	replace conbano_ch=0 if v11==7
	
	***********************
	*banoalcantarillado_ch*
	***********************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch=1 if v11==1
	replace banoalcantarillado_ch=0 if inlist(v11,2,3,4,5,6,7)
	
	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	replace des1_ch=0 if v11==7
	replace des1_ch=1 if inlist(v11,1,2,3,4,5)
	replace des1_ch=2 if v11==6

*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte ECU_m_pared_ch= v05
	label var ECU_m_pared_ch  "Material de las paredes según el censo del país - variable original"
	label def ECU_m_pared_ch  1 "Hormigón" 2 "Ladrillo o bloque" 3 "Panel prefabricado" 4 "Adobe o tapia" 5 "Madera" 6 "Cana revestida o bahareque" 7 "Cana no revestida" 8 "Otro material"  //categorías originales del país
	label val ECU_m_pared_ch  ECU_m_pared_ch 

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte ECU_m_piso_ch= v07
	label var ECU_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	label def ECU_m_piso_ch  1 "Duela, parquet, tablón o piso flotante" 2 "Cerámica, baldosa, vinil o porcelanato" 3 "Mármol o marmetón" 4 "Ladrillo o cemento" 5 "Tabla sin tratar" 6 "Caña sin tratar" 7 "Tierra" 8 "Otro material"   //categorías originales del país
	label val ECU_m_piso_ch  ECU_m_piso_ch 
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte ECU_m_techo_ch= v03
	label var ECU_m_techo_ch  "Material del techo según el censo del país - variable original"
	label def ECU_m_techo_ch  1 "Hormigón (losa, cemento)" 2 "Fibrocemento, asbesto (eternit, eurolit)" 3 "Zinc, aluminio" 4 "Teja" 5 "Palma, paja u hoja" 6"Otro material" //categorías originales del país
	label val ECU_m_techo_ch ECU_m_techo_ch 
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long ECU_ingreso_ci = .
	label var ECU_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long ECU_ingresolab_ci = .	
	label var ECU_ingreso_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte ECU_dis_ci = dis_ci
	label var ECU_dis_ci  "Individuos con discapacidad según el censo del país - variable original"
	label def ECU_dis_ci 1 "Sí" 0 "No"   //categorías originales del país
	label val ECU_dis_ci ECU_dis_ci


/*******************************************************************************
   III. Incluir variables externas
*******************************************************************************/
capture drop _merge
merge m:1 pais_c anio_c using "Z:\general_documentation\data_externa\poverty\International_Poverty_Lines\clean\5_International_Poverty_Lines_LAC_long.dta", keepusing (ppp_2011 cpi_2011 lp19_2011 lp31_2011 lp5_2011 tc_wdi ppp_wdi2011 lp365_2017 lp685_2017)
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
capture label var lp365_2017  "Línea de pobreza USD3.65 día en moneda local a precios corrientes a PPA 2017"
capture label var lp685_2017 "Línea de pobreza USD6.85 por día en moneda local a precios corrientes a PPA 2017"

drop ppp_2011 cpi_2011 lp19_2011 lp31_2011 lp5_2011 tc_wdi ppp_wdi2011 _merge


/*******************************************************************************
   IV. Revisión de que se hayan creado todas las variables
*******************************************************************************/
* CALIDAD: revisa que hayas creado todas las variables. Si alguna no está
* creada, te apacerá en rojo el nombre. 

global lista_variables region_BID_c region_c geolev1 pais_c anio_c idh_ch idp_ci factor_ci factor_ch estrato_ci upm zona_c sexo_c edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch miembros_ci clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch afro_ci ind_ci noafroind_ci afroind_ci afro_ch ind_ch noafroind_ch afroind_ch  dis_ci disWG_ci dis_ch migrante_ci migrantiguo5_ci miglac_ci aedu_ci eduno_ci edupi_ci edupc_ci edusi_ci edusc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci edupre_ci asiste_ci literacy condocup_ci emp_ci desemp_ci pea_ci rama_ci  categopri_ci spublico_ci luz_ch piso_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch1 aguaentubada_ch aguared_ch aguafuente_ch aguadist_ch aguadisp1_ch aguadisp2_ch aguamide_ch bano_ch banoex_ch banoalcantarillado_ch sinbano_ch conbano_ch des1_ch ${PAIS}_ingreso_ci ${PAIS}_ingresolab_ci ${PAIS}_m_pared_ch ${PAIS}_m_piso_ch ${PAIS}_m_techo_ch ${PAIS}_dis_ci tc_c ipc_c lp19_ci lp31_ci lp5_ci lp365_2017 lp685_2017


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

keep  $lista_variables p00 id_viv id_hog id_per

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
*
compress
save "$base_out", replace 
log close

********************************************************************************
******************* FIN. Muchas gracias por tu trabajo ;) **********************
********************************************************************************