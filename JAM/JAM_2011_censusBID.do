* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: JAMAICA
Año: 2011
Autores: Nathalia Maya Scarpeta y Cesar Lins
Última versión:  30MAR2022
División: SCL/LMK - IADB
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
global PAIS JAM   				 //cambiar
global ANIO 2011   				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using `"$log_file"'  //agregar ,replace si ya está creado el log_file en tu carpeta

use "$base_in", clear

rename *, lower

* sample 20   		// significa muestra de 20% de la base. Activar si se necesita.     

/****************************************************************************
   II. Armonización de variables 
*****************************************************************************/

	****************
	* region_BID_c *
	****************
	* CCB
	gen byte region_BID_c=2 

	**********
	*region_c*   
	**********
	gen region_c = parish
	label define region_c  ///
			   1 "Kingston" ///
			   2 "St andrew" ///
			   3 "St thomas" ///
			   4 "Portland" ///
			   5 "St mary" ///
			   6 "St ann" ///
			   7 "Trelawny" ///
			   8 "St james" ///
			   9 "Hanover" ///
			  10 "Westmoreland" ///
			  11 "St elizabeth" ///
			  12 "Manchester" ///
			  13 "Clarendon" ///
			  14 "St catherine", replace
			
	label value region_c region_c

	***************
	**** geolev1 ****
	***************
	gen long geolev1=.
	replace geolev1 = 388001  if parish==1 
	replace geolev1 = 388002	if parish==2 
	replace geolev1 = 388003	if parish==3 
	replace geolev1 = 388004	if parish==4 
	replace geolev1 = 388005	if parish==5 
	replace geolev1 = 388006	if parish==6 
	replace geolev1 = 388007	if parish==7 
	replace geolev1 = 388008	if parish==8
	replace geolev1 = 388009	if parish==9 
	replace geolev1 = 388010	if parish==10 
	replace geolev1 = 388011	if parish==11 
	replace geolev1 = 388012	if parish==12 
	replace geolev1 = 388013	if parish==13 
	replace geolev1 = 388014	if parish==14 

	label define geolev1 388001	"Kingston" 388002	"Saint Andrew" 388003	"Saint Thomas" 388004	"Portland" 388005	"Saint Mary" 388006	"Saint Ann" 388007	"Trelawny" 388008	"Saint James" 388009	"Hanover" 388010	"Westmoreland" 388011	"Saint Elizabeth" 388012	"Manchester" 388013	"Clarendon" 388014	"Saint Catherine"
	label value geolev1 geolev1

	*********
	*pais_c*
	*********
    gen str3 pais_c="JAM"
	
	*********
	*anio_c*
	*********
	gen int anio_c=2011
	
	******************
    *idh_ch (id hogar)*
    ******************
	** SE ENCUENTRA EN EL SCRIPT DE MERGE ****
	tostring idh_ch, replace 
	
	******************
    *idp_ci (idpersonas)*
    ******************
	gen idp_ci = individu 
	tostring idp_ci, replace 
	
	****************************************
	*factor expansión individio (factor_ci)* 
	****************************************
	gen factor_ci = weight
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
	gen factor_ch = hweight
	
	***********
	* estrato * 
	***********
	gen byte estrato_ci=.
	
	***************************
	* Zona urbana (1) o rural (0)
	***************************
	gen byte zona_c=sector
	recode zona_c (2=0)	


************************************
*** 2. Demografía (18 variables) ***
************************************
	
	*********
	*sexo_c*
	*********
	gen byte sexo_ci = q1_1
	
	*********
	*edad_c*
	*********
	gen int edad_ci = q1_2b_ag

 	*************
	*relacion_ci*
	*************	
	gen byte relacion_ci=1 if q1_3==1
    replace relacion_ci=2 if q1_3==2 | q1_3==3
    replace relacion_ci=3 if q1_3>=4 & q1_3<=6
    replace relacion_ci=4 if q1_3>=7 & q1_3<=11
    replace relacion_ci=6 if q1_3==12 
	replace relacion_ci=. if q1_3==99
	
	**************
	*Estado Civil*
	**************
	*2010 no tiene variable marst
	gen byte civil_ci=.
	replace civil_ci=1 if q1_6==4
	replace civil_ci=2 if q1_6==1
	replace civil_ci=3 if q1_6==2 | q1_6==5
	replace civil_ci=4 if q1_6==3
	replace civil_ci=. if q1_6==9
	
    *********
	*jefe_ci*
	*********
	gen byte jefe_ci=(relacion_ci==1)
	replace jefe_ci=. if relacion_ci == 99
	
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
	* tab related, nol
	by idh_ch, sort: egen nempdom_ch=sum(q1_3==12) if relacion_ci==6	  

	************
	*miembros_ci
	************
	gen miembros_ci=(relacion_ci>=1 & relacion_ci<=5) 
	* tab persons
	* tab miembros_ci	
	
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
	***afroind_ci**
	***************
	gen byte afroind_ci=. 
	replace afroind_ci=2 if q1_4 == 1
	replace afroind_ci=3 if q1_4 != 1 
	replace afroind_ci=. if q1_4==9 

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
	egen byte afroind_ch  = min(afroind_jefe), by(idh_ch) 
	drop afroind_jefe 

	********
	*dis_ci*
	********
	gen byte dis_ci=.
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	
	********
	*dis_ch*
	********
	gen dis_ch=.
	/*
	PROBLEM: these variables are in another dataset,
	but the id variables are inconsistent and do not
	uniquely identify the observations, making the merge
	impossible. Needs further investigation.

	gen dis_ci = 0
	recode dis_ci nonmiss=. if inlist(9,q1_7seei,q1_7hear,q1_7walk,q1_7memo,q1_7lift,q1_7self,q1_7comm) //
	recode dis_ci nonmiss=. if q1_7seei>=. & q1_7hear>=. & q1_7walk>=. & q1_7memo>=. & q1_7lift>=. & q1_7self>=. & q1_7comm>=. //
		foreach i in seei hear walk memo lift self comm {
			forvalues j=2/4 {
			replace dis_ci=1 if q1_7`i'==`j'
			}
			}

	egen dis_ch  = sum(dis_ci), by(idh_ch) 
	replace dis_ch=1 if dis_ch>=1 & dis_ch!=. 
	*/

**********************************
*** 4. Migración (3 variables) ***
**********************************	


*******************************************************
***           VARIABLES DE MIGRACIÓN              ***
*******************************************************

    *******************
	****migrante_ci****
	*******************
	gen byte migrante_ci =.
	replace migrante_ci = 1 if q4_3a == 1
	replace migrante_ci = 0 if q4_3a == .

	**********************
	*** migrantelac_ci ***
	**********************
	gen migrantelac_ci = 0
	replace migrantelac_ci= 1 if inlist(q4_3a_2,5,13,29)
	replace migrantelac_ci =. if q4_3a_2==9999

	*******************
	**migrantiguo5_ci**
	*******************
	gen migrantiguo5_ci = 1 if q4_4<=2006
	replace migrantiguo5_ci = 0 if q4_4>2006
	replace migrantiguo5_ci = . if q4_4==.

	**********************
	****** miglac_ci *****
	**********************
	gen miglac_ci= 1 if inlist(q4_3a_2,5,13,29)
	replace miglac_ci = 0 if q4_3a_2!=5 & q4_3a_2!=13 & q4_3a_2!=29
	replace miglac_ci = . if q4_3a_2==.

   

**********************************
**** VARIABLES DE LA VIVIENDA ****
**********************************

	************
	*aguaentubada_ch* 
	************

	gen aguaentubada_ch=.
	replace aguaentubada_ch=1 if q3_13wat<=3 
	replace aguaentubada_ch=0 if q3_13wat>3
	replace aguaentubada_ch=. if q3_13wat==99

	************
	*aguared_ch*
	************
	gen aguared_ch=.
	replace aguared_ch = 1 if inlist(q3_6kitc,1)
	replace aguared_ch = 0 if inlist(q3_6kitc,2,9)
	
	************
	*aguafuente_ch*
	************
	gen aguafuente_ch=.
	replace aguafuente_ch=1 if inlist(q3_14dri,2,3) & inlist(q3_13wat,1,2)
	replace aguafuente_ch=2 if inlist(q3_13wat,5)
	replace aguafuente_ch=6 if inlist(q3_13wat,8)
	replace aguafuente_ch=7 if inlist(q3_13wat,3,4)
	replace aguafuente_ch=8 if inlist(q3_13wat,7)
	replace aguafuente_ch=10 if inlist(q3_13wat,6,9,99)
	replace aguafuente_ch=3 if q3_14dri ==1
	
	*************
	*aguadist_ch*
	*************
	gen aguadist_ch=.
	replace aguadist_ch =1 if inlist(q3_13wat,1,3)
	replace aguadist_ch =2 if inlist(q3_13wat,2,4)
	replace aguadist_ch = 3 if inlist(q3_13wat,5,6)
	replace aguadist_ch = 0 if inlist(q3_13wat,7,8,9,10)
	
	**************
	*aguadisp1_ch*
	**************
	gen aguadisp1_ch= 9
	**************
	*aguadisp2_ch*
	**************
	gen aguadisp2_ch= 9
	*************
	*aguamide_ch*
	*************
	gen aguamide_ch= 9
	
	
    *********
	*bano_ch*
	*********
	gen bano_ch= .
	replace bano_ch = 0 if q3_9toil ==5
	replace bano_ch = 1 if q3_9toil ==1
	replace bano_ch = 6 if inlist(q3_9toil, 2,3,4,9)
	
	
	***********
	*banoex_ch*
	***********
	gen banoex_ch=.
	replace banoex_ch = 1 if inlist(q3_10toi,2)
	replace banoex_ch = 0 if q3_10toi == 1
	

	**************
	*sinbano_ch*
	**************
	gen sinbano_ch =.
	replace sinbano_ch =0 if inlist(q3_9toil, 1,2,3,4,9)
	replace sinbano_ch =3 if inlist(q3_9toil, 5)
	
		
	********
	*luz_ch*
	********
	*En la nueva encuesta no se encontro si se pregunta por instalacion electrica
	gen luz_ch=.
	replace aguared_ch=1 if q3_11lig==1 
	replace aguared_ch=0 if q3_11lig==2 | q3_11lig==3  
	replace aguared_ch=. if q3_11lig==9
	

	*********
	*conbano_ch*
	*********
	gen conbano_ch=.
	replace conbano_ch= 1 if inlist(q3_9toil,1,2,3,4)
	replace conbano_ch= 0 if q3_9toil==5
 	replace conbano_ch=. if q3_9toil==9

	*********
	*des1_ch*
	*********
	gen des1_ch=.
	replace des1_ch=0 if q3_9toil==0
	replace des1_ch=1 if q3_9toil==1
	replace des1_ch=2 if q3_9toil==3
	replace des1_ch=. if q3_9toil==9
	
	*********
	*piso_ch*
	*********
	gen piso_ch=.

	*****************
	*banomejorado_ch*
	*****************
	gen banoalcantarillado_ch=0
	replace banoalcantarillado_ch =1 if q3_9toil == 1
 	

	**********
	*pared_ch*
	**********
	gen pared_ch=.
		replace pared_ch = 1 if q2_2wall == 3 | q2_2wall == 4
		replace pared_ch = 2 if q2_2wall == 1 | q2_2wall == 2 | q2_2wall == 5 | q2_2wall == 6
	    replace pared_ch=. if q2_2wall == 7 | q2_2wall == 9
	
	**********
	*techo_ch* 
	**********
	gen techo_ch=.
	replace techo_ch = 1 if q2_3roof <5
	replace techo_ch = 2 if q2_3roof ==5
	replace techo_ch = . if q2_3roof ==9
	
	**********
	*resid_ch*
	**********
	gen resid_ch=.
	cap confirm variable trash
	replace resid_ch=0  if q3_15gar >= 1 & q3_15gar <= 3
    replace resid_ch=1  if q3_15gar >= 4 & q3_15gar <= 5
    replace resid_ch=2  if q3_15gar >= 6 & q3_15gar <= 9
    replace resid_ch=3  if q3_15gar == 10
	replace resid_ch=.  if q3_15gar == 99
	
	
	*********
	*dorm_ch*
	*********
	gen dorm_ch=.
	replace dorm_ch=q3_4bedr
	replace dorm_ch=. if q3_4bedr==99
	
	************
	*cuartos_ch*
	************
	gen cuartos_ch=.
	replace cuartos_ch=q3_3room
	replace cuartos_ch=. if q3_3room==99

	***********
	*cocina_ch* 
	***********
	gen cocina_ch=.
	replace cocina_ch= 1 if q3_5kitc<=2
	replace cocina_ch = 0  if q3_5kitc == 3
	replace cocina_ch=. if q3_5kitc==9
	
	***********
	*telef_ch*
	***********
	gen telef_ch=.
	replace telef_ch=0 if q3_16tel == 4
	replace telef_ch=1 if q3_16tel >= 1 & q3_16tel <= 3
	replace telef_ch=. if q3_16tel == 9

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
	    replace compu_ch=0 if q3_17pc==2
		replace compu_ch=1 if q3_17pc==1
		replace compu_ch=. if q3_17pc==9

	*************
	*internet_ch*
	************* 
	gen internet_ch=.
	replace internet_ch=0 if q3_18int == 4
	replace internet_ch=1 if q3_18int >= 1 & q3_18int<=3
	replace internet_ch=. if q3_18int == 9 
	
	********
	*cel_ch*
	********
	gen cel_ch=.

	*************
	*viviprop_ch*
	*************
	gen viviprop_ch1=.
	replace viviprop_ch1=1 if q3_1tenu==1
	replace viviprop_ch1=0 if q3_1tenu!=1
	replace viviprop_ch1=. if q3_1tenu==9
	
	
**********************************************
***      VARIABLES DEL MERCADO LABORAL     ***
**********************************************	

     *******************
     ****condocup_ci****
     *******************
	 
    gen condocup_ci=.
    replace condocup_ci=1 if q5_1==1 | q5_2==1 | q5_3==1 | q5_4==1 | q5_4==2
    replace condocup_ci=2 if q5_1==2 & q5_2==2 & q5_3==2 & (q5_4==3 | q5_4==4)
    replace condocup_ci=3 if q5_1==2 & q5_2==2 & q5_3==2 & q5_4>=5
    replace condocup_ci=. if q5_1==2 & q5_2==2 & q5_3==2 & q5_4==99/*unkown/missing as missing*/ 
    replace condocup_ci=. if q5_1==. & q5_2==. & q5_3==. & q5_4==. /*NIU as missing*/
	
      ************
      ***emp_ci***
      ************
    gen emp_ci=.
	replace emp_ci=0 if condocup_ci==2 | condocup_ci==3
	replace emp_ci=1 if condocup_ci==1
	
	
      ****************
      ***desemp_ci***
      ****************	
	gen desemp_ci=.
	replace desemp_ci=1 if condocup_ci==2 /*1 desempleados*/
	replace desemp_ci=0 if condocup_ci==3 | condocup_ci==1 /*0 cuando están inactivos o empleados*/
	
      *************
      ***pea_ci***
      *************
    gen pea_ci=.
	replace pea_ci=1 if condocup_ci==1
	replace pea_ci=1 if condocup_ci==2
	replace pea_ci=0 if condocup_ci==3
	
     *************************
     ****rama de actividad****
     *************************
	 *2010 no tiene variable indgen
    gen rama_ci = . 
    replace rama_ci = 1 if q5_7==0
    replace rama_ci = 2 if q5_7==1  
    replace rama_ci = 3 if q5_7==2   
    replace rama_ci = 4 if q5_7==3      
    replace rama_ci = 5 if q5_7==4   
    replace rama_ci = 6 if q5_7==5   
    replace rama_ci = 7 if q5_7==6   
    replace rama_ci = 8 if q5_7==7   
    replace rama_ci = 9 if q5_7==8  
    replace rama_ci = 10 if q5_7==10   
    replace rama_ci = 11 if q5_7==9  
    replace rama_ci = 12 if q5_7==11 
    replace rama_ci = 13 if q5_7==12 
    replace rama_ci = 14 if q5_7==13    
    replace rama_ci = 15 if q5_7==14  
    replace rama_ci = . if q5_7>14  
	
     *********************
     ****categopri_ci****
     *********************
	 *OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.	


	gen categopri_ci=.
    replace categopri_ci=0 if q5_8==7
    replace categopri_ci=1 if q5_8==5
    replace categopri_ci=2 if q5_8==6
    replace categopri_ci=3 if q5_8==1 | q5_8==2 | q5_8==3
    replace categopri_ci=4 if q5_8==4
    replace categopri_ci=. if q5_8==9 | q5_8==9999 
	
	
      *****************
      ***spublico_ci***
      *****************
    gen spublico_ci=.
		replace spublico_ci=1 if q5_8==1
		replace spublico_ci=0 if q5_8!=1
	
**********************************
**** VARIABLES DE INGRESO ****
***********************************

	* This variable is categorical, so we replicate IPUMS methodology
	*  of assigning the midpoint of the intervals
	* Codes 1--7 are weekly salaries (multiply by 4.5)
	* Codes 8--14 are Monthly salaries
	* Codes 15--21 are Annual salaries (divide by 12)
   gen ylm_ci=.
   * weekly
   replace ylm_ci=(4070/2)*4.5 if q5_10==1
   replace ylm_ci=((5999-4070)/2)*4.5 if q5_10==2
   replace ylm_ci=((9999-6000)/2)*4.5 if q5_10==3
   replace ylm_ci=((19999-10000)/2)*4.5 if q5_10==4
   replace ylm_ci=((29999-20000)/2)*4.5 if q5_10==5
   replace ylm_ci=((59999-30000)/2)*4.5 if q5_10==6
   replace ylm_ci=60000*4.5 if q5_10==7
   * monthly
   replace ylm_ci=16280/2 if q5_10==8
   replace ylm_ci=(23999-16280)/2 if q5_10==9
   replace ylm_ci=(39999-24000)/2 if q5_10==10
   replace ylm_ci=(79999-40000)/2 if q5_10==11
   replace ylm_ci=(119999-80000)/2 if q5_10==12
   replace ylm_ci=(239999-120000)/2 if q5_10==13
   replace ylm_ci=240000 if q5_10==14
   * annual
   replace ylm_ci=(195360/2)/12 if q5_10==15
   replace ylm_ci=((287999-195360)/2)/12 if q5_10==16
   replace ylm_ci=((479999-288000)/2)/12 if q5_10==17
   replace ylm_ci=((959999-480000)/2)/12 if q5_10==18
   replace ylm_ci=((1439999-960000)/2)/12 if q5_10==19
   replace ylm_ci=((2879999-1440000)/2)/12 if q5_10==20
   replace ylm_ci=2880000/12 if q5_10==21
   
 
   gen ynlm_ci=.


*****************************************************
******* Variables specific for this census **********
*****************************************************


******************************************************
***           VARIABLES DE INGRESO                 ***
******************************************************

    ***********
	**ylm_ch*
	***********
   gen ylm_ch=.
   
    ***********
	**ynlm_ch*
	***********
   gen ynlm_ch=.
   
   
*******************************************************
***           VARIABLES DE EDUCACIÓN               ***
*******************************************************

*NOTA: Como terciario, universitario y posgrado tienen una duración variable se supone 
*que terciario completo implica 3 años de educacion adicional a la secundaria, universitario 5 años adicionales y 
*postgrado 7. Esto solo se basa en la modas de finalización de estos niveles. ESTO SE DEBE DISCUTIR 
	*********
	*aedu_ci* // años de educacion aprobados
	*********
	gen aedu_ci=.
	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********

	gen eduno_ci=.
	**********
	*edupre_ci* // preescolar
	**********
	gen edupre_ci=.
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci=.
	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci=.
	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci=.

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci=.

	**********
	*eduui_ci* // no completó la educación universitaria o terciaria
	**********
	gen eduui_ci=.
	**********
	*eduuc_ci* // completó la educación universitaria o terciaria
	**********
	gen eduuc_ci=.
	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci=. 

	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci=.

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci=.

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci=.
	***********
	*asiste_ci*
	***********
	gen asiste_ci=.
	replace asiste_ci=1 if q2_1==1
	replace asiste_ci=0 if q2_1==2

	************
	* literacy *
	************
	gen literacy=. 

	*****************************
	** Include all labels of   **
	**  harmonized variables   **
	*****************************

include "../Base/labels.do"

order region_BID_c region_c pais_c anio_c idh_ch idp_ci factor_ch factor_ci estrato_ci zona_c sexo_ci edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch condocup_ci emp_ci desemp_ci pea_ci rama_ci categopri_ci spublico_ci ylm_ci ynlm_ci ylm_ch ynlm_ch aedu_ci eduno_ci edupre_ci edupi_ci  edupc_ci  edusi_ci edusc_ci  eduui_ci eduuc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci asiste_ci literacy aguaentubada_ch aguared_ch aguafuente_ch aguadist_ch aguadisp1_ch aguadisp2_ch aguamide_ch bano_ch banoex_ch sinbano_ch luz_ch conbano_ch des1_ch piso_ch banoalcantarillado_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch migrante_ci migrantelac_ci migantiguo5_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci

compress

save "`base_out'", replace 
log close
