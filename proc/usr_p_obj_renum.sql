create or replace procedure usr_p_obj_renum (
   nident   in number,
   ncompany in number
) as
   nprn int;
begin
   select min(prn)
     into nprn
     from invlsnfaobj
    where rn in (
      select sl.document
        from selectlist sl
       where nident = sl.ident
   );

   for rows in (
      select i.rn,
             row_number()
             over(
                 order by nm.nomen_code,
                          i.nomen,
                          i.rn
             ) as str_code
        from invlsnfaobj i,
             dicnomns nm
       where i.company = ncompany
         and i.nomen = nm.rn
         and i.prn = nprn
   ) loop
      update invlsnfaobj
         set
         str_code = str_code + 1000
       where rn = rows.rn;
   end loop;
   for rows in (
      select i.rn,
             row_number()
             over(
                 order by nm.nomen_code,
                          i.nomen,
                          i.rn
             ) as str_code
        from invlsnfaobj i,
             dicnomns nm
       where i.company = ncompany
         and i.nomen = nm.rn
         and i.prn = nprn
   ) loop
      update invlsnfaobj
         set
         str_code = rows.str_code
       where rn = rows.rn;
   end loop;
end;