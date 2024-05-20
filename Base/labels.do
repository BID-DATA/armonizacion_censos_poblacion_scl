*====================================================================================================================================*
*                                                         VARIABLES DE IDENTIFICACION                                                *
*====================================================================================================================================*
label var region_BID_c "Regiones BID"
	label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)", add modify
	label value region_BID_c region_BID_c

label var factor_ci "Factor de expansion del individuo"
label var factor_ch "Factor de expansion del hogar"

label var idh_ch "ID del hogar"
label var idp_ci "ID de personas"

label var region_c "Regiones especifica de cada país"

label var zona_c "Zona del pais"
	label define zona_c 1 "urbana" 0 "rural", add modify
	label value zona_c zona_c

	
label var pais_c "Nombre del País"
label var anio_c "Anio de la encuesta" 

label var estrato_ci "Estrato del hogar"

*====================================================================================================================================*
*                                                          VARIABLES DEMOGRAFICAS                                                    *
*====================================================================================================================================*
label var relacion_ci "Relacion o parentesco con el jefe del hogar"
	label define relacion_ci 1 "Jefe/a" 2 "Conyuge/esposo/compañero" 3 "Hijo/a" 4 "Otros_parientes" 5 "Otros_no_Parientes" 6 "Empleado/a_domestico/a" 9 "Desconocida", add modify 
	label values relacion_ci relacion_ci
	
label var sexo_ci "Sexo del individuo" 
	label define sexo_ci 1 "Hombre" 2 "Mujer", add modify
	label value sexo_ci sexo_ci

label var edad_ci "Edad del individuo en años"
label var civil_ci "Estado civil"
	label define civil_ci 1 "soltero/a" 2 "union_formal/informal" 3 "divorciado/a_o_separado/a" 4 "Viudo/a" , add modify
	label value civil_ci civil_ci
	
	label var nconyuges_ch "# de conyuges en el hogar"
label var nhijos_ch "# de hijos en el hogar"
label var notropari_ch "# de otros familiares en el hogar"	
label var notronopari_ch "# de no familiares en el hogar"
label var nempdom_ch "# de empleados domesticos"
label var clasehog_ch "Tipo de hogar"
	label define clasehog_ch 1 "unipersonal" 2 "nuclear" 3 "ampliado" 4 "compuesto" 5 "corresidente", add modify
	label value clasehog_ch clasehog_ch
	

label var nmayor21_ch "# de familiares mayores a 21 anios en el hogar"
label var nmenor21_ch "# de familiares menores a 21 anios en el hogar"
label var nmayor65_ch "# de familiares mayores a 65 anios en el hogar"
label var nmenor6_ch "# de familiares menores a 6 anios en el hogar"
label var nmenor1_ch "# de familiares menores a 1 anio en el hogar"
label var miembros_ci "=1: es miembro del hogar"
label var nmiembros_ch "# de miembros en el hogar"
	
	
label var dis_ci "Personas con discapacidad"
	label define dis_ci 1 "Con Discapacidad" 0 "Sin Discapacidad"
	label val dis_ci dis_ci
	
label var dis_ch "Hogares con miembros con discapacidad"
	label define dis_ch 0 "Hogares sin miembros con discapacidad"1 "Hogares con al menos un miembro con discapacidad" 
	label val dis_ch dis_ch 

label var afroind_ci "Raza o etnia del individuo"
	label define afroind_ci 1 "Indígena" 2 "Afro-descendiente" 3 "Otros" 9 "No se le pregunta"
	label val afroind_ci afroind_ci 

label var afroind_ch "Raza/etnia del hogar en base a raza/etnia del jefe de hogar"
	label define afroind_ch 1 "Hogares con Jefatura Indígena" 2 "Hogares con Jefatura Afro-descendiente" 3 "Hogares con Jefatura Otra" 9 "Hogares sin Información étnico/racial"
	label val afroind_ch afroind_ch 

label var afroind_ano_c "Año Cambio de Metodología Medición Raza/Etnicidad"
	
label var jefe_ci "Jefe/a de hogar"
label var nhijos_ch "# de hijos en el hogar"
label var nmiembros_ch "# de miembros en el hogar"

*====================================================================================================================================*
*                                                          VARIABLES DEL MERCADO LABORAL                                              *
*====================================================================================================================================*
label var condocup_ci "Condicion de ocupación de acuerdo a def armonizada para cada pais"
	label define condocup_ci 1 "Ocupado" 2 "Desocupado" 3 "Inactivo" 4 "No_responde_por_menor_edad", add modify
	label value condocup_ci condocup_ci
	
/*label var ocupa_ci "Ocupacion laboral en la actividad principal"  
	label define ocupa_ci 1"profesional_y_tecnico" 2"director_o_funcionario_sup" 3"administrativo_y_nivel_intermedio", add modify
	label define ocupa_ci  4 "comerciantes_y_vendedores" 5 "en_servicios" 6 "trabajadores_agricolas", add modify
	label define ocupa_ci  7 "obreros_no_agricolas,_conductores_de_maq_y_ss_de_transporte", add modify
	label define ocupa_ci  8 "FFAA" 9 "otras", add modify
	label value ocupa_ci ocupa_ci
*/
label var emp_ci "=1: si ocupado (empleado)"

label var desemp_ci "Desempleado que buscó empleo en el periodo de referencia"

label var pea_ci "Población Económicamente Activa"


label var categopri_ci "Categoria ocupacional en la actividad principal"
	label define categopri_ci 1"Patron" 2"Cuenta propia" 3"Empleado" 4" No_remunerado" 0 "Otro" , add modify
	label value categopri_ci categopri_ci
/*label var categosec_ci "Categoria ocupacional en la actividad secundaria"
	label define categosec_ci 1"Patron" 2"Cuenta_propia" 3"Empleado" 4" No_remunerado" 0 "Otro" , add modify
	label value categosec_ci categosec_ci
	
*label var contrato_ci "Ocupados que tienen contrato firmado de trabajo"
label var tipocontrato_ci "Tipo de contrato segun su duracion"
label define tipocontrato_ci 0 "Con contrato" 1 "Permanente/indefinido" 2 "Temporal" 3 "Sin_contrato/verbal", add modify
label value tipocontrato_ci tipocontrato_ci
*label var segsoc_ci "Personas que tienen seguridad social en SALUD por su trabajo" - ver si se incluye
label var nempleos_ci "# de empleos" 
	capture label define nempleos_ci 1 "Un empleo" 2 "Mas de un empleo"
	capture label value nempleos_ci nempleos_ci
*label var firmapeq_ci "=1: Trabajadores en empresas de <5 personas ~informales" /*esta variable se reemplaza por tamemp_ci*/
label var tamemp_ci "# empleados en la empresa segun rangos"
	label define tamemp_ci 1 "Pequena" 2 "Mediana" 3 "Grande", add modify
	label value tamemp_ci tamemp_ci
*/	
label var spublico_ci "=1: Personas que trabajan en el sector público"

 label var rama_ci "Rama de actividad"
    label def rama_ci 1"Agricultura, pesca y forestal" 2"Minería y extracción" 3"Industrias manufactureras" 4"Electricidad, gas, agua y manejo de residuos" 5"Construcción" 6"Comercio" 7"Hoteles y restaurantes" 8"Transporte, almacenamiento y comunicaciones" 9"Servicios financieros y seguros" 10"Administración pública y defensa" 11"Servicios empresariales e inmobiliarios" 12"Educación" 13"Salud y trabajo social" 14"Otros servicios" 15"Servicio doméstico", add modify
    label val rama_ci rama_ci	
*====================================================================================================================================*
*                                                          VARIABLES DE INGRESO                                              *
*====================================================================================================================================*	
	label var ylm_ci "Ingreso laboral monetario total individual"
	label var ynlm_ci "Ingreso no laboral monetario total individual"
	label var ylm_ch "Ingreso laboral monetario del hogar"
	label var ynlm_ch "Ingreso no laboral monetario del hogar"
/*	
label var durades_ci "Duracion del desempleo en meses"
	
	*Actividad Principal
label var ylmpri_ci "Ingreso laboral monetario actividad principal" 
label var nrylmpri_ci "ID de no respuesta ingreso de la actividad principal"  
label var ylnmpri_ci "Ingreso laboral NO monetario actividad principal"  
label var tcylmpri_ci "Identificador de top-code del ingreso de la actividad principal" 
	* Actividad secundaria
label var ylmsec_ci "Ingreso laboral monetario segunda actividad" 
label var ylnmsec_ci "Ingreso laboral NO monetario actividad secundaria"
	* Otros ingresos laborales
label var ylmotros_ci "Ingreso laboral monetario de otros trabajos"
label var ylnmotros_ci "Ingreso laboral NO monetario de otros trabajos" 
	* Ingresos no laborales
label var autocons_ci "Autoconsumo reportado por el individuo"
label var remesas_ci "Remesas mensuales reportadas por el individuo" 
label var ylmhopri_ci "Salario monetario horario de la actividad principal" 
label var ylmho_ci "Salario monetario horario de todas las actividades" 
			* Totales individuales
label var ylnm_ci "Ingreso laboral NO monetario total individual"  	  
label var ynlnm_ci "Ingreso no laboral no monetario total individual" 
			
			* Totales a nivel de hogar
label var nrylmpri_ch "Hogares con algún miembro que no respondió por ingresos"
label var ylm_ch "Ingreso laboral monetario del hogar"
label var ylnm_ch "Ingreso laboral no monetario del hogar"
label var ylmnr_ch "Ingreso laboral monetario del hogar con missing en NR"
label var ynlm_ch "Ingreso no laboral monetario del hogar"
label var ynlnm_ch "Ingreso no laboral no monetario del hogar"
label var rentaimp_ch "Rentas imputadas del hogar"
label var autocons_ch "Autoconsumo reportado por el hogar"
label var remesas_ch "Remesas mensuales del hogar"	
label var ypen_ci "Monto de ingreso por pension contributiva"
label var ypensub_ci "Monto de ingreso por pension subsidiada / no contributiva"
* LINEAS DE POBREZA y OTRAS VARIABLES EXTERNAS DE REFERENCIA
capture label var lp19_ci  "Línea de pobreza USD1.9 día en moneda local a precios corrientes a PPA 2011"
capture label var lp31_ci  "Línea de pobreza USD3.1 día en moneda local a precios corrientes a PPA 2011"
capture label var lp5_ci "Línea de pobreza USD5 por día en moneda local a precios corrientes a PPA 2011"
capture label var tc_c "Tasa de cambio LCU/USD Fuente: WB/WDI"
capture label var ipc_c "Índice de precios al consumidor base 2011=100 Fuente: IMF/WEO"
capture label var ppa_c "Factor de conversión Paridad de Poder Adquisitivo PPA LCU/USD 2011 Fuente: WB/WDI"
label var lp_ci "Linea de pobreza oficial del pais en moneda local a precios corrientes"
label var lpe_ci "Linea de indigencia oficial del pais en moneda local a precios corrientes"
label var salmm_ci "Salario minimo legal a precios corrientes"
*/

*====================================================================================================================================*
*                                                          VARIABLES DE SEGURIDAD SOCIAL                                             *
*====================================================================================================================================*
/*
label var cotizando_ci "Cotizante a la Seguridad Social (SS)"
	label define cotizando_ci 0"No_cotiza" 1"Cotiza_a_SS", add modify 
	label value cotizando_ci cotizando_ci
label var afiliado_ci "Afiliado a la Seguridad Social"
	label define afiliado_ci 0"No_afiliado" 1"Afiliado_a_SS", add modify 
	label value afiliado_ci afiliado_ci
	
label var tipopen_ci "Tipo de pension - variable original de cada pais" 
label var instpen_ci "Institucion proveedora de la pension - variable original de cada pais" 
label var instcot_ci "Institucion a la cual cotiza o es afiliado - variable original de cada pais" 
label var pension_ci "=1: Recibe pension contributiva"
label var pensionsub_ci "=1: recibe pension subsidiada / no contributiva"
*/

*====================================================================================================================================*
*                                                          VARIABLES DE EDUCACION                                             *
*====================================================================================================================================*
label var aedu_ci "Anios de educacion aprobados"
    label def aedu_ci 0"Cero o preescolar" 1"1 año" 2"2 años" 3"3 años" 4"4 años" 5"5 años" 6"6 años" 7"7 años" 8"8 años" 9"9 años" 10"10 años" 11"11 años" 12"12 años" 13"13 años" 14"14 años" 15"15 años" 16"16 años" 17"17 años" 18"18 años o más"  
    label val aedu_ci aedu_ci	

label var asiste_ci "Personas que actualmente asisten a centros de enseñanza"
label var eduno_ci "Cero anios de educacion"
label var edupre_ci "Personas con preescolar como maximo nivel educativo alcanzado"
label var edupi_ci "Primaria incompleta"
label var edupc_ci "Primaria completa"
label var edusi_ci "Secundaria incompleta"
label var edusc_ci "Secundaria completa"
label var edus1i_ci "1er ciclo de la secundaria incompleto"
label var edus1c_ci "1er ciclo de la secundaria completo"
label var edus2i_ci "2do ciclo de la secundaria incompleto"
label var edus2c_ci "2do ciclo de la secundaria completo"
label var literacy "Alfabetización"

*====================================================================================================================================*
* VARIABLES DE INFRAESTRUCTURA DEL HOGAR                       *
*====================================================================================================================================*

label var aguared_ch "Acceso a fuente de agua por red"

label var luz_ch  "La principal fuente de iluminación es electricidad"

label var bano_ch "El hogar tiene servicio sanitario"

label var des1_ch "Tipo de desague según unimproved de MDG"
	label define des1_ch 0 "No_tiene_servicio_sanitario" 1 "Conectado_a_red_general_o_cámara_séptica" 2"Letrina_o_conectado_a_pozo_ciego" 3"Desemboca_en_río_o_calle", add modify
	label values des1_ch des1_ch

	label var auto_ch "El hogar posee automovil particular"
	
label var piso_ch "Materiales de construcción del piso"  
	label define piso_ch 0"Sin piso o sin terminar" 1 "Piso de tierra" 2 "Materiales_permanentes", add modify
	label values piso_ch piso_ch

label var banomejorado_ch "Tipo de desague"
	label define banomejorado_ch 0 "No tiene servicio sanitario" 1"Eliminacion de aguas residuales o fosa séptica"
	label values banomejorado_ch banomejorado_ch
	
label var pared_ch "Materiales de construcción de las paredes"
	label define pared_ch 0 "No tiene paredes"  1	"Materiales no permanentes" 2 "Materiales permanentes", add modify
	label values pared_ch pared_ch

label var techo_ch "Materiales de construcción del techo" 
	label define techo_ch 1 "Materiales_permanentes"  0"Materiales_no_permanentes" 2 "Otros_materiales", add modify
label values techo_ch techo_ch 

label var resid_ch "Método de eliminación de residuos" 
	label define resid_ch 0"Recolección pública o privada" 1"Quemados o enterrados" 2 "Tirados a un espacio abierto" 3"Otros", add modify
label values resid_ch resid_ch
	
label var dorm_ch "# de habitaciones exclusivas para dormir"
label var cuartos_ch "# Habitaciones en el hogar"

label var cocina_ch "Cuarto separado y exclusivo para cocinar"

label var telef_ch "El hogar tiene servicio telefónico fijo"

label var refrig_ch "El hogar posee refrigerador o heladera"

label var auto_ch "El hogar posee automovil"

label var compu_ch "El hogar posee computadora"

label var internet_ch "El hogar posee conexión a internet"

label var cel_ch "El hogar tiene servicio telefonico celular"

label var viviprop_ch1 "Propiedad de la vivienda" 
	label def viviprop_ch 0"Alquilada" 1"Propia" 3"Ocupada_(propia_de_facto)", add modify
	label val viviprop_ch viviprop_ch1
	
	
***********************************
***    VARIABLES DE MIGRACIÓN.  ***
***********************************
	label var migrante_ci "=1 si es migrante"

	label var migantiguo5_ci "=1 si es migrante antiguo (5 anos o mas)"
	
	label var migrantelac_ci "=1 si es migrante proveniente de un pais LAC"
	
	label var migrantiguo5_ci "=1 si es migrante antiguo (5 anos o mas)(sobre población migrante)"
	
	label var miglac_ci "=1 si es migrante proveniente de un pais LAC(sobre población migrante)"
	
	
	
	
* labels de variables

*====================================================================================================================================*
*                                                     INCLUSIóN DE VARIABLES EXTERNAS                                                *
*====================================================================================================================================*
capture drop _merge
merge m:1 pais_c anio_c using "$ruta\5_International_Poverty_Lines_LAC_long.dta",   keepusing (ppp_2011 cpi_2011 lp19_2011 lp31_2011 lp5_2011 tc_wdi ppp_wdi2011)

drop if _merge ==2

g tc_c     = tc_wdi
g ipc_c    = cpi_2011
*g ppa_c    = ppp_wdi2011
g lp19_ci  = lp19_2011 
g lp31_ci  = lp31_2011 
g lp5_ci   = lp5_2011

*----------------------------------------------------------------------------------------------*
*se debe eliminar una vez se actualice la linea de pobreza en Oct. 2021: lp31_ci2020= lp31_ci2019* (1.42015)

replace lp31_ci = 2800.9949*1.420151 if anio_c==2020 & pais_c=="ARG" 

replace lp19_ci = 1716.7388*1.420151 if anio_c==2020 & pais_c=="ARG" 

replace lp5_ci = 4517.7334*1.420151 if anio_c==2020 & pais_c=="ARG" 

*--------------------------------------------------------------------------------------------*

drop ppp_2011 cpi_2011 lp19_2011 lp31_2011 lp5_2011 tc_wdi _merge	
