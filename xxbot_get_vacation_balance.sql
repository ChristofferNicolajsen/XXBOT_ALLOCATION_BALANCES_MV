--------------------------------------------------------
--  File created - onsdag-februar-13-2019   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XXBOT_GET_VACATION_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."XXBOT_GET_VACATION_BALANCE" (l_person_id IN NUMBER, l_type IN NUMBER) 
return varchar2 AS 
/* kreeret af CNIC 19-03-2018 
   funktionen returnerer antallet af restferiedage for en person
   hvis l_type = 0 så ferie med løn
   ellers ferie uden løn 
   15-01-2019 tilføjet særlige feriedage samt omsorgsdage
   */


BEGIN
declare 
  l_aar                 NUMBER;
  l_bg_id               NUMBER;
  l_mlon                NUMBER;
  l_ulon                NUMBER;
  l_lontraek            NUMBER;
  l_giro                NUMBER;
  l_optjent             NUMBER;
  l_ovf_fra             NUMBER;
  l_ovf_til             NUMBER;
  l_afholdt             NUMBER;
  l_udbetalt            NUMBER;
  l_saldo               NUMBER;
  l_nulstil             NUMBER; -- 1.12
  l_tildelt             NUMBER;
  l_nul_aarsskifte      NUMBER;
  l_nul_fratraedelse    NUMBER;
  l_nul_relation        NUMBER;
  l_gl_saldo            NUMBER;

 p_person_id            NUMBER;-- := 23311;
 p_mlon                 NUMBER;
 p_ulon                 NUMBER;
 p_ulon_rest            NUMBER;
 p_mlon_rest            NUMBER;
 p_opslagsdato          DATE;
 p_afholdt              NUMBER;
 l_year                 NUMBER;

 --p_business_group_id
 --
BEGIN
    p_person_id := l_person_id;
    SELECT LAST_DAY(add_months(sysdate,-1)) into p_opslagsdato from dual;
  --select distinct business_group_id from per_all_people_f where person_id = 23311 = 0
  -- determins business_group_id and optjeningsår
  select distinct business_group_id into l_bg_id from per_all_people_f where person_id = p_person_id;

   /* finder optjeningsår for sidste dag i forrige måned */
       IF TO_NUMBER(TO_CHAR(p_opslagsdato,'MMDD')) > '0500' THEN
          -- new ferieår
          l_aar := TO_NUMBER(TO_CHAR(p_opslagsdato,'YYYY')) - 1;
       ELSE l_aar := TO_NUMBER(TO_CHAR(p_opslagsdato,'YYYY')) - 2;
       END IF;
IF l_type <= 10 THEN
  xxups_ferfo.overfor_ferie(
     p_aar                => l_aar          --IN number
    ,p_opslagsdato        => p_opslagsdato  --IN DATE
    ,p_business_group_id  => 0        --IN NUMBER
    ,p_person_id          => p_person_id    --IN NUMBER

    ,p_mlon               => l_mlon         --OUT NUMBER
    ,p_ulon               => l_ulon         --OUT NUMBER

    ,p_ovf_fra            => l_ovf_fra      --OUT NUMBER
    ,p_ovf_til            => l_ovf_til      --OUT NUMBER
    ,p_afholdt            => l_afholdt      --OUT NUMBER
    ,p_udbetalt           => l_udbetalt     --OUT NUMBER
    ,p_mlon_rest          => p_mlon_rest    --OUT NUMBER
    ,p_ulon_rest          => p_ulon_rest    --OUT NUMBER
    ,p_løntræk            => l_lontraek     --OUT NUMBER
    ,p_giro               => l_giro         --OUT NUMBER
    ,p_nulstil            => l_nulstil      --OUT NUMBER  1.12
    );

case l_type
    when 0 then return ROUND(p_mlon_rest,2);
    when 1 then return ROUND(p_ulon_rest,2);
    when 2 then return ROUND(l_mlon,2);
    when 3 then return ROUND(l_ulon,2);
    when 4 then return p_opslagsdato;
    when 5 then return ROUND(l_udbetalt,2);
    else return -999;

    END CASE;
END IF;


IF l_type > 10 and l_type <= 20 THEN
xxups_ferfo.overfor_saer_ferie(
     p_aar                => l_aar          --IN number
    ,p_opslagsdato        => p_opslagsdato  --IN DATE
    ,p_business_group_id  => 0        --IN NUMBER
    ,p_person_id          => p_person_id    --IN NUMBER

    ,p_optjent            => l_optjent      --OUT NUMBER
    ,p_ovf_fra            => l_ovf_fra      --OUT NUMBER
    ,p_ovf_til            => l_ovf_til      --OUT NUMBER
    ,p_afholdt            => l_afholdt      --OUT NUMBER
    ,p_udbetalt           => l_udbetalt     --OUT NUMBER
    ,p_saldo              => l_saldo        --OUT NUMBER
    ,p_nulstil            => l_nulstil      --OUT NUMBER  1.12
);

case l_type
    when 11 then return ROUND(l_saldo,2);
    when 12 then return ROUND(l_afholdt,2);
    else return -999;

    END CASE;
END IF;

IF l_type > 20 and l_type <= 30 THEN  /*OMSORGSDAGE*/
xxwm_omsorgfo.overfor_omsorg(
     p_aar                => l_aar              --IN number
    ,p_business_group_id  => 0                  --IN NUMBER
    ,p_person_id          => p_person_id        --IN NUMBER

    ,p_tildelt            => l_tildelt          --OUT NUMBER
    ,p_ovf_fra            => l_ovf_fra          --OUT NUMBER
    ,p_afholdt            => l_afholdt          --OUT NUMBER
    ,p_nul_aarsskifte     => l_nul_aarsskifte   --OUT NUMBER
    ,p_nul_fratraedelse   => l_nul_fratraedelse --OUT NUMBER
    ,p_nul_relation       => l_nul_relation     --OUT NUMBER
    ,p_saldo              => l_saldo            --OUT NUMBER
    );

case l_type
    when 21 then return ROUND(l_saldo,2);    --Restsaldo omsorgsdage
    when 22 then return ROUND(l_tildelt,2);  --Tildelte omsorgsdage
    else return -999;
END CASE;
END IF;  


IF l_type > 30 and l_type <= 40 THEN  /*OMSORGSDAGE*/
xxwm_omsorgfo.overfor_gl_omsorg(
     p_aar                => l_aar              --IN number
    ,p_business_group_id  => 0                  --IN NUMBER
    ,p_person_id          => p_person_id        --IN NUMBER
    ,p_gl_saldo           => l_gl_saldo         --OUT NUMBER
    );
case l_type
    when 31 then return ROUND(l_saldo,2);    --Restsaldo omsorgsdage gamle regler
    else return -999;
END CASE;
END IF;
END;
END XXBOT_GET_VACATION_BALANCE;

/
