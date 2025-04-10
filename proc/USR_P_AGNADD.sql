create or replace procedure USR_P_AGNADDSKILL (
       nCOMPANY          in number,
       nIDENT            in number,          -- выбранный контрагент
       sPRATNTYP         in varchar2,        -- знание/навык
       sPRAYNGRD         in varchar2)        -- степень владения
as
       nPRATNTYP         PKG_STD.tREF;
       nPRAYNGRD         PKG_STD.tREF;
       nRN               PKG_STD.tREF;
       nPRN              PKG_STD.tREF;
begin
  FIND_PRATNTYP_CODE(1, 0, nCOMPANY, sPRATNTYP, nPRATNTYP);
  if nPRATNTYP is null then
     nPRATNTYP := gen_id;
  end if;  
  FIND_PRAYNGRD_CODE(0, 0, nCOMPANY, sPRAYNGRD, nPRAYNGRD);

       for skill in (
           select
               t.rn
           from AGNLIST t, SELECTLIST sl
           where t.rn = sl.document
               and sl.ident = nIDENT)
       loop
           P_AGNATNMS_BASE_INSERT( nCOMPANY, nPRN, nPRATNTYP, nPRAYNGRD, nRN );
       end loop;
end;
