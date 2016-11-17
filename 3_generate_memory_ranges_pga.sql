set head off pages 0 lines 200 trimout on trimspool on feed off sqlblanklines off
spool memory_ranges_pga.csv
select to_number(rawtohex(heap_descriptor),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(heap_descriptor),'xxxxxxxxxxxxxxxx')+bytes)||'|'||'pga'||'|'||category||', '||heap_name||', '||name from v$process_memory_detail;
spool off
