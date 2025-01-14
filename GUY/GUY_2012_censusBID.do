* (Versión Stata 17)
/*==============================================================================
							CENSOS POBLACIONALES
						   Script de armonización
País: GUYANA
Año: 2012
Autores: Agustina Thailinger  
Última versión: 30JUN2022
División: SCL/EDU - IADB
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
global PAIS GUY    				 //cambiar
global ANIO 2012 				 //cambiar

global base_in  = "$ruta\\raw\\$PAIS\\$ANIO\\data_orig\\${PAIS}_${ANIO}_NOIPUMS.dta"
global base_out = "$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.dta"
global log_file ="$ruta\\clean\\$PAIS\\${PAIS}_${ANIO}_censusBID.log"                                                   
capture log close
log using "$log_file"  //agregar ,replace si ya está creado el log_file en tu carpeta

use "$base_in", clear

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
	gen byte region_BID_c=2
	label var region_BID_c "Regiones BID"
	label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
	label value region_BID_c region_BID_c

	**********
	*region_c*
	**********
	gen byte region_c=.   
	replace region_c=1  if regno=="01"
	replace region_c=2  if regno=="02"
	replace region_c=3  if regno=="03"
	replace region_c=4  if regno=="04"
	replace region_c=5  if regno=="05"
	replace region_c=6  if regno=="06"
	replace region_c=7  if regno=="07"
	replace region_c=8  if regno=="08"
	replace region_c=9  if regno=="09"
	replace region_c=10 if regno=="10"
	   
	label value region_c region_c
	label var region_c "division politico-administrativa, provincias"

	**********
	*geolev1*
	**********
	gen long geolev1=.   
	replace geolev1=328001  if regno=="01"
	replace geolev1=328002  if regno=="02"
	replace geolev1=328003  if regno=="03"
	replace geolev1=328004  if regno=="04"
	replace geolev1=328005  if regno=="05"
	replace geolev1=328006  if regno=="06"
	replace geolev1=328007  if regno=="07"
	replace geolev1=328008  if regno=="08"
	replace geolev1=328009  if regno=="09"
	replace geolev1=328010 if regno=="10"
	   
	label value geolev1 geolev1
	label var geolev1 "division politico-administrativa, provincias 6 dígitos"

	********
	*pais_c*
	********
	gen pais_c="GUY"

	********
	*anio_c*
	********
	gen int anio_c=2012

	********
	*idh_ch*
	********	
	tostring serialno, gen(idh_ch)

	********
	*idp_ci*
	********
	gen idp_ci=""

	***********
	*factor_ci*
	***********
	gen byte factor_ci=.

	***********
	*factor_ch*
	***********
	gen byte factor_ch=.

	***********
	*estrato_ch*
	***********
	gen byte estrato_ci=.

	********
	*zona_c*
	********		
	gen byte zona_c=.

		
************************************
*** 2. Demografía (18 variables) ***
************************************

	*********
	*sexo_ci*
	*********
	gen byte sexo_ci=1 if p12==1
	replace sexo_ci=2 if p12==2

	*********
	*edad_ci*
	*********
	gen int edad_ci=p13age2
	replace edad_ci=. if edad_ci==999 // age=999 corresponde a "unknown"
	replace edad_ci=98 if edad_ci>=98

	*************
	*relacion_ci*
	*************
	gen byte relacion_ci=1 if p11==1
	replace relacion_ci=2 if p11==2
	replace relacion_ci=3 if p11==3 | p11==4 
	replace relacion_ci=4 if p11==5 | p11==6 | p11==7 | p11==8
	replace relacion_ci=5 if p11==9 | p11==10

	**********
	*civil_ci*
	**********
	gen byte civil_ci=1 if p61==1
	replace civil_ci=2 if p61==2
	replace civil_ci=3 if p61==3 | p61==5
	replace civil_ci=4 if p61==4
	replace civil_ci=9 if p61==0

	*********
	*jefe_ci*
	*********
	gen byte jefe_ci=(relacion_ci==1)
	replace jefe_ci=. if relacion_ci==.

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
	egen byte nmenor6_ch=sum((relacion_ci>0 & relacion_ci<=4) & (edad_ci<6)), by(idh_ch) 

	************
	*nmenor1_ch*
	************
	egen byte nmenor1_ch=sum((relacion_ci>0 & relacion_ci<=4) & (edad_ci<1)), by(idh_ch) 


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
	
	************
	*afroind_ci*
	************
	gen byte afroind_ci=.
	replace afroind_ci=1 if p14==2 // Amerindian
	replace afroind_ci=2 if p14==1 // African/Black
	replace afroind_ci=3 if (p14==3 | p14==4 | p14==5 | p14==6 | p14==7 | p14==8)  // Others

	*********
	*afro_ch*
	*********
	gen byte afro_jefe =.

	********
	*ind_ch*
	********	
	gen byte ind_jefe =.

	**************
	*noafroind_ch*
	**************
	gen byte noafroind_jefe =.
	
	************
	*afroind_ch*
	************
	gen byte afroind_jefe=afroind_ci if p11==1
	egen afroind_ch=min(afroind_jefe), by(idh_ch)
	drop afroind_jefe 

	********
	*dis_ci*
	********
	gen byte dis_ci=1 if p21==1

	**********
	*disWG_ci*
	**********
	gen byte disWG_ci=. 
	
	********
	*dis_ch*
	********
	egen dis_ch=min(dis_ci), by(idh_ch)

**********************************
*** 4. Migración (3 variables) ***
**********************************

	*************
	*migrante_ci*
	*************
	gen byte migrante_ci=.
	replace migrante_ci=1 if p31==1
	replace migrante_ci=0 if p31==2

	*****************
	*migrantiguo5_ci*
	*****************
	gen byte migrantiguo5_ci=.
	replace migrantiguo5_ci=1 if (p34<=2008 & migrante_ci==1)
	replace migrantiguo5_ci=0 if migantiguo5_ci!=1 & migrante_ci==1
	
	***********
	*miglac_ci*
	***********
	gen byte miglac_ci=.
	replace miglac_ci=1 if p33cntry=="ARG" | p33cntry=="BHS" | p33cntry=="BRB" | p33cntry=="BLZ" | p33cntry=="BOL" | p33cntry=="BRA" | p33cntry=="CHL" | p33cntry=="COL" | p33cntry=="CRI" | p33cntry=="DOM" | p33cntry=="ECU" | p33cntry=="SLV" | p33cntry=="GTM" | p33cntry=="HTI" | p33cntry=="HND" | p33cntry=="JAM" | p33cntry=="MEX" | p33cntry=="NIC" | p33cntry=="PAN" | p33cntry=="PRY" | p33cntry=="PER" | p33cntry=="SUR" | p33cntry=="TTO" | p33cntry=="URY" | p33cntry=="VEN" 
	replace miglac_ci=0 if migrantelac_ci!=1 & migrante_ci==1 


***********************************
*** 5. Educación (13 variables) ***
***********************************

	*********
	*aedu_ci* // años de educacion aprobados
	*********
	gen byte aedu_ci=.

	*Usamos p44: what class did you complete?
	replace aedu_ci=0  if p44==1  // not stated, none
	replace aedu_ci=1 if p44==2  // prep A & B/ Grds 1 & 2
	replace aedu_ci=3  if p44==3  // std 1/ grd 3
	replace aedu_ci=4  if p44==4  // std 2/ grd 4
	replace aedu_ci=5  if p44==5  // std 3/ grd 5
	replace aedu_ci=6  if p44==6  // std 4/ grd 6
	replace aedu_ci=7  if p44==7  // frm 1/ grd 7
	replace aedu_ci=8  if p44==8  // frm 2/ grd 8
	replace aedu_ci=9  if p44==9  // frm 3/ grd 9
	replace aedu_ci=10 if p44==10 // frm 4/ grd 10
	replace aedu_ci=11 if p44==11 // frm 5/ grd 11
	replace aedu_ci=12 if p44==12 // frm 6/ grd 12
	replace aedu_ci=13 if p44tetyr==1 & aedu_ci==. // post secondary/ tertiary/ university
	replace aedu_ci=14 if p44tetyr==2 & aedu_ci==. // post secondary/ tertiary/ university
	replace aedu_ci=15 if p44tetyr==3 & aedu_ci==. // post secondary/ tertiary/ university
	replace aedu_ci=16 if p44tetyr==4 & aedu_ci==. // post secondary/ tertiary/ university
	replace aedu_ci=17 if p44tetyr==5 & aedu_ci==. // post secondary/ tertiary/ university
	replace aedu_ci=18 if p44tetyr==6 & aedu_ci==. // post secondary/ tertiary/ university

	*Imputacion
	replace aedu_ci=13 if p44==13 & p44tetyr==. & aedu_ci==.

	replace aedu_ci=0 if (p43==1 | p43==2) & aedu_ci==.
	replace aedu_ci=6 if p43==3 & aedu_ci==.
	replace aedu_ci=11 if (p43==4 | p43==5) & aedu_ci==.

	replace aedu_ci=0 if (p42==1 | p42==2 | p42==3 | p42==4) & aedu_ci==. 
	replace aedu_ci=6 if p42==5 & aedu_ci==. 
	replace aedu_ci=11 if p42==6 & aedu_ci==.
	replace aedu_ci=0 if p42==7 & aedu_ci==.
	replace aedu_ci=11 if p42==12 & aedu_ci==.

	replace aedu_ci=0 if p44==0 & p43==0 & p42==0 & aedu_ci==.

	label var aedu_ci "Años de educacion aprobados"

	**********
	*eduno_ci*
	**********
	gen byte eduno_ci=(aedu_ci==0)
	replace eduno_ci=. if aedu_ci==.
	label variable eduno_ci "Cero anios de educacion"
		
	**********
	*edupi_ci*
	**********
	gen byte edupi_ci=(aedu_ci>0 & aedu_ci<6)
	replace edupi_ci=. if aedu_ci==.
	label variable edupi_ci "Primaria incompleta"

	********** 
	*edupc_ci*
	**********
	gen byte edupc_ci=aedu_ci==6
	replace edupc_ci=. if aedu_ci==.
	label variable edupc_ci "Primaria completa"

	**********
	*edusi_ci*
	**********
	gen byte edusi_ci=(aedu_ci>6 & aedu_ci<11) 
	replace edusi_ci=. if aedu_ci==.
	label variable edusi_ci "Secundaria incompleta"

	**********
	*edusc_ci*
	**********
	gen byte edusc_ci=(aedu_ci==11) 
	replace edusc_ci=. if aedu_ci==.
	label variable edusc_ci "Secundaria completa"

	***********
	*edus1i_ci*
	***********
	gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
	replace edus1i_ci=. if aedu_ci==.

	***********
	*edus1c_ci*
	***********
	gen byte edus1c_ci=(aedu_ci==9)
	replace edus1c_ci=. if aedu_ci==.

	***********
	*edus2i_ci*
	***********
	gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<11)
	replace edus2i_ci=. if aedu_ci==.

	***********
	*edus2c_ci*
	***********
	gen byte edus2c_ci=(aedu_ci==11)
	replace edus2c_ci=. if aedu_ci==. 

	***********
	*edupre_ci*
	***********
	gen byte edupre_ci=.

	***********
	*asiste_ci*
	***********
	gen byte asiste_ci=.
	replace asiste_ci=1 if (p41==1 | p41==2)
	replace asiste_ci=0 if p41==3
	replace asiste_ci=. if p41==0 | p41==5
	
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
	replace condocup_ci=1 if p81==1 | p81==2
	replace condocup_ci=2 if p81==3 | p81==4
	replace condocup_ci=3 if p81==5 | p81==6 | p81==7 | p81==8 | p81==9
	replace condocup_ci=. if p81==10 | p81==32 | p81==0
									
	********
	*emp_ci*
	********
	gen byte emp_ci=.
	replace emp_ci=0 if condocup_ci==2 | condocup_ci==3
	replace emp_ci=1 if condocup_ci==1

	***********
	*desemp_ci*
	***********	
	gen byte desemp_ci=.
	replace desemp_ci=1 if condocup_ci==2
	replace desemp_ci=0 if condocup_ci==1 | condocup_ci==3

	********
	*pea_ci*
	********
	gen byte pea_ci=.
	replace pea_ci=1 if condocup_ci==1
	replace pea_ci=1 if condocup_ci==2
	replace pea_ci=0 if condocup_ci==3

	*********
	*rama_ci*
	*********

	/*
	IPUMS vs. GUY CENSUS

	NIU (not in universe)
	Agriculture, fishing, and forestry               vs. Agriculture, Forestry and Fishing
	Mining and extraction                            vs. Mining and Quarrying
	Manufacturing                                    vs. Manufacturing
	Electricity, gas, water and waste management     vs. Electricity, Gas, Steam and Air Conditioning Supply + Water Supply; Sewerage, Waste
														 Management and Remediation Activities
	Construction                                     vs. Construction
	Wholesale and retail trade                       vs. Wholesale and Retail Trade; Repair of Motor Vehicles and Motorcycles
	Hotels and restaurants                           vs. Accommodation and Food Service Activities
	Transportation, storage, and communications      vs. Transportation and Storage + Information and Communication
	Financial services and insurance                 vs. Financial and Insurance Activities
	Public administration and defense                vs. Public Administration and Defence; Compulsory Social Security
	Services, not specified
	Business services and real estate                vs. Real Estate Activities + Professional, Scientific and Technical Activities +
														 Administrative and Support Service Activities
	Education                                        vs. Education
	Health and social work                           vs. Human Health and Social Work Activities
	Other services                                   vs. Arts, Entertainment and Recreation + Activities of Households as Employers; Undifferentiated
														 Goods - and Services - Producing Activities of Households for Own Use + Activities of
														 Extraterritorial Organizations and Bodies + Other Service Activities
	Private household services
	Other industry, n.e.c.
	Response suppressed
	Unknown
	*/

	replace p89=trim(p89)
	replace p89=subinstr(p89," ","",.)
	gen byte notnumeric=real(p89)==.
	replace p89="" if notnumeric==1
	drop notnumeric

	gen p89_rama=substr(p89, 1,2)

	replace p89_rama="01" if p89=="001"
	replace p89_rama="07" if p89=="007"
	replace p89_rama="03" if p89=="33"
	replace p89_rama="03" if p89=="331"
	replace p89_rama="03" if p89=="332"
	replace p89_rama="03" if p89=="333"
	replace p89_rama="03" if p89=="34"
	replace p89_rama="03" if p89=="341"
	replace p89_rama="03" if p89=="342"

	gen byte rama_ci=.
	replace rama_ci=1  if p89_rama=="01" | p89_rama=="02" | p89_rama=="03"
	replace rama_ci=2  if p89_rama=="05" | p89_rama=="06" | p89_rama=="07" | p89_rama=="08" | p89_rama=="09"
	replace rama_ci=3  if p89_rama=="10" | p89_rama=="11" | p89_rama=="12" | p89_rama=="13"  | p89_rama=="14" | p89_rama=="15" | p89_rama=="16" | p89_rama=="17" | p89_rama=="18" | p89_rama=="19" | p89_rama=="20" | p89_rama=="21" | p89_rama=="22" | p89_rama=="23" | p89_rama=="24" | p89_rama=="25" | p89_rama=="26" | p89_rama=="27" | p89_rama=="28" | p89_rama=="29" | p89_rama=="30" | p89_rama=="31" | p89_rama=="32" 
	replace rama_ci=4  if p89_rama=="35" | p89_rama=="36" | p89_rama=="37" | p89_rama=="38" | p89_rama=="39"  
	replace rama_ci=5  if p89_rama=="41" | p89_rama=="42" | p89_rama=="43" 
	replace rama_ci=6  if p89_rama=="45" | p89_rama=="46" | p89_rama=="47"
	replace rama_ci=7  if p89_rama=="55" | p89_rama=="56"
	replace rama_ci=8  if p89_rama=="49" | p89_rama=="50" | p89_rama=="51" | p89_rama=="52" | p89_rama=="53" | p89_rama=="58" | p89_rama=="59" | p89_rama=="60" | p89_rama=="61" | p89_rama=="62" | p89_rama=="63"
	replace rama_ci=9  if p89_rama=="64" | p89_rama=="65" | p89_rama=="66"
	replace rama_ci=10 if p89_rama=="84"
	replace rama_ci=12 if p89_rama=="68" | p89_rama=="69" | p89_rama=="70" | p89_rama=="71" | p89_rama=="72" | p89_rama=="73" | p89_rama=="74" | p89_rama=="75" | p89_rama=="77" | p89_rama=="78" | p89_rama=="79" | p89_rama=="80" | p89_rama=="81" | p89_rama=="82"
	replace rama_ci=13 if p89_rama=="85"
	replace rama_ci=14 if p89_rama=="86" | p89_rama=="87" | p89_rama=="88"
	replace rama_ci=15 if p89_rama=="90" | p89_rama=="91" | p89_rama=="92" | p89_rama=="93" | p89_rama=="94" | p89_rama=="95" | p89_rama=="96" | p89_rama=="97" | p89_rama=="98" | p89_rama=="99"
	replace rama_ci=. if p89=="999" | p89=="00"

	**************
	*categopri_ci*
	**************
	gen byte categopri_ci=.
	replace categopri_ci=0 if p87==8 | p87==9
	replace categopri_ci=1 if p87==5
	replace categopri_ci=2 if p87==6
	replace categopri_ci=3 if p87>=1 & p87<=4
	replace categopri_ci=4 if p87==7
	replace categopri_ci=. if p87==0
					
	*************
	*spublico_ci*
	*************
	gen byte spublico_ci=.
													
													**********************************************************
***  7.1 Vivienda - variables generales (15 variables) ***
**********************************************************	

	********
	*luz_ch*
	********
	gen byte luz_ch=.
	replace luz_ch=0 if h42==1 | h42==2 | h42==5 // gas lantern, kerosene, solar/inverter
	replace luz_ch=1 if h42==3 | h42==4
	replace luz_ch=. if h42==6
			
	*********
	*piso_ch*
	*********
	gen byte piso_ch=.
	replace piso_ch=. if h45==7
		
	**********
	*pared_ch*
	**********
	gen byte pared_ch=.
	replace pared_ch=1 if h12==1 | h12==6 | h12==5 // wood, makeshift, adobe and palm
	replace pared_ch=2 if h12==2 | h12==3 | h12==4 | h12==7 | h12==8 | h12==9 | h12==10 // concrete, wood and concrete, stone, brick only, stone and brick, galvanize, wood and brick
	replace pared_ch=. if h12==11

	**********
	*techo_ch*
	**********
	gen byte techo_ch=.
	replace techo_ch=1 if h13==1 | h13==2 | h13==3 | h13==4 | h13==5 | h13==6 // sheet metal, shingle (asphalt), shingle (wood), shingle (other), tile, concrete
	replace techo_ch=2 if h13==7 | h13==8 // thatched/troolie Palm, makeshift
	replace techo_ch=. if h13==9

	**********
	*resid_ch*
	**********
	gen byte resid_ch=.
	replace resid_ch=0 if h49==6 | h49==7
	replace resid_ch=1 if h49==3 | h49==5
	replace resid_ch=2 if h49==1 | h49==4
	replace resid_ch=3 if h49==2
	replace resid_ch=. if h49==8
		
	*********
	*dorm_ch*
	*********
	gen byte dorm_ch=.
	destring h48, replace
	replace dorm_ch=h48 
		
	************
	*cuartos_ch*
	************
	gen byte cuartos_ch=.
	destring h47, replace
	replace cuartos_ch=h47

	***********
	*cocina_ch*
	***********
	gen byte cocina_ch=.
	replace cocina_ch=1 if h519==1
	replace cocina_ch=1 if h519==2
		
	**********
	*telef_ch*
	**********
	gen byte telef_ch=.
	replace telef_ch=1 if h5111==1	
	replace telef_ch=0 if h5111==2

	***********
	*refrig_ch*
	***********
	gen byte refrig_ch=.
	replace refrig_ch=1 if h517==1
	replace refrig_ch=0 if h517==2

	*********
	*auto_ch*
	*********
	gen byte auto_ch=.
	replace auto_ch=1 if h516==1
	replace auto_ch=0 if h516==2
		
	*********
	*compu_ch*
	*********
	gen byte compu_ch=.
	replace compu_ch=1 if h514==1
	replace compu_ch=0 if h514==2

	*************
	*internet_ch*
	************* 
	gen byte internet_ch=.
	replace internet_ch=1 if h515==1
	replace internet_ch=0 if h515==2
		
	********
	*cel_ch*
	********
	gen byte cel_ch=.
	replace cel_ch=1 if h5112==1	
	replace cel_ch=0 if h512==2

	*************
	*viviprop_ch*
	*************
	gen byte viviprop_ch1=.
	replace viviprop_ch1=1 if h31==1 // owned/freehold
	replace viviprop_ch1=0 if h31==2 | h31==3 | h31==4 | h31==5 | h31==6 | h31==7 // lease-hold, rented, squatted, rent-free 
	replace viviprop_ch1=. if h31==6 | h31==7 | h31==8   /// none/not applicable, other, ns

***************************************************
*** 7.2 Vivienda - variables Wash (13 variables) ***
***************************************************	

	************
	*aguaentubada_ch*
	************
	gen byte aguaentubada_ch=.
	replace aguaentubada_ch=1 if h43==1 | h43==3 | h43==4 | h43==5  // piped into dwelling, piped into yard/plot, 
	replace aguaentubada_ch=0 if h43==2 | h43==6 | h43==8 | h43==9 | h43==10 | h43==7 // private catchments/rain water, public standpipe or hand pump, spring/river/pond, truck borne, dug well/borehole
	replace aguaentubada_ch=. if h43==11

	************
	*aguared_ch*
	************
	gen byte aguared_ch=.
	replace aguared_ch = 1 if inlist(h43,4,5)
	replace aguared_ch = 0 if inlist(h43,1,2,3,6,7,8,9,10,11,99)
	
	************
	*aguafuente_ch*
	************
	gen byte aguafuente_ch=.
	replace aguafuente_ch=1 if inlist(h44,1,2) & inlist(h43,4,5)
	replace aguafuente_ch=2 if inlist(h44,3)
	replace aguafuente_ch=3 if inlist(h44,6)
	replace aguafuente_ch=4 if inlist(h44,4,5)
	replace aguafuente_ch=5 if inlist(h44,7)
	replace aguafuente_ch=6 if inlist(h44,10) & inlist(h43, 9)
	replace aguafuente_ch=7 if inlist(h44,10) & inlist(h43, 1,3)
	replace aguafuente_ch=8 if inlist(h44,9) 
	replace aguafuente_ch=9 if inlist(h44,8) 
	replace aguafuente_ch=10 if inlist(h44,11)
	
	*************
	*aguadist_ch*
	*************
	gen byte aguadist_ch=.
	replace aguadist_ch =1 if inlist(h44,1)
	replace aguadist_ch =2 if inlist(h44,2)
	replace aguadist_ch = 3 if inlist(h44,3)
	replace aguadist_ch = 0 if inlist(h44,4,5,6,7,8,9,10,11)
	
	**************
	*aguadisp1_ch*
	**************
	gen byte aguadisp1_ch= 9
	
	**************
	*aguadisp2_ch*
	**************
	gen byte aguadisp2_ch= 9
	
	*************
	*aguamide_ch*
	*************
	gen byte aguamide_ch= 9
	
    *********
	*bano_ch*
	*********
	gen byte bano_ch= .
	replace bano_ch = 0 if h45 ==6
	replace bano_ch = 1 if h45 ==1
	replace bano_ch = 2 if h45 ==2
	replace bano_ch = 3 if inlist(h45,3,4)
	replace bano_ch = 5 if inlist(h45,5)
	replace bano_ch = 6 if inlist(h45, 7)
	
	***********
	*banoex_ch*
	***********
	gen byte banoex_ch=.
	replace banoex_ch = 1 if inlist(h46,2)
	replace banoex_ch = 0 if h46 == 1
	
	**************
	*sinbano_ch*
	**************
	gen byte sinbano_ch =.
	replace sinbano_ch =0 if inlist(h45, 1,2,3,4,5,7)
	replace sinbano_ch =3 if inlist(h45, 6)

	*********
	*conbano_ch*
	*********
	gen byte conbano_ch=.
	replace conbano_ch=1 if h45==1 | h45==2 | h45==3 | h45==4 | h45==5 // wc (flush toilet) linked to sewer, wc (flush toilet) linked to septic tank/soak-away, ventilated pit latrine (VIP), trad. pit latrine with slab, trad. pit Latrine w/out slab
	replace conbano_ch=0 if h45==6
	replace conbano_ch=. if h45==7
		
	*****************
	*banoalcantarillado_ch_ch*
	*****************
	gen byte banoalcantarillado_ch=.
	replace banoalcantarillado_ch_ch=1 if h45==1  // wc (flush toilet) linked to sewer 
	replace banoalcantarillado_ch_ch=0 if  h45==2 | h45==3 | h45==4 | h45==5 | h45==6 //  wc (flush toilet) linked to septic tank/soak-away, ventilated pit latrine (VIP), trad. pit latrine with slab, trad. pit Latrine w/out slab, none

	*********
	*des1_ch*
	*********
	gen byte des1_ch=.
	replace des1_ch=0 if bano_ch==0
	replace des1_ch=1 if h45==1 // wc (flush toilet) linked to sewer
	replace des1_ch=2 if h45==2 | h45==3 | h45==4 | h45==5 // wc (flush toilet) linked to septic, ventilated pit latrine (VIP), trad. pit latrine with slab, trad. pit Latrine w/out slab
	replace des1_ch=. if h45==6
	


*************************************************************
*** 8. Otras variables específicas por país (6 variables) ***
*************************************************************	
* si no existe la variable, crearla con un missing value (.). Cambia ISOalpha3Pais
* por el país que te toca. Por ejemplo si te toca Ecuador debe ser 
* ECU_m_pared_ch, ECU_m_piso_ch, etc.
 
	**************************
	*ISOalpha3Pais_m_pared_ch*
	**************************	
	gen byte GUY_m_pared_ch= h12 
	label var GUY_m_pared_ch  "Material de las paredes según el censo del país - variable original"

	*************************
	*ISOalpha3Pais_m_piso_ch*
	*************************
	gen byte GUY_m_piso_ch= .
	label var GUY_m_piso_ch  "Material de los pisos según el censo del país - variable original"

	**************************
	*ISOalpha3Pais_m_techo_ch*
	**************************	
	gen byte GUY_m_techo_ch= h13
	label var GUY_m_techo_ch  "Material del techo según el censo del país - variable original"

*Guatemala 2018 no tiene variables de ingreso

	**************************
	*ISOalpha3Pais_ingreso_ci*
	**************************	
	gen long GUY_ingreso_ci = .
	label var GUY_ingreso_ci  "Ingreso total según el censo del país - variable original"
	
	*****************************
	*ISOalpha3Pais_ingresolab_ci*
	*****************************
	gen long GUY_ingresolab_ci = .	
	label var GUY_ingresolab_ci  "Ingreso laboral según el censo del país - variable original"

	**********************
	*ISOalpha3Pais_dis_ci*
	**********************
	gen byte GUY_dis_ci = .
	label var GUY_dis_ci  "Individuos con discapacidad según el censo del país - variable original"


/*******************************************************************************
   III. Incluir variables externas
*******************************************************************************/
capture drop _merge
merge m:1 pais_c anio_c using "Z:/general_documentation/data_externa/poverty/International_Poverty_Lines/5_International_Poverty_Lines_LAC_long_PPP17.dta", keepusing ( cpi_2017 lp19_2011 lp31_2011 lp5_2011 tc_wdi lp365_2017 lp685_201)
drop if _merge ==2

g tc_c     = tc_wdi
g ipc_c    = cpi_2017
g lp19_ci  = lp19_2011 
g lp31_ci  = lp31_2011 
g lp5_ci   = lp5_2011

capture label var tc_c "Tasa de cambio LCU/USD Fuente: WB/WDI"
capture label var ipc_c "Índice de precios al consumidor base 2017=100 Fuente: IMF/WEO"
capture label var lp19_ci  "Línea de pobreza USD1.9 día en moneda local a precios corrientes a PPA 2011"
capture label var lp31_ci  "Línea de pobreza USD3.1 día en moneda local a precios corrientes a PPA 2011"
capture label var lp5_ci "Línea de pobreza USD5 por día en moneda local a precios corrientes a PPA 2011"
capture label var lp365_2017  "Línea de pobreza USD3.65 día en moneda local a precios corrientes a PPA 2017"
capture label var lp685_2017 "Línea de pobreza USD6.85 por día en moneda local a precios corrientes a PPA 2017"

drop  lp19_2011 lp31_2011 lp5_2011 tc_wdi _merge

/*******************************************************************************
   IV. Revisión de que se hayan creado todas las variables
*******************************************************************************/
* CALIDAD: revisa que hayas creado todas las variables. Si alguna no está
* creada, te apacerá en rojo el nombre. 

global lista_variables region_BID_c region_c geolev1 pais_c anio_c idh_ch idp_ci factor_ci factor_ch estrato_ci upm zona_c sexo_c edad_ci relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch miembros_ci clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch afro_ci ind_ci noafroind_ci afroind_ci afro_ch ind_ch noafroind_ch afroind_ch  dis_ci disWG_ci dis_ch migrante_ci migrantiguo5_ci miglac_ci aedu_ci eduno_ci edupi_ci edupc_ci edusi_ci edusc_ci edus1i_ci edus1c_ci edus2i_ci edus2c_ci edupre_ci asiste_ci literacy condocup_ci emp_ci desemp_ci pea_ci rama_ci  categopri_ci spublico_ci luz_ch piso_ch pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch auto_ch compu_ch internet_ch cel_ch viviprop_ch1 aguaentubada_ch aguared_ch aguafuente_ch aguadist_ch aguadisp1_ch aguadisp2_ch aguamide_ch bano_ch banoex_ch banoalcantarillado_ch sinbano_ch conbano_ch des1_ch ${PAIS}_ingreso_ci ${PAIS}_ingresolab_ci ${PAIS}_m_pared_ch ${PAIS}_m_piso_ch ${PAIS}_m_techo_ch ${PAIS}_dis_ci tc_c ipc_c lp19_ci lp31_ci lp5_ci lp365_2017  lp685_2017

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

keep  $lista_variables num_vivienda num_hogar pcp1

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
compress
save "$base_out", replace 

log close

********************************************************************************
******************* FIN. Muchas gracias por tu trabajo ;) **********************
********************************************************************************