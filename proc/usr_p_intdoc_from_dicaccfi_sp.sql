create or replace procedure usr_p_intdoc_from_dicaccfi_sp (
   ncompany in number,    -- Организация
   nrn      in number
)    -- Идентификатор текущей записи
 as
   spec_nomen_code number(17);
   spec_amount     number(17);
   spec_real_sum   number(
      17,
      2
   );
   spec_currency   number(17);
   out_nrn         number(17);
   indoc_rn        number(17);
   ncreate_intdoc  int := usr_pkg_dicaccfi.ncreate_intdoc;
begin
							-- возьмем нужные поля из спецификации этого док-та
   select food_code,
          amount,
          sum_total,
          sp.currency,
          indoc_rn
     into
      spec_nomen_code,
      spec_amount,
      spec_real_sum,
      spec_currency,
      indoc_rn
     from diclacfi sp,
          dicaccfi doc
    where sp.rn = nrn
      and doc.rn = sp.prn;
							-- вставка спецификации внутреннего документа
   p_intdocs_sp_base_insert(
      indoc_rn,             -- nPRN
      ncompany,
      null,
      spec_nomen_code,
      null,                 -- sNOMEN_PARTNO
      null,                 -- dNOMEN_INDATE
      spec_currency,        -- nCURRENCY
      spec_amount,          -- nDOC_QUANT
      spec_amount,          -- nFACT_QUANT
      null,                 -- nACNT_CL_PR_ACC
      null,                 -- nACNT_ANALYTIC1
      null,                 -- nACNT_ANALYTIC2
      null,                 -- nACNT_ANALYTIC3
      null,                 -- nACNT_ANALYTIC4
      null,                 -- nACNT_ANALYTIC5
      null,                 -- nCTRL_CL_PR_ACC
      null,                 -- nCTRL_ANALYTIC1
      null,                 -- nCTRL_ANALYTIC2
      null,                 -- nCTRL_ANALYTIC3
      null,                 -- nCTRL_ANALYTIC4
      null,                 -- nCTRL_ANALYTIC5
      0,                    -- nACNT_PRICE
      0,                    -- nACNT_BASE_PRICE
      0,                    -- nCTRL_PRICE
      0,                    -- nCTRL_BASE_PRICE
      spec_real_sum,        -- nACNT_SUM
      spec_real_sum,        -- nACNT_BASE_SUM
      0,                    -- nCTRL_SUM
      0,                    -- nCTRL_BASE_SUM
      1,                    -- nAUTO_CALC_SIGN
      null,                 -- nEXPSTRUCT
      null,                 -- nINCOMECLASS
      null,                 -- nFINSOURCES
      null,                 -- nECONCLASS
      null,                 -- nACCOUNT_DEBIT
      null,                 -- nANALYTIC_DEBIT1
      null,                 -- nANALYTIC_DEBIT2
      null,                 -- nANALYTIC_DEBIT3
      null,                 -- nANALYTIC_DEBIT4
      null,                 -- nANALYTIC_DEBIT5
      null,                 -- nACCOUNT_CREDIT
      null,                 -- nANALYTIC_CREDIT1
      null,                 -- nANALYTIC_CREDIT2
      null,                 -- nANALYTIC_CREDIT3
      null,                 -- nANALYTIC_CREDIT4
      null,                 -- nANALYTIC_CREDIT5
      null,                 -- nTAX_GROUP -- налоговая группа
      0,                    -- nNOT_TAX_NDS -- признак "не облагать НДС"
      0,                    -- nNDS_DEDUCT -- НДС к вычету
      0,                    -- nNDS_COEFF -- коэффициент распределения НДС
      0,                    -- nACNT_PRICE_WOUT -- цена без НДС в валюте (бухгалтерская оценка)
      0,                    -- nACNT_BASE_PRICE_WOUT -- цена без НДС в базовой валюте (бухгалтерская оценка)
      0,                    -- nACNT_SUM_WOUT -- сумма без НДС в валюте (бухгалтерская оценка)
      0,                    -- nACNT_SUM_NDS -- сумма НДС в валюте (бухгалтерская оценка)
      0,                    -- nACNT_BASE_SUM_WOUT -- сумма без НДС в базовой валюте (бухгалтерская оценка)
      0,                    -- nACNT_BASE_SUM_NDS -- сумма НДС в базовой валюте (бухгалтерская оценка)
      0,                    -- nCTRL_PRICE_WOUT -- цена без НДС в валюте (управленческая оценка)
      0,                    -- nCTRL_BASE_PRICE_WOUT -- цена без НДС в базовой валюте (управленческая оценка)
      0,                    -- nCTRL_SUM_WOUT -- сумма без НДС в валюте (управленческая оценка)
      0,                    -- nCTRL_SUM_NDS -- сумма НДС в валюте (управленческая оценка)
      0,                    -- nCTRL_BASE_SUM_WOUT -- сумма без НДС в базовой валюте (управленческая оценка)
      0,                    -- nCTRL_BASE_SUM_NDS -- сумма НДС в базовой валюте (управленческая оценка)
      0,                    -- nWAY_CALC_SUM -- расчет суммы ( 0 - прямой, 1 - обратный )
      0,                    -- nACNT_DIRATE_NDS -- прямая ставка НДС
      0,                    -- nACNT_RSRATE_NDS -- обратная ставка НДС
      null,                 -- nBALUNIT -- ПБЕ
      null,                 -- sNOTE -- Примечание
      null,                 -- nNOMMODIF -- модификация номенклатуры
      null,                 -- nREVREAS -- Причина списания
      null,                 -- sRES_COMMS -- Решение комиссии
      null,                 -- sREVOKE_EVN -- Мероприятия по списанию
      null,                 -- sSERTIF_NUM -- Номер сертификата соответствия товара
      null,                 -- nDEV_QUANT -- Отклонение по количеству
      null,                 -- nDEV_FACT_QUANT -- Фактическое количество с отклонением по качеству
      null,                 -- nSUM_WOUT -- Сумма без НДС по документам в валюте
      null,                 -- nSUM_NDS -- Сумма НДС по документам в валюте
      null,                 -- nSUM_ALL -- Сумма всего по документам в валюте
      null,                 -- nDEV_ALL_QUANT -- Всего отклонений - Количество
      null,                 -- nDEV_ALL_SUM -- Всего отклонений - Сумма в валюте
      null,                 -- nDEV_ALL_SUM_E -- Всего отклонений - Сумма в эквиваленте
      null,                 -- nMISS_QUANT -- Недостача - Количество
      null,                 -- nMISS_SUM -- Недостача - Сумма в валюте
      null,                 -- nMISS_SUM_E -- Недостача - Сумма в эквиваленте
      null,                 -- nOVER_QUANT -- Излишки - Количество
      null,                 -- nOVER_SUM -- Излишки - Сумма в валюте
      null,                 -- nOVER_SUM_E -- Излишки - Сумма в эквиваленте
      null,                 -- nBRAK_QUANT -- Брак и бой - Количество
      null,                 -- nBRAK_SUM -- Брак и бой - Сумма в валюте
      null,                 -- nBRAK_SUM_E -- Брак и бой - Сумма в эквиваленте
      null,                 -- nCOUNTRY_DOC -- Страна происхождения товара (по документам)
      null,                 -- nCOUNTRY_FACT -- Страна происхождения товара (фактически)
      null,                 -- sREG_NUM -- Рег. № Декларации или Партии, не соответствующей заявленному
      null,                 -- sMISMATCH -- Несоответствие требованиям и характеристикам
      null,                 -- sOTHER -- Прочее
      out_nrn,
      0,                    --  Признак обновляния сумм в заголовке ( 1 - да, 0 - нет )
      null
   );                -- nDUP_RN
end;