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
País: Colombia
Año:
Autores: 
Última versión: 
							SCL/LMK - IADB
****************************************************************************/
****************************************************************************

local PAIS COL
local ANO "1964"

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

gen region_c =.
replace region_c=1 if geo1_co1964 ==5 /*Antioquia*/ 
replace region_c=2 if geo1_co1964 ==8 /*Atlántico*/ 
replace region_c=3 if geo1_co1964 ==11 /*Bogotá*/ 
replace region_c=4 if geo1_co1964 ==13 /*Bolívar*/ 
replace region_c=5 if geo1_co1964 ==15 /*Boyacá*/ 
replace region_c=6 if geo1_co1964 ==17 /*Caldas*/ 
replace region_c=7 if geo1_co1964 ==18 /*Caquetá*/ 
replace region_c=8 if geo1_co1964 ==19 /*Cauca*/ 
replace region_c=9 if geo1_co1964 ==20 /*Cesar*/ 
replace region_c=10 if geo1_co1964 ==23 /*Córdoba*/ 
replace region_c=11 if geo1_co1964 ==25 /*Cundinamarca*/ 
replace region_c=12 if geo1_co1964 ==27 /*Chocó*/ 
replace region_c=13 if geo1_co1964 ==41 /*Huila*/ 
replace region_c=14 if geo1_co1964 ==44 /*La Guajira*/
replace region_c=15 if geo1_co1964 ==47 /*Magdalena*/ 
replace region_c=16 if geo1_co1964 ==50 /*Meta*/ 
replace region_c=17 if geo1_co1964 ==52 /*Nariño*/ 
replace region_c=18 if geo1_co1964 ==54/*Norte de Santander*/ 
replace region_c=19 if geo1_co1964 ==63 /*Quindío*/ 
replace region_c=20 if geo1_co1964 ==66 /*Risaralda*/ 
replace region_c=21 if geo1_co1964 ==68 /*Santander*/ 
replace region_c=22 if geo1_co1964 ==70 /*Sucre*/ 
replace region_c=23 if geo1_co1964 ==73 /*Tolima*/ 
replace region_c=24 if geo1_co1964 ==76 /*Valle*/ 
replace region_c=25 if geo1_co1964 ==81 /*Arauca*/ 
replace region_c=26 if geo1_co1964 ==85 /*Casanare*/ 
replace region_c=27 if geo1_co1964 ==86 /*Putumayo*/ 
replace region_c=28 if geo1_co1964 ==88 /*San Andrés*/ 
replace region_c=29 if geo1_co1964 ==95 /*Amazonas, Guaviare, Vaupes, Vichada, Guania*/ 

label define region_c 1"Antioquia" 2"Atlántico" 3"Bogotá" 4"Bolívar" 5"Boyacá" 6"Caldas" 7"Caquetá" 8"Cauca" 9"Cesár" 10"Córdoba" 11"Cundinamarca" 12"Chocó" 13"Huila" 14"La Guajira" 15"Magdalena" 16"Meta" 17"Nariño" 18"Norte de Santander" 19"Quindío" 20"Risaralda" 21"Santander" 22"Sucre" 23"Tolima" 24"Valle" 25"Arauca" 26"Casanare" 27"Putumayo" 28"San Andrés" 29"Amazonas, Guaviare, Vaupes, Vichada, Guania"	
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
	 
      *******************
      **migantiguo5_ci***
      *******************
	gen migantiguo5_ci = (migyrs1 >= 5) & migrante_ci == 1
	replace migantiguo5_ci = . if migantiguo5_ci == 0 & nativity != 2
	
	**********************
	*** migrantelac_ci ***
	**********************
	
	gen migrantelac_ci= 1 if inlist(bplcountry, 21100, 23010, 22060, 23110, 22020, 22040, 23100, 22030, 23060, 23140, 22050, 23040, 23100, 29999, 23130, 23030, 21250, 21999, 22010, 22070, 22080, 22999)
	replace migrantelac_ci = 0 if migrantelac_ci == . & nativity == 2

	
	*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

compress

save "`base_out'", replace 
log close

