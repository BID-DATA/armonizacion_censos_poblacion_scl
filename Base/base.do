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

	
	*********
	*anio_c*
	*********
	rename year anio_c
	
	******************
    *idh_ch (id hogar)*
    ******************
    gen str13 idh_ch=string(serial)
	
	
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
	rename strata estrato_ci
	
	***************************
	* Zona urbana (1) o rural (0)
	***************************
	replace urban = urban-1
	rename urban zona_c 
	

    ****************************
	***VARIABLES DEMOGRAFICAS***
	****************************
	
	*********
	*sexo_c*
	*********
	rename sex sexo_ci
	
	*********
	*edad_c*
	*********
	rename age edad_ci
	

 	*************
	*relacion_ci*
	*************	
	gen relacion_ci=1 if relate==1000
    replace relacion_ci=2 if relate==2000
    replace relacion_ci=3 if relate==3000
    replace relacion_ci=4 if relate==4100 | relate==4200 | relate==4900
    replace relacion_ci=5 if relate==5310 | relate==5600 | relate==5900
    replace relacion_ci=6 if relate==5210
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
	
    rename nchild nhijos_ch
 	
 	
	*****************************
	* Numero de miembros en el hogar
	*****************************
	rename persons nmiembros_ch 
	

	***********************************
	***VARIABLES DE EDUCACIÓN       ***
	***********************************	

	rename yrschool aedu_ci


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
	

	
	