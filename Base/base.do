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
global ruta = "${censusFolder}"

local log_file = "$ruta\\clean\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID.log"
local base_in = "$ruta\\raw\\`PAIS'\\`PAIS'_`ANO'_IPUMS.dta"
local base_out = "$ruta\\clean\\`PAIS'\\`PAIS'_`ANO'_censusBID.dta"
                                                    
capture log close
log using "`log_file'", replace

use "`base_in'", clear

			****************************
			*  VARIABLES DE DISENO     *
			****************************

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
		if `"`PAIS'"'=="BLZ" | `"`PAIS'"'=="CRI" | `"`PAIS'"'=="SLV" | `"`PAIS'"'=="GTM" | `"`PAIS'"'=="HTI" | `"`PAIS'"'=="HON" | `"`PAIS'"'=="PAN" | `"`PAIS'"'=="MEX" | `"`PAIS'"'=="DOM" | `"`PAIS'"'=="NIC" local reg_bid 1
		
	gen region_BID_c=`reg_bid'

	*********
	*pais_c*
	*********
    rename __00000 pais_c
	
	*********
	*anio_c*
	*********
	rename year anio_c
	
	******************
    *idh_ch (id hogar)*
    ******************
    rename serial idh_ch 
	
	******************
    *idp_ci (idpersonas)*
    ******************
	
	rename pernum idp_ci 
	
	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
	rename perwt factor_ci
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
	rename hhwt factor_ch
	
	
	***********
	* estrato *
	***********
	gen estrato_ci=.
	cap confirm variable strata
	if (_rc==0) {
	replace estrato_ci=strata 
	}

	
	***************************
	* Zona urbana (1) o rural (0)
	***************************
	gen zona_c=.
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
	drop if sexo_ci>2 | sexo_ci<1  /* sex=9 corresponde a "unknown" */
	
	*********
	*edad_c*
	*********
	rename age edad_ci
	replace edad_ci=. if edad_ci==999 /* age=999 corresponde a "unknown" */
	replace edad_ci=98 if edad_ci>=98  /* age=100 corresponde a 100+ */

 	*************
	*relacion_ci*
	*************	
	gen relacion_ci=1 if related==1000
    replace relacion_ci=2 if related==2000
    replace relacion_ci=3 if related==3000
    replace relacion_ci=4 if related==4100 | related==4200 | related==4900
    replace relacion_ci=5 if related==5310 | related==5600 | related==5900
    replace relacion_ci=6 if related==5210
	replace relacion_ci=9 if related==9999
	**************
	*Estado Civil*
	**************
	*2010 no tiene variable marst
	cap confirm variable marst
	if (_rc==0) {
	recode marst (2=1 "Union formal o informal") (3=2 "Divorciado o separado") (4=3 "Viudo") (1=4 "Soltero") (else=.), gen(civil_ci) 
	}
	
    *********
	*jefe_ci*
	*********

	gen jefe_ci=(relate==1)
	

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
	tab related, nol
	
	by idh_ch, sort: egen nempdom_ch=sum(related==5210) if relacion_ci==6	  
	
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
	tab persons
	tab miembros_ci	

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

**********************************
**** VARIABLES DE LA VIVIENDA ****
**********************************
		
	************
	*aguared_ch*
	************

	gen aguared_ch=.
	cap confirm variable watsup
	if (_rc==0) {
	replace aguared_ch=1 if watsup>=10 & watsup<20
	replace aguared_ch=0 if watsup ==20
	replace aguared_ch=. if watsup==99
	}

	********
	*luz_ch*
	********
	*En la nueva encuesta no se encontro si se pregunta por instalacion electrica
	gen luz_ch=.
	cap confirm variable electric
	if (_rc==0) {
	 replace luz_ch = 0 if electric== 2
	 replace luz_ch = 1 if electric== 1
	 replace luz_ch=. if electric==9
	}

	*********
	*bano_ch*
	*********
	gen bano_ch=.
	gen des1_ch=.
	cap confirm variable toilet
	if (_rc==0) {
	replace bano_ch= 1 if toilet==20 | toilet==21 | toilet==22 | toilet==23
	replace bano_ch= 0 if toilet==10
 	replace bano_ch=. if toilet==99

	*********
	*des1_ch*
	*********
	replace des1_ch=0 if bano_ch==0
	replace des1_ch=1 if toilet==21
	replace des1_ch=2 if toilet==22
	replace des1_ch=. if toilet==99
	
	}
	
	*********
	*piso_ch*
	*********
	gen piso_ch=.
 	cap confirm variable floor
	if (_rc==0) {
	replace piso_ch=0 if floor==100
	replace piso_ch=1 if (floor>100 & floor<=120)
	replace piso_ch=2 if floor>=200 & floor<999
	replace piso_ch=. if floor==999
	}
	
	*****************
	*banomejorado_ch*
	*****************
	gen banomejorado_ch=.
 	cap confirm variable sewage
	if (_rc==0) {
	replace banomejorado_ch=1 if sewage == 11 | sewage == 12 
	replace banomejorado_ch=0 if sewage == 20
	replace piso_ch=. if sewage == 99
	}

	**********
	*pared_ch*
	**********
	gen pared_ch=.
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
*Modificación SGR Julio 2019
	gen techo_ch=.
	cap confirm variable roof
	if (_rc==0) {
	replace techo_ch=1  if roof>=10 & roof<20
    replace techo_ch=0  if roof>=20 & roof<80
	replace techo_ch=2  if roof==80
	}
	
	**********
	*resid_ch*
	**********
	gen resid_ch=.
	cap confirm variable trash
	if (_rc==0) {
	replace resid_ch=0  if trash == 11 | trash == 12
    replace resid_ch=1  if trash == 21 |trash == 22 | trash == 23
	replace resid_ch=2  if trash == 24 |trash == 25 
	replace resid_ch=3  if trash == 39
	replace resid_ch=.  if trash == 99
	}
	
	*********
	*dorm_ch*
	*********
	gen dorm_ch=.
	cap confirm variable bedrooms
	if (_rc==0) {
	replace dorm_ch=bedrooms 
	replace dorm_ch=. if bedrooms==99 | bedrooms==98
	}
	
	************
	*cuartos_ch*
	************
	gen cuartos_ch=.
	cap confirm variable rooms
	if (_rc==0) {
	replace cuartos_ch=rooms
	replace cuartos_ch=. if rooms==99 | rooms==98
	}

	***********
	*cocina_ch*
	***********
	gen cocina_ch=.
	cap confirm variable kitchen
	if (_rc==0) {
	replace cocina_ch= 1 if kitchen>=20 & kitchen<=28
	replace cocina_ch = 0 if kitchen == 10
	replace cocina_ch=. if kitchen==99
	}
	
	***********
	*telef_ch*
	***********
	gen telef_ch=.
	cap confirm variable phone
	if (_rc==0) {
	replace telef_ch=0 if phone == 1	
	replace telef_ch=1 if phone == 2
	replace telef_ch=. if phone == 9
	}

	***********
	*refrig_ch*
	***********
	gen refrig_ch=.
	cap confirm variable refrig
	if (_rc==0) {
	replace refrig_ch=0 if refrig==1
	replace refrig_ch=1 if refrig==2
	replace refrig_ch=. if refrig==9
	}

	*********
	*auto_ch*
	*********
	gen auto_ch=.
	cap confirm variable autos
	if (_rc==0) {
	replace auto_ch= 1 if autos>0 & autos<8
	replace auto_ch= 0 if autos==0
	replace auto_ch=. if autos==8 | autos==9
	}
	
	********
	*compu_ch*
	********
	gen compu_ch=.
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
	gen internet_ch=.
	cap confirm variable internet
	if (_rc==0) {
	replace internet_ch=0 if internet == 1
	replace internet_ch=1 if internet == 2
	replace internet_ch=. if internet == 9
	}
	
	********
	*cel_ch*
	********
	gen cel_ch=.
	cap confirm variable cell
	if (_rc==0) {
	replace cel_ch=0 if cell == 1	
	replace cel_ch=1 if cell == 2
	replace cel_ch=. if cell == 9
	}

	*************
	*viviprop_ch*
	*************
	*NOTA: aqui se genera una variable parecida, pues no se puede saber si es propia total o parcialmente pagada
	gen viviprop_ch1=.
	cap confirm variable ownership
	if (_rc==0) {
	replace viviprop_ch1=0 if ownership==2
	replace viviprop_ch1=1 if ownership==1
	*replace viviprop_ch1=3 if 
	replace viviprop_ch1=. if ownership==9
	}
**********************************
**** VARIABLES DE INGRESO ****
***********************************
*NOTA: variables se generan vacias para que en el do del País y Anio se cambien dependiendo de la variable de ingreso disponible

   gen ylm_ci=.
 
   gen ynlm_ci=.
   
   gen ylm_ch =.
   
   gen ynlm_ch =.
   
********************************
*** Health indicators **********
********************************
	gen discapacidad_ci =.
	

	gen ceguera_ci=.
	
	
	gen sordera_ci  =.
	

	gen mudez_ci=.
	

	gen dismental_ci=.
