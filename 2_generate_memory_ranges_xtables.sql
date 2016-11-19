set feed off serverout on pages 0 lines 600 trimspool on trimout on
create global temporary table memory_ranges_xtables_temp ( statement varchar2(4000)) on commit preserve rows;
declare
	cursor xtables is select kqftanam from x$kqfta;
	address varchar2(16);
	xtable varchar2(30);
	sgabeg varchar2(16);
	sgaend varchar2(16);
	type t_refcursor is ref cursor;
	c_cursor t_refcursor;
	type address_list_type is table of varchar2(16);
	address_list address_list_type;
begin
	select rawtohex(max(addr)) into sgaend from x$ksmmem;
	select rawtohex(min(addr)) into sgabeg from x$ksmmem;
	for c in xtables loop
		begin
			execute immediate 'select rawtohex(addr), '''||c.kqftanam||''' from '||c.kqftanam||' where rownum < 2' into address, xtable;
			if to_number(address,'xxxxxxxxxxxxxxxx') > to_number(sgabeg,'xxxxxxxxxxxxxxxx') and to_number(address,'xxxxxxxxxxxxxxxx') < to_number(sgaend,'xxxxxxxxxxxxxxxx') then
				open c_cursor for 'select addr from '||xtable;
				loop
					fetch c_cursor bulk collect into address_list limit 1000;
					exit when address_list.count = 0;
					for n_address in 1 .. address_list.count() loop
						insert into memory_ranges_xtables_temp values ('select ('||to_number(address_list(n_address),'xxxxxxxxxxxxxxxx')||'+c.kqfcooff)||''|''||('||to_number(address_list(n_address),'xxxxxxxxxxxxxxxx')||'+c.kqfcooff+c.kqfcosiz-1)||''|''||''shared pool''||''|''||t.kqftanam||''.''||c.kqfconam from x$kqfta t, x$kqfco c where t.indx=c.kqfcotab and kqfcooff != 0 and t.kqftanam = '''||xtable||''';');
					end loop;
				end loop;
				close c_cursor;
			end if;
		exception
			when others then null;
		end;
	end loop;
	commit;
end;
/
spool 2a_generate_memory_ranges_xtables_generated.sql
select 'set head off pages 0 lines 400 trimout on trimspool on feed off sqlblanklines off' from dual;
select 'spool memory_ranges_xtables.csv' from dual;
select * from memory_ranges_xtables_temp;
select 'spool off' from dual;
spool off
truncate table memory_ranges_xtables_temp;
drop table memory_ranges_xtables_temp purge;
@2a_generate_memory_ranges_xtables_generated
host rm 2a_generate_memory_ranges_xtables_generated.sql
