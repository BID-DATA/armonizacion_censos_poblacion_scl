* (Versión Stata 19)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: CHL
Año: 2024
Autores: Matias Rodriguez (SCL/SCL)
Última versión: Enero 14, 2026
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

clear all
set more off

global ruta = "${censusFolder}"
local PAIS CHL
local ANIO 2024

local base_in  = "$ruta\\raw\\`PAIS'\\`ANIO'\\data_merge\\`PAIS'_`ANIO'_NOIPUMS.dta" 
local base_out = "$ruta\\clean\\`PAIS'\\`PAIS'_`ANIO'_censusBID.dta"
local log_file ="$ruta\\clean\\`PAIS'\\`PAIS'_`ANIO'_censusBID.log"                                                   
capture log close
log using "`log_file'", replace  //agregar ,replace si ya está creado el log_file en tu carpeta

use "`base_in'", clear

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
	gen byte region_BID_c = 4

	**********
	*region_c*   
	**********
	destring provincia, replace
	gen int region_c = provincia
	label define region_c ///
		11  "Iquique" ///
		14  "Del Tamarugal" ///
		21  "Antofagasta" ///
		22  "El Loa" ///
		23  "Tocopilla" ///
		31  "Copiapó" ///
		32  "Chañaral" ///
		33  "Huasco" ///
		41  "Elqui" ///
		42  "Choapa" ///
		43  "Limarí" ///
		51  "Valparaíso" ///
		52  "Isla de Pascua" ///
		53  "Los Andes" ///
		54  "Petorca" ///
		55  "Quillota" ///
		56  "San Antonio" ///
		57  "San Felipe de Aconcagua" ///
		58  "Marga Marga" ///
		61  "Cachapoal" ///
		62  "Cardenal Caro" ///
		63  "Colchagua" ///
		71  "Talca" ///
		72  "Cauquenes" ///
		73  "Curicó" ///
		74  "Linares" ///
		81  "Concepción" ///
		82  "Arauco" ///
		83  "Biobío" ///
		91  "Cautín" ///
		92  "Malleco" ///
		101 "Llanquihue" ///
		102 "Chiloé" ///
		103 "Osorno" ///
		104 "Palena" ///
		111 "Coyhaique" ///
		112 "Aysén" ///
		113 "Capitán Prat" ///
		114 "General Carrera" ///
		121 "Magallanes" ///
		122 "Antártica Chilena" ///
		123 "Tierra del Fuego" ///
		124 "Última Esperanza" ///
		131 "Santiago" ///
		132 "Cordillera" ///
		133 "Chacabuco" ///
		134 "Maipo" ///
		135 "Melipilla" ///
		136 "Talagante" ///
		141 "Valdivia" ///
		142 "Ranco" ///
		151 "Arica" ///
		152 "Parinacota" ///
		161 "Diguillín" ///
		162 "Itata" ///
		163 "Punilla"
	label values region_c region_c
	
	*********
	*geolev1*
	*********
	gen long geolev1 = .
	replace geolev1 = 152014 if inlist(provincia, 11, 14)
	replace geolev1 = 152021 if provincia == 21
	replace geolev1 = 152022 if provincia == 22
	replace geolev1 = 152023 if provincia == 23
	replace geolev1 = 152031 if provincia == 31
	replace geolev1 = 152032 if provincia == 32
	replace geolev1 = 152033 if provincia == 33
	replace geolev1 = 152041 if provincia == 41
	replace geolev1 = 152042 if provincia == 42
	replace geolev1 = 152043 if provincia == 43
	replace geolev1 = 152051 if inlist(provincia, 51, 52, 55, 58)
	replace geolev1 = 152053 if provincia == 53
	replace geolev1 = 152054 if provincia == 54
	replace geolev1 = 152056 if provincia == 56
	replace geolev1 = 152057 if provincia == 57
	replace geolev1 = 152061 if provincia == 61
	replace geolev1 = 152062 if provincia == 62
	replace geolev1 = 152063 if provincia == 63
	replace geolev1 = 152071 if provincia == 71
	replace geolev1 = 152072 if provincia == 72
	replace geolev1 = 152073 if provincia == 73
	replace geolev1 = 152074 if provincia == 74
	replace geolev1 = 152081 if provincia == 81
	replace geolev1 = 152082 if provincia == 82
	replace geolev1 = 152083 if provincia == 83
	replace geolev1 = 152091 if provincia == 91
	replace geolev1 = 152092 if provincia == 92
	replace geolev1 = 152101 if provincia == 101
	replace geolev1 = 152102 if inlist(provincia, 102, 104)
	replace geolev1 = 152103 if provincia == 103
	replace geolev1 = 152111 if provincia == 111
	replace geolev1 = 152112 if inlist(provincia, 112, 113, 114)
	replace geolev1 = 152121 if inlist(provincia, 121, 122, 123)
	replace geolev1 = 152124 if provincia == 124
	replace geolev1 = 152131 if provincia == 131
	replace geolev1 = 152132 if provincia == 132
	replace geolev1 = 152133 if provincia == 133
	replace geolev1 = 152134 if provincia == 134
	replace geolev1 = 152135 if provincia == 135
	replace geolev1 = 152136 if provincia == 136
	replace geolev1 = 152141 if inlist(provincia, 141, 142)
	replace geolev1 = 152151 if inlist(provincia, 151, 152)
	replace geolev1 = 152163 if inlist(provincia, 161, 162, 163)
	label define geolev1 ///
		152014 "Iquique, Tamarugal" ///
		152021 "Antofagasta" ///
		152022 "El Loa" ///
		152023 "Tocopilla" ///
		152031 "Copiapó" ///
		152032 "Chañaral" ///
		152033 "Huasco" ///
		152041 "Elqui" ///
		152042 "Choapa" ///
		152043 "Limarí" ///
		152051 "Valparaíso, Quillota, Marga Marga, Isla de Pascua" ///
		152053 "Los Andes" ///
		152054 "Petorca" ///
		152056 "San Antonio" ///
		152057 "San Felipe de Aconcagua" ///
		152061 "Cachapoal" ///
		152062 "Cardenal Caro" ///
		152063 "Colchagua" ///
		152071 "Talca" ///
		152072 "Cauquenes" ///
		152073 "Curicó" ///
		152074 "Linares" ///
		152081 "Concepcion" ///
		152082 "Arauco" ///
		152083 "Biobío" ///
		152091 "Cautin" ///
		152092 "Malleco" ///
		152101 "Llanquihue" ///
		152102 "Chiloe, Palena" ///
		152103 "Osorno" ///
		152111 "Coihaique" ///
		152112 "Aisén, General Carrera, Capitan Prat" ///
		152121 "Magallanes, Tierra del Fuego, Antártica Chilena" ///
		152124 "Última Esperanza" ///
		152131 "Santiago" ///
		152132 "Cordillera" ///
		152133 "Chacabuco" ///
		152134 "Maipo" ///
		152135 "Melipilla" ///
		152136 "Talagante" ///
		152141 "Valdivia, Ranco" ///
		152151 "Arica, Parinacota" ///
		152163 "Diguillín, Itata, Punilla"
	label value geolev1 geolev1

    ********
	*pais_c*
	********
	gen str3 pais_c = "CHL" 

    ********
	*anio_c*
	********
	gen int anio_c = 2024
	
    *******************
    *idh_ch (ID hogar)*
    *******************
	egen idh_ch = concat(id_vivienda id_hogar region provincia comuna), punct(_)
	tostring idh_ch, replace format("%16.0f")
	*egen unique_tag = tag(idh_ch)
	*count if unique_tag == 1 & id_hogar!=. //6622597
	
	**********************
    *idp_ci (ID personas)*
    **********************
	egen idp_ci = concat(id_vivienda id_hogar id_persona region provincia comuna), punct(_)
	tostring idp_ci, replace format("%16.0f")
	*duplicates r idp_ci //0
		
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

	
************************************
*** 2. Demografía (18 variables) ***
************************************

    ********
	*sexo_c*
	********
	gen byte sexo_ci =.
	replace sexo_ci = 1 if sexo==1
	replace sexo_ci = 2 if sexo==2
		
	********
	*edad_c*
	********
	gen int edad_ci = edad
	replace edad_ci=. if edad==-66

	*************
	*relacion_ci*
	*************
	gen byte relacion_ci = .
	replace relacion_ci = 1 if parentesco==1
	replace relacion_ci = 2 if inlist(parentesco,2,3,4)
	replace relacion_ci = 3 if  inlist(parentesco,5,6)
	replace relacion_ci = 4 if parentesco>=7 & parentesco<=14
	replace relacion_ci = 5 if inlist(parentesco,15,17,19)
	replace relacion_ci = 6 if parentesco==16

	**********
	*civil_ci*
	**********
	gen	byte civil_ci=.
	replace civil_ci=1 if p23_est_civil == 8
	replace civil_ci=2 if inlist(p23_est_civil,1,2,3)
	replace civil_ci=3 if inlist(p23_est_civil,4,5,6)
	replace civil_ci=4 if p23_est_civil ==7

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
	*CHECK CON fre tipologia_hogar
	
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
	replace afro_ci =1 if p29_afrodescendencia>=1 & p29_afrodescendencia<=6
	replace afro_ci =0 if p29_afrodescendencia==7
	
	*********
	*indi_ci*
	*********	
	gen byte ind_ci =.
	replace ind_ci =1 if p28_autoid_pueblo==1
	replace ind_ci =0 if p28_autoid_pueblo==2

	**************
	*noafroind_ci*
	**************
	gen byte noafroind_ci =.
	replace noafroind_ci =1 if afro_ci==0 & ind_ci==0
	replace noafroind_ci =0 if afro_ci==1 | ind_ci==1

	************
	*afroind_ci*
	************
	gen byte afroind_ci=. 
	replace afroind_ci=1 if ind_ci==1 
	replace afroind_ci=2 if afro_ci==1
	replace afroind_ci=3 if noafroind_ci== 1
	
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
	replace dis_ci=0 if p32a_dificultad_ver==1 & p32b_dificultad_oir==1 & p32c_dificultad_mover==1 & p32d_dificultad_cogni==1 & p32e_dificultad_cuidado==1 & p32f_dificultad_comunic==1
	replace dis_ci=1 if p32a_dificultad_ver>1 | p32b_dificultad_oir>1 | p32c_dificultad_mover>1 | p32d_dificultad_cogni>1 | p32e_dificultad_cuidado>1 | p32f_dificultad_comunic>1
		
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=.
	replace disWG_ci=0 if inlist(p32a_dificultad_ver,1,2) & inlist(p32b_dificultad_oir,1,2) & inlist(p32c_dificultad_mover,1,2) & inlist(p32d_dificultad_cogni,1,2) & inlist(p32e_dificultad_cuidado,1,2) & inlist(p32f_dificultad_comunic,1,2)
replace disWG_ci=1 if inlist(p32a_dificultad_ver,3,4) | inlist(p32b_dificultad_oir,3,4) | inlist(p32c_dificultad_mover,3,4) | inlist(p32d_dificultad_cogni,3,4) | inlist(p32e_dificultad_cuidado,3,4) | inlist(p32f_dificultad_comunic,3,4)
	 
	********
	*dis_ch*
	********
	egen byte dis_ch = sum(dis_ci), by(idh_ch) 
	replace dis_ch=1 if dis_ch>=1 & dis_ch!=.
	
	
**********************************
*** 4. Migración (3 variables) ***
**********************************	

    ****************
    **migrante_ci***
    ****************
	gen byte migrante_ci=0 
	replace migrante_ci=1 if p25_lug_nacimiento_rec == 2
	 	
	****************
    *migantiguo5_ci*
    ****************
	gen byte migrantiguo5_ci=0
	replace migrantiguo5_ci=1 if p24_lug_resid5==4 
	
	***********
	*miglac_ci*
	***********
	gen byte miglac_ci=0
	replace miglac_ci = 1 if inlist(p25_lug_nacimiento_esp, 5, 13,32,68,170,332,604,862) & migrante_ci == 1


***********************************
*** 5. Educación (13 variables) ***
***********************************	
	*********
	*aedu_ci*
	*********
	* Censo no incluye desagregación por nivel/curso aprobado. Viene por defecto variable con el nivel más alto alcanzado, es decir, donde la persona aprobó al menos un curso, y el último curso aprobado por la persona. Por ejemplo, una persona que su último curso y nivel más alto alcanzado es 4° de enseñanza media, tiene 12 años de escolaridad.
	gen byte aedu_ci= escolaridad
	replace aedu_ci=. if escolaridad == -99
 
	**********
	*eduno_ci*
	**********
	gen byte eduno_ci = (aedu_ci == 0) 
	replace eduno_ci = . if aedu_ci == .
 
	**********
	*edupi_ci*
	**********
	*Logro educativo de acuerdo con la Clasificación Internacional Normalizada de la Educación (CINE11)
	gen byte edupi_ci = .
	replace edupi_ci = 1 if cine11 == 3  // 03: Primaria en forma parcial
	replace edupi_ci = 0 if cine11 != 3 & cine11 != -99 & cine11 != .
		
	**********
	*edupc_ci*
	**********
	*Logro educativo de acuerdo con la Clasificación Internacional Normalizada de la Educación (CINE11)
	gen byte edupc_ci = .
	replace edupc_ci = 1 if inlist(cine11, 4, 5)  // 10: Educación primaria (nivel 1), 14: Educación primaria (nivel 2), con orientación general
	replace edupc_ci = 0 if !inlist(cine11, 4, 5) & cine11 != -99 & cine11 != .

	**********
	*edusi_ci*
	**********
	* CINE11 no incluye educación parcial para secundaria, se utiliza escolaridad
	gen edusi_ci=(aedu_ci>=7 & aedu_ci<12)
	replace edusi_ci=. if aedu_ci==.
	
	**********
	*edusc_ci*
	**********
	*Logro educativo de acuerdo con la Clasificación Internacional Normalizada de la Educación (CINE11)
	gen byte edusc_ci = .
	replace edusc_ci = 1 if inlist(cine11, 6, 7)  // 24: Educación secundaria, con orientación general, 25: Educación secundaria, con orientación vocacional 
	replace edusc_ci = 0 if !inlist(cine11, 6, 7) & cine11 != -99 & cine11 != .

	***********
	*edus1i_ci*
	***********
	* CINE11 no incluye educación parcial para secundaria, se utiliza escolaridad
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<8)
	replace edus1i_ci=. if aedu_ci==. // missing a los NIU & missing

	***********
	*edus1c_ci*
	***********
	gen byte edus1c_ci=(aedu_ci==8)
	replace edus1c_ci=. if aedu_ci==.
	
	***********
	*edus2i_ci*
	***********
	gen byte edus2i_ci=(aedu_ci>8 & aedu_ci<12)
	replace edus2i_ci=. if aedu_ci==.
	
	***********
	*edus2c_ci*
	***********
	gen byte edus2c_ci=(aedu_ci==12)
	replace edus2c_ci=. if aedu_ci==.
	
	***********
	*edupre_ci*
	***********
	* CINE11 solo incluye "02: Educación de la primera infancia (incluye la forma parcial)" lo cual no cumple el requisito de educación preescolar completa.
	gen byte edupre_ci=.
 
    ***********
    *asiste_ci*
    ***********
	gen byte asiste_ci = .
	replace asiste_ci = 1 if p33_edu_asiste == 1
	replace asiste_ci = 0 if p33_edu_asiste == 0 & p33_edu_asiste != -99 & p33_edu_asiste != .

	**********
	*literacy*
	**********
	gen byte literacy = .
	replace literacy = 1 if p37_alfabet == 1
	replace literacy = 0 if p37_alfabet == 0 & p37_alfabet != -99 & p37_alfabet != .
	
	
****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************	
	
    *************
    *condocup_ci*
    *************
	gen byte condocup_ci = .
	* Ocupados
	replace condocup_ci = 1 if sit_fuerza_trabajo == 1
	* Desocupados
	replace condocup_ci = 2 if sit_fuerza_trabajo == 2
	* Inactivos
	replace condocup_ci = 3 if sit_fuerza_trabajo == 3
	* Menores de edad
	replace condocup_ci = 4 if edad < 15 
	
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
	gen byte rama_ci = .
	* 1 = Agricultura, pesca y forestal
	replace rama_ci = 1 if cod_caenes == "A" & emp_ci == 1 // Agricultura, ganadería, silvicultura y pesca
	* 2 = Minería y extracción
	replace rama_ci = 2 if cod_caenes == "B" & emp_ci == 1 // Explotación de minas y canteras
	* 3 = Industrias manufactureras
	replace rama_ci = 3 if cod_caenes == "C" & emp_ci == 1 // Industrias manufactureras
	* 4 = Electricidad, gas, agua y manejo de residuos
	replace rama_ci = 4 if inlist(cod_caenes, "D", "E") & emp_ci == 1 // Suministro de electricidad, gas, vapor y aire acondicionado & Suministro de agua; evacuación de aguas residuales, gestión de desechos y descontaminación
	* 5 = Construcción
	replace rama_ci = 5 if cod_caenes == "F" & emp_ci == 1 // Construcción
	* 6 = Comercio
	replace rama_ci = 6 if cod_caenes == "G" & emp_ci == 1 // Comercio al por mayor y al por menor; reparación de vehículos automotores y motocicletas
	* 7 = Hoteles y restaurantes
	replace rama_ci = 7 if cod_caenes == "I" & emp_ci == 1 // Actividades de alojamiento y de servicio de comidas
	* 8 = Transporte, almacenamiento y comunicaciones
	replace rama_ci = 8 if inlist(cod_caenes, "H", "J") & emp_ci == 1 // Transporte y almacenamiento & Información y comunicaciones
	* 9 = Servicios financieros y seguros
	replace rama_ci = 9 if inlist(cod_caenes, "K") & emp_ci == 1 // Actividades financieras y de seguros
	* 10 = Administración pública y defensa
	replace rama_ci = 10 if cod_caenes == "O" & emp_ci == 1 // Administración pública y defensa; planes de seguridad social de afiliación obligatoria
	* 11 = Servicios empresariales e inmobiliarios
	replace rama_ci = 11 if inlist(cod_caenes, "M", "N", "L") & emp_ci == 1 // Actividades profesionales, científicas y técnicas & Actividades de servicios administrativos y de apoyo & Actividades inmobiliarias
	* 12 = Educación
	replace rama_ci = 12 if cod_caenes == "P" & emp_ci == 1 // Enseñanza
	* 13 = Salud y trabajo social
	replace rama_ci = 13 if cod_caenes == "Q" & emp_ci == 1 // Actividades de atención de la salud humana y de asistencia social
	* 14 = Otros servicios
	replace rama_ci = 14 if inlist(cod_caenes, "R", "S", "U") & emp_ci == 1 // Actividades artísticas, de entretenimiento y recreativas & Otras actividades de servicios & Actividades de organizaciones y órganos extraterritoriales
	* 15 = Servicio doméstico
	replace rama_ci = 15 if cod_caenes == "T" & emp_ci == 1 // Actividades de los hogares como empleadores; actividades no diferenciadas de los hogares como productores de bienes y servicios para uso propio

	**************
    *categopri_ci*
    **************
	gen byte categopri_ci = .
	* 1 = Patrón o empleador
	replace categopri_ci = 1 if p40_cise_rec == 1 & emp_ci == 1  // Independiente (no se incluye variable que permita identificar empleador)
	* 2 = Cuenta Propia o independiente
	replace categopri_ci = 2 if p40_cise_rec == 1 & emp_ci == 1 // Independiente
	* 3 = Empleado o asalariado
	replace categopri_ci = 3 if p40_cise_rec == 2 & emp_ci == 1 // Dependiente
	* 4 = Trabajador no remunerado
	replace categopri_ci = 4 if p40_cise_rec == 3 & emp_ci == 1 // Trabajador/a familiar o personal no remunerado en un negocio de un integrante de su familia
	* 0 = Otra clasificación no aplica

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
	replace luz_ch=0 if p9_fuente_elect>=1 & p9_fuente_elect<=5
	replace luz_ch=1 if p9_fuente_elect==6
	
	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
	replace piso_ch=0 if inlist(p4c_mat_piso,5)
	replace piso_ch=2 if inlist(p4c_mat_piso,1,2,3,4)

	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	replace pared_ch=1 if inlist(p4a_mat_paredes,6)
	replace pared_ch=2 if inlist(p4a_mat_paredes,1,2,3,4)

	**********
	*techo_ch*
	********** 
	gen byte techo_ch=.
	replace techo_ch=0 if inlist(p4b_mat_techo,8)
	replace techo_ch=1 if inlist(p4b_mat_techo,7)
	replace techo_ch=2 if inlist(p4b_mat_techo,1,2,3,4,5,6)

	**********
	*resid_ch*
	**********
	gen byte resid_ch=. 
	replace resid_ch=0 if inlist(p10_basura,1)
	replace resid_ch=1 if inlist(p10_basura,2)
	replace resid_ch=2 if inlist(p10_basura,3,4)
	replace resid_ch=3 if inlist(p10_basura,5)

	*********
	*dorm_ch*
	*********
	gen byte dorm_ch = p5_num_dormitorios
	
	************
	*cuartos_ch* 
	************
	gen byte cuartos_ch = .
	
	***********
	*cocina_ch*
	***********
	gen byte cocina_ch = .
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch = .
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch = . 
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch = .

	**********
	*compu_ch*
	**********
	gen byte compu_ch = .
	replace compu_ch=0 if p15b_serv_compu==2
	replace compu_ch=1 if p15b_serv_compu==1

	*************
	*internet_ch*
	************* 
	gen byte internet_ch = .
	replace internet_ch=0 if inlist(2,p15d_serv_internet_fija, p15e_serv_internet_movil, p15f_serv_internet_satelital)
	replace internet_ch=1 if inlist(1,p15d_serv_internet_fija, p15e_serv_internet_movil, p15f_serv_internet_satelital)
	
	********
	*cel_ch*
	********
	gen byte cel_ch = .
	replace cel_ch=0 if p15a_serv_tel_movil==2
	replace cel_ch=1 if p15a_serv_tel_movil==1
	
	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch = .
	replace viviprop_ch=0 if inlist(p12_tenencia_viv,3,4,5,6,7,8,9)
	replace viviprop_ch=1 if inlist(p12_tenencia_viv,1,2)
	
	
***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	************
	*aguaentubada_ch*
	************
	* 7. ¿Cuál es el sistema de distribución del agua en esta vivienda? 
	gen byte aguaentubada_ch = .
	replace aguaentubada_ch = 1 if inlist(p7_distrib_agua, 1, 2) // Con llave dentro de la vivienda & Con llave dentro del sitio, pero fuera de la vivienda
	replace aguaentubada_ch = 0 if p7_distrib_agua == 3 // No tiene sistema, la acarrea

	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch = 1 if p6_fuente_agua == 1 // Red pública
	replace aguared_ch=0 if inlist(p6_fuente_agua, 2,3,4) // Pozo o noria & Camión aljibe & Río, vertiente, estero, canal, lago, agua lluvia, etc.
	
	************
	*aguafuente_ch*
	************
	gen byte aguafuente_ch = .
	* 1 = red de distribución, llave privada (dentro del hogar/terreno)
	replace aguafuente_ch = 1 if p6_fuente_agua == 1 & inlist(p7_distrib_agua, 1, 2)
	* 2 = red llave pública (red pública pero sin sistema de distribución propio)
	replace aguafuente_ch = 2 if p6_fuente_agua == 1 & p7_distrib_agua == 3
	* 6 = camión, cisterna, pipa
	replace aguafuente_ch = 6 if p6_fuente_agua == 3
	* 8 = cuerpo de agua superficial (río, vertiente, estero, canal, lago)
	replace aguafuente_ch = 8 if p6_fuente_agua == 4  // Incluye río, vertiente, estero, canal, lago, agua lluvia
	* 10 = Pozo sin clasificación clara
	replace aguafuente_ch = 10 if p6_fuente_agua == 2  // Pozo o noria sin especificar protección

	************
	*aguadist_ch*
	************
	gen byte aguadist_ch = .
	* 1 = Adentro de la casa
	replace aguadist_ch = 1 if p7_distrib_agua == 1 // Con llave dentro de la vivienda
	* 2 = Afuera de la casa pero adentro del terreno (o a menos de 100mts de distancia)
	replace aguadist_ch = 2 if p7_distrib_agua == 2 // Con llave dentro del sitio, pero fuera de la vivienda
	* 3 = Afuera de la casa y afuera del terreno (o a más de 100mts de distancia)
	replace aguadist_ch = 3 if p7_distrib_agua == 3 // No tiene sistema, la acarrea

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
	gen byte bano_ch = .
	* 0 = Sin instalaciones
	replace bano_ch = 0 if p8_serv_hig == 9 // No tiene servicio higiénico
	* 1 = Indoro a red de desagüe
	replace bano_ch = 1 if inlist(p8_serv_hig, 1, 2) // Dentro de la vivienda, conectado a una red de alcantarillado & Fuera de la vivienda, conectado a una red de alcantarillado
	* 2 = Indoro a fosa séptica
	replace bano_ch = 2 if p8_serv_hig == 3 // Conectado a una fosa séptica
	* 3 = Letrina mejorada / otra instalacion mejorada
	replace bano_ch = 3 if inlist(p8_serv_hig, 4, 8) // Conectado a pozo negro (letrina sanitaria o cajón) & Conectado a baño seco
	* 4 = Indoro/letrina a cuerpo de agua superficial o suelo
	replace bano_ch = 4 if p8_serv_hig == 5 // En un cajón sobre acequia o canal
	* 6 = Instalación que no se puede clasificar
	replace bano_ch = 6 if inlist(p8_serv_hig, 6, 7) // En un cajón conectado a otro sistema & Baño químico

	*********
	*banoex_ch*
	*********
	gen byte banoex_ch = 9
	replace banoex_ch = 0 if p8_serv_hig == 9  // No tiene baño

	*********
	*sinbano_ch*
	*********
	gen byte sinbano_ch = .
	* 0 = Tiene baño (cualquier tipo)
	replace sinbano_ch = 0 if inlist(p8_serv_hig, 1, 2, 3, 4, 5, 6, 7, 8)
	* 3 = No tiene baño pero el censo no pregunta alternativas
	replace sinbano_ch = 3 if p8_serv_hig == 9

	*****************
	*conbano_ch*
	*****************
	gen byte conbano_ch = .
	* Tiene servicio higiénico (cualquier tipo excepto "no tiene")
	replace conbano_ch = 1 if inlist(p8_serv_hig, 1, 2, 3, 4, 5, 6, 7, 8)
	* No tiene servicio higiénico
	replace conbano_ch = 0 if p8_serv_hig == 9

	*********
	*banoalcantarillado_ch*
	*********
	gen byte banoalcantarillado_ch = .
	* Tiene acceso a alcantarillado o tanque séptico
	replace banoalcantarillado_ch = 1 if inlist(p8_serv_hig, 1, 2, 3)
	* No tiene acceso a alcantarillado
	replace banoalcantarillado_ch = 0 if inlist(p8_serv_hig, 4, 5, 6, 7, 8, 9)

	*********
	*des1_ch*
	*********
	gen byte des1_ch = .
	* 0 = No cuenta con servicio
	replace des1_ch = 0 if p8_serv_hig == 9
	* 1 = Escusado conectado a la red (alcantarillado o fosa séptica)
	replace des1_ch = 1 if inlist(p8_serv_hig, 1, 2, 3)
	* 2 = Letrina u otro servicio no conectado (pozo negro, cajón, baño químico, baño seco)
	replace des1_ch = 2 if inlist(p8_serv_hig, 4, 5, 6, 7, 8)

	
*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte CHL_m_pared_ch= p4a_mat_paredes
	label var CHL_m_pared_ch  "Material de las paredes según el censo del país - variable original"
	label def CHL_m_pared_ch  1 "Hormigón armado" 2 "Albañilería: bloque de cemento, ladrillo o piedra" 3 "Tabique forrado por ambas caras (madera o acero)" 4 "Tabique sin forro interior (madera u otro)" 5 "Adobe, barro, pirca, quincha u otro material artesanal" -99 "No respuesta"  //categorías originales del país
	label val CHL_m_pared_ch CHL_m_pared_ch

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte CHL_m_piso_ch= p4c_mat_piso
	label var CHL_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	label def CHL_m_piso_ch  1 "Parquet, piso flotante, cerámico, madera, alfombra, flexit, cubrepiso u otro similar; sobre radier o vigas de madera" 2 "Radier sin revestimiento" 3 "Baldosa de cemento" 4 "Capa de cemento sobre tierra" 5 "Tierra" -99 "No respuesta"  //categorías originales del país
	label val CHL_m_piso_ch  CHL_m_piso_ch
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte CHL_m_techo_ch= p4b_mat_techo
	label var CHL_m_techo_ch  "Material del techo según el censo del país - variable original"
	label def CHL_m_techo_ch  1 "Tejas o tejuelas de arcilla, metálicas, de cemento, de madera, asfálticas o plásticas" 2 "Losa hormigón" 3 "Planchas metálicas de zinc, cobre, etc" 4 "Planchas de fibrocemento tipo pizarreño" 5 "Fonolita o plancha de fieltro embreado" 6 "Paja, coirón, totora o caña" 7 "Materiales precarios o de desecho: cartón, sacos, trozos de latas o plásticos, etc" 8 "Sin cubierta sólida de techo" -99 "No respuesta"  //categorías originales del país
	label val CHL_m_techo_ch CHL_m_techo_ch
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long CHL_ingreso_ci = .
	label var CHL_ingreso_ci "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long CHL_ingresolab_ci = .	
	label var CHL_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte CHL_dis_ci = discapacidad
	label var CHL_dis_ci  "Individuos con discapacidad según el censo del país - variable original"
	label def CHL_dis_ci 1 "Sí" 2 "No" -99 "No respuesta"
	label val CHL_dis_ci CHL_dis_ci
	

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

global lista_variables region_BID_c region_c geolev1 pais_c anio_c idh_ch idp_ci factor_ci factor_ch estrato_ci upm zona_c sexo_c edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch miembros_ci clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch afro_ci ind_ci noafroind_ci afroind_ci afro_ch ind_ch noafroind_ch afroind_ch  dis_ci disWG_ci dis_ch migrante_ci migrantiguo5_ci miglac_ci aedu_ci eduno_ci edupi_ci edupc_ci edusi_ci edusc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci edupre_ci asiste_ci literacy condocup_ci emp_ci desemp_ci pea_ci rama_ci  categopri_ci spublico_ci luz_ch piso_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch aguared_ch bano_ch des1_ch CHL_ingreso_ci CHL_ingresolab_ci CHL_m_pared_ch CHL_m_piso_ch CHL_m_techo_ch CHL_dis_ci tc_wdi ppp_wdi ppp_2021 ppp_2017 cpi cpi_2017 cpi2017 cpi_2021 cpi2021 lp365_2017 lp685_2017 lp14_2017 lp81_2017 lp420_2021 lp830_2021

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
 
