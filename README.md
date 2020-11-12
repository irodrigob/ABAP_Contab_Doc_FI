# Objetivo

Ejemplo de programa que contabiliza documentos usando la BAPI BAPI_ACC_DOCUMENT_POST y BAPI_ACC_GL_POSTING_POST, la del ledger. Este programa lee de un excel usando el ![abap2xlsx](https://github.com/sapmentors/abap2xlsx) y muestra un listado 

El programa tiene la siguiente pantalla selección:

![Configuracion main screen](https://github.com/irodrigob/ABAP_Contab_Doc_FI/blob/main/docs/pantalla_seleccion.png)

Un ejemplo de fichero esta [aquí](https://github.com/irodrigob/ABAP_Contab_Doc_FI/blob/main/docs/Ejemplo%20fichero%20carga.xlsx). El fichero tiene la mayor parte de los ficheros que se necesitan para contabilizar.

Una de las cosas interesantes es que se usa la función BAPI_ACC_DOCUMENT_CHECK antes de contabilizar con lo que se detectan los errores, que por supuesto, se muestran en el listaod.

Otro tema es que para los impuestos se usa una función que devuelvo los importes, cuenta, etc. que hay que añadir en las tablas de impuesto de la BAPI para que en el documento contable se pueda usar.

El programa hace uso de las extensiones que permite la BAPI para poder cambiar la clave de contabilización y otros campos.

En ella se puede escoger:

* Ruta del fichero
* Número de cabeceras. El excel de ejemplo tiene 2.
* Si se quiere contabilizar con ledger o contabilización normal
* El listado se puede ejecutar para que solo se vea lo que sea ha leído, para que lea y haga una simulación y contabilización real.
