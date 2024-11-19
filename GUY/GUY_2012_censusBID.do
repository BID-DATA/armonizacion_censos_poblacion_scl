* (Versión Stata 17)

clear
set more off

 *________________________________________________________________________________________________________________*
 
 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: ${censusFolder}
 * Se tiene acceso al servidor únicamente al interior del BID.
 *________________________________________________________________________________________________________________*
 
*Population and Housing Censuses/ Not Harmonized by IPUMS

/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Guyana
Año: 2012
Autores: Agustina Thailinger SCL/EDU 
Última versión: 

							SCL/EDU - IADB
****************************************************************************/
****************************************************************************

local PAIS GUY
local ANO "2012"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************

global ruta = "${censusFolder}"

local log_file = "$ruta\\clean\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID.log"
local base_in = "$ruta\\raw\\`PAIS'\\`PAIS'_`ANO'_NOIPUMS.dta"
local base_out = "$ruta\\clean\\`PAIS'\\`PAIS'_`ANO'_censusBID.dta"
                                                    
capture log close
log using "`log_file'", replace

use "`base_in'", clear

*******************************************************
****          VARIABLES DE IDENTIFICACION          ****
*******************************************************
********
*pais_c*
********
gen pais_c="GUY"

**************
*region_BID_c*
**************
gen region_BID_c=2
label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c

**********
*region_c*
**********
gen region_c=.   
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
gen geolev1=.   
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
*anio_c*
********
gen anio_c=2012

********
*idh_ci*
********
gen idh_ci=.
********
*idp_ci*
********
gen idp_ci=. 
********
*idh_ch*
********		
gen idh_ch=serialno

***********
*factor_ci*
***********
gen factor_ci=.

***********
*factor_ch*
***********
gen factor_ch=.

***********
*factor_ch*
***********
gen estrato_ci=.

********
*zona_c*
********		
gen zona_c=.
	
**************************************************
****          VARIABLES DEMOGRAFICAS          ****
**************************************************
*********
*sexo_ci*
*********
gen sexo_ci=1 if p12==1
replace sexo_ci=2 if p12==2

*********
*edad_ci*
*********
gen edad_ci=p13age2
replace edad_ci=. if edad_ci==999 // age=999 corresponde a "unknown"
replace edad_ci=98 if edad_ci>=98

*************
*relacion_ci*
*************
gen relacion_ci=1 if p11==1
replace relacion_ci=2 if p11==2
replace relacion_ci=3 if p11==3 | p11==4 
replace relacion_ci=4 if p11==5 | p11==6 | p11==7 | p11==8
replace relacion_ci=5 if p11==9 | p11==10

**********
*civil_ci*
**********
gen civil_ci=1 if p61==1
replace civil_ci=2 if p61==2
replace civil_ci=3 if p61==3 | p61==5
replace civil_ci=4 if p61==4
replace civil_ci=9 if p61==0

*********
*jefe_ci*
*********
gen jefe_ci=(relacion_ci==1)
replace jefe_ci=. if relacion_ci==.

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
by idh_ch, sort: egen nempdom_ch=sum(p11==9) if relacion_ci==5 
	
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

***************************************************
****          VARIABLES DE DIVERSIDAD          ****
***************************************************
************
*afroind_ci*
************
gen afroind_ci=.
replace afroind_ci=1 if p14==2 // Amerindian
replace afroind_ci=2 if p14==1 // African/Black
replace afroind_ci=3 if (p14==3 | p14==4 | p14==5 | p14==6 | p14==7 | p14==8)  // Others

************
*afroind_ch*
************
gen afroind_jefe=afroind_ci if p11==1
egen afroind_ch=min(afroind_jefe), by(idh_ch)
drop afroind_jefe 

****************
*afroind_ano_ci*
****************
gen afroind_ano_c=1991

********
*dis_ci*
********
gen dis_ci=1 if p21==1

********
*dis_ch*
********
egen dis_ch=min(dis_ci), by(idh_ch)

***********************************************
****          VARIABLES LABORALES          ****
***********************************************
*************
*condocup_ci*
*************
gen condocup_ci=.
replace condocup_ci=1 if p81==1 | p81==2
replace condocup_ci=2 if p81==3 | p81==4
replace condocup_ci=3 if p81==5 | p81==6 | p81==7 | p81==8 | p81==9
replace condocup_ci=. if p81==10 | p81==32 | p81==0
								
********
*emp_ci*
********
gen emp_ci=.
replace emp_ci=0 if condocup_ci==2 | condocup_ci==3
replace emp_ci=1 if condocup_ci==1

***********
*desemp_ci*
***********	
gen desemp_ci=.
replace desemp_ci=1 if condocup_ci==2
replace desemp_ci=0 if condocup_ci==1 | condocup_ci==3

********
*pea_ci*
********
gen pea_ci=.
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

gen rama_ci=.
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
gen categopri_ci=.
replace categopri_ci=0 if p87==8 | p87==9
replace categopri_ci=1 if p87==5
replace categopri_ci=2 if p87==6
replace categopri_ci=3 if p87>=1 & p87<=4
replace categopri_ci=4 if p87==7
replace categopri_ci=. if p87==0
				
*************
*spublico_ci*
*************
gen spublico_ci=.
													
************************************************
****          VARIABLES DE INGRESO          ****
************************************************
********
*ylm_ci*
********
gen ylm_ci=.
 
*********
*ynlm_ci*
*********
gen ynlm_ci=.
							
********
*ylm_ch*
********
gen ylm_ch=.
							  
*********
*ynlm_ch*
*********
gen ynlm_ch=.				
							
**************************************************
****          VARIABLES DE EDUCACIÓN          ****
**************************************************
*********
*aedu_ci* // años de educacion aprobados
*********
gen aedu_ci=.

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
*asiste_ci*
***********
gen asiste_ci=.
replace asiste_ci=1 if (p41==1 | p41==2)
replace asiste_ci=0 if p41==3
replace asiste_ci=. if p41==0 | p41==5

***********
*edupre_ci*
***********
gen edupre_ci=.

**********
*literacy*
**********
gen literacy=.

****************************************************
****          VARIABLES DE LA VIVIENDA          ****
****************************************************
************
*aguaentubada_ch*
************

gen aguaentubada_ch=.
replace aguaentubada_ch=1 if h43==1 | h43==3 | h43==4 | h43==5  // piped into dwelling, piped into yard/plot, public well
replace aguaentubada_ch=0 if h43==2 | h43==6 | h43==8 | h43==9 | h43==10 | h43==7 // private catchments/rain water, public standpipe or hand pump, spring/river/pond, truck borne, dug well/borehole
replace aguaentubada_ch=. if h43==11

	************
	*aguared_ch*
	************
	gen aguared_ch=.
	replace aguared_ch = 1 if inlist(h43,1,2,4,5)
	replace aguared_ch = 0 if inlist(h43,3,6,7,8,9,10,11,99)
	
	************
	*aguafuente_ch*
	************
	gen aguafuente_ch=.
	replace aguafuente_ch=1 if inlist(h44,1,2)
	replace aguafuente_ch=2 if inlist(h44,3)
	replace aguafuente_ch=3 if inlist(h44,6)
	replace aguafuente_ch=4 if inlist(h44,4,5)
	replace aguafuente_ch=5 if inlist(h44,7)
	replace aguafuente_ch=6 if inlist(h44,10) & inlist(h43, 9)
	replace aguafuente_ch=7 if inlist(h44,10) & inlist(h43, 1,)
	replace aguafuente_ch=8 if inlist(h44,9) 
	replace aguafuente_ch=9 if inlist(h44,8) 
	replace aguafuente_ch=10 if inlist(h44,11)
	
	*************
	*aguadist_ch*
	*************
	gen aguadist_ch=.
	replace aguadist_ch =1 if inlist(h44,1)
	replace aguadist_ch =2 if inlist(h44,2)
	replace aguadist_ch = 3 if inlist(h44,3)
	replace aguadist_ch = 0 if inlist(h44,4,5,6,7,8,9,10,11)
	
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
	replace bano_ch = 0 if h45 ==6
	replace bano_ch = 1 if h45 ==1
	replace bano_ch = 2 if h45 ==2
	replace bano_ch = 3 if inlist(h45,3,4)
	replace bano_ch = 5 if inlist(h45,5)
	replace bano_ch = 6 if inlist(h45, 7)
	
	
	***********
	*banoex_ch*
	***********
	gen banoex_ch=.
	replace banoex_ch = 1 if inlist(h46,2)
	replace banoex_ch = 0 if h46 == 1
	

	**************
	*sinbano_ch*
	**************
	gen sinbano_ch =.
	replace sinbano_ch =0 if inlist(h45, 1,2,3,4,5,7)
	replace sinbano_ch =3 if inlist(h45, 6)




********
*luz_ch*
********
gen luz_ch=.
replace luz_ch=0 if h42==1 | h42==2 | h42==5 // gas lantern, kerosene, solar/inverter
replace luz_ch=1 if h42==3 | h42==4
replace luz_ch=. if h42==6
	
*********
*conbano_ch*
*********
gen conbano_ch=.
replace conbano_ch=1 if h45==1 | h45==2 | h45==3 | h45==4 | h45==5 // wc (flush toilet) linked to sewer, wc (flush toilet) linked to septic tank/soak-away, ventilated pit latrine (VIP), trad. pit latrine with slab, trad. pit Latrine w/out slab
replace conbano_ch=0 if h45==6
replace conbano_ch=. if h45==7
	
*********
*des1_ch*
*********
gen des1_ch=.
replace des1_ch=0 if bano_ch==0
replace des1_ch=1 if h45==1 // wc (flush toilet) linked to sewer
replace des1_ch=2 if h45==2 | h45==3 | h45==4 | h45==5 // wc (flush toilet) linked to septic, ventilated pit latrine (VIP), trad. pit latrine with slab, trad. pit Latrine w/out slab
replace des1_ch=. if h45==6
	
*********
*piso_ch*
*********
gen piso_ch=.
replace piso_ch=. if h45==7
	
*****************
*banoalcantarillado_ch_ch*
*****************
gen banoalcantarillado_ch=.
replace banoalcantarillado_ch_ch=1 if h45==1  // wc (flush toilet) linked to sewer 
replace banoalcantarillado_ch_ch=0 if  h45==2 | h45==3 | h45==4 | h45==5 | h45==6 //  wc (flush toilet) linked to septic tank/soak-away, ventilated pit latrine (VIP), trad. pit latrine with slab, trad. pit Latrine w/out slab, none


**********
*pared_ch*
**********
gen pared_ch=.
replace pared_ch=1 if h12==1 | h12==6 | h12==5 // wood, makeshift, adobe and palm
replace pared_ch=2 if h12==2 | h12==3 | h12==4 | h12==7 | h12==8 | h12==9 | h12==10 // concrete, wood and concrete, stone, brick only, stone and brick, galvanize, wood and brick
replace pared_ch=. if h12==11

**********
*techo_ch*
**********
gen techo_ch=.
replace techo_ch=1 if h13==1 | h13==2 | h13==3 | h13==4 | h13==5 | h13==6 // sheet metal, shingle (asphalt), shingle (wood), shingle (other), tile, concrete
replace techo_ch=2 if h13==7 | h13==8 // thatched/troolie Palm, makeshift
replace techo_ch=. if h13==9

**********
*resid_ch*
**********
gen resid_ch=.
replace resid_ch=0 if h49==6 | h49==7
replace resid_ch=1 if h49==3 | h49==5
replace resid_ch=2 if h49==1 | h49==4
replace resid_ch=3 if h49==2
replace resid_ch=. if h49==8
	
*********
*dorm_ch*
*********
gen dorm_ch=.
destring h48, replace
replace dorm_ch=h48 
	
************
*cuartos_ch*
************
gen cuartos_ch=.
destring h47, replace
replace cuartos_ch=h47

***********
*cocina_ch*
***********
gen cocina_ch=.
replace cocina_ch=1 if h519==1
replace cocina_ch=1 if h519==2
	
**********
*telef_ch*
**********
gen telef_ch=.
replace telef_ch=1 if h5111==1	
replace telef_ch=0 if h5111==2

***********
*refrig_ch*
***********
gen refrig_ch=.
replace refrig_ch=1 if h517==1
replace refrig_ch=0 if h517==2

*********
*auto_ch*
*********
gen auto_ch=.
replace auto_ch=1 if h516==1
replace auto_ch=0 if h516==2
	
*********
*compu_ch*
*********
gen compu_ch=.
replace compu_ch=1 if h514==1
replace compu_ch=0 if h514==2

*************
*internet_ch*
************* 
gen internet_ch=.
replace internet_ch=1 if h515==1
replace internet_ch=0 if h515==2
	
********
*cel_ch*
********
gen cel_ch=.
replace cel_ch=1 if h5112==1	
replace cel_ch=0 if h512==2

*************
*viviprop_ch*
*************
gen viviprop_ch1=.
replace viviprop_ch1=1 if h31==1 // owned/freehold
replace viviprop_ch1=0 if h31==2 | h31==3 | h31==4 | h31==5 | h31==6 | h31==7 // lease-hold, rented, squatted, rent-free 
replace viviprop_ch1=. if h31==6 | h31==7 | h31==8   /// none/not applicable, other, ns

**********************************************
****          VARIABLES DE SALUD          ****
**********************************************
*****************
*discapacidad_ci*
*****************
gen discapacidad_ci=.
replace discapacidad_ci=1 if p21==1
replace discapacidad_ci=0 if p21==2
replace discapacidad_ci=. if p21==3 | p21==0

************
*ceguera_ci*
************
gen ceguera_ci=.
replace ceguera_ci=1 if p221==1 & discapacidad_ci==1
replace ceguera_ci=0 if (p221!=1 & discapacidad_ci==1)

************
*sordera_ci*
************
gen sordera_ci=.
replace sordera_ci=1 if p222==1 & discapacidad_ci==1
replace sordera_ci=0 if (p222!=1 & discapacidad_ci==1)

**********
*mudez_ci*
**********
gen mudez_ci=.
replace mudez_ci=1 if p223==1 & discapacidad_ci==1
replace mudez_ci=0 if (p223!=1 & discapacidad_ci==1)
	
**************
*dismental_ci*
**************
gen dismental_ci=.
replace dismental_ci=1 if p227==1 & discapacidad_ci==1
replace dismental_ci=0 if (p227!=1 & discapacidad_ci==1)
	
**************************************************
****          VARIABLES DE MIGRACIÓN          ****
**************************************************
*************
*migrante_ci*
*************
gen migrante_ci=.
replace migrante_ci=1 if p31==1
replace migrante_ci=0 if p31==2

****************
*migrantelac_ci*
****************
gen migrantelac_ci=.
replace migrantelac_ci=1 if p33cntry=="ARG" | p33cntry=="BHS" | p33cntry=="BRB" | p33cntry=="BLZ" | p33cntry=="BOL" | p33cntry=="BRA" | p33cntry=="CHL" | p33cntry=="COL" | p33cntry=="CRI" | p33cntry=="DOM" | p33cntry=="ECU" | p33cntry=="SLV" | p33cntry=="GTM" | p33cntry=="HTI" | p33cntry=="HND" | p33cntry=="JAM" | p33cntry=="MEX" | p33cntry=="NIC" | p33cntry=="PAN" | p33cntry=="PRY" | p33cntry=="PER" | p33cntry=="SUR" | p33cntry=="TTO" | p33cntry=="URY" | p33cntry=="VEN" & migrante_ci==1
replace migrantelac_ci=0 if migrantelac_ci==. & migrante_ci==1 | migrante_ci==0

***********
*miglac_ci*
***********
gen miglac_ci=.
replace miglac_ci=1 if p33cntry=="ARG" | p33cntry=="BHS" | p33cntry=="BRB" | p33cntry=="BLZ" | p33cntry=="BOL" | p33cntry=="BRA" | p33cntry=="CHL" | p33cntry=="COL" | p33cntry=="CRI" | p33cntry=="DOM" | p33cntry=="ECU" | p33cntry=="SLV" | p33cntry=="GTM" | p33cntry=="HTI" | p33cntry=="HND" | p33cntry=="JAM" | p33cntry=="MEX" | p33cntry=="NIC" | p33cntry=="PAN" | p33cntry=="PRY" | p33cntry=="PER" | p33cntry=="SUR" | p33cntry=="TTO" | p33cntry=="URY" | p33cntry=="VEN" 
replace miglac_ci=0 if migrantelac_ci!=1 & migrante_ci==1 

****************
*migantiguo5_ci*
****************
destring p34, replace
gen migantiguo5_ci=.
replace migantiguo5_ci=1 if (p34<=2008 & migrante_ci==1)
replace migantiguo5_ci=0 if migantiguo5_ci==. & migrante_ci==1 | migrante_ci==0

*****************
*migrantiguo5_ci*
*****************
gen migrantiguo5_ci=.
replace migrantiguo5_ci=1 if (p34<=2008 & migrante_ci==1)
replace migrantiguo5_ci=0 if migantiguo5_ci!=1 & migrante_ci==1
	
*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
cd "C:\Users\JILLIEC\OneDrive - Inter-American Development Bank Group\2023\IADB_2023\censos\raw"
include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguaentubada_ch aguared_ch aguafuente_ch aguadist_ch aguadisp1_ch aguadisp2_ch aguamide_ch bano_ch banoex_ch sinbano_ch luz_ch conbano_ch des1_ch piso_ch banoalcantarillado_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress


save "`base_out'", replace 
log close