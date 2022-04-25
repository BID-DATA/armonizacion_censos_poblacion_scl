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

include "../Base/base.do"

*****************************************************
******* Variables specific for this census **********
*****************************************************
****************
*** region_c ***
****************
gen region_c=.   
replace region_c=1  if regno==01
replace region_c=2  if regno==02
replace region_c=3  if regno==03
replace region_c=4  if regno==04
replace region_c=5  if regno==05
replace region_c=6  if regno==06
replace region_c=7  if regno==07
replace region_c=8  if regno==08
replace region_c=9  if regno==09
replace region_c=10 if regno==10
   
label value region_c region_c
label var region_c "division politico-administrativa, provincias"
	
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************
***************
***afroind_ci***
***************
gen afroind_ci=.
replace afroind_ci=1 if p14==2 // Amerindian
replace afroind_ci=2 if p14==1 // African/Black
replace afroind_ci=3 if (p14==3 | p14==4 | p14==5 | p14==6 | p14==7 | p14==8)  // Others

***************
***afroind_ch***
***************
gen afroind_jefe=afroind_ci if p11==1
egen afroind_ch=min(afroind_jefe), by(idh_ch)
drop afroind_jefe 

*******************
***afroind_ano_c***
*******************
gen afroind_ano_c=1991

********************
*** discapacidad ***
********************
gen dis_ci=1 if p21==1
egen dis_ch=min(dis_ci), by(idh_ch)
							
*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
***********
**ylm_ch*
***********
by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
  
***********
**ynlm_ch*
***********
by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1, missing

******************************************************
***           VARIABLES DE EDUCACIÓN               ***
******************************************************
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


*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress

save "`base_out'", replace 
log close