create or replace procedure USR_P_INV_RESULTS (
nCOMPANY              in number,       -- Организация
nIDENT                in number,       -- Помеченная запись
sDOC_TYPE             in varchar2,     -- Тип документа (мнемокод)
dDATE                 in date)         -- Дата
as
nRN_temp_p            int; -- Родитель
nRN_temp              int; -- Для выходных РНов
nRN_temp_sp           int; -- Для спецификаций
nRN_temp_ap2          int; -- Родитель для разд. 2
nRN_temp_ap3          int; -- Родитель для разд. 3
inv_nn                int; -- Для порядковых номеров
nDOCTYPE              pkg_std.tREF;
sDOCNAME              varchar2(40):= '0510463';
begin
    begin
        select dt.docname, dt.rn into sDOCNAME, nDOCTYPE from doctypes dt where dt.doccode = sDOC_TYPE;
        exception when NO_data_found then p_exception(0,'Не найден тип документа "'||sDOC_TYPE||'"');
    end;
    for zagolovok in (
        select
            T.RN as nRN,
            T.COMPANY as nCOMPANY,
            (select ac.rn from acatalog ac, acatalog ac2 where ac.docname='InventoryResultsActs'
                and ac.name=ac2.name and ac2.rn=t.crn) as nCRN_NEW,
            T.JUR_PERS as nJUR_PERS,
            D.RN as DOC_TYPE,
            T.DOC_DATE as dDOC_DATE,
            nvl(trim(T.DOC_NUMB), '') as sDOC_NUMB,
            T.INV_DATE as dINV_DATE,
            T.BEGIN_DATE as dBEGIN_DATE,
            T.END_DATE as dEND_DATE,
            T.AGENT as nAGENT,
            (select emppost from agnlist agn where agn.rn=T.AGENT) emppost,
            T.SOLUTION_NUMB as sSOLUTION_NUMB,
            T.SOLUTION_DATE as dSOLUTION_DATE,
            case
                when T.COMMIS_NUMB in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
                    then cast(T.COMMIS_NUMB as int)
                else 0
            end as nCOMMIS_NUMB, -- процедура P_INVRESACT_BASE_INSERT принимает number в номер комиссии
            T.STRUCT_SUBDIV as nSTRUCT_SUBDIV
        from
            INVLSNFA T
        join SELECTLIST SL on IDENT = nIDENT and SL.Document = T.RN
        left join DOCTYPES D on sDOC_TYPE = D.DOCCODE)
    loop
        P_INVRESACT_BASE_INSERT(
            zagolovok.nCOMPANY,
            zagolovok.nCRN_NEW,
            zagolovok.nJUR_PERS,
            zagolovok.DOC_TYPE,
            null, --docpref
            zagolovok.sDOC_NUMB,
            dDATE,
            null, -- SEP_DEP
            zagolovok.nSTRUCT_SUBDIV,
            zagolovok.sSOLUTION_NUMB,
            zagolovok.dSOLUTION_DATE,
            zagolovok.nCOMMIS_NUMB,
            null, -- nDUP_RN
            nRN_temp_p);
        for spec_bu_ok in (
            select B.RN, B.CODE, B.NAME, min(t2.PLACE_INV) place
            from INVLSNFAOBJ T2
            join DICACCS  D2 on T2.ACCOUNT = D2.RN
            join BALELEMENT B on D2.BALUNIT = B.RN
            where zagolovok.nRN = T2.PRN
                and not exists (select null from invlsnfaobjr r where r.prn=t2.rn)                        
            group by b.rn, b.code, b.name)
        loop   
            P_INVRESACTLNOK_NEXTNUMB(nCOMPANY, nRN_temp_p, inv_nn);
            P_INVRESACTLNOK_BASE_INSERT(
                nCOMPANY,
                nRN_temp_p,
                inv_nn, -- nNUMB,
                sDOC_TYPE, -- sFORM_CODE,
                sDOCNAME, -- sINVLS_NAME,
                nDOCTYPE, -- DOC_TYPE,
                zagolovok.sdoc_numb, --  sSOLUTION_NUMB,
                dDATE, -- dSOLUTION_DATE,
                spec_bu_ok.RN, -- nBALUNIT,
                spec_bu_ok.name, -- sINV_OBJ,
                spec_bu_ok.code, -- sACC_CODE,
                zagolovok.nagent, -- nAGENT,
                zagolovok.emppost, -- sAGENT_EMP,
                zagolovok.dINV_DATE,
                zagolovok.dBEGIN_DATE,
                zagolovok.dEND_DATE,
                null, -- nINS_DEP
                spec_bu_ok.place, -- nINV_PLACE,
                null, -- sPLACE_NAME
                null, -- sNOTE
                nRN_temp);
        end loop;                    
        for spec_err in (
            select
                B.RN,
                B.CODE,
                B.NAME,
                min(T2.PLACE_INV) place
            from INVLSNFAOBJ T2
            join DICACCS  D2 on T2.ACCOUNT = D2.RN
            join BALELEMENT B on D2.BALUNIT = B.RN
            where zagolovok.nRN = T2.PRN
                and exists(select null from invlsnfaobjr r where r.prn=t2.rn)
            group by B.RN, B.CODE,	B.NAME)
        loop
            P_INVRESACTLNER_NEXTNUMB(nCOMPANY, nRN_temp_p, inv_nn);
            P_INVRESACTLNER_BASE_INSERT(
                nCOMPANY,
                nRN_temp_p,
                inv_nn, -- nNUMB,
                sDOC_TYPE, -- sFORM_CODE,
                sDOCNAME, -- sINVLS_NAME,
                nDOCTYPE, -- DOC_TYPE,
                zagolovok.sdoc_numb, -- sSOLUTION_NUMB,
                zagolovok.dSOLUTION_DATE,
                spec_err.RN, -- nBALUNIT,
                spec_err.name, -- sINV_OBJ,
                spec_err.code, -- sACC_CODE,
                zagolovok.nagent, -- nAGENT,
                zagolovok.emppost, -- sAGENT_EMP,
                zagolovok.dINV_DATE,
                zagolovok.dBEGIN_DATE,
                zagolovok.dEND_DATE,
                null, -- nINS_DEP
                spec_err.place, -- nINV_PLACE,
                null, -- sPLACE_NAME
                null, -- sNOTE
                7, -- nAPP_NUMB
                nRN_temp_sp);
            FIND_INVRESACTAP2_PRN( 1, nRN_temp_p, nRN_temp_ap2 );
            if
                nRN_temp_ap2 is null
            then
                P_INVRESACTAP2_BASE_INSERT( nCOMPANY, nRN_temp_p, nRN_temp_ap2 );
            end if;
            for spec_24 in (
                select
                    T2.NOMEN as nOBJECT,
                    cast(nvl(trim(T2.INVENTORY), '-') as varchar2(100)) as sINV_NUM,
                    D2.RN as nACCOUNT,
                    T2.ANALYTIC1 as nANALYTIC1,
                    T2.ANALYTIC2 as nANALYTIC2,
                    T2.ANALYTIC3 as nANALYTIC3,
                    T2.ANALYTIC4 as nANALYTIC4,
                    T2.ANALYTIC5 as nANALYTIC5,
                    T3.QUANT_MISS as nSHORT_QTY,
                    case when T3.QUANT_MISS != 0 then T3.AMOUNT else  0 end as nSHORT_SUM,
                    T3.QUANT_OVER as nSURPL_QTY,
                    case when T3.QUANT_OVER != 0 then T3.AMOUNT else 0 end as nSURPL_SUM,
                    T3.RESOLUTION as sCONCL_INVLS
                from
                    INVLSNFAOBJ T2
                join INVLSNFAOBJR T3 on T2.RN = T3.PRN
                left join DICACCS  D2 on T2.ACCOUNT = D2.RN
                left join BALELEMENT B on D2.BALUNIT = B.RN
                where zagolovok.nRN = T2.PRN
                    and D2.BALUNIT = spec_err.RN
                    and (T3.QUANT_MISS != 0 or T3.QUANT_OVER != 0))
            loop
                P_INVRESACTAP27_NEXTNUMB(nCOMPANY, nRN_temp_ap2, inv_nn);
                P_INVRESACTAP27_BASE_INSERT(
                nCOMPANY,
                nRN_temp_ap2, --nPRN,
                inv_nn, --nNUMB,
                nRN_temp_sp, -- nINVLST
                spec_24.nOBJECT,
                spec_24.sINV_NUM, --sNFA_NUMB,
                spec_24.nACCOUNT,
                spec_24.nANALYTIC1,
                spec_24.nANALYTIC2,
                spec_24.nANALYTIC3,
                spec_24.nANALYTIC4,
                spec_24.nANALYTIC5,
                spec_24.nSHORT_QTY,
                spec_24.nSHORT_SUM,
                spec_24.nSURPL_QTY,
                spec_24.nSURPL_SUM,
                spec_24.sCONCL_INVLS,
                null, --sSOL_ACT,
                nRN_temp);
            end loop;
        end loop;
        for spec_qlty_chr in (
            select
                B.RN,
                B.CODE,
                B.NAME,
                min(T2.PLACE_INV) place
            from INVLSNFAOBJ T2
            join DICACCS  D2 on T2.ACCOUNT = D2.RN
            join BALELEMENT B on D2.BALUNIT = B.RN
            where zagolovok.nRN = T2.PRN
                and exists(select null from invlsnfaobjr r where r.prn=t2.rn)
            group by B.RN, B.CODE,	B.NAME)
        loop
            P_INVRESACTQUCH_NEXTNUMB(nCOMPANY, nRN_temp_p, inv_nn);
            P_INVRESACTQUCH_BASE_INSERT(
                nCOMPANY,
                nRN_temp_p,
                inv_nn, -- nNUMB,
                sDOC_TYPE, -- sFORM_CODE,
                sDOCNAME, -- sINVLS_NAME,
                nDOCTYPE, -- DOC_TYPE,
                zagolovok.sdoc_numb, -- sSOLUTION_NUMB,
                zagolovok.dSOLUTION_DATE,
                spec_qlty_chr.RN, -- nBALUNIT,
                spec_qlty_chr.name, -- sINV_OBJ,
                spec_qlty_chr.code, -- sACC_CODE,
                zagolovok.nagent, -- nAGENT,
                zagolovok.emppost, -- sAGENT_EMP,
                zagolovok.dINV_DATE,
                zagolovok.dBEGIN_DATE,
                zagolovok.dEND_DATE,
                null, -- nINS_DEP
                spec_qlty_chr.place, -- nINV_PLACE,
                null, -- sPLACE_NAME
                null, -- sNOTE
                4, -- nAPP_NUMB
                nRN_temp_sp); --nRN
            FIND_INVRESACTAP3_PRN( 1, nRN_temp_p, nRN_temp_ap3 );
            if
                nRN_temp_ap3 is null
            then
                P_INVRESACTAP3_BASE_INSERT( nCOMPANY, nRN_temp_p, nRN_temp_ap3 );
            end if;
            for spec_37 in (
                select
                    T2.NOMEN as nOBJECT,
                    cast(nvl(trim(T2.INVENTORY), '-') as varchar2(100)) as sINV_NUM,
                    D2.RN as nACCOUNT,
                    T2.ANALYTIC1 as nANALYTIC1,
                    T2.ANALYTIC2 as nANALYTIC2,
                    T2.ANALYTIC3 as nANALYTIC3,
                    T2.ANALYTIC4 as nANALYTIC4,
                    T2.ANALYTIC5 as nANALYTIC5,
                    T3.QUANT_NONCOND as nNOMATCH_QTY,
                    case when T3.QUANT_NONCOND != 0 then T3.AMOUNT else 0 end as nNOMATCH_SUM,
                    T3.QUANT_IMPAIR as nDEPREC_QTY,
                    case when T3.QUANT_IMPAIR != 0 then T3.AMOUNT else 0 end as nDEPREC_SUM,
                    T3.RESOLUTION as sCONCL_INVLS
                from
                    INVLSNFAOBJ T2
                join INVLSNFAOBJR T3 on T2.RN = T3.PRN
                left join DICACCS  D2 on T2.ACCOUNT = D2.RN
                left join BALELEMENT B on D2.BALUNIT = B.RN
                where zagolovok.nRN = T2.PRN
                    and D2.BALUNIT = spec_qlty_chr.RN
                    and (T3.QUANT_NONCOND != 0 or T3.QUANT_IMPAIR != 0))
            loop
                P_INVRESACTAP34_NEXTNUMB(nCOMPANY, nRN_temp_ap3, inv_nn);
                P_INVRESACTAP34_BASE_INSERT(
                    nCOMPANY,
                    nRN_temp_ap3, -- nPRN,
                    inv_nn, -- nNUMB,
                    nRN_temp_sp,
                    spec_37.nOBJECT,
                    spec_37.sINV_NUM, -- sNFA_NUMB,
                    spec_37.nACCOUNT,
                    spec_37.nANALYTIC1,
                    spec_37.nANALYTIC2,
                    spec_37.nANALYTIC3,
                    spec_37.nANALYTIC4,
                    spec_37.nANALYTIC5,
                    spec_37.nNOMATCH_QTY,
                    spec_37.nNOMATCH_SUM,
                    spec_37.nDEPREC_QTY,
                    spec_37.nDEPREC_SUM,
                    spec_37.sCONCL_INVLS,
                    null, -- sSOL_ACT
                    nRN_temp);
            end loop;
        end loop;
    end loop;
end;
