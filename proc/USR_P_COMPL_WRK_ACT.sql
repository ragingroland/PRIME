create or replace procedure usr_p_compl_wrk_act (
        ncompany in number,
        -- организация
        nident in number,
        -- помеченные записи
        ddate in date,
        -- дата
        sutver in varchar2,
        -- утверждаю
        sjurpers in varchar2,
        -- учреждение
        ssubdiv in varchar2,
        -- стр.подразделение
        smol in varchar2,
        -- МОЛ
        scomiss in varchar2,
        -- комиссия
        sconclusion in varchar2
    ) -- заключение комиссии
    as -- лист
    sheet constant pkg_std.tstring := 'SHEET';
-- заголовок
utver_post constant pkg_std.tstring := 'UTVER_POST';
utver_fio constant pkg_std.tstring := 'UTVER_FIO';
utver_day constant pkg_std.tstring := 'UTVER_DAY';
utver_month constant pkg_std.tstring := 'UTVER_MONTH';
utver_year constant pkg_std.tstring := 'UTVER_YEAR';
jurpers constant pkg_std.tstring := 'JURPERS';
subdiv constant pkg_std.tstring := 'SUBDIV';
mol constant pkg_std.tstring := 'MOL';
comiss constant pkg_std.tstring := 'COMISS';
-- таблица
line constant pkg_std.tstring := 'LINE';
npp constant pkg_std.tstring := 'npp';
work_kind constant pkg_std.tstring := 'work_kind';
work_place constant pkg_std.tstring := 'work_place';
work_measure constant pkg_std.tstring := 'work_measure';
work_amount constant pkg_std.tstring := 'work_amount';
mat_spent_name constant pkg_std.tstring := 'mat_spent_name';
mat_spent_measure constant pkg_std.tstring := 'mat_spent_measure';
mat_spent_norm constant pkg_std.tstring := 'mat_spent_norm';
mat_spent_to_work_amount constant pkg_std.tstring := 'mat_spent_to_work_amount';
cost_on_mat_measure constant pkg_std.tstring := 'cost_on_mat_measure';
cost_on_mat_to_work_amount constant pkg_std.tstring := 'cost_on_mat_to_work_amount';
summ constant pkg_std.tstring := 'SUMM';
-- комиссия
conclusion constant pkg_std.tstring := 'CONCLUSION';
presid_post constant pkg_std.tstring := 'presid_post';
presid_fio constant pkg_std.tstring := 'presid_fio';
com_str constant pkg_std.tstring := 'com_str';
com_mem_post constant pkg_std.tstring := 'com_mem_post';
com_mem_fio constant pkg_std.tstring := 'com_mem_fio';
nsumm number(17, 2) := 0;
line_idx int;
npp_counter int := 1;
begin
/* Инициализация */
prsg_excel.prepare;
/* установка рабочего листа */
prsg_excel.sheet_select(sheet);
-- заголовок
prsg_excel.cell_describe(utver_post);
prsg_excel.cell_describe(utver_fio);
prsg_excel.cell_describe(utver_day);
prsg_excel.cell_describe(utver_month);
prsg_excel.cell_describe(utver_year);
prsg_excel.cell_describe(jurpers);
prsg_excel.cell_describe(subdiv);
prsg_excel.cell_describe(mol);
prsg_excel.cell_describe(comiss);
-- Таблица
prsg_excel.line_describe(line);
prsg_excel.line_cell_describe(line, npp);
prsg_excel.line_cell_describe(line, work_kind);
prsg_excel.line_cell_describe(line, work_place);
prsg_excel.line_cell_describe(line, work_measure);
prsg_excel.line_cell_describe(line, work_amount);
prsg_excel.line_cell_describe(line, mat_spent_name);
prsg_excel.line_cell_describe(line, mat_spent_measure);
prsg_excel.line_cell_describe(line, mat_spent_norm);
prsg_excel.line_cell_describe(
    line,
    mat_spent_to_work_amount
);
prsg_excel.line_cell_describe(
    line,
    cost_on_mat_measure
);
prsg_excel.line_cell_describe(
    line,
    cost_on_mat_to_work_amount
);
prsg_excel.cell_describe(summ);
-- комиссия
prsg_excel.cell_describe(conclusion);
prsg_excel.cell_describe(presid_post);
prsg_excel.cell_describe(presid_fio);
prsg_excel.line_describe(com_str);
prsg_excel.line_cell_describe(com_str, com_mem_post);
prsg_excel.line_cell_describe(com_str, com_mem_fio);
-- утверждаю
for utv in (
    select case
            when (a.agnfamilyname is not null) then ltrim(
                case
                    when(a.agnfirstname is not null) then substr(
                        a.agnfirstname,
                        1,
                        1
                    ) || '.'
                    else ''
                end || case
                    when(a.agnlastname is not null) then substr(
                        a.agnlastname,
                        1,
                        1
                    ) || '.'
                    else ''
                end || ' ' || a.agnfamilyname
            )
            else a.agnabbr
        end as agent_fio,
        a.emppost
    from agnlist a
    where a.agnabbr = sutver
) loop prsg_excel.cell_value_write(
    utver_post,
    utv.emppost
);
prsg_excel.cell_value_write(
    utver_fio,
    utv.agent_fio
);
prsg_excel.cell_value_write(
    utver_day,
    extract(
        day
        from ddate
    )
);
prsg_excel.cell_value_write(
    utver_month,
    f_get_month(
        extract(
            month
            from ddate
        ),
        1
    )
);
prsg_excel.cell_value_write(
    utver_year,
    extract(
        year
        from ddate
    ) || ' г.'
);
end loop;
-- шапка
prsg_excel.cell_value_write(jurpers, sjurpers);
prsg_excel.cell_value_write(subdiv, ssubdiv);
prsg_excel.cell_value_write(mol, smol);
-- в составе комиссии
for com_info in (
    with t1 as (
        select case
                when (a.agnfamilyname is not null) then ltrim(
                    case
                        when(a.agnfirstname is not null) then substr(
                            a.agnfirstname,
                            1,
                            1
                        ) || '.'
                        else ''
                    end || case
                        when(a.agnlastname is not null) then substr(
                            a.agnlastname,
                            1,
                            1
                        ) || '.'
                        else ''
                    end || ' ' || a.agnfamilyname
                )
                else a.agnabbr
            end as agnabbr,
            sp.emppost,
            sp.president,
            s.order_numb,
            s.order_date
        from stancomm s,
            stancommsp sp,
            agnlist a
        where s.name = scomiss
            and s.rn = sp.prn
            and sp.agent = a.rn
        order by sp.president desc,
            sp.member_number
    )
    select 'Председатель комиссии - ' || max(
            case
                when president = 1 then emppost || ' ' || agnabbr
                else ' '
            end
        ) || '; Члены комиссии - ' || listagg(
            case
                when president = 0 then emppost || ' ' || agnabbr
                else ' '
            end,
            ', '
        ) within group(
            order by emppost
        ) || 'назначенной приказом №' || max(
            order_numb || ' от ' || extract(
                day
                from order_date
            ) || ' ' || f_get_month(
                extract(
                    month
                    from order_date
                ),
                1
            ) || ' ' || extract(
                year
                from order_date
            ) || ' г.'
        ) as text
    from t1
) loop prsg_excel.cell_value_write(
    comiss,
    com_info.text
);
end loop;
-- таблица
for spec in (
    select dn.nomen_name,
        dm.meas_mnemo,
        ts.quant,
        round(
            ts.price,
            2
        ) as price,
        round(
            ts.summwithnds,
            2
        ) as summ
    from selectlist sl
        join transinvdeptspecs ts on sl.document = ts.prn
        and ident = nident
        join nommodif nmd on ts.nommodif = nmd.rn
        join dicnomns dn on nmd.prn = dn.rn
        join dicmunts dm on dn.umeas_main = dm.rn
) loop if (line_idx is null) then line_idx := prsg_excel.line_append(line);
else line_idx := prsg_excel.line_continue(line);
end if;
prsg_excel.cell_value_write(
    npp,
    0,
    line_idx,
    npp_counter
);
prsg_excel.cell_value_write(
    mat_spent_name,
    0,
    line_idx,
    spec.nomen_name
);
prsg_excel.cell_value_write(
    mat_spent_measure,
    0,
    line_idx,
    spec.meas_mnemo
);
prsg_excel.cell_value_write(
    mat_spent_to_work_amount,
    0,
    line_idx,
    spec.quant
);
prsg_excel.cell_value_write(
    cost_on_mat_measure,
    0,
    line_idx,
    spec.price
);
prsg_excel.cell_value_write(
    cost_on_mat_to_work_amount,
    0,
    line_idx,
    spec.summ
);
npp_counter := npp_counter + 1;
nsumm := nsumm + spec.summ;
end loop;
-- ИТОГО
prsg_excel.cell_value_write(summ, nsumm);
/* комиссия */
line_idx := null;
for rvot in (
    select case
            when (a.agnfamilyname is not null) then ltrim(
                case
                    when(a.agnfirstname is not null) then substr(
                        a.agnfirstname,
                        1,
                        1
                    ) || '.'
                    else ''
                end || case
                    when(a.agnlastname is not null) then substr(
                        a.agnlastname,
                        1,
                        1
                    ) || '.'
                    else ''
                end || ' ' || a.agnfamilyname
            )
            else a.agnabbr
        end as agnabbr,
        sp.emppost,
        sp.president
    from stancomm s,
        stancommsp sp,
        agnlist a
    where s.name = scomiss
        and s.rn = sp.prn
        and sp.agent = a.rn
    order by sp.president desc,
        sp.member_number
) loop if rvot.president = 1 then prsg_excel.cell_value_write(
    presid_post,
    rvot.emppost
);
prsg_excel.cell_value_write(
    presid_fio,
    rvot.agnabbr
);
else if (line_idx is null) then line_idx := prsg_excel.line_append(com_str);
else line_idx := prsg_excel.line_continue(com_str);
end if;
prsg_excel.cell_value_write(
    com_mem_post,
    0,
    line_idx,
    rvot.emppost
);
prsg_excel.cell_value_write(
    com_mem_fio,
    0,
    line_idx,
    rvot.agnabbr
);
end if;
end loop;
-- заключение комиссии
prsg_excel.cell_value_write(conclusion, sconclusion);
-- удаление экземпляров строк
prsg_excel.line_delete(line);
prsg_excel.line_delete(com_str);
end;
