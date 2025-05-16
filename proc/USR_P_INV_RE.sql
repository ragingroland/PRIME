create or replace procedure usr_p_inv_results (
   ncompany  in number,       -- Организация
   nident    in number,       -- Помеченная запись
   sdoc_type in varchar2,     -- Тип документа (мнемокод)
   ddate     in date
)         -- Дата
 as
   nrn_temp_p   int; -- Родитель
   nrn_temp     int; -- Для выходных РНов
   nrn_temp_sp  int; -- Для спецификаций
   nrn_temp_ap2 int; -- Родитель для разд. 2
   nrn_temp_ap3 int; -- Родитель для разд. 3
   inv_nn       int; -- Для порядковых номеров
   ndoctype     pkg_std.tref;
   sdocname     varchar2(40) := '0510463';
   ndoc_num     int;  -- Для порядковых номеров док-тов
begin
   begin
      select dt.docname,
             dt.rn
        into
         sdocname,
         ndoctype
        from doctypes dt
       where dt.doccode = sdoc_type;
   exception
      when no_data_found then
         p_exception(
            0,
            'Не найден тип документа "'
            || sdoc_type
            || '"'
         );
   end;
   for zagolovok in (
      select t.rn as nrn,
             t.company as ncompany,
             (
                select ac.rn
                  from acatalog ac,
                       acatalog ac2
                 where ac.docname = 'InventoryResultsActs'
                   and ac.name = ac2.name
                   and ac2.rn = t.crn
             ) as ncrn_new,
             t.jur_pers as njur_pers,
             d.rn as doc_type,
             t.doc_date as ddoc_date,
             nvl(
                trim(t.doc_numb),
                ''
             ) as sdoc_numb,
             t.inv_date as dinv_date,
             t.begin_date as dbegin_date,
             t.end_date as dend_date,
             t.agent as nagent,
             (
                select emppost
                  from agnlist agn
                 where agn.rn = t.agent
             ) emppost,
             t.solution_numb as ssolution_numb,
             t.solution_date as dsolution_date,
             case
                when t.commis_numb in ( 0,
                                        1,
                                        2,
                                        3,
                                        4,
                                        5,
                                        6,
                                        7,
                                        8,
                                        9 ) then
                   cast(t.commis_numb as int)
                else
                   0
             end as ncommis_numb, -- процедура P_INVRESACT_BASE_INSERT принимает number в номер комиссии
             t.struct_subdiv as nstruct_subdiv
        from invlsnfa t
        join selectlist sl
      on ident = nident
         and sl.document = t.rn
        left join doctypes d
      on sdoc_type = d.doccode
   ) loop
      p_invresact_base_getnextnumb(
         ncompany,
         zagolovok.njur_pers,
         zagolovok.doc_type,
         null,
         ddate,
         ndoc_num
      );
      p_invresact_base_insert(
         zagolovok.ncompany,
         zagolovok.ncrn_new,
         zagolovok.njur_pers,
         zagolovok.doc_type,
         null, --docpref
         ndoc_num, --zagolovok.sDOC_NUMB,
         ddate,
         null, -- SEP_DEP
         zagolovok.nstruct_subdiv,
         zagolovok.ssolution_numb,
         zagolovok.dsolution_date,
         zagolovok.ncommis_numb,
         null, -- nDUP_RN
         nrn_temp_p
      );
      for spec_bu_ok in (
         select b.rn,
                b.code,
                b.name,
                min(t2.place_inv) place
           from invlsnfaobj t2
           join dicaccs d2
         on t2.account = d2.rn
           join balelement b
         on d2.balunit = b.rn
          where zagolovok.nrn = t2.prn
            and not exists (
            select null
              from invlsnfaobjr r
             where r.prn = t2.rn
         )
          group by b.rn,
                   b.code,
                   b.name
      ) loop
         p_invresactlnok_nextnumb(
            ncompany,
            nrn_temp_p,
            inv_nn
         );
         p_invresactlnok_base_insert(
            ncompany,
            nrn_temp_p,
            inv_nn, -- nNUMB,
            sdoc_type, -- sFORM_CODE,
            sdocname, -- sINVLS_NAME,
            ndoctype, -- DOC_TYPE,
            zagolovok.sdoc_numb, --  sSOLUTION_NUMB,
            ddate, -- dSOLUTION_DATE,
            spec_bu_ok.rn, -- nBALUNIT,
            spec_bu_ok.name, -- sINV_OBJ,
            spec_bu_ok.code, -- sACC_CODE,
            zagolovok.nagent, -- nAGENT,
            zagolovok.emppost, -- sAGENT_EMP,
            zagolovok.dinv_date,
            zagolovok.dbegin_date,
            zagolovok.dend_date,
            null, -- nINS_DEP
            spec_bu_ok.place, -- nINV_PLACE,
            null, -- sPLACE_NAME
            null, -- sNOTE
            nrn_temp
         );
      end loop;
      for spec_err in (
         select b.rn,
                b.code,
                b.name,
                min(t2.place_inv) place
           from invlsnfaobj t2
           join dicaccs d2
         on t2.account = d2.rn
           join balelement b
         on d2.balunit = b.rn
          where zagolovok.nrn = t2.prn
            and exists (
            select null
              from invlsnfaobjr r
             where r.prn = t2.rn
         )
          group by b.rn,
                   b.code,
                   b.name
      ) loop
         p_invresactlner_nextnumb(
            ncompany,
            nrn_temp_p,
            inv_nn
         );
         p_invresactlner_base_insert(
            ncompany,
            nrn_temp_p,
            inv_nn, -- nNUMB,
            sdoc_type, -- sFORM_CODE,
            sdocname, -- sINVLS_NAME,
            ndoctype, -- DOC_TYPE,
            zagolovok.sdoc_numb, -- sSOLUTION_NUMB,
            zagolovok.dsolution_date,
            spec_err.rn, -- nBALUNIT,
            spec_err.name, -- sINV_OBJ,
            spec_err.code, -- sACC_CODE,
            zagolovok.nagent, -- nAGENT,
            zagolovok.emppost, -- sAGENT_EMP,
            zagolovok.dinv_date,
            zagolovok.dbegin_date,
            zagolovok.dend_date,
            null, -- nINS_DEP
            spec_err.place, -- nINV_PLACE,
            null, -- sPLACE_NAME
            null, -- sNOTE
            7, -- nAPP_NUMB
            nrn_temp_sp
         );
         find_invresactap2_prn(
            1,
            nrn_temp_p,
            nrn_temp_ap2
         );
         if nrn_temp_ap2 is null then
            p_invresactap2_base_insert(
               ncompany,
               nrn_temp_p,
               nrn_temp_ap2
            );
         end if;
         for spec_24 in (
            select t2.nomen as nobject,
                   cast(nvl(
                      trim(t2.inventory),
                      '-'
                   ) as varchar2(100)) as sinv_num,
                   d2.rn as naccount,
                   t2.analytic1 as nanalytic1,
                   t2.analytic2 as nanalytic2,
                   t2.analytic3 as nanalytic3,
                   t2.analytic4 as nanalytic4,
                   t2.analytic5 as nanalytic5,
                   t3.quant_miss as nshort_qty,
                   case
                      when t3.quant_miss != 0 then
                         t3.amount
                      else
                         0
                   end as nshort_sum,
                   t3.quant_over as nsurpl_qty,
                   case
                      when t3.quant_over != 0 then
                         t3.amount
                      else
                         0
                   end as nsurpl_sum,
                   t3.resolution as sconcl_invls
              from invlsnfaobj t2
              join invlsnfaobjr t3
            on t2.rn = t3.prn
              left join dicaccs d2
            on t2.account = d2.rn
              left join balelement b
            on d2.balunit = b.rn
             where zagolovok.nrn = t2.prn
               and d2.balunit = spec_err.rn
               and ( t3.quant_miss != 0
                or t3.quant_over != 0 )
         ) loop
            p_invresactap27_nextnumb(
               ncompany,
               nrn_temp_ap2,
               inv_nn
            );
            p_invresactap27_base_insert(
               ncompany,
               nrn_temp_ap2, --nPRN,
               inv_nn, --nNUMB,
               nrn_temp_sp, -- nINVLST
               spec_24.nobject,
               spec_24.sinv_num, --sNFA_NUMB,
               spec_24.naccount,
               spec_24.nanalytic1,
               spec_24.nanalytic2,
               spec_24.nanalytic3,
               spec_24.nanalytic4,
               spec_24.nanalytic5,
               spec_24.nshort_qty,
               spec_24.nshort_sum,
               spec_24.nsurpl_qty,
               spec_24.nsurpl_sum,
               spec_24.sconcl_invls,
               null, --sSOL_ACT,
               nrn_temp
            );
         end loop;
      end loop;
      for spec_qlty_chr in (
         select b.rn,
                b.code,
                b.name,
                min(t2.place_inv) place
           from invlsnfaobj t2
           join dicaccs d2
         on t2.account = d2.rn
           join balelement b
         on d2.balunit = b.rn
          where zagolovok.nrn = t2.prn
            and exists (
            select null
              from invlsnfaobjr r
             where r.prn = t2.rn
         )
          group by b.rn,
                   b.code,
                   b.name
      ) loop
         p_invresactquch_nextnumb(
            ncompany,
            nrn_temp_p,
            inv_nn
         );
         p_invresactquch_base_insert(
            ncompany,
            nrn_temp_p,
            inv_nn, -- nNUMB,
            sdoc_type, -- sFORM_CODE,
            sdocname, -- sINVLS_NAME,
            ndoctype, -- DOC_TYPE,
            zagolovok.sdoc_numb, -- sSOLUTION_NUMB,
            zagolovok.dsolution_date,
            spec_qlty_chr.rn, -- nBALUNIT,
            spec_qlty_chr.name, -- sINV_OBJ,
            spec_qlty_chr.code, -- sACC_CODE,
            zagolovok.nagent, -- nAGENT,
            zagolovok.emppost, -- sAGENT_EMP,
            zagolovok.dinv_date,
            zagolovok.dbegin_date,
            zagolovok.dend_date,
            null, -- nINS_DEP
            spec_qlty_chr.place, -- nINV_PLACE,
            null, -- sPLACE_NAME
            null, -- sNOTE
            4, -- nAPP_NUMB
            nrn_temp_sp
         ); --nRN
         find_invresactap3_prn(
            1,
            nrn_temp_p,
            nrn_temp_ap3
         );
         if nrn_temp_ap3 is null then
            p_invresactap3_base_insert(
               ncompany,
               nrn_temp_p,
               nrn_temp_ap3
            );
         end if;
         for spec_37 in (
            select t2.nomen as nobject,
                   cast(nvl(
                      trim(t2.inventory),
                      '-'
                   ) as varchar2(100)) as sinv_num,
                   d2.rn as naccount,
                   t2.analytic1 as nanalytic1,
                   t2.analytic2 as nanalytic2,
                   t2.analytic3 as nanalytic3,
                   t2.analytic4 as nanalytic4,
                   t2.analytic5 as nanalytic5,
                   t3.quant_noncond as nnomatch_qty,
                   case
                      when t3.quant_noncond != 0 then
                         t3.amount
                      else
                         0
                   end as nnomatch_sum,
                   t3.quant_impair as ndeprec_qty,
                   case
                      when t3.quant_impair != 0 then
                         t3.amount
                      else
                         0
                   end as ndeprec_sum,
                   t3.resolution as sconcl_invls
              from invlsnfaobj t2
              join invlsnfaobjr t3
            on t2.rn = t3.prn
              left join dicaccs d2
            on t2.account = d2.rn
              left join balelement b
            on d2.balunit = b.rn
             where zagolovok.nrn = t2.prn
               and d2.balunit = spec_qlty_chr.rn
               and ( t3.quant_noncond != 0
                or t3.quant_impair != 0 )
         ) loop
            p_invresactap34_nextnumb(
               ncompany,
               nrn_temp_ap3,
               inv_nn
            );
            p_invresactap34_base_insert(
               ncompany,
               nrn_temp_ap3, -- nPRN,
               inv_nn, -- nNUMB,
               nrn_temp_sp,
               spec_37.nobject,
               spec_37.sinv_num, -- sNFA_NUMB,
               spec_37.naccount,
               spec_37.nanalytic1,
               spec_37.nanalytic2,
               spec_37.nanalytic3,
               spec_37.nanalytic4,
               spec_37.nanalytic5,
               spec_37.nnomatch_qty,
               spec_37.nnomatch_sum,
               spec_37.ndeprec_qty,
               spec_37.ndeprec_sum,
               spec_37.sconcl_invls,
               null, -- sSOL_ACT
               nrn_temp
            );
         end loop;
      end loop;
   end loop;
end;