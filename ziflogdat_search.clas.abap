CLASS ziflogdat_search DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES IF_AMDP_MARKER_HDB.  "amdp sql接口实现
  TYPES:BEGIN OF ty_data,
        score  type  eigenmaak_dec6,
        mandt  type  zif_logdat-mandt,
        guid   type  zif_logdat-guid,
        logtyp type  zif_logdat-logtyp,
        paylod type  zif_logdat-paylod,
       END OF ty_data.

       types: it_header type table of zif_header,
              it_data   type table of ty_data.

        CLASS-METHODS GETDATA
        IMPORTING
            VALUE(IV_MANDT) TYPE MANDT
            VALUE(IV_WHERE) TYPE STRING
            VALUE(IT_HEAD)  TYPE IT_HEADER
        EXPORTING
            VALUE(ET_DATA)  TYPE IT_DATA.

        CLASS-METHODS GETDATA2
        IMPORTING
            VALUE(IV_MANDT) TYPE MANDT
            VALUE(IV_WHERE) TYPE STRING
        EXPORTING
            VALUE(ET_DATA)  TYPE IT_DATA.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ziflogdat_search IMPLEMENTATION.
  METHOD getdata BY DATABASE PROCEDURE FOR HDB LANGUAGE
                    SQLSCRIPT OPTIONS READ-ONLY USING zif_logdat .
      et_data = SELECT
           score() as score,
           f.mandt ,
           f.guid,
           logtyp,
           paylod
           from  zif_logdat as f
           inner join :it_head as h on h.mandt = f.mandt and h.guid = f.guid
          where  f.mandt = :iv_mandt
            and contains(paylod, iv_where, fuzzy(0.8))
          ;
   ENDMETHOD.

    METHOD getdata2 BY DATABASE PROCEDURE FOR HDB LANGUAGE
                    SQLSCRIPT OPTIONS READ-ONLY USING zif_logdat .
      et_data = SELECT
           score() as score,
           f.mandt ,
           f.guid,
           logtyp,
           paylod
           from  zif_logdat as f
          where  f.mandt = :iv_mandt
            and contains(paylod, iv_where, fuzzy(0.8))
            ORDER BY score DESC;
   ENDMETHOD.
ENDCLASS.
