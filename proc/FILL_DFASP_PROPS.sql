create or replace procedure USR_P_FILL_DFASP_PROPS (
        nCOMPANY in number,
        nRN in number
    ) as nCRN number(17);
nGTIN number(17);
nGTIN_prop number(17);
nLIMIT_PRICE number(17);
nLIMIT_PRICE_prop number(17);
nSOLUTION_NUMB number(17);
nSOLUTION_NUMB_prop number(17);
dREG_DATE date;
dREG_DATE_prop number(17);
sUNITCODE varchar2(21) := 'AccountFactInputSlave';
inout_rn number(17);
begin begin
select mc.CRN,
    mcg.GTIN,
    mcg.LIMIT_PRICE,
    mcg.SOLUTION_NUMB,
    mcg.REG_DATE into nCRN,
    nGTIN,
    nLIMIT_PRICE,
    nSOLUTION_NUMB,
    dREG_DATE
from DICLACFI DA
    join NOMMODIF mc on mc.RN = DA.FOODMODIF_CODE
    join MMRMEDCARD mcd on mcd.NOMMODIF = mc.RN
    join MMRMEDCTLG mcc on mcc.RN = mcd.MMRMEDCTLG
    join MMRMEDCTLGPRS mcg on mcg.PRN = mcc.RN
where DA.RN = nRN;
exception
when others then p_exception(0, sqlerrm);
end;
if nCRN = 1726344157 then FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'Штрих-код (GTIN)', nGTIN_prop);
FIND_DOCS_PROPS_CODE(
    0,
    nCOMPANY,
    'ДатаРегистрацииЦены',
    dREG_DATE_prop
);
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'ФармЦенаЗавода', nLIMIT_PRICE_prop);
FIND_DOCS_PROPS_CODE(
    0,
    nCOMPANY,
    'НомерРегистрацУдост',
    nSOLUTION_NUMB_prop
);
if nGTIN is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
    nRN,
    sUNITCODE,
    nGTIN_prop,
    nGTIN,
    null,
    null,
    inout_rn
);
end if;
if dREG_DATE is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
    nRN,
    sUNITCODE,
    dREG_DATE_prop,
    null,
    null,
    dREG_DATE,
    inout_rn
);
end if;
if nLIMIT_PRICE is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
    nRN,
    sUNITCODE,
    nLIMIT_PRICE_prop,
    nLIMIT_PRICE,
    null,
    null,
    inout_rn
);
end if;
if nSOLUTION_NUMB is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
    nRN,
    sUNITCODE,
    nSOLUTION_NUMB_prop,
    nSOLUTION_NUMB,
    null,
    null,
    inout_rn
);
end if;
end if;
end;
