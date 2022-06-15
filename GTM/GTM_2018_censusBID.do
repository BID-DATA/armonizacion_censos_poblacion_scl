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
País: Guatemala
Año: 2018
Autores: Eric Torres
Última versión: Junio, 2022

							SCL/LMK - IADB
****************************************************************************/

local PAIS GTM
local ANO "2018"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
*include "../Base/base.do"
global ruta ="${censusFolder}"

global ruta_raw = "${censusFolder_raw}"

local log_file ="$ruta\\clean\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID.log"
local base_in = "Z:\census\GTM\2018\raw\\`PAIS'_`ANO'_NOIPUMS.dta"
local base_out ="$ruta\\clean\\`PAIS'\\`PAIS'_`ANO'_censusBID.dta"

capture log close
log using "`log_file'", replace

use "`base_in'", clear

*****************************************************
******* Variables specific for this census **********
*****************************************************

****************
*** region_c ***
****************

   gen region_c=.   
	replace region_c=1 if departamento==320001 /*Guatemala*/
	replace region_c=2 if departamento==320002 /*El Progreso*/
	replace region_c=3 if departamento==320003 /*Sacatepéquez*/
	replace region_c=4 if departamento==320004 /*Chimaltenango*/
	replace region_c=5 if departamento==320005 /*Escuintla*/
	replace region_c=6 if departamento==320006 /*Santa Rosa*/
	replace region_c=7 if departamento==320007 /*Sololá*/
	replace region_c=8 if departamento==320008 /*Totonicapán*/
	replace region_c=9 if departamento==320009 /*Quetzaltenango*/
	replace region_c=10 if departamento==320010 /*Suchitepéquez*/
	replace region_c=11 if departamento==320011 /*Retalhuleu*/
	replace region_c=12 if departamento==320012 /*San Marcos*/
	replace region_c=13 if departamento==320013 /*Huehuetenango*/
	replace region_c=14 if departamento==320014 /*Quiché*/
	replace region_c=15 if departamento==320015 /*Baja Verapaz*/
	replace region_c=16 if departamento==320016 /*Alta Verapaz*/
	replace region_c=17 if departamento==320017 /*Petén*/
	replace region_c=18 if departamento==320018 /*Izabal*/
	replace region_c=19 if departamento==320019 /*Zacapa*/
	replace region_c=20 if departamento==320020 /*Chiquimula*/
	replace region_c=21 if departamento==320021 /*Jalapa*/
	replace region_c=22 if departamento==320022 /*Jutiapa*/

	
	label define region_c 1 "Guatemala" 2 "El Progreso" 3 "Sacatepéquez" 4 "Chimaltenango" 5 "Escuintla" 6 "Santa Rosa" 7 "Sololá" 8 "Totonicapán" 9 "Quetzaltenango" 10 "Suchitepéquez" 11 "Retalhuleu" 12 "San Marcos" 13 "Huehuetenango" 14 "Quiché" 15 "Baja Verapaz" 16 "Alta Verapaz" 17 "Petén" 18 "	Izabal" 19 "Zacapa" 20 "Chiquimula" 21 "Jalapa" 22 "Jutiapa"
	
	 label value region_c region_c

	 

gen region_BID_c = 1

    *********
	*pais_c*
	*********
gen pais_c = "GTM"

    *********
	*anio_c*
	*********
gen anio_c = 2018

    ******************
    *idh_ch (id hogar)*
    ******************
	
	gen str14 idh_ch = string(num_vivienda,"%02.0f") + string(num_hogar,"%02.0f") 


	******************
    *idp_ci (idpersonas)*
    ******************
rename pcp1 idp_ci 

    ***********
	* estrato *
	***********
gen estrato_ci=.

    ***************************
	* Zona urbana (1) o rural (0)
	***************************
gen zona_c=.
replace zona_c=1 if area==1
replace zona_c=0 if area==2
	
	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
gen factor_ci=.
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
gen factor_ch=.



*****************************************************
***             VARIABLES DEMOGRAFICAS            ***
*****************************************************
    *********
	*sexo_c*
	*********
rename pcp6 sexo_ci 

	*********
	*edad_c*=3
	*********
rename pcp7 edad_ci

	*************
	*relacion_ci*
	*************
*considero hijastro como hijo y no como otro pariente
gen relacion_ci=pcp5
replace relacion_ci=3 if pcp5==4
replace relacion_ci=4 if pcp5==5 | pcp5==6 | pcp5==7 | pcp5==8 | pcp5==9 | pcp5==10 | pcp5==11
replace relacion_ci=5 if pcp5==13 | pcp5==14 | pcp5==15
replace relacion_ci=6 if pcp5==12

	**************
	*Estado Civil*
	**************
gen	civil_ci=pcp34
replace civil_ci=2 if pcp34==3
replace civil_ci=3 if pcp34==4 | pcp34==5 | pcp34==6
replace civil_ci=4 if pcp34==7

	
    *********
	*jefe_ci*
	*********
	gen jefe_ci=(pcp5==1)
	
	**************
	*nconyuges_ch*
	**************
	by idh_ch, sort: egen nconyuges_ch=sum(relacion_ci==2)
	
	***********
	*nhijos_ch*
	***********
	by idh_ch, sort: egen nhijos_ch=sum(relacion_ci==3) 

	**************
	*notropari_ch*
	**************
	by idh_ch, sort: egen notropari_ch=sum(relacion_ci==4)
	
	****************
	*notronopari_ch*
	****************
	by idh_ch, sort: egen notronopari_ch=sum(relacion_ci==5)
	
	************
	*nempdom_ch*
	************
	by idh_ch, sort: egen nempdom_ch=sum(relacion_ci==6)
	
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
	by idh_ch, sort: egen byte nmiembros_ch=sum(relacion_ci>0 & relacion_ci<9)

	*************
	*nmayor21_ch*
	*************
	by idh_ch, sort: egen byte nmayor21_ch=sum((relacion_ci>0 & relacion_ci<9) & (edad_ci>=21 & edad_ci<=98))

	*************
	*nmenor21_ch*
	*************
	by idh_ch, sort: egen byte nmenor21_ch=sum((relacion_ci>0 & relacion_ci<9) & (edad_ci<21))

	*************
	*nmayor65_ch*
	*************
	by idh_ch, sort: egen byte nmayor65_ch=sum((relacion_ci>0 & relacion_ci<9) & (edad_ci>=65 & edad_ci!=.))

	************
	*nmenor6_ch*
	************
	by idh_ch, sort: egen byte nmenor6_ch=sum((relacion_ci>0 & relacion_ci<9) & (edad_ci<6))

	************
	*nmenor1_ch*
	************
	by idh_ch, sort: egen byte nmenor1_ch=sum((relacion_ci>0 & relacion_ci<9) & (edad_ci<1))

	************
	*miembros_ci
	************
	gen miembros_ci=(relacion_ci>=1 & relacion_ci<9) 
	tab miembros_ci	
	
	
	
**********************************
**** VARIABLES DE LA VIVIENDA ****
**********************************
		
	************
	*aguared_ch*
	************
	* se crea conforme las tablas de armonización IPUMS
	gen aguared_ch=.
	replace aguared_ch=1 if pch4 == 1 | pch4 == 2 | pch4 == 3
	replace aguared_ch=0 if pch4>=4 & pch4<=10
	
	********
	*luz_ch*
	********
	*En la nueva encuesta no se encontro si se pregunta por instalacion electrica
	gen luz_ch=pch8
	replace luz_ch=0 if pch8>=2 & pch8<=5
	
	*********
	*bano_ch*
	*********
	gen bano_ch=.
	replace bano_ch=1 if pch5>=1 & pch5<=4
	replace bano_ch=0 if pch5==5
	
	
	*********
	*des1_ch*
	*********
	gen des1_ch=.
	replace des1_ch=0 if bano_ch ==0
	replace des1_ch=1 if pch5 == 1 | pch5 == 2
	replace des1_ch=2 if pch5 == 3 | pch5 == 4
	
	
	*********
	*piso_ch*
	*********
	gen piso_ch=.
	replace piso_ch = 0 if pcv5 == 7
	replace piso_ch = 1 if pcv5 == 1 | pcv5 == 2 | pcv5 == 4 | pcv5 == 5 | pcv5 == 6
	replace piso_ch = 2 if pcv5 == 3 | pcv5 == 8
	
	*****************
	*banomejorado_ch*
	*****************
	gen banomejorado_ch=.
	replace banomejorado_ch=1 if pch5 == 1 | pch5==2
	replace banomejorado_ch=0 if pch5 == 3 | pch5==4| pch5==5
	
	
	**********
	*pared_ch*
	**********
	gen pared_ch=.
	replace pared_ch=0 if pcv2 ==9 
	replace pared_ch=1 if pcv2 == 1 | pcv2==2 | pcv2 ==3 | pcv2 ==5
	replace pared_ch=2 if pcv2 == 4 | pcv2==6 | pcv2 ==7 | pcv2 ==8 | pcv2 ==10 | pcv2 ==11

	
	**********
	*techo_ch*
	**********
	gen techo_ch=.
	replace techo_ch=0 if pcv3 ==6
	replace techo_ch=1 if pcv3 ==1 | pcv3 == 2 | pcv3 == 3 | pcv3==4
	replace techo_ch=2 if pcv3 ==5 | pcv3 == 7 | pcv3 == 8
	
	**********
	*resid_ch*
	**********
	gen resid_ch=. 
    replace resid_ch=0 if pch10 ==1 | pch10 == 2
	replace resid_ch=1 if pch10 ==3 | pch10 == 4 
	replace resid_ch=2 if pch10 ==5 | pch10 == 6
	
	*********
	*dorm_ch*
	*********
	gen dorm_ch=pch12
	
	
	************
	*cuartos_ch*
	************
	gen cuartos_ch=pch11
	
	***********
	*cocina_ch*
	***********
	gen cocina_ch=pch13
	replace cocina_ch=0 if pch13==2
	
	***********
	*telef_ch*
	***********
	*sin dato
	gen telef_ch=.
	
	***********
	*refrig_ch*
	***********
	gen refrig_ch=pch9_e
	replace refrig_ch=0 if pch9_e==2
	
	*********
	*auto_ch*
	*********
	gen auto_ch=pch9_m
	replace auto_ch = 0 if pch9_m==2
	
	********
	*compu_ch*
	********
	gen compu_ch=pch9_h
	replace compu_ch =0 if pch9_h==2
	
	*************
	*internet_ch*
	************* 
	gen internet_ch=pch9_i
	replace internet_ch=0 if pch9_i==2
	
	********
	*cel_ch*
	********
	*sin dato
	gen cel_ch=.
	
	*************
	*viviprop_ch*
	*************
	gen viviprop_ch1=.
	replace viviprop_ch1=0 if pch1 == 3
	replace viviprop_ch1=1 if pch1 ==1 
	replace viviprop_ch1=2 if pch1 == 2 



**********************************************
***      VARIABLES DEL MERCADO LABORAL     ***
**********************************************	

     *******************
     ****condocup_ci****
     *******************
    gen condocup_ci=.
	replace condocup_ci=1 if pocupa==1 
	replace condocup_ci=2 if pdesoc==1
	replace condocup_ci=3 if pei==1
	replace condocup_ci=4 if edad_ci<7
	
	************
     ***emp_ci***
     ************
    gen emp_ci=0
	replace emp_ci=1 if pocupa==1 
	
	****************
     ***desemp_ci***
     ****************	
	gen desemp_ci=0
	replace desemp_ci=1 if pdesoc==1

	
	*************
      ***pea_ci***
      *************
    gen pea_ci=.
	replace pea_ci=1 if condocup_ci==1
	replace pea_ci=1 if condocup_ci==2
	replace pea_ci=0 if condocup_ci==3
	replace pea_ci=0 if condocup_ci==4
	
	 *************************
     ****rama de actividad****
     *************************
*************
**rama_ci****
*************
gen rama_ci=.
replace rama_ci=1 if pcp32_2d>=1 & pcp32_2d<=3
replace rama_ci=2 if pcp32_2d>=5 & pcp32_2d<=9
replace rama_ci=3 if pcp32_2d>=10 & pcp32_2d<=33
replace rama_ci=4 if pcp32_2d>=35 & pcp32_2d<=39
replace rama_ci=5 if pcp32_2d>=41 & pcp32_2d<=43
replace rama_ci=6 if (pcp32_2d>=45 & pcp32_2d<=47) | (pcp32_2d>=55 & pcp32_2d<=56)
replace rama_ci=7 if (pcp32_2d>=49 & pcp32_2d<=53) | pcp32_2d==61 
replace rama_ci=8 if pcp32_2d>=64 & pcp32_2d<=68
replace rama_ci=9 if (pcp32_2d>=69 & pcp32_2d<=99) | (pcp32_2d>=58 & pcp32_2d<=60) | (pcp32_2d>=62 & pcp32_2d<=63)

	
	*********************
     ****categopri_ci****
     *********************
	 *OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.
	 gen categopri_ci=.
	 replace categopri_ci=1 if pcp31_d==1
	 replace categopri_ci=2 if pcp31_d==2 | pcp31_d==3
	 replace categopri_ci=3 if pcp31_d==4 | pcp31_d==5 | pcp31_d==6
	 replace categopri_ci=4 if emp_ci==1  & pcp31_d==7
	 
	 
	 *****************
     ***spublico_ci***
     *****************
    gen spublico_ci=.
	replace spublico_ci=1 if emp_ci==1 & pcp32_1d ==15
	replace spublico_ci=0 if emp_ci==1 & pcp32_1d ~=15
	

**********************************
**** VARIABLES DE INGRESO ****
***********************************
*Guatemala 2018 no tiene variables de ingreso

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
	replace migrante_ci=1 if migra_vida==1 | migra_rec==1
	
	*******************
    **migantiguo5_ci***
    *******************
	gen migantiguo5_ci =.
	replace migantiguo5_ci=1 if migra_vida==1
	
	**********************
	*** migrantelac_ci ***
	**********************
	gen migrantelac_ci = .
	
	*******************
    **migrantiguo5_ci**
    *******************
	gen migrantiguo5_ci =.
	
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
gen aedu_ci =aneduca


**************
***eduno_ci***
**************
gen eduno_ci=(aedu_ci==0) // never attended or pre-school
replace eduno_ci=. if aedu_ci==. // NIU & missing

**************
***edupi_ci***
**************
gen edupi_ci=(aedu_ci>0 & aedu_ci<6) //
replace edupi_ci=. if aedu_ci==. // NIU & missing


**************
***edupc_ci***
**************
gen edupc_ci=(aedu_ci==6) 
replace edupc_ci=. if aedu_ci==. // NIU & missing

**************
***edusi_ci***
**************
gen edusi_ci=(aedu_ci>6 & aedu_ci<11) // 7 a 10 anos de educación
replace edusi_ci=. if aedu_ci==. // NIU & missing

**************
***edusc_ci***
**************
gen edusc_ci=(aedu_ci>=11) // 11 anos de educación
replace edusc_ci=. if aedu_ci==. // NIU & missing

***************
***edus1i_ci***
***************
gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
replace edus1i_ci=. if aedu_ci==. // missing a los NIU & missing

***************
***edus1c_ci***
***************
gen byte edus1c_ci=(aedu_ci==9)
replace edus1c_ci=. if aedu_ci==. // missing a los NIU & missing

***************
***edus2i_ci***
***************
gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<11)
replace edus2i_ci=. if aedu_ci==. // missing a los NIU & missing

***************
***edus2c_ci***
***************
gen byte edus2c_ci=(aedu_ci>=11)
replace edus2c_ci=. if aedu_ci==. // missing a los NIU & missing

***************
***edupre_ci***
***************
gen byte edupre_ci=(nivgrado==2)
replace edupre_ci=. if aedu_ci==.
*label variable edupre_ci "Educacion preescolar"

***************
***asiste_ci***
***************
gen asiste_ci=.
replace asiste_ci=1 if pcp18==1
replace asiste_ci=0 if pcp18==2
*label variable asiste_ci "Asiste actualmente a la escuela"

**************
***literacy***
**************
gen literacy=. 


*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
			
	***************
	***afroind_ci***
	***************
gen afroind_ci=. 
replace afroind_ci=1 if pcp12==1 | pcp12==2 | pcp12==3 
replace afroind_ci=2 if pcp12==4
replace afroind_ci=3 if pcp12==5 | pcp12==6 


   ***************
	***afroind_ch***
	***************
	gen afroind_jefe= afroind_ci if jefe_ci==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 
	
	drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=1964	

	*******************
	***dis_ci***
	*******************
/*	
No, sin dificultad ..................1
Sí, con algo de dificultad ......... 2
Sí, con mucha dificultad ........... 3
No puede ............................4
*/
gen dis_ci=0
replace dis_ci=1 if pcp16_a>=3 & pcp16_a<=4 | pcp16_b>=3 & pcp16_b<=4 | pcp16_c>=3 & pcp16_c<=4 
replace dis_ci=1 if pcp16_d>=3 & pcp16_d<=4 | pcp16_e>=3 & pcp16_e<=4 | pcp16_f>=3 & pcp16_f<=4 

	*******************
	***dis_ch***
	*******************
egen dis_ch  = sum(dis_ci), by(idh_ch) 
replace dis_ch=1 if dis_ch>=1 & dis_ch!=.


*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"


compress

save "`base_out'", replace 
log close	

	
