create or replace procedure USR_P_VACREP (
       nIDENT     in number,
       nCOMPANY   in number,
       sEXEC      in number,
       dDATE_FROM in date,
       dDATE_TO   in date,
       sFIO in varchar2)
as
       SHEET_NAME             varchar2(3) := 'АХО';
       CELL_TOP_FIO           constant PKG_STD.tSTRING := 'top_fio';
       CELL_TOP_POSITION      constant PKG_STD.tSTRING := 'top_position';
       CELL_DEPT              constant PKG_STD.tSTRING := 'dept';
       CELL_VAC_FIO           constant PKG_STD.tSTRING := 'vac_fio';
       CELL_VAC_DATE          constant PKG_STD.tSTRING := 'vac_date';
       CELL_VAC_DAYS          constant PKG_STD.tSTRING := 'vac_days';
       CELL_VAC_SIGN_DATE     constant PKG_STD.tSTRING := 'vac_sign_date';
       CELL_VAC_NOTES         constant PKG_STD.tSTRING := 'vac_notes';
       CELL_BOTTOM_POSITION   constant PKG_STD.tSTRING := 'bottom_position';
       CELL_SIGN              constant PKG_STD.tSTRING := 'sign';
       CELL_BOTTOM_FIO        constant PKG_STD.tSTRING := 'bottom_fio';
       LINE1                  constant PKG_STD.tSTRING := 'vac_row';
       iLINE                  integer;
begin
       PRSG_EXCEL.PREPARE;
       PRSG_EXCEL.SHEET_SELECT(SHEET_NAME);
       
       PRSG_EXCEL.CELL_DESCRIBE(CELL_TOP_FIO);
       PRSG_EXCEL.CELL_DESCRIBE(CELL_TOP_POSITION);
       PRSG_EXCEL.CELL_DESCRIBE(CELL_DEPT);
       PRSG_EXCEL.CELL_DESCRIBE(CELL_BOTTOM_POSITION);
       PRSG_EXCEL.CELL_DESCRIBE(CELL_SIGN);
       PRSG_EXCEL.CELL_DESCRIBE(CELL_BOTTOM_FIO);

       PRSG_EXCEL.LINE_DESCRIBE(LINE1);
       PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_VAC_FIO);
       PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_VAC_DATE);
       PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_VAC_DAYS);
       PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_VAC_SIGN_DATE);
       PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_VAC_NOTES);
       
       for row in (select
                       AGNABBR as fio,
                       coalesce(cpd.CODE, cpst.CODE) as position,
                       idp.NAME as dept
                   from clnpspfm spfm
                   join (select agn.AGNABBR, cp.RN
                         from clnpersons cp
                         join agnlist agn on cp.PERS_AGENT = agn.RN) fio on spfm.PERSRN = fio.RN
                   left join clnpsdep cpd on cpd.RN = spfm.PSDEPRN
                   left join clnposts cpst on cpst.RN = spfm.POSTRN
                   join ins_department idp on spfm.DEPTRN = idp.RN
                   where spfm.RN = sEXEC)
       loop
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_TOP_FIO, row.fio);
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_TOP_POSITION, row.position);
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_DEPT, row.dept);
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_BOTTOM_POSITION, row.position);
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_SIGN, '');
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_BOTTOM_FIO, row.fio);
       end loop;

       for row in (select
                       agn.AGNABBR as fio,
                       vs.PERIOD_BEGIN as vac_start,
                       pvs.MAJOR_DAYS + pvs.MINOR_DAYS as vac_days_sum
                   from PRVACSHD vs
                   join PRVACSHDSP pvs on pvs.PRN = vs.RN
                   join AGNLIST agn on pvs.AGENT = agn.RN
                   join SELECTLIST l on IDENT = nIDENT and vs.RN = l.document
                   where pvs.BEGIN_DATE between dDATE_FROM and dDATE_TO
                   order by pvs.BEGIN_DATE)
       loop
                   iLINE := PRSG_EXCEL.LINE_APPEND(LINE1);
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_VAC_FIO, 0, iLINE, row.fio);
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_VAC_DATE, 0, iLINE, row.vac_start);
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_VAC_DAYS, 0, iLINE, row.vac_days_sum);
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_VAC_SIGN_DATE, 0, iLINE, '');
                   PRSG_EXCEL.CELL_VALUE_WRITE(CELL_VAC_NOTES, 0, iLINE, '');
       end loop;

       PRSG_EXCEL.LINE_DELETE(LINE1);

end;
