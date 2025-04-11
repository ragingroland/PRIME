create or replace procedure usr_p_nfa_strdiv_numb (
   nident   in number,
   ncompany in number,
   sdocnumb in varchar2,
   sstrdiv  in varchar2
) as
   nstrdiv int;
begin
   for main in (
      select t.rn
        from invlsnfa t
        join selectlist sl
      on t.rn = sl.document
         and nident = sl.ident
   ) loop
      if sdocnumb is not null then
         update invlsnfa t
            set
            t.doc_numb = sdocnumb
          where t.rn = main.rn;
      end if;
      if sstrdiv is not null then
         find_subdivs_code(
            0,
            ncompany,
            sstrdiv,
            nstrdiv
         );
         update invlsnfa t
            set
            t.struct_subdiv = nstrdiv
          where t.rn = main.rn;
      end if;
   end loop;
end;