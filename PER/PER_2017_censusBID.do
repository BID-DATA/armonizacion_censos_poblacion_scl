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
País: Peru
Año: 2017
Autores: Cesar Lins
Última versión: October, 2021

							SCL - IADB
****************************************************************************/


local PAIS PER
local ANO "2017"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
global ruta = "${censusFolder}"

*local log_file ="$ruta//clean//`PAIS'//log//`PAIS'_`ANO'_censusBID.log"
local base_in ="$ruta//raw//`PAIS'//`PAIS'_`ANO'_NOIPUMS.dta"
local base_out ="$ruta//clean//`PAIS'//`PAIS'_`ANO'_censusBID.dta"
                                                    
*capture log close
*log using "`log_file'", replace

use "`base_in'", clear
cap gen region_BID_c = 3

    *********
	*pais_c*
	*********
gen pais_c = "PER"

    *********
	*anio_c*
	*********
gen anio_c = 2017

    ******************
    *idh_ch (id hogar)*
    ******************
rename id_hog_imp_f idh_ch

	******************
    *idp_ci (idpersonas)*
    ******************
rename id_pob_imp_f idp_ci 

    ***********
	* estrato *
	***********
gen estrato_ci=.

    ***************************
	* Zona urbana (1) o rural (0)
	***************************
gen zona_c=.
replace zona_c=1 if encarea==1
replace zona_c=0 if encarea==2
	
	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
gen factor_ci=rk_final
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
gen factor_ch=1
	
*********************************************
***         VARIABLES DEMOGRAFICAS        ***
*********************************************
    *********
	*sexo_c*
	*********
rename c5_p2 sexo_ci 

	*********
	*edad_c*
	*********
rename c5_p4_1 edad_ci

	*************
	*relacion_ci*
	*************

gen relacion_ci=c5_p1
replace relacion_ci=4 if c5_p1==5 | c5_p1==6 | c5_p1==7 | c5_p1==8
replace relacion_ci=6 if c5_p1==9 | c5_p1==10
replace relacion_ci=5 if c5_p1==11

	**************
	*Estado Civil*
	**************
gen	civil_ci=.
replace civil_ci=1 if c5_p24==6
replace civil_ci=2 if c5_p24==1 | c5_p24==3
replace civil_ci=3 if c5_p24==2 | c5_p24==5
replace civil_ci=4 if c5_p24==4

	
    *********
	*jefe_ci*
	*********
	gen jefe_ci=(c5_p1==1)
	
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
	*aguaentubada_ch*
	************
	
	gen aguaentubada_ch=.
	replace aguaentubada_ch=1 if c2_p6 == 1 | c2_p6 == 2 
	replace aguaentubada_ch=0 if c2_p6>2 & c2_p6<9 
	
	
	************
	*aguared_ch*
	************

	gen aguared_ch=.
	replace aguared_ch = 1 if inlist(c2_p6, 1,2)
	replace aguared_ch = 0 if inlist(c2_p6,3,4,5,6,8)
	
    ***************
	*aguafuente_ch*
	***************
 
	gen aguafuente_ch=.
	replace aguafuente_ch = 1 if inlist(c2_p6, 1,2)
	replace aguafuente_ch = 2 if c2_p6 ==3
	replace aguafuente_ch = 6 if c2_p6 ==4
	replace aguafuente_ch = 8 if inlist(c2_p6, 7)
	replace aguafuente_ch = 10 if inlist(c2_p6, 6,7,8)
	
	
	*************
	*aguadist_ch*
	*************
	gen aguadist_ch=.
	replace aguadist_ch = 1 if inlist(c2_p6, 1)
	replace aguadist_ch = 2 if inlist(c2_p6, 2)
	replace aguadist_ch = 3 if inlist(c2_p6, 3)
	replace aguadist_ch = 0 if inlist(c2_p6, 4,5,6,7,8)
	
	**************
	*aguadisp1_ch*
	**************
	gen aguadisp1_ch =9 
	
	**************
	*aguadisp2_ch*
	**************
	gen aguadisp2_ch =.
	replace aguadisp2_ch = 1 if c2_p7a <12 | (c2_p7c < 12 | c2_p7b<4)
	replace aguadisp2_ch = 2 if (c2_p7a >=12 & c2_p7a<24) | (c2_p7c >= 12 & c2_p7b>=4)
	replace aguadisp2_ch = 3 if c2_p7 ==1 & c2_p7a == 24
	
	*************
	*aguamide_ch*
	*************
	gen aguamide_ch =9
	
	*********
	*bano_ch*
	*********
	gen bano_ch = . 
	replace bano_ch = 1 if inlist(c2_p10,1,2)
	replace bano_ch = 2 if c2_p10 == 3
	replace bano_ch = 4 if inlist(c2_p10, 6,7) 
	replace bano_ch = 6 if inlist(c2_p10, 4,5,8)
	
	***********
	*banoex_ch*
	***********
	
	gen banoex_ch =9

	************
	*sinbano_ch*
	************
	gen sinbano_ch =.

/*

Nota: 
	
El censo no da la opcion de "no tiene" en cuanto a las instalaciones sanitarias

*/
	
	********
	*luz_ch*
	********
	*En la nueva encuesta no se encontro si se pregunta por instalacion electrica
	gen luz_ch=.
	replace luz_ch=1 if c2_p11 ==1 
	replace luz_ch=0 if c2_p11 ==2
	
	*********
	*conbano_ch*
	*********
	gen conbano_ch=.
	replace conbano_ch=1 if c2_p10
	replace conbano_ch=1 if c2_p10 >= 1 & c2_p10 <= 4
	replace conbano_ch=0 if c2_p10>4
	
	*********
	*des1_ch*
	*********
	gen des1_ch=.
	replace des1_ch=0 if bano_ch ==0
	replace des1_ch=1 if c2_p10 == 3
	replace des1_ch=2 if c2_p10 >=4 & c2_p10<9
	
	
	*********
	*piso_ch*
	*********
	gen piso_ch=.
	replace piso_ch = 0 if c2_p5 == 6
	replace piso_ch = 1 if c2_p5 == 2 | c2_p5 ==3
	replace piso_ch = 2 if c2_p5  == 5 | c2_p5 == 4 | c2_p5==1
	
	*****************
	*banoalcantarillado_ch_ch*
	*****************
	gen banoalcantarillado_ch=.
	replace banoalcantarillado_ch=1 if c2_p10 >= 1 & c2_p10 < 4
	replace banoalcantarillado_ch=0 if c2_p10>=4
	
	
	**********
	*pared_ch*
	**********
	gen pared_ch=.
	replace pared_ch=2 if c2_p3 == 1 | c2_p3==2 | c2_p3 ==3 | c2_p3 ==4
	replace pared_ch=1 if c2_p3 >=5 & c2_p3 <=8
	
	**********
	*techo_ch*
	**********
	gen techo_ch=.
	replace techo_ch=2 if c2_p5 ==1 | c2_p5 == 2 | c2_p5 == 5 | c2_p5==6
	replace techo_ch=1 if c2_p5 ==2 | c2_p5 == 3 | c2_p5 == 4
	
	**********
	*resid_ch*
	**********
	* Peru no tiene está variable se genera en missing
	gen resid_ch=. 

	*********
	*dorm_ch*
	*********
	* Peru no tiene está variable se genera en missing
	gen dorm_ch=.
	
	
	************
	*cuartos_ch*
	************
	gen cuartos_ch=c2_p12
	replace cuartos_ch=. if c2_p12==99
	
	***********
	*cocina_ch*
	***********
	* Peru no tiene está variable se genera en missing
	gen cocina_ch=.
	
	***********
	*telef_ch*
	***********
	gen telef_ch=c3_p2_11
	replace telef_ch=0 if c3_p2_11==2
	
	***********
	*refrig_ch*
	***********
	gen refrig_ch=c3_p2_4
	replace refrig_ch=0 if c3_p2_4==2
	
	*********
	*auto_ch*
	*********
	gen auto_ch=c3_p2_14
	replace auto_ch = 0 if c3_p2_14==2
	
	********
	*compu_ch*
	********
	gen compu_ch=c3_p2_9
	replace compu_ch =0 if c3_p2_9==2
	
	*************
	*internet_ch*
	************* 
	gen internet_ch=c3_p2_13
	replace internet_ch=0 if c3_p2_13==2
	
	********
	*cel_ch*
	********
	gen cel_ch=c3_p2_10
	replace cel_ch=0 if c3_p2_10==2
	
	*************
	*viviprop_ch*
	*************
	*NOTA: aqui se genera una variable parecida, pues no se puede saber si es propia total o parcialmente pagada
	gen viviprop_ch1=.
	replace viviprop_ch1=1 if c2_p13 == 2 | c2_p13 == 3 
	replace viviprop_ch1=0 if c2_p13 ==1 | c2_p13 == 4
	
	
**********************************************
***      VARIABLES DEL MERCADO LABORAL     ***
**********************************************	

     *******************
     ****condocup_ci****
     *******************
	gen byte condocup_ci=.
	replace condocup_ci=1 if (c5_p17 >=1 & c5_p17<=5)|c5_p16==1 // trabajó
	replace condocup_ci=2 if (c5_p17==7|c5_p17==6|c5_p16==2)&c5_p18==1 // no trabajó y buscó
	replace condocup_ci=3 if (c5_p17==7|c5_p17==6|c5_p16==2)&c5_p18==2 // no trabajó y no buscó
	replace condocup_ci=4 if edad_ci <15     

	
	
	************
     ***emp_ci***
     ************
    gen emp_ci=.
	replace emp_ci=1 if c5_p17>=1 & c5_p17<=6
	replace emp_ci=0 if c5_p17==7
	
	
	****************
     ***desemp_ci***
     ****************	
	gen desemp_ci=.
	replace desemp_ci=1 if c5_p17==7 & c5_p18==1
	replace desemp_ci=0 if c5_p17<7 | c5_p18==2
	
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
    gen rama_ci = .
	destring c5_p19_cod, replace
	replace rama_ci= 1 if c5_p19_cod>=111 & c5_p19_cod<=500
	replace rama_ci = 2 if c5_p19_cod>=1010 & c5_p19_cod<=1429
	replace rama_ci = 3 if c5_p19_cod>=1511 & c5_p19_cod <= 3700
	replace rama_ci = 4 if c5_p19_cod>=4010 & c5_p19_cod<=4100
	replace rama_ci = 5 if c5_p19_cod>=4510 & c5_p19_cod<=4550
	replace rama_ci = 6 if c5_p19_cod>=5010 & c5_p19_cod<=5260
	replace rama_ci = 7 if c5_p19_cod>=5510 & c5_p19_cod<=5220 
	replace rama_ci = 8 if c5_p19_cod>=6010 & c5_p19_cod<= 6420
	replace rama_ci = 9 if c5_p19_cod>=6511 & c5_p19_cod <= 6720
	replace rama_ci = 11 if c5_p19_cod>=7010 & c5_p19_cod <= 7499
	replace rama_ci = 10 if c5_p19_cod>=7511 & c5_p19_cod<=7530
	replace rama_ci = 12 if c5_p19_cod>=8010 & c5_p19_cod<=8090
	replace rama_ci = 13 if c5_p19_cod>=8511 & c5_p19_cod>=8532
	replace rama_ci = 14 if c5_p19_cod>=9000 & c5_p19_cod>=9309
	replace rama_ci = 15 if c5_p19_cod==9500
	
	*********************
     ****categopri_ci****
     *********************
	 *OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.
	 gen categopri_ci=.
	 replace categopri_ci=1 if c5_p21==1
	 replace categopri_ci=2 if c5_p21==2
	 replace categopri_ci=3 if c5_p21==3 |c5_p21==4 |c5_p21==5 | c5_p21==6
	 replace categopri_ci=4 if emp_ci==1 & c5_p16==2
	 
	 
	 *****************
     ***spublico_ci***
     *****************
    gen spublico_ci=.
	replace spublico_ci=1 if emp_ci==1 & rama_ci ==10
	replace spublico_ci=0 if emp_ci==1 & rama_ci ~=10
	

**********************************
**** VARIABLES DE INGRESO ****
***********************************
*Peru no tiene variables de ingreso

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
	gen migrante_ci =.  
	
	*******************
    **migantiguo5_ci***
    *******************
	gen migantiguo5_ci =.
	
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
	
	
*****************************************************
******* Variables specific for this census **********
*****************************************************

****** REGION *****************
gen region_c=ccdd
label define region_c ///
1"Amazonas"	          ///
2"Ancash"	          ///
3"Apurimac"	          ///
4"Arequipa"	          ///
5"Ayacucho"	          ///
6"Cajamarca"	      ///
7"Callao"	          ///
8"Cusco"	          ///
9"Huancavelica"	      ///
10"Huanuco"	          ///
11"Ica"	              ///
12"Junin"	          ///
13"La libertad"	      ///
14"Lambayeque"	      ///
15"Lima"	          ///
16"Loreto"	          ///
17"Madre de Dios"	  ///
18"Moquegua"	      ///
19"Pasco"	          ///
20"Piura"	          ///
21"Puno"	          ///
22"San Martín"	      ///
23"Tacna"	          ///
24"Tumbes"	          ///
25"Ucayali"	

****** geolev1 *****************
destring ccdd, replace
gen geolev1=.
replace geolev1 = 604001 if ccdd ==1
replace geolev1 = 604002 if ccdd ==2
replace geolev1 = 604003 if ccdd ==3
replace geolev1 = 604004 if ccdd ==4
replace geolev1 = 604005 if ccdd ==5
replace geolev1 = 604006 if ccdd ==6
replace geolev1 = 604007 if ccdd ==7
replace geolev1 = 604008 if ccdd ==8
replace geolev1 = 604009 if ccdd ==9
replace geolev1 = 604010 if ccdd ==10
replace geolev1 = 604011 if ccdd ==11
replace geolev1 = 604012 if ccdd ==12
replace geolev1 = 604013 if ccdd ==13
replace geolev1 = 604014 if ccdd ==14
replace geolev1 = 604015 if ccdd ==15
replace geolev1 = 604016 if ccdd ==16
replace geolev1 = 604017 if ccdd ==17
replace geolev1 = 604018 if ccdd ==18
replace geolev1 = 604019 if ccdd ==19
replace geolev1 = 604020 if ccdd ==20
replace geolev1 = 604021 if ccdd ==21
replace geolev1 = 604022 if ccdd ==22
replace geolev1 = 604023 if ccdd ==23
replace geolev1 = 604024 if ccdd ==24
replace geolev1 = 604025 if ccdd ==25

label define geolev1 604001 "Amazonas" 604002 "Ancash" 604003 "Apurímac" 604004 "Arequipa" 604005	"Ayacucho" 604006	"Cajamarca" 604007	"Callao" 604008	"Cusco" 604009	"Huancavelica" 604010	"Huanuco" 604011	"Ica" 604012	"Junin" 604013	"La Libertad" 604014	"Lambayeque" 604015	"Lima" 604016	"Loreto" 604017	"Madre de Dios" 604018	"Moquegua" 604019	"Pasco" 604020	"Piura" 604021	"Puno" 604022	"San Martin" 604023	"Tacna" 604024	"Tumbes" 604025	"Ucayali"
label value geolev1 geolev1

***************************************
************** Education **************
***************************************

*************
***aedu_ci***
*************
gen aedu_ci = .
replace aedu_ci = 0 if c5_p13_niv == 1 | c5_p13_niv ==2
replace aedu_ci = 1 if (c5_p13_niv == 3 & c5_p13_gra ==1) | (c5_p13_niv == 3 & c5_p13_anio_pri ==1)
replace aedu_ci = 2 if (c5_p13_niv == 3 & c5_p13_gra ==2) | (c5_p13_niv == 3 & c5_p13_anio_pri ==2)
replace aedu_ci = 3 if (c5_p13_niv == 3 & c5_p13_gra ==3) | (c5_p13_niv == 3 & c5_p13_anio_pri ==3)
replace aedu_ci = 4 if (c5_p13_niv == 3 & c5_p13_gra ==4) | (c5_p13_niv == 3 & c5_p13_anio_pri ==4)
replace aedu_ci = 5 if (c5_p13_niv == 3 & c5_p13_gra ==5) | (c5_p13_niv == 3 & c5_p13_anio_pri ==5)
replace aedu_ci = 6 if (c5_p13_niv == 3 & c5_p13_gra ==6) | (c5_p13_niv == 3 & c5_p13_anio_pri ==6)
replace aedu_ci = 7 if (c5_p13_niv == 4 & c5_p13_gra ==1) | (c5_p13_niv == 4 & c5_p13_anio_sec ==1)
replace aedu_ci = 8 if (c5_p13_niv == 4 & c5_p13_gra ==2) | (c5_p13_niv == 4 & c5_p13_anio_sec ==2)
replace aedu_ci = 9 if (c5_p13_niv == 4 & c5_p13_gra ==3) | (c5_p13_niv == 4 & c5_p13_anio_sec ==3)
replace aedu_ci = 10 if (c5_p13_niv == 4 & c5_p13_gra ==4) | (c5_p13_niv == 4 & c5_p13_anio_sec ==4)
replace aedu_ci = 11 if (c5_p13_niv == 4 & c5_p13_gra ==5) | (c5_p13_niv == 4 & c5_p13_anio_sec ==5)
replace aedu_ci = 12 if (c5_p13_niv == 4 & c5_p13_gra ==6) | (c5_p13_niv == 4 & c5_p13_anio_sec ==6)
replace aedu_ci = 13 if c5_p13_niv ==7 | c5_p13_niv== 8 | c5_p13_niv == 9 | c5_p13_niv == 10 


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
gen edusi_ci=(aedu_ci>=7 & aedu_ci<11) // 7 a 10 anos de educación
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
gen byte edupre_ci=(c5_p13_niv==2)
replace edupre_ci=. if aedu_ci==.
*label variable edupre_ci "Educacion preescolar"

***************
***asiste_ci***
***************
gen asiste_ci=.
replace asiste_ci=1 if c5_p14==1
replace asiste_ci=0 if c5_p14==2
*label variable asiste_ci "Asiste actualmente a la escuela"

**************
***literacy***
**************
gen literacy=. 
replace literacy=1 if c5_p12 == 1
replace literacy=0 if c5_p12 == 2

*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
			
	***************
	***afroind_ci***
	***************
gen afroind_ci=. 
replace afroind_ci=1 if c5_p25==1 | c5_p25==2 | c5_p25==3 | c5_p25==4
replace afroind_ci=2 if c5_p25==5
replace afroind_ci=3 if c5_p25==6 | c5_p25==7 | c5_p25==8

	***************
	***afroind_ch***
	***************
    gen afroind_jefe= afroind_ci if jefe_ci==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 
	
	drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=2017	

	*******************
	***dis_ci***
	*******************
gen dis_ci=. 
replace dis_ci=1 if c5_p9_1==1 | c5_p9_2==1 | c5_p9_3==1 |c5_p9_4==1 | c5_p9_5==1 | c5_p9_6==1
replace dis_ci=0 if c5_p9_1==0  & c5_p9_2==0 & c5_p9_3==0 & c5_p9_4==0 & c5_p9_5==0 & c5_p9_6==0
replace dis_ci=0 if c5_p9_7==1

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


*log close

