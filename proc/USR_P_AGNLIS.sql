create or replace procedure USR_P_AGNLIST_ADDRESS (nIDENT in number)
as
  SHEET_NAME varchar2(17) := 'КонтрагентыАдреса';
  CELL_NPP constant PKG_STD.tSTRING := 'НомерПоПорядку';
  CELL_FIO constant PKG_STD.tSTRING := 'ФИО';
  CELL_REG_ADDRESS constant PKG_STD.tSTRING := 'АдресРегистрации';
  CELL_RES_ADDRESS constant PKG_STD.tSTRING := 'АдресФактический';
  CELL_REL_Mthr constant PKG_STD.tSTRING := 'Мать';
  CELL_REL_Fthr constant PKG_STD.tSTRING := 'Отец';
  LINE1 constant PKG_STD.tSTRING := 'ДанныеКонтрагента';
  iLINE integer;
begin
  PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(SHEET_NAME);
  
  PRSG_EXCEL.LINE_DESCRIBE(LINE1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_NPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_FIO);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_REG_ADDRESS);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_RES_ADDRESS);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_REL_Mthr);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LINE1,CELL_REL_Fthr);
  
  for rec in (
      select
          t.agnfamilyname,
          t.agnfirstname,
          (select f.FULLNAME
           from AGNADDRESSES d, GEOGRAFY f
           where d.geografy_rn = f.rn
             and d.prn = t.rn
             and d.legal_sign = 1
             and rownum = 1) as legal_sign,
          (select f.FULLNAME
           from AGNADDRESSES d, GEOGRAFY f
           where d.geografy_rn = f.rn
             and d.prn = t.rn
             and d.real_sign = 1
             and rownum = 1) as real_sign,
          (select r.relat_name || ' ' || r.relat_sirname || ' ' || r.oldrel_sirname as fullname
           from AGNRELATIVE r, PRRELDEG pr
           where r.prn = t.rn
             and r.prreldeg = pr.rn
             and pr.Code = 'Мать'
             and rownum = 1) as mthr,
          (select r.relat_name || ' ' || r.relat_sirname || ' ' || r.oldrel_sirname as fullname
           from AGNRELATIVE r, PRRELDEG pr
           where r.prn = t.rn
             and r.prreldeg = pr.rn
             and pr.Code = 'Отец'
             and rownum = 1) as fthr
      from AGNLIST t, SELECTLIST sl
      where t.agntype = 1
            and t.rn = sl.document
            and sl.ident = nIDENT) loop
    iLINE := PRSG_EXCEL.LINE_APPEND(LINE1);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_NPP, 0, iLINE, iLINE);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_FIO, 0, iLINE, rec.agnfamilyname ||' '|| rec.agnfirstname);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_REG_ADDRESS, 0, iLINE, rec.legal_sign);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_RES_ADDRESS, 0, iLINE, rec.real_sign);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_REL_Mthr, 0, iLINE, rec.mthr);
    PRSG_EXCEL.CELL_VALUE_WRITE(CELL_REL_Fthr, 0, iLINE, rec.fthr);
  end loop;
  
  PRSG_EXCEL.LINE_DELETE(LINE1);
  
end;
