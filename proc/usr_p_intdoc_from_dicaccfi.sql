create or replace procedure usr_p_intdoc_from_dicaccfi (
   ncompany in number,    -- Организация
   nrn      in number
)    -- Идентификатор текущей записи
 as
   ctlg_name      varchar2(100);
   ctlg_crn       number(17);
   intdoc_crn     number(17);
   ctlg_num       number(17);
   spec_exists    number(17);
   njur_pers      number(17);
   ddoc_date      date;
   sdoc_number    varchar2(10);
   contr_from     number(17);
   contr_to       number(17);
   conf_date      date;
   conf_type      number(17);
   conf_numb      varchar2(240);
   base_date      date;
   base_type      number(17);
   base_numb      varchar2(240);
   sum_total      number(
      17,
      2
   );
   jur_code       varchar2(20);
   out_nrn        number(17);
   ncreate_intdoc number(17) := usr_pkg_dicaccfi.ncreate_intdoc;
begin
   usr_pkg_dicaccfi.ncreate_intdoc := 1; -- является маневром для того, чтобы триггер не закинул новый док-т на каталог выше

							-- зная CRN записи, для которой мы выполняем действие, найдем наименование каталога, в котором
							-- содержится эта запись, для того чтобы найти RN и наименование каталога с таким же наименованием каталога,
							-- но в разделе внутренних документов
   select rn,
          name
     into
      ctlg_crn,
      ctlg_name
     from acatalog
    where name = (
         select name
           from acatalog
          where rn = (
            select crn
              from dicaccfi
             where rn = nrn
         )
      )
      and docname = 'InternalDocuments';
       -- узнаем есть ли подкаталог "Приход + Принадлежность" для каталога, который мы узнали выше
   begin
      select rn
        into ctlg_num
        from acatalog
       where name like 'Приход ' || ctlg_name
         and crn = ctlg_crn;
   exception
      when no_data_found then
         begin
            if ctlg_num is null
																			-- если каталога нет, то создадим новый
             then
               p_acatalog_insert(
                  ncompany,
                  ctlg_crn,
                  'Приход ' || ctlg_name,
                  ctlg_num
               );
            end if;
         exception
            when others then
               p_exception(
                  0,
                  'Возникла ошибка при создании нового каталога'
               );
         end;
   end;
       -- возьмем нужные поля из заголовка этого док-та
   select jur_pers,
          acc_date,
          pr_code,
          cs_code,
          conf_date,
          conf_type,
          conf_numb,
          base_date,
          base_type,
          base_numb,
          wcor_sum_total
     into
      njur_pers,
      ddoc_date,
      contr_from,
      contr_to,
      conf_date,
      conf_type,
      conf_numb,
      base_date,
      base_type,
      base_numb,
      sum_total
     from dicaccfi
    where rn = nrn;

							-- нужно узнать как зовут юр.лицо
   select code
     into jur_code
     from jurpersons
    where rn = njur_pers;
							-- следующий № документа
   p_intdocs_getnextnumb(
      ncompany,
      jur_code,
      ddoc_date,
      'ф. 0510452',
      null,
      sdoc_number
   );
       -- вставка заголовка
   p_intdocs_base_insert(
      ncompany,
      ctlg_num,
      njur_pers,
      1323962938,       -- DOC_TYPE
      null,             -- DOC_PREFIX
      sdoc_number,
      ddoc_date,
      base_type,        -- nVALID_DOCTYPE
      base_numb,        -- sVALID_DOCNUMB
      base_date,        -- dVALID_DOCDATE
      contr_from,
      contr_to,
      null,             -- nAGENT_THROUGH
      null,             -- nSTORE_FROM
      null,             -- nSTORE_TO
      null,             -- nSTORE_THROUGH
      null,             -- nBALUNIT
      null,             -- nSPECIAL_MARK
      0,                -- nDOC_KIND
      null,             -- nEXPSTRUCT
      null,             -- nINCOMECLASS
      null,             -- nFINSOURCES
      null,             -- nECONCLASS
      conf_type,        -- документ-подтверждение как входящий документ
      conf_numb,
      conf_date,
      null,
      null,
      null,             -- nCOMMS_DOCTYPE    -- Приказ о создании комиссии, Тип
      null,             -- sCOMMS_DOCNUMB    -- Приказ о создании комиссии, Номер
      null,             -- dCOMMS_DOCDATE    -- Приказ о создании комиссии, Дата
      null,             -- nNEED_UTIL        -- Необходимость уничтожения (утилизации)
      null,             -- sPLACE            -- Место поставки товара
      null,             -- nCUSTOMER_REQ     -- Реквизиты заказчика
      null,             -- nPROVIDER_REQ     -- Реквизиты поставщика
      null,             -- nSENDER           -- Грузоотправитель
      null,             -- nSENDER_REQ       -- Реквизиты грузоотправителя
      null,             -- nINSURED          -- Страхователь
      null,             -- nINSURED_REQ      -- Реквизиты страхователя
      null,             -- dPERIOD_BEG       -- Начало отчётного периода
      null,             -- dPERIOD_END       -- Конец отчётного периода
      null,             -- sBUILDING         -- Стройка
      null,             -- sOBJECT_NAME      -- Объект
      null,             -- sOBJECT_CODE      -- Уникальный код объекта капитального строительства
      0,                -- nSUM_ALL          -- Стоимость работ всего
      0,                -- nSUM_YEAR         -- Стоимость работ с начала года
      0,                -- nSUM_PERIOD       -- Стоимость работ за отчётный период
      0,                -- nSUM_NDS_ALL      -- Стоимость работ всего, НДС
      0,                -- nSUM_NDS_YEAR     -- Стоимость работ с начала года, НДС
      0,                -- nSUM_NDS_PERIOD   -- Стоимость работ за отчётный период, НДС
      0,                -- nSUM_TOTAL_ALL     -- Стоимость работ всего, с НДС
      0,                -- nSUM_TOTAL_YEAR   -- Стоимость работ с начала года, с НДС
      0,                -- nSUM_TOTAL_PERIOD -- Стоимость работ за отчётный период, с НДС
      out_nrn,
      sum_total,        -- сумма (бухгалтерская оценка)
      0,                -- сумма (управленческая оценка)
      0,                -- сумма без НДС (бухгалтерская оценка)
      0,                -- сумма НДС (бухгалтерская оценка)
      0,                -- сумма без НДС (управленческая оценка)
      0
   );               -- сумма НДС (управленческая оценка)

							-- передача РНа дальше
   update dicaccfi
      set
      indoc_rn = out_nrn
    where rn = nrn;

   usr_pkg_dicaccfi.ncreate_intdoc := 0;
end;