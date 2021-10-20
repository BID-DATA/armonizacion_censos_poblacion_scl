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
local PAIS ARG
local ANO "1970"

local log_file = "$ruta\harmonized\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID.log"
local base_in  = "$ruta\census\\`PAIS'\\`ANO'\data_merge\\`PAIS'_`ANO'_IPUMS.dta"
local base_out = "$ruta\harmonized\\`PAIS'\data_arm\\`PAIS'_`ANO'_censusBID.dta"
                                                    
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Argentina
Año: 1970
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

use "`base_in'", clear

rename __000000 ARG_1970

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

   gen region_c=.   
   replace region_c=1 if geo1_ar==32002			    /*Ciudad de Buenos Aires*/
   replace region_c=2 if geo1_ar==32006			    /*Provincia de Buenos Aires*/
   replace region_c=3 if geo1_ar==32010			    /*Catamarca*/
   replace region_c=4 if geo1_ar==32014			    /*Córdoba*/
   replace region_c=5 if geo1_ar==32018		     	/*Corrientes*/
   replace region_c=6 if geo1_ar==32022			    /*Chaco*/
   replace region_c=7 if geo1_ar==32026			    /*Chubut*/
   replace region_c=8 if geo1_ar==32030			    /*Entre Rí­os*/
   replace region_c=9 if geo1_ar==32034			    /*Formosa*/
   replace region_c=10 if geo1_ar==32038			/*Jujuy*/
   replace region_c=11 if geo1_ar==32042			/*La Pampa*/
   replace region_c=12 if geo1_ar==32046			/*La Rioja*/
   replace region_c=13 if geo1_ar==32050			/*Mendoza*/
   replace region_c=14 if geo1_ar==32054			/*Misiones*/
   replace region_c=15 if geo1_ar==32058			/*Neuquén*/
   replace region_c=16 if geo1_ar==32062			/*Rio Negro*/
   replace region_c=17 if geo1_ar==32066			/*Salta*/
   replace region_c=18 if geo1_ar==32070			/*San Juan*/
   replace region_c=19 if geo1_ar==32074			/*San Luis*/
   replace region_c=20 if geo1_ar==32078			/*Santa Cruz*/
   replace region_c=21 if geo1_ar==32082			/*Santa Fe*/
   replace region_c=22 if geo1_ar==32086			/*Santiago del Estero*/
   replace region_c=23 if geo1_ar==32090			/*Tucumán*/
   replace region_c=24 if geo1_ar==32094			/*Tierra del Fuego*/
   replace region_c=99 if geo1_ar==32099			/*Unknown*/


	label define region_c 1"Ciudad de Buenos Aires" 2"Provincia de Buenos Aires" 3"Catamarca" 4"Córdoba" 5"Corrientes" 6"Chaco" 7"Chubut" 8"Entre Ríos" 9"Formosa" 10"Jujuy" 11"La Pampa" 12"La Rioja" 13"Mendoza" 14"Misiones" 15"Neuquén" 16"Río Negro" 17"Salta" 18"San Juan" 19"San Luis" 20"Santa Cruz" 21"Santa Fe" 22"Santiago del Estero" 23"Tucumán" 24"Tierra del Fuego" 99""
      label value region_c region_c
      label var region_c "division politico-administrativa, provincia"
    label value region_c region_c


**********************************************
***      VARIABLES DEL MERCADO LABORAL     ***
**********************************************
			

     *******************
     ****condocup_ci****
     *******************
	 *2010 no tiene variable empstat
	 
    gen condocup_ci=.
    replace condocup_ci=1 if empstat==1
    replace condocup_ci=2 if empstat==2
    replace condocup_ci=3 if empstat==3
    replace condocup_ci=. if empstat==9
    replace condocup_ci=4 if empstat==0
	
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
	
	
     *************************
     ****rama de actividad****
     *************************
	 *2010 no tiene variable indgen
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
	
	 *********************
     ****categopri_ci****
     *********************
	 *OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.	
    gen categopri_ci=.
	cap confirm variable classwkd
	if (_rc==0) {
    replace categopri_ci=0 if classwkd==400 | classwkd==999
    replace categopri_ci=1 if classwkd==110
    replace categopri_ci=2 if classwkd==120
    replace categopri_ci=3 if classwkd==203 | classwkd==204 | classwkd==216 | classwkd==230 
    replace categopri_ci=4 if classwkd==310
    label var categopri_ci "categoría ocupacional de la actividad principal "
    label define categopri_ci 0 "Otra clasificación" 1 "Patrón o empleador" 2 "Cuenta Propia o independiente" 3 "Empleado o asalariado" 4 "Trabajador no remunerado" 
    label value categopri_ci categopri_ci	 
	}
	
	*****************
      ***spublico_ci***
      *****************
    gen spublico_ci=(indgen==100)	


*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************
* Cesar Lins & Nathalia Maya - Septiembre 2021	

	***************
	***afroind_ci***
	***************
**Pregunta: 

gen afroind_ci=. 

	***************
	***afroind_ch***
	***************
gen afroind_jefe=.
gen afroind_ch  =.

drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=.

********************
*** discapacid
********************
gen dis_ci=.
gen dis_ch=.

****************************
***VARIABLES DE EDUCACION***
****************************

*********
*aedu_ci* // años de educacion aprobados
*********
*NOTA: Como terciario, universitario y posgrado tienen una duración variable se supone 
*que terciario completo implica 3 años de educacion adicional a la secundaria, universitario 5 años adicionales y 
*postgrado 7. Esto solo se basa en la modas de finalización de estos niveles. ESTO SE DEBE DISCUTIR 

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
replace aedu_ci=18 if yrschool==18 // 18 or more
replace aedu_ci=. if yrschool==98 | yrschool==99 // unknown/missing or NIU

label var aedu_ci "Años de educacion aprobados"
	
**********
*eduno_ci* // no ha completado ningún año de educación // Para esta variable no se puede usar aedu_ci porque aedu_ci=0 es none o pre-school
**********

gen eduno_ci=(educar==110) // never attended
replace eduno_ci=. if educar==0 | educar==999 // NIU & missing
	
**********
*edupi_ci* // no completó la educación primaria
**********
	
gen edupi_ci=(educar==130 | educar==210 | educar==220 | educar==230 | educar==240 | educar==250 | educar==280) // primary (zero years completed) + grade 1-5 + primary grade unknown
replace edupi_ci=. if educar==0 | educar==999 // NIU & missing

********** 
*edupc_ci* // completó la educación primaria
**********
	
gen edupc_ci=(educar==260 | educar==270) // grade 6 + grade 7
replace edupc_ci=. if educar==0 | educar==999 // NIU & missing

**********
*edusi_ci* // no completó la educación secundaria
**********
	
gen edusi_ci=(aedu_ci>=8 & aedu_ci<=11) // 8 a 11 anos de educación
replace edusi_ci=. if educar==0 | educar==999 // NIU & missing

**********
*edusc_ci* // completó la educación secundaria
**********
	
gen edusc_ci=(aedu_ci==12 | aedu_ci==13) // 12 y 13 anos de educación
replace edusc_ci=. if educar==0 | educar==999 // NIU & missing

**********
*eduui_ci* // no completó la educación universitaria o terciaria
**********
	
gen eduui_ci=(aedu_ci>=14 & aedu_ci<=16) // 14 a 16 anos de educación
replace eduui_ci=. if educar==0 | educar==999 // NIU & missing

**********
*eduuc_ci* // completó la educación universitaria o terciaria
**********
	
gen eduuc_ci=(aedu_ci==17 | aedu_ci==18) // 17 y 18 anos de educación
replace eduuc_ci=. if edattaind==0 | edattaind==999 // missing a los NIU & missing

***********
*edus1i_ci* // no completó el primer ciclo de la educación secundaria
***********


    *********
	*pais_c*
	*********
    gen str3 pais_c="ARG"
	
	*********
	*anio_c*
	*********
    gen int anio_c=year
	
	
			****************************
			*  VARIABLES DE DISENO     *
			****************************
	
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************

	gen factor_ch=hhwt
	label var factor_ch "Factor de expansion del hogar"
	

	****************************************
	*factor expansión individio (factor_ci)*
	****************************************

	gen factor_ci=perwt
	label var factor_ci "Factor de expansion del individuo"
	
	
	******************
    *idh_ch (idhogar)*
    ******************
	
    gen str13 idh_ch=string(serial)
	
	
		    ****************************
			***VARIABLES DEMOGRAFICAS***
			****************************

	*********
	*sexo_ci*
	*********
	
	capture gen sexo_ci=sex
	drop if sexo_ci>2 | sexo_ci<1 
	
	*********
	*edad_ci*
	*********
	
	capture gen edad_ci=age
	replace edad_ci=98 if edad_ci>=98 
	
	*************
	*relacion_ci*
	*************	
	gen relacion_ci=1 if related==1000
    replace relacion_ci=2 if related==2000
    replace relacion_ci=3 if related==3000
    replace relacion_ci=4 if related==4100 | related==4200 | related==4900
    replace relacion_ci=5 if related==5310 | related==5600 | related==5900
    replace relacion_ci=6 if related==5210
	label var relacion_ci "Relación de parentesco con el jefe de hogar"
    label define relacion_ci 1 "Jefe" 2 "Conyuge" 3 "Hijo" 4 "Otros Parientes" 5 "Otros no Parientes" 6 "Servicio Domestico"
    label values relacion_ci relacion_ci

	
	**************
	*Estado Civil*
	**************
	*2010 no tiene variable marst
	
	recode marst (2=1 "Union formal o informal") (3=2 "Divorciado o separado") (4=3 "Viudo") (1=4 "Soltero") (else=.), gen(civil_ci) 
	label variable civil_ci "Estado civil"
	
	
    *********
	*jefe_ci*
	*********

	gen jefe_ci=(relate==1)

	
    ***********
	*nhijos_ch*
	***********
	*2010 no tiene variable nchild
	
    gen byte nhijos_ch=nchild
	

			***********************************
			***VARIABLES DEL MERCADO LABORAL***
			***********************************
			

     *******************
     ****condocup_ci****
     *******************
	 *2010 no tiene variable empstat
	 
    gen condocup_ci=.
    replace condocup_ci=1 if empstat==1
    replace condocup_ci=2 if empstat==2
    replace condocup_ci=3 if empstat==3
    replace condocup_ci=. if empstat==9
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
	 *OBSERVACIONES: El censo no distingue entre actividad principal o secundaria, asigno por default principal.	
	 *2010 no tiene variable classwkd
    gen categopri_ci=.
    replace categopri_ci=0 if classwkd==999
    replace categopri_ci=1 if classwkd==110
    replace categopri_ci=2 if classwkd==120
    replace categopri_ci=3 if classwkd==203 | classwkd==204
    replace categopri_ci=4 if classwkd==310
    label var categopri_ci "categoría ocupacional de la actividad principal "
    label define categopri_ci 0 "Otra clasificación" 1 "Patrón o empleador" 2 "Cuenta Propia o independiente" 3 "Empleado o asalariado" 4 "Trabajador no remunerado" 
    label value categopri_ci categopri_ci	 


     *************************
     ****rama de actividad****
     *************************
	 *2010 no tiene variable indgen
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
    label var rama_ci "Rama de actividad"
    label def rama_ci 1"Agricultura, pesca y forestal" 2"Minería y extracción" 3"Industrias manufactureras" 4"Electricidad, gas, agua y manejo de residuos" 5"Construcción" 6"Comercio" 7"Hoteles y restaurantes" 8"Transporte, almacenamiento y comunicaciones" 9"Servicios financieros y seguros" 10"Administración pública y defensa" 11"Servicios empresariales e inmobiliarios" 12"Educación" 13"Salud y trabajo social" 14"Otros servicios" 15"Servicio doméstico"
    label val rama_ci rama_ci
	
	
	  *****************
      ***spublico_ci***
      *****************
    gen spublico_ci=(indgen==100)	
	




compress

save "`base_out'", replace 
log close

