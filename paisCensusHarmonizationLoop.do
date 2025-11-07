capture program drop open_file                                                        
program open_file
  args pais ano
  
	global ruta = "${surveysFolder}"
	local mydir "${gitFolder}/calculo_indicadores_encuestas_hogares_scl"
	* Directory containing do-Files used as input
	global input "`mydir'/Input"
	include "${input}/Directorio HS LAC.do"
	display "${source}/`pais'//$encuestas/data_arm//`pais'_`ano'${rondas}_BID.dta - no se encontró el archivo. Generando missing values..."
 
	local base_in = "$ruta\harmonized\\`pais'\\$encuestas\data_arm\\`pais'_`ano'${rondas}_BID.dta"
	use `base_in', clear
 
end
 
 
*SUR NIC ARG BOL BRA CHL CRI DOM SLV HTI HND TTO URY
local paisess SUR NIC ARG BOL BRA CHL CRI DOM SLV HTI HND URY VEN
foreach pais of local paisess {
	clear 
	cd "C:\Users\DCOR\OneDrive - Inter-American Development Bank Group\Documents\GitHub\armonizacion_censos_poblacion_scl/`pais'/"
	*IPUMS
	if "`pais'" == "SUR"  local anio 2012
	if "`pais'" == "NIC"  local anio 2005
	if "`pais'" == "ARG"  local anio 2010
	if "`pais'" == "BOL"  local anio 2012
	if "`pais'" == "BRA"  local anio 2010
	if "`pais'" == "CHL"  local anio 2017
	if "`pais'" == "CRI"  local anio 2011
	if "`pais'" == "DOM"  local anio 2010
	if "`pais'" == "SLV"  local anio 2007
	if "`pais'" == "HTI"  local anio 2003
	if "`pais'" == "HND"  local anio 2001
	if "`pais'" == "TTO"  local anio 2011
	if "`pais'" == "URY"  local anio 2011
	if "`pais'" == "VEN"  local anio 2001
	* NO IPUMS
	/*
	if "`pais'" == "PAN"  local anio 2023
	if "`pais'" == "BLZ"  local anio 2022
	if "`pais'" == "ECU"  local anio 2022
	if "`pais'" == "MEX"  local anio 2020
	if "`pais'" == "GUY"  local anio 2012
	if "`pais'" == "BRB"  local anio 2010
	if "`pais'" == "GTM"  local anio 2018
	if "`pais'" == "PRY"  local anio 2012
	if "`pais'" == "JAM"  local anio 2011
	if "`pais'" == "PER"  local anio 2017 
	*/ 
	do "`pais'_`anio'_censusBID.do"		
	
	}