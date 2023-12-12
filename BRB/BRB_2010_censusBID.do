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
País: Guatemala
Año: 2018
Autores: Eric Torres
Última versión: Junio, 2022

							SCL/LMK - IADB
****************************************************************************/

local PAIS BRB
local ANO "2010"

**************************************
** Setup code, load database,       **
** and include all common variables **
**************************************
*include "../Base/base.do"
global ruta ="${censusFolder}"

global ruta_clean = "$ruta\\clean\\`PAIS'"
global ruta_raw = "$ruta\\raw\\`PAIS'"

local log_file ="$ruta\\clean\\`PAIS'\\log\\`PAIS'_`ANO'_censusBID.log"
local base_in = "$ruta_raw\\`PAIS'_`ANO'_NOIPUMS.dta"
local base_out ="$ruta_clean\\`PAIS'\\`PAIS'_`ANO'_censusBID.dta"

capture log close
log using "`log_file'", replace

use "`base_in'", clear

    *********
	*region_BID_c*
	*********
gen region_BID_c = 2
	
	*********
	*region_c
	*********
gen region_c = parish
	
    *********
	*pais_c*
	*********
gen pais_c = "`PAIS'"

    *********
	*anio_c*
	*********
gen anio_c = "`ANO'"

    ******************
    *idh_ch (id hogar)*
    ******************

egen idh_ch = group(ed building dwelling_unit household) 

	******************
    *idp_ci (idpersonas)*
    ******************
egen idp_ci = group(ed building dwelling_unit household id_person) 

    ***********
	* estrato *
	***********
gen estrato_ci=.

    ***************************
	* Zona urbana (1) o rural (0)
	***************************
gen zona_c=.
	
	****************************************
	*factor expansión individio (factor_ci)*
	****************************************
gen factor_ci=1
	
	*******************************************
	*Factor de expansion del hogar (factor_ch)*
	*******************************************
gen factor_ch=1
	

*********************************************
***         VARIABLES DEMOGRAFICAS        ***
*********************************************
	
	***************************
	*sexo_c (1 hombre 2 mujer)*
	***************************
	gen sexo_ci = sex
	
	*********
	*edad_c*
	*********
	gen edad_ci = age

 	*************
	*relacion_ci*
	*************	
	gen relacion_ci=. 
	replace relacion=1 if rth==0 // Jefe
	replace relacion=2 if rth==1 // Conyuge, esposa, companero
	replace relacion=3 if rth==3  // Hijo/a
	replace relacion=4 if rth==4 | rth==5 | rth==6 // Otros parientes
	replace relacion=5 if rth==7 | rth==8 // Otros no parientes
			
	**************
	*Estado Civil*
	**************
	gen civil_ci=.
	replace civil_ci=1 if p9==5
	replace civil_ci=2 if p9==1
	replace civil_ci=3 if p9==2 | p9==3
	replace civil_ci=4 if p9==3
	replace civil_ci=. if p9==9

    *********
	*jefe_ci*
	*********
	gen jefe_ci=(relacion_ci==1)           
	replace jefe_ci=. if relacion_ci == 99
	

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
	* tab persons
	* tab miembros_ci	

*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
			
	***************
	***afroind_ci***
	***************
	gen afroind_ci=. 
	replace afroind_ci=2 if p10==1
	replace afroind_ci=3 if inrange(p10,2,9)

	***************
	***afroind_ch***
	***************
    gen afroind_jefe= afroind_ci if jefe_ci==1
	egen afroind_ch  = min(afroind_jefe), by(idh_ch) 
	
	drop afroind_jefe 

	*******************
	***afroind_ano_c***
	*******************
	gen afroind_ano_c=.	

	*******************
	***dis_ci***
	*******************
	gen dis_ci=. 

	*******************
	***dis_ch***
	*******************
	egen dis_ch  = sum(dis_ci), by(idh_ch) 
	replace dis_ch=1 if dis_ch>=1 & dis_ch!=.


**********************************************
***      VARIABLES DEL MERCADO LABORAL     ***
**********************************************	

    *******************
    ****condocup_ci****
    *******************
    gen condocup_ci=.
	replace condocup_ci=1 if inlist(p34,1,2)
	replace condocup_ci=2 if p34==3
	replace condocup_ci=3 if inrange(p34,6,8)
	replace condocup_ci=4 if edad_ci<14
	
	************
    ***emp_ci***
    ************
	
    gen emp_ci=.
	replace emp_ci=1 if condocup_ci==1
	replace emp_ci=0 if condocup_ci==2
	
	
	****************
    ***desemp_ci***
    ****************	
	gen desemp_ci=.
	replace desemp_ci=1 if condocup_ci==2
	replace desemp_ci=0 if condocup_ci==1 | condocup_ci==3
	
	*************
    ***pea_ci***
    *************
    gen pea_ci=.
	replace pea_ci=1 if condocup_ci==1
	replace pea_ci=1 if condocup_ci==2
	replace pea_ci=0 if condocup_ci==3
	replace pea_ci=0 if condocup_ci==4
	
	*************************
    ****rama de actividad****
    *************************
	
	*p37_occupationcode (ISIC Rev 4)
    gen rama_ci = .

/*
Se armonizo los grandes grupos de industrias

CIIU 3										 	CIIU 4
A Agricultura, ganadería, caza y silvicultura	A. Agricultura, ganadería, silvicultura y pesca
B Pesca
C Explotación de minas y canteras				B. Explotación de minas y canteras
D Industrias manufactureras						C. Industrias manufactureras
E Suministro de electricidad, gas y agua		D. Suministro de electricidad, gas, vapor y aire acondicionado
												E. Suministro de agua; evacuación de aguas residuales, gestión de desechos y descontaminación
F Construcción									F. Construcción


1	Agricultura, pesca y forestal - Agriculture, hunting, forestry and fishing
2	Minería y extracción - Exploitation of mines and quarries
3	Industrias manufactureras - Manufacturing industries
4	Electricidad, gas, agua y manejo de residuos - Electricity, gas and water
5	Construcción - Construction
6	Comercio - Commerce
7	Hoteles y restaurantes - Restaurants and hotels
8	Transporte, almacenamiento y comunicaciones - Transportation, storage and communications
9	Servicios financieros y seguros - Financial and insurance establishments
10	Administración pública y defensa - Public administration and defense
11	Servicios empresariales e inmobiliarios - Business and real estate services
12	Educación - Education
13	Salud y trabajo social - Social, community and personal services
14	Otros servicios - Other services
15	Servicio doméstico - Domestic work
*/
	** REVISAR **
/*
	replace rama_ci= 1 if p38_industrycode>=110 & p38_industrycode<=490
	replace rama_ci = 2 if p38_industrycode>=510 & p38_industrycode<=990
	replace rama_ci = 3 if p38_industrycode>=1010 & p38_industrycode <=3390
	replace rama_ci = 4 if p38_industrycode>=3510 & p38_industrycode<=3900
	replace rama_ci = 5 if p38_industrycode>=4100 & p38_industrycode<=4390
	replace rama_ci = 6 if p38_industrycode>=4510 & p38_industrycode<=4799
	replace rama_ci = 7 if p38_industrycode>=5510 & p38_industrycode<=5630 
	replace rama_ci = 8 if (p38_industrycode>=4911 & p38_industrycode<= 5320) | (p38_industrycode>=5811 & p38_industrycode<= 6399) 
	replace rama_ci = 9 if p38_industrycode>=6411 & p38_industrycode<= 6630
	replace rama_ci = 10 if p38_industrycode>=8400 & p38_industrycode<=8499
	replace rama_ci = 11 if p38_industrycode>=6800 & p38_industrycode <=8299
	replace rama_ci = 12 if p38_industrycode>=8500 & p38_industrycode<=8599
	replace rama_ci = 13 if p38_industrycode>=8600 & p38_industrycode<=9399
	replace rama_ci = 14 if (p38_industrycode>=9400 & p38_industrycode<=9699) | p38_industrycode>=9900
	replace rama_ci = 15 if p38_industrycode>=9700 & p38_industrycode<=9899
*/
	

	label var rama_ci "Economic Sector"
	label define rama_ci 							///
	1"Agriculture, hunting, forestry and fishing"	///
	2"Exploitation of mines and quarries"	        ///
	3"Manufacturing industries"	          	  		///
	4"Electricity, gas and water"	          		///
	5"Construction"	          						///
	6"Commerce"	      								///
	7"Restaurants and hotels"	          			///
	8"Transportation, storage and communications"   ///
	9"Financial and insurance establishments"	    ///
	10"Public administration and defense"	        ///
	11"Business and real estate services"	        ///
	12"Education"	          						///
	13"Social, community and personal services"	    ///
	14"Other services"	      						///
	15"Domestic work", replace

	label val rama_ci rama_ci


		
	*********************
    ****categopri_ci****
    *********************
	*
	/*
OBSERVACIONES: 
- El censo no distingue entre actividad principal o secundaria, asigno por default principal.
- No se tomo en cuenta por las categorias, la opcion "Patron o empleador"
- Para la categoria "Cuenta propia o independiente", se tomo en cuenta: 
	*With Paid Help (6)
	*With Unpaid Help (7)
- Para la categoria "Empleado o Asalariado", se tomo en cuenta: 
	*Government (1)
	*Private Enterprise (2)
	*Private Household (3)
	*Other (4)
- Para la categoria "Trabajador no remunerado", se tomo en cuenta: 
	*Unpaid Worker (5)
- Tener en cuenta que existe la opcion "Did not work" (8) que no se tomo en cuenta (y a veces no se condice con la variable p34)
	*/
	
	gen categopri_ci=.
	replace categopri_ci=0 if p35==9 | p35==99
	replace categopri_ci=2 if p35==6 | p35==7
	replace categopri_ci=3 if p35<=4
	replace categopri_ci=4 if emp_ci==1 & p35==5
	replace categopri_ci=. if emp_ci==0 | emp_ci==.
	 
	 
	*****************
    ***spublico_ci***
    *****************
    gen spublico_ci=(p35==1) if emp_ci==1


**********************************
**** VARIABLES DE INGRESO ****
***********************************
	*Ingreso donde el periodo de pago es "Other", se considerara como missing
   gen ylm_ci=p40b if p40a==3
	replace ylm_ci=p40b*2 if p40a==2
	replace ylm_ci=p40b*4 if p40a==1
	replace ylm_ci=. if emp_ci!=1 | p40b==900999
	replace 
 
   gen ynlm_ci=p40c
   
   bysort idh_ch : egen ylm_ch = total(ylm_ci)
   
   bysort idh_ch : egen ynlm_ch= total(ynlm_ci)
  

***************************************
************** Education **************
***************************************

	*************
	***aedu_ci***
	*************
	gen aedu_ci = .

	**************
	***eduno_ci***
	**************
	gen eduno_ci=(p22==8) if edad_ci>=3 // never attended or pre-school
	replace eduno_ci=. if  p22==9 | p22==. // NIU & missing

	**************
	***edupre_ci**
	**************
	gen edupre_ci=(p22==1) if edad_ci>=3 //
	replace edupre_ci=. if  p22==9 | p22==. // NIU & missing

	**************
	***edupi_ci***
	**************
	gen edupi_ci=.

	**************
	***edupc_ci***
	**************
	gen edupc_ci=(p22==2) if edad_ci>=3 //
	replace eduno_ci=. if  p22==9 | p22==. // NIU & missing

	**************
	***edusi_ci***
	**************
	gen edusi_ci=.
	
	**************
	***edusc_ci***
	**************
	gen edusc_ci=(p22==3) if edad_ci>=3 //
	replace eduno_ci=. if  p22==9 | p22==. // NIU & missing

	***************
	***edus1i_ci***
	***************
	gen byte edus1i_ci=.

	***************
	***edus1c_ci***
	***************
	gen byte edus1c_ci=.

	***************
	***edus2i_ci***
	***************
	gen byte edus2i_ci=.

	***************
	***edus2c_ci***
	***************
	gen byte edus2c_ci=.

	***************
	***asiste_ci***
	***************
	gen asiste_ci=(p20a==1)
		replace asiste_ci=. if p20a==9
	*label variable asiste_ci "Asiste actualmente a la escuela"

	**************
	***literacy***
	**************
	gen literacy=. 


**********************************
**** VARIABLES DE LA VIVIENDA ****
**********************************
		
	************
	*aguared_ch*
	************
	* se crea conforme las tablas de armonización IPUMS
	gen aguared_ch=(h18==1) if h18!=9
	
	********
	*luz_ch*
	********
	*En la nueva encuesta no se encontro si se pregunta por instalacion electrica
	gen luz_ch=.
	replace luz_ch=1 if c2_p11 ==1 
	replace luz_ch=0 if c2_p11 ==2
	
	*********
	*bano_ch*
	*********
	gen bano_ch=.
	replace bano_ch=1 if c2_p10
	replace bano_ch=1 if c2_p10 >= 1 & c2_p10 <= 4
	replace bano_ch=0 if c2_p10>4
	
	*********
	*des1_ch*
	*********
	gen des1_ch=.
	replace des1_ch=0 if bano_ch ==0
	replace des1_ch=1 if c2_p10 == 3
	replace des1_ch=2 if c2_p10 >=4 & c2_p10<9
	
	
	*********
	*piso_ch*
	*********
	gen piso_ch=.
	replace piso_ch = 0 if c2_p5 == 6
	replace piso_ch = 1 if c2_p5 == 2 | c2_p5 ==3
	replace piso_ch = 2 if c2_p5  == 5 | c2_p5 == 4 | c2_p5==1
	
	*****************
	*banomejorado_ch*
	*****************
	gen banomejorado_ch=.
	replace banomejorado_ch=1 if c2_p10 >= 1 & c2_p10 < 4
	replace banomejorado_ch=0 if c2_p10>=4
	
	
	**********
	*pared_ch*
	**********
	gen pared_ch=.
	replace pared_ch=2 if c2_p3 == 1 | c2_p3==2 | c2_p3 ==3 | c2_p3 ==4
	replace pared_ch=1 if c2_p3 >=5 & c2_p3 <=8
	
	**********
	*techo_ch*
	**********
	gen techo_ch=.
	replace techo_ch=2 if c2_p5 ==1 | c2_p5 == 2 | c2_p5 == 5 | c2_p5==6
	replace techo_ch=1 if c2_p5 ==2 | c2_p5 == 3 | c2_p5 == 4
	
	**********
	*resid_ch*
	**********
	* Peru no tiene está variable se genera en missing
	gen resid_ch=. 

	*********
	*dorm_ch*
	*********
	* Peru no tiene está variable se genera en missing
	gen dorm_ch=.
	
	
	************
	*cuartos_ch*
	************
	gen cuartos_ch=c2_p12
	replace cuartos_ch=. if c2_p12==99
	
	***********
	*cocina_ch*
	***********
	* Peru no tiene está variable se genera en missing
	gen cocina_ch=.
	
	***********
	*telef_ch*
	***********
	gen telef_ch=c3_p2_11
	replace telef_ch=0 if c3_p2_11==2
	
	***********
	*refrig_ch*
	***********
	gen refrig_ch=c3_p2_4
	replace refrig_ch=0 if c3_p2_4==2
	
	*********
	*auto_ch*
	*********
	gen auto_ch=c3_p2_14
	replace auto_ch = 0 if c3_p2_14==2
	
	********
	*compu_ch*
	********
	gen compu_ch=c3_p2_9
	replace compu_ch =0 if c3_p2_9==2
	
	*************
	*internet_ch*
	************* 
	gen internet_ch=c3_p2_13
	replace internet_ch=0 if c3_p2_13==2
	
	********
	*cel_ch*
	********
	gen cel_ch=c3_p2_10
	replace cel_ch=0 if c3_p2_10==2
	
	*************
	*viviprop_ch*
	*************
	*NOTA: aqui se genera una variable parecida, pues no se puede saber si es propia total o parcialmente pagada
	gen viviprop_ch1=.
	replace viviprop_ch1=1 if c2_p13 == 2 | c2_p13 == 3 
	replace viviprop_ch1=0 if c2_p13 ==1 | c2_p13 == 4
	
	

   
   
*******************************************************
***           VARIABLES DE MIGRACIÓN              ***
*******************************************************

    *******************
    ****migrante_ci****
    *******************
	gen migrante_ci =.  
	
	*******************
    **migantiguo5_ci***
    *******************
	gen migantiguo5_ci =.
	
	**********************
	*** migrantelac_ci ***
	**********************
	gen migrantelac_ci = .
	
	*******************
    **migrantiguo5_ci**
    *******************
	gen migrantiguo5_ci =.
	
	**********************
	****** miglac_ci *****
	**********************
	gen miglac_ci = .
	
	
*****************************************************
******* Variables specific for this census **********
*****************************************************

****** REGION *****************
gen region_c=ccdd
label define region_c ///
1"Amazonas"	          ///
2"Ancash"	          ///
3"Apurimac"	          ///
4"Arequipa"	          ///
5"Ayacucho"	          ///
6"Cajamarca"	      ///
7"Callao"	          ///
8"Cusco"	          ///
9"Huancavelica"	      ///
10"Huanuco"	          ///
11"Ica"	              ///
12"Junin"	          ///
13"La libertad"	      ///
14"Lambayeque"	      ///
15"Lima"	          ///
16"Loreto"	          ///
17"Madre de Dios"	  ///
18"Moquegua"	      ///
19"Pasco"	          ///
20"Piura"	          ///
21"Puno"	          ///
22"San Martín"	      ///
23"Tacna"	          ///
24"Tumbes"	          ///
25"Ucayali"	


*****************************
** Include all labels of   **
**  harmonized variables   **
*****************************
include "../Base/labels.do"


compress

save "`base_out'", replace 
log close

