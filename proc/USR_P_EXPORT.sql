create or replace procedure USR_P_EXPORTREWARDTXT (
    nCOMPANY       in number,
    nIDENT         in number)
as
    temp_text       clob;
    header          varchar2(50);
    sFILENAME       varchar2(100);
    v_error_msg     varchar2(100);
    v_error_stack   varchar2(200);
    nRN             int;
begin
    nRN := gen_id;
    header := 'Контрагент;Название награды;Дата награждения;' || cr;
    sFILENAME := 'RWRD_' || to_char(current_date, 'DD.MM.YYYY') || '.txt';
    dbms_lob.createtemporary(temp_text, True);
    
    for i in (
      select
          (agn.agnabbr || ';' || rt.code || ';' || to_char(agnr.award_date,'DD.MM.YYYY') || ';' || cr) as row_
      from AGNLIST agn
      join AGNRWRD agnr on agnr.PRN = agn.RN
      join PRREWTYPE rt on agnr.PRREWTYPE = rt.RN
      join SELECTLIST sl on nIDENT = sl.IDENT
           and sl.document = agn.RN
      group by (agn.agnabbr || ';' || rt.code || ';' || to_char(agnr.award_date,'DD.MM.YYYY')))
    loop
    dbms_lob.writeappend(temp_text, length(i.row_), i.row_);
    end loop;
    p_file_buffer_insert(nIDENT, sFILENAME, header || temp_text, null);
exception
  when others then
    v_error_msg := SQLERRM;
    v_error_stack := dbms_utility.format_error_backtrace;
    P_MSGJOURNAL_INSERT(nCOMPANY, nIDENT, 1, 'Ошибка: ' || v_error_msg || ' Стек: ' || v_error_stack, nRN);
end;
