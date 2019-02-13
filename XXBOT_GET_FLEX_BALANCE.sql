--------------------------------------------------------
--  File created - onsdag-februar-13-2019   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XXBOT_GET_FLEX_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."XXBOT_GET_FLEX_BALANCE" (l_person_id IN NUMBER) 
RETURN VARCHAR2 AS 
/* Oprettet af CNIC 25-10-2018 
   funktionen returnerer flexsaldo for person
   */

BEGIN
declare
  flexbalance   NUMBER := 0;
  p_person_id   NUMBER; -- := 23311;

BEGIN
    p_person_id := l_person_id;

    select nvl(SUM(pei.quantity),0)
    into flexbalance
    from pa_expenditures_all pe, pa_expenditure_items_all pei 
    where pe.expenditure_id = pei.expenditure_id 
    and pe.incurred_by_person_id = p_person_id
    and pei.project_id = 1571901 -- 'FLEX BALANCER'
    and pei.task_id = 1545641    -- 'FLEX'
    and pei.expenditure_item_date <= last_day(add_months(sysdate,-1));

    return flexbalance;
END;
END XXBOT_GET_FLEX_BALANCE;

/
