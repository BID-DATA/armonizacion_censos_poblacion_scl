* (Versión Stata 12)
clear
set more off
*________________________________________________________________________________________________________________*

 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: ${censusFolder}
 * Se tiene acceso al servidor únicamente al interior del BID.
 *________________________________________________________________________________________________________________*
 
*Population and Housing Censuses/Harmonized Censuses - IPUMS


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Colombia
Año: 2018
Autores: Juan Perdomo
Última versión: Septiembre, 2022

							SCL/MIG - IADB
****************************************************************************/

local PAIS COL
local ANO "2018"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
*include "../Base/base.do"
global ruta ="${censusFolder}"

global ruta_raw = "${censusFolder_raw}"

local log_file ="$ruta\\clean\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID.log"
local base_in = "$censusFolder_raw/COL/Censo Colombia 2018 completo.dta"
local base_out ="$ruta\\clean\\`PAIS'\\`PAIS'_`ANO'_censusBID.dta"

capture log close
*log using "`log_file'", replace

use "`base_in'", clear

***************
***region_c ***
***************
destring u_dpto, replace
gen region_c=u_dpto
label define region_c       /// 
	5  "Antioquia"	        ///
	8  "Atlantico"	        ///
	11 "Bogota, D.C"	    ///
	13 "Bolivar" 	        ///
	15 "Boyace"	            ///
	17 "Caldas"	            ///
	18 "Caqueta"	        ///
	19 "Cauca"	            ///
	20 "Cesar"	            ///
	23 "Cordoba"	        ///
	25 "Cundinamarca"       ///
	27 "Choco"	            ///
	41 "Huila"	            ///
	44 "La Guajira"	        ///
	47 "Magdalena"	        ///
	50 "Meta"	            ///
	52 "Narino"	            ///
	54 "Norte de Santander"	///
	63 "Quindio"	        ///
	66 "Risaralda"	        ///
	68 "Santander"	        ///
	70 "Sucre"	            ///
	73 "Tolima"	            ///
	76 "Valle del Cauca"	///
	81 "Arauca"	            ///
	85 "Casanare"	        ///
	88 "Archipiélago De San Andrés Y Providencia"	        ///
	86 "Putumayo"	        ///
	91 "Amazonas"	        ///
	94 "Guainía"	        ///
	95 "Guaviare"	        ///
	97 "Vaupés" 	        ///
	99 "Vichada"*
label value region_c region_c

************
* Region_BID *
************
gen region_BID_c=.
replace region_BID_c=3 
label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c

***************
**** ine01 ****
***************
gen ine01=.
replace ine01 = 170005 if u_dpto==5
replace ine01 = 170008 if u_dpto==8
replace ine01 = 170011 if inlist(u_dpto,11,25)
replace ine01 = 170013 if inlist(u_dpto,13,70)
replace ine01 = 170015 if inlist(u_dpto,15,85)
replace ine01 = 170018 if u_dpto==18
replace ine01 = 170019 if u_dpto==19
replace ine01 = 170023 if u_dpto==23
replace ine01 = 170027 if u_dpto==27
replace ine01 = 170041 if u_dpto==41
replace ine01 = 170044 if u_dpto==44
replace ine01 = 170050 if u_dpto==50
replace ine01 = 170052 if u_dpto==52
replace ine01 = 170054 if inlist(u_dpto,20,47)
replace ine01 = 170066 if inlist(u_dpto,17,63,66)
replace ine01 = 170068 if inlist(u_dpto,68,54)
replace ine01 = 170073 if u_dpto==73
replace ine01 = 170076 if u_dpto==76
replace ine01 = 170081 if u_dpto==81
replace ine01 = 170086 if u_dpto==86
replace ine01 = 170088 if u_dpto==88
replace ine01 = 170095 if inlist(u_dpto,91,95,97,99,94)
label define ine01 170005 "Antioquia" 170008 "Atlántico" 170011 "Bogotá D.C., Cundinamarca" 170013 "Bolívar, Sucre" 170015 "Boyacá, Casanare" 170018 "Caquetá" 170019 "Cauca" 170023 "Córdoba" 170027 "Chocó" 170041 "Huila" 170044 "La Guajira" 170050 "Meta" 170052 "Nariño" 170054 "Cesar, Norte De Santander, Magdalena" 170066 "Caldas, Quindío, Risaralda" 170068 "Santander" 170073 "Tolima" 170076 "Valle Del Cauca" 170081 "Arauca" 170086 "Putumayo" 170088 "Archipiélago De San Andrés Y Providencia" 170095 "Amazonas, Guaviare, Vaupés, Vichada, Guainía"
label value ine01 ine01

************
****pais****
************
g str3 pais_c = "COL"

**********
***anio***
**********
g anio_c = 2018

***************
****idh_ch*****
***************
sort u_dpto u_mpio ua_clase cod_encuestas u_vivienda p_nrohog
egen idh_ch = group(u_dpto u_mpio ua_clase cod_encuestas u_vivienda p_nrohog)

**************
****idp_ci****
**************
gen idp_ci = p_nro_per

**********
***zona***
**********
destring ua_clase, replace
g zona_c = (ua_clase == 1)
replace zona_c = . if ua_clase == .
la de zona_c 1 "Urbana" 0 "Rural"
la val zona_c zona_c

****************************************
*factor expansión individio (factor_ci)*
****************************************
gen factor_ci=.
	
*******************************************
*Factor de expansion del hogar (factor_ch)*
*******************************************
gen factor_ch=.

*******************************************
*Estrato(estrato_ci)*
*******************************************
gen estrato_ci=.

		****************************
		***VARIABLES DEMOGRAFICAS***
		****************************

*****************
***relacion_ci***
*****************
	g 		relacion_ci = 1 if p_parentescor == 1
	replace relacion_ci = 2 if p_parentescor == 2
	replace relacion_ci = 3 if p_parentescor == 3
	replace relacion_ci = 4 if p_parentescor == 4
	replace relacion_ci = 5 if p_parentescor == 5
	replace relacion_ci = . if p_parentescor == .
	la de relacion_ci 	1 "Jefe/a" 				///
						2 "Esposo/a" 			///
						3 "Hijo/a" 				///
						4 "Otros parientes" 	///
						5 "Otros no parientes"
	la val relacion_ci relacion_ci

**********
***sexo***
**********
	g sexo_ci = p_sexo
	replace sexo_ci = . if p_sexo == .
	la define sexo_ci 1 "Hombre" 2 "Mujer"
	la val sexo_ci sexo_ci

**********
***edad***
**********
	g edad_ci = .
	g edad_grupo_ci = p_edadr
	la var edad_grupo_ci "Edad del individuo (años)"
	la de edad_grupo_ci	1 "de 00 A 04 Años" 	///
						2 "de 05 A 09 Años" 	///
						3 "de 10 A 14 Años"	    ///
						4 "de 20 A 24 Años" 	///
						5 "de 20 A 24 Años"		///
						6 "de 25 A 29 Años"		///
						7 "de 30 A 34 Años"		///
						8 "de 35 A 39 Años"		///
						9 "de 40 A 44 Años"		///
						10 "de 45 A 49 Años"	///
						11 "de 50 A 54 Años"	///
						12 "de 55 A 59 Años"	///
						13 "de 60 A 64 Años"	///
						14 "de 65 A 69 Años"	///
						15 "de 70 A 74 Años"	///
						16 "de 75 A 79 Años"	///
						17 "de 80 A 84 Años"	///
						18 "de 85 A 89 Años"	///
						19 "de 90 A 94 Años"	///
						20 "de 95 A 99 Años"	///
						21 "de 100 y más Años"
	la val relacion_ci relacion_ci

*****************
****civil_ci*****
*****************
	g 		civil_ci = .
	replace civil_ci = 1 if p_est_civil == 7
	replace civil_ci = 2 if p_est_civil == 1 | p_est_civil == 2
	replace civil_ci = 3 if p_est_civil == 3 | p_est_civil == 4 | p_est_civil == 5 
	replace civil_ci = 4 if p_est_civil==6
	replace civil_ci = . if p_est_civil==9 | p_est_civil==.
	la var civil_ci "Estado civil"
	la de civil_ci 	1 "Soltero" 				///
					2 "Unión formal o informal" ///
					3 "Divorciado o separado" 	///
					4 "Viudo"
	la val civil_ci civil_ci

**************
***jefe_ci***
*************
	g jefe_ci = relacion_ci == 1

******************
***nconyuges_ch***
******************
	bys idh_ch: egen nconyuges_ch = sum(relacion_ci == 2)

***************
***nhijos_ch***
***************
	bys idh_ch: egen nhijos_ch = sum(relacion_ci == 3)

******************
***notropari_ch***
******************
	bys idh_ch: egen notropari_ch = sum(relacion_ci == 4)

********************
***notronopari_ch***
********************
	bys idh_ch: egen notronopari_ch = sum(relacion_ci == 5)

****************
***nempdom_ch***
****************
	bys idh_ch: egen nempdom_ch = sum(relacion_ci == 6)

*****************
***clasehog_ch***
*****************
	g byte clasehog_ch = 0
**** unipersonal
	replace clasehog_ch = 1 if nhijos_ch == 0 & nconyuges_ch == 0 & notropari_ch == 0 & notronopari_ch == 0
**** nuclear (child with or without spouse but without other relatives)
	replace clasehog_ch = 2 if (nhijos_ch > 0 | nconyuges_ch > 0) & (notropari_ch == 0 & notronopari_ch == 0)
**** ampliado
	replace clasehog_ch = 3 if notropari_ch > 0 & notronopari_ch == 0
**** compuesto (some relatives plus non relative)
	replace clasehog_ch = 4 if ((nconyuges_ch > 0 | nhijos_ch > 0 | notropari_ch > 0) & (notronopari_ch > 0))
**** corresidente
	replace clasehog_ch = 5 if nhijos_ch == 0 & nconyuges_ch == 0 & notropari_ch == 0 & notronopari_ch > 0
	
	la variable clasehog_ch "Tipo de hogar"
	la de clasehog_ch 	1 "Unipersonal" 	///
						2 "Nuclear" 		///
						3 "Ampliado" 		///
						4 "Compuesto" 		///
						5 "Corresidente"
	la val clasehog_ch clasehog_ch

******************
***nmiembros_ch***
******************
	bys idh_ch: egen nmiembros_ch = sum(relacion_ci >= 1 & relacion_ci <= 4)

*****************
***nmayor21_ch***
*****************
	gen nmayor21_ch= .

*****************
***nmenor21_ch***
*****************
	gen nmenor21_ch= .

*****************
***nmayor65_ch***
*****************
	gen nmayor65_ch= .

****************
***nmenor6_ch***
****************
	gen nmenor6_ch= .

****************
***nmenor1_ch***
****************
	gen nmenor1_ch= .

****************
***miembros_ci***
****************
	gen miembros_ci = (relacion_ci <= 4)

	
**********************************
**** VARIABLES DE LA VIVIENDA ****
**********************************
		
	************
	*aguared_ch*
	************
	gen aguared_ch=1 if vb_acu==1
	replace aguared_ch=0 if vb_acu==2
	replace aguared_ch=. if vb_acu==.
	
	********
	*luz_ch*
	********
	gen luz_ch= 1 if va_ee==1
	replace luz_ch= 0 if va_ee==2
	replace luz_ch=. if va_ee==.
	
	*********
	*bano_ch*
	*********
	gen bano_ch=(inrange(v_tipo_sersa,1,5))
	replace bano_ch=. if v_tipo_sersa==9 | v_tipo_sersa==.
	
	*********
	*des1_ch*
	*********
	gen des1_ch= 1 if inrange(v_tipo_sersa,1,2)
	replace des1_ch=0 if inrange(v_tipo_sersa,3,6)
	replace des1_ch=. if v_tipo_sersa==9 | v_tipo_sersa==.
	
	*********
	*piso_ch*
	*********
	gen piso_ch=.
	replace piso_ch = 0 if v_mat_piso == 6
	replace piso_ch = 1 if v_mat_piso == 1 | v_mat_piso == 2 | v_mat_piso == 3 | v_mat_piso == 4
	replace piso_ch = 2 if v_mat_piso == 5
	replace piso_ch = . if v_mat_piso==9 | v_mat_piso==.
	
	*****************
	*banomejorado_ch*
	*****************
	gen banomejorado_ch=.
	
	**********
	*pared_ch*
	**********
	gen pared_ch=.
	replace pared_ch=0 if v_mat_pared ==8
	replace pared_ch=1 if v_mat_pared == 1 | v_mat_pared==2 | v_mat_pared ==3 | v_mat_pared ==6
	replace pared_ch=2 if v_mat_pared == 4 | v_mat_pared==5 | v_mat_pared ==7
	replace pared_ch=. if v_mat_piso==9 | v_mat_piso==.

	**********
	*techo_ch*
	**********
	gen techo_ch=.
	
	**********
	*resid_ch*
	**********
	gen resid_ch=. 
	
	*********
	*dorm_ch*
	*********
	gen dorm_ch=h_nro_dormit
	
	************
	*cuartos_ch*
	************
	gen cuartos_ch=h_nro_cuartos
	
	***********
	*cocina_ch*
	***********
	gen cocina_ch=.
	replace cocina_ch=1 if h_donde_prepalim ==1 
	replace cocina_ch=0 if h_donde_prepalim==2 | h_donde_prepalim==3 | h_donde_prepalim==4  | h_donde_prepalim==5 | h_donde_prepalim==6
	
	***********
	*telef_ch*
	***********
	*sin dato
	gen telef_ch=.
	
	***********
	*refrig_ch*
	***********
	gen refrig_ch=.
	
	*********
	*auto_ch*
	*********
	gen auto_ch=.
	
	********
	*compu_ch*
	********
	gen compu_ch=.
	
	*************
	*internet_ch*
	************* 
	gen internet_ch=vf_internet
	replace internet_ch=0 if vf_internet==2
	
	********
	*cel_ch*
	********
	*sin dato
	gen cel_ch=.
	
	*************
	*viviprop_ch*
	*************
	gen viviprop_ch1=.
	

**********************************************
***      VARIABLES DEL MERCADO LABORAL     ***
**********************************************	

    *******************
    ****condocup_ci****
    *******************
    gen condocup_ci=.
	
	************
     ***emp_ci***
     ************
    gen emp_ci=(inrange(p_trabajo,1,3))
	
	****************
     ***desemp_ci***
     ****************	
	gen desemp_ci=(p_trabajo==4)
	
	*************
    ***pea_ci***
    *************
    gen pea_ci=(inrange(p_trabajo,1,4))
	
	*************************
    ****rama de actividad****
    *************************
	 
	*************
	**rama_ci****
	*************
	gen rama_ci=.
	
	*********************
    ****categopri_ci****
    *********************
	 gen categopri_ci=.
	 
	 
	*****************
    ***spublico_ci***
    *****************
    gen spublico_ci=.
	

**********************************
**** VARIABLES DE INGRESO ****
***********************************
*Colombia 2018 no tiene variables de ingreso

   gen ylm_ci=.
 
   gen ynlm_ci=.
   
   gen ylm_ch =.
   
   gen ynlm_ch=.
   
   
*******************************************************
***           VARIABLES DE MIGRACIÓN              ***
*******************************************************

    *******************
    ****migrante_ci****
    *******************
	gen migrante_ci = 0
	replace migrante_ci=1 if pa_lug_nac==3
	replace migrante_ci=. if pa_lug_nac==. | pa_lug_nac==9
	
	*******************
    **migantiguo5_ci***
    *******************
	gen migantiguo5_ci =0
	replace migantiguo5_ci=1 if pa_lug_nac==3 | pa_vivia_5anos==4
	
	
	**********************
	*** migrantelac_ci ***
	**********************
	gen migrantelac_ci = .
	
	*******************
    **migrantiguo5_ci**
    *******************
	gen migrantiguo5_ci =0 
	replace migrantiguo5_ci=1 if pa_lug_nac==3 & pa_vivia_5anos==4
	replace migrantiguo5_ci=. if pa_lug_nac!=3 | pa_vivia_5anos==.
	
	**********************
	****** miglac_ci *****
	**********************
	gen miglac_ci = .
	
***************************************
************** Education **************
***************************************

*************
***aedu_ci***
*************
gen aedu_ci =.

**************
***eduno_ci***
**************
gen eduno_ci=(p_nivel_anosr==10|p_nivel_anosr==1) // never attended or pre-school
replace eduno_ci=. if p_nivel_anosr==. // NIU & missing

**************
***edupi_ci***
**************
gen edupi_ci=.
replace edupi_ci=. if p_nivel_anosr==. // NIU & missing


**************
***edupc_ci***
**************
gen edupc_ci=(p_nivel_anosr==2)
replace edupc_ci=. if p_nivel_anosr==. // NIU & missing

**************
***edusi_ci***
**************
gen edusi_ci=.

**************
***edusc_ci***
**************
gen edusc_ci=(p_nivel_anosr==4 |p_nivel_anosr==3 |p_nivel_anosr==3 |p_nivel_anosr==6) 
replace edusc_ci=. if p_nivel_anosr==. // NIU & missing

***************
***edus1i_ci***
***************
gen byte edus1i_ci=.
replace edus1i_ci=. if p_nivel_anosr==. // missing a los NIU & missing

***************
***edus1c_ci***
***************
gen byte edus1c_ci=.
replace edus1c_ci=. if aedu_ci==. // missing a los NIU & missing

***************
***edus2i_ci***
***************
gen byte edus2i_ci=.
replace edus2i_ci=. if p_nivel_anosr==. // missing a los NIU & missing

***************
***edus2c_ci***
***************
gen byte edus2c_ci=(p_nivel_anosr==4 |p_nivel_anosr==3 |p_nivel_anosr==5 |p_nivel_anosr==6)
replace edus2c_ci=. if p_nivel_anosr==. // missing a los NIU & missing

***************
***edupre_ci***
***************
gen byte edupre_ci=(p_nivel_anosr==1)
replace edupre_ci=. if p_nivel_anosr==.
*label variable edupre_ci "Educacion preescolar"

**************
***eduuc_ci***
**************
gen eduuc_ci=(p_nivel_anosr==7|p_nivel_anosr==8|p_nivel_anosr==9) 
replace eduuc_ci=. if p_nivel_anosr==. // NIU & missing

***************
***asiste_ci***
***************
gen asiste_ci=.
replace asiste_ci=1 if pa_asistencia==1
replace asiste_ci=0 if pa_asistencia==2
replace asiste_ci=. if pa_asistencia==.|pa_asistencia==9
*label variable asiste_ci "Asiste actualmente a la escuela"

**************
***literacy***
**************
gen literacy=(p_alfabeta==1)
replace literacy=. if p_alfabeta==.|p_alfabeta==9


*******************************
*** VARIABLES DE DIVERSIDAD ***
*******************************

	***afroind_ci***
	***************
**Pregunta: De acuerdo con su cultura, pueblo o rasgos físicos, … es o se reconoce como:(P6080) (1- Indigena 2- Gitano - Rom 3- Raizal del archipiélago de San Andrés y providencia 4- Palenquero de San basilio o descendiente 5- Negro(a), mulato(a), Afrocolombiano(a) o Afrodescendiente 6- Ninguno de los anteriores (mestizo, blanco, etc)) 
gen afroind_ci=. 
replace afroind_ci=1 if pa1_grp_etnic == 1 
replace afroind_ci=2 if pa1_grp_etnic == 3 | pa1_grp_etnic == 4 | pa1_grp_etnic == 5
replace afroind_ci=3 if pa1_grp_etnic == 2 | pa1_grp_etnic == 6
replace afroind_ci=. if pa1_grp_etnic ==.
label var afroind_ci "Raza o etnia del individuo"

	***************
	***afroind_ch***
	***************
gen afroind_jefe= afroind_ci if relacion_ci==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 
label var afroind_ch "Raza/etnia del hogar en base a raza/etnia del jefe de hogar"
drop afroind_jefe

	*******************
	***afroind_ano_c***
	*******************
* por ahora se pone 2018 porque antes no se había considerado, pero desde 2005 se podría hacer	
gen afroind_ano_c=2018
label var afroind_ano_c "Año Cambio de Metodología Medición Raza/Etnicidad"

	*******************
	***dis_ci***
	*******************
gen dis_ci=. 
label var dis_ci "Personas con discapacidad"

	*******************
	***dis_ch***
	*******************
gen dis_ch=. 
lab var dis_ch "Hogares con miembros con discapacidad"


*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"


compress

save "`base_out'", replace 
log close


