# Banco de Datos Armonizado de Censos de Población y Vivienda

## Descripción
El repositorio armonizacion_censos_poblacion_scl contiene los scripts de transformación de los censos originales de forma tal que proporcionan información censal comparable a lo largo del tiempo y entre países.
Las variables de estas bases son construidas bajo un enfoque y estructura común, con nombres, definiciones y desagregaciones estandarizadas y almacenadas en un solo archivo para cada país. Actualmente la armonización de Censos de Población y Vivienda cuenta con bases de datos para 15 países desde x.

## Estructura de trabajo
Este repositorio tiene una estructura estandarizada para el flujo de trabajo y para el almacenamiento de los scripts. Esta se compone de dos elementos estructurados de la siguiente manera. 

- Almacenamiento
- Contribución: 
  * Preliminares
  * Git Workflow
  * Documentación

### Almacenamiento 

El repositorio tiene 26 carpetas referentes a los países de la región, estas están nombradas con el acrónimo del país (ISO 3166-1 alpha-3).
Asimismo, el repositorio contiene una carpeta llamada "Base" con dos scripts para generar  y nombrar las variables que son comunes entre gran parte de los censos. Lo anterior, para evitar una repetición constante de algo que puede ser homologado, evitando errores y ahorrando tiempo.

**1) Carpetas de país:** Cada carpeta contiene los scripts de las armonizaciones disponibles para el país en cuestión. Los scripts son realizados en Stata (archivos con extensión do), y su nombre se construye como: `PAIS_año_censusBID.do`. El número de scripts dentro de una 
carpeta depende del número de Censos de Población y Vivienda que hayan sido armonizados para ese país.

**2) Carpeta Base:** En esta carpeta se encuentran dos archivos en Stata. El primer archivo `base.do` contiene el código para armonizar las variables que son comunes entre muchos países y años, para evitar la repetición de código y facilitar el trabajo. 
El segundo archivo `labels.do` contiene el código para definir las etiquetas de **TODAS** las variables, aún si estas no están en el código 
base.do. 

### Contribución

#### Preliminares

Antes de empezar a trabajar o contribuir en la armonización de los censos de población y vivienda se deben realizar los siguientes pasos:

**1. Clonar el repositorio**

Se debe de clonar el repositorio **"armonizacion_censos_poblacion_scl"** a nivel local en el desktop personal. Para esto se puede usar GitHub
Desktop o la consola. 

**a. GitHub Desktop**

* Una vez instalado el programa GitHub Desktop se va al icono **“File”** y se selecciona **“Clone a repository”**.
* En **“Clone a repository”** se selecciona el repositorio “armonizacion_censos_poblacion_scl” y se escoge el path local donde se quiera guardar la información. Hacer clic en Clone. 
* Una vez se tenga el repositorio sincronizado, se puede avanzar a generar las Branch de trabajo.

**b. Consola**

* Te situas en el directorio en dónde quieres trabajar
``` 
cd "C:\Users\MARIAREY\OneDrive - Inter-American Development Bank Group\Documents"
``` 
* Clonas el repositorio de GitHub 
```
git clone https://github.com/BID-SCL/armonizacion_censos_poblacion_scl.git
```
* Después de poner tus credenciales en la consola, el repositorio se clonará en el path que eligiste y puedes proceder a crear tu branch de trabajo.
```
git branch feature_armonizacion_scl
```
Esta es la forma de hacerlo si la armonización se realiza en Platform on Demand. 

**2. Definir path de datos**

Para el trabajo con la armonización se deben precisar dos global principales con el objetivo de definir los path necesarios para generar la armonización de las bases. Los global se deben definir a nivel local. Se recomienda que los global se definan en el Do-File `profile.do` alojado en la carpeta local **“PERSONAL”** para que una vez se inicie el programa de STATA ya los global estén definidos:

Para encontrar la carpeta **“PERSONAL”** en stata se pone el siguiente comando. 
```
display "`=c(sysdir_personal)'"
```
En general, la carpeta está ubicada en `C:\Users\NAME\ado\personal\`
Es muy probable que la carpeta no esté creada. Debido a esto, se debe crear bajo el nombre **“personal”**.
Una vez se ubique la carpeta, se debe crear el Do-file bajo `profile.do` que debe ir alojado en la carpeta mencionada anteriormente. Dentro de Do-file se van a generar los global:

```
global censusFolder C:\Users\MARIAREY\OneDrive - Inter-American Development Bank Group\Documents\Data Governance - SCL\Censos\raw
global gitFolder "C:\Users\MARIAREY\OneDrive - Inter-American Development Bank Group\Documents\GitHub"
```
Se debe considerar que este es un ejemplo. Los path pueden cambiar de acuerdo con el directorio local de cada uno de los desktops. Recuerde que **NO** se deben modificar los paths ya establecidos en cada uno de los scripts de Git.

#### Git Workflow

Para mantener estructurado y estandarizado el proceso de armonización de los censos de población, el repositorio tiene dos branches principales: **1) Master**
y **2) Development**. Esto ayuda a mantener la estructura de trabajo y minimizar los errores. En particular, estas dos ramas tienen las siguientes funciones.

**1) Master:** La versión contenida en esta Branch es la versión revisada más actualizada. Esta Branch está aprobada para ejecutarse, por lo que no se debe modificar a menos que todos los cambios sean previamente aprobados en la Branch de Development. 

**2) Development:** En esta Branch se realizan pruebas y cambios a los scripts. De esta Branch se desligan las Branch de cada una de los features que se generan para el trabajo en los scripts. 

Debido a que el trabajo de armonización principalmente se realiza de forma paralela entre varios desarrolladores, se requiere que cada uno trabaje con una branch personal donde se solucione o trabaje en el feature requerido y se deben seguir los siguientes pasos: 

1) Para trabajar en el feature, se debe crear una Branch que sea la copia de la versión de Development. La Branch debe tener el nombre estandarizado “type-task-division”.

   **a.	Type:** hace referencia a el proceso que se va a llevar a cabo (un feature, fix, refactor, test, docs, chore)
    
   **b.	Task:** Hace referencia a una breve descripción de la tarea a realizar
    
   **c.	Division:** El nombre de la división a la que pertenece el desarrollador que trabaja en el proceso. 
    
2) Una vez terminado el proceso de modificación o ajuste de los scripts se debe realizar el pull request para realizar el merge. Se debe tener en cuenta que el merge siempre se debe solicitar para realiza en la Branch de Development. 
3) Una vez se realiza la solitud de merge, se revisa y verifica que no existan errores en el nuevo pull antes de aceptar el merge a la branch principal. 

Para ampliar la explicación del flujo de trabajo en el repositorio ver [M.2.1.2 Git Conventions.pptx](https://idbg.sharepoint.com/:p:/r/sites/DataGovernance-SCL/_layouts/15/Doc.aspx?sourcedoc=%7B6D4613EB-D3FC-4CFD-BE65-25AD1ED4A805%7D&file=M.2.1.2%20Git%20Conventions.pptx&action=edit&mobileredirect=true)

#### Documentación 

Por último, ya que las variables se añadieron al script de forma correcta es necesario documentar este proceso en dos lugares. 
1) Primero, se debe definir las variables en el documento [D.7.1 Documentación armonización variables censos](https://idbg.sharepoint.com/:w:/r/sites/DataGovernance-SCL/_layouts/15/Doc.aspx?sourcedoc=%7BEFB4C3F1-CE12-4FBB-B773-062CE027F21C%7D&file=D.7.1%20Documentaci%C3%B3n%20armonizaci%C3%B3n%20variables%20censos.docx&action=default&mobileredirect=true). Aquí se debe detallar el significado de la variable, así como la información que se considere necesaria para su construcción y entendimiento. 
2) Asimismo, en el documento [D.7.1.3 Diccionario variables censos](https://idbg.sharepoint.com/:x:/r/sites/DataGovernance-SCL/_layouts/15/Doc.aspx?sourcedoc=%7BEE4A0CBC-226C-4C9C-982A-E8085AB7D0B9%7D&file=D.7.1.3%20Diccionario%20variables%20censos.xlsx&action=default&mobileredirect=true), se deben incluir las variables, así como el tipo de variable y sus categorías o valores. 

En conjunto el repositorio y estos dos documentos deben de ser suficientes para que una persona que no forme parte de los TS pueda contribuir y entender todo el contenido. Así como para promover la continuidad de este proyecto.

## Cómo citar el uso del banco de datos armonizado
La información tomada de este banco de datos debe ser citada como:
"Fuente: Banco Interamericano de Desarrollo: Banco de Datos Armonizado de Censos de Población". Se sugiere hacer referencia a la fecha en que las bases de datos fueron consultadas, dado que la información contenida en ellas podría cambiar. Asimismo, se agradece una copia de las publicaciones o informes que utilicen la información contenida en este banco de datos para nuestros registros. **PENDIENTE**
