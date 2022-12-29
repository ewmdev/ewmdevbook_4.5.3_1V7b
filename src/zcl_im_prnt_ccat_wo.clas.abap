class ZCL_IM_PRNT_CCAT_WO definition
  public
  final
  create public .

public section.

  interfaces /SCWM/IF_EX_PRNT_CCAT_WO .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.

  constants CV_FIELDNAME type /SAPCND/FIELDNAME value 'ZHUFLAG' ##NO_TEXT.
ENDCLASS.



CLASS ZCL_IM_PRNT_CCAT_WO IMPLEMENTATION.


  METHOD /scwm/if_ex_prnt_ccat_wo~change.

    DATA: lt_ordim_o   TYPE /scwm/tt_ordim_o,
          ls_attribute TYPE /sapcnd/det_attrib_value.

    BREAK-POINT ID zewmdevbook_453.

    DATA(lo_appl) = CAST /scwm/cl_wo_ppf( io_context_wo->appl ).
    DATA(lv_tanum) = lo_appl->get_tanum( ).
    IF lv_tanum IS INITIAL.
      RETURN.
    ENDIF.
    "1 See if field ZHUFLAG is in request
    READ TABLE ct_request
    ASSIGNING FIELD-SYMBOL(<fs_request>) INDEX 1.
    READ TABLE <fs_request>-item_attributes
    ASSIGNING FIELD-SYMBOL(<fs_attribute>)
    WITH KEY fieldname = cv_fieldname. "'ZHUFLAG'
    IF sy-subrc = 0 AND <fs_attribute>-value IS INITIAL.
      DELETE <fs_request>-item_attributes INDEX sy-tabix.
    ELSE.
      RETURN. "field is not in condition table, so value is not required
    ENDIF.
    "2 Get the WT from memory
    DATA(lv_who) = lo_appl->get_who( ).
    IF lv_who IS NOT INITIAL.
      TRY.
          CALL FUNCTION '/SCWM/WHO_GET'
            EXPORTING
              iv_lgnum   = iv_lgnum
              iv_whoid   = lv_who
              iv_to      = abap_true
            IMPORTING
              et_ordim_o = lt_ordim_o.
        CATCH /scwm/cx_core.
          "no error
      ENDTRY.
    ENDIF.
    "3 Determine if it is a product or HU task
    READ TABLE lt_ordim_o ASSIGNING FIELD-SYMBOL(<ordim_o>)
    WITH KEY tanum = lv_tanum.
    IF sy-subrc IS INITIAL.
      CASE <ordim_o>-flghuto.
        WHEN space.
          ls_attribute-value = 'P'.
        WHEN abap_true.
          ls_attribute-value = 'H'.
      ENDCASE.
    ENDIF.
    "4 Return the value
    ls_attribute-fieldname = cv_fieldname. "'ZHUFLAG'
    TRANSLATE ls_attribute-value TO UPPER CASE.
    INSERT ls_attribute INTO TABLE <fs_request>-item_attributes.

  ENDMETHOD.
ENDCLASS.
