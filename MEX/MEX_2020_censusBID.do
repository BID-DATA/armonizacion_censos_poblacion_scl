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
global ruta = "${censusFolder}"
local PAIS MEX
local ANO "2020"

local log_file = "$ruta//clean//`PAIS'//`PAIS'_`ANO'_censusBID.log"
local base_in  = "$ruta//raw//`PAIS'//`PAIS'_`ANO'.dta"
local base_out = "$ruta//clean//`PAIS'//`PAIS'_`ANO'_censusBID.dta"
                                                    
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Mexico
Año:
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

use "`base_in'", clear

			****************************
			*  VARIABLES DE DISENO     *
			****************************
	*********
	*pais_c*
	*********
    gen pais_c="`PAIS'"
	
	*********
	*anio_c*
	*********
	gen anio_c=`ANO'
	
	******************
    *idh_ch (id hogar)*
    ******************
    rename id_viv idh_ch 
	
	******************
    *idp_ci (idpersonas)*
    ******************
	
	tostring id_persona numper, replace 
	egen idp_ci=concat(id_persona numper)
	destring idp_ci, replace
	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
	gen factor_ci=factor
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
	gen factor_ch=factor
	
	
	***********
	* estrato *
	***********
	gen estrato_ci=estrato
	
	***********
	* 	UPM	  *
	***********
	gen upm_ci=upm

	
	***************************
	* Zona urbana (1) o rural (0)
	***************************
	gen zona_c=.
	

	
****************
* region_BID_c *
****************
	
gen region_BID_c=.

label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c

****************
 *** region_c ***
****************

gen region_c =.
replace region_c=ent

label define region_c ///
1 "Aguascalientes" ///
2 "Baja California" ///
3 "Baja California Sur" ///
4 "Campeche" ///
5 "Coahuila de Zaragoza" ///
6 "Colima" ///
7 "Chiapas" ///
8 "Chihuahua" ///
9 "Distrito Federal" ///
10 "Durango" ///
11 "Guanajuato" ///
12 "Guerrero" ///
13 "Hidalgo" ///
14 "Jalisco" ///
15 "México" ///
16 "Michoacán de Ocampo" ///
17 "Morelos" ///
18 "Nayarit" ///
19 "Nuevo León" ///
20 "Oaxaca" ///
21 "Puebla" ///
22 "Querétaro" ///
23 "Quintana Roo" ///
24 "San Luis Potosí" ///
25 "Sinaloa" ///
26 "Sonora" ///
27 "Tabasco" ///
28 "Tamaulipas" ///
29 "Tlaxcala" ///
30 "Veracruz de Ignacio de la Llave" ///
31 "Yucatán" ///
32 "Zacatecas" 
label value region_c region_c
label var region_c "division politico-administrativa, estados"

*********************************************
***         VARIABLES DEMOGRAFICAS        ***
*********************************************
	
	*********
	*sexo_c*
	*********
	rename sexo sexo_ci
	replace sexo_ci =2 if sexo_ci == 3
	
	*********
	*edad_c*
	*********
	rename edad edad_ci
	replace edad_ci=. if edad_ci==999 /* age=999 corresponde a "unknown" */
	replace edad_ci=98 if edad_ci>=98  /* age=100 corresponde a 100+ */

 	*************
	*relacion_ci*
	*************	
	gen relacion_ci=1 if parentesco==101
    replace relacion_ci=2 if parentesco>=201 & parentesco<300
    replace relacion_ci=3 if parentesco>=300 & parentesco <400
    replace relacion_ci=4 if parentesco>=400 & parentesco <500
    replace relacion_ci=5 if (parentesco>=500 & parentesco <600) | (parentesco>=611 & parentesco <613) | parentesco==701
    replace relacion_ci=6 if parentesco==601
	replace relacion_ci=. if parentesco==999
	
	**************
	*Estado Civil*
	**************
	*2010 no tiene variable marst
	gen civil_ci=.
	replace civil_ci=1 if situa_conyugal==8 //soltero
	replace civil_ci=2 if situa_conyugal==2 | situa_conyugal==5 | situa_conyugal==6 | situa_conyugal==7     //union
	replace civil_ci=3 if situa_conyugal==2 | situa_conyugal==3   //divorciado
	replace civil_ci=4 if situa_conyugal==4 //viudo
	
	
        *********
	*jefe_ci*
	*********
	gen jefe_ci=(relacion_ci==1)
	replace jefe_ci=. if relacion_ci == .
	

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
	*NOTA: se utiliza la variable related la cual tiene más desagregación en cuanto a la relación con el jefe de hogar
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
	
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************

	gen afroind_ci=. 
	replace afroind_ci=1  if (perte_indigena == 1)
	replace afroind_ci=2  if (afrodes == 1)
	replace afroind_ci=3 if (perte_indigena !=1 & afrodes!=1)


	***************
	***afroind_ch***
	***************
	gen afroind_jefe= afroind_ci if relacion_ci==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

	drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
	gen afroind_ano_c=2000


	********************
	*** discapacidad ***
	********************
	gen dis_ci=.
	
replace dis_ci=0 if (dis_caminar==1 & dis_ver==1 & dis_recordar==1 & dis_oir==1 & dis_banarse==1 & dis_hablar==1)
replace dis_ci=1 if dis_ci!=0
replace dis_ci=. if (dis_caminar==9 & dis_ver==9 & dis_recordar==9 & dis_oir==9 & dis_banarse==9 & dis_hablar==9)

	*************
	***dis_ch***
	**************
egen dis_ch = sum(dis_ci), by(idh_ch) 
replace dis_ch=1 if dis_ch>=1 & dis_ch!=. 

**********************************
**** VARIABLES DE LA VIVIENDA ****
**********************************
		
	************
	*aguared_ch*
	************

	gen aguared_ch=.
	replace aguared_ch=1 if agua_entubada==1 | agua_entubada==2
	replace aguared_ch=0 if agua_entubada==3
	
	
	********
	*luz_ch*
	********
	*En la nueva encuesta no se encontro si se pregunta por instalacion electrica
	gen luz_ch=.
	replace luz_ch=1 if electricidad==1
	replace luz_ch=2 if electricidad==3
	

	*********
	*bano_ch*
	*********
	gen bano_ch=.
	replace bano_ch=1 if sersan==1 | sersan==2
	replace bano_ch=0 if sersan==0
	

	*********
	*des1_ch*
	*********
	gen des1_ch=.
	replace des1_ch=0 if bano_ch==0 
	replace des1_ch=1 if sersan==1
	replace des1_ch=2 if sersan==2
	
	*********
	*piso_ch*
	*********
	gen piso_ch=.
 	replace piso_ch=2 if pisos==3
	replace piso_ch=0 if pisos==1
	replace piso_ch=1 if pisos==2
	
	*****************
	*banomejorado_ch*
	*****************
	gen banomejorado_ch=.
 	replace banomejorado_ch=0 if drenaje==5 
	replace banomejorado_ch=1 if drenaje>=1 & drenaje<=4

	**********
	*pared_ch*
	**********
	gen pared_ch=.
	replace pared_ch=1 if paredes>=1 & paredes<=7
	replace pared_ch=2 if paredes==8

	**********
	*techo_ch*
	**********
	gen techo_ch=.
	replace techo_ch=1 if techos>=1 & techos<=8
	replace techo_ch=2 if techos>=9 & techos<=10
	
	**********
	*resid_ch*
	**********
	gen resid_ch=.
	replace resid_ch=0 if destino_bas==1 | destino_bas==5
	replace resid_ch=1 if destino_bas==3
	replace resid_ch=2 if destino_bas==6
	replace resid_ch=3 if destino_bas==9 | destino_bas==2


	*********
	*dorm_ch*
	*********
	gen dorm_ch=.
	replace dorm_ch=cuadorm if cuadorm!=99
	
	************
	*cuartos_ch*
	************
	gen cuartos_ch=.
	replace cuartos_ch=totcuart if totcuart!=99 

	***********
	*cocina_ch*
	***********
	gen cocina_ch=.
	replace cocina_ch=1 if cocina==1
	replace cocina_ch=0 if cocina==3
	
	***********
	*telef_ch*
	***********
	gen telef_ch=.
	replace telef_ch=1 if telefono==3 
	replace telef_ch=0 if telefono==4

	***********
	*refrig_ch*
	***********
	gen refrig_ch=.
	replace refrig_ch=1 if refrigerador==1
	replace refrig_ch=0 if refrigerador==2
	
	*********
	*auto_ch*
	*********
	gen auto_ch=.
	replace auto_ch=1 if autoprop==7
	replace auto_ch=0 if autoprop==8
	
	********
	*compu_ch*
	********
	gen compu_ch=.
	replace compu_ch=1 if computadora==1 
	replace compu_ch=0 if computadora==2

	*************
	*internet_ch*
	************* 
	*pendiente esta variable no es lo que queremos generar
	gen internet_ch=.
	replace internet_ch=1 if internet==7
	replace internet_ch=0 if internet==8
	
	********
	*cel_ch*
	********
	gen cel_ch=.
	replace cel_ch=1 if celular==5
	replace cel_ch=0 if celular==6

	*************
	*viviprop_ch*
	*************
	*NOTA: aqui se genera una variable parecida, pues no se puede saber si es propia total o parcialmente pagada
	gen viviprop_ch1=.
	replace viviprop_ch=1 if tenencia==1
	replace viviprop_ch=0 if tenencia>1 & tenencia<=4
	

******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
gen ylm_ci=.
	replace ylm_ci=ingtrmen
	replace ylm_ci=. if ingtrmen==999998 | ingtrmen==999999
gen ynlm_ci=.	
	replace ynlm_ci=.


    ***********
	**ylm_ch*
	***********
   
   by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
   
    ***********
	**ynlm_ch*
	***********
   by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1, missing

 ****************************
***VARIABLES DE EDUCACION***
****************************

***************
***asiste_ci*** 
***************
gen asiste_ci=1 if asisten==1
replace asiste_ci=. if asisten==9 //  Unknown/missing as missing
replace asiste_ci=0 if asisten==2

*************
***aedu_ci*** // años de educacion aprobados
*************
gen aedu_ci=.
replace aedu_ci=escoacum
replace aedu_ci=. if escoacum==99
replace aedu_ci=. if aedu_ci==99

**************
***eduno_ci***
**************
gen byte eduno_ci=0
replace eduno_ci=1 if aedu_ci==0
replace eduno_ci=. if aedu_ci==.
	
**************
***edupi_ci***
**************
gen byte edupi_ci=0
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<6
replace edupi_ci=. if aedu_ci==.


**************
***edupc_ci***
**************
gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==6
replace edupc_ci=. if aedu_ci==.
replace edupc_ci=1 if nivacad==6
**************
***edusi_ci***
**************
gen byte edusi_ci=0
replace edusi_ci=1 if aedu_ci>6 & aedu_ci<12
replace edusi_ci=. if aedu_ci==.

**************
***edusc_ci***
**************
gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==12
replace edusc_ci=. if aedu_ci==.
replace edusc_ci=1 if nivacad==8  // Some tertiary

**********
*eduui_ci* // no completó la educación universitaria o terciaria
**********
gen eduui_ci=(aedu_ci>=13 & aedu_ci<=16) // 14 a 16 anos de educación
replace eduui_ci=. if aedu_ci ==. // NIU & missing


**********
*eduuc_ci* // completó la educación universitaria o terciaria
**********
gen eduuc_ci=.
replace eduuc_ci=1 if aedu_ci>=17
replace eduuc_ci=. if aedu_ci==. // NIU & missing

***************
***edus1i_ci***
***************
gen byte edus1i_ci=0
replace edus1i_ci=1 if aedu_ci>6 & aedu_ci<9
replace edus1i_ci=. if aedu_ci==.

***************
***edus1c_ci***
***************
gen byte edus1c_ci=0
replace edus1c_ci=1 if aedu_ci==9 
replace edus1c_ci=1 if nivacad==7 // Some tertiary
replace edus1c_ci=. if aedu_ci==.

***************
***edus2i_ci***
***************
gen byte edus2i_ci=0
replace edus2i_ci=1 if aedu_ci>9 & aedu_ci<12
replace edus2i_ci=. if aedu_ci==.

***************
***edus2c_ci***
***************
gen byte edus2c_ci=0
replace edus2c_ci=1 if aedu_ci==12
replace edus2c_ci=1 if nivacad==8 // Some tertiary
replace edus2c_ci=. if aedu_ci==.

***************
***edupre_ci***
***************
gen edupre_ci=.

**************
***literacy***
**************
gen literacy=. 
replace literacy=. if alfabet==9
replace literacy=0 if alfabet==1
replace literacy=1 if alfabet==2

**********************************************
***      VARIABLES DEL MERCADO LABORAL     ***
**********************************************	

     *******************
     ****condocup_ci****
     *******************
	 
    gen condocup_ci=.
	replace condocup_ci=1 if conact==10 | conact==16 | conact==17 | conact==18 | conact==19 | conact==20
	replace condocup_ci=2 if conact==13 | conact==30
	replace condocup_ci=3 if conact==14 | conact==15 | conact==40 | conact==50 | conact==60 | conact==70 | conact==80


      ************
      ***emp_ci***
      ************
    gen emp_ci=.
	replace emp_ci=(condocup_ci==1) if condocup_ci!=.
	
	
      ****************
      ***desemp_ci***
      ****************	
	gen desemp_ci=.
	cap confirm variable condocup_ci
	if (_rc==0){
		replace desemp_ci=1 if condocup_ci==2 /*1 desempleados*/
		replace desemp_ci=0 if condocup_ci==3 | condocup_ci==1 /*0 cuando están inactivos o empleados*/
	}
	
      *************
      ***pea_ci***
      *************
    gen pea_ci=.
	cap confirm variable condocup_ci
	if (_rc==0){
		replace pea_ci=1 if condocup_ci==1
		replace pea_ci=1 if condocup_ci==2
		replace pea_ci=0 if condocup_ci==3
	}
	
     *************************
     ****rama de actividad****
     *************************
	 *2010 no tiene variable indgen
    gen rama_ci = . 

    replace rama_ci = 1 if actividades_c>=1110 & actividades_c<2100
    replace rama_ci = 2 if actividades_c>=2110 & actividades_c<2200
    replace rama_ci = 3 if actividades_c>=3110 & actividades_c<3400 
    replace rama_ci = 4 if actividades_c>=2210 & actividades_c<2300  
    replace rama_ci = 5 if actividades_c>=2310 & actividades_c<2400   
    replace rama_ci = 6 if actividades_c>=4310 & actividades_c<4700  
    replace rama_ci = 7 if actividades_c>=7210 & actividades_c< 7300   
    replace rama_ci = 8 if actividades_c>=4810 & actividades_c<   5200
    replace rama_ci = 9 if actividades_c>=5210 & actividades_c< 5300
    replace rama_ci = 10 if actividades_c>=9311 & actividades_c< 9400 
    replace rama_ci = 11 if actividades_c>=5310 & actividades_c<5400 | actividades_c==5510  
    replace rama_ci = 12 if actividades_c>=6111 & actividades_c<6200 
    replace rama_ci = 13 if actividades_c>=6211 & actividades_c<6300 
    replace rama_ci = 14 if (actividades_c>=7111 & actividades_c<7200) | (actividades_c>=8111 & actividades_c<8140) | (actividades_c>=5411 & actividades_c<5500) | (actividades_c>=5611 & actividades_c<5700)
    replace rama_ci = 15 if actividades_c==8140
	


     *********************
     ****categopri_ci****
     *********************
	 *OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.	
    gen categopri_ci=.

    replace categopri_ci=0 if sittra==9
    replace categopri_ci=1 if sittra==4
    replace categopri_ci=2 if sittra==5
    replace categopri_ci=3 if sittra>=1 & sittra<=3
    replace categopri_ci=4 if sittra==6
	

      *****************
      ***spublico_ci***
      *****************
    gen spublico_ci=.

		replace spublico_ci=1 if rama_ci==10
		replace spublico_ci=0 if emp_ci==1 & rama_ci!=10
		replace spublico_ci=. if rama_ci==.
	
	

*******************************************************
***           VARIABLES DE MIGRACIÓN              ***
*******************************************************

    *******************
    ****migrante_ci****
    *******************
	
	gen migrante_ci =.

	replace migrante_ci = 1 if ent_pais_nac>99 & ent_pais_nac<536
	replace migrante_ci = 0 if ent_pais_nac>0 & ent_pais_nac<33
	
   
	*******************
    **migantiguo5_ci***
    *******************
	gen migantiguo5_ci =.
	
	
	**********************
	*** migrantelac_ci ***
	**********************

	gen migrantelac_ci = .

	replace migrantelac_ci= 1 if inlist(ent_pais_nac, 204, 206, 207, 208, 210, 211, 214, 215, 217, 219, 220, 225, 226, 228, 229, 230, 234, 235, 236, 237, 239, 244, 245, 250) & migrante_ci == 1
	replace migrantelac_ci = 0 if migrantelac_ci == . & migrante_ci == 1 | migrante_ci == 0
	
	
	*******************
    **migrantiguo5_ci**
    *******************
	gen migrantiguo5_ci =.

	**********************
	****** miglac_ci *****
	**********************

	gen miglac_ci = .

	replace miglac_ci= 1 if inlist(ent_pais_nac, 204, 206, 207, 208, 210, 211, 214, 215, 217, 219, 220, 225, 226, 228, 229, 230, 234, 235, 236, 237, 239, 244, 245, 250) & migrante_ci == 1
	replace miglac_ci = 0 if migrantelac_ci != 1 & migrante_ci == 1 
	
   

order region_BID_c region_c pais_c anio_c idh_ch idp_ci factor_ch factor_ci estrato_ci zona_c sexo_ci edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch condocup_ci emp_ci desemp_ci pea_ci rama_ci categopri_ci spublico_ci ylm_ci ynlm_ci ylm_ch ynlm_ch aedu_ci eduno_ci edupre_ci edupi_ci  edupc_ci  edusi_ci edusc_ci  eduui_ci eduuc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci asiste_ci literacy aguared_ch luz_ch bano_ch des1_ch piso_ch banomejorado_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch migrante_ci migrantelac_ci migantiguo5_ci 
*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

compress

save "`base_out'", replace 
log close


