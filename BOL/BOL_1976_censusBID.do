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
local PAIS BOL
local ANO "1976"

local log_file = "$ruta\harmonized\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID.log"
local base_in  = "$ruta\census\\`PAIS'\\`ANO'\data_merge\\`PAIS'_`ANO'_IPUMS.dta"
local base_out = "$ruta\harmonized\\`PAIS'\data_arm\\`PAIS'_`ANO'_censusBID.dta"
                                                    
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE CENSOS POBLACIONALES
País: Bolivia
Año: 1976
Autores: 
Última versión: 

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

use "`base_in'", clear

rename __000001 BOL_1976

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
   replace region_c=1 if geo1_bo==68001			    /*Chuquisaca*/
   replace region_c=2 if geo1_bo==68002			    /*La Paz*/
   replace region_c=3 if geo1_bo==68003			    /*Cochabamba*/
   replace region_c=4 if geo1_bo==68004			    /*Oruro*/
   replace region_c=5 if geo1_bo==68005		     	/*Potosí*/
   replace region_c=6 if geo1_bo==68006			    /*Tarija*/
   replace region_c=7 if geo1_bo==68007			    /*Santa Cruz*/
   replace region_c=8 if geo1_bo==68008			    /*Beni*/
   replace region_c=9 if geo1_bo==68009			    /*Pando*/
  *replace region_c=99 if geo1_co==68099			    /*Unknown*/

	  label define region_c 1"Chuquisaca" 2"La Paz" 3"Cochabamba" 4"Oruro" 5"Potosí" 6"Tarija" 7"Santa Cruz" 8"Beni" 9"Pando" 99""
      label value region_c region_c
      label var region_c "division politico-administrativa, departamento"

    *********
	*pais_c*
	*********
    gen str3 pais_c="BOL"
	
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
    replace relacion_ci=4 if related==4100 | related==4200 | related==4300 | related==4900
    replace relacion_ci=5 if related==5900
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

	

			***********************************
			***VARIABLES DEL MERCADO LABORAL***
			***********************************
			

     *******************
     ****condocup_ci****
     *******************
	 *2010 no tiene variable empstat

 *** region_c ***
 ****************


   gen region_c=.
   replace region_c=1 if geo1_bo==68001  
   replace region_c=2 if geo1_bo==68002
   replace region_c=3 if geo1_bo==68003
   replace region_c=4 if geo1_bo==68004
   replace region_c=5 if geo1_bo==68005
   replace region_c=6 if geo1_bo==68006
   replace region_c=7 if geo1_bo==68007
   replace region_c=8 if geo1_bo==68008
   replace region_c=9 if geo1_bo==68009
   
   label define region_c 1 "Chuqisaca" 2 "La paz" 3 "Cochabamba" 4 "Oruro" 5 "Potosá" 6 "Tarija" 7 "Santa Cruz" 8 "Beni" 9 "Pando", add modify 
   label value region_c region_c 
	

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



	***********************************
	***    VARIABLES DE MIGRACIÓN.  ***
	***********************************

      *******************
      ****migrante_ci****
      *******************
	gen migrante_ci = (nativity == 2)
	 
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

