set head on pages 1000 lines 200 serverout on
select p.pid as pid, s.sid||','||p.serial#||',@'||p.inst_id as sid_serial_inst, p.spid as ospid, s.username as username, s.program as program
from gv$process p, gv$session s where s.paddr=p.addr and s.inst_id=p.inst_id;
accept pid prompt "enter pid number to get pga details:";
alter session set events 'immediate trace name pga_detail_get level &pid';
set head off
select 'execute something (eg. select * from dual) in the target process to have the process fill v$process_memory_detail out.' from dual;
undef pid
