--------------------------------------------------------
--  File created - onsdag-februar-13-2019   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Materialized View XXBOT_ALLOCATION_BALANCES_MV
--------------------------------------------------------

  CREATE MATERIALIZED VIEW "APPS"."XXBOT_ALLOCATION_BALANCES_MV" ("FULL_NAME", "USER_NAME", "PERSON_ID", "FLEXSALDO", "FERIE_MLON", "FERIE_ULON", "FERIE_MLON_IALT", "FERIE_ULON_IALT", "FERIE_UDBETALT", "FERIE_OPSLAGSDATO", "SAER_FERIESALDI", "OMSORGSDAGE_SALDO", "OMSORGSDAGE_TILDELT", "OMSORGSDAGE_SALDO_GL_REGLER", "LAST_UPDATE")
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "APPS_TS_TX_DATA"   NO INMEMORY 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH FORCE ON DEMAND START WITH sysdate+0 NEXT SYSDATE + 1
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE QUERY REWRITE
  AS SELECT ppf.full_name, fu.user_name, ppf.person_id, XXBOT_GET_FLEX_BALANCE(ppf.person_id) AS flexsaldo
    , xxbot_get_vacation_balance(ppf.person_id,0) AS ferie_mlon, xxbot_get_vacation_balance(ppf.person_id,1) AS ferie_ulon, xxbot_get_vacation_balance(ppf.person_id,2) AS ferie_mlon_ialt
    , xxbot_get_vacation_balance(ppf.person_id,3) AS ferie_mlon_ialt, xxbot_get_vacation_balance(ppf.person_id,5) AS ferie_mlon_ialt, xxbot_get_vacation_balance(ppf.person_id,4) AS ferie_opslagsdato
    , xxbot_get_vacation_balance(ppf.person_id, 11) AS saer_feriesaldi, xxbot_get_vacation_balance(ppf.person_id, 21) AS omsorgsdage_saldo 
    , xxbot_get_vacation_balance(ppf.person_id, 22) AS omsorgsdage_tildelt, xxbot_get_vacation_balance(ppf.person_id, 31) AS omsorgsdage_saldo_gl_regler  
    , SYSDATE
    FROM per_people_f ppf
    JOIN fnd_user fu ON (fu.employee_id = ppf.person_id)
    WHERE sysdate BETWEEN ppf.effective_start_date AND nvl(ppf.effective_end_date,sysdate);

   COMMENT ON MATERIALIZED VIEW "APPS"."XXBOT_ALLOCATION_BALANCES_MV"  IS 'snapshot table for snapshot APPS.XXBOT_ALLOCATION_BALANCES_MV';
