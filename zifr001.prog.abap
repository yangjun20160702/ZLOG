*&---------------------------------------------------------------------*
*& Report ZIFR001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zifr001.

TABLES:zif_ifdef,ztif001.

TYPES: BEGIN OF ty_alv,
         ifnum     TYPE zif_ifdef-ifnum,
         ifnam     TYPE zif_ifdef-ifnam,
         ifmod     TYPE ztif001-ifmod,
         iffuc     TYPE ztif001-iffuc,
         bukrs     TYPE ztif001-bukrs,
         programm  TYPE ztif001-programm,
         tcode     TYPE ztif001-tcode,
         mess(100) TYPE c,
       END OF ty_alv.

DATA:gt_fieldcat TYPE lvc_t_fcat,      " 字段目录
     gs_fieldcat TYPE lvc_s_fcat,
     gs_layout   TYPE lvc_s_layo.      " 布局结构

DEFINE macro_init_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname        = &1.     "字段名称
  gs_fieldcat-ref_field        = &2.     "字段参考字段
  gs_fieldcat-ref_table        = &3.     "字段参考表
  gs_fieldcat-scrtext_l        = &4.     "字段长名称
  gs_fieldcat-scrtext_s        = &4.     "字段短名称
  gs_fieldcat-scrtext_m        = &4.     "字段中名称
  gs_fieldcat-coltext          = &4.
  gs_fieldcat-edit             = &5.
  APPEND gs_fieldcat TO gt_fieldcat.

END-OF-DEFINITION.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME .

  SELECT-OPTIONS:s_ifnum FOR zif_ifdef-ifnum,
                 s_ifmod FOR ztif001-ifmod.

SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION .
  PERFORM frm_get_data.

END-OF-SELECTION.

*--设置字段目录
  PERFORM frm_set_fieldcat.
*--设置布局属性
  PERFORM frm_set_layout.
*--ALV显示
  PERFORM frm_dispaly_alv.

FORM frm_get_data.

  SELECT
    a~ifnum,
    a~ifnam,
    b~ifmod,
    b~iffuc,
    b~programm,
    b~bukrs,
    b~tcode,
    CASE WHEN programm IS INITIAL
         THEN '请维护ZTIF001'
         ELSE ' '
         END AS mess
    FROM zif_ifdef AS a
    LEFT JOIN ztif001 AS b ON a~ifnum = b~ifnum
    WHERE a~ifnum IN @s_ifnum
    INTO TABLE @DATA(lt_ifdef).

ENDFORM.

FORM frm_set_fieldcat.

  macro_init_fieldcat 'IFNUM '    'IFNUM'    'ZIF_IFDEF'  '接口编号'    ''.
  macro_init_fieldcat 'IFNAM '    'IFNAM'    'ZIF_IFDEF'  '接口名称'    ''.
  macro_init_fieldcat 'IFMOD '    'IFMOD'    'ZTIF001'    '业务模块'    ''.
  macro_init_fieldcat 'BUKRS '    'BUKRS'    'ZTIF001'    '公司代码'    ''.
  macro_init_fieldcat 'PROGRAMM ' 'PROGRAMM' 'ZTIF001 '   '程序名称'    ''.
  macro_init_fieldcat 'TCODE '    'TCODE'    'ZTIF001'    '事务代码'    ''.
  macro_init_fieldcat 'IFFUC '    'IFFUC'    'ZTIF001'    '接口函数'    ''.
  macro_init_fieldcat 'MESS '     'MESS'     'ZTIF001'    '消息'        ''.

ENDFORM.

FORM frm_set_layout.
  CLEAR gs_layout.
  gs_layout-sel_mode = 'A'.     "设置行模式"
  gs_layout-cwidth_opt = 'X'.   "优化列宽设置"
  gs_layout-zebra = 'X'.        "设置斑马线"
*  gs_layout-box_fname = 'CHECK'.         "选择字段
ENDFORM.

FORM frm_dispaly_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = sy-repid         "当前程序
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'ALV_USER_COMMAND'
      it_events                = lt_events       "事件注册
      is_layout_lvc            = gs_layout     "界面格式"
      it_fieldcat_lvc          = gt_fieldcat   "字段属性"
      i_save                   = 'A'           "字段属性"
    TABLES
      t_outtab                 = gt_alv
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.

FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STD'. "自定义状态名称
ENDFORM. "set_pf_status

FORM alv_user_command USING r_ucomm LIKE sy-ucomm
      rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1'.   "双击
      READ TABLE gt_alv INTO gs_alv INDEX rs_selfield-tabindex.
      IF sy-subrc = 0 AND gs_alv-programm IS NOT INITIAL.
        PERFORM frm_call_programm.
      ENDIF.

    WHEN 'ZCL'.
      PERFORM frm_post_data.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.
