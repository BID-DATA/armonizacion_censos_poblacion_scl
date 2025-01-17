

 *************************************
 *** Identificación (12 variables) ***
 *************************************
 
label var region_BID_c "Región a la que pertenece el país según la clasificación utilizada por el BID"
label define region_BID_c 1 "Centroamérica (CID)" 2 "Caribe (CCB)" 3 "Andinos (CAN)" 4 "Cono Sur (CSC)", add modify
label val region_BID_c region_BID_c

label var region_c "División geográfica al nivel administrativo 1 original del país"

label var geolev1 "División geográfica política-administrativa en el formato de IPUMS"

label var pais_c "Nombre del país"

label var anio_c "Anio del censo" 

label var idh_ch "Identificador único del hogar"

label var idp_ci "Identificador único del invididuo"

label var factor_ci "Factor de expansión a nivel del individuo"

label var factor_ch "Factor de expansión a nivel del hogar"

label var estrato_ci "Estratificación de la muestra para mejorar estimación "

label var upm "Unidad primaria de muestreo"

label var zona_c "Zona del país"
label define zona_c 1 "Urbana" 0 "Rural", add modify
label val zona_c zona_c

 ************************************
 *** 2. Demografía (18 variables) ***
 ************************************

label var sexo_ci "Sexo del individuo" 
label define sexo_ci 1 "Hombre" 2 "Mujer", add modify
label val sexo_ci sexo_ci
	
label var edad_ci "Edad del individuo en anios"

label var relacion_ci "Relación o parentesco con el jefe(a) del hogar"
label define relacion_ci 1 "Jefe(a)" 2 "Cónyuge/esposo(a)/compañero(a)" 3 "Hijo(a)" 4 "Otros parientes" 5 "Otros no parientes" 6 "Empleado(a) domestico(a)", add modify 
label val relacion_ci relacion_ci

label var civil_ci "Estado civil del individuo"
label define civil_ci 1 "Soltero(a)" 2 "Union formal/informal" 3 "Divorciado(a) o separado(a)" 4 "Viudo(a)" , add modify
label val civil_ci civil_ci	
	
label var jefe_ci "Jefe(a) del hogar declarado(a)"
label define jefe_ci 1 "Sí es jefe(a) del hogar" 0 "No es jefe(a) del hogar", add modify
label val jefe_ci jefe_ci

label var nconyuges_ch "Número de cónyuges o esposo(a)s en el hogar"

label var nhijos_ch "Número de hijo(a)s en el hogar"

label var notropari_ch "Número de otros parientes en el hogar"	

label var notronopari_ch "Número de otros habitantes del hogar que no son parientes"

label var nempdom_ch "Número de empleado(a)s doméstico(a)s en el hogar"

label var miembros_ci "Individuos que son miembros del hogar"
label define jefe_ci 1 "Sí es miembro del hogar" 0 "No es miembro del hogar", add modify
label val jefe_ci jefe_ci

label var clasehog_ch "Tipo de hogar"
label define clasehog_ch 1 "Unipersonal" 2 "Nuclear" 3 "Ampliado" 4 "Compuesto" 5 "Corresidente", add modify
label val clasehog_ch clasehog_ch
	
label var nmiembros_ch "Número de miembros en el hogar"

label var nmayor21_ch "Número de miembros en el hogar con 21 anios o más de edad"

label var nmenor21_ch "Número de miembros en el hogar menores a 21 anios de edad"

label var nmayor65_ch "Número de miembros en el hogar mayores a 65 anios de edad"

label var nmenor6_ch "Número de miembros en el hogar menores a 6 anios de edad"

label var nmenor1_ch "Número de miembros en el hogar menores a 1 anio de edad"


 ************************************
 *** 3. Diversidad (11 variables) ***
 ************************************	
 
label var afro_ci "Etnia/raza del individuo afrodescendiente"
label define afro_ci 1 "Afrodescendiente" 0 "No afrodescendiente"
label val afro_ci afro_ci

label var ind_ci "Etnia/raza del individuo índigena"
label define ind_ci  1 "Indígena" 0 "No indígena"
label val ind_ci ind_ci

label var noafroind_ci "Etnia/raza del invididuo ni afrodescendiente ni indígena"
label define noafroind_ci 1 "Ni afrodescendiente ni indígena" 0 "Afrodescendiente y/o indígena"
label val noafroind_ci noafroind_ci 

label var afroind_ci "Etnia/raza del individuo"
label define afroind_ci  1 "Indígena" 2 "Afrodescendiente" 3 "Otro"
label val afro_ci afro_ci

label var afro_ch "Etnia/raza del hogar afrodescendiente según la jefatura del hogar"
label define afro_ch  1 "Hogar con jefatura afrodescendiente" 0 "Hogar con jefatura no afrodescendiente"
label val afro_ch afro_ch

label var ind_ch "Etnia/raza del hogar indígena según la jefatura del hogar"
label define ind_ch 1 "Hogar con jefatura indígena" 0 "Hogar con jefatura no indígena"
label val ind_ch ind_ch

label var noafroind_ch "Etnia/raza del hogar ni afrodescendiente ni indígena según la jefatura del hogar"
label define noafroind_ch 1 "Hogar con jefatura ni afrodescendiente ni indígena" 0 "Hogar con jefatura afrodescendiente y/o indígena"
label val noafroind_ch noafroind_ch

label var afroind_ch "Etnia/raza del hogar según la jefatura del hogar"
label define afroind_ch  1 "Indígena" 2 "Afrodescendiente" 3 "Otro"
label val afroind_ch afroind_ch 

label var dis_ci "Individuos con condición de discapacidad - criterio flexible del WG"
label define dis_ci 1 "Con condición de discapacidad" 0 "Sin condición de discapacidad"
label val dis_ci

label var disWG_ci "Individuos con condición de discapacidad - criterio estricto del WG"	 
label define disWG_ci 1 "Con condición de discapacidad" 0 "Sin condición de discapacidad"
label val disWG_ci disWG_ci 

label var dis_ch "Miembros con condición de discapacidad en el hogar - criterio flexible del WG"	 
label define dis_ch 1 "Hogares sin miembros con condición de discapacidad" 0 "Hogares con al menos un miembro con condición de discapacidad"
label val dis_ch dis_ch
	 

**********************************
*** 4. Migración (3 variables) ***
**********************************

label var migrante_ci "Migrante (nació en otro país)"	 
label define migrante_ci 1 "Sí es un migrante" 0 "No es un migrante"
label val migrante_ci migrante_ci

label var migrantiguo5_ci "Migrante que lleva viviendo más de 5 años en el país del censo (migrante antiguo)"	 
label define migrantiguo5_ci 1 "Sí es un migrante antiguo" 0 "No es un migrante antiguo"
label val migrantiguo5_ci migrantiguo5_ci

label var miglac_ci "Migrante nacido(a) en algún país de la América Latina y el Caribe"	 
label define miglac_ci 1 "Sí es un migrante nacido(a) en América Latina y el Caribe" 0 "No es un migrante nacido(a) en América Latina y el Caribe"
label val miglac_ci miglac_ci

***********************************
*** 5. Educación (13 variables) ***
***********************************

label var aedu_ci "Número de años de educación culminados del individuo censado"	 

label var eduno_ci "Individuos sin ningún año o grado de educación formal aprobado"
label define eduno_ci  1 "No tiene ningún año o grado de educación formal aprobado" 0 "Tiene al menos un año de educación formal aprobado "
label val eduno_ci eduno_ci

label var edupi_ci "Individuos con primaria incompleta" 
label define edupi_ci 1 "Máximo nivel educativo alcanzado es primaria incompleta" 0 "Máximo nivel educativo alcanzado diferente a primaria incompleta"
label val edupi_ci edupi_ci  

label var edupc_ci "Individuos con primaria completa"
label define edupc_ci 1 "Máximo nivel educativo alcanzado es primaria completa" 0  "Máximo nivel educativo alcanzado diferente a primaria completa"
label val edupc_ci edupc_ci

label var edusi_ci "Individuos con secundaria incompleta"
label define edusi_ci 1 "Máximo nivel educativo alcanzado es secundaria incompleta" 0  "Máximo nivel educativo alcanzado diferente a secundaria incompleta"
label val edusi_ci edusi_ci

label var edusc_ci  "Individuos con secundaria completa"
label define edusc_ci 1 "Máximo nivel educativo alcanzado es secundaria completa" 0 "Máximo nivel educativo alcanzado diferente a secundaria completa"
label val edusc_ci edusc_ci  
	
label var edus1i_ci "Individuos con el 1er ciclo de secundaria incompleta"  
label define edus1i_ci  1 "Máximo nivel educativo alcanzado es 1er ciclo de secundaria incompleta" 0 "Máximo nivel educativo alcanzado diferente a 1er ciclo de secundaria incompleta"
label value edus1i_ci edus1i_ci 

label var  edus1c_ci "Individuos con el 1er ciclo de secundaria completa"
label define edus1c_ci 1 "Máximo nivel educativo alcanzado es 1er ciclo de secundaria completa" 0 "Máximo nivel educativo alcanzado diferente a 1er ciclo de secundaria completa"
label value edus1c_ci edus1c_ci

label var edus2i_ci "Individuos con el 2do ciclo de secundaria incompleta"  
label define edus2i_ci 1 "Máximo nivel educativo alcanzado es 2do ciclo de secundaria incompleta" 0  "Máximo nivel educativo alcanzado diferente a 2do ciclo de secundaria incompleta"
label value edus2i_ci edus2i_ci 

label var  edus2c_ci "Individuos con el 2do ciclo de secundaria completa" 
label define edus2c_ci 1 "Máximo nivel educativo alcanzado es 2do ciclo de secundaria completa" 0 "Máximo nivel educativo alcanzado diferente a 2do ciclo de secundaria completa"
label value edus2c_ci edus2c_ci   

label var  edupre_ci "Individuos con educación preescolar completa" 
label define edupre_ci  1 "Sí tiene educación preescolar completa" 0 "No tiene educación preescolar completa"
label value edupre_ci  edupre_ci  

label var asiste_ci "Individuos que asisten a algún centro de enseñanza al momento de ser censados"
label define asiste_ci  1 "Sí asiste a algún centro de enseñanza (considerando centros de primaria, secundaria y terciaria)" 0 "No asiste a algún centro de enseñanza"
label value asiste_ci asiste_ci 

label var  literacy  "Individuos alfabetizados"
label define literacy  1 "Alfabetizado" 0 "Analfabeto"
label value literacy literacy 

****************************************
*** 6. Mercado laboral (7 variables) ***
****************************************
 
label var condocup_ci  "Condición de ocupación de los individuos"
label define condocup_ci 1 "Ocupado" 2 "Desocupado" 3 "Inactivo" 4 "No responde por ser menor de edad"
label value condocup_ci condocup_ci

label var emp_ci "Individuos ocupados"
label define emp_ci 1 "Sí es ocupado" 0 "No es ocupado"
label value emp_ci emp_ci

label var  desemp_ci "Individuos desocupados que buscan trabajo"
label define desemp_ci 1 "Sí es desocupado" 0 "No es desocupado"
label value desemp_ci desemp_ci

label var pea_ci "Individuos que forman parte de la fuerza laboral"
label define pea_ci 1 "Sí forma parte de la fuerza laboral" 0 "No forma parte de la fuerza laboral"
label value pea_ci pea_ci

label var  rama_ci "Rama de la actividad laboral de la ocupacion principal" 
label def rama_ci 1"Agricultura, pesca y forestal" 2"Minería y extracción" 3"Industrias manufactureras" 4"Electricidad, gas, agua y manejo de residuos" 5"Construcción" 6"Comercio" 7"Hoteles y restaurantes" 8"Transporte, almacenamiento y comunicaciones" 9"Servicios financieros y seguros" 10"Administración pública y defensa" 11"Servicios empresariales e inmobiliarios" 12"Educación" 13"Salud y trabajo social" 14"Otros servicios" 15"Servicio doméstico", add modify
label val rama_ci rama_ci	
	
label var  categopri_ci "Categoría ocupacional de la actividad principal para los ocupados"
label define categopri_ci 0 "Otra clasificación" 1"Patrón o empleador" 2"Cuenta propia o independiente" 3"Empleado o asalariado" 4"Trabajador no remunerado"
label value categopri_ci categopri_ci
	
label var spublico_ci "Individuos que trabajan en el sector público"
label define spublico_ci 1 "Sí trabaja en el sector público" 0 "No trabaja en el sector público"
label value spublico_ci spublico_ci

		
 **********************************************************
 ***  7.1 Vivienda - variables generales (15 variables) ***
 **********************************************************		

label var luz_ch  "La principal fuente de iluminación de la vivienda es electricidad"
label define luz_ch 1 "La principal fuente sí es la electricidad" 0 "La principal fuente no es la electricidad"
label value luz_ch luz_ch
	
label var piso_ch  "Materiales de construcción del piso"  
label define piso_ch 0 "Sin piso, sin terminar o de tierra" 1 "Materiales no permanentes" 2 "Materiales permanentes (cemento u otros)"
label value piso_ch piso_ch

label var pared_ch  "Materiales de construcción de las paredes"
label define pared_ch 0 "No tiene paredes" 1 "Materiales no permanentes" 2 "Materiales permanentes"
label value pared_ch pared_ch
	
label var techo_ch  "Materiales de construcción del techo"
label define techo_ch  0 "No tiene techo" 1 "Materiales no permanentes" 2 "Materiales permanentes"
label value techo_ch techo_ch

label var resid_ch  "Método de eliminación de residuos"
label define resid_ch 0 "Servicio de recolección pública o privada" 1 "Servicio de quemados o enterrados" 2 "Servicio de tirado a un espacio abierto" 3 "Otro método"
label value resid_ch resid_ch
	
label var dorm_ch "Número de habitaciones destinadas generalmente a dormir" 

label var cuartos_ch  "Número de cuartos"

label var cocina_ch  "El hogar tiene alguna habitación separada exclusiva para cocinar"
label define cocina_ch 1 "Sí tiene una habitación exclusiva para cocinar" 0 "No tiene una habitación exclusiva para cocinar"
label value cocina_ch cocina_ch

label var  telef_ch "El hogar tiene servicio telefónico fijo"
label define telef_ch 1 "Sí tiene servicio telefónico fijo" 0 "No tiene servicio telefónico fijo"
label value telef_ch telef_ch

label var  refrig_ch "El hogar tiene refrigerador"
label define refrig_ch 1 "Sí tiene refrigerador" 0 "No tiene refrigerador"
label value	 refrig_ch refrig_ch
	
label var  auto_c "El hogar tiene automóvil"
label define auto_c 1 "Sí tiene automóvil" 0 "No tiene automóvil"
label value auto_c auto_c
	
label var  compu_ch "El hogar tiene computadora"
label define compu_ch 1 "Sí tiene computadora" 0 "No tiene computadora"
label value compu_ch compu_ch

label var  internet_ch "El hogar cuenta con servicio de internet"
label define internet_ch 1 "Sí tiene servicio de internet" 0 "No tiene servicio de internet"
label value internet_ch internet_ch

label var  cel_ch "El hogar cuenta con servicio telefónico celular"
label define cel_ch 1 "Sí tiene servicio telefónico celular" 0 "No tiene servicio telefónico celular"
label value cel_ch cel_ch

label var  viviprop_ch "Propiedad de la vivienda en la que reside el hogar"
label define viviprop_ch 1 "Sí pertenece a los habitantes del hogar" 0 "No pertenece a los habitantes del hogar"
label value viviprop_ch viviprop_ch


 ******************************************************
 ***  7.2 Vivienda - variables WASH (13 variables) ***
 *****************************************************

label var aguaentubada_ch "El hogar tiene acceso a agua entubada"
label define aguaentubada_ch 1 "Sí cuenta con agua entubada " 0 "No cuenta con agua entubada"
label value aguaentubada_ch aguaentubada_ch

label var aguared_ch "El hogar tiene acceso a un servicio de agua por red"
label define aguared_ch 1 "Sí cuenta con servicio de agua por red" 0 "No cuenta con servicio de agua por red"
label value aguared_ch aguared_ch

label var aguafuente_ch  "Fuente del agua utilizada por el hogar"
label define aguafuente_ch 1	"Red de distribución, llave privada" 2	"Red (llave pública, standpipe)" 3	"Agua embotellada" 4	"Pozo protegido" 5	"Agua de lluvia" 6	"Camión, cisterna, pipa" 7	"Otra fuente mejorada" 8	"Cuerpo de agua superficial"  9	"Otra fuente no mejorada" 10	"Pozo, mantial o otra sin clasificación clara"
label value aguafuente_ch aguafuente_ch 

label var aguadist_ch  "Distancia de la ubicación de acceso al agua"
label define aguadist_ch 1	"Adentro de la casa" 2	"Afuera de la casa pero adentro del terreno (o a menos de 100mts de distancia)" 3	"Afuera de la casa y afuera del terreno (o a más de 100mts de distancia)" 0	"No se especifica"
label value aguadist_ch aguadist_ch 

label var aguadisp1_ch "Disponibilidad de agua si la encuesta pregunta si el hogar tiene suficiente continuidad del acceso al agua"
label define aguadisp1_ch 0	"No" 1	"Sí" 9	"La encuesta no hace esta pregunta"
label value aguadisp1_ch aguadisp1_ch

label var aguadisp2_ch "Disponibilidad de agua si la encuesta mide la continuidad al acceso a agua de manera cuantitativa"
label define aguadisp2_ch 1	"Reporta corte y el agua está disponible menos de la mitad del tiempo" 2	"Reporta corte pero el agua está disponible más de la mitad del tiempo" 3	"Reporta que no han tenido corte de agua durante el periodo" 9	"La encuesta no hace esta pregunta"
label value aguadisp2_ch aguadisp2_ch

label var aguamide_ch "El hogar tiene un medidor de agua"
label define aguamide_ch 0	"No" 1	"Sí" 9	"La encuesta no hace esta pregunta"
label value  aguamide_ch  aguamide_ch 

label var bano_ch "Instalación sanitaria disponible en el hogar"
label define bano_ch 0	"Sin instalaciones" 1	"Indoro a red de desagüe" 2	"Indoro a fosa séptica" 3	"Letrina mejorada / otra instalacion mejorada" 4	"Indoro/letrina a cuerpo de agua superficial o suelo" 5	"Instalación no mejorada" 6	"Instalación que no se puede clasificar"
label value bano_ch bano_ch

label var banoex_ch  "El uso del baño es exclusivo al hogar"
label define banoex_ch 0	"No" 1	"Sí" 9	"La encuesta no hace esta pregunta"
label value banoex_ch banoex_ch 

label var sinbano_ch "Indica qué hacen los hogares que no tienen baños para sus necesidades sanitarias"
label define sinbano_ch 0	"Tiene baño" 1	"Utliza instalaciones públicas, o las de un vecino o amigo" 2	"Defecación al aire libre" 3	"No tiene baño y no se pregunta qué alternativas se usan en el hogar"
label value sinbano_ch sinbano_ch 

label var conbano_ch "El hogar tiene algún tipo de servicio higiénico (inodoro o letrina)"
label define conbano_ch 1 "Sí tiene un servicio higiénico como letrina o inodoro" 0 "No tiene un servicio higiénico como letrina o inodoro"
label value conbano_ch conbano_ch

label var banoalcantarillado_ch "El hogar tiene acceso a alcantarillado"
label define banoalcantarillado_ch 0 "No tiene acceso a alcantarillado" 1 "Sí tiene acceso a alcantarillado"
label value banoalcantarillado_ch banoalcantarillado_ch

label var des1_ch "Tipo de desagüe con el que cuenta el hogar"
label define des1_ch 0	"No tiene servicio sanitario" 1	"Escusado conectado a la red" 2	"Letrina u otro servicio no conectado a la red"
label value des1_ch des1_ch



	
	
	
	
