/* (Versión Stata 12)*/
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
País: Brasil
Año: 2000
Autores: Cesar Lins
Última versión: Septiembre, 2021

							SCL/LMK - IADB
****************************************************************************/

local PAIS BRA
local ANO "2000"

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
 replace region_c=1 if geo1_br2000 ==11  /*Rondônia*/
 replace region_c=2 if geo1_br2000 ==12  /*Acre*/
 replace region_c=3 if geo1_br2000 ==13 /*Amazonas*/
 replace region_c=4 if geo1_br2000 ==14 /*Roraima*/
 replace region_c=5 if geo1_br2000 ==15 /*Pará*/
 replace region_c=6 if geo1_br2000 ==16 /*Amapá*/
 replace region_c=7 if geo1_br2000 ==17 /*Tocantins*/
 replace region_c=8 if geo1_br2000 ==21 /*Maranhão*/
 replace region_c=9 if geo1_br2000 ==22 /*Piauí*/
 replace region_c=10 if geo1_br2000 ==23 /*Ceará*/
 replace region_c=11 if geo1_br2000 ==24 /*Rio Grande do Norte*/
 replace region_c=12 if geo1_br2000 ==25 /*Paraíba*/
 replace region_c=13 if geo1_br2000 ==26 /*Pernambuco*/
 replace region_c=14 if geo1_br2000 ==27 /*Alagoas*/
 replace region_c=15 if geo1_br2000 ==28 /*Sergipe*/
 replace region_c=16 if geo1_br2000 ==29 /*Bahia*/
 replace region_c=17 if geo1_br2000 ==31 /*Minas Gerais*/
 replace region_c=18 if geo1_br2000 ==32 /*Espírito Santo*/
 replace region_c=19 if geo1_br2000 ==33 /*Rio de Janeiro*/
 replace region_c=20 if geo1_br2000 ==35 /*São Paulo*/
 replace region_c=21 if geo1_br2000 ==41 /*Paraná*/
 replace region_c=22 if geo1_br2000 ==42 /*Santa Catarina*/
 replace region_c=23 if geo1_br2000 ==43 /*Rio Grande do Sul*/
 replace region_c=24 if geo1_br2000 ==50 /*Mato Grosso do Sul*/
 replace region_c=25 if geo1_br2000 ==51 /*Mato Grosso*/
 replace region_c=26 if geo1_br2000 ==52 /*Goiás*/
 replace region_c=27 if geo1_br2000 ==53 /*Distrito Federal*/

 label define region_c 1"Rondônia" 2"Acre" 3"Amazonas" 4"Roraima" 5"Pará" 6"Amapá" 7"Tocantins" 8"Maranhão" 9"Piauí" 10"Ceará" 11"Rio Grande do Norte" 12"Paraíba" 13"Pernambuco" 14"Alagoas" 15"Sergipe" 16"Bahia" 17"Minas Gerais" 18"Espírito Santo" 19"Rio de Janeiro" 20"São Paulo" 21"Paraná" 22"Santa Catarina" 23"Rio Grande do Sul" 24"Mato Grosso do Sul" 25"Mato Grosso" 26"Goiás" 27"Distrito Federal"
 

			***********************************
			***VARIABLES DEL MERCADO LABORAL***
			***********************************
			

     *******************
     ****condocup_ci****
     *******************
    gen condocup_ci=.
    replace condocup_ci=1 if empstat==1
    replace condocup_ci=2 if empstat==2
    replace condocup_ci=3 if empstat==3
    replace condocup_ci=4 if empstat==0
    label var condocup_ci "Condicion de ocupación"
    label define condocup_ci 1 "Ocupado" 2 "Desocupado" 3 "Inactivo" 4 "Menor de PET" 
    label value condocup_ci condocup_ci
	
	
	  ************
      ***emp_ci***
      ************
    gen emp_ci=(condocup_ci==1)

	
      ****************
      ***desemp_ci***
      ****************
    gen desemp_ci=(condocup_ci==2)
	
	
	  *************
      ***pea_ci***
      *************
    gen pea_ci=(emp_ci==1 | desemp_ci==1)
	
	
     *********************
     ****categopri_ci****
     *********************
	 *OBSERVACIONES: 
    gen categopri_ci=.
    replace categopri_ci=0 if classwkd==230 | classwkd==340
    replace categopri_ci=1 if classwkd==110
    replace categopri_ci=2 if classwkd==120 | classwkd==123
    replace categopri_ci=3 if classwkd==200 | classwkd==209
    replace categopri_ci=4 if classwkd==310
    label var categopri_ci "categoría ocupacional de la actividad principal "
    label define categopri_ci 0 "Otra clasificación" 1 "Patrón o empleador" 2 "Cuenta Propia o independiente" 3 "Empleado o asalariado" 4 "Trabajador no remunerado" 
    label value categopri_ci categopri_ci	 


     *************************
     ****rama de actividad****
     *************************
    gen rama_ci = .
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
	replace rama_ci = 16 if indgen==999
    label var rama_ci "Rama de actividad"
    label def rama_ci 1"Agricultura, pesca y forestal" 2"Minería y extracción" 3"Industrias manufactureras" 4"Electricidad, gas, agua y manejo de residuos" 5"Construcción" 6"Comercio" 7"Hoteles y restaurantes" 8"Transporte, almacenamiento y comunicaciones" 9"Servicios financieros y seguros" 10"Administración pública y defensa" 11"Servicios empresariales e inmobiliarios" 12"Educación" 13"Salud y trabajo social" 14"Otros servicios" 15"Servicio doméstico" 16"Otras ramas"
    label val rama_ci rama_ci
	
	
	  *****************
      ***spublico_ci***
      *****************
    gen spublico_ci=(indgen==100)	
	

**********************************
**** VARIABLES DE INGRESO ****
**********************************
	
     ***********
	  *ylm_ci*
	 ***********
   cap confirm variable incearn
   if (_rc==0) {
   replace ylm_ci = incearn
   replace ylm_ci =. if incearn==99999999 | incearn==99999998
   }

	 *********
	 *ynlm_ci*
	 *********
   cap confirm variable incwel
   if (_rc==0) {
   replace ynlm_ci=incwel
   replace ynlm_ci=. if incwel== 99999999 | incwel==99999998
   } 
   
     ***********
	  *ylm_ch*
	 ***********
   
   by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
   
    ***********
	  *ynlm_ch*
	 ***********
   by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1, missing
   
 
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
**Pregunta: 

gen afroind_ci=. 
replace afroind_ci=1  if race == 30
replace afroind_ci=2 if race == 20 | race == 51 
replace afroind_ci=3 if race == 10 | race == 40 
replace afroind_ci=. if race == 99

	***************
	***afroind_ch***
	***************
gen afroind_jefe= afroind_ci if relate==1
egen afroind_ch  = min(afroind_jefe), by(idh_ch) 

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=1990

********************
*** discapacidad ***
********************
gen dis_ci=.
gen dis_ch=.

***********************************
***    VARIABLES DE MIGRACIÓN.  ***
***********************************
	gen migrante_ci=.

	gen migantiguo5_ci=.
	
	gen migrantelac_ci=.

****************************
***	VARIABLES EDUCATIVAS ***
****************************

*********
*aedu_ci* // años de educacion aprobados
*********

gen aedu_ci=0 if yrschool==0 // none or pre-school
replace aedu_ci=1 if yrschool==1
replace aedu_ci=2 if yrschool==2
replace aedu_ci=3 if yrschool==3
replace aedu_ci=4 if yrschool==4
replace aedu_ci=5 if yrschool==5
replace aedu_ci=6 if yrschool==6
replace aedu_ci=7 if yrschool==7
replace aedu_ci=8 if yrschool==8
replace aedu_ci=9 if yrschool==9
replace aedu_ci=10 if yrschool==10
replace aedu_ci=11 if yrschool==11
replace aedu_ci=12 if yrschool==12
replace aedu_ci=13 if yrschool==13
replace aedu_ci=14 if yrschool==14
replace aedu_ci=15 if yrschool==15
replace aedu_ci=16 if yrschool==16
replace aedu_ci=17 if yrschool==17
replace aedu_ci=. if yrschool==98 | yrschool==99 | yrschool==95 // unknown/missing or NIU + 95=adult literacy (de acuerdo a los documentos de EDU primaria completa es 4 anos en BRA y según la base if yrschool==95, then edattaind==Some primary complete; however, we don't know how many).
replace aedu_ci=. if educbr==3900 // secondary, grade unspecified

label var aedu_ci "Años de educacion aprobados"

**********
*eduno_ci* // no ha completado ningún año de educación // Para esta variable no se puede usar aedu_ci porque aedu_ci=0 es none o pre-school
**********
	
gen eduno_ci=(aedu_ci==0 & educbr!=1200 & educbr!=1700 & educbr!=4130 & educbr!=2900) // none

***************
***edupre_ci***
***************
gen byte edupre_ci=(educbr==1200) // pre-school
label variable edupre_ci "Educacion preescolar"
	
**********
*edupi_ci* // no completó la educación primaria
**********
	
gen edupi_ci=(aedu_ci>=1 & aedu_ci<=7 | educbr==1700 | educbr==2900) // 1 a 7 anos de educación + attending first grade + primary grade unspecified

********** 
*edupc_ci* // completó la educación primaria
**********
	
gen edupc_ci=(aedu_ci==8) // 8 anos de educación

**********
*edusi_ci* // no completó la educación secundaria
**********
	
gen edusi_ci=(aedu_ci==9 | aedu_ci==10) // 9 y 10 anos de educación

**********
*edusc_ci* // completó la educación secundaria
**********
	
gen edusc_ci=(aedu_ci==11) // 11 anos de educación

**********
*eduui_ci* // no completó la educación universitaria o terciaria
**********
	
gen eduui_ci=(aedu_ci>=12 & aedu_ci<=14) // some college completed + anos 15 de educación que aparece como universitario completo pero no lo sería

**********
*eduuc_ci* // completó la educación universitaria o terciaria
**********
	
gen eduuc_ci=(aedu_ci==15 | aedu_ci==16 | aedu_ci==17) // 15 a 17 anos de educación

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

**************
**asiste_ci***
**************

gen asiste_ci=(school==1) // 0 includes NIU (0), attended in the past (3), never attended (4) and unknown/missing (9)
replace asiste_ci=. if edattaind==0 // missing a los NIU & missing
label var asiste_ci "Personas que actualmente asisten a un centro de enseñanza"
	
*Other variables

************
* literacy *
************

gen literacy=(lit==2) // 0 includes illiterate (1), NIU(0) and unknown/missing (9)
replace literacy=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"
compress

save "`base_out'", replace 
log close
