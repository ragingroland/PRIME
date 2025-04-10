create or replace procedure USR_P_REWARDSFROMCSV (
       nCOMPANY       in number,         -- организация
       nIDENT         in number,         -- файлы для импорта
       nPRN           out number,
       nRN            out number)
as
       i             int;
       counter       int;
       data_lngt     int;
       cur_row       varchar2(4000);
       cur_row_start int;
       cur_row_end   int;
       sAGN          varchar2(20);
       sRWTYPE       varchar2(80);
       dDATE         date;
       nREWARD       int;
       sREWARD       varchar2(80);
       sPRREWTYPE    varchar2(80);
       nPRREWTYPE    int;
       v_error_msg   varchar(500);
       corrupted_data boolean;
begin
       for rec in (
           select DATA
           from FILE_BUFFER
           where IDENT = nIDENT)
       loop
         data_lngt := length(rec.data);
         cur_row_start := instr(rec.data, chr(10)) + 1;
         counter := 1;
         while cur_row_start <= data_lngt loop
           corrupted_data := False;
           cur_row_end := instr(substr(rec.data, cur_row_start), chr(10)) - 1;
           if cur_row_end = - 1
             then cur_row_end := data_lngt - cur_row_start + 1;
           end if;
           cur_row := substr(rec.data, cur_row_start, cur_row_end);
           begin
             sAGN := strtok(cur_row, ';', i);
             sRWTYPE := strtok(cur_row, ';', 2);
             dDATE := to_date(strtok(cur_row, ';', 3), 'DD.MM.YYYY');
           exception
             when others then
              corrupted_data := True;
              v_error_msg := 'Отсутствуют данные или неверный тип данных';
              P_MSGJOURNAL_INSERT(nCOMPANY, nIDENT, 1, 'Ошибка: ' || v_error_msg || ' в строке: ' || counter, nRN);
           end;
           begin
           FIND_AGNLIST_BY_MNEMO(0,nCOMPANY, sAGN, nPRN);
           exception
             when others then
              corrupted_data := True;
              v_error_msg := 'Такой контрагент не найден';
              P_MSGJOURNAL_INSERT(nCOMPANY, nIDENT, 1, 'Ошибка: ' || v_error_msg || ' в строке: ' || counter, nRN);
           end;
           begin
           find_prrewtype_code(0, 0, nCOMPANY, sRWTYPE, nPRREWTYPE);
           exception
             when others then
              corrupted_data := True;
              v_error_msg := 'Такой тип награды не найден';
              P_MSGJOURNAL_INSERT(nCOMPANY, nIDENT, 1, 'Ошибка: ' || v_error_msg || ' в строке: ' || counter, nRN);
           end;
           if corrupted_data = False
             then
               P_AGNRWRD_BASE_INSERT(nCOMPANY, nPRN, dDATE, null, '', '',
                 '', nREWARD, nPRREWTYPE, '', null, null, null, '', 0, nRN);
             else
               v_error_msg := 'Загружаемые данные повреждены и не были вставлены в таблицу';
               P_MSGJOURNAL_INSERT(nCOMPANY, nIDENT, 1, 'Ошибка: ' || v_error_msg || ' в строке: ' || counter, nRN);
           end if;
           nRN := null;
           nPRN := null;
           cur_row_start := cur_row_start + cur_row_end + 1;
           counter := counter + 1;
         end loop;
       end loop;
end;
