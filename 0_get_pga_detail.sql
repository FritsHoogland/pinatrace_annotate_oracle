set head on pages 1000 lines 200 serverout on
col SID_SERIAL_INST form a15
select p.pid as pid, s.sid||','||p.serial#||',@'||p.inst_id as sid_serial_inst, p.spid as ospid, s.username as username, s.program as program
from gv$process p, gv$session s where s.paddr=p.addr and s.inst_id=p.inst_id;
accept pid prompt "enter pid number to get pga details: ";
alter session set events 'immediate trace name pga_detail_get level &pid';
set head off
accept dummy prompt "execute something (eg. select * from dual) in the target process, then press enter";
undef pid
undef dummy
