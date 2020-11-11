*&---------------------------------------------------------------------*
*& Report zfi_r_carga_apuntes_manuales
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_r_carga_docs_fi.
*----------------------------------------------------------------------*
* VARIABLES
*----------------------------------------------------------------------*
CLASS lcl_controller DEFINITION DEFERRED.
DATA mo_controller TYPE REF TO lcl_controller.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
PARAMETERS p_file TYPE rlgrap-filename OBLIGATORY.
PARAMETERS p_nhead TYPE i DEFAULT 2.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-t03.
PARAMETERS: p_norm RADIOBUTTON GROUP g2 DEFAULT 'X',
            p_ledger RADIOBUTTON GROUP g2.
SELECTION-SCREEN end OF BLOCK bl3.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-t02.
PARAMETERS: p_test RADIOBUTTON GROUP g1,
            p_simu RADIOBUTTON GROUP g1,
            p_real RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK bl2.


INCLUDE zfi_r_carga_docs_fi_c01.

*----------------------------------------------------------------------*
* Inicialización de datos
*----------------------------------------------------------------------*
INITIALIZATION.
  mo_controller = NEW lcl_controller( ).

*----------------------------------------------------------------------*
* Validación de pantalla de seleccion
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  mo_controller->f4_file(  ).

*----------------------------------------------------------------------*
* Selección de datos
*----------------------------------------------------------------------*
START-OF-SELECTION.

  mo_controller->process(  ).

*----------------------------------------------------------------------*
* Fin de selección de datos
*----------------------------------------------------------------------*
END-OF-SELECTION.

  mo_controller->show_data(  ).
