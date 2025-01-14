*******************************************
* SCL Data Ecosystem, 2021
* Armonización de Censos de Población IPUMS
*
* Este archivo define las variables que 
* son comunes a todos los países. 
* Incluya este archivo cuando armonice un
* nuevo censo para no tener que volver a
* definir estas variables.
*
* La definición de las variables en la
* armonización de censos intenta, siempre
* que sea posible, mantener la misma
* nomenclatura y metodología utilizada en
* la armonización de encuestas de hogares.
* Consultar los documentos de gobernanza
* D.1.1 y D.1.1.3.
*******************************************

global ruta = "${censusFolder}"  //cambiar ruta seleccionada 

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_IPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"
                                                    
capture log close
log using `"$log_file"' , replace  //agregar ,replace si ya está creado el log_file en tu carpeta

use "$base_in", clear


/*
if (`"`PAIS'"'=="VEN" & `"`ANO'"'=="2001") | (`"`PAIS'"'=="MEX" & `"`ANO'"'=="2015") | (`"`PAIS'"'=="PAN" & `"`ANO'"'=="2010") {

merge 1:1 country year sample serial pernum using "$ruta\\raw\\IPUMS_extravars_17Oct23.dta"
keep if _m==3
drop _m 

	foreach z in mx2015a_afrdes pa2010a_black ve2001a_indig {
		sum `z'
		if r(N)==0 {
			drop `z'
		}
	}
} */
			****************************
			*  VARIABLES DE DISENO     *
			****************************

	****************
	* region_BID_c *
	****************
	*CSC
		if  `"$PAIS"'=="ARG" |  `"$PAIS"' =="URY" |  `"$PAIS"' =="BRA" |  `"$PAIS"' =="PRY" |  `"$PAIS"' =="CHL" local reg_bid 4
	*CAN	
		if  `"$PAIS"' =="BOL" |  `"$PAIS"' =="COL" |  `"$PAIS"' =="ECU" |  `"$PAIS"' =="PER" |  `"$PAIS"' =="VEN" local reg_bid 3
		
	*CCB	
if  `"$PAIS"' =="BHS" |  `"$PAIS"' =="GUY" | `"$PAIS"' =="JAM" |  `"$PAIS"' =="SUR" |  `"$PAIS"' =="BRB" |  `"$PAIS"' =="TTO" local reg_bid 2
	
	*CID
		if  `"$PAIS"'=="BLZ" |  `"$PAIS"' =="CRI" |  `"$PAIS"' =="SLV" |  `"$PAIS"' =="GTM" |  `"$PAIS"' =="HTI" |  `"$PAIS"'=="HND" |  `"$PAIS"' =="PAN" | `"$PAIS"' =="MEX" |  `"$PAIS"' =="DOM" |  `"$PAIS"'=="NIC" local reg_bid 1

		
	gen region_BID_c=`reg_bid'
	
	*\eliminar _00000*\
	capture drop __00000
	
	*********
	*pais_c*
	*********
    gen pais_c=`"$PAIS"'
	
	*********
	*anio_c*
	*********
	rename year anio_c
	
	******************
    *idh_ch (id hogar)*
    ******************
    gen idh_ch =serial 
	tostring idh_ch, replace
	
	******************
    *idp_ci (idpersonas)*
    ******************
	egen idp_ci = concat(idh_ch pernum)
	tostring idp_ci , replace
	
	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
	rename perwt factor_ci
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
	rename hhwt factor_ch
		
	*****
	*UPM*
	*****	
	gen upm =.
	
	***********
	* estrato *
	***********
	gen byte estrato_ci=.
	cap confirm variable strata
	if (_rc==0) {
	replace estrato_ci=strata 
	}

	***************************
	* Zona urbana (1) o rural (0)
	***************************
	gen byte zona_c=.
	cap confirm variable urban
	if (_rc==0) {
	replace urban = urban-1
	replace zona_c=urban
	}
	

*********************************************
***         VARIABLES DEMOGRAFICAS        ***
*********************************************
	
	*********
	*sexo_c*
	*********
	rename sex sexo_ci
	replace sexo_ci = . if sexo_ci == 9
	
	*********
	*edad_c*
	*********
	rename age edad_ci
	replace edad_ci=. if edad_ci==999 /* age=999 corresponde a "unknown" */
	replace edad_ci=98 if edad_ci>=98  /* age=100 corresponde a 100+ */

 	*************
	*relacion_ci*
	*************	
	gen byte relacion_ci=1 if related==1000
    replace relacion_ci=2 if related>=2000 & related<3000
    replace relacion_ci=3 if related>=3000 & related <4000
    replace relacion_ci=4 if related>=4000 & related <5000
    replace relacion_ci=5 if (related>=5000 & related <5200) | (related>5210 & related <=6000) | related == 5900
    replace relacion_ci=6 if related==5210 
	replace relacion_ci=. if related==9999
	
	**************
	*Estado Civil*
	**************
	*2010 no tiene variable marst
	gen byte civil_ci=.
	cap confirm variable marst
	if (_rc==0) {
	replace civil_ci=marst 
	replace civil_ci=. if marst==9
}
	
    *********
	*jefe_ci*
	*********
	gen byte jefe_ci=(relate==1)
	replace jefe_ci=. if related == 9999
	
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
	*NOTA: se utiliza la variable related la cual tiene más desagregación en cuanto a la relación con el jefe de hogar
	tab related, nol
	by idh_ch, sort: egen nempdom_ch=sum(related==5210) if relacion_ci==6	  

	************
	*miembros_ci
	************
	gen miembros_ci=(relacion_ci>=1 & relacion_ci<9) 
	tab persons
	tab miembros_ci	
	
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
	
	*********
	*afro_ch*
	*********
	gen byte afro_ch=.
	
	********
	*ind_ch*
	********	
	gen byte ind_ch=.
	
	**************
	*noafroind_ch*
	**************
	gen byte noafroind_ch =.
	
	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 

	
**********************************
*** 4. Migración (3 variables) ***
**********************************	

    *******************
    ****migrante_ci****
    *******************
	gen byte migrante_ci =.
	cap confirm variable nativity 
	if(_rc==0){
	replace migrante_ci = 1 if nativity == 2
	replace migrante_ci = 0 if nativity == 1 
	}
   
	/*******************
    **migantiguo5_ci***
    *******************
	gen migantiguo5_ci =.
	cap confirm variable migrate5
	if(_rc==0){
	replace migantiguo5_ci = 1 if inlist(migrate5, 10, 11, 12, 20) & migrante_ci == 1
	replace migantiguo5_ci = 0 if (migrate5 == 30 & migrante_ci == 1) | migrante_ci == 0
	}
	cap confirm variable migyrs1
	if(_rc==0){
	replace migantiguo5_ci = 1 if migyrs1 >= 5 & migrante_ci == 1
	replace migantiguo5_ci = 0 if (migyrs1 < 5 & migrante_ci == 1) | migrante_ci == 0
	}
	
	
	**********************
	*** migrantelac_ci ***
	**********************

	gen migrantelac_ci = .
	cap confirm variable bplcountry
	if(_rc==0){
	replace migrantelac_ci= 1 if inlist(bplcountry, 21050, 21080, 21100, 21130, 21140, 21180, 21250, 22010, 22020, 22030, 22040, 22050, 22060, 22070, 22080, 23010, 23020, 23030, 23040, 23050, 23060, 23090, 23100, 23110, 23120, 23130, 23140) & migrante_ci == 1
	replace migrantelac_ci = 0 if migrantelac_ci == . & migrante_ci == 1 | migrante_ci == 0
	}
	*/
	
	*******************
    **migrantiguo5_ci**
    *******************
	gen byte migrantiguo5_ci =.
	cap confirm variable migrate5
	if(_rc==0){
	replace migrantiguo5_ci = 1 if inlist(migrate5, 10, 11, 12, 20) & migrante_ci == 1
	replace migrantiguo5_ci = 0 if (migrate5 == 30 & migrante_ci == 1)
	}
	cap confirm variable migyrs1
	if(_rc==0){
	replace migrantiguo5_ci = 1 if migyrs1 >= 5 & migrante_ci == 1
	replace migrantiguo5_ci = 0 if (migyrs1 < 5 & migrante_ci == 1)
	}
	
	**********************
	****** miglac_ci *****
	**********************

	gen byte  miglac_ci = .
	cap confirm variable bplcountry
	if(_rc==0){
	replace miglac_ci= 1 if inlist(bplcountry, 21050, 21080, 21100, 21130, 21140, 21180, 21250, 22010, 22020, 22030, 22040, 22050, 22060, 22070, 22080, 23010, 23020, 23030, 23040, 23050, 23060, 23090, 23100, 23110, 23120, 23130, 23140) & migrante_ci == 1
	replace miglac_ci = 0 if migrantelac_ci != 1 & migrante_ci == 1 
	}
  
  
****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************

    *******************
    ****condocup_ci****
    ******************* 
    gen byte condocup_ci=.
	cap confirm variable empstat
	if (_rc==0){
    replace condocup_ci=1 if empstat==1
    replace condocup_ci=2 if empstat==2
    replace condocup_ci=3 if empstat==3
    replace condocup_ci=. if empstat==9 /*unkown/missing as missing*/ 
    replace condocup_ci=. if empstat==0 /*NIU as missing*/
	}
	
    ************
    ***emp_ci***
    ************
    gen byte emp_ci=.
	cap confirm variable empstat
	if (_rc==0){
		replace emp_ci=0 if empstat==2
		replace emp_ci=0 if empstat==3
		replace emp_ci=1 if empstat==1
		replace emp_ci=. if empstat==0 /*NIU as missing*/
		replace emp_ci=. if empstat==9 /*unkown/missing as missing*/
	}
	
	
    ****************
    ***desemp_ci***
    ****************	
	gen byte desemp_ci=.
	cap confirm variable condocup_ci
	if (_rc==0){
		replace desemp_ci=1 if condocup_ci==2 /*1 desempleados*/
		replace desemp_ci=0 if condocup_ci==3 | condocup_ci==1 /*0 cuando están inactivos o empleados*/
	}
	
    *************
    ***pea_ci***
    *************
    gen byte pea_ci=.
	cap confirm variable condocup_ci
	if (_rc==0){
		replace pea_ci=1 if condocup_ci==1
		replace pea_ci=1 if condocup_ci==2
		replace pea_ci=0 if condocup_ci==3
	}
	
    **********
    *rama_ci**
    **********
	*2010 no tiene variable indgen
    gen byte rama_ci = . 
	cap confirm variable indgen 
	if (_rc==0) {
    replace rama_ci = 1 if indgen==10
    replace rama_ci = 2 if indgen==20  
    replace rama_ci = 3 if indgen==30   
    replace rama_ci = 4 if indgen==40    
    replace rama_ci = 5 if indgen==50    
    replace rama_ci = 6 if indgen==60    
    replace rama_ci = 7 if indgen==70    
    replace rama_ci = 8 if indgen==80    
    replace rama_ci = 9 if indgen==90
    replace rama_ci = 10 if indgen==100  
    replace rama_ci = 11 if indgen==111  
    replace rama_ci = 12 if indgen==112
    replace rama_ci = 13 if indgen==113 
    replace rama_ci = 14 if indgen==114 
    replace rama_ci = 15 if indgen==120 
	}
	
    *********************
    ****categopri_ci****
    *********************
	*OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.	
    gen byte categopri_ci=.
	cap confirm variable classwkd
	if (_rc==0) {
    replace categopri_ci=0 if classwkd==400 | classwkd == 150 | classwkd == 130
    replace categopri_ci=1 if classwkd==110 | classwkd == 111
    replace categopri_ci=2 if classwkd>=120 & classwkd<= 126 | classwkd == 141 | classwkd == 100 | classwkd == 101 | classwkd == 102 | classwkd == 199
    replace categopri_ci=3 if classwkd>=200 & classwkd <300 | classwkd == 142
    replace categopri_ci=4 if classwkd>=300 & classwkd <400
	}
	
      *****************
      ***spublico_ci***
      *****************
    gen byte spublico_ci=.
	cap confirm variable indgen
	if (_rc==0){
		replace spublico_ci=1 if indgen==100
		replace spublico_ci=0 if emp_ci==1 & indgen!=100
		replace spublico_ci=. if indgen == 998 | indgen == 999 | indgen == 000
	}

   
**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************	
		
	********
	*luz_ch*
	********
	*En la nueva encuesta no se encontro si se pregunta por instalacion electrica
	gen byte luz_ch=.
	cap confirm variable electric
	if (_rc==0) {
	 replace luz_ch = 0 if electric== 2
	 replace luz_ch = 1 if electric== 1
	 replace luz_ch=. if electric==9
	}

	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
 	cap confirm variable floor
	if (_rc==0) {
	replace piso_ch=0 if floor==100
	replace piso_ch=1 if (floor>100 & floor<=120)
	replace piso_ch=2 if floor>=200 & floor<999
	replace piso_ch=. if floor==999
	}
	
	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	cap confirm variable wall
	if (_rc==0) {
		replace pared_ch = 0 if wall == 100
		replace pared_ch = 1 if wall>100 & wall<500
	    replace pared_ch= 2 if wall>=500 & wall<=600
		replace pared_ch=. if wall==999
	}

	**********
	*techo_ch*
	**********
	gen byte techo_ch=.
	cap confirm variable roof
	if (_rc==0) {
    replace techo_ch=0  if roof == 90
	replace techo_ch=1 if roof>=10 & roof<70
	replace techo_ch=2 if roof>=70 & roof<=80
	}
	
	**********
	*resid_ch*
	**********
	gen byte resid_ch=.
	cap confirm variable trash
	if (_rc==0) {
	replace resid_ch=0  if trash >= 10 | trash <= 14
    replace resid_ch=1  if trash == 21 |trash == 22 | trash == 23
	replace resid_ch=2  if trash >= 24 & trash <= 34
	replace resid_ch=3  if trash>= 35 & trash <= 39
	replace resid_ch=.  if trash == 99
	}
	
	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=.
	cap confirm variable bedrooms
	if (_rc==0) {
	replace dorm_ch=bedrooms 
	replace dorm_ch=. if bedrooms==99 | bedrooms==98
	}
	
	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=.
	cap confirm variable rooms
	if (_rc==0) {
	replace cuartos_ch=rooms
	replace cuartos_ch=. if rooms==99 | rooms==98
	}

	***********
	*cocina_ch*
	***********
	gen byte cocina_ch=.
	cap confirm variable kitchen
	if (_rc==0) {
	replace cocina_ch= 1 if kitchen>=20 & kitchen<=28
	replace cocina_ch = 0  if kitchen >= 10 & kitchen<=13
	replace cocina_ch=. if kitchen==99
	}
	
	***********
	*telef_ch*
	***********
	gen byte telef_ch=.
	cap confirm variable phone
	if (_rc==0) {
	replace telef_ch=0 if phone == 1	
	replace telef_ch=1 if phone == 2
	replace telef_ch=. if phone == 9 | phone==0
	}

	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=.
	cap confirm variable refrig
	if (_rc==0) {
	replace refrig_ch=0 if refrig==1
	replace refrig_ch=1 if refrig==2
	replace refrig_ch=. if refrig==9
	}

	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	cap confirm variable autos
	if (_rc==0) {
	replace auto_ch= 1 if autos>0 & autos<8
	replace auto_ch= 0 if autos==0
	replace auto_ch=. if autos==8 | autos==9
	}
	
	********
	*compu_ch*
	********
	gen byte compu_ch=.
	cap confirm variable computer
	if (_rc==0) {
	    replace compu_ch=0 if computer==1
		replace compu_ch=1 if computer==2
		replace compu_ch=. if computer==9
	}

	*************
	*internet_ch*
	************* 
	*pendiente esta variable no es lo que queremos generar
	gen byte internet_ch=.
	cap confirm variable internet
	if (_rc==0) {
	replace internet_ch=0 if internet == 1
	replace internet_ch=1 if internet == 2
	replace internet_ch=. if internet == 9 
	}
	
	********
	*cel_ch*
	********
	gen byte cel_ch=.
	cap confirm variable cell
	if (_rc==0) {
	replace cel_ch=0 if cell == 1	
	replace cel_ch=1 if cell == 2
	replace cel_ch=. if cell == 9 | cell==0
	}

	*************
	*viviprop_ch*
	*************
	*NOTA: aqui se genera una variable parecida, pues no se puede saber si es propia total o parcialmente pagada
	gen byte viviprop_ch=.
	cap confirm variable ownership
	if (_rc==0) {
	replace viviprop_ch=0 if ownership==2
	replace viviprop_ch=1 if ownership==1
	*replace viviprop_ch1=3 if 
	replace viviprop_ch=. if ownership==9
	}

***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	*****************
	*aguaentubada_ch*
	*****************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch = 1 if watsup inrange(10,17)
	replace aguaentubada_ch = 0 if watsup inrange(18,20)
	
	************
	*aguared_ch*
	************
	gen byte aguared_ch=.

	
	***************
	*aguafuente_ch*
	***************
	gen byte aguafuente_ch=.
	replace aguafuente_ch = 2 if watsup ==17 | watsup == 18
	replace aguafuente_ch = 6 if inrange(watsup,10,16) | inrange(watsup,20,99)
	
	**************
	*aguadist_ch*
	**************
	gen byte aguadist_ch =.
	replace aguadist_ch =1 uf watsup == 11
	replace aguadist_ch =2 if watsup inrange(14,16)
	replace aguadist_ch =3 if watsup inrange(17,18)
	replace aguadist_ch =0 if watsup inrange(20,99)
	
	**************
	*aguadisp1_ch*
	**************
	gen byte aguadisp1_ch = .
	
	**************
	*aguadisp2_ch*
	**************
	gen byte aguadisp2_ch = .	

	*************
	*aguamide_ch*
	*************
	gen byte aguamide_ch = .
	
	*********
	*bano_ch*
	*********
	gen bano_ch=.
	gen des1_ch=.
	cap confirm variable toilet
	if (_rc==0) {
		replace bano_ch= 0 if toilet==10 & bathrooms ==00
		replace bano_ch= 1 if toilet==21 & sewage==11 
		replace bano_ch= 2 if toilet==21 & sewage==12
		replace bano_ch= 3 if toilet==22 & (sewage ==12 | sewage ==10)
		replace bano_ch= 6 if inrange(toilet, 20,99) & (sewage == 20 | sewage ==99)
	}
	
	***********
	*banoex_ch*
	***********
	gen byte banoex_ch = .

	************
	*sinbano_ch*
	************
	gen byte sinbano_ch =.
	replace sinbano_ch = 3 if toilet ==10
	replace sinbano_ch = 0 if inrange(toilet, 11,23)

	************
	*conbano_ch*
	************
	gen byte conbano_ch=.
	replace conbano_ch = 1 if inrange(toilet, 11,23)
	replace conbano_ch = 0 if if toilet ==10			
	*****************
	*banoalcantarillado_ch*
	*****************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch =1 if sewage ==11
	replace banoalcantarillado_ch =0 if inrange(sewage, 12,20)
	
	*****************
	*banomejorado_ch*
	*****************
	gen banomejorado_ch=.
	replace banomejorado_ch =1 if inrange(bano_ch, 1,3)
	replace banomejorado_ch =2 if bano_ch ==6
	replace banomejorado_ch =0 if bano_ch ==0
 	
	
	/*********
	*des1_ch*
	*********
	replace des1_ch=0 if bano_ch==0
	replace des1_ch=1 if toilet==21
	replace des1_ch=2 if toilet==22
	replace des1_ch=. if toilet==99
	
	
*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	

	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen ${PAIS}_m_pared_ch =.
	cap confirm variable wall
	if (_rc==0) {
	    replace  ${PAIS}_m_pared_ch = wall
	}
	label var ${PAIS}_m_pared_ch  "Material de las paredes según el censo del país - variable original"

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen ${PAIS}_m_piso_ch =.
	cap confirm variable wall
	if (_rc==0) {
	    replace  ${PAIS}_m_piso_ch = wall
	}
	label var ${PAIS}_m_piso_ch  "Material de los pisos según el censo del país - variable original"
	
	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen ${PAIS}_m_techo_ch =.
	cap confirm variable roof
	if (_rc==0) {
	    replace  ${PAIS}_m_piso_ch = roof
	}
	label var ${PAIS}_m_techo_ch  "Material del techo según el censo del país - variable original"
	
	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long ${PAIS}_ingreso_ci = .
	label var ${PAIS}_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long ${PAIS}_ingresolab_ci = .	
	label var ${PAIS}_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte ${PAIS}_dis_ci = .
	label var ${PAIS}_dis_ci  "Individuos con discapacidad según el censo del país - variable original"
	

 
