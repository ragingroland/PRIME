create or replace procedure usr_p_invlsnfaobj_setstatfunc (
   ncompany  in number,      -- ид. организации
   nident    in number,      -- отмеченные записи
   sobj_stat in varchar2,     -- статус объекта учета
   sobj_func in varchar2
)    -- целевая функция
 as
begin
   update invlsnfaobj
      set status = nvl(
      sobj_stat,
      status
   ), -- если какой-то из параметров не указан, то не меняем существующее значение
          target_func = nvl(
             sobj_func,
             target_func
          )
    where rn in (
      select document
        from selectlist
       where ident = nident
         and unitcode = 'InventoryListsNonFinAssetsObjects'
   );
end;