create or replace procedure USR_P_SET_NOMEN_PROPS (
		nCOMPANY in number,
		-- организация
		nIDENT in number,
		-- помеченные записи
		sMED_ACC_TYPE in varchar2,
		-- Вид учета медикаментов
		sPHARM_GROUP in varchar2,
		-- Фарм группа
		sSTORAGE in varchar2,
		-- Место хранения
		sACC_GROUP in varchar2,
		-- Группа учета
		sVITAL in varchar2,
		-- Жизненно важность
		sIMPORTED in varchar2,
		-- Импортное
		sATH_CODE in varchar2,
		-- Код АТХ
		sVKK in varchar2,
		-- ВКК
		sEXTEMP in varchar2,
		-- Экстемпоральные
		sVEN_CL in varchar2
	) -- Ven-классификация
	as nMED_ACC_TYPE number(17);
nPHARM_GROUP number(17);
nSTORAGE number(17);
nACC_GROUP number(17);
nVITAL number(17);
nIMPORTED number(17);
nATH_CODE number(17);
nVKK number(17);
nEXTEMP number(17);
nVEN_CL number(17);
nDOCUMENT number(17);
inout_rn number(17);
sUNITCODE varchar2(11) := 'Nomenclator';
begin -- поиск РН для свойств
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'ФармВидУчета', nMED_ACC_TYPE);
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'ФармГруппа', nPHARM_GROUP);
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'Место хранения', nSTORAGE);
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'ФармГруппаУчета', nACC_GROUP);
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'ФармЖизнВажное', nVITAL);
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'ФармИмпортное', nIMPORTED);
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'ФармКодАТХ', nATH_CODE);
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'ФармВКК', nVKK);
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'ФармЭкстемпоральные', nEXTEMP);
FIND_DOCS_PROPS_CODE(0, nCOMPANY, 'Ven-классификация', nVEN_CL);
-- для каждой номенклатуры вставляет значение, если оно указано пользователем
for doc in (
	select DOCUMENT as RN
	from SELECTLIST
	where IDENT = nIDENT
) loop if sMED_ACC_TYPE is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
	doc.RN,
	sUNITCODE,
	nMED_ACC_TYPE,
	sMED_ACC_TYPE,
	null,
	null,
	inout_rn
);
end if;
if sPHARM_GROUP is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
	doc.RN,
	sUNITCODE,
	nPHARM_GROUP,
	sPHARM_GROUP,
	null,
	null,
	inout_rn
);
end if;
if sSTORAGE is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
	doc.RN,
	sUNITCODE,
	nSTORAGE,
	sSTORAGE,
	null,
	null,
	inout_rn
);
end if;
if sACC_GROUP is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
	doc.RN,
	sUNITCODE,
	nACC_GROUP,
	sACC_GROUP,
	null,
	null,
	inout_rn
);
end if;
if sVITAL is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
	doc.RN,
	sUNITCODE,
	nVITAL,
	sVITAL,
	null,
	null,
	inout_rn
);
end if;
if sIMPORTED is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
	doc.RN,
	sUNITCODE,
	nIMPORTED,
	sIMPORTED,
	null,
	null,
	inout_rn
);
end if;
if sATH_CODE is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
	doc.RN,
	sUNITCODE,
	nATH_CODE,
	sATH_CODE,
	null,
	null,
	inout_rn
);
end if;
if sVKK is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
	doc.RN,
	sUNITCODE,
	nVKK,
	sVKK,
	null,
	null,
	inout_rn
);
end if;
if sEXTEMP is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
	doc.RN,
	sUNITCODE,
	nEXTEMP,
	sEXTEMP,
	null,
	null,
	inout_rn
);
end if;
if sVEN_CL is not null then P_DOCS_PROPS_VALS_BASE_MODIFY(
	doc.RN,
	sUNITCODE,
	nVEN_CL,
	sVEN_CL,
	null,
	null,
	inout_rn
);
end if;
end loop;
end;