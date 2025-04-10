create or replace procedure USR_P_VACREP_FIOINS (
       sATTRIB  in varchar2,     -- идентификатор изм.атрибута
       sEXEC    in number,       -- рег.номер исполнителя
       NCOMPANY in number,       -- организация
       sFIO     in out varchar2) -- ФИО сотрудника(исполнителя), которое вставится по событию
as
begin
       if sATTRIB='SEXEC'
           then
               if sEXEC is not null then
                  begin
                      select
                          AGNABBR into sFIO
                      from clnpspfm spfm
                      join (select agn.AGNABBR, cp.RN
                            from clnpersons cp
                            join agnlist agn on cp.PERS_AGENT = agn.RN) fio on spfm.PERSRN = fio.RN
                      where spfm.RN = sEXEC;
                  exception
                      when others then
                          p_exception(0, 'ФИО ответственного исполнителя с таким рег.номером не найдено');
                  end;
               else
                   sFIO := null;
               end if;
       end if;
end;
