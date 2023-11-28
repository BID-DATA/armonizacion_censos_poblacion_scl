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
País: Paraguay
Año: 2002
Autores: Cecilia y Olga
Última versión: Nov, 2023

							SCL/LMK - IADB
****************************************************************************/
global ruta = "${censusFolder}"

local PAIS PRY
local ANO "2012"

local log_file = "$ruta//clean//`PAIS'//`PAIS'_`ANO'_censusBID.log"
local base_in  = "$ruta//raw//`PAIS'//`PAIS'_`ANO'_BID_raw.dta"
local base_out = "$ruta//clean//`PAIS'//`PAIS'_`ANO'_censusBID.dta"
                                                    
use "`base_in'", clear

*****************************************************
******* Variables specific for this census **********
*****************************************************

*********************************
** VARIABLES DE IDENTIFICACION **
*********************************

local PAIS PRY
local ANO "2012"




	****************
	* region_BID_c *
	****************
	*CSC
		if `"`PAIS'"'=="ARG" | `"`PAIS'"'=="URY" | `"`PAIS'"'=="BRA" | `"`PAIS'"'=="PRY" | `"`PAIS'"'=="CHL" local reg_bid 4
	*CAN	
		if `"`PAIS'"'=="BOL" | `"`PAIS'"'=="COL" | `"`PAIS'"'=="ECU" | `"`PAIS'"'=="PER" | `"`PAIS'"'=="VEN" local reg_bid 3
		
	*CCB	
		if `"`PAIS'"'=="BHS" | `"`PAIS'"'=="GUY" | `"`PAIS'"'=="JAM" | `"`PAIS'"'=="SUR" | `"`PAIS'"'=="BRB" | `"`PAIS'"'=="TTO" local reg_bid 2
	
	*CID
		if `"`PAIS'"'=="BLZ" | `"`PAIS'"'=="CRI" | `"`PAIS'"'=="SLV" | `"`PAIS'"'=="GTM" | `"`PAIS'"'=="HTI" | `"`PAIS'"'=="HND" | `"`PAIS'"'=="PAN" | `"`PAIS'"'=="MEX" | `"`PAIS'"'=="DOM" | `"`PAIS'"'=="NIC" local reg_bid 1
		
	gen region_BID_c=`reg_bid'
	
	*\eliminar _00000*\
	capture drop __00000
	
	*********
	*pais_c*
	*********
    gen pais_c="`PAIS'"
	
	*********
	*anio_c*
	*********
	gen anio_c=2012
	
	******************
    *idh_ch (id hogar)*
    ******************
	gen idh_ch = .
	
	******************
    *idp_ci (idpersonas)*
    ******************
	
	gen idp_ci = .
	
	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
	gen factor_ci = FEX
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
	gen factor_ch = FEX
	
	
	***********
	* estrato *
	***********
	gen estrato_ci=.
	
	***************************
	* Zona urbana (1) o rural (0)
	***************************
	gen zona_c=.
	replace zona_c = 1 if inlist(AREA, 1, 3) // tomo suburbana como urbana 
	replace zona_c = 0 if AREA == 6
	

	****************
    *** region_c ***
    ****************
	gen region_c=.   
	replace region_c=1 if DPTOD==1	/*Concepción*/
	replace region_c=2 if DPTOD==2	/*San Pedro*/
	replace region_c=3 if DPTOD==3	/*Cordillera*/
	replace region_c=4 if DPTOD==4	/*Guaira*/
	replace region_c=5 if DPTOD==5	/*Caaguazú*/
	replace region_c=6 if DPTOD==6	/*Caazapá*/
	replace region_c=7 if DPTOD==7	/*Itapúa*/
	replace region_c=8 if DPTOD==8	/*Misiones*/
	replace region_c=9 if DPTOD==9	/*Paraguarí*/
	replace region_c=10 if DPTOD==10	/*Alto Paraná*/
	replace region_c=11 if DPTOD==11	/*Central*/
	replace region_c=12 if DPTOD==12	/*Ñembuccú*/
	replace region_c=13 if DPTOD==13	/*Amambay*/
	replace region_c=14 if DPTOD==14	/*Canindeyú*/
	replace region_c=15 if DPTOD==15	/*Presidente Hayes*/
	replace region_c=16 if DPTOD==16	 /*Boquerón*/
	replace region_c=17 if DPTOD==17	/*Alto Paraguay*/
	replace region_c=18 if DPTOD==18	/*Asunción*/ 

	label define region_c ///
	 1	"Concepción" ///
	 2 "San Pedro" ///
	 3	"Cordillera" ///
	 4	"Guaira" ///
	 5	"Caaguazú" ///
	 6	"Caazapá" ///
	 7	"Itapúa" ///
	 8	"Misiones" ///
	 9	"Paraguarí" ///
	 10	"Alto Paraná" ///
	 11	"Central" ///
	 12	"Ñembuccú" ///
	 13	"Amambay" ///
	 14	"Canindeyú" ///
	 15	"Presidente Hayes" ///
	 16	"Boquerón" ///
	 17	"Alto Paraguay" ///
	 18 "Asunción"

	label value region_c region_c
	label var region_c "division politico-administrativa, departamento"
	
*********************************************
***         VARIABLES DEMOGRAFICAS        ***
*********************************************
	
	*********
	*sexo_c*
	*********
    gen sexo_ci = .
	replace sexo_ci = 1 if P03 == 1
	replace sexo_ci = 2 if P03 == 6
	
	
	*********
	*edad_c*
	*********
	gen edad_ci = P04A 

 	*************
	*relacion_ci*
	*************
	gen relacion_ci = . 
	replace relacion_ci = 1 if P02 == 1 // Jefe
    replace relacion_ci = 2 if P02 == 2 // Cónyugue/esposo/a/compañero/a
    replace relacion_ci = 3 if P03 == 3 // Hijo/a
    replace relacion_ci = 4 if inrange(P03, 4, 10) //  Otros parientes
    replace relacion_ci = 5 if P03 == 12 // Otros no parientes 
    replace relacion_ci = 6 if P03 == 11 // Servicio doméstico 
	
	**************
	*Estado Civil*
	**************
	gen civil_ci = . 
	replace civil_ci = 1 if P24 == 6 // Soltero
	replace civil_ci = 2 if P24 == 2 // Union formal o infomral 
	replace civil_ci = 3 if inlist(P24, 4, 5) // Divorciado o separado
	replace civil_ci = 4 if P24 == 3 // Viudo
	
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
	by idh_ch, sort: egen nempdom_ch=sum(relacion_ci==6)
	
	*******************************************************
	***           VARIABLES DE DIVERSIDAD               ***
	*******************************************************				
	* Cesar Lins & Nathalia Maya - Septiembre 2021	

		***************
		***afroind_ci***
		***************
	**Pregunta: 

	gen afroind_ci=. 
	replace afroind_ci = 1 if P42A == 1
	replace afroind_ci = 3 if P42A == 6 


		***************
		***afroind_ch***
		***************
	gen afroind_jefe = afroind_ci if P02==1
	*egen afroind_ch  = min(afroind_jefe), by(idh_ch) VER ESTO! 
	
	*drop afroind_jefe 

		*******************
		***afroind_ano_c***
		*******************
	gen afroind_ano_c=2012


		********************
		*** discapacidad ***
		********************
	gen dis_ci = . 
	replace dis_ci = 1 if (inrange(P09, 1, 3) | inrange(P10, 1, 3) ///
	| inrange(P11, 1, 3) | inrange(P12, 1, 3) | inrange(P13, 1, 3))
	replace dis_ci = 0 if (P09 == 4 | P10 == 4 | P11 == 4 | P12 == 4 ///
	| P13 == 4)
	
	
	gen dis_ch = . 
	
	
**********************************************
***      VARIABLES DEL MERCADO LABORAL     ***
**********************************************	

     *******************
     ****condocup_ci****
     *******************
	 
    gen condocup_ci=.
	replace condocup_ci = 1 if P25 == 1 | P26 == 1 // ocupado
	replace condocup_ci = 2 if P29 == 1 // desempleo abierto
	replace condocup_ci = 3 if P29 == 6 // inactivos

	
      ************
      ***emp_ci***
      ************
    gen emp_ci=.
	replace emp_ci = 1 if condocup_ci == 1 // empleados
	replace emp_ci = 0 if inlist(condocup_ci, 2, 3) // desempleados e inactivos

	
	
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
	replace pea_ci=1 if condocup_ci == 1 | condocup_ci == 2
	replace pea_ci=0 if condocup_ci == 3
	
     *************************
     ****rama de actividad****
     *************************

    gen rama_ci = . //  VER: Esta la variable P33_A se usa rama de actividad a 2 digitos. el detalle no se presenta an la documentacion del censo. 
	
     *********************
     ****categopri_ci****
     *********************
	 
	gen categopri_ci=.
	replace categopri_ci = 1 if P34 == 3 & condocup_ci == 1 // patron o empleador 
	replace categopri_ci = 2 if P34 == 1 & condocup_ci == 1 // cuenta propia o indep 
	replace categopri_ci = 3 if inlist(P34, 4, 5) & condocup_ci == 1 // empleado u obrero
	replace categopri_ci = 4 if P34 == 2 & condocup_ci == 1 // empleado no remunerado

      *****************
      ***spublico_ci***
      *****************
    gen spublico_ci=.
	replace spublico_ci = 1 if categopri_ci != . & P35 == 1 // sector publico
	replace spublico_ci = 0 if categopri_ci != . & P35 == 6 
	
	
*******************************************************
***           VARIABLES DE INGRESO                  ***
*******************************************************
	
    ***********
	**ylm_ci**
	***********
	
	gen ylm_ci=.
	
    ***********
	**ynlm_ci**
	***********
 
	gen ynlm_ci=.

    ***********
	**ylm_ch**
	***********
   
   gen ylm_ch=.
   
    ***********
	**ynlm_ch**
	***********
   gen ynlm_ch=.



	
	************************
	* VARIABLES EDUCATIVAS *
	************************
	
	replace P18B_GRA = . if P18B_GRA == 9
	
/*	
	  18a- ¿Cuál es el último nivel más |
                         alto aprobado? |     Código 
----------------------------------------+--------------
                                Ninguno |       0
                         Grado Especial |       1
            Programas de alfabetización |       2
                           Pre-primario |       3
      EEB (1° y 2° Ciclo) / Ex Primaria |       4
  EEB (3° Ciclo) / Ex Secundaria Básica |       5 
      Educación Media / Ex Bachillerato |       6
Superior No Universitario  o Universita |       7
                                     NR |       9
*/


	*********
	*aedu_ci* // 
	*********
	gen aedu_ci = .	
	replace aedu_ci = 0 if inrange(P18A_NIV, 0, 3) // Ninguno, Grado especial, Programas de alfabetizacion. 
	replace aedu_ci = P18B_GRA if inrange(P18A_NIV, 4, 5) // EEB (1° y 2° Ciclo y  EEB (3° Ciclo)
	replace aedu_ci = P18B_GRA + 9 if P18A_NIV == 6 // Educación media.
	replace aedu_ci = P18B_GRA + 12 if P18A_NIV == 7 // Superior (univ o no univ)
 
	**********
	*eduno_ci* // no ha completado ningún año de educación
	**********
	gen eduno_ci = (aedu_ci == 0) // never attended or pre-school
	replace eduno_ci =. if aedu_ci == . // NIU & missing
	
	***********
	*edupre_ci* // preescolar
	***********
	gen edupre_ci=(P18A_NIV==3) // pre-school
	replace edupre_ci=. if P18A_NIV==. // NIU & missing
	
	**********
	*edupi_ci* // no completó la educación primaria
	**********
	gen edupi_ci = (aedu_ci > 0 & aedu_ci < 6)
	replace edupi_ci = . if aedu_ci == . 

	********** 
	*edupc_ci* // completó la educación primaria
	**********
	gen edupc_ci = (aedu_ci == 6) 
	replace edupc_ci = . if aedu_ci == . // NIU & missing

	**********
	*edusi_ci* // no completó la educación secundaria
	**********
	gen edusi_ci = (aedu_ci > 6 & aedu_ci <= 11)
	replace edusi_ci = . if aedu_ci == . 

	**********
	*edusc_ci* // completó la educación secundaria
	**********
	gen edusc_ci = (aedu_ci == 12) // 
	replace edusc_ci = . if aedu_ci == . // NIU & missing
	
	***********
	*edus1i_ci* // no completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1i_ci = (aedu_ci > 6 & aedu_ci < 9)
	replace edus1i_c = . if aedu_ci == .
	
	***********
	*edus1c_ci* // completó el primer ciclo de la educación secundaria
	***********
	gen byte edus1c_ci = (aedu_ci == 9)
	replace edus1c_ci = . if aedu_ci == . 

	***********
	*edus2i_ci* // no completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2i_ci = (aedu_ci > 9 & aedu_ci < 12)
	replace edus2i_ci = . if aedu_ci == . 

	***********
	*edus2c_ci* // completó el segundo ciclo de la educación secundaria
	***********
	gen byte edus2c_ci = (aedu_ci == 12)
	replace edus2c_ci = . if aedu_ci == . 
	
	***********
	*asiste_ci*
	***********
	gen asiste_ci = . 
	replace asiste_ci = 1 if P16 == 1
	replace asiste_ci = 0 if P16 == 6

	**********
	*literacy*
	**********
	gen literacy = . 
	replace literacy = 1 if P15 == 1 // literate
	replace literacy = 0 if P15 == 6 // illiterate

	
**********************************
**** VARIABLES DE LA VIVIENDA ****
**********************************
		
	************
	*aguared_ch*
	************
/*

	Nota: 
	
	Tomo como agua de red:
	      
		  ESSAP (ex corposana) 
          SENASA o Junta de Saneamiento 
          Red comunitaria 
          Red  privada 

*/

	gen aguared_ch=.
	replace aguared_ch = 1 if inrange(V09, 1, 4)
	replace aguared_ch = 0 if inrange(V09, 5, 12)

	********
	*luz_ch*
	********
	gen luz_ch = .
	replace luz_ch = 1 if V07 == 1
	replace luz_ch = 0 if V07 == 6
	
	
	*********
	*bano_ch*
	*********
	gen bano_ch=.
	replace bano_ch = 1 if inrange(V18, 1, 3)
	replace bano_ch = 0 if V18 == 6
	
	
	*********
	*des1_ch*
	*********
	gen des1_ch = . 
	replace des1_ch = 0 if V20 == 8 
	replace des1_ch = 1 if V20 == 1
	replace des1_ch = 2 if inrange(V20, 2, 6)
	
	
	*********
	*piso_ch*
	*********
	
	* Se utiliza la metodologia de encustas de hogares.
	
	gen piso_ch = .
	replace piso_ch = 0 if V04 == 1 // materiales no permanentes
	replace piso_ch = 1 if inrange(V04, 2, 8) // materiales permanentes
	replace piso_ch = 2 if V04 == 9 // otros
	
	*****************
	*banomejorado_ch*
	*****************
	gen banomejorado_ch = .
	replace banomejorado_ch = 1 if inrange(V20, 1, 4)
	replace banomejorado_ch = 0 if inlist(V20, 5, 8)


	**********
	*pared_ch*
	**********
	gen pared_ch = .
	replace pared_ch = 0 if inlist(V03, 3, 7) // no permanentes
	replace pared_ch = 1 if inlist(V03, 1, 5) // permanentes 
	replace pared_ch = 2 if inlist(V03, 2, 6, 9) // otros
	

	**********
	*techo_ch*
	**********
	gen techo_ch = .
	replace techo_ch = 0 if inlist(V05, 2, 3, 8) // no permanentes
	replace techo_ch = 1 if inlist(V05, 1, 4, 5, 6, 7) // permanentes 
	replace techo_ch = 2 if V05 == 9 // otros
	
	**********
	*resid_ch*
	**********
	gen resid_ch = .
	replace resid_ch = 0 if V06 == 2 // recolección pública o privada
	replace resid_ch = 1 if inlist(V06, 1, 3) // quemados o enterrados
	replace resid_ch = 2 if inlist(V06, 4, 5, 6, 7) // espacio abiertos
	
	*********
	*dorm_ch*
	*********
	gen dorm_ch = .
	replace dorm_ch = V15B if V15B != 99
	
	************
	*cuartos_ch*
	************
	gen cuartos_ch = .
	replace cuartos_ch = V15A if V15A != 88

	***********
	*cocina_ch*
	***********
	gen cocina_ch = .
	
	***********
	*telef_ch*
	***********
	gen telef_ch = .
	replace telef_ch = 1 if V1604 == 4 

	***********
	*refrig_ch*
	***********
	gen refrig_ch=.
	replace refrig_ch = 1 if V1603 == 3 

	*********
	*auto_ch*
	*********
	gen auto_ch=.
	replace auto_ch = 1 if V1611 == 11

	********
	*compu_ch*
	********
	gen compu_ch=.
	replace compu_ch = 1 if V1616 == 16 

	*************
	*internet_ch*
	************* 
	gen internet_ch=.
	replace internet_ch = 1 if V1617 == 17

	
	********
	*cel_ch*
	********
	gen cel_ch=.
	replace cel_ch = 1 if V1605 == 5 

	*************
	*viviprop_ch*
	*************
	gen vivprop_ch = .
	replace vivprop_ch = 0 if V11 == 4 // alquilada 
	replace vivprop_ch = 1 if V11 == 1 // propia y totalmente pagada
	replace vivprop_ch = 2 if V11 == 2 // en proceso de pago
	replace vivprop_ch = 3 if V11 == 6 // ocupada de hecho

	
****************************************
***         VARIABLES DE SALUD       ***
****************************************

*****************
*discapacidad_ci*
*****************

gen discapacidad_ci = . 
replace discapacidad_ci = 1 if (inrange(P09, 1, 3) | inrange(P10, 1, 3) ///
| inrange(P11, 1, 3) | inrange(P12, 1, 3) | inrange(P13, 1, 3))
replace discapacidad_ci = 0 if (P09 == 4 | P10 == 4 | P11 == 4 | P12 == 4 ///
| P13 == 4)

************
*ceguera_ci*
************

gen ceguera_ci = . 
replace ceguera_ci = 1 if inrange(P09, 1, 3) 
replace ceguera_ci = 0 if P09 == 4

************
*sordera_ci*
************ 

gen sordera_ci = . 
replace sordera_ci = 1 if inrange(P10, 1, 3)
replace sordera_ci = 0 if P10 == 4

**********
*mudez_ci*
**********

gen mudez_ci = . 

**************
*dismental_ci*
**************

gen dismental_ci = . 
replace dismental_ci = 1 if inrange(P13, 1, 3)
replace dismental_ci = 0 if P13 == 4

	
*******************************************************
***           VARIABLES DE MIGRACIÓN              ***
*******************************************************

    *******************
    ****migrante_ci****
    *******************
	
	gen migrante_ci =.
	replace migrante_ci = 1 if P14A == 3
	replace migrante_ci = 0 if inlist(P14A, 1, 2)
   
	*******************
    **migantiguo5_ci***
    *******************
	gen migantiguo5_ci =.
	
	**********************
	*** migrantelac_ci ***
	**********************

	gen migrantelac_ci = 0
	replace migrantelac_ci = 1 if inlist(P14CPAIS, 32, 68, 76, 152, 170, 188, 192, 214, 218, 222, 484, 604, 858, 862)
	replace migrantelac_ci = . if P14CPAIS == 999 
	

	**********************
	****** miglac_ci *****
	**********************

	gen miglac_ci = .
	replace miglac_ci = 1 if inlist(P14CPAIS, 32, 68, 76, 152, 170, 188, 192, 214, 218, 222, 484, 604, 858, 862)
	replace miglac_ci = 0 if !inlist(P14CPAIS, 32, 68, 76, 152, 170, 188, 192, 214, 218, 222, 484, 604, 858, 862, 999)


order region_BID_c pais_c estrato_ci zona_c relacion_ci civil_ci idh_ch factor_ch idp_ci factor_ci edad_ci sexo_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch clasehog_ch nmiembros_ch nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch nmenor1_ch miembros_ci condocup_ci emp_ci desemp_ci pea_ci rama_ci spublico_ci migrante_ci migantiguo5_ci aguared_ch luz_ch bano_ch des1_ch piso_ch pared_ch techo_ch dorm_ch cuartos_ch cocina_ch refrig_ch auto_ch internet_ch cel_ch viviprop_ch viviprop_ch1 region_c categopri_ci discapacidad_ci ceguera_ci sordera_ci mudez_ci dismental_ci afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch aedu_ci

*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"

compress

save "`base_out'", replace 
log close

