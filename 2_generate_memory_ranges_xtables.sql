set feed off serverout on pages 0 lines 600 trimspool on trimout on
spool 2a_generate_memory_ranges_xtables_generated.sql
select 'set head off pages 0 lines 400 trimout on trimspool on feed off sqlblanklines off' from dual;
select 'spool memory_ranges_xtables.csv' from dual;
declare
	sgaend number;
	cursor xtables is select kqftanam from x$kqfta where kqftanam not like 'X$LOGMNR%' or kqftanam != 'X$DRC';
	address varchar2(16);
	xtable varchar2(30);
	sgaend varchar@(16);

	type address_list_type is table of varchar2(16);
	address_list address_list_type;
begin
	select max(rawtohex(addr)) into sgaend from x$ksmmem;
	for c in xtables loop
		begin
			execute immediate 'select rawtohex(addr), '''||c.kqftanam||''' from '||c.kqftanam||' where rownum < 2' into address, xtable;
			if to_number(address,'xxxxxxxxxxxxxxxx') < to_number(sgaend,'xxxxxxxxxxxxxxxx') then
				execute immediate 'select addr from '||xtable bulk collect into address_list;
				for n_address in 1 .. address_list.count() loop
					dbms_output.put_line('select ('||to_number(address_list(n_address),'xxxxxxxxxxxxxxxx')||'+c.kqfcooff)||''|''||('||to_number(address_list(n_address),'xxxxxxxxxxxxxxxx')||'+c.kqfcooff+c.kqfcosiz-1)||''|''||''shared pool''||''|''||t.kqftanam||''.''||c.kqfconam from x$kqfta t, x$kqfco c where t.indx=c.kqfcotab and kqfcooff != 0 and t.kqftanam = '''||xtable||'''; ');
				end loop;
			end if;
		exception
			when no_data_found then null;
			when others then null;
		end;
	end loop;
end;
/
select 'spool off' from dual;
spool off
@2a_generate_memory_ranges_xtables_generated
host rm 2a_generate_memory_ranges_xtables_generated.sql
