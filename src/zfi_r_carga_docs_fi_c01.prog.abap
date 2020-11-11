*&---------------------------------------------------------------------*
*& Include zfi_r_carga_docs_fi_c01
*&---------------------------------------------------------------------*

CLASS lcl_controller DEFINITION.
  PUBLIC SECTION.
    METHODS f4_file.
    METHODS process.
    METHODS show_data.

    METHODS on_link_click FOR EVENT link_click OF zcl_ca_alv
      IMPORTING row column.
    METHODS on_user_command FOR EVENT added_function OF zcl_ca_alv
      IMPORTING e_salv_function.

  PROTECTED SECTION.
    TYPES: BEGIN OF ts_message,
             status  TYPE lvc_s_icon,
             message TYPE string,
           END OF ts_message.
    TYPES tt_message TYPE STANDARD TABLE OF ts_message WITH EMPTY KEY.
    TYPES: BEGIN OF ts_excel_data,
             bukrs     TYPE bkpf-bukrs,
             blart     TYPE bkpf-blart,
             budat     TYPE bkpf-budat,
             bldat     TYPE bkpf-bldat,
             xblnr     TYPE bkpf-xblnr,
             waers     TYPE bkpf-waers,
             bktxt     TYPE bkpf-bktxt,
             vatdate   TYPE bkpf-vatdate,
             xmwst     TYPE bkpf-xmwst,
             kursf     TYPE bkpf-kursf,
             wwert     TYPE bkpf-wwert,
             belnr     TYPE bkpf-belnr,
             buzei     TYPE bseg-buzei,
             bschl     TYPE bseg-bschl,
             umskz     TYPE bseg-umskz,
             kunnr     TYPE bseg-kunnr,
             lifnr     TYPE bseg-lifnr,
             hkont     TYPE bseg-hkont,
             mwskz     TYPE bseg-mwskz,
             wrbtr     TYPE bseg-wrbtr,
             zuonr     TYPE bseg-zuonr,
             sgtxt     TYPE bseg-sgtxt,
             vbund     TYPE bseg-vbund,
             kostl     TYPE bseg-kostl,
             prctr     TYPE bseg-prctr,
             gsber     TYPE bseg-gsber,
             aufnr     TYPE bseg-aufnr,
             segment   TYPE bseg-segment,
             xref1     TYPE bseg-xref1,
             xref2     TYPE bseg-xref2,
             xref3     TYPE bseg-xref3,
             zlsch     TYPE bseg-zlsch,
             bvtyp     TYPE bseg-bvtyp,
             zfbdt     TYPE bseg-zfbdt,
             zterm     TYPE bseg-zterm,
             hbkid     TYPE bseg-hbkid,
             hktid     TYPE bseg-hktid,
             witht     TYPE accit_wt-witht,
             qsskz     TYPE bseg-qsskz,
             qsshb     TYPE bseg-qsshb,
             vertt     TYPE bseg-vertn,
             vertn     TYPE bseg-vertn,
             long_text TYPE string,
             newbk     TYPE rf05a-newbk,
             zlspr     TYPE bseg-zlspr,
             projk     TYPE ps_posid,
             xinve     TYPE bseg-xinve,
             rldnr     TYPE acdoca-rldnr,
           END OF ts_excel_data.
    TYPES: BEGIN OF ts_data,
             status        TYPE lvc_s_icon,
             row           TYPE zexcel_cell_row.
             INCLUDE TYPE ts_excel_data.
           TYPES:
                    shkzg         TYPE bseg-shkzg,
                    gjahr         TYPE bkpf-gjahr,
                    acc_principle TYPE accounting_principle,
                    log           TYPE string,
                    messages      TYPE tt_message,
                    celltype      TYPE salv_t_int4_column,
                  END OF ts_data.
    TYPES: tt_data TYPE STANDARD TABLE OF ts_data WITH EMPTY KEY.
    TYPES: BEGIN OF ts_tbsl,
             bschl TYPE tbsl-bschl,
             shkzg TYPE tbsl-shkzg,
           END OF ts_tbsl.
    TYPES: tt_tbsl TYPE STANDARD TABLE OF ts_tbsl WITH EMPTY KEY.
    TYPES:
      BEGIN OF ts_clv_doc_fi,
        belnr TYPE bkpf-belnr,
        bukrs TYPE bkpf-bukrs,
        gjahr TYPE bkpf-gjahr,
      END OF ts_clv_doc_fi .
    TYPES: tt_account_gl_ledger TYPE STANDARD TABLE OF bapiacgl08 WITH EMPTY KEY.
    TYPES: tt_currencyamount_ledger TYPE STANDARD TABLE OF bapiaccr08 WITH EMPTY KEY.
    TYPES: tt_extensionin_ledger TYPE STANDARD TABLE OF bapiextc WITH EMPTY KEY.
    TYPES: BEGIN OF ts_ledger_acc_principle,
             acc_principle TYPE tacc_trgt_ldgr-acc_principle,
             target_ledger TYPE tacc_trgt_ldgr-target_ledger,
           END OF ts_ledger_acc_principle.
    TYPES: tt_ledger_acc_principle TYPE STANDARD TABLE OF ts_ledger_acc_principle WITH EMPTY KEY.
    CONSTANTS: BEGIN OF cs_icon_status,
                 green  TYPE lvc_s_icon VALUE icon_green_light,
                 yellow TYPE lvc_s_icon VALUE icon_yellow_light,
                 red    TYPE lvc_s_icon VALUE icon_red_light,
               END OF cs_icon_status.
    CONSTANTS: BEGIN OF cs_message,
                 error   TYPE bapi_mtype VALUE 'E',
                 success TYPE bapi_mtype VALUE 'S',
                 warning TYPE bapi_mtype VALUE 'W',
               END OF cs_message.

    DATA mt_data TYPE tt_data.
    DATA mo_alv TYPE REF TO zcl_ca_alv.
    DATA mt_tbsl TYPE tt_tbsl.
    DATA ms_documentheader TYPE bapiache09 .
    DATA mt_accountreceivable TYPE bapiacar09_tab .
    DATA mt_accountgl TYPE bapiacgl09_tab .
    DATA mt_currencyamount TYPE bapiaccr09_tab .
    DATA mt_accounttax TYPE bapiactx09_tab .
    DATA mt_accountpayable TYPE bapiacap09_tab .
    DATA mt_retencions TYPE bapiacwt09_tab .
    DATA mt_extension1 TYPE bapiacextc_tab .
    DATA ms_documentheader_ledger TYPE bapiache08.
    DATA mt_accountgl_ledger TYPE tt_account_gl_ledger.
    DATA mt_currency_ledger TYPE tt_currencyamount_ledger.
    DATA mt_extensionin_ledger TYPE tt_extensionin_ledger.
    DATA mt_ledger_acc_principle TYPE tt_ledger_acc_principle.

    METHODS read_excel.
    METHODS read_documents
      IMPORTING
        io_worksheet TYPE REF TO zcl_excel_worksheet.
    METHODS delete_row_header
      CHANGING
        ct_content TYPE zexcel_t_cell_data.
    METHODS change_fieldcat.
    METHODS post_processing_doc
      CHANGING
        cs_data TYPE lcl_controller=>ts_data.
    METHODS add_msg_2_log
      IMPORTING
        iv_status TYPE any
        iv_msg    TYPE any
      CHANGING
        cs_data   TYPE ts_data.
    METHODS check_mandatory_fields
      CHANGING
        cs_data TYPE lcl_controller=>ts_data.
    METHODS process_post_document.
    METHODS posting_document
      IMPORTING
        it_data   TYPE lcl_controller=>tt_data
      EXPORTING
        et_return TYPE bapiret2_t
        ev_bukrs  TYPE bkpf-bukrs
        ev_belnr  TYPE bkpf-belnr
        ev_gjahr  TYPE bkpf-gjahr.
    METHODS fill_cab_posting_doc
      IMPORTING
        is_data_header TYPE lcl_controller=>ts_data.
    METHODS fill_pos_posting_doc
      IMPORTING
        it_data TYPE lcl_controller=>tt_data.
    METHODS fill_pos_account_doc
      IMPORTING
                is_data    TYPE lcl_controller=>ts_data
      CHANGING  cv_pos     TYPE posnr_acc
                cv_tax_pos TYPE taxps.
    METHODS fill_pos_amount_doc
      IMPORTING
        iv_pos  TYPE posnr_acc
        is_data TYPE lcl_controller=>ts_data.
    METHODS fill_pos_account_key_doc
      IMPORTING
        iv_pos  TYPE posnr_acc
        is_data TYPE lcl_controller=>ts_data.
    METHODS fill_pos_vendor_doc
      IMPORTING
        iv_pos  TYPE posnr_acc
        is_data TYPE lcl_controller=>ts_data.
    METHODS fill_pos_customer_doc
      IMPORTING
        iv_pos  TYPE posnr_acc
        is_data TYPE lcl_controller=>ts_data.
    METHODS ejecutar_bapi_conta
      IMPORTING
        iv_commit     TYPE abap_bool
      EXPORTING
        es_clv_doc_fi TYPE ts_clv_doc_fi
        et_return     TYPE bapiret2_t.
    METHODS ir_doc_fi
      IMPORTING
        iv_bukrs TYPE bkpf-bukrs
        iv_belnr TYPE bkpf-belnr
        iv_gjahr TYPE bkpf-gjahr
        iv_rldnr TYPE bkpf-rldnr OPTIONAL.

    METHODS posting_document_ledger
      IMPORTING
        it_data   TYPE lcl_controller=>tt_data
      EXPORTING
        et_return TYPE bapiret2_t
        ev_bukrs  TYPE bkpf-bukrs
        ev_belnr  TYPE bkpf-belnr
        ev_gjahr  TYPE bkpf-gjahr.
    METHODS fill_cab_posting_doc_ledger
      IMPORTING
        is_data_header TYPE lcl_controller=>ts_data.
    METHODS fill_pos_posting_doc_ledger
      IMPORTING
        it_data TYPE lcl_controller=>tt_data.
    METHODS fill_pos_account_doc_ledger
      IMPORTING
        iv_pos  TYPE posnr_acc
        is_data TYPE lcl_controller=>ts_data.
    METHODS fill_pos_amount_doc_ledger
      IMPORTING
        iv_pos  TYPE posnr_acc
        is_data TYPE lcl_controller=>ts_data.
    METHODS fill_pos_accnt_key_doc_ledger
      IMPORTING
        iv_pos  TYPE posnr_acc
        is_data TYPE lcl_controller=>ts_data.
    METHODS ejecutar_bapi_conta_ledger
      IMPORTING
        iv_commit     TYPE abap_bool
      EXPORTING
        es_clv_doc_fi TYPE ts_clv_doc_fi
        et_return     TYPE bapiret2_t.
    METHODS fill_pos_account_tax
      IMPORTING is_data       TYPE lcl_controller=>ts_data
      EXPORTING ev_tax_amount TYPE bapiamtbase
      CHANGING  cv_pos        TYPE posnr_acc.


ENDCLASS.

CLASS lcl_controller IMPLEMENTATION.

  METHOD f4_file.
    DATA lt_filetable TYPE filetable.

    DATA lv_rc TYPE i.
    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        multiselection = abap_false
        file_filter    = '*.xslx'
      CHANGING
        file_table     = lt_filetable
        rc             = lv_rc.

    READ TABLE lt_filetable INTO p_file INDEX 1.
  ENDMETHOD.


  METHOD process.

    " Lectura fichero excel
    read_excel(  ).

    " En modo real o simulación se generá el documento contable
    IF p_test = abap_false.
      process_post_document(  ).
    ENDIF.

  ENDMETHOD.


  METHOD read_excel.
    DATA: lo_reader TYPE REF TO zif_excel_reader.

    CREATE OBJECT lo_reader TYPE zcl_excel_reader_2007.

    TRY.
        " Se lee el fichero
        DATA(lo_excel) = lo_reader->load_file( i_filename = p_file ).

        " Inicialmente el excel solo tendrá una pestaña, pero dejo preparado el codigo por si hubiese más de una
        DATA(lo_iterator) = lo_excel->get_worksheets_iterator( ).
        DO.
          TRY.
              lo_iterator->get_next( ).

              DATA(lv_index) = lo_iterator->get_index( ).
              lo_excel->set_active_sheet_index( CONV #( lv_index ) ).

              DATA(lo_worksheet) = lo_excel->get_active_worksheet( ).
              IF lo_worksheet IS BOUND.

                " El indice de la pestaña indicará que datos estamos leyendo
                CASE lv_index.
                  WHEN 1. " Datos principales
                    read_documents( lo_worksheet ).

                ENDCASE.

              ELSE. " Si no hay más pestañas se sale del proceso
                EXIT.
              ENDIF.
            CATCH zcx_excel. " Si se produce una excepción se sale del proceso
              EXIT.
          ENDTRY.

        ENDDO.

      CATCH zcx_excel.
        MESSAGE TEXT-s01 TYPE 'S'.
    ENDTRY.
  ENDMETHOD.


  METHOD read_documents.
    DATA ls_excel_data TYPE ts_excel_data.

    CLEAR mt_data.

    DATA(lt_content) = io_worksheet->sheet_content.

    " Si hay filas con cabecera se eliminan
    IF p_nhead NE 0.
      delete_row_header( CHANGING ct_content = lt_content ).
    ENDIF.

    " Recupero los campos de la estructura donde se guardará el resultado para saber su tipo
    DATA(lt_fields_excel_data) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_excel_data ) )->get_components(  ).

    LOOP AT lt_content ASSIGNING FIELD-SYMBOL(<ls_content_dummy>)
                       GROUP BY ( cell_row = <ls_content_dummy>-cell_row )
                       ASSIGNING FIELD-SYMBOL(<group>).

      INSERT VALUE #( row = <group>-cell_row ) INTO TABLE mt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      " Los campos del excel primero se pasan a una estructura que tiene los campos y en el mismo orden que el excel. Para luego moverlo
      " a la tabla de datos
      CLEAR ls_excel_data.
      LOOP AT GROUP <group> ASSIGNING FIELD-SYMBOL(<ls_content>).
        " Se lee el formato del campo que se esta leyendo.
        READ TABLE lt_fields_excel_data ASSIGNING FIELD-SYMBOL(<ls_fields_excel_data>) INDEX <ls_content>-cell_column.
        ASSIGN COMPONENT <ls_content>-cell_column OF STRUCTURE ls_excel_data TO FIELD-SYMBOL(<field_data>).

        " Segín el formato del campo hay que aplicar rutinas de conversión
        CASE <ls_fields_excel_data>-type->type_kind.
          WHEN <ls_fields_excel_data>-type->typekind_date.
            TRY.
                <field_data> = zcl_excel_common=>excel_string_to_date( ip_value =  <ls_content>-cell_value ).
              CATCH zcx_excel. " Si hay excepción es que no viene una fecha y hay que convertirla al modo tradicionales
                <field_data> = |{ <ls_content>-cell_value+6(4) }{ <ls_content>-cell_value+3(2) }{ <ls_content>-cell_value(2) }|.
            ENDTRY.
          WHEN OTHERS.
            <field_data> = <ls_content>-cell_value.
        ENDCASE.

      ENDLOOP.
      <ls_data> = CORRESPONDING #( BASE ( <ls_data> ) ls_excel_data ).
      " Post proceso de los datos leídos: validaciones, completar campos, etc.
      post_processing_doc( CHANGING cs_data = <ls_data> ).
    ENDLOOP.

  ENDMETHOD.


  METHOD delete_row_header.
    DO p_nhead TIMES.
      DELETE ct_content WHERE cell_row = sy-index.
    ENDDO.
  ENDMETHOD.


  METHOD show_data.

    IF mt_data IS NOT INITIAL.
      CREATE OBJECT mo_alv.

      CALL METHOD mo_alv->crear_alv
        EXPORTING
          i_container     = cl_gui_container=>screen0
          i_programa      = sy-repid
        CHANGING
          c_datos         = mt_data
        EXCEPTIONS
          error_crear_alv = 1
          OTHERS          = 2.

      IF sy-subrc = 0.
        " Indico que las columnas van estar optimizadas
        CALL METHOD mo_alv->set_cols_optimizadas( ).

        mo_alv->set_titulo( CONV #( sy-title ) ).

        " funciones del propio alv
        mo_alv->set_funciones_alv( abap_true ).

        " Podrán grabar las disposiciones
        mo_alv->set_gestion_layout( ).

        " Campos del ALV
        change_fieldcat(  ).

        " Que campo tendrá el control individual de celda
        mo_alv->set_celltype( 'CELLTYPE' ).

        SET HANDLER: on_link_click FOR mo_alv.
        SET HANDLER: on_user_command FOR mo_alv.

        " Finalmente llamo ALV
        CALL METHOD mo_alv->mostrar_alv( ).

* En modo online hago el write para que me salga el ALV. En fondo no puede salir porque solo sale el '.' y no el ALV.
        IF sy-batch = abap_false. WRITE '.'. ENDIF.

      ENDIF.
    ELSE.
      MESSAGE TEXT-s02 TYPE 'S'.
    ENDIF.
  ENDMETHOD.


  METHOD change_fieldcat.

    mo_alv->set_atributos_campo( i_campo = 'STATUS' i_simbolo = abap_true i_texto_todas = TEXT-c01 ).
    mo_alv->set_atributos_campo( i_campo = 'LOG' i_texto_todas = TEXT-c02 ).
    mo_alv->set_atributos_campo( i_campo = 'SHKZG' i_tecnico = abap_true ).
    mo_alv->set_atributos_campo( i_campo = 'MESSAGES' i_tecnico = abap_true ).
    mo_alv->set_atributos_campo( i_campo = 'GJAHR' i_tecnico = abap_true ).
    mo_alv->set_atributos_campo( i_campo = 'ACC_PRINCIPLE' i_tecnico = abap_true ).
    " El campo de ledger se oculta para documentos normales
    IF p_norm = abap_true.
      mo_alv->set_atributos_campo( i_campo = 'RLDNR' i_tecnico = abap_true ).
    ENDIF.

  ENDMETHOD.


  METHOD post_processing_doc.

    " Campos que se pasan a mayúsculas
    cs_data-blart = |{ cs_data-blart CASE = UPPER }|.
    cs_data-waers = |{ cs_data-waers CASE = UPPER }|.

    " Validación que tenga determinados campos informados
    check_mandatory_fields( CHANGING cs_data = cs_data ).

    " El importe puede venir con signo en el excel. Pero como no tengo las garantías que se siempre va ser así, me baso en la clave contable.
    IF cs_data-bschl IS NOT INITIAL.
      READ TABLE mt_tbsl ASSIGNING FIELD-SYMBOL(<ls_tbsl>) WITH KEY bschl = cs_data-bschl.
      IF sy-subrc NE 0. " Si no existe se busca y se añade.
        SELECT bschl shkzg INTO TABLE mt_tbsl
               FROM tbsl
               WHERE bschl = cs_data-bschl.
        IF sy-subrc = 0.
          READ TABLE mt_tbsl ASSIGNING <ls_tbsl> WITH KEY bschl = cs_data-bschl.
        ELSE. " Error no existe
          add_msg_2_log( EXPORTING iv_msg = TEXT-e01
                                   iv_status = cs_icon_status-red
                         CHANGING cs_data = cs_data ).

        ENDIF.
      ENDIF.
      IF <ls_tbsl> IS ASSIGNED.
        cs_data-shkzg = <ls_tbsl>-shkzg.
        cs_data-wrbtr = abs( cs_data-wrbtr ). " Quito el negativo que pueda tener.

        " Si el importe es 0 pongo un warning que la posición se ignorará
        IF cs_data-wrbtr IS NOT INITIAL.
          cs_data-wrbtr = COND #( WHEN <ls_tbsl>-shkzg = 'H' THEN - cs_data-wrbtr ELSE cs_data-wrbtr ).
        ELSE.
          add_msg_2_log( EXPORTING iv_msg = TEXT-w01
                                   iv_status = cs_icon_status-yellow
                         CHANGING cs_data = cs_data ).
        ENDIF.
      ENDIF.
    ENDIF.

    " El campo número de documento no lo hago navegable hasta que no se haga la contabilización
    INSERT VALUE #( columnname = 'BELNR' value = if_salv_c_cell_type=>text ) INTO TABLE cs_data-celltype.

    " Se determina norma de presentación del ledger
    IF p_ledger = abap_true.
      IF cs_data-rldnr IS NOT INITIAL.
        " La tabla tiene menos de diez registros, o sea, que la leo entera y listos.
        IF mt_ledger_acc_principle IS INITIAL.
          SELECT acc_principle ldgrp_gl INTO TABLE mt_ledger_acc_principle FROM tacc_trgt_ldgr.
        ENDIF.
        READ TABLE mt_ledger_acc_principle ASSIGNING FIELD-SYMBOL(<ls_ledger_acc_principle>)
                                           WITH KEY target_ledger = cs_data-rldnr.
        IF sy-subrc = 0.
          cs_data-acc_principle = <ls_ledger_acc_principle>-acc_principle.
        ELSE.
          add_msg_2_log( EXPORTING iv_msg = TEXT-e10
                             iv_status = cs_icon_status-red
                   CHANGING cs_data = cs_data ).
        ENDIF.
      ENDIF.

      " No puede haber datos de proveedor/clientes
      IF cs_data-lifnr IS NOT INITIAL.
        add_msg_2_log( EXPORTING iv_msg = TEXT-e11
                                    iv_status = cs_icon_status-red
                          CHANGING cs_data = cs_data ).
      ELSEIF cs_data-kunnr IS NOT INITIAL.
        add_msg_2_log( EXPORTING iv_msg = TEXT-e12
                                           iv_status = cs_icon_status-red
                                 CHANGING cs_data = cs_data ).
      ENDIF.

    ENDIF.


  ENDMETHOD.


  METHOD add_msg_2_log.
    " Texto para el log
    IF cs_data-log IS INITIAL.
      cs_data-log = iv_msg.
    ELSE.
      cs_data-log = |{ cs_data-log } / { iv_msg }|.
    ENDIF.

    " El status. Si el status que tiene es de error, no se sobreescribe porque tiene prioridad absoluta
    cs_data-status = COND #( WHEN cs_data-status NE cs_icon_status-red THEN iv_status ELSE cs_data-status ).

    INSERT VALUE #( status = iv_status message = iv_msg ) INTO TABLE cs_data-messages.

  ENDMETHOD.


  METHOD check_mandatory_fields.

    IF cs_data-blart IS INITIAL. " Clase de documento
      add_msg_2_log( EXPORTING iv_msg = TEXT-e03
                                     iv_status = cs_icon_status-red
                           CHANGING cs_data = cs_data ).
    ENDIF.

    IF cs_data-bukrs IS INITIAL. " Sociedad
      add_msg_2_log( EXPORTING iv_msg = TEXT-e04
                                     iv_status = cs_icon_status-red
                           CHANGING cs_data = cs_data ).
    ENDIF.

    IF cs_data-bschl IS INITIAL. " Clave contabilización
      add_msg_2_log( EXPORTING iv_msg = TEXT-e05
                                     iv_status = cs_icon_status-red
                           CHANGING cs_data = cs_data ).
    ENDIF.

    IF cs_data-bldat IS INITIAL. " Fecha documento
      add_msg_2_log( EXPORTING iv_msg = TEXT-e06
                                     iv_status = cs_icon_status-red
                           CHANGING cs_data = cs_data ).
    ENDIF.

    IF cs_data-budat IS INITIAL. " Fecha contabilización
      add_msg_2_log( EXPORTING iv_msg = TEXT-e07
                                     iv_status = cs_icon_status-red
                           CHANGING cs_data = cs_data ).
    ENDIF.

    " Proveedor, cliente o cuenta tiene que estar informado
    IF cs_data-lifnr IS INITIAL AND cs_data-kunnr IS INITIAL AND cs_data-hkont IS INITIAL.
      add_msg_2_log( EXPORTING iv_msg = TEXT-e08
                                     iv_status = cs_icon_status-red
                           CHANGING cs_data = cs_data ).
    ENDIF.

    " Campos obligatorios para el ledger
    IF p_ledger = abap_true.
      IF cs_data-rldnr IS INITIAL.
        add_msg_2_log( EXPORTING iv_msg = TEXT-e09
                                    iv_status = cs_icon_status-red
                          CHANGING cs_data = cs_data ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD process_post_document.
    DATA lt_return TYPE bapiret2_t.
    " Se hará un documento contable por cada valor en el campo belnr

    LOOP AT mt_data ASSIGNING FIELD-SYMBOL(<ls_data_dummy>)
                    GROUP BY ( belnr = <ls_data_dummy>-belnr )
                    ASSIGNING FIELD-SYMBOL(<group>).


      DATA(lt_data) = VALUE tt_data(  ).
      LOOP AT GROUP <group> ASSIGNING FIELD-SYMBOL(<ls_data>).
        INSERT <ls_data> INTO TABLE lt_data.
      ENDLOOP.

      " Si hay errores previos el documento no se procesa
      READ TABLE lt_data TRANSPORTING NO FIELDS WITH KEY status = cs_icon_status-red.
      IF sy-subrc NE 0.

        " Se realiza la contabilización del documento según la opción escogida
        IF p_norm = abap_true.
          posting_document( EXPORTING it_data = lt_data
                    IMPORTING et_return = lt_return
                              ev_bukrs = DATA(lv_bukrs)
                              ev_belnr = DATA(lv_belnr)
                              ev_gjahr = DATA(lv_gjahr) ).

        ELSE.
          posting_document_ledger( EXPORTING it_data = lt_data
                          IMPORTING et_return = lt_return
                                    ev_bukrs = lv_bukrs
                                    ev_belnr = lv_belnr
                                    ev_gjahr = lv_gjahr ).

        ENDIF.


        " Determino el status en base si hay error.
        READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type = cs_message-error.
        IF sy-subrc = 0.
          DATA(lv_status) = cs_icon_status-red.
        ELSE.
          lv_status = cs_icon_status-green.
        ENDIF.

        " Ahora se recorren los datos del documentos para actualizarlos en la tabla principal
        LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data_aux>).
          READ TABLE mt_data ASSIGNING <ls_data> WITH KEY row = <ls_data_aux>-row.
          <ls_data>-status = lv_status.

          " Si no hay errores y se esta en modo real se informa los campos del documento generado
          IF lv_status = cs_icon_status-green AND p_real = abap_true.
            <ls_data>-belnr = lv_belnr.
            <ls_data>-gjahr = lv_gjahr.

            " Indico que el campo de nº documento es navegable
            READ TABLE <ls_data>-celltype ASSIGNING FIELD-SYMBOL(<ls_celltype>) WITH KEY columnname = 'BELNR'.
            IF sy-subrc = 0.
              <ls_celltype>-value = if_salv_c_cell_type=>hotspot.
            ENDIF.

          ENDIF.

          " Se recorren los mensajes devueltos y se añaden al log. El motivo de hacerlo así es para que se guarde en la tabla de mensajes
          " los textos de manera independiete
          LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<ls_return>).
            add_msg_2_log( EXPORTING iv_msg = <ls_return>-message
                                    iv_status = SWITCH #( <ls_return>-type
                                                          WHEN cs_message-error THEN cs_icon_status-red
                                                          WHEN cs_message-success THEN cs_icon_status-green
                                                          WHEN cs_message-warning THEN cs_icon_status-yellow )
                          CHANGING cs_data = <ls_data> ).
          ENDLOOP.
        ENDLOOP.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.


  METHOD posting_document.

    CLEAR: et_return, ev_belnr, ev_bukrs, ev_gjahr.

    " Variables para la BAPI
    CLEAR: ms_documentheader, mt_accountgl, mt_accountpayable, mt_accountreceivable, mt_accounttax, mt_currencyamount.
    CLEAR: mt_extension1, mt_retencions.

    " Como la cabecera se repite en todos los registros solo es necesario leer el primer registro para obtener los datos
    DATA(ls_data_header) = it_data[ 1 ].


    " Cabecera
    fill_cab_posting_doc( EXPORTING is_data_header = ls_data_header ).

    " Posiciones del documento
    fill_pos_posting_doc( EXPORTING it_data = it_data ).


    " Se lanza la contabilización con los documentos generados
    ejecutar_bapi_conta( EXPORTING iv_commit = abap_true
                         IMPORTING es_clv_doc_fi = DATA(ls_clv_doc_fi)
                                   et_return = et_return ).

    ev_belnr = ls_clv_doc_fi-belnr.
    ev_bukrs = ls_clv_doc_fi-bukrs.
    ev_gjahr = ls_clv_doc_fi-gjahr.

  ENDMETHOD.


  METHOD fill_cab_posting_doc.

    ms_documentheader-fisc_year   = is_data_header-budat(4).
    ms_documentheader-pstng_date  = is_data_header-budat.
    ms_documentheader-doc_date    = is_data_header-bldat.
    ms_documentheader-username    = sy-uname.
    ms_documentheader-comp_code   = is_data_header-bukrs.
    ms_documentheader-bus_act     = 'RFBU'.
    ms_documentheader-doc_type = is_data_header-blart.


    ms_documentheader-ref_doc_no = is_data_header-xblnr.
    ms_documentheader-header_txt = is_data_header-bktxt.
    ms_documentheader-vatdate = is_data_header-vatdate.


  ENDMETHOD.


  METHOD fill_pos_posting_doc.

    DATA(lv_pos) = CONV posnr_acc( 1 ).
    DATA(lv_tax_pos) = CONV taxps( 1 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<ls_data>).



      IF <ls_data>-hkont IS NOT INITIAL. " Datos de cuenta
        fill_pos_account_doc( EXPORTING is_data = <ls_data>
                              CHANGING cv_pos = lv_pos
                                       cv_tax_pos = lv_tax_pos ).
      ELSE.

        IF <ls_data>-lifnr IS NOT INITIAL.
          fill_pos_vendor_doc( EXPORTING iv_pos = lv_pos
                                            is_data = <ls_data> ).
        ELSEIF <ls_data>-kunnr IS NOT INITIAL.
          fill_pos_customer_doc( EXPORTING iv_pos = lv_pos
                                            is_data = <ls_data> ).
        ENDIF.

        " Importe de la posición. Para posiciones de terceros se añade después de los
        " metodos correspondientes porque no se añaden subposiciones como en cuenta de mayor. Que
        " en caso de haber impuestos se añade el importe del impuesto
        fill_pos_amount_doc( EXPORTING iv_pos = lv_pos
                                   is_data = <ls_data> ).
      ENDIF.

      " Clave de la contabilización
      fill_pos_account_key_doc( EXPORTING iv_pos = lv_pos
                                 is_data = <ls_data> ).

      lv_pos = lv_pos + 1.
    ENDLOOP.

  ENDMETHOD.


  METHOD fill_pos_account_doc.

    " Datos apunte contables
    APPEND INITIAL LINE TO mt_accountgl ASSIGNING FIELD-SYMBOL(<ls_account_gl>).
    <ls_account_gl>-itemno_acc = cv_pos.

    <ls_account_gl>-gl_account = |{ is_data-hkont ALPHA = IN }|.
    <ls_account_gl>-pstng_date  = ms_documentheader-pstng_date. " Fecha contabilizacion
    <ls_account_gl>-item_text = is_data-sgtxt.
    <ls_account_gl>-tax_code = is_data-mwskz.
    <ls_account_gl>-alloc_nmbr = is_data-zuonr.
    <ls_account_gl>-costcenter = is_data-kostl.
    <ls_account_gl>-profit_ctr = |{ is_data-prctr ALPHA = IN }|.

    CALL FUNCTION 'CONVERSION_EXIT_ABPSN_INPUT'
      EXPORTING
        input  = is_data-projk
      IMPORTING
        output = <ls_account_gl>-wbs_element.

    <ls_account_gl>-bus_area = is_data-gsber.
    <ls_account_gl>-orderid = |{ is_data-aufnr ALPHA = IN }|.
    <ls_account_gl>-segment = is_data-segment.
    <ls_account_gl>-ref_key_1 = is_data-xref1.
    <ls_account_gl>-ref_key_2 = is_data-xref2.
    <ls_account_gl>-ref_key_3 = is_data-xref3.
    <ls_account_gl>-ref_key_3 = is_data-xref3.
    <ls_account_gl>-trade_id = is_data-vbund.

    " Importe de la posición.
    fill_pos_amount_doc( EXPORTING iv_pos = cv_pos
                                   is_data = is_data ).

    " Indicador de calculo automático de impuestos
    IF is_data-xmwst IS NOT INITIAL.
*      APPEND INITIAL LINE TO mt_extension1 ASSIGNING FIELD-SYMBOL(<ls_extension1>).
*      <ls_extension1>-field1 = cv_pos.
*      <ls_extension1>-field3 = 'XMWST'.
*      <ls_extension1>-field4 = is_data-xmwst.

      " Leo la posición del importe por si hay que cambiarla con el importe base
      READ TABLE mt_currencyamount ASSIGNING FIELD-SYMBOL(<ls_currencyamount>) WITH KEY itemno_acc = cv_pos.

      " Se rellenará la posición del impuesto
      fill_pos_account_tax( EXPORTING is_data = is_data
                            IMPORTING ev_tax_amount = DATA(lv_tax_amount)
                            CHANGING cv_pos = cv_pos ).

      " Si hay importe de impuesto se ajusta el
      IF lv_tax_amount IS NOT INITIAL.
        " Se ajusta el signo del importe del impuesto al de la posición
        <ls_currencyamount>-amt_doccur = COND #( WHEN is_data-wrbtr < 0 THEN - lv_tax_amount ELSE lv_tax_amount ).
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD fill_pos_amount_doc.

    APPEND INITIAL LINE TO mt_currencyamount ASSIGNING FIELD-SYMBOL(<ls_amount>).
    <ls_amount>-itemno_acc = iv_pos.
    <ls_amount>-currency   = is_data-waers.
    <ls_amount>-amt_doccur = is_data-wrbtr.

  ENDMETHOD.


  METHOD fill_pos_account_key_doc.

    APPEND INITIAL LINE TO mt_extension1 ASSIGNING FIELD-SYMBOL(<ls_extension1>).
    <ls_extension1>-field1 = iv_pos.
    <ls_extension1>-field3 = 'BSCHL'.
    <ls_extension1>-field4 = is_data-bschl.


  ENDMETHOD.


  METHOD fill_pos_vendor_doc.

* Cuenta del proveedor
    APPEND INITIAL LINE TO mt_accountpayable ASSIGNING FIELD-SYMBOL(<ls_account>).

    <ls_account>-itemno_acc = iv_pos.
    <ls_account>-vendor_no = |{ is_data-lifnr ALPHA = IN }|.
    <ls_account>-item_text = ms_documentheader-ref_doc_no. " Texto posicion
    <ls_account>-bline_date = is_data-zfbdt. " Fecha de vencimiento
    <ls_account>-item_text = is_data-sgtxt. " Texto posicion
    <ls_account>-pymt_meth = is_data-zlsch.
    <ls_account>-profit_ctr = is_data-prctr.
    <ls_account>-bus_area = is_data-gsber.
    <ls_account>-alloc_nmbr = is_data-zuonr.
    <ls_account>-ref_key_1 = is_data-xref1.
    <ls_account>-ref_key_2 = is_data-xref2.
    <ls_account>-ref_key_3 = is_data-xref3.
    <ls_account>-ref_key_3 = is_data-xref3.
    <ls_account>-pmnttrms = is_data-zterm.
    <ls_account>-bank_id = is_data-hbkid.
    <ls_account>-partner_bk = is_data-bvtyp.
    <ls_account>-housebankacctid = is_data-hktid.
    <ls_account>-pmnt_block = is_data-zlspr.
    <ls_account>-tax_code = is_data-mwskz.

*    " Vía de pago
*    IF is_data-zlsch IS NOT INITIAL.
*      APPEND INITIAL LINE TO mt_extension1 ASSIGNING FIELD-SYMBOL(<ls_extension1>).
*      <ls_extension1>-field1 = iv_pos.
*      <ls_extension1>-field3 = 'ZLSCH'.
*      <ls_extension1>-field4 = is_data-zlsch.
*    ENDIF.

    " Indicador inversion
    IF is_data-xinve IS NOT INITIAL.
      APPEND INITIAL LINE TO mt_extension1 ASSIGNING FIELD-SYMBOL(<ls_extension1>).
      <ls_extension1>-field1 = iv_pos.
      <ls_extension1>-field3 = 'XINVE'.
      <ls_extension1>-field4 = is_data-xinve.
    ENDIF.

    " Indicador de calculo automático de impuestos
*    IF is_data-xmwst IS NOT INITIAL.
*      APPEND INITIAL LINE TO mt_extension1 ASSIGNING <ls_extension1>.
*      <ls_extension1>-field1 = iv_pos.
*      <ls_extension1>-field3 = 'XMWST'.
*      <ls_extension1>-field4 = is_data-xmwst.
*    ENDIF.

    " Elemento PEP
    IF is_data-projk IS NOT INITIAL.
      APPEND INITIAL LINE TO mt_extension1 ASSIGNING <ls_extension1>.
      <ls_extension1>-field1 = iv_pos.
      <ls_extension1>-field3 = 'PS_PSP_PNR'.
      CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
        EXPORTING
          input  = is_data-projk
        IMPORTING
          output = <ls_extension1>-field4.
    ENDIF.

    " Retenciones
    IF is_data-witht IS NOT INITIAL.
      APPEND INITIAL LINE TO mt_retencions ASSIGNING FIELD-SYMBOL(<ls_retencions>).
      <ls_retencions>-itemno_acc = iv_pos.
      <ls_retencions>-wt_type = is_data-witht.
      <ls_retencions>-wt_code = is_data-qsskz.
      <ls_retencions>-bas_amt_lc = is_data-qsshb.

    ENDIF.
  ENDMETHOD.


  METHOD fill_pos_customer_doc.
* Cuenta del proveedor
    APPEND INITIAL LINE TO mt_accountreceivable ASSIGNING FIELD-SYMBOL(<ls_account>).

    <ls_account>-itemno_acc = iv_pos.
    <ls_account>-customer = |{  is_data-kunnr ALPHA = IN }|.
    <ls_account>-item_text = ms_documentheader-ref_doc_no. " Texto posicion
    <ls_account>-bline_date = is_data-zfbdt. " Fecha de vencimiento
    <ls_account>-item_text = is_data-sgtxt. " Texto posicion
    <ls_account>-pymt_meth = is_data-zlsch.
    <ls_account>-profit_ctr = is_data-prctr.
    <ls_account>-bus_area = is_data-gsber.
    <ls_account>-alloc_nmbr = is_data-zuonr.
    <ls_account>-ref_key_1 = is_data-xref1.
    <ls_account>-ref_key_2 = is_data-xref2.
    <ls_account>-ref_key_3 = is_data-xref3.
    <ls_account>-ref_key_3 = is_data-xref3.
    <ls_account>-pmnttrms = is_data-zterm.
    <ls_account>-bank_id = is_data-hbkid.
    <ls_account>-partner_bk = is_data-bvtyp.
    <ls_account>-housebankacctid = is_data-hktid.
    <ls_account>-pmnt_block = is_data-zlspr.
    <ls_account>-tax_code = is_data-mwskz.

*    " Vía de pago
*    IF is_data-zlsch IS NOT INITIAL.
*      APPEND INITIAL LINE TO mt_extension1 ASSIGNING FIELD-SYMBOL(<ls_extension1>).
*      <ls_extension1>-field1 = iv_pos.
*      <ls_extension1>-field3 = 'ZLSCH'.
*      <ls_extension1>-field4 = is_data-zlsch.
*    ENDIF.

    " Indicador inversion
    IF is_data-xinve IS NOT INITIAL.
      APPEND INITIAL LINE TO mt_extension1 ASSIGNING FIELD-SYMBOL(<ls_extension1>).
      <ls_extension1>-field1 = iv_pos.
      <ls_extension1>-field3 = 'XINVE'.
      <ls_extension1>-field4 = is_data-xinve.
    ENDIF.

    " Indicador de calculo automático de impuestos
*    IF is_data-xmwst IS NOT INITIAL.
*      APPEND INITIAL LINE TO mt_extension1 ASSIGNING <ls_extension1>.
*      <ls_extension1>-field1 = iv_pos.
*      <ls_extension1>-field3 = 'XMWST'.
*      <ls_extension1>-field4 = is_data-xmwst.
*    ENDIF.

    " Elemento PEP
    IF is_data-projk IS NOT INITIAL.
      APPEND INITIAL LINE TO mt_extension1 ASSIGNING <ls_extension1>.
      <ls_extension1>-field1 = iv_pos.
      <ls_extension1>-field3 = 'PS_PSP_PNR'.
      CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
        EXPORTING
          input  = is_data-projk
        IMPORTING
          output = <ls_extension1>-field4.
    ENDIF.

    " Retenciones
    IF is_data-witht IS NOT INITIAL.
      APPEND INITIAL LINE TO mt_retencions ASSIGNING FIELD-SYMBOL(<ls_retencions>).
      <ls_retencions>-itemno_acc = iv_pos.
      <ls_retencions>-wt_type = is_data-witht.
      <ls_retencions>-wt_code = is_data-qsskz.
      <ls_retencions>-bas_amt_lc = is_data-qsshb.

    ENDIF.
  ENDMETHOD.


  METHOD ejecutar_bapi_conta.
    DATA lv_obj_key   TYPE bapiache09-obj_key.


    CLEAR: es_clv_doc_fi, et_return.

* Primero validamos que funcionalmente el documento sea correcto.
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        documentheader    = ms_documentheader
      TABLES
        accountgl         = mt_accountgl[]
        currencyamount    = mt_currencyamount[]
        accounttax        = mt_accounttax[]
        accountpayable    = mt_accountpayable[]
        accountreceivable = mt_accountreceivable[]
        accountwt         = mt_retencions[]
        extension1        = mt_extension1[]
        return            = et_return[].

* Si no hay errores lanzamos el proceso de grabacion y se esta lanzando en modo real
    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = cs_message-error.
    IF sy-subrc NE 0.

      IF p_real = abap_true.

        CLEAR et_return.

        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
          EXPORTING
            documentheader    = ms_documentheader
          IMPORTING
            obj_key           = lv_obj_key
          TABLES
            accountgl         = mt_accountgl[]
            currencyamount    = mt_currencyamount[]
            accounttax        = mt_accounttax[]
            accountpayable    = mt_accountpayable[]
            accountreceivable = mt_accountreceivable[]
            accountwt         = mt_retencions[]
            extension1        = mt_extension1[]
            return            = et_return[].

* Si hay algun error en la contabilización se devuelve el error.
        READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = cs_message-error.
        IF sy-subrc = 0.
          IF iv_commit = abap_true.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ENDIF.
        ELSE.
          es_clv_doc_fi = lv_obj_key. " Paso la clave devuelta a una estructura.

          IF iv_commit = abap_true.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
          ENDIF.

          " Se devuelve un mensaje genérico para entender
          CLEAR et_return.
          DATA(lv_msg) = |{ TEXT-s04 } { es_clv_doc_fi-bukrs } { es_clv_doc_fi-belnr } { es_clv_doc_fi-gjahr }|.
          INSERT VALUE #( type = cs_message-success message = lv_msg ) INTO TABLE et_return.

        ENDIF.
      ELSE.
        " Si no hay errores y solo se quiere simulacion limpio los mensajes para devolver un generico.
        " Porque el que devuelve la bapi es demasido técnico
        CLEAR et_return.
        INSERT VALUE #( type = cs_message-success message = TEXT-s03 ) INTO TABLE et_return.

      ENDIF.

    ELSE.
      " Borro el mensaje generico.
      DELETE et_return WHERE id = 'RW' AND number = '609'.

      " Ahora miro si hay mensajes distintos a la clase de mensaje RW. Si es así, borro los RW porque no aportan nada.
      " Si no hay distinto a RW, entonces los dejo.
      LOOP AT et_return TRANSPORTING NO FIELDS WHERE id NE 'RW'.
        DELETE et_return WHERE id = 'RW'.
        EXIT.
      ENDLOOP.


    ENDIF.



    " Hay errores, como el de proveedor, que los devuelve por duplicados. Por eso los quito.
    SORT et_return BY type id number.
    DELETE ADJACENT DUPLICATES FROM et_return COMPARING type id number.
  ENDMETHOD.

  METHOD on_link_click.

    READ TABLE mt_data ASSIGNING FIELD-SYMBOL(<ls_data>) INDEX row.
    IF sy-subrc = 0.
      CASE column.
        WHEN 'BELNR'.
          ir_doc_fi( EXPORTING iv_bukrs = <ls_data>-bukrs
                               iv_belnr = <ls_data>-belnr
                               iv_gjahr = <ls_data>-gjahr
                               iv_rldnr = <ls_data>-rldnr ).
      ENDCASE.
    ENDIF.

  ENDMETHOD.

  METHOD on_user_command.

  ENDMETHOD.


  METHOD ir_doc_fi.

    IF iv_belnr IS NOT INITIAL.
      IF p_norm = abap_true.
        AUTHORITY-CHECK OBJECT 'S_TCODE'
               ID 'TCD' FIELD 'FB03'.
        IF sy-subrc = 0.
          SET PARAMETER ID 'BUK' FIELD iv_bukrs.
          SET PARAMETER ID 'BLN' FIELD iv_belnr.
          SET PARAMETER ID 'GJR' FIELD iv_gjahr.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE s172(00) WITH 'FB03'.
        ENDIF.
      ELSEIF p_ledger = abap_true.
        AUTHORITY-CHECK OBJECT 'S_TCODE'
               ID 'TCD' FIELD 'FB03L'.
        IF sy-subrc = 0.
          SET PARAMETER ID 'BUK' FIELD iv_bukrs.
          SET PARAMETER ID 'BLN' FIELD iv_belnr.
          SET PARAMETER ID 'GJR' FIELD iv_gjahr.
          " Parámetro del ledger para un control interno que hace la FB03L
          SET PARAMETER ID 'GLN' FIELD iv_rldnr.
          " Parámetro oficial de la pantalla
          SET PARAMETER ID 'GLN_FLEX' FIELD iv_rldnr.
          CALL TRANSACTION 'FB03L' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE s172(00) WITH 'FB03L'.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDMETHOD.





  METHOD posting_document_ledger.

    CLEAR: et_return, ev_belnr, ev_bukrs, ev_gjahr.

    CLEAR: mt_currency_ledger, mt_accountgl_ledger, ms_documentheader_ledger, mt_extensionin_ledger.

    " Como la cabecera se repite en todos los registros solo es necesario leer el primer registro para obtener los datos
    DATA(ls_data_header) = it_data[ 1 ].


    " Datos cabecera del documento para ledger
    fill_cab_posting_doc_ledger( is_data_header = ls_data_header ).


    " Posiciones del documento
    fill_pos_posting_doc_ledger( EXPORTING it_data = it_data ).


    " Se lanza la contabilización con los documentos generados
    ejecutar_bapi_conta_ledger( EXPORTING iv_commit = abap_true
                                IMPORTING es_clv_doc_fi = DATA(ls_clv_doc_fi)
                                   et_return = et_return ).

    ev_belnr = ls_clv_doc_fi-belnr.
    ev_bukrs = ls_clv_doc_fi-bukrs.
    ev_gjahr = ls_clv_doc_fi-gjahr.

  ENDMETHOD.


  METHOD fill_cab_posting_doc_ledger.
    ms_documentheader_ledger-fisc_year   = is_data_header-budat(4).
    ms_documentheader_ledger-pstng_date  = is_data_header-budat.
    ms_documentheader_ledger-doc_date    = is_data_header-bldat.
    ms_documentheader_ledger-username    = sy-uname.
    ms_documentheader_ledger-comp_code   = is_data_header-bukrs.
    ms_documentheader_ledger-doc_type = is_data_header-blart.
    ms_documentheader_ledger-ref_doc_no = is_data_header-xblnr.
    ms_documentheader_ledger-header_txt = is_data_header-bktxt.
    ms_documentheader_ledger-acc_principle = is_data_header-acc_principle.

  ENDMETHOD.


  METHOD fill_pos_posting_doc_ledger.

    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      DATA(lv_pos) = CONV posnr_acc( sy-tabix ).


      IF <ls_data>-hkont IS NOT INITIAL. " Datos de cuenta
        fill_pos_account_doc_ledger( EXPORTING iv_pos = lv_pos
                                        is_data = <ls_data> ).
      ENDIF.

      " Importe de la posición
      fill_pos_amount_doc_ledger( EXPORTING iv_pos = lv_pos
                                 is_data = <ls_data> ).

      " Clave de la contabilización
      fill_pos_accnt_key_doc_ledger( EXPORTING iv_pos = lv_pos
                                 is_data = <ls_data> ).

    ENDLOOP.


  ENDMETHOD.


  METHOD fill_pos_account_doc_ledger.

    " Datos apunte contables
    APPEND INITIAL LINE TO mt_accountgl_ledger ASSIGNING FIELD-SYMBOL(<ls_account_gl>).
    <ls_account_gl>-itemno_acc = iv_pos.

    <ls_account_gl>-gl_account = |{ is_data-hkont ALPHA = IN }|.
    <ls_account_gl>-pstng_date  = ms_documentheader-pstng_date. " Fecha contabilizacion
    <ls_account_gl>-item_text = is_data-sgtxt.
    <ls_account_gl>-alloc_nmbr = is_data-zuonr.
    <ls_account_gl>-costcenter = is_data-kostl.
    <ls_account_gl>-profit_ctr = |{ is_data-prctr ALPHA = IN }|.

    CALL FUNCTION 'CONVERSION_EXIT_ABPSN_INPUT'
      EXPORTING
        input  = is_data-projk
      IMPORTING
        output = <ls_account_gl>-wbs_element.

    <ls_account_gl>-bus_area = is_data-gsber.
    <ls_account_gl>-orderid = |{ is_data-aufnr ALPHA = IN }|.
    <ls_account_gl>-segment = is_data-segment.
    <ls_account_gl>-ref_key_1 = is_data-xref1.
    <ls_account_gl>-ref_key_2 = is_data-xref2.
    <ls_account_gl>-ref_key_3 = is_data-xref3.
    <ls_account_gl>-ref_key_3 = is_data-xref3.


  ENDMETHOD.


  METHOD fill_pos_amount_doc_ledger.

    APPEND INITIAL LINE TO mt_currency_ledger ASSIGNING FIELD-SYMBOL(<ls_amount>).
    <ls_amount>-itemno_acc = iv_pos.
    <ls_amount>-currency   = is_data-waers.
    <ls_amount>-amt_doccur = is_data-wrbtr.

  ENDMETHOD.


  METHOD fill_pos_accnt_key_doc_ledger.

    APPEND INITIAL LINE TO mt_extensionin_ledger ASSIGNING FIELD-SYMBOL(<ls_extension1>).
    <ls_extension1>-field1 = iv_pos.
    <ls_extension1>-field2 = 'BSCHL'.
    <ls_extension1>-field3 = is_data-bschl.

  ENDMETHOD.


  METHOD ejecutar_bapi_conta_ledger.

    DATA lv_obj_key   TYPE bapiache09-obj_key.


    CLEAR: es_clv_doc_fi, et_return.

* Primero validamos que funcionalmente el documento sea correcto.
    CALL FUNCTION 'BAPI_ACC_GL_POSTING_CHECK'
      EXPORTING
        documentheader = ms_documentheader_ledger
      TABLES
        accountgl      = mt_accountgl_ledger
        currencyamount = mt_currency_ledger
        return         = et_return
        extension1     = mt_extensionin_ledger.


* Si no hay errores lanzamos el proceso de grabacion y se esta lanzando en modo real
    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = cs_message-error.
    IF sy-subrc NE 0.

      IF p_real = abap_true.

        CLEAR et_return.

        CALL FUNCTION 'BAPI_ACC_GL_POSTING_POST'
          EXPORTING
            documentheader = ms_documentheader_ledger
          IMPORTING
            obj_key        = lv_obj_key
          TABLES
            accountgl      = mt_accountgl_ledger
            currencyamount = mt_currency_ledger
            return         = et_return
            extension1     = mt_extensionin_ledger.

* Si hay algun error en la contabilización se devuelve el error.
        READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = cs_message-error.
        IF sy-subrc = 0.
          IF iv_commit = abap_true.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ENDIF.
        ELSE.
          es_clv_doc_fi = lv_obj_key. " Paso la clave devuelta a una estructura.

          IF iv_commit = abap_true.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
          ENDIF.

          " Se devuelve un mensaje genérico para entender
          CLEAR et_return.
          DATA(lv_msg) = |{ TEXT-s04 } { es_clv_doc_fi-bukrs } { es_clv_doc_fi-belnr } { es_clv_doc_fi-gjahr }|.
          INSERT VALUE #( type = cs_message-success message = lv_msg ) INTO TABLE et_return.

        ENDIF.
      ELSE.
        " Si no hay errores y solo se quiere simulacion limpio los mensajes para devolver un generico.
        " Porque el que devuelve la bapi es demasido técnico
        CLEAR et_return.
        INSERT VALUE #( type = cs_message-success message = TEXT-s03 ) INTO TABLE et_return.

      ENDIF.

    ELSE.
      " Borro el mensaje generico.
      DELETE et_return WHERE id = 'RW' AND number = '609'.

      " Ahora miro si hay mensajes distintos a la clase de mensaje RW. Si es así, borro los RW porque no aportan nada.
      " Si no hay distinto a RW, entonces los dejo.
      LOOP AT et_return TRANSPORTING NO FIELDS WHERE id NE 'RW'.
        DELETE et_return WHERE id = 'RW'.
        EXIT.
      ENDLOOP.


    ENDIF.



    " Hay errores, como el de proveedor, que los devuelve por duplicados. Por eso los quito.
    SORT et_return BY type id number.
    DELETE ADJACENT DUPLICATES FROM et_return COMPARING type id number.

  ENDMETHOD.


  METHOD fill_pos_account_tax.
    DATA lt_taxes TYPE STANDARD TABLE OF rtax1u15.

    CLEAR: ev_tax_amount.

    CALL FUNCTION 'CALCULATE_TAX_FROM_GROSSAMOUNT'
      EXPORTING
        i_bukrs = is_data-bukrs
        i_mwskz = is_data-mwskz
        i_waers = is_data-waers
        i_wrbtr = is_data-wrbtr
      TABLES
        t_mwdat = lt_taxes.

    READ TABLE lt_taxes ASSIGNING FIELD-SYMBOL(<ls_taxes>) INDEX 1.
    IF sy-subrc = 0.
      " Se incrementa en uno la posición global ya que el impuesto se añade como una posición más en el documento
      cv_pos = cv_pos + 1.
      APPEND INITIAL LINE TO mt_accounttax ASSIGNING FIELD-SYMBOL(<ls_accounttax>).

      <ls_accounttax>-itemno_acc = sy-tabix + 1.
      <ls_accounttax>-tax_code = is_data-mwskz.
      <ls_accounttax>-acct_key = <ls_taxes>-ktosl.
      <ls_accounttax>-cond_key = <ls_taxes>-kschl.
      <ls_accounttax>-taxjurcode = <ls_taxes>-txjcd.
      <ls_accounttax>-taxjurcode_deep = <ls_taxes>-txjcd_deep.
      <ls_accounttax>-taxjurcode_level = <ls_taxes>-txjlv.

      "Importe del impuesto
      APPEND INITIAL LINE TO mt_currencyamount ASSIGNING FIELD-SYMBOL(<ls_amount>).
      <ls_amount>-itemno_acc = cv_pos.
      <ls_amount>-currency   = is_data-waers.
      <ls_amount>-amt_doccur = <ls_taxes>-wmwst.
      <ls_amount>-amt_base  = <ls_taxes>-kawrt.

      " Se devuelve la base del impuesto que servirá para ponerlo en el importe de la cuenta de mayor
      ev_tax_amount = <ls_taxes>-kawrt.
    ENDIF.



  ENDMETHOD.

ENDCLASS.
