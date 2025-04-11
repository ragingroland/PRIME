create or replace procedure usr_p_obj_fill_res (
    nident   in number,
    ncompany in number)
as
    gentd_rn int;
begin
    for rows in (
        select i.amount,
            i.quant_fact,
            i.rn
        from invlsnfaobj i,
            selectlist sl
        where i.company = ncompany
            and sl.document = i.rn
            and ident = nident)
    loop
        p_invlsnfaobjr_base_insert(
            ncompany,
            rows.rn,
            null,
            null,
            null,
            0,
            0,
            rows.quant_fact,
            0,
            rows.amount,
            null,
            null,
            null,
            null,
            0,
            null,
            gentd_rn);
    end loop;
end;