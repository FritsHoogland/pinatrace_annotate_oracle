set head off pages 0 lines 200 trimout on trimspool on feed off sqlblanklines off
spool memory_ranges.csv
--format: start address (int) | end address (int) | memory area (redo,fixed,variable) | description
--- public redo 
select to_number(rawtohex(pnext_buf_kcrfa_cln),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(pnext_buf_kcrfa_cln),'xxxxxxxxxxxxxxxx')+strand_size_kcrfa)||'|'||'redo'||'|'||'PUB_REDO_'||indx from x$kcrfstrand where pnext_buf_kcrfa_cln != hextoraw(0)
union all
-- private redo strands
select to_number(rawtohex(ptr_kcrf_pvt_strand),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(ptr_kcrf_pvt_strand),'xxxxxxxxxxxxxxxx')+strand_size_kcrfa)||'|'||'shared pool'||'|'||'PVT_REDO_'||indx from x$kcrfstrand where ptr_kcrf_pvt_strand != hextoraw(0)
union all
-- in memory undo buffers
select to_number(rawtohex(ktifpupb),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(ktifpupb),'xxxxxxxxxxxxxxxx')+ktifppsi)||'|'||'shared pool'||'|'||'IMU_'||indx from x$ktifp
union all
-- fixed sga variables
select to_number(rawtohex(ksmfsadr),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(ksmfsadr),'xxxxxxxxxxxxxxxx')+ksmfssiz)||'|'||'fixed sga'||'|'||'var:'||ksmfsnam from x$ksmfsv
union all
-- shared pool/ksmsp
select to_number(rawtohex(ksmchptr),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(ksmchptr),'xxxxxxxxxxxxxxxx')+ksmchsiz)||'|'||'shared pool'||'|'||ksmchcom||',duration '||ksmchdur||',cls '||ksmchcls from x$ksmsp
union all
-- latches parent latches -- I assume a latch is 160 bytes
select to_number(rawtohex(kslltaddr),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(kslltaddr),'xxxxxxxxxxxxxxxx')+160)||'|'||'fixed sga'||'|'||'(parent)latch:'||kslltnam from x$kslltr_parent
union all
-- latches child latches
select to_number(rawtohex(kslltaddr),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(kslltaddr),'xxxxxxxxxxxxxxxx')+160)||'|'||'shared  pool'||'|'||'(child)latch:'||kslltnam from x$kslltr_children
union all
-- buffercache buffers
select to_number(rawtohex(ba),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(ba),'xxxxxxxxxxxxxxxx')+blsiz)||'|'||'buffer cache'||'|'||ltrim(rawtohex(ba),'0') from x$bh
union all
-- dictionary cache parent
select to_number(rawtohex(p.addr),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(p.addr),'xxxxxxxxxxxxxxxx')+p.kqrpdtsz)||'|'||'shared pool'||'|(parent dc)'||s.kqrsttxt from x$kqrpd p, x$kqrst s where s.kqrstcid = p.kqrpdcid
union all
-- dictionary cache subordinate
select to_number(rawtohex(p.addr),'xxxxxxxxxxxxxxxx')||'|'||(to_number(rawtohex(p.addr),'xxxxxxxxxxxxxxxx')+p.kqrsdtsz)||'|'||'shared pool'||'|(subordinate dc)'||s.kqrsttxt from x$kqrsd p, x$kqrst s where s.kqrstcid = p.kqrsdcid;
spool off
