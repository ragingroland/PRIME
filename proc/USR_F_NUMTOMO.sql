create or replace function USR_F_NUMTOMONTH(
    month_num in number
) return varchar2 is
begin
    case month_num
        when 1 then return 'январь';
        when 2 then return 'февраль';
        when 3 then return 'март';
        when 4 then return 'апрель';
        when 5 then return 'май';
        when 6 then return 'июнь';
        when 7 then return 'июль';
        when 8 then return 'август';
        when 9 then return 'сентябрь';
        when 10 then return 'октябрь';
        when 11 then return 'ноябрь';
        when 12 then return 'декабрь';
        else return 'Месяц не распознан';
    end case;
exception
    when others then
        return 'Месяц не распознан';
end;
