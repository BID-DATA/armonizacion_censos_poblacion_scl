* (Versión Stata 19)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: BHS
Año: 2022
Autores: Matias Rodriguez (SCL/SCL)
Última versión: Diciembre 19, 2025
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

global ruta = "${censusFolder}"  //cambiar ruta seleccionada 
global PAIS BHS    				 //cambiar
global ANIO 2022   				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using "$log_file", replace

use "$base_in", clear
	rename *, lower
	svyset _n [pweight=weight] // svy: tab c2_sex 398,165 w/ person weight
	svyset, clear
	

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

	**********
	*region_c*   
	**********
	gen byte region_c=.
	/*
	label define region_c   ///
	1 "..." 			///  
	2 "..."	 			
	label value region_c region_c
	*/
	*********
	*geolev1*
	*********
	gen long geolev1 =.
	/*
	replace geolev1= ... if ... 
	replace geolev1= ... if ...   
	label define geolev1	///
	... "..." 			///
	... "..." 			
	label value geolev1 geolev1
	*/	
    ********
	*pais_c*
	********
	gen str3 pais_c = "BHM"

    ********
	*anio_c*
	********
	gen int anio_c = 2022
	
    *******************
    *idh_ch (ID hogar)*
    *******************
	tostring hhid, gen(idh_ch) format("%16.0f")	
	
	**********************
    *idp_ci (ID personas)*
	egen idp_ci = concat(idh_ch personid)
	tostring idp_ci, replace format ("%16.0f") 
	duplicates report idp_ci // copies = 1, 11 missing are included
		
	****************************************
	*(factor_ci) factor expansión individio*
	****************************************
	gen factor_ci=weight
	
	*******************************************
	*(factor_ch) Factor de expansion del hogar*
	*******************************************
	gen factor_ch=hh_wgt
		
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

	
************************************
*** 2. Demografía (18 variables) ***
************************************

    *********
	*sexo_ci*
	*********
	gen byte sexo_ci =.
	replace sexo_ci = 1 if c2_sex==1
	replace sexo_ci = 2 if c2_sex==2
	
	********
	*edad_ci*
	********
	gen int edad_ci = .
	
	********
	*grupo_edad*
	********
	gen edad_grupo_ci = age
	la de edad_grupo_ci 1 "de 00 A 04 Años" ///
						2 "de 05 A 09 Años" ///
						3 "de 10 A 14 Años" ///
						4 "de 15 A 19 Años" ///
						5 "de 20 A 24 Años" ///
						6 "de 25 A 29 Años" ///
						7 "de 30 A 34 Años" ///
						8 "de 35 A 39 Años" ///
						9 "de 40 A 44 Años" ///
						10 "de 45 A 49 Años" ///
						11 "de 50 A 54 Años" ///
						12 "de 55 A 59 Años" ///
						13 "de 60 A 64 Años" ///
						14 "de 65 A 69 Años" ///
						15 "de 70 A 74 Años" ///
						16 "de 75 A 79 Años" ///
						17 "de 80+"
	la val edad_grupo_ci edad_grupo_ci

	*************
	*relacion_ci*
	*************
	gen byte relacion_ci = .
	replace relacion_ci = 1 if c1_rel_head==1
	replace relacion_ci = 2 if c1_rel_head==2
	replace relacion_ci = 3 if c1_rel_head==3|c1_rel_head==4
	replace relacion_ci = 4 if c1_rel_head>=5 & c1_rel_head<=11
	replace relacion_ci = 5 if c1_rel_head==12 |c1_rel_head==13 |c1_rel_head==15
	replace relacion_ci = 6 if c1_rel_head==14

	**********
	*civil_ci*
	**********
	gen	byte civil_ci=.
	replace civil_ci=1 if c4_marital_status==1
	replace civil_ci=2 if c4_marital_status==2
	replace civil_ci=3 if c4_marital_status==4|c4_marital_status==5
	replace civil_ci=4 if c4_marital_status==3

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
	
	*********
	*indi_ci*
	*********	
	gen byte ind_ci = .
	
	**************
	*noafroind_ci*
	**************
	gen byte noafroind_ci = .
	
	************
	*afroind_ci*
	************
	gen byte afroind_ci= .

	*********
	*afro_ch*
	*********
	gen byte afro_ch = .

	********
	*ind_ch*
	********
	gen byte ind_ch = .

	**************
	*noafroind_ch*
	**************
	gen byte noafroind_ch = .
	
	************
	*afroind_ch*
	************
    gen byte afroind_ch  = .
	
	********
	*dis_ci*
	********
	gen byte dis_ci= . 
	replace dis_ci=1 if inlist(p12_1_see,2,3,4)
	replace dis_ci=1 if inlist(p12_2_hear,2,3,4)
	replace dis_ci=1 if inlist(p12_3_walk,2,3,4)
	replace dis_ci=1 if inlist(p12_4_remember,2,3,4)
	replace dis_ci=1 if inlist(p12_5_selfcare,2,3,4)
	replace dis_ci=1 if inlist(p12_6_speak,2,3,4)
	replace dis_ci=0 if (p12_1_see==1 & p12_2_hear==1 & p12_3_walk==1 & p12_4_remember==1 & p12_5_selfcare==1 & p12_6_speak==1)
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	replace disWG_ci=1 if inlist(p12_1_see,3,4)
	replace disWG_ci=1 if inlist(p12_2_hear,3,4) 
	replace disWG_ci=1 if inlist(p12_3_walk,3,4) 
	replace disWG_ci=1 if inlist(p12_4_remember,3,4) 
	replace disWG_ci=1 if inlist(p12_5_selfcare,3,4) 
	replace disWG_ci=1 if inlist(p12_6_speak,3,4) 
	replace disWG_ci=0 if inlist(p12_1_see,1,2) & inlist(p12_2_hear,1,2) & inlist(p12_3_walk,1,2) & inlist(p12_4_remember,1,2) & inlist(p12_5_selfcare,1,2) & inlist(p12_6_speak,1,2)
	
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
	replace migrante_ci=1 if p2_wher_brn==2
	replace migrante_ci=. if p2_wher_brn==.
	 	
	****************
    *migantiguo5_ci*
    ****************
	gen byte migrantiguo5_ci=0
	replace migrantiguo5_ci=1 if p6_yr_last_cmtobah<=2018  & migrante_ci ==1 
	replace migrantiguo5_ci=. if migrante_ci!=1
	
	***********
	*miglac_ci*
	***********
	gen byte miglac_ci=.
	* not recommended to create variable
	*replace miglac_ci=1 if inlist(p3_isl_cntry, 328,332,388) & migrante_ci ==1
	*replace miglac_ci=. if migrante_ci!=1

***********************************
*** 5. Educación (13 variables) ***
***********************************
*fre p15_attend_school p15a_grade_year p15b_grade_comple p16_high_educ
*p15_attend_school Is PERSON attending school or any educational institution now
*p15a_grade_year -- What grade/year is PERSON in now?
*p15b_grade_comple -- What GRADE of school or YEAR of college/university has PERSON COMPLETED?
*p16_high_educ -- What is the HIGHEST qualification that PERSON has obtained up to the present tim

	*********
	*aedu_ci*
	*********
	gen byte aedu_ci=.
	replace aedu_ci=0 if inlist(p15b_grade_comple,1,2)
	replace aedu_ci=1 if p15b_grade_comple==3
	replace aedu_ci=2 if p15b_grade_comple==4
	replace aedu_ci=3 if p15b_grade_comple==5
	replace aedu_ci=4 if p15b_grade_comple==6
	replace aedu_ci=5 if p15b_grade_comple==7
	replace aedu_ci=6 if p15b_grade_comple==8
	replace aedu_ci=7 if p15b_grade_comple==9
	replace aedu_ci=8 if p15b_grade_comple==10
	replace aedu_ci=9 if p15b_grade_comple==11
	replace aedu_ci=10 if p15b_grade_comple==12
	replace aedu_ci=11 if p15b_grade_comple==13
	replace aedu_ci=12 if p15b_grade_comple==14
	replace aedu_ci=13 if p15b_grade_comple==15
	replace aedu_ci=14 if p15b_grade_comple==16 |p15b_grade_comple==17
	replace aedu_ci=15 if p15b_grade_comple==18
	replace aedu_ci=16 if p15b_grade_comple==19
	replace aedu_ci=17 if p15b_grade_comple==20
	replace aedu_ci=18 if p15b_grade_comple==21
	*** aedu_ci=13 ==13+, aedu_ci==14 includes Post Secondary/Technical/Vocational (Non-Tertiary) and aedu_ci=18 is Year 5+ of university ***
	
	**********
	*eduno_ci*
	**********
	gen byte eduno_ci=(aedu_ci==0) 
	replace eduno_ci=. if aedu_ci==. 

	**********
	*edupi_ci*
	**********
	gen byte edupi_ci=(aedu_ci>=1 & aedu_ci<=5) 
	replace edupi_ci=. if aedu_ci==. 

	**********
	*edupc_ci*
	**********
	gen byte edupc_ci=(aedu_ci>=6)
	replace edupc_ci=. if aedu_ci==. 

	**********
	*edusi_ci*
	**********
	gen byte edusi_ci=(aedu_ci>=7 & aedu_ci<=11) 
	replace edusi_ci=. if aedu_ci==. 

	**********
	*edusc_ci*
	**********
	gen byte edusc_ci=(p15b_grade_comple>=12) 
	replace edusc_ci=. if aedu_ci==. 

	***********
	*edus1i_ci*
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<10)
	replace edus1i_ci=. if aedu_ci==. 

	***********
	*edus1c_ci*
	***********
	gen byte edus1c_ci=(aedu_ci>=11)
	replace edus1c_ci=. if aedu_ci==. 

	***********
	*edus2i_ci*
	***********
	gen byte edus2i_ci=(aedu_ci>10 & aedu_ci<12)
	replace edus2i_ci=. if aedu_ci==. 

	***********
	*edus2c_ci*
	***********
	gen byte edus2c_ci=(aedu_ci>=12 & p16_high_educ>2)
	replace edus2c_ci=. if aedu_ci==. 

	***********
	*edupre_ci*
	***********
	gen byte edupre_ci= (p15b_grade_comple==2)
	replace edupre_ci=. if aedu_ci==.
	
	***********
	*asiste_ci*
	***********
	gen byte asiste_ci=1 if p15_attend_school>=1 & p15_attend_school<=9
	replace asiste_ci=0 if inlist(p15_attend_school,10, 11)

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
	replace condocup_ci=1 if edad_grupo_ci>=4 & p18_work_lastweek>=1 & p18_work_lastweek<=6 //ocupados aunque es 14 o mas
	replace condocup_ci=2 if  edad_grupo_ci>=4 & !inlist(p18_work_lastweek, 1,2,3,4,5,6) & p19_nonwork_descr==5	//ocupados aunque es 14 o mas	//desocupados	
	replace condocup_ci=3 if edad_grupo_ci>=4 & !inlist(p18_work_lastweek, 1,2,3,4,5,6) & inlist(p19_nonwork_descr, 1,2,3,4,9) //inactivos
	replace condocup_ci=4 if edad_grupo_ci<4 //no responde por ser menor de edad

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
    *******************
	gen byte rama_ci = . 
    replace rama_ci = 1 if ind_section==1 & emp_ci==1
    replace rama_ci = 2 if ind_section==2 & emp_ci==1
    replace rama_ci = 3 if ind_section==3 & emp_ci==1
    replace rama_ci = 4 if ind_section==4 |ind_section==5 & emp_ci==1   
    replace rama_ci = 5 if ind_section==6 & emp_ci==1 
    replace rama_ci = 6 if ind_section==7 & emp_ci==1   
    replace rama_ci = 7 if ind_section==9 & emp_ci==1  
    replace rama_ci = 8 if ind_section==8 | ind_section==10 &emp_ci==1   
    replace rama_ci = 9 if ind_section==11 & emp_ci==1
    replace rama_ci = 10 if ind_section==15 & emp_ci==1
    replace rama_ci = 11 if ind_section==12 |ind_section==14 & emp_ci==1
    replace rama_ci = 12 if ind_section==16 & emp_ci==1
    replace rama_ci = 13 if ind_section==17 & emp_ci==1
    replace rama_ci = 14 if ind_section==13 |ind_section==18 | ind_section==19 | ind_section==21 & emp_ci==1
    replace rama_ci = 15 if ind_section==20 & emp_ci==1

	**************
    *categopri_ci*
    **************
	gen byte categopri_ci=.
	replace categopri_ci=1 if emp_ci==1 & p22_3_inc_ownbusine==1 & p22_1_income_empjob!=1 & p22_2_inco_othejob!=1 & occ_major_group==1
	replace categopri_ci=2 if emp_ci==1 & p22_3_inc_ownbusine==1 & p22_1_income_empjob!=1 & p22_2_inco_othejob!=1 & occ_major_group!=1
	replace categopri_ci=3 if emp_ci==1 & p22_3_inc_ownbusine!=1 & p22_1_income_empjob==1 & p22_2_inco_othejob==1 
	replace categopri_ci=4 if emp_ci==1 & p22_3_inc_ownbusine!=1 & p22_1_income_empjob!=1 & p22_2_inco_othejob!=1
	replace categopri_ci=0 if emp_ci==1 & categopri_ci!=1 & categopri_ci!=2 & categopri_ci!=3 & categopri_ci!=4
/*En el caso de la definición de categopri_ci nos parece que es correcta dadas las variables disponibles, solo nos preocupa la condición "&" entre p22_1_income_empjob y p22_2_inco_othejob, si la segunda variable implica otro trabajo secundario, solo estaríamos capturando aquellos que tienen un primer trabajo en p22_1_income_empjob y un segundo trabajo en p22_2_inco_othejob, tal vez sería mejor usar la condición or "|" por si el individuo tiene uno o el otro trabajo (al menos uno), pero dependerá de la naturaleza de la encuesta que ustedes la conocen mejor.*/
 
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
	replace luz_ch=1 if h11_mansrcelec==1|h11_mansrcelec==3
	replace luz_ch=0 if h11_mansrcelec==2 |h11_mansrcelec==4

	*********
	*piso_ch*
	*********
	gen byte piso_ch=.

	**********
	*pared_ch*
	**********
	gen byte pared_ch=.

	**********
	*techo_ch*
	**********  
	gen byte techo_ch=.
	replace techo_ch=0 if h2_roomat==9
	replace techo_ch=1 if h2_roomat==4
	replace techo_ch=2 if inlist(h2_roomat, 1,2,3)

	**********
	*resid_ch*
	**********
	gen byte resid_ch=.

	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=h5_bdrms
	replace dorm_ch=. if dorm_ch==99
	*7 is 7+
	
	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=h4_numrooms
	replace cuartos_ch=. if cuartos_ch==99
	*8 is 8+
	
	***********
	*cocina_ch*
	***********
	gen byte cocina_ch = .
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch=.
	
	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=.
	replace refrig_ch=1 if h13_applanc__6==1
	replace refrig_ch=0 if h13_applanc__6==0
	
	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	* This question relates to number of vehicles not of cars replace auto_ch=1 if h14_num_veh_hh>=1 & h14_num_veh_hh<=4
	* replace auto_ch=0 if h14_num_veh_hh==5

	**********
	*compu_ch*
	**********
	gen byte compu_ch=h13_applanc__10

	*************
	*internet_ch*
	************* 
	gen byte internet_ch=.
	replace internet_ch=1 if p13_intrnt_acs==1 & p14_wher_last_acc_int==1
	replace internet_ch=0 if p13_intrnt_acs!=1 | p14_wher_last_acc_int!=1

	********
	*cel_ch*
	********
	gen byte cel_ch=.
	
	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch=.

	
***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	************
	*aguaentubada_ch*
	************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch=1 if h7_mansrcwtrsup<=3 
	replace aguaentubada_ch=0 if h7_mansrcwtrsup==4

	************
	*aguared_ch*
	************
	gen byte aguared_ch=.

	************
	*aguafuente_ch*
	************
	gen byte aguafuente_ch=.
	replace aguafuente_ch=1 if inlist(1,h6_watrsupl__3,h6_watrsupl__4)
	replace aguafuente_ch=2 if inlist(1,h6_watrsupl__1,h6_watrsupl__2,h6_watrsupl__5)
	replace aguafuente_ch=3 if h6_watrsupl__8==1 
	*replace aguafuente_ch=4 if ==
	replace aguafuente_ch=5 if h6_watrsupl__7==1
	*replace aguafuente_ch=6 if ==
	*replace aguafuente_ch=7 if ==
	*replace aguafuente_ch=8 if ==
	*replace aguafuente_ch=9 if 
	replace aguafuente_ch=10 if h6_watrsupl__9 ==1 |h6_watrsupl__6==1

	************
	*aguadist_ch*
	************
	gen byte aguadist_ch=0

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
	gen byte bano_ch=. 
	replace bano_ch=0 if h8_typtoil ==5
	replace bano_ch=1 if h8_typtoil ==1
	replace bano_ch=2 if h8_typtoil ==2
	*replace bano_ch=3 if 
	replace bano_ch=4 if h8_typtoil ==3
	replace bano_ch=5 if h8_typtoil ==4

	*********
	*banoex_ch*
	*********
	gen byte banoex_ch=.
	replace banoex_ch=0 if h9_toilshrd==2
	replace banoex_ch=1 if h9_toilshrd==1

	*********
	*sinbano_ch*
	*********
	gen byte sinbano_ch=.
	replace sinbano_ch=0 if h8_typtoil <=4
	replace sinbano_ch=3 if h8_typtoil ==5

	*****************
	*conbano_ch*
	*****************
	gen byte conbano_ch=0
	replace conbano_ch=0 if h8_typtoil ==5
	replace conbano_ch=1 if h8_typtoil <=4

	***********************
	*banoalcantarillado_ch*
	***********************
	gen byte banoalcantarillado_ch=0  
	replace banoalcantarillado_ch=1 if inlist(h7_mansrcwtrsup, 1, 2, 3) & h8_typtoil <= 2

	*********
	*des1_ch*
	*********
	gen byte des1_ch=.


*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	 
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte BHS_m_pared_ch= .

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte BHS_m_piso_ch= .
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte BHS_m_techo_ch= h2_roomat
	label var BHS_m_techo_ch  "Material del techo según el censo del país - variable original"
	label def BHS_m_techo_ch  1 "Sheet/Tile Metal (Zinc, Aluminum, Galvanize)" 2 "Shingle (Asphalt)" 3 "Shingle (Wood)" 4 "Other" 5 "Not stated"  //categorías originales del país
	label val BHS_m_techo_ch BHS_m_techo_ch 
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long BHS_ingreso_ci = p22_total_income
	label var BHS_ingreso_ci  "Ingreso total según el censo del país - variable original"
	label def BHS_ingreso_ci  1 "0 - 5000 " 2 "5001 - 10000" 3 "10001 - 15000" 4 "15001 - 20000" 5 "20001 - 40000" 6"40001 - 60000" 7"60001 - 80000" 8"80001 - 100000" 9"100001 or more" 10"Not stated" //categorías originales del país
	label val BHS_ingreso_ci BHS_ingreso_ci 
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long BHS_ingresolab_ci = p22_1a_income_mainjob	
	label var BHS_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"
	label def BHS_ingresolab_ci  1 "0 - 5000 " 2 "5001 - 10000" 3 "10001 - 15000" 4 "15001 - 20000" 5 "20001 - 40000" 6"40001 - 60000" 7"60001 - 80000" 8"80001 - 100000" 9"100001 or more" 10"Not stated" //categorías originales del país
	label val BHS_ingresolab_ci BHS_ingresolab_ci 
	
	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte BHS_dis_ci = .
	

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

keep  $lista_variables edad_grupo_ci

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
********************************************************************************
