20130816
ordered hint 在9i上完全工作  但leading在9i上工作不太正常，但在10g上ok


20130814
DETERMINISTIC 能够优化性能如果带入的参数不变的话，就不用重复调用 
You must specify this keyword if you intend to call the function in the expression of a
function-based index or from the query of a materialized view that is marked
REFRESH FAST or ENABLE QUERY REWRITE.


20130812 
ref cursor 不能跨db link


我们知道clustering_factor是通过oracle的索引得到表数据块的一个因子，实际上表示index列的排列顺序和表中index这个列的排列顺序的关系

20130508 utl_smtp实现抄送
 type split_type IS TABLE OF VARCHAR2(4000);

真正实现发件的是
  UTL_SMTP.RCPT(v_smtp_con, i_cc);
下面这个只是客户端显示的时候用
utl_smtp.write_data(v_smtp_con, 'Cc:  ' || i_cc || utl_tcp.CRLF);
   
function split(p_str in varchar2, p_delimiter in varchar2 default (','))
    return split_type IS
    j        INT := 0;
    i        INT := 1;
    len      INT := 0;
    len1     INT := 0;
    str      VARCHAR2(4000);
    my_split split_type := split_type();
  BEGIN
    len  := LENGTH(p_str);
    len1 := LENGTH(p_delimiter);
  
    WHILE j < len LOOP
      j := INSTR(p_str, p_delimiter, i);
    
      IF j = 0 THEN
        j   := len;
        str := SUBSTR(p_str, i);
        my_split.EXTEND;
        my_split(my_split.COUNT) := str;
      
        IF i >= len THEN
          EXIT;
        END IF;
      ELSE
        str := SUBSTR(p_str, i, j - i);
        i   := j + len1;
        my_split.EXTEND;
        my_split(my_split.COUNT) := str;
      END IF;
    END LOOP;
  
    RETURN my_split;
  END split;
  
  
procedure p_send_mail_new(i_from    varchar2,
                           i_to      varchar2,
                           i_cc      varchar2,
                           i_bcc     varchar2,
                           i_subject varchar2,
                           i_content varchar2) is
    v_smtp_con      utl_smtp.connection := utl_smtp.open_connection(g_smtp_host);
    v_from          varchar2(100);
    v_mail_body     varchar2(32767);
    v_offset        number := 1;
    v_amount        number := 32767;
    v_subject       varchar2(1000);
    v_content       varchar2(5000);
    v_email_addrees split_type;
  begin
    UTL_SMTP.HELO(v_smtp_con, g_smtp_host);
  
    if i_from is not null and length(i_from) > 0 then
      v_from := i_from;
    else
      v_from := g_smtp_from;
    end if;
    UTL_SMTP.MAIL(v_smtp_con, v_from);
  
    v_email_addrees := split(i_to, ';');
    for i in v_email_addrees.FIRST .. v_email_addrees.last loop
      dbms_output.put_line(v_email_addrees(i));
      UTL_SMTP.RCPT(v_smtp_con, v_email_addrees(i));
    end loop;
    --    UTL_SMTP.RCPT(v_smtp_con, i_to);
  
    if i_cc is not null and length(i_cc) > 0 then
      v_email_addrees := split(i_cc, ';');
       for i in v_email_addrees.FIRST .. v_email_addrees.last loop
       dbms_output.put_line(v_email_addrees(i));
       UTL_SMTP.RCPT(v_smtp_con, v_email_addrees(i));
       end loop;
    end if;
    if i_bcc is not null and length(i_bcc) > 0 then
      
     v_email_addrees := split(i_bcc, ';');
       for i in v_email_addrees.FIRST .. v_email_addrees.last loop
       dbms_output.put_line(v_email_addrees(i));
       UTL_SMTP.RCPT(v_smtp_con, v_email_addrees(i));
       end loop;  
    
    end if;
    UTL_SMTP.OPEN_DATA(v_smtp_con);
      utl_smtp.write_data(v_smtp_con, 'MIME-version: 1.0' || utl_tcp.CRLF);
    utl_smtp.write_data(v_smtp_con,
                        'Content-Type: text/html; charset=utf-8' ||
                        utl_tcp.CRLF);
    utl_smtp.write_data(v_smtp_con,
                        'Content-Transfer-Encoding: 8bit' || utl_tcp.CRLF); 
  
    utl_smtp.write_data(v_smtp_con, 'From: ' || v_from || utl_tcp.CRLF);
    utl_smtp.write_data(v_smtp_con, 'To: ' || i_to || utl_tcp.CRLF);
    -- utl_smtp.write_data(v_smtp_con, utl_tcp.crlf);
    if i_cc is not null and length(i_cc) > 0 then
      utl_smtp.write_data(v_smtp_con, 'Cc:  ' || i_cc || utl_tcp.CRLF);
      -- utl_smtp.write_data(v_smtp_con, utl_tcp.crlf);
    end if;
  
    if i_bcc is not null and length(i_bcc) > 0 then
      utl_smtp.write_data(v_smtp_con, 'BCc:  ' || i_bcc || utl_tcp.CRLF);
      --   utl_smtp.write_data(v_smtp_con, utl_tcp.crlf);
    end if;
    --v_subject := '=?utf-8?Q?' ||
    --             utl_raw.cast_to_varchar2(utl_encode.quoted_printable_encode(utl_raw.cast_to_raw(i_subject))) || '?=';
    --  utl_smtp.write_data(v_smtp_con, utl_tcp.crlf);
    v_subject := 'Subject:' || i_subject  ;
    --v_subject:=i_subject;
    /*  utl_smtp.WRITE_RAW_DATA(v_smtp_con,
    UTL_RAW.CAST_TO_RAW( v_subject ));*/
  
   -- utl_smtp.write_data(v_smtp_con, v_subject);
   utl_smtp.WRITE_raw_DATA(v_smtp_con,
                         utl_raw.cast_to_raw(v_subject));
   
    utl_smtp.write_data(v_smtp_con, utl_tcp.crlf);
  
    UTL_SMTP.WRITE_raw_DATA(v_smtp_con, utl_raw.cast_to_raw(i_content)); 
   -- UTL_SMTP.write_data(v_smtp_con, i_content);
    UTL_SMTP.CLOSE_DATA(v_smtp_con);
    UTL_SMTP.QUIT(v_smtp_con);
  
  EXCEPTION
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      BEGIN
        UTL_SMTP.QUIT(v_smtp_con);
      EXCEPTION
        WHEN UTL_SMTP.TRANSIENT_ERROR OR UTL_SMTP.PERMANENT_ERROR THEN
          NULL; -- When the SMTP server is down or unavailable, we don't have
        -- a connection to the server. The QUIT call will raise an
        -- exception that we can ignore.
      END;
      raise_application_error(-20000,
                              'Failed to send mail due to the following error: ' ||
                              sqlerrm);
  end p_send_mail_new;
  

20121107 ,sqlldr 复合处理

load data
truncate into table temp_octo_trade
fields terminated by ','  TRAILING NULLCOLS
(tradeno ,
tradeDATE      date "yyyy-mm-dd"  "substr(:tradeDATE,1,10)"   ,
confirmationdate   date "yyyy-mm-dd"  "substr(:confirmationdate,1,10)"
)


20120822
在server上设置 SQLNET.EXPIRE_TIME=10 做定期检测，以防止firewall阻止idel connection,
设置后需要重启listener和db

flash back query 

flash backup drop only  for non-system, locally managed tablespaces,can query 
tables which have Fine-Grained Auditing (FGA) and Virtual Private Database (VPD) policies defined over them are not protected by the recycle bin.
Partitioned index-organized tables are not protected by the recycle bin.

flash back table和flash back query在做了ddl操作之后，都不可以

Flashback Transaction Query uses the data dictionary view FLASHBACK_TRANSACTION_QUERY to retrieve transaction information for all tables involved in a transaction.


flashback database to TIMESTAMP(sysdate - 2/24);

SELECT versions_startscn, versions_starttime,
versions_endscn, versions_endtime,
versions_xid, versions_operation,
description
FROM flashback_version_query
VERSIONS BETWEEN TIMESTAMP TO_TIMESTAMP('2004-04-27 15:13:57', 'YYYY-MM-DD HH24:MI:SS')
AND TO_TIMESTAMP('2004-04-27 15:14:52', 'YYYY-MM-DD HH24:MI:SS')
WHERE id = 1;


SELECT * FROM EMPLOYEE AS OF TIMESTAMP
TO_TIMESTAMP('2003-03-19 10:00:00', 'YYYY-MM-DD HH:MI:SS')
WHERE name = 'YASH';

SELECT xid, operation, start_scn,commit_scn, logon_user, undo_sql
FROM flashback_transaction_query
WHERE xid = HEXTORAW('0006001000000250'); 2 3





flash backup database ,通过 DB_FLASHBACK_RETENTION_TARGET 控制时间，但是这个不是guanrett的，除非空间够
V$FLASHBACK_DATABASE_LOG 


20100908
使用utl_mail发送邮件更方便
使用前线设置
 alter system set SMTP_OUT_SERVER='192.168.20.43' scope=spfile;
 @$ORACLE_HOME/rdbms/admin/utlmail.sql
 @$ORACLE_HOME/rdbms/admin/prvtmail.plb
 
execute UTL_MAIL.SEND(sender=>'wanzy@cicc.com.cn',recipients=>'wanzy@cicc.com.cn',subject =>'中文',message => '中文test',mime_type=>'text/html;charset=GBK');
20081119
在并行查询中，除非表小于某个阀值，否则都是走direct read的
alter session set "_px_trace"="all"; 
20080506
再在dedeciate 连接的时候，
客户端交互都是和listener的端口交互，就算listener 断了，也是那个server进程继续在该端口和客户端通讯，连接之后的通讯和listener没有关系了



20080219 关于同时插入和删除的问题
即使有Pk和unique index,在一个session插入未提交的情况下，也可以同时插入不同的记录
可以在插入未提交的时候，做删除


http://edelivery.oracle.com/

20071128 materialized view
首先要设置 query rewrite enable=true
然后收集mv的statistics

20070910 检查死锁
在rac环境
分别在两个节点进行测试 ，1分钟后解锁
在一个节点进行测试 ，1分钟后解锁
单机环境，马上解锁


20070815 如何让一个程序的事务独立于主事务
create or replace procedure p_test as 
PRAGMA AUTONOMOUS_TRANSACTION;
begin
insert into test_1 values(1);
commit;
end p_test;
/

declare 
begin
insert into test_1 values(2);
	p_test;
rollback;
end;
/


20070726

too many row cache lock for dc_sequences 

Doc ID: 	Note:395314.1

SQL> select SEQUENCE_OWNER,CACHE_SIZE from dba_sequences where SEQUENCE_NAME='AUDSES$';

SEQUENCE_OWNER                 CACHE_SIZE
------------------------------ ----------
SYS                                    20

alter sequence sys.audses$ cache 10000;


Mon Jul 16 23:00:13 2007
>>> WAITED TOO LONG FOR A ROW CACHE ENQUEUE LOCK! pid=285
System State dumped to trace file /picclife/oracle/app/oracle/admin/life/udump/life1_ora_487544.trc
Mon Jul 16 23:00:45 2007
Errors in file /picclife/oracle/app/oracle/admin/life/bdump/life1_pmon_136088.trc:

SELECT cache#, type, parameter
FROM v$rowcache
WHERE cache# = <cache id>; 


This event is used to wait for a lock on a data dictionary cache specified by "cache id". If this event shows up a lot, consider increasing the shared pool so that more data dictionary can be cached. The row cache lock we are waiting for can be shown from:




20070725

10.2.0.2

Deadlock detection can take too long in a RAC environment 
where many processes are waiting for a lock involved in the deadlock cycle.
This fix allows "_lm_dd_interval"=0 to be set to allow faster deadlock
detection.

This parameter should only be set under the guidance of Oracle Support.
Note that the faster deadlock detection comes at a CPU cost .



20070629 如何在线redefine table 


drop table test_wzy_mid;
drop table test_wzy2;
drop table test_wzy;

	create table test_wzy (id number(2),name varchar2(20)) tablespace lifedata_t_m;
	alter table test_wzy add constraint pk_test_wzy primary key (id);
	create index idx_test_wzy on test_wzy(name);
	
	insert into test_wzy values(1,'1');
	insert into test_wzy values(2,'2');
	
	create table test_wzy2(id number(2));
	alter table test_wzy2 add constraint fk_test_wzy2 foreign key (id) references test_wzy(id);
	
	insert into test_wzy2 values(1);
	insert into test_wzy2 values(2);

select  index_name,status ,t.TABLESPACE_NAME from user_indexes t where t.table_name like 'TEST_WZY%';
select CONSTRAINT_NAME,TABLE_NAME,R_CONSTRAINT_NAME,VALIDATED  From user_constraints t where t.table_name like 'TEST_WZY%';


alter table test_wzy move tablespace lifedata_t_l;
alter index pk_test_wzy rebuild;
alter index idx_test_wzy rebuild;

重新编译所有失效对象。

用 DBMS_REDEFINITION 会出现 子表同时和主表以及中间表出现关联关系，而且约束状态不对。


alter session force parallel dml parallel 8;
alter session force parallel query parallel 8;


execute DBMS_REDEFINITION.CAN_REDEF_TABLE('PICCPROD','TEST_WZY',DBMS_REDEFINITION.CONS_USE_PK);

create interim table 
create table test_wzy_mid (id number(2) primary key ,name varchar2(20)) tablespace LIFEDATA_T_L;


execute DBMS_REDEFINITION.START_REDEF_TABLE('PICCPROD', 'TEST_WZY','test_wzy_mid','id id, name name',dbms_redefinition.cons_use_pk);

DECLARE
num_errors PLS_INTEGER;
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS('PICCPROD', 'TEST_WZY','test_wzy_mid',DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);
END;

select object_name, base_table_name, ddl_txt from DBA_REDEFINITION_ERRORS;


execute DBMS_REDEFINITION.SYNC_INTERIM_TABLE('PICCPROD', 'TEST_WZY', 'test_wzy_mid');

execute DBMS_REDEFINITION.FINISH_REDEF_TABLE('PICCPROD', 'TEST_WZY', 'test_wzy_mid');


select  index_name,status ,t.TABLESPACE_NAME from user_indexes t where t.table_name like 'TEST_WZY%';

drop table test_wzy_mid;

20070528 10.2.0.2 when set aq_tm_processes 
qmnc process spins or exhibits very high CPU
set aq_tm_processes=0,ok

20070404 
v$sql里面的parse应该和execute差不多一样
除非cursor不关闭,直接重复执行

可以通过  select  *from v$sql_shared_cursor t where t.ADDRESS='5D374E28'; 查询不能共享的sql

alter system set cursor_sharing='EXACT';
select *from test where id=4;
select *from test where id=5;

select  * from v$sql t where t.SQL_TEXT like 'select *from test where id%'
1	3chc9df7zwtqt	select *from test where id=4  
3	asrudpjdm7yxa	select *from test where id=5  


alter system set cursor_sharing='SIMILAR';
select *from test where id=2;
select *from test where id=3;
select  * from v$sql t where t.SQL_TEXT like 'select *from test where id%'
08xczwxuf61u6	select *from test where id=:"SYS_B_0"  



alter system set cursor_sharing='SIMILAR';

select *from test where id>1;
select *from test where id>2;
select *from test where id>3;

2	0v63fq7mstvtu	select *from test where id>:"SYS_B_0"  
3	0v63fq7mstvtu	select *from test where id>:"SYS_B_0"  
4	0v63fq7mstvtu	select *from test where id>:"SYS_B_0"  


alter system set cursor_sharing='FORCE';

select *from test where id>3;
select *from test where id>2;
select *from test where id>1;
select *from test where id>9;

0v63fq7mstvtu	select *from test where id>:"SYS_B_0"  	4


20070331
imp \'username/password AS SYSDBA\'
exp  \'system/sys_picc_01 AS SYSDBA\'
20070330 
处理oracle问题标准流程
select *from v$session_wait;
execute pkg_picclife_maintain.p_gather_state
oradebug hanganalyze 3


检查锁情况

drop table lock_holders;

create table LOCK_HOLDERS   /* temporary table */
(
  waiting_session   number,
  holding_session   number,
  lock_type         varchar2(26),
  mode_held         varchar2(14),
  mode_requested    varchar2(14),
  lock_id1          varchar2(22),
  lock_id2          varchar2(22)
);

drop   table dba_locks_temp;
create table dba_locks_temp as select * from dba_locks;

insert into lock_holders
  select w.session_id,
        h.session_id,
        w.lock_type,
        h.mode_held,
        w.mode_requested,
        w.lock_id1,
        w.lock_id2
  from dba_locks w, dba_locks h
 where h.blocking_others =  'Blocking'
  and  h.mode_held      !=  'None'
  and  h.mode_held      !=  'Null'
  and  w.mode_requested !=  'None'
  and  w.lock_type       =  h.lock_type
  and  w.lock_id1        =  h.lock_id1
  and  w.lock_id2        =  h.lock_id2;

commit;

drop table dba_locks_temp;

insert into lock_holders
  select holding_session, null, 'None', null, null, null, null
    from lock_holders
 minus
  select waiting_session, null, 'None', null, null, null, null
    from lock_holders;
commit;

column waiting_session format a17;
column lock_type format a17;
column lock_id1 format a17;
column lock_id2 format a17;

/* Print out the result in a tree structured fashion */
select  lpad(' ',3*(level-1)) || waiting_session waiting_session,
        lock_type,
        mode_requested,
        mode_held,
        lock_id1,
        lock_id2
 from lock_holders
connect by  prior waiting_session = holding_session
  start with holding_session is null;

drop table lock_holders;


或者直接从v$lock提取数据

 drop table lock_holders;
 
 create table lock_holders as select w.sid wait_session,
        h.sid hold_session,
        w.type,
        h.LMODE,
        w.REQUEST,
        w.id1,
        w.id2
  from PICC_03301411v$lock  w, PICC_03301411v$lock h
 where h.block =1 
  and  h.LMODE      >0
  and  w.REQUEST >0
  and  w.type       =  h.type
  and  w.id1        =  h.id1
  and  w.id2        =  h.id2;

insert into lock_holders
  select hold_session, null, 0, null, null, null, null
    from lock_holders
 minus
  select wait_session, null, 0, null, null, null, null
    from lock_holders;
commit;




select  lpad(' ',3*(level-1)) || wait_session waiting_session,
        type,
        REQUEST,
        LMODE,
        id1,
       id2
 from lock_holders
connect by  prior wait_session = hold_session
  start with hold_session is null;
  
  

20061223 ldap
first load plsql api
SQL> CONNECT / AS SYSDBA
SQL> @?/rdbms/admin/catldap.sql


20061214

SQL> select *from t2;

 ID ID2
--- ---
  3  33
  2  22
  4  46

SQL> 
SQL> select *from t1;

 ID ID2
--- ---
  1  11
  3  33
  4  45
  6  66

能查出在表一不在表二,或者不一样的记录 ,效果等于外连接


 select *from t1 where not exists (select * from t2 where t1.id=t2.id  );
 select * From t1,t2 where t1.id=t2.id(+) and  t2.id is null;

 ID ID2  ID ID2
--- --- --- ---
  1  11     
  6  66     


 ID ID2
--- ---
  1  11
  6  66
  

  
select *from t1 where not exists (select * from t2 where t1.id=t2.id and t1.id2=t2.id2 );

 ID ID2
--- ---
  4  45
  1  11
  6  66
  
  
select * From t1,t2 where t1.id=t2.id(+) and t1.id2=t2.id2(+) and t2.id is null;

 ID ID2  ID ID2
--- --- --- ---
  4  45     
  1  11     
  6  66     
  

  
  

20061211
Connections that Used to Work in Oracle 10.1 Now Intermittently Fail with ORA-3113,ORA-3106 or ORA-3136 in 10.2
The Oracle Net 10g parameters SQLNET.INBOUND_CONNECT_TIMEOUT and INBOUND_CONNECT_TIMEOUT_listenername default to 0 (indefinite) in 10.1.  To address Denial of Service (DOS) issues,  the parameters were set to have a default of 60 (seconds) in Oracle 10.2.

If applications are longer than 60 secs to authenticate with the Oracle database, the errors occur.

The following may be seen in the alert log: WARNING: inbound connection timed out (ORA-3136)

SQLNET.INBOUND_CONNECT_TIMEOUT is set to a value in seconds and determines how long a client has to provide the necessary authentication information to a database.

INBOUND_CONNECT_TIMEOUT_listenername is set to a value in seconds and determines how long a client has to complete its connect request to the listener after the network connection has been established.

To protect both the listener and the database server, Oracle Corporation recommends setting INBOUND_CONNECT_TIMEOUT_listenername in combination with the SQLNET.INBOUND_CONNECT_TIMEOUT parameter.
Cause

Whenever default timeouts are assigned to a parameter, there may be cases where this default does not work well with a particular application. However, some type of timeout on the connection establishment is necessary to combat Denial of Service attacks on the database.  In this case, SQLNET.INBOUND_CONNECT__TIMEOUT and INBOUND_CONNECT_TIMEOUT_listenername were given default values of 60 seconds in Oracle 10.2.  It is these timeout values that can cause the errors described in this note.


Also note that it is possilbe the reason the database is slow to authenticate, may be due to an overloaded Oracle database or node.
Solution

Set the parameters SQLNET.INBOUND_CONNECT_TIMEOUT and INBOUND_CONNECT_TIMEOUT_listenername to 0 (indefinite) or to an approprate value for the application yet still combat DOS attacks (120 for example). 

These parameters are set on the SERVER side:
listener.ora: INBOUND_CONNECT_TIMEOUT_listenername
sqlnet.ora:   SQLNET.INBOUND_CONNECT_TIMEOUT

Further tuning of these parameters may be needed is the problem persists.



Whenever default timeouts are assigned to a parameter, there may be cases where this default does not work well with a particular application. However, some type of timeout on the connection establishment is necessary to combat Denial of Service attacks on the database.  In this case, SQLNET.INBOUND_CONNECT__TIMEOUT and INBOUND_CONNECT_TIMEOUT_listenername were given default values of 60 seconds in Oracle 10.2.  It is these timeout values that can cause the errors described in this note.

20061208

导数据注意事项
导之前先停止所有后台job

20061207 生产环境监控


--监控数据库剩余空间
create table tab_mon_free_space(snap_id number(10),snap_time date,tablespace_name varchar2(200),free_space_m number(10));

--监控数据库数据增长
create table tab_mon_used_space(snap_id number(10),snap_time date,owner varchar2(200),used_space_m number(10)) tablespace sysaux;

create or replace procedure p_gather_db_stats
as
begin
pkg_picclife_maintain.p_mail('wanzhengyong@picclife.cn','start gather db statistics','start gather db statistics');
dbms_stats.gather_database_stats(degree => 8);
pkg_picclife_maintain.p_mail('wanzhengyong@picclife.cn','end gather db statistics','end gather db statistics');
end p_gather_db_stats;

create directory log_dir as '/picclife/backup/script/log';
GRANT READ ON DIRECTORY user_dir TO PUBLIC;

create sequence seq_mon_space start with 1 cache 200;

create or replace package pkg_picclife_maintain as
--create by： roger wan
--create time：200601208
--info：  监控维护程序
--modification hist：
--序号  修改日期    姓名                            修改内容
--1        20061208   roger wan                     增加dg监控

  procedure p_grant_privllege(i_user_name varchar2, i_privllege number);
  PROCEDURE send_header(name IN VARCHAR2, header IN VARCHAR2);
  procedure p_mail(i_to varchar2, i_subject varchar2, i_content varchar2);
  procedure p_file(i_dir       in varchar2,
                   i_file_name in varchar2,
                   o_content   out varchar2);
  procedure p_mail_log(i_to        varchar2,
                       i_subject   varchar2,
                       i_file_name varchar2,
                       i_dir       varchar2);
  procedure p_mail_log_daily;
  procedure p_monitor_space;
  procedure p_monitor_dataguard ;
  procedure p_grant_procedure_privllege(i_user_name varchar2);
    procedure p_gather_state;
  procedure p_kill_session;
 procedure p_monitor_session_wait;

   
end pkg_picclife_maintain;
/
create or replace package body pkg_picclife_maintain as
  c         UTL_SMTP.CONNECTION;
  mail_host varchar2(200) := '10.0.254.5';
  -- from_user varchar2(200):='monitor';
  to_user     varchar2(200) := 'wanzhengyong@picclife.cn';
  from_user   varchar2(200) := 'monitor@picclife.cn';
  domain_name varchar2(200) := 'picclife.cn';
  procedure p_grant_privllege(i_user_name varchar2, i_privllege number) as
    v_current_user  varchar2(20);
    v_sql           varchar2(2000);
    v_create_syn    varchar2(2000);
    v_drop_syn      varchar2(2000);
    v_error_message varchar2(2000);
    v_syn_count     number(2);
  begin
    select sys_context('USERENV', 'CURRENT_USER')
      into v_current_user
      from dual;
  
    for all_table in (select * from user_tables) loop
      if i_privllege = 2 then
        v_sql := 'grant select ,update,insert on ' || all_table.TABLE_NAME ||
                 ' to ' || i_user_name;
      end if;
      if i_privllege = 1 then
        v_sql := 'grant select on ' || all_table.TABLE_NAME || ' to ' ||
                 i_user_name;
      end if;
      v_create_syn := 'create synonym ' || i_user_name || '.' ||
                      all_table.TABLE_NAME || ' for ' || v_current_user || '.' ||
                      all_table.TABLE_NAME;
      --select count(*) into v_syn_count from i_user_name.user_synonyms t where t.owner=i_user_name and t.synonym_name=all_table.TABLE_NAME;
      execute immediate v_sql;
    
      begin
        v_drop_syn := 'drop synonym ' || i_user_name || '.' ||
                      all_table.TABLE_NAME;
        --if v_syn_count=1 then
        execute immediate v_drop_syn;
        --end if;
      exception
        when others then
          v_error_message := '' || SQLERRM;
          dbms_output.put_line(v_error_message);
      end;
    
      begin
        execute immediate v_create_syn;
      exception
        when others then
          v_error_message := '' || SQLERRM;
          dbms_output.put_line(v_error_message);
      end;
    
    end loop;
  end p_grant_privllege;

  procedure p_mail(i_to             varchar2,
                   i_subject        varchar2,
                   i_content        varchar2,
                   p_return_code    out number,
                   p_return_message out varchar2) as
 v_msg varchar2(5000);
 v_subject varchar2(1000);
  BEGIN
    c := UTL_SMTP.OPEN_CONNECTION(mail_host);
    UTL_SMTP.HELO(c, domain_name);
    UTL_SMTP.MAIL(c, from_user);
    UTL_SMTP.RCPT(c, i_to);
    UTL_SMTP.OPEN_DATA(c);
    
  utl_smtp.write_data(c, 'MIME-version: 1.0' || utl_tcp.CRLF);
  utl_smtp.write_data(c, 'Content-Type: text/html; charset=utf-8' ||utl_tcp.CRLF);
  utl_smtp.write_data(c, 'Content-Transfer-Encoding: 8bit' ||utl_tcp.CRLF);
 
  utl_smtp.write_data(c, 'From: ' ||i_to||utl_tcp.CRLF);
  utl_smtp.write_data(c, 'To:' ||i_to||utl_tcp.CRLF);
  
  v_subject:='=?utf-8?Q?' || utl_raw.cast_to_varchar2(  
  utl_encode.quoted_printable_encode(utl_raw.cast_to_raw(i_subject)))|| '?=';
 
  utl_smtp.write_data(c, 'Subject:' ||v_subject||utl_tcp.crlf);
 
  utl_smtp.write_data(c, utl_tcp.crlf);

    UTL_SMTP.WRITE_raw_DATA(c, utl_raw.cast_to_raw(i_content));
    UTL_SMTP.CLOSE_DATA(c);
    UTL_SMTP.QUIT(c);

    p_return_code := 1;

  EXCEPTION
    /*
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      BEGIN
        UTL_SMTP.QUIT(c);
      EXCEPTION
        WHEN UTL_SMTP.TRANSIENT_ERROR OR UTL_SMTP.PERMANENT_ERROR THEN
          NULL; -- When the SMTP server is down or unavailable, we don't have
        -- a connection to the server. The QUIT call will raise an
        -- exception that we can ignore.
      END;

      p_return_code := 0;

      p_return_message := sqlerrm;

      raise_application_error(-20000,
                              'Failed to send mail due to the following error: ' ||
                              sqlerrm);
                              */
    when others then
      p_return_code    := 0;
      p_return_message := sqlerrm;
  END;
  
  
  
  PROCEDURE send_header(name IN VARCHAR2, header IN VARCHAR2) as
  BEGIN
    UTL_SMTP.WRITE_DATA(c, name || ': ' || header || UTL_TCP.CRLF);
  END;

  procedure p_file(i_dir       in varchar2,
                   i_file_name in varchar2,
                   o_content   out varchar2) as
    V1 VARCHAR2(32767);
    F1 UTL_FILE.FILE_TYPE;
  begin
    o_content := '';
    v1        := '';
    F1        := UTL_FILE.FOPEN(upper(i_dir), i_file_name, 'R');
    loop
      begin
        UTL_FILE.GET_LINE(F1, V1, 32767);
        o_content := o_content || '\d\r' || v1;
      exception
        when NO_DATA_FOUND then
          exit;
      end;
    end loop;
    UTL_FILE.FCLOSE(F1);
  end p_file;

  procedure p_mail_log(i_to        varchar2,
                       i_subject   varchar2,
                       i_file_name varchar2,
                       i_dir       varchar2) as
    V1 VARCHAR2(32767);
    F1 UTL_FILE.FILE_TYPE;
  
  BEGIN
    c := UTL_SMTP.OPEN_CONNECTION(mail_host);
    UTL_SMTP.HELO(c, domain_name);
    UTL_SMTP.MAIL(c, from_user);
    UTL_SMTP.RCPT(c, i_to);
    UTL_SMTP.OPEN_DATA(c);
    send_header('From', from_user);
    send_header('To', i_to);
    send_header('Subject', i_subject);
    --read file to mail
    F1 := UTL_FILE.FOPEN(upper(i_dir), i_file_name, 'R');
    loop
      begin
        UTL_FILE.GET_LINE(F1, V1, 32767);
        UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF || V1);
      
      exception
        when NO_DATA_FOUND then
          exit;
      end;
    end loop;
    UTL_FILE.FCLOSE(F1);
  
    UTL_SMTP.CLOSE_DATA(c);
    UTL_SMTP.QUIT(c);
  EXCEPTION
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      BEGIN
        UTL_SMTP.QUIT(c);
      EXCEPTION
        WHEN UTL_SMTP.TRANSIENT_ERROR OR UTL_SMTP.PERMANENT_ERROR THEN
          NULL; -- When the SMTP server is down or unavailable, we don't have
        -- a connection to the server. The QUIT call will raise an
        -- exception that we can ignore.
      END;
      raise_application_error(-20000,
                              'Failed to send mail due to the following error: ' ||
                              sqlerrm);
    
  end p_mail_log;

  procedure p_mail_log_daily as
    v_file_name varchar2(2000);
  begin
    select 'rman_' || to_char(sysdate, 'yyyy-mm-dd') || '_01:00:00.log'
      into v_file_name
      from dual;
   
    p_mail_log('wanzhengyong@picclife.cn',
               v_file_name,
               v_file_name,
               'LOG_DIR');
   exception
   when others then
        p_mail('wanzhengyong@picclife.cn',
               'mail rman log error',
               ''||sqlerrm);
        end p_mail_log_daily;
  procedure p_monitor_space as
  begin
    p_mail(to_user, 'start check free space and segment', '');
  
    for all_free_space in (select sum(bytes / 1024 / 1024) size_m,
                                  TABLESPACE_NAME
                             from dba_free_space
                            group by TABLESPACE_NAME) loop
      if all_free_space.size_m < 1000 and
         all_free_space.TABLESPACE_NAME != 'USERS' then
      
        p_mail(to_user,
               'table space warning',
               'TABLESPACE ' || all_free_space.TABLESPACE_NAME ||
               ' size <1000m now is ' || all_free_space.size_m);
      end if;
    end loop;
  
    for all_used_space in (select sum(bytes / 1024 / 1024) size_m, owner
                             from dba_segments t
                            group by t.owner) loop
      insert into tab_mon_used_space
      values
        (seq_mon_space.nextval,
         sysdate,
         all_used_space.owner,
         all_used_space.size_m);
    end loop;
    commit;
  end;
  
    procedure p_monitor_dataguard as
    begin
   for c in (select *from gv$archive_dest_status where dest_Id=2)loop
   if c.STATUS!='VALID' then 
       p_mail('wanzhengyong@picclife.cn',
             'data guard not valid','instance '||c.INST_ID|| 'not valid ');
         end if;
             
   end loop;
   


  end p_monitor_dataguard;
   procedure p_grant_procedure_privllege(i_user_name varchar2)
 as 
    v_current_user  varchar2(20);
    v_sql           varchar2(2000);
    v_create_syn    varchar2(2000);
    v_drop_syn      varchar2(2000);
    v_error_message varchar2(2000);
    v_syn_count     number(2);
  begin
    select sys_context('USERENV', 'CURRENT_USER')
      into v_current_user
      from dual;

    for all_proc in (select * from user_objects t where t.object_type in ('PROCEDURE','FUNCTION','TRIGGER','PACKAGE')) loop
          v_sql := 'grant execute  on ' || all_proc.object_name ||
                 ' to ' || i_user_name;
         v_sql2 := 'grant debug  on ' || all_proc.object_name ||
                 ' to ' || i_user_name;
        v_create_syn := 'create synonym ' || i_user_name || '.' ||
                      all_proc.object_name || ' for ' || v_current_user || '.' ||
                      all_proc.object_name;
      --select count(*) into v_syn_count from i_user_name.user_synonyms t where t.owner=i_user_name and t.synonym_name=all_table.TABLE_NAME;
      begin
      execute immediate v_sql;
      execute immediate v_sql2;
      exception
        when others then
          v_error_message := '' || SQLERRM;
          dbms_output.put_line(v_sql||' '||v_error_message);
      end;
      begin
        v_drop_syn := 'drop synonym ' || i_user_name || '.' ||all_proc.object_name;
        --if v_syn_count=1 then
        execute immediate v_drop_syn;
        --end if;
      exception
        when others then
          v_error_message := '' || SQLERRM;
          dbms_output.put_line(v_error_message);
      end;

      begin
        execute immediate v_create_syn;
      exception
        when others then
          v_error_message := '' || SQLERRM;
          dbms_output.put_line(v_error_message);
      end;

    end loop;
end p_grant_procedure_privllege;

 procedure p_gather_state as
    v_suf_fix varchar2(200) := 'PICC_';
    v_sql     varchar2(2000) := '';
    v_date    varchar2(200) := '';
  begin
    select to_char(sysdate, 'mmddhh24mi') into v_date from dual;
    for c in (select * from tab_picclife_snap_view) loop
      v_suf_fix := 'PICC_' || v_date || c.name;
      v_sql     := 'create table ' || v_suf_fix || ' as select * from ' ||
                   c.name;
      execute immediate v_sql;
    end loop;
  end p_gather_state;

  procedure p_kill_session as
    v_sql         varchar2(2000);
    v_session_sql varchar2(2000);
    v_machine     varchar2(200);
    v_username    varchar2(200);
    v_osuser      varchar2(200);
    v_object      varchar2(200);
    v_rowid       varchar(200);
    v_wait varchar2(200);
  
  begin
    for c in (select l.CTIME, s.SID, s.SERIAL#
                From v$lock l, v$session s
               where s.SID = l.SID and l.CTIME >= 300 and l.TYPE = 'TX' and
                     l.BLOCK = 1
               group by s.sid, s.SERIAL#, l.CTIME) loop
      v_sql := 'alter system kill session ''' || c.sid || ',' || c.SERIAL# || '''';
      begin
        for c2 in (select l2.sid,l2.ctime
                     from v$lock l1, v$lock l2
                    where l1.sid = c.sid and l1.type = l2.type
                     and l2.id1 = l1.id1
                     and l2.sid!=l1.sid) loop
                     
             select sq.SQL_TEXT
            into v_session_sql
            From v$session s, v$sql sq
           where nvl(s.SQL_ADDRESS, s.PREV_SQL_ADDR) = sq.ADDRESS and
                 nvl(s.SQL_HASH_VALUE, s.PREV_HASH_VALUE) = sq.HASH_VALUE and
                 s.SID = c2.sid;
          select machine, USERNAME, osuser
            into v_machine, v_username, v_osuser
            from v$session
           where sid = c2.sid;
           
              select machine, USERNAME, osuser
          into v_machine, v_username, v_osuser
          from v$session
         where sid = c2.sid;
         
        select dbms_rowid.rowid_create(1,
                                       s.ROW_WAIT_OBJ#,
                                       s.ROW_WAIT_FILE#,
                                       s.ROW_WAIT_BLOCK#,
                                       s.ROW_WAIT_ROW#),
               o.object_name
          into v_rowid, v_object
          from v$session s, dba_objects o
         where sid = c2.sid and s.ROW_WAIT_OBJ# = o.object_id;
         
          p_mail('wanzhengyong@picclife.cn',
                 ' enqu blocked session ',
                 'sid=' || c2.sid || ' machine=' || v_machine ||
                 ' loginname=' || v_username || ' osuser=' || v_osuser ||
                 '   ' || v_session_sql ||'    ojbect='||v_object||' rowid='||v_rowid||' blocked time'||c2.ctime);
          --p_mail('wanzhengyong@picclife.cn','enqu blocked session ',v_session_sql);
        
        end loop;
      exception
        when others then
          null;
      end;
      begin
        select machine, USERNAME, osuser,w.EVENT
          into v_machine, v_username, v_osuser,v_wait
          from v$session s,v$session_wait w
         where s.sid = c.sid 
         and s.SID=w.SID;
        select dbms_rowid.rowid_create(1,
                                       s.ROW_WAIT_OBJ#,
                                       s.ROW_WAIT_FILE#,
                                       s.ROW_WAIT_BLOCK#,
                                       s.ROW_WAIT_ROW#),
               o.object_name
          into v_rowid, v_object
          from v$session s, dba_objects o
         where sid = c.sid and s.ROW_WAIT_OBJ# = o.object_id;
      exception
        when others then
          null;
      end;
    
      execute immediate v_sql;
      p_mail('wanzhengyong@picclife.cn',
             'kill blocking session ',
             'sid=' || c.sid || ' machine=' || v_machine || ' loginname=' ||
             v_username || ' osuser=' || v_osuser||' ojbect='||v_object||' rowid='||v_rowid||' wait='||v_wait||' locked time'||c.ctime);
    
    end loop;
  end p_kill_session;


  procedure p_monitor_session_wait as
    v_count number(4) := 0;
  begin
    select count(*)
      into v_count
      from v$session_wait
     where event not like '%SQL%';
    if v_count > 50 then
      p_mail('wanzhengyong@picclife.cn',
             'alert more session_wait session count ' || v_count,
             'alert more session_wait');
    
    end if;
  end p_monitor_session_wait;


end pkg_picclife_maintain;
/

--生产环境数据库监控

create user monitor identified by mon_ftp123 default tablespace sysaux;
grant connect,resource ,dba,select_catalog_role to monitor;
--20061205 

--每周二收集数据库统计参数

login in 10.64.1.30


sqlpljus '/as sysdba'

var job number;

create or replace procedure p_gather_db_stats
as
begin
dbms_stats.gather_database_stats(degree => 8);
end p_gather_db_stats;
/


declare
begin
  sys.dbms_job.submit(job => :job,
                      what => 'p_gather_db_stats;',
                      next_date => to_date('2006-12-05 03','yyyy-mm-dd hh24'),
                      interval => 'trunc(sysdate+7)+(3/24)' );
  commit;
end;
/



declare
begin
  sys.dbms_job.submit(job => :job,what => 'pkg_picclife_maintain.p_mail_log_daily;',next_date => to_date('2006-12-09 04','yyyy-mm-dd hh24'),interval => 'trunc(sysdate+1)+(4/24)' );
  end;
/



--sys用户
declare
begin
  sys.dbms_job.submit(job => :job,what => 'pkg_picclife_maintain.p_monitor_space;',next_date => to_date('2006-12-09 05','yyyy-mm-dd hh24'),interval => 'trunc(sysdate+1)+(5/24)' );
  end;
/

declare
begin
  sys.dbms_job.submit(job => :job,what => 'pkg_picclife_maintain.p_monitor_dataguard;',next_date => sysdate,interval => 'sysdate+10/1440' );
  end;
/



declare
v_sql varchar2(1000);
job_id number;
begin
v_sql:='declare
  v_to_system      varchar2(100);
  v_sync_version   number;
  v_is_success     varchar2(100);
  v_return_code    number;
  v_return_message varchar2(4000);
begin
  pkg_sync_recon.p_recon(''HAS'', v_return_code, v_return_message);
  if v_return_code = 1 then
    pkg_sync_rds_to_has.p_dml_main(v_to_system,
                                      v_sync_version,
                                      v_is_success,
                                      v_return_code,
                                      v_return_message);
  dbms_output.put_line(v_to_system);
    if v_return_code = 0 then
    null;
   dbms_output.put_line(v_return_message);
    end if;
  else
    dbms_output.put_line(v_return_message);
  end if;
end;' ;
sys.dbms_job.submit(job => job_id,
                      what =>v_sql,
                      next_date => sysdate + 1 ,
                      interval => 'trunc(sysdate) + 1 + 3/24');
                      

end;
/ 

if get ORA-29275 error when execute sql
then TO_single_BYTE(sql_text)

In Oracle versions up to and including 9.2.0.4, the size of the PL/SQL cursor 
cache was controlled by the parameter OPEN_CURSORS

In 9.2.0.5 and Oracle 10g, the parameter controlling the size of the PL/SQL 
cursor cache was changed to SESSION_CACHED_CURSORS which already controlled 
the session cursor cache.

ORA-04031 error and Large Pool



jdbc and tfa
in weblogic 
config 

 <JDBCConnectionPool DriverName="oracle.jdbc.OracleDriver"
        InitialCapacity="10" Name="MyPool"
        PasswordEncrypted="{3DES}QugSmxDRtHc=" Properties="user=system"
        Targets="myserver" TestTableName="SQL SELECT 1 FROM DUAL" URL="jdbc:oracle:thin:@(DESCRIPTION =      (ADDRESS_LIST =
    (load_balance = on)    (failover = on)          (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.0.120)(PORT = 1521))         (ADD
RESS = (PROTOCOL = TCP)(HOST = 10.0.0.121)(PORT = 1521))      )          (CONNECT_DATA =         (SERVICE_NAME = rac)
     )        )"/>
     
all 10 connection connect to rac01
when down rac01,restart weblogic ,all connection conn to rac02

config 	Test Frequency: =5s
the connection can auto failover.

but load balance is not even.
或者通过weblogic multipool来解决 能够even load




If you do not use Loadbalance, preconnect ,etc. in the tnsnames.ora service entries, it will not failover/loadbalance automatically just because it is a RAC environment.

Inactive sessions will not failover. Only active sessions failover when the node it was connected to is down





The OPatch scripts are idempotent, that is running the scripts once will have the same effect as running them many times. You can therefore rerun the script if the initial run is interrupted. However, a partially installed interim patch cannot be removed - the patch process must finish successfully first.

or if you are on a Unix system you can use the supplied wrapper script. In order to use the wrapper script you must set ORACLE_HOME appropriately for your operating system, as the wrapper script will use the version of perl installed in that ORACLE_HOME. You use the wrapper script to invoke OPatch as follows:
opatch The –force option should be used with care. If a conflict exists which prevents the patch from being applied, it will remove any conflicting patches before installing the current patch. This argument is needed however if you are reinstalling the current patch.



aix上面 9.2.0.6有如下两个bug
4081980
Oracle Bug 4081980: AFTER APPLYING THE 9206 PATCHSET YOU CAN NO LONGER CREATE A DATABASE
4074633P+ 	AIX5L: Higher CPU usage in RAC background processes in 9.2.0.6
需要安装9207


如果发生 ora-12638

Solution Description
--------------------

- On the client side, edit sqlnet.ora (O_H\network\ADMIN)
- Replace sqlnet.authentication_services = (NTS) 
  with
          sqlnet.authentication_services = (BEQ,NONE)
  
Also, verify the Ora_User goup settings..

Additional Search Words
-----------------------
ORA-12638 SQLNET.ORA SQL*PLUS



TNS-12516 listerer认为连接已经达到最大，但是pmon没有及时更新信息，加大process和session

如果数据库shutdown abort，那么重起后 日志会前移一个。
如果正常的shutdown ，日志不会前移

通过如下控制文件
LOAD DATA
infile all.log
append
into table wanzy_web_log
FIELDS TERMINATED BY " "
(ip TERMINATED BY WHITESPACE,run_time TERMINATED BY WHITESPACE,d1 TERMINATED BY WHITESPACE,d2 TERMIN
ATED BY WHITESPACE,access_time POSITION(*+1) date(22) "dd/Mon/yyyy:hh24:mi:ss" TERMINATED BY WHITESP
ACE ,url POSITION(*+8) char(4000) TERMINATED BY  '"'  ,return_code TERMINATED BY WHITESPACE)

导数据
如下
10.2.34.174 0  - - [17/May/2005:16:39:05 +0800] "POST /life/servlet/com.ebao.life.newbiz.appentry.indv.AppEntryServlet HTTP/1.1" 200 12752
sqlldr 方式下 对应字段位clob 


sqlldr taipinglife2iastest/ftp123@tpl8 control=control.ctl  errors=100000  direct=y data=/tmp/all_access_log_2005-05-18.log



Total logical records skipped:          0
Total logical records read:         74045
Total logical records rejected:       268
Total logical records discarded:        0

Run began on Wed May 18 15:47:56 2005
Run ended on Wed May 18 15:49:09 2005

Elapsed time was:     00:01:13.35
CPU time was:         00:00:04.53


bind方式

Bind array size not used in direct path. 
Column array  rows :    5000
Stream buffer bytes:  256000
Read   buffer bytes: 1048576

Total logical records skipped:          0
Total logical records read:         74045
Total logical records rejected:       268
Total logical records discarded:        0
Total stream buffers loaded by SQL*Loader main thread:       18
Total stream buffers loaded by SQL*Loader load thread:       41

Run began on Wed May 18 15:55:54 2005
Run ended on Wed May 18 15:55:58 2005

Elapsed time was:     00:00:03.95
CPU time was:         00:00:00.94

sqlldr 方式下 对应字段位 varchar2(4000)

Space allocated for bind array:                 100608 bytes(64 rows)
Read   buffer bytes: 1048576

Total logical records skipped:          0
Total logical records read:         74045
Total logical records rejected:       268
Total logical records discarded:        0

Run began on Wed May 18 15:57:08 2005
Run ended on Wed May 18 15:57:15 2005

Elapsed time was:     00:00:07.37
CPU time was:         00:00:00.71


bind方式

Bind array size not used in direct path.
Column array  rows :    5000
Stream buffer bytes:  256000
Read   buffer bytes: 1048576

Total logical records skipped:          0
Total logical records read:         74045
Total logical records rejected:       268
Total logical records discarded:        0
Total stream buffers loaded by SQL*Loader main thread:       18
Total stream buffers loaded by SQL*Loader load thread:       23

Run began on Wed May 18 15:57:54 2005
Run ended on Wed May 18 15:57:56 2005

Elapsed time was:     00:00:01.71
CPU time was:         00:00:00.78


"Table Fetch Continued row" increases with each full table scan (fts) if chained rows exist in a table.
 This can be a bit misleading on the surface. For instance if a row spans, say, 4 blocks,
  the "Table Fetch Continued row" will be incremented by 3 whenever (the last column in)
   that row is fetched via an fts. 
   
   
   table fetch by rowid" is the number of rows that are fetched using a ROWID 
   (usually recovered from an index). So that can be a good indicator that your 
   indexes are being used/ as opposed to not used.

通过修改 /etc/security/limits 文件，放开对某个用户的ram限制

9i中如果打开workarea_size_policy=auto，那么一个sql
能用到(max)5%（serial)3(max)0%/DOP(parallel)的sort area size。 同时sort_area_size不起作用。


The maximum of used memory can be controlled using the hidden parameter
 "_smm_max_size" parameter which defines how many kilobytes a serial session can use for its workarea operations (as mentioned the default is 5% ). The other hidden parameter "_smm_px_max_size" controls max workarea for parallel slaves (as mentioned the default is 30% from pga_aggregate_target). These parameters have no effect when set at session level - so alter system has to be used for setting them. 


If you have WORKAREA_SIZE_POLICY set to AUTO, the SORT_AREA_SIZE parameter is not used/ignored. Instead the work area is based on the PGA memory used by the system, the target PGA memory set in PGA_AGGREGATE_TARGET, and the requirement of each individual operator. You can specify AUTO only when PGA_AGGREGATE_TARGET is defined. 

可以通过native dynamic sql来加快执行动态sql （比dbms_sql快）

可以通过 加快执行速度
 FORALL i IN depts.FIRST..depts.LAST
UPDATE emp SET sal = sal * 1.10 WHERE deptno = depts(i);

可以通过nocopy方式来传参数加快速度
DECLARE
TYPE Platoon IS VARRAY(200) OF Soldier;
PROCEDURE reorganize (my_unit IN OUT NOCOPY Platoon) IS ...
BEGIN
...
END;

可以把pl/sql部分消耗cpu资源(非数据处理的）放到c上面去做，或者编译为native


sqlj 相当于在java中直接写sql，通过这种方式来编译，解释，象pro c(是标准)

当sql正在执行的时候，他的执行次数就已经加上去了，但是disk 和buffer还是0，执行结束后在写disk和buffer.


备份 Retention Policy 7 days,需要3个全备，如果6 days,需要两个2全备


核心系统备份 全备 一次 50G，增量一次48G（12/27）11g(28)   13g(12/29)   6g            

axi ps v 和svmon 关系

SIZE = 4 * Pgspace of (work lib data + work private)
RSS = 4 * Inuse of (work lib data + work private + pers code) 11+42+
TRS = 4 * Inuse of (pers code)5657+




每个oracle连接进程 消耗 19m(财务)26M(核心)(program)	其它消耗8m(财务)核心6M

I have to disagree w/ Bill here. There is _db_block_hash_buckets
and _db_block_hash_latches. _db_block_hash_buckets represents the
number of different cache buffers chains that buffers in the cache
will hash to. In 8i, it defaults to 2 * db_block_buffers. That's
intended to keep all the individual chains short.
_db_block_hash_latches, on the other hand, defaults according to the
following bit of pseudo-code:
if(db_block_buffers < 2052) then
_db_block_hash_latches = 2^(trunc(log(2,db_block_buffers-4)-1);
else if(db_block_buffers > 131075) then
_db_block_hash_latches = 2^trunc(log(2,db_block_buffers-4)-6);
else
_db_block_hash_latches = 1024;
end if;




通过java的
java.sql.ResultSet rs=st.executeQuery("select * from test_wzy"); 
不行?
preparestatement 也不行...


library cache lock 在parse create 的时候需要exclusive，执行的时候需要share，执行完后需要null。
library cache pin 在 parse 时候需要exclusive，其他时候 share即可。
library cache(latch)在查找sqlarea的sql时候需要，需要 library cache lock的时候，需要先library cache。
shared pool(latch)再分配(shared pool)时候需要，需要查找free chunks，大量的小的free chunks导致竞争严重。


通过pl/sql的cursor可以实现parse一次，多次执行的效果。
在sqlplus里面执行sql，可以做到soft parse，虽然cursor一直打开，但是不能做到没有soft parse。但是通过procedure可以做到。



pl/sql执行效率非常高，特别是对单个sql修改多条记录的情况下，修改为pl/sql效率提高无数

cursor parse步骤
SESSION_CACHED_CURSORS 参数比较有效果。
In reference to SESSION_CACHED_CURSORS causing shared pool fragmentation. 
Actually, what is stored in the PGA is a cache of references to cursors which themselves are in the Library Cache.
 There are documents you might have read concerning fragmentation can be caused if the parameter is set "too high".
(i.e. Note: 30804.1) 

可以通过
v$sesstat 的session cursor cache hits查询hit rate.
1.是否open? no parse
2.是否在session cache中？ no parse
3.打开cursor ,如果shareable,softparse
4.hard parse.

alter system flush shared_pool; 
会导致缓存的SEQUENCE 全部丢失。


如何比较两张表的数据


declare 
begin
for a in(select * from T_PRODUCT_LIFE  ) loop 
for b in (select *From T_PRODUCT_LIFE_2 )loop
if a.product_id =b.product_id then
--通过脚本生成
select 'if a.'||COLUMN_NAME||'!=b.'||COLUMN_NAME||' then '
||'dbms_output.put_line(''product_id=''||a.product_id  '
||'||''  a.'||COLUMN_NAME||'=''||a.'||COLUMN_NAME||' ' 
||'||''  b.'||COLUMN_NAME||'=''||b.'||COLUMN_NAME||' ); '
||'end if;' 
from user_tab_columns  t where t.table_name='T_PRODUCT_LIFE' and COLUMN_NAME!='PRODUCT_ID'


end if;
end loop;
end loop;
end;






当执行 alter system archive log all; 的时候，会通过smon派生多个进程来进行归档，而不是通过arch进程归档。


每3s起来一次

PMON will only rollback a certain number of transactions for a given connection. This number is determined by the 
CLEANUP_ROLLBACK_ENTRIES parameter in the INIT.ORA file

可以通过oradebug wakeup {v$process.pid of pmon),来人工唤醒
Actually, (by tracing PMON), I have discovered that it only checks 
for dead processes once every 20 wakeups, or once per minute. 
If you strace/truss/whatever on your pmon process, you'll see that 
every 20th wakeup, it does a kill(pid,0) on each and every Oracle 
background process and all the server processes, which checks for 
process existance. You can also observe that if you wakeup pmon, it 
will immediately do the process check. 

smon每5分钟出来活动一次，可以通过oradebug直接wakeup



x$ksmmem 可以存取所有的sga
x$ksmfsv  代表系统所有的变量 其中 ksmsgf_ 表示sga起始地址

我得系统 _max_exponential_sleep 居然为零？ 那就意味着不会超时，一直等待下去。。





生产系统问题
10.1.3.20 listener工作不正常。
如果listener.ora配置中用hostname，则先解析/etc/hosts文件，工作正常
如果listener.ora配置中用ip，如果resolv.conf有配置，会通过dns server解析，，导致工作不正常
aix中可以通过
/etc/netsvc.conf设置解析顺序。如果设置hosts优先，则listener.ora配置中用ip也正常。

linux 做dns和windows不一样，导致发现该问题。



Tools

ORADEBUG

ORADEBUG is an undocumented debugging utility supplied with Oracle

For more general information see ORADEBUG introduction

In Oracle 9.2 commands include

	
HELP
SETMYPID
SETORAPID
SETOSPID
TRACEFILE_NAME
UNLIMIT
FLUSH
CLOSE_TRACE
SUSPEND
RESUME
WAKEUP
DUMPLIST
DUMP
EVENT
SESSION_EVENT
DUMPSGA
DUMPVAR
PEEK
POKE
IPC
Dumping the SGA
HELP command

The ORADEBUG HELP command lists the commands available within ORADEBUG

These vary by release and platform. Commands appearing in this help do not necessarily work for the release/platform on which the database is running

For example in Oracle 9.2.0.1 (Windows 2000) the command

  ORADEBUG HELP

returns the following

Command 	Arguments 	Description
HELP 	[command] 	Describe one or all commands
SETMYPID 	  	Debug current process
SETOSPID 	&ltospid> 	Set OS pid of process to debug
SETORAPID 	&ltorapid> ['force'] 	Set Oracle pid of process to debug
DUMP 	&ltdump_name> &ltlvl> [addr] 	Invoke named dump
DUMPSGA 	[bytes] 	Dump fixed SGA
DUMPLIST 	  	Print a list of available dumps
EVENT 	&lttext> 	Set trace event in process
SESSION_EVENT 	&lttext> 	Set trace event in session
DUMPVAR 	&ltp|s|uga> &ltname> [level] 	Print/dump a fixed PGA/SGA/UGA variable
SETVAR 	&ltp|s|uga> &ltname> &ltvalue> 	Modify a fixed PGA/SGA/UGA variable
PEEK 	&ltaddr> &ltlen> [level] 	Print/Dump memory
POKE 	&ltaddr> &ltlen> &ltvalue> 	Modify memory
WAKEUP 	&ltorapid> 	Wake up Oracle process
SUSPEND 	  	Suspend execution
RESUME 	  	Resume execution
FLUSH 	  	Flush pending writes to trace file
CLOSE_TRACE 	  	Close trace file
TRACEFILE_NAME 	  	Get name of trace file
LKDEBUG 	  	Invoke global enqueue service debugger
NSDBX 	  	Invoke CGS name-service debugger
-G 	&ltInst-List | def | all> 	Parallel oradebug command prefix
-R 	&ltInst-List | def | all> 	Parallel oradebug prefix (return output)
SETINST 	&ltinstance# .. | all> 	Set instance list in double quotes
SGATOFILE 	&ltSGA dump dir> 	Dump SGA to file; dirname in double quotes
DMPCOWSGA 	&ltSGA dump dir> 	Dump & map SGA as COW; dirname in double quotes
MAPCOWSGA 	&ltSGA dump dir> 	Map SGA as COW; dirname in double quotes
HANGANALYZE 	[level] 	Analyze system hang
FFBEGIN 	  	Flash Freeze the Instance
FFDEREGISTER 	  	FF deregister instance from cluster
FFTERMINST 	  	Call exit and terminate instance
FFRESUMEINST 	  	Resume the flash frozen instance
FFSTATUS 	  	Flash freeze status of instance
SKDSTTPCS 	&ltifname> &ltofname> 	Helps translate PCs to names
WATCH 	&ltaddress> &ltlen> &ltself|exist|all|target> 	Watch a region of memory
DELETE 	&ltlocal|global|target> watchpoint &ltid> 	Delete a watchpoint
SHOW 	&ltlocal|global|target> watchpoints 	Show watchpoints
CORE 	  	Dump core without crashing process
UNLIMIT 	  	Unlimit the size of the trace file
PROCSTAT 	  	Dump process statistics
CALL 	&ltfunc> [arg1] ... [argn] 	Invoke function with arguments

SETMYPID command

Before using ORADEBUG commands, a process must be selected. Depending on the commands to be issued, this can either be the current process or another process

Once a process has been selected, this will be used as the ORADEBUG process until another process is selected

The SETMYPID command selects the current process as the ORADEBUG process

For example

  ORADEBUG SETMYPID

ORADEBUG SETMYPID can be used to select the current process to run systemwide commands such as dumps

Do not use ORADEBUG SETMYPID if you intend to use the ORADEBUG SUSPEND command
SETORAPID command

Before using ORADEBUG commands, a process must be selected. Depending on the commands to be issued, this can either be the current process or another process

Once a process has been selected, this will be used as the ORADEBUG process until another process is selected

The SETORAPID command selects another process using the Oracle PID as the ORADEBUG process

The syntax is

  ORADEBUG SETORAPID pid

where pid is the Oracle process ID of the target process For example

  ORADEBUG SETORAPID 9

The Oracle process id for a process can be found in V$PROCESS.PID

To obtain the Oracle process ID for a foreground process use

  SELECT pid FROM v$process 
  WHERE addr =
  (
    SELECT paddr FROM v$session
    WHERE sid = DBMS_SUPPORT.MYSID
  );

Alternatively, if the DBMS_SUPPORT package is not available use

  SELECT pid FROM v$process 
  WHERE addr =
  (
    SELECT paddr FROM v$session
    WHERE sid = 
    (
      SELECT sid FROM v$mystat WHERE ROWNUM = 1
    )
  );

To obtain the process ID for a background process e.g. SMON use

  SELECT pid FROM v$process 
  WHERE addr =
  (
    SELECT paddr FROM v$bgprocess
    WHERE name = 'SMON'
  );

To obtain the process ID for a dispatcher process e.g. D000 use

  SELECT pid FROM v$process 
  WHERE addr =
  (
    SELECT paddr FROM v$dispatcher
    WHERE name = 'D000'
  );

To obtain the process ID for a shared server process e.g. S000 use

  SELECT pid FROM v$process 
  WHERE addr =
  (
    SELECT paddr FROM v$shared_server
    WHERE name = 'S000'
  );

To obtain the process ID for a job queue process e.g. job 21 use

  SELECT pid FROM v$process 
  WHERE addr =
  (
    SELECT paddr FROM v$session
    WHERE sid = 
    (
      SELECT sid FROM dba_jobs_running WHERE job = 21
    )
  );

To obtain the process ID for a parallel execution slave e.g. P000 use

  SELECT pid FROM v$px_process 
  WHERE server_name = 'P000';

SETOSPID command

Before using ORADEBUG commands, a process must be selected. Depending on the commands to be issued, this can either be the current process or another process

Once a process has been selected, this will be used as the ORADEBUG process until another process is selected

The SETOSPID command selects the another process using the operating system PID as the ORADEBUG process

The syntax is

  ORADEBUG SETOSPID pid

where pid is the operating system process ID of the target process For example

  ORADEBUG SETOSPID 34345

The operating system process ID is the PID on Unix systems and the thread number on Windows NT/2000 systems

On Unix the PID of interest may have been identified using a top or ps command
TRACEFILE_NAME command

This command prints the name of the current trace file e.g.

    ORADEBUG TRACEFILE_NAME

For example

    /export/home/admin/SS92003/udump/ss92003_ora_14917.trc

This command does not work on Windows 2000 (Oracle 9.2)
UNLIMIT command

In Oracle 8.1.5 and below the maximum size of the trace file is restricted by default. This means that large dumps (LIBRARY_CACHE, BUFFERS) may fail.

To remove the limitation on the size of the trace file use

    ORADEBUG UNLIMIT

In Oracle 8.1.6 and above the maximum size of the trace file defaults to UNLIMITED
FLUSH command

To flush the current contents of the trace buffer to the trace file use

    ORADEBUG FLUSH

CLOSE_TRACE command

To close the current trace file use

    ORADEBUG CLOSE_TRACE

SUSPEND command

This command suspends the current process

First select a process using SETORAPID or SETOSPID

Do not use SETMYPID as the current ORADEBUG process will hang and cannot be resumed even from another ORADEBUG process

For example the command

  ORADEBUG SUSPEND

suspends the current process

The command

  ORADEBUG RESUME

resumes the current process

While the process is suspended ORADEBUG can be used to take dumps of the current process state e.g. global area, heap, subheaps etc.

This example demonstrates how to take a heap dump during a large (sorting) query

This example requires two sessions, session 1 logged on SYS AS SYSDBA and session 2 which executes the query. In session 2 identify the PID using

    SELECT pid FROM v$process
    WHERE addr IN
    (
        SELECT paddr FROM v$session
        WHERE sid = dbms_support.mysid
    );

In this example the PID was 12

In session 1 set the Oracle PID using

    ORADEBUG SETORAPID 12

In session 2 start the query

    SELECT ... FROM t1 ORDER BY ....

In session 1 suspend session 2

    ORADEBUG SUSPEND

The query in session 2 will be suspended

In session 1 run the heap dump

    ORADEBUG DUMP HEAPDUMP 1

The heapdump will show the memory structures allocated for the sort. At this point further dumps e.g. subheap dumps can be taken.

In session 1 resume session 2

    ORADEBUG RESUME

The query in session 2 will resume execution
RESUME command

This command resumes the current process

First select a process using SETORAPID or SETOSPID

Do not use SETMYPID as the current ORADEBUG process will hang and cannot be resumed even from another ORADEBUG process

For example the command

  ORADEBUG SUSPEND

suspends the current process

The command

  ORADEBUG RESUME

resumes the current process

While the process is suspended ORADEBUG can be used to take dumps of the current process state e.g. global area, heap, subheaps etc.

See SUSPEND for an example of use of the SUSPEND and RESUME commands
WAKEUP command

To wake up a process use

    ORADEBUG WAKEUP pid

For example to wake up SMON, first obtain the PID using

    SELECT pid FROM v$process
    WHERE addr = 
    (
        SELECT paddr FROM v$bgprocess
        WHERE name = 'SMON'
    );

If the PID is 6 then send a wakeup call using

    ORADEBUG WAKEUP 6

DUMPLIST command

To list the dumps available in ORADEBUG use

    ORADEBUG DUMPLIST pid

For example in Oracle 9.2 (Windows 2000) this command returns the following

	
Dump Name
EVENTS
TRACE_BUFFER_ON
TRACE_BUFFER_OFF
HANGANALYZE
LATCHES
PROCESSSTATE
SYSTEMSTATE
INSTANTIATIONSTATE
REFRESH_OS_STATS
CROSSIC
CONTEXTAREA
HEAPDUMP
HEAPDUMP_ADDR
POKE_ADDRESS
POKE_LENGTH
POKE_VALUE
POKE_VALUE0
GLOBAL_AREA
MEMORY_LOG
REALFREEDUMP
ERRORSTACK
HANGANALYZE_PROC
TEST_STACK_DUMP
BG_MESSAGES
ENQUEUES
SIMULATE_EOV
KSFQP_LIMIT
KSKDUMPTRACE
DBSCHEDULER
GRANULELIST
GRANULELISTCHK
SCOREBOARD
GES_STATE
ADJUST_SCN
NEXT_SCN_WRAP
CONTROLF
FULL_DUMPS
BUFFERS
RECOVERY
SET_TSN_P1
BUFFER
PIN_BUFFER
BC_SANITY_CHECK
FLUSH_CACHE
LOGHIST
ARCHIVE_ERROR
REDOHDR
LOGERROR
OPEN_FILES
DATA_ERR_ON
DATA_ERR_OFF
BLK0_FMTCHG
TR_SET_BLOCK
TR_SET_ALL_BLOCKS
TR_SET_SIDE
TR_CRASH_AFTER_WRITE
TR_READ_ONE_SIDE
TR_CORRUPT_ONE_SIDE
TR_RESET_NORMAL
TEST_DB_ROBUSTNESS
LOCKS
GC_ELEMENTS
FILE_HDRS
KRB_CORRUPT_INTERVAL
KRB_CORRUPT_SIZE
KRB_PIECE_FAIL
KRB_OPTIONS
KRB_SIMULATE_NODE_AFFINITY
KRB_TRACE
KRB_BSET_DAYS
DROP_SEGMENTS
TREEDUMP
LONGF_CREATE
ROW_CACHE
LIBRARY_CACHE
SHARED_SERVER_STATE
KXFPCLEARSTATS
KXFPDUMPTRACE
KXFPBLATCHTEST
KXFXSLAVESTATE
KXFXCURSORSTATE
WORKAREATAB_DUMP
OBJECT_CACHE
SAVEPOINTS
OLAP_DUMP
DUMP command

To perform a dump use

    ORADEBUG DUMP dumpname level

For example for a level 4 dump of the library cache use

    ORADEBUG SETMYPID
    ORADEBUG DUMP LIBRARY_CACHE 4

EVENT command

To set an event in a process use

    ORADEBUG EVENT event TRACE NAME CONTEXT FOREVER, LEVEL level

For example to set event 10046, level 12 in Oracle process 8 use

    ORADEBUG SETORAPID 8
    ORADEBUG EVENT 10046 TRACE NAME CONTEXT FOREVER, LEVEL 12

SESSION_EVENT command

To set an event in a session use

    ORADEBUG SESSION_EVENT event TRACE NAME CONTEXT FOREVER, LEVEL level

For example

    ORADEBUG SESSION_EVENT 10046 TRACE NAME CONTEXT FOREVER, LEVEL 12

DUMPSGA

To dump the fixed SGA use

    ORADEBUG DUMPSGA

DUMPVAR

To dump an SGA variable use

    ORADEBUG DUMPVAR SGA variable_name

e.g.

    ORADEBUG DUMPVAR SGA kcbnhb

which returns the number of hash buckets in the buffer cache

The names of SGA variables can be found in X$KSMFSV.KSMFSNAM. Variables in this view are suffixed with an underscore e.g.

    kcbnhb_

PEEK

To peek memory locations use

    ORADEBUG PEEK address length

where address can be decimal or hexadecimal and length is in bytes

For example

    ORADEBUG PEEK 0x20005F0C 12

returns 12 bytes starting at location 0x20005f0c
POKE

To poke memory locations use

    ORADEBUG POKE address length value

where address and value can be decimal or hexadecimal and length is in bytes

For Example

    ORADEBUG POKE 0x20005F0C 4 0x46495845
    ORADEBUG POKE 0x20005F10 4 0x44205349
    ORADEBUG POKE 0x20005F14 2 0x5A45

WARNING Do not use the POKE command on a production system
IPC

To dump information about operating system shared memory and semaphores configuration use the command

    ORADEBUG IPC

This command does not work on Windows NT or Windows 2000 (Oracle 9.2)

On Solaris, similar information can be obtained using the operating system command

    ipcs -b

Dumping the SGA

In some versions it is possible to dump the entire SGA to a file

Freeze the instance using

    ORADEBUG FFBEGIN

Dump the SGA to a file using

    ORADEBUG SGATOFILE directory

Unfreeze the instance using

    ORADEBUG FFRESUMEINST

This works in Oracle 9.0.1 and 9.2.0 on Solaris, but fails in both versions in Windows 2000 




Introduction
Enabling Events
Listing All Events
Listing Enabled Events
Event Reference
Introduction

There are four types of numeric events

    * Immediate dumps
    * Conditional dumps
    * Trace dumps
    * Events that change database behaviour

Every event has a number which is in the Oracle error message range e.g. event 10046 is ORA-10046

Each event has one or more levels which can be

    * range e.g. 1 to 10
    * bitmask e.g. 0x01 0x02 0x04 0x08 0x10
    * flag e.g. 0=off; 1=on
    * identifier e.g. object id, memory address etc

Note that events change from one release to another. As existing events become deprecated and then obsolete, the event number is frequently reused for a new event. Note also that the message file sometimes does not reflect the events in the current release.

Many events change the behaviour of the database. Some testing events may cause the database to crash. Never set an event on a production database without obtaining permission from Oracle support. In addition, never set an event on a development database without first making a backup.
Enabling Events

Events can be enabled at instance level in the init.ora file using

    event='event trace name context forever, level level';

Multiple events can be enabled in one of two ways

1 - Use a colon to separate the event text e.g.

    event = "10248 trace name context forever, level 10:10249 trace name context forever, level 10"

2 - List events on consecutive lines e.g.

    event = "10248 trace name context forever, level 10"
    event = "10249 trace name context forever, level 10"

Note that in some versions of Oracle, the keyword "event" must be in the same case (i.e. always uppercase or always lowercase).

Events can also be enabled at instance level using the ALTER SYSTEM command

    ALTER SYSTEM SET EVENTS
    'event trace name context forever, level level';

Events are disabled at instance level using

    ALTER SYSTEM SET EVENTS
    'event trace name context off';

Events can also be enabled at session level using the ALTER SESSION command

    ALTER SESSION SET EVENTS
    'event trace name context forever, level level';

Events are disabled at session level using

    ALTER SESSION SET EVENTS
    'event trace name context off';

Events can be enabled in other sessions using ORADEBUG

To enable an event in a process use

    ORADEBUG EVENT event TRACE NAME CONTEXT FOREVER, LEVEL level

For example to set event 10046, level 12 in Oracle process 8 use

    ORADEBUG SETORAPID 8
    ORADEBUG EVENT 10046 TRACE NAME CONTEXT FOREVER, LEVEL 12

To disable an event in a process use

    ORADEBUG EVENT event TRACE NAME CONTEXT OFF

To enable an event in a session use

    ORADEBUG SESSION_EVENT event TRACE NAME CONTEXT FOREVER, LEVEL level

For example

    ORADEBUG SESSION_EVENT 10046 TRACE NAME CONTEXT FOREVER, LEVEL 12

To disable an event in a session use

    ORADEBUG SESSION_EVENT event TRACE NAME CONTEXT OFF

Events can be also enabled in other sessions using DBMS_SYSTEM.SETEV

The SID and the serial number of the target session must be obtained from V$SESSION.

For example to enable event 10046 level 8 in a session with SID 9 and serial number 29 use

    EXECUTE dbms_system.set_ev (9,29,10046,8,'');

To disable event 10046 in the same session use

    EXECUTE dbms_system.set_ev (9,29,10046,0,'');

Listing All Events

Most events are numbered in the range 10000 to 10999. To dump all event messages in this range use

    SET SERVEROUTPUT ON
    
    DECLARE 
      err_msg VARCHAR2(120);
    BEGIN
      dbms_output.enable (1000000);
      FOR err_num IN 10000..10999
      LOOP
        err_msg := SQLERRM (-err_num);
        IF err_msg NOT LIKE '%Message '||err_num||' not found%' THEN
          dbms_output.put_line (err_msg);
        END IF;
      END LOOP;
    END;
    /

On Unix systems event messages are in the formatted text file

    $ORACLE_HOME/rdbms/mesg/oraus.msg

To print detailed event messages (Unix only) use the following script

    event=10000
    while [ $event -ne 10999 ]
    do
        event=`expr $event + 1`
        oerr ora $event
    done

Listing Enabled Events

To check which events are enabled in the current session

    SET SERVEROUTPUT ON
    DECLARE
        l_level NUMBER;
    BEGIN
        FOR l_event IN 10000..10999
        LOOP
            dbms_system.read_ev (l_event,l_level);
            IF l_level > 0 THEN
                dbms_output.put_line ('Event '||TO_CHAR (l_event)||
                ' is set at level '||TO_CHAR (l_level));
            END IF;
        END LOOP;
    END;
    /




Flushing the buffer cache

In Oracle 9.0.1 and above the following command can be used to flush the buffer cache.

    ALTER SESSION SET EVENTS 'immediate trace name flush_cache';


http://www.juliandyke.com/
http://www.ixora.com.au/


如果rac环境
最好采用assm


每16个block(2 extends )一个level bmb

在aum方式下，undo segment最多
max(1.1*sessions,30)


The possible values of X$BH.STATE are:

        0, FREE, no valid block image
        1, XCUR, a current mode block, exclusive to this instance
        2, SCUR, a current mode block, shared with other instances
        3, CR,   a consistent read (stale) block image
        4, READ, buffer is reserved for a block being read from disk
        5, MREC, a block in media recovery mode
        6, IREC, a block in instance (crash) recovery mode

x$bh.class
0 specail case-can mean system rollback segment
1 data block
2 sort block
3 save undo 
4 segment header block
5 save undo segment header block
6 free list block
7+(n*2) undo segment header block 
8+(n*2) undo segment block 

It is normative to have no FREE buffers. FREE buffers are always moved immediately to the tail of the auxiliary replacement list from where they will be reused before any other buffer is aged out. You may see some free buffers shortly after instance startup, or shortly dropping or truncating a segment or putting a tablespace offline that had some buffers in cache, but those free buffer should be re-used very quickly unless the instance is idle.

The query that you have used is misleading. The LRBA_SEQ (low redo block address sequence number) is normally only non-zero for dirty blocks. So the query is effectively counting dirty blocks and CR blocks together as being used, and clean current mode blocks as being available. However, clean blocks may nevertheless be pinned and CR blocks will in general not be. You could fix the query by using the low-order bit of the FLAG field to determine which blocks are dirty and the MODE_HELD column to determine which blocks are pinned, but the information you get will be of very little utility.

	When I query the X$BH table's state field, I get 0, 1, or 3. What do these values mean? And in the query

select
  decode(state,
  0, 'FREE',
  1, decode(lrba_seq, 0, 'AVAILABLE', 'BEING USED'),
  3, 'BEING USED',
  state) "BLOCK STATUS",
  count(*)
from x$bh
group by
  decode(state,
  0, 'FREE',
  1, decode(lrba_seq, 0, 'AVAILABLE', 'BEING USED'),
  3, 'BEING USED',
  state);

BLOCK STATUS                              COUNT(*)
---------------------------------------- ---------
AVAILABLE                                     3928
BEING USED                                      72

You see I do not have FREE blocks. Is it a problem?




oracle dsi心得

源程序都在tao上
event主要有如下几类
immediate dump(controlf,redohdr,file_hdrs,systemstate,processstate) alter session set events 'immediate trace name processstate level 10';  oradebug dump processdump 10
on_error dump  alter session set events '60 trace name errorstack level 10';  oradebug event 10012 trace name context level 1
change behavior  alter session set events '10269 trace name context forever, level 10';   主要在init设置          
trace           alter session set events '10046 trace name context forever, level 12';             
                alter session set events '10046 trace name context off';            
event 设置办法
设置方法
alter session 'event_name action:event_name action';
alter system 'event_name action:event_name action';
action=action_keyword,qualifier,qualifier
action_keyword  crash  cause an oracle crash for testting recover 
                debugger invoke a system debugger if any
                trace    is context specfic or named context_independent ones
                
event trace name trace_name qualifier,qualifier

当错误发生的时候，做hanganalyze 3
 alter session set events '60 trace name hanganalyze  level 10'

memory dump
1. alter session set events 'immediate trace name heapdump level 10'
Heap <level> <level> with contents
description Hex | Dec Hex | Dec
Top PGA 0x01 1 0x401 1025
Top SGA 0x02 2 0x802 2050
Top UGA 0x04 4 0x1004 5000
Current call 0x08 8 0x2008 8200
User call 0x10 16 0x4010 16400
Large pool 0x20 32 0x8020 3280


2.当错误发生的时候  alter session set events '60 trace name heapdump level 10'

alter session set events 'immediate trace name heapdump_addr decimal_addr'

察看buffer cache

alter session set events 'immediate trace name buffers level 10'

Level  	Description
1 	Buffer headers only
2 	Level 1 + block headers
3 	Level 2 + block contents
4 	Buffer headers only + hash chain
5 	Level 1 + block headers + hash chain
6 	Level 2 + block contents + hash chain
8 	Buffer headers only + hash chain + users/waiters
9 	Level 1 + block headers + hash chain + users/waiters
10 	Level 2 + block contents + hash chain + users/waiters




察看library cache
alter session set events 'immediate trace name library_cache level 1';
察看dictionary cache
alter session set events 'immediate trace name row_cache level 10'

dump各种文件
数据文件

alter system dump datafile 1 block 2;
数据文件

alter system dump datafile 1 block  min  2 block max 3;

select segment_name, header_file, header_block from dba_segments  where  segment_name = '_SYSSMU9$'; 

控制文件

alter system set events 'immediate trace name controlf level 10';
redo 文件头
alter system set events 'immediate trace name redohdr level 10';
所有文件头
To dump all the datafile headers use
ALTER SESSION SET EVENTS 'immediate trace name file_hdrs level level';

Levels (circa Oracle 8.1.5) are

Level 	Description
1 	Dump datafile entry from control file
2 	Level 1 + generic file header
3 	Level 2 + datafile header
10 	Same as level 3
dump redologs 
alter system dump logfile 'logfile';

dump undo block
alter system dump undo header 'RBS01'; 

alter system dump undo block '_SYSSMU7$' xid 7 24 3696;

dump latch 
ALTER SESSION SET EVENTS 'immediate trace name latches level level';



In later versions, level 7 appears to generate additional trace

The following ORADEBUG command has the same effect

    ORADEBUG DUMP FILE_HDRS level
    
    Enqueues

To dump the current enqueue states use

    ALTER SESSION SET EVENTS 'immediate trace name enqueues level level';

Levels are

	
Level 	Description
1 	Dump a summary of active resources and locks, the resource free list and the hash table
2 	Include a dump of resource structures
3 	Include a dump of lock structures

The following ORADEBUG command has the same effect

    ORADEBUG DUMP ENQUEUES level

Work Areas

To dump the current workareas use

    ALTER SESSION SET EVENTS 'immediate trace name workareatab_dump level level';

Levels are (bitmask)

	
Level 	Description
1 	Global SGA Info
2 	Workarea Table (Summary)
3 	Workarea Table (Detail)

The following ORADEBUG command has the same effect

    ORADEBUG DUMP WORKAREATAB_DUMP level

dump Individual Buffers

In Oracle 8.0 and above is is possible to dump buffer all buffers currently in the cache for a specific block

For example where a block has been modified and is subject to consistent read from a number of transactions, 
there may be more than one copy of the block in the buffer cache

First identify the tablespace number for the block e.g for tablespace TS01

    SELECT ts# FROM sys.ts$
    WHERE name = 'TS01';

Set the tablespace number using

    ALTER SESSION SET EVENTS  'immediate trace name set_tsn_p1 level 13';

where level is the tablespace number + 1

Identify the relative DBA for the block

This is equal to

    RelativeFileNumber * 4194304 + BlockNumber

e.g. for a block with relative file number of 5 and a block number of 127874

    5 * 4194304 + 127874 = 21099394

Dump the buffer using

    ALTER SESSION SET EVENTS
    'immediate trace name buffer level level';

where level is the relative DBA e.g.

    ALTER SESSION SET EVENTS    'immediate trace name buffer level 46137358';




通过如下方式察看crash 前没有提交的事务
alter system dump undo header R01;
where R01 is the rollback segment name. A dead transaction is identified by having cflags =
'0x10'.




通过bbed编辑block 
cd $ORACLE_HOME/rdbms/lib 
make -f ins_rdbms.mk $ORACLE_HOME/rdbms/lib/bbed
./rdbms/lib/bbed 
保护密码是blockedit

 rdbms/mesg/oraus.msg记录系统所有错误信息
 
 如何relink所有的oracle文件
 
 
 How to Relink Oracle Applications 11i Programs After Upgrade or Patch 
of the UNIX Operating System

fix:

To relink the Oracle8i or Oracle9i database:
1. Change directory to the Oracle8i or Oracle9i $ORACLE_HOME (${ORACLE_SID}db/8.
1.7 if the instance is using an Oracle8i database).
2. Source the ${ORACLE_SID}.env file.
3. Run "relink all" .

To relink the Oracle8 (8.0.6) programs:
1. Change directory to the Oracle8 $ORACLE_HOME (${ORACLE_SID}ora/8.0.6).
2. Source the ${ORACLE_SID}.env file.
3. cd $ORACLE_HOME/bin
4. gensyslib
5. genclntsh
6. cd $ORACLE_HOME/network/lib
7. make -f ins_network.mk install
8. cd $ORACLE_HOME/sqlplus/lib
9. make -f ins_sqlplus.mk install
10. cd $ORACLE_HOME/svrmgr/lib
11. make -f ins_svrmgr.mk linstall
12. cd $ORACLE_HOME/rdbms/lib
13. make -f ins_rdbms.mk install
14. cd $ORACLE_HOME/forms60/lib
15. make -f ins_forms60w.mk
16. cd $ORACLE_HOME/reports60/lib
17. make -f ins_reports60w.mk
18. cd $ORACLE_HOME/graphics60/lib
19. make -f ins_graphics60w.mk
20. cd $ORACLE_HOME/browser60/lib
21. make -f ins_browser60.mk
22. cd $ORACLE_HOME/procbuilder60/lib
23. make -f ins_procbuilder.mk

To relink the Oracle Applications 11i programs:
1. cd $APPL_TOP 
2. Source the ${ORACLE_SID}.env file.
3. adrelink.sh force=y ranlib=y "AD all"
4. Run adadmin
5. Select option 2 "Maintain Applications Files Menu".
6. Select option 2 "Relink Applications Programs".
7. Relink all modules' programs.

Note on Step #3 (adrelink.sh ...): The adadmin utility does not relink the AD 
executables.  You must relink the AD executables manually via adrelink.sh .

References:
131321.1 "How to Relink Oracle Database Software on UNIX"
110849.1 "Installing and Relinking Oracle Developer on UNIX Platforms"
118234.1 "AD UTILITIES - SETUP AND USAGE"


fix:

1) Log in as the oracle user
2) Close all Oracle instances (ps -ef | grep ora, lists them),
3) From ORACLE_HOME, type the command: which make or which ld,
4) The path that returns must be: /usr/ccs/bin, 
5) To ensure that this path is returned, from the unix prompt execute:

setenv PATH /usr/ccs/bin:$PATH (C shell)

PATH=/usr/ccs/bin:$PATH (K or Bourne shell)
export PATH

6) Display the path environment variable, /usr/ccs/bin 
MUST be the very first directory.
7) Execute the following syntax (pause between 
each install statement to let the screen scroll):

% cd $ORACLE_HOME/rdbms/lib
% make -f ins_rdbms.mk install

% cd $ORACLE_HOME/network/lib
% make -f ins_network.mk install

% cd $ORACLE_HOME/sqlplus/lib
% make -f ins_sqlplus.mk install


8) Issue the command: adapters 
to ensure everything installed successfully.


. 
 
 
stream 通过 logminr 来挖掘数据，可以1->n或者n<->n(同步数据)
ar通过内部的trigger来扑获数据变化，可以通过replica procedure来批量修改数据，这样会减少网络压力。但是会导致本地事务变慢。
mv通过mv log，导致一个update，需要两次update log也会导致本地事务变慢。



只要SESSION做过INSERT,DELETE,UPDATE，都会在REDO LOG里面体现，即使ROLLBACK也会有
SQL> insert into wzy1 values(5);
SQL> ROLLBACK;
SQL> insert into wzy1 values(5);
SQL> COMMIT;
SQL> insert into wzy1 values(6);
SQL> COMMIT;
SQL> insert into wzy1 values(7);
SQL> COMMIT;

REDO LOG如下
"insert into ""RMAN"".""WZY1""(""ID"") values ('5');"               
"delete from ""RMAN"".""WZY1"" where ROWID = 'AAAH/nAALAAAAQqAAE';" 
"insert into ""RMAN"".""WZY1""(""ID"") values ('5');"               
"insert into ""RMAN"".""WZY1""(""ID"") values ('6');"               
"insert into ""RMAN"".""WZY1""(""ID"") values ('7');"               
"insert into ""RMAN"".""WZY1""(""ID"") values ('8');"               
"insert into ""RMAN"".""WZY1""(""ID"") values ('9');"               
"insert into "	"RMAN"".""WZY1""(""ID"") values ('10');"              
"insert into ""RMAN"".""WZY1""(""ID"") values ('11');"              

SQL> UPDATE WZY1 SET ID=12 WHERE ID=11;
SQL> ROLLBACK;
SQL> UPDATE WZY1 SET ID=12 WHERE ID=11;
SQL> COMMIT;
REDO LOG如下
update "RMAN"."WZY1" set "ID" = '12' where "ID" = '11' and ROWID = 'AAAH/nAALAAAAQqAAK';
update "RMAN"."WZY1" set "ID" = '11' where ROWID = 'AAAH/nAALAAAAQqAAK';
update "RMAN"."WZY1" set "ID" = '12' where "ID" = '11' and ROWID = 'AAAH/nAALAAAAQqAAK';


可能再v$logmnr_contents看不到session_info和username，原因可能是
1.RANSACTION_AUDITING=false(缺省true)
2.COMPATIBLE <=8.1
3.记录登陆信息的log没有加入到该分析中



SQL> conn / as sysdba;
ERROR:
ORA-12545: Connect failed because target host or object does not exist


发现$ORACLE_HOME/bin/oracle不见了 ，cp一个即可。




如何在sqlplus中察看执行计划
 explain plan for insert /*+append */ into wanzy_policy  select *  from t_policy a;
select * from table(dbms_xplan.display); 

SQL> select * from table(dbms_xplan.display);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
| Id  | Operation            |  Name       | Rows  | Bytes | Cost  |  TQ    |IN-OUT| PQ Distrib |
-------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT     |             |   631K|   226M|   759 |        |      |            |
|   1 |  LOAD AS SELECT      |             |       |       |       |        |      |            |
|   2 |   TABLE ACCESS FULL  | T_POLICY    |   631K|   226M|   759 | 66,00  | P->S | QC (RAND)  |
-------------------------------------------------------------------------------------------------



通过下列参数跟踪sys操作
 alter system set audit_sys_operations=true scope=spfile;
 alter system set AUDIT_TRAIL ='OS' scope=spfile;
 alter system set AUDIT_FILE_DEST='/tpdata/9.2.0/admin/tpecard/udump' scope=spfile;
 
 即可

跟踪ddl
 grant select on  sys.V_$SESSION to monitor;
 
create table t_tract_ddl (
sysevent varchar2(20),
login_user varchar2(30),
instance_num number,
database_name varchar2(50),
object_name varchar2(30),
object_type varchar2(20),
object_owner varchar2(30),
tri_time date,
sid NUMBER,
serial# NUMBER,
osuserid VARCHAR2(30),
machinename VARCHAR2(64),
ip_addr varchar2(200),
program_module varchar2(200),
current_sql varchar2(4000)
) tablespace monitor
/ 


CREATE or REPLACE TRIGGER tri_ddl before DDL on data.SCHEMA
BEGIN
p_write_ddl;
END;
/ 

CREATE or REPLACE TRIGGER monitor.tri_ddl before DDL on database
BEGIN
monitor.p_write_ddl;
END;
/ 

create or replace procedure monitor.p_write_ddl
as
machinename VARCHAR2(64);
osuserid VARCHAR2(30);
v_sid NUMBER(10);
v_ip varchar2(200);
v_serial NUMBER(10);
v_username varchar2(200);
v_program varchar2(200);
v_sql varchar2(4000);
sql_text ora_name_list_t;
v_stmt VARCHAR2(32760);
no_count number(3);
begin

no_count := ora_sql_txt(sql_text);
FOR i IN 1..no_count LOOP
v_stmt := v_stmt || sql_text(i);
if length(v_stmt)>=3000 then
  exit;
end if;
END LOOP;

SELECT sid, serial#, osuser, machine,sys_context('USERENV','IP_ADDRESS'),ss.module,sys_context('USERENV','CURRENT_SQL')
into v_sid,v_serial,osuserid,machinename,v_ip,v_program ,v_sql
FROM v$session ss WHERE sid = sys_context('USERENV','SID');
v_sql:=substr(v_stmt,1,4000);
insert into t_tract_ddl values
(ora_sysevent,
ora_login_user,
ora_instance_num,
ora_database_name,
ora_dict_obj_name,
ora_dict_obj_type,
ora_dict_obj_owner,
sysdate,
v_sid ,
v_serial ,
osuserid,
machinename,
v_ip,
v_program,
v_sql
);
exception 
  when others then
    null;
end p_write_ddl;
/


如何禁止某个ip建立sql 连接
#TCP.VALIDNODE_CHECKING=YES
#TCP.EXCLUDED_NODES=(10.1.1.73)
#TCP.INVITED_NODES=(10.1.1.72)

然后重起listener即可

drop table perfstat.t_logonaudittable;
CREATE TABLE t_audituser
(
event VARCHAR2(10),
sid NUMBER,
serial# NUMBER,
timestamp DATE,
username VARCHAR2(30),
osuserid VARCHAR2(30),
machinename VARCHAR2(64),
ip_addr varchar2(200),
program_module varchar2(200)
) tablespace monitor;




create or replace procedure monitor.p_track_login(id number) as
  machinename VARCHAR2(64);
  osuserid    VARCHAR2(30);
  v_sid       NUMBER(10);
  v_ip        varchar2(200);
  v_serial    NUMBER(10);
  v_user	  varchar2(200);
  v_program   varchar2(200);
  c_no_count number(2);
    c_yes_count number(2);

  CURSOR c1 IS
    SELECT sid,
           serial#,
           osuser,
           machine,
           sys_context('USERENV', 'IP_ADDRESS'),
           ss.module
      FROM sys.v_$session ss
     WHERE sid = sys_context('USERENV','SID');

BEGIN
  OPEN c1;
  FETCH c1
    INTO v_sid, v_serial, osuserid, machinename, v_ip, v_program;

  --if user != 'SYS'   and v_program not like  '%JDBC%' and v_program is not null then
  if v_program not like  '%JDBC%' and v_program is not null then
     INSERT INTO t_audituser
    VALUES
      (decode(id, 0, 'LOGON', 1, 'LOGOFF'),
       v_sid,
       v_serial,
       sysdate,
       user,
       osuserid,
       machinename,
       v_ip,
       v_program);
   --    commit;
  end if;

  CLOSE c1;
 /* if user='WZY' and v_ip!=null then
   select count(*) into c_no_count from sys.t_allowuser where ip_addr=v_ip and ALLOW_YES_NO='N' and upper(user)=upper('WZY') ;
  if c_no_count>=1 then
  raise_application_error( -20001, 'not allowed logon as '||user||' from '||v_ip );
  return;
  end if;
    select count(*) into c_yes_count from t_allowuser where ip_addr=v_ip and ALLOW_YES_NO='Y' and upper(user)=upper('WZY') ;
   if c_yes_count<1 then
  raise_application_error( -20001, 'not allowed logon as '||user||' from '||v_ip );
  return;
  end if;
 end if;
  --if user='TAIPINGLIFETEST'  and v_program   not like  '%JDBC%'   then

  --raise_application_error( -20001, 'no logon for XXXX' );
  -- end if;
 */
  commit;
  exception 
  when others then
    null;
end p_track_login;




CREATE OR REPLACE TRIGGER monitor.tri_log_in before LOGOFF  ON database
BEGIN
monitor.p_track_login(1);
END;
/


CREATE OR REPLACE TRIGGER monitor.tri_log_off after LOGON  ON database
BEGIN
monitor.p_track_login(0);
END;
/




cbo

3. 初试化参数对于执行计划的影响
有几个初试化参数对于多表连接的执行计划有重要的关系。

在Oracle 8 release 8.0.5中引入了两个参数OPTIMIZER_MAX_PERMUTATIONS 和 OPTIMIZER_SEARCH_LIMIT

optimizer_search_limit参数指定了在决定连接多个数据表的最好方式时，CBO需要衡量的数据表连接组合的最大数目。
该参数的缺省值是5。
如果连接表的数目小于optimizer_search_limit参数，那么Oracle会执行所有可能的连接。可能连接的组合数目是数据表数目的阶乘。

我们刚才有7张表，那么有7!（5040）种组合。

optimizer_max_permutations参数定义了CBO所考虑的连接排列的最大数目的上限。
当我们给这个参数设置很小的一个值的时候，Oracle的计算比较很快就可以被遏制。然后执行计划，给出结果。

optimizer_search_limit参数和optimizer_max_permutations参数和Ordered参数不相容，如果定义了ordered提示，那么optimizer_max_permutations参数将会失效。
实际上，当你定义了ordered提示时，oracle已经无需计算了。




如何使用stored outline修改执行计划
 alter session set create_stored_outlines=wanzy2;
然后执行sql，使执行计划存储在outln.ol$hints中
然后可以手工修改outln.ol$hints纪录，修改后
执行ALTER SYSTEM FLUSH SHARED_POOL;
在使用该sql plan的时候，需要在session或者instance一级指定
 alter session set user_stored_outlines=wanzy2;
 即可
 Privilege needed to create outlines:

CREATE ANY OUTLINE privilege

It is also useful to be able to select from DBA_OUTLINES 

 select *from dba_outlines;可以察看当前使用的outline
 select t.outline_category  from v$sql t where t.outline_category is not null; 可以察看当前使用的outline
  

 







exp 加上CONSTRAINTS=n 则pk和fk还有not null都不导出

在windows下面直接打开dmp文件，可以看到sql


http://www.juliandyke.com/ 该网站有大量的oracle内部资料
20040115 oracle trace

Event 10065 - Restrict Library Cache Dump Output for State Object Dumps
The amount of library cache dump output for state object dumps can be limited using event 10065

    ALTER SESSION SET EVENTS '10065 trace name context forever, level level';

where level is one of the following

Level Description
1 Address of library object only
2 As level 1 plus library object lock details
3 As level 2 plus library object handle and library object


Level 3 is the default

Event 10704 - Trace Enqueues
This event dumps information about which enqueues are being obtained

When enabled it prints out arguments to calls to ksqcmi and ksqlrl and the return values

    ALTER SESSION SET EVENTS
    '10704 trace name context forever, level 1';

Event 10706 - Trace Global Enqueue Manipulation
This event allows RAC global enqueue manipulation to be trace

    ALTER SESSION SET EVENTS
    '10706 trace name context forever, level 1';

The amount of output can be limited using the unsupported parameter '_ksi_trace'.

This parameter specifies the lock types that should be included e.g. TM, TX etc. They are specified as a string e.g. 'TMTX'

The parameter '_ksi_trace' can only be set in the initialisation file.

Event 10053 - Dump Optimizer Decisions
This event can be used to dump the decisions made by the optimizer when parsing a statement. Level 1 is the most detailed

For example

    ALTER SESSION SET EVENTS    '10053 trace name context forever, level 1';

Levels are

Level Action
1 Print statistics and computations
2 Print computations only


ORA-10005: trace latch operations for debugging

你可以用
SET SERVEROUTPUT ON
    
    DECLARE
      err_msg VARCHAR2(120);
    BEGIN
      dbms_output.enable (1000000);
      FOR err_num IN 10000..10999
      LOOP
        err_msg := SQLERRM (-err_num);
        IF err_msg NOT LIKE '%Message '||err_num||' not found%' THEN
          dbms_output.put_line (err_msg);
        END IF;
      END LOOP;
    END;
    /
来看所有的events,oracle提供了强大的跟踪工具,如果要深入了解内部机制,这些events会有帮助 




  关于 在aix上安装oracle的调整
  
 lsattr -El sys0 ||more
通过smit修改成功process 修改为1240

  如果使用raw device 调整file cache
  调整系统参数

/usr/samples/kernel/vmtune -p 15 -P 20



  
  如何执行parallel查询？
  -- ALTER SESSION ENABLE PARALLEL DML
  alter session force parallel query;
  select 　/*+PARALLEL(employees,2) */　from employees;
  select /*+PARALLEL(a,2) */ count(*) from t_billcard_detail;
  
  如果表一级parallel degree>1，那么做full scan的时候，会自动选择parallel
  如果表一级parallel degree=1，那么做full scan的时候，不会自动选择parallel
  如果表一级parallel degree=1，通过hint指定parallel，不一定会自动选择parallel
  如果表一级parallel degree=1，通过hint指定parallel，full，在单纯(count(*)情况下paralle)，其他情况（如insert into table select * from tab)
  也不一定会自动选择parallel
  
  以上情况都和ALTER SESSION ENABLE PARALLEL DML无关
  
  如果 alter session force parallel query; 则不管有没有指定parallel hint 都选择parallel
  
  
  如果direct insert(parallel方式insert)，必须要添加/*+ append */ table可以设置nologging或者logging，就不会产生redo
  
 通过 select * from v$pq_slave;
 select * from v$pq_sysstat;
 select * from v$pq_sesstat;
 可以察看parallel执行状态
 
 通过ALTER SESSION ENABLE PARALLEL DML 可以并行，但是回产生redo(table nologging db noarchive)
 
 通过alter session force parallel query 可以并行，不会产生redo(table nologging  db noarchive)
 
 如果添加/*+ append */就没有log
 
 
  Parameter  Default Values parallel_automatic_tuning= FALSE   Default Values When parallel_automatic_tuning=TRUE
 
parallel_execution_message_size     2KByte           4KByte 
parallel_adaptive_multi_user        FALSE            TRUE 
large_pool_size                     no effect         is incerased based ona complicated computation using various other parameters 
processes                           no effect         if processes < parallel_max_servers The processes parameter is increased 
parallel_max_servers                 5                if parallel_adaptive_multi_user==true  (cpus * parallel_threads_per_cpu * 4 * 5) else (cpus * parallel_threads_per_cpu *4 * 8) 

  parallel 执行情况
  
  表记录数 11391003
  cpu=8
create index idx_billdetail_RETURN_ID on t_billcard_detail(return_id) parallel 32;
Executed in 43.031 seconds
create index idx_billdetail_RETURN_ID on t_billcard_detail(return_id) ;
Executed in 112.359 seconds
create index idx_billdetail_RETURN_ID on t_billcard_detail(return_id) parallel 8;
Executed in 36.578 seconds
create index idx_billdetail_RETURN_ID on t_billcard_detail(return_id) parallel 16;
Executed in 34.516 seconds
  
  
  
  
  如何使用csscan处理字符转换问题
到oracle网站下载最新的csscan 1.2
解开
tar xvzf csscan_12_linux_920.tar.Z
  安装
  % cd $ORACLE_HOME/rdbms/admin
  sqlplus "system/manager as sysdba"
  START csminst.sql

aLTER USER csmig DEFAULT TABLESPACE taipinglife;


党conn '/ as sysdba' 提示 权限不够的时候 
检查 是否再dba组中
vi /tpsys/app/oracle/product/9.2.0/rdbms/lib/config.c
ORA-01031: insufficient privileges

也有可能是设置了TWO_TASK导致的



从gbk的数据库到 AL32UTF8的转换没有问题
imp进程会表示没有导入的row.


select dump(certi_code) from t_customer@test where  customer_id=247288;

DUMP(CERTI_CODE)
--------------------------------------------------------------------------------
Typ=1 Len=22: 206,196,214,176,184,201,178,191,205,203,208,221,214,164,177,177,21

SQL>  select (certi_code) from t_customer@test where  customer_id=247288;

CERTI_CODE
------------------------------
文职干部退休证北字5078

SQL> 

会有certi_code不能导入？？？ 因为有非法字符。




A single instance configuration will have just the one segment, hence one  pool of extents.

select TABLESPACE_NAME,TOTAL_BLOCKS,USED_BLOCKS,FREE_BLOCKS         from v$sort_segment;
 
察看当前正在使用的temp
 select st.machine,ss.segtype,ss.blocks From v$sort_usage ss,v$session st where ss.session_addr=st.saddr;


所有的排序都使用一个temp seg的不同extent

当instance startup 后，第一次使用的session创建sort segment,使用完后，free到Sort Extent Pool (SEP),
instance startup的时候，smon负责
The background process SMON actually de-allocates the sort segment

after the instance has been started and the database has been opened.

Thus, after the database has been opened, SMON may be seen to consume

large amounts of CPU as it first de-allocates the (extents from the)

temporary segment, and after that performs free space coalescing

of the free extents created by the temporary segment cleanup


使用with可以加快执行速度
with
all_pp as (select a.policy_id,b.insured_1,b.amount,c.internal_id  FROM t_contract_master a , t_contract_product b, t_product_life c, t_benefit_type d
        WHERE a.policy_id = b.policy_id
          AND b.product_id = c.product_id
          AND c.benefit_type = d.benefit_type
          AND a.liability_state = 1
          AND b.liability_state = 1 --有效
          --AND a.branch_id = 102 --北分
          --AND c.Internal_Id in (1003,1012,1017)
        AND a.insert_time >= to_date('2002-01-01','YYYY-MM-DD')
        AND a.insert_time < to_date('2003-07-31','YYYY-MM-DD')
        )
 select  * from  (select Internal_Id, sum(amount) amount  from all_pp group by internal_id),
 (select count(distinct policy_id ),
 count( distinct insured_1 ) from all_pp)

Executed in 6.62 seconds

 select  * from  (select Internal_Id, sum(b.amount) amount  from 
 t_contract_master a , t_contract_product b, t_product_life c, t_benefit_type d
        WHERE a.policy_id = b.policy_id
          AND b.product_id = c.product_id
          AND c.benefit_type = d.benefit_type
          AND a.liability_state = 1
          AND b.liability_state = 1 --有效
          AND a.branch_id = 102 --北分
          AND c.Internal_Id in (1003,1012,1017)
        AND a.insert_time >= to_date('2002-01-01','YYYY-MM-DD')
        AND a.insert_time < to_date('2003-07-31','YYYY-MM-DD') group by internal_id),
 (select count(distinct a.policy_id ),
 count( distinct insured_1 ) 
   FROM t_contract_master a , t_contract_product b, t_product_life c, t_benefit_type d
        WHERE a.policy_id = b.policy_id
          AND b.product_id = c.product_id
          AND c.benefit_type = d.benefit_type
          AND a.liability_state = 1
          AND b.liability_state = 1 --有效
          AND a.branch_id = 102 --北分
          AND c.Internal_Id in (1003,1012,1017)
        AND a.insert_time >= to_date('2002-01-01','YYYY-MM-DD')
        AND a.insert_time < to_date('2003-07-31','YYYY-MM-DD'))

Executed in 9.514 seconds


    再windows 9203环境下
 
mv refresh complete on commit 
nologging  和logging 产生所有日志(delete ,insert).
 

mv refresh complete on demand
nologging 不产生所有日志.(truncate table "WANZY"."MV_TEST_2" purge snapshot log;  )
logging 产生insert 日志(truncate table "WANZY"."MV_TEST_2" purge snapshot log;  ) 
 
可以在指定
alter materialized view MV_TEST_2 refresh on demand start with sysdate next sysdate+10/1440;
 
可以在user_tables中察看mv德log情况
 

再cost情况下，可以使用mv做query rewrite;
 

begin DBMS_LOGMNR.ADD_LOGFILE(LOGFILENAME => 'D:\ORACLE\ORADATA\WZY\REDO02.LOG',OPTIONS => DBMS_LOGMNR.NEW); end;
begin DBMS_LOGMNR.START_LOGMNR(OPTIONS =>+DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG); end;
select dd.scn,dd.sql_redo,dd.session_info from v$logmnr_contents dd where scn>494
 

对于isqlplus
里面的连接串就是apache服务器上的tnsnames.ora
 
对于需要用dba方式访问isqlplus 
需要htpasswd %ORACLE_HOME%\sqlplus\admin\iplusdba.pw username
该程序在$ORACLE_HOME\Apache\Apache\bin下面
 
 
 
   merge into wzy2
   using wzy
   on (wzy.name_3=wzy2.name_3)
   when matched then
   update set  name3=wzy.name3
   when not matched then
   insert values(wzy.name_3,wzy.name3,wzy.name2)

不管是
CREATE TABLE TEST_2 AS SELECT *FROM T_POLICY WHERE ROWNUM<1000;
INSERT INTO TEST_2 /*+ APPEND */ SELECT  *FROM T_POLICY WHERE ROWNUM<10;
都会在REDO LOG 里面记录所有的信息

就是说不会产生DATA GUARD出现不能RECOVER的情况
DROP TABLE不产生REDO LOG
TRUNCATE TABLE不产生REDO LOG

create table 之类的的ddl也可以通过下面语句察看
select dd.scn,dd.sql_redo,dd.session_info from v$logmnr_contents dd where dd.seg_owner='WANZY' AND OPERATION='DDL';

9.2的mv不会产生redo log?

truncate table "WANZY"."MV_TEST_L" purge snapshot log;
但是9.01
 create materialized view  mv_wzy_R NOLOGGING enable query rewrite as select *From wzy;
不会产生LOG
 ALTER materialized view mv_wzy_R LOGGING;
会产生LOG

9.01
如果

  REFRESH complete 则会产生所有的REDO 
 如果 ALTER materialized view  mv_wzy_4  REFRESH FAST 则会产生新的;



如果需要用到fast refresh，需要使用mv log
创建形式

create materialized view log on wzy_testmv with rowid,primary key;

创建mv
 create materialized view mv_policy refresh fast start with sysdate next sysdate+2/1440 as select * from wzy_testmv;


需要对数据库增加SUPPLEMENTAL LOG DATA
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

9.2.0.3 (force logging)

有mv log情况下，对主表插入记录，log表都会有记录
执行刷新
sql操作 

SQL> insert into wzy_testmv values('2',2);

SQL> update wzy_testmv set id=3 where name='2';

SQL> execute dbms_mview.refresh('mv_policy');

redo 记录
SCN TIMESTAMP   SEG_NAME                                                                         SQL_REDO
--- ----------- -------------------- --------------------------------------------------------------------------------
135 2004-4-6 10 WZY_TESTMV           insert into "MV"."WZY_TESTMV"("NAME","ID") values ('2','2');
135 2004-4-6 10 WZY_TESTMV,PK_WZY    
135 2004-4-6 10 MLOG$_WZY_TESTMV     insert into "MV"."MLOG$_WZY_TESTMV"("NAME","M_ROW$$","SNAPTIME$$","DMLTYPE$$","O
135 2004-4-6 10 WZY_TESTMV           update "MV"."WZY_TESTMV" set "ID" = '3' where "ID" = '2' and ROWID = 'AAAHeFAALA
135 2004-4-6 10 MLOG$_WZY_TESTMV     insert into "MV"."MLOG$_WZY_TESTMV"("NAME","M_ROW$$","SNAPTIME$$","DMLTYPE$$","O
135 2004-4-6 10 MLOG$_WZY_TESTMV     update "MV"."MLOG$_WZY_TESTMV" set "SNAPTIME$$" = TO_DATE('06-4月 -
135 2004-4-6 10 MLOG$_WZY_TESTMV     update "MV"."MLOG$_WZY_TESTMV" set "SNAPTIME$$" = TO_DATE('06-4月 -
135 2004-4-6 10 MV_POLICY            insert into "MV"."MV_POLICY"("NAME","ID") values ('2','3');
135 2004-4-6 10 MV_POLICY,PK_WZY1    
135 2004-4-6 10 MLOG$_WZY_TESTMV     delete from "MV"."MLOG$_WZY_TESTMV" where "NAME" = '2' and "M_ROW$$" = 'AAAHeFAA
135 2004-4-6 10 MLOG$_WZY_TESTMV     delete from "MV"."MLOG$_WZY_TESTMV" where "NAME" = '2' and "M_ROW$$" = 'AAAHeFAA
 
update wzy_testmv set id=4 where name='2';

135 2004-4-6 10 WZY_TESTMV           update "MV"."WZY_TESTMV" set "ID" = '4' where "ID" = '3' and ROWID = 'AAAHeFAALA
135 2004-4-6 10 MLOG$_WZY_TESTMV     insert into "MV"."MLOG$_WZY_TESTMV"("NAME","M_ROW$$","SNAPTIME$$","DMLTYPE$$","O
135 2004-4-6 10 MLOG$_WZY_TESTMV     update "MV"."MLOG$_WZY_TESTMV" set "SNAPTIME$$" = TO_DATE('06-4月 -
135 2004-4-6 10 MV_POLICY            update "MV"."MV_POLICY" set "NAME" = '2', "ID" = '4' where "NAME" = '2' and "ID"
135 2004-4-6 10 MLOG$_WZY_TESTMV     delete from "MV"."MLOG$_WZY_TESTMV" where "NAME" = '2' and "M_ROW$$" = 'AAAHeFAA


delete from wzy_testmv where name='1';
execute dbms_mview.refresh('mv_policy');

13564891 WZY_TESTMV	        delete from "MV"."WZY_TESTMV" where "NAME" = '1' and "ID" = '1' and ROWID = 'AAAHeFAALAAAAPiAAA';
13564891 WZY_TESTMV,PK_WZY	
13564891 MLOG$_WZY_TESTMV	insert into "MV"."MLOG$_WZY_TESTMV"("NAME","M_ROW$$","SNAPTIME$$","DMLTYPE$$","OLD_NEW$$","CHANGE_VECTOR$$") values ('1','AAAHeFAALAAAAPiAAA',TO_DATE('01-1月 -
13564905 MLOG$_WZY_TESTMV	update "MV"."MLOG$_WZY_TESTMV" set "SNAPTIME$$" = TO_DATE('06-4月 -
13564917 MV_POLICY	        delete from "MV"."MV_POLICY" where "NAME" = '1' and "ID" = '1' and ROWID = 'AAAHeJAALAAAAP6AAA';
13564917 MV_POLICY,PK_WZY1	
13564926 MLOG$_WZY_TESTMV	delete from "MV"."MLOG$_WZY_TESTMV" where "NAME" = '1' and "M_ROW$$" = 'AAAHeFAALAAAAPiAAA' and "SNAPTIME$$" = TO_DATE('06-4月 -


create materialized view mv_wzy refresh complete on demand as select * from wzy_testmv;
没有mv log
insert into wzy values(2,'w');
 execute dbms_mview.refresh('mv_wzy');
redo log
 
1	13565678	2004-4-6 10:42:05	WZY	insert into "MV"."WZY"("ID","NAME") values ('2','w');
2	13565678	2004-4-6 10:42:05	WZY,PK_WZY_2	
3	13565795	2004-4-6 10:43:50	MV_WZY	truncate table "MV"."MV_WZY" purge snapshot log;
4	13565806	2004-4-6 10:43:51	MV_WZY	insert into "MV"."MV_WZY"("ID","NAME") values ('1','w');
5	13565806	2004-4-6 10:43:51	MV_WZY	insert into "MV"."MV_WZY"("ID","NAME") values ('2','w');
6	13565806	2004-4-6 10:43:51	MV_WZY,PK_WZY_21	


在没有redolog可以用的情况，增加log_archive_max_processes  没有用？


set NLS_LANG=american_america.zhs16gbk
C:\>wrap iname=w.sql
 
PL/SQL Wrapper: Release 9.2.0.3.0- Production on Sat Jul 21 22:45:00 2001
 
Copyright (c) Oracle Corporation 1993, 2001.  All Rights Reserved.
 
Processing w.sql to w.plb
Luv Xiaowan

再linux下面察看error
oerr ora  600

如何跟踪checkpoint事件
alter system set log_checkpoints_to_alert=true;
 alter system checkpoint;
 alter system switch logfile;
 都会导致cheeckpoint
 
 
 kill arch进程会导致instance crash
 
 
 从V$PWFILE_USERS 查询那些用户具有sysdba,SYSOPER权限
 
 
imp 顺序
DATABASE LINK
object
TABLE


exp顺序
PUBLIC type synonyms
private type synonyms
object type definitions 
database links
sequence numbers
cluster definitions
table
synonyms
views
stored procedures
operators
referential integrity constraints
triggers
indextypes
bitmap, functional and extensible indexes
materialized views
snapshot logs
 job queues
 refresh groups and children
 dimensions
 
 buffer busy waits 
 This wait happens when a session wants to access a database block in the buffer cache but it 
 cannot as the buffer is "busy". The two main cases where this can occur are: 
Another session is reading the block into the buffer 
Another session holds the buffer in an incompatible mode to our request 

 
 
 latch free _cache buffer chain
 
 
 查询那个session hold 
 select *from v$latchholder;
 
 查询那个latch
 SELECT name, 'Child '||child#, gets, misses, sleeps
    FROM v$latch_children 
   WHERE addr='07000001E1DC4560'
  UNION
  SELECT name, null, gets, misses, sleeps
    FROM v$latch
   WHERE addr='07000001E1E41000';
  
  查询热块
   
  select /*+ rule */
  e.owner ||'.'|| e.segment_name  segment_name,
  e.extent_id  extent#,
  x.dbablk - e.block_id + 1  block#,
  x.tch,
  l.child#
from
  sys.v$latch_children  l,
  sys.x$bh  x,
  sys.dba_extents  e
where
  x.hladdr  = '07000001E21D89D0' and
  e.file_id = x.file# 
  and l.addr=x.hladdr 
  and x.dbablk between e.block_id and e.block_id + e.blocks - 1
order by x.tch desc ;
  
  
querry : 
select count(*) "cCHILD" 
, sum(GETS) "sGETS" 
, sum(MISSES) "sMISSES" 
, max(SLEEPS) "sSLEEPS" 
from v$latch_children 
where name = 'cache buffers chains' 
order by 4, 1, 2, 3; 

select /*+ ordered */ 
e.owner ||'.'|| e.segment_name segment_name, 
e.extent_id extent#, 
x.dbablk - e.block_id + 1 block#, 
x.tch, 
l.child# 
from 
sys.v$latch_children l, 
sys.x$bh x, 
sys.dba_extents e 
where 
l.name = 'cache buffers chains' and 
l.sleeps > &sleep_count and 
x.hladdr = l.addr and 
e.file_id = x.file# and 
x.dbablk between e.block_id and e.block_id + e.blocks - 1; 



  In order to reduce contention for this object the following mechanisms can be put in place:

   1)Examine the application to see if the execution of certain DML
     and SELECT statements can be reorganized to eliminate contention
     on the object.
   2)Decrease the buffer cache -although this may only help in a small amount of cases.
   3)DBWR throughput may have a factor in this as well.
      If using multiple DBWR's then increase the number of DBWR's
   4)Increase the PCTUSED / PCTFREE for the table storage parameters via ALTER TABLE 
     or rebuild. This will result in less rows per block.
   5)Consider implementing reverse key indexes 
     (if range scans aren't commonly used against the segment)
     
 
 library cache pin
  

handle address

    Use P1RAW rather than P1
    This is the handle of the library cache object which the waiting session wants to acquire a pin on.
    The actual object being waited on can be found using

  SELECT kglnaown "Owner", kglnaobj "Object"     FROM x$kglob    WHERE kglhdadr='5b520424' ;  
   
 
   The following SQL can be used to show the sessions which are holding and/or requesting pins on the object that
    given in P1 in the wait:

  SELECT s.sid, kglpnmod "Mode", kglpnreq "Req",machine,username,sid,serial#
    FROM x$kglpn p, v$session s
   WHERE p.kglpnuse=s.saddr
     AND kglpnhdl='07000001F7DE0510' ;

An X request (3) will be blocked by any pins held S mode (2) on the object.
An S request (2) will be blocked by any X mode (3) pin held, or may queue behind some other X request.

 
library cache lock

察看一个对象锁住的所有对象

select KGLLKREQ,KGLLKMOD, KGLNAOBJ,machine,username,sid,serial# from x$kgllk xk,v$session ss  where ss.SADDR=xk.KGLLKSES;

select KGLLKREQ,KGLLKMOD, KGLNAOBJ,KGLLKHDL,machine,username,sid,serial# from x$kgllk xk,v$session ss  
where ss.SADDR=xk.KGLLKSES and ss.sid=273;

This will show you all the library locks held by this session where  KGLNAOBJ contains 
the first 80 characters of the name of the object. 
The value in KGLLKHDL corresponds with the 'handle address' of the  object in METHOD 1. 

察看所有lock和等待lock该对象的session


select KGLLKREQ,KGLLKMOD, KGLNAOBJ,machine,username,sid,serial# from x$kgllk xk,v$session ss  where
 ss.SADDR=xk.KGLLKSES and KGLLKHDL='07000001E7BBFA48';


You will see that at least one lock for the session has KGLLKREQ > 0   which means this is a
 REQUEST for a lock (thus, the session is waiting).  
  If we now match the KGLLKHDL with the handles of other sessions in   X$KGLLK that should give us the address 
  of the blocking session since  KGLLKREQ=0 for this session, meaning it HAS the lock. 

  The X$KGLLK table (accessible only as SYS/INTERNAL) contains all the   library object locks (both held & requested) for all sessions and
  is more complete than the V$LOCK view although the column names don't  always reveal their meaning.   
  You can examine the locks requested (and held) by the waiting session   by looking up the session address 
  (SADDR) in V$SESSION and doing the   following select:   
  select * from x$kgllk where KGLLKSES = 'saddr_from_v$session'   
  This will show you all the library locks held by this session where  KGLNAOBJ contains the first 80
   characters of the name of the object.  The value in KGLLKHDL corresponds with the 'handle address' of the  
   object in METHOD 1.   You will see that at least one lock for the session has KGLLKREQ > 0  
    which means this is a REQUEST for a lock (thus, the session is waiting). 
      If we now match the KGLLKHDL with the handles of other sessions in 
        X$KGLLK that should give us the address of the blocking session since  KGLLKREQ=0 for this session,
         meaning it HAS the lock. 






通过dbms_metadata.getddl可以获得一个对象的创建脚本
通过dba_job_running可以查询当前正在运行的job，然后可以通过kill session处理。

For using the RESUME mode we have do the following;
1.      Issue 'GRANT RESUMABLE TO <user>'.
2.      Issue 'ALTER SESSION ENABLE RESUMABLE TIMEOUT <seconds> name 'name ''
Alternatively for disabling RESUME mode;
1.      Issue 'REVOKE RESUMABLE TO <user>'.
2.      Issue 'ALTER SESSION DISABLE RESUMABLE'
alert.log

statement in resumable session 'myid' was suspended due to
    ORA-01691: unable to extend lob segment TAIPINGLIFETEST.SYS_LOB0000049229C00002$$ by 8 in tablespace LIMITTEST
statement in resumable session 'myid' was resumed


oracle安装需要两个root用户执行脚本
/tmp/orainstRoot.sh
#!/bin/sh
INVPTR=/etc/oraInst.loc
INVLOC=/tpdata/tpdata/9.2.0/oraInventory
GRP=oracle
PTRDIR="`dirname $INVPTR`";
# Create the Software Inventory location pointer file
if [ ! -d "$PTRDIR" ]; then
 mkdir -p $PTRDIR;
fi
echo "Creating Oracle Inventory pointer file ($INVPTR)";
echo    inventory_loc=$INVLOC > $INVPTR
echo    inst_group=$GRP >> $INVPTR
chmod 644 $INVPTR
# Create the Inventory Directory if it doesn't exist
if [ ! -d "$INVLOC" ];then
 echo "Creating the Oracle Inventory Directory ($INVLOC)";
 mkdir -p $INVLOC;
 chmod 775 $INVLOC;
fi
echo "Changing groupname of $INVLOC to oracle.";
chgrp oracle $INVLOC;
if [ $? != 0 ]; then
 echo "WARNING: chgrp of $INVLOC to oracle failed!";
fi


Creating Oracle Inventory pointer file (/etc/oraInst.loc)
Changing groupname of /tpdata/tpdata/9.2.0/oraInventory to oracle.

宁外一个脚本/tpdata/tpsys/app/oracle/product/9.2.0/root.sh
unning Oracle9 root.sh script...
\nThe following environment variables are set as:
    ORACLE_OWNER= oracle
    ORACLE_HOME=  /tpdata/tpsys/app/oracle/product/9.2.0

Enter the full pathname of the local bin directory: [/usr/local/bin]: 
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...

\nCreating /etc/oratab file...
Adding entry to /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root.sh script.
Now product-specific root actions will be performed.


可以使用 

select sys_context('USERENV','IP_ADDRESS') from dual;
来获得一些参数



dbnewid ==>dn 


对于同样一个对象(如 type)，在数据库中是唯一的，不是基于schema唯一的
所以，如果已经有一个SCHEMA有这个对象，则再导入其它的SCHEMA就会报错误
ORA-02304: invalid object identifier literal
IMP-00017: following statement failed with ORACLE error 2304:
 "CREATE TYPE "PLANCANCLE_CERTNOLIST" TIMESTAMP '2003-07-01:13:27:56' OID 'C1"
 "68BA61FF2A8C0FE030020A01212BE9'                                            "
 "                                AS TABLE OF CertStrut"

CONTROL_FILE_RECORD_KEEP_TIME 参数制定 v$archived_log保存历史，缺省为7天，最多365天

对以前的数据不做约束检查

alter table w1 add constraint  fk_w foreign key (id1) references w(id1) novalidate; 


如何在pl/sql中捕捉错误
create or replace procedure p_test(mess out varchar2)
is
begin
insert into t_policy (policy_id) values(1);
exception
when others then
  mess:=sqlerrm(sqlcode);
end;

如何使用x$bh来确定 热点 sga

从v$latch.ADDR=x$bh.hladdr 关联得到sga地址
从x$bh FILE# DBABLK 关联dba_extents

 select * from dba_extents dd where dd.file_id=29 and 171411 between dd.block_id and dd.block_id+dd.blocks-1;



You could look at X$BH.OBJ which maps to obj$.obj#. This will tell 
you what object each buffer is a part of. Something like: 
select o.name, count(*) from x$bh xbh, obj$ o 
where o.obj#=xbh.obj 
group by o.name; 
will give you a list of objects that have buffers in the cache and 
the count of buffers per object. 

Other notable columns in X$BH are 'DBARFIL' and 'DBABLK' if you're 
trying to determine if a specific file#/block# is in the buffer cache, 
and TCH is the 'touch count', which is an indication of how hot the 
buffer is. 



rdbms/admin/utlirp.sql可以失效所有函数，然后重新编译


使用外部表

创建目录
CONNECT / AS SYSDBA;
-- Set up directories and grant access to hr
CREATE OR REPLACE DIRECTORY my_dir
AS '/home/oracle9i';
授权
grant read,write on DIRECTORY  my_dir to wanzy;
创建外部表
conn wanzy/ftp123
CREATE TABLE t_ex(name varchar2(20),name2 varchar2(20),name3 varchar2(20))
ORGANIZATION EXTERNAL
(
TYPE ORACLE_LOADER
DEFAULT DIRECTORY my_dir
ACCESS PARAMETERS
(
records delimited by newline
fields terminated by 0x
missing field values are null
(name,name2,name3
)
)
LOCATION ('wzy.sql')
)
PARALLEL
REJECT LIMIT UNLIMITED;;

修改字符集
alter database character set INTERNAL_CONVERT AL32UTF8
alter database national character set INTERNAL_CONVERT AL16UTF16


使用isqlplus
打开oralce apache，输入http://localhost/isqlplus 既可以访问
如果需要以dba方式访问
运行 htpasswd 实用程序，将用户添加到验证文件中。
htpasswd 实用程序通常位于以下路径中：%ORACLE_HOME%\Apache\Apache\bin。
对于 SYSDBA 或 SYSOPER 用户，可使用以下格式：
htpasswd %ORACLE_HOME%\sqlplus\admin\iplusdba.pw username

http://localhost/isqlplusdba
isqlplus配置文件

$ORACLE_HOME\sqlplus\admin\isqlplus.conf



To immediate kill a session at OS level use ORAKILL utility
to kill sessions thread on windows
and KILL command on UNIX.






启动mts，设置
 alter system set dispatchers='(PROTOCOL=TCP)(DISPATCHERS=3)(LISTENER=listeners_1)';
alter system set shared_servers=4参数
LISTENER=listeners_1参数一定要加上，不然自动注册会有问题，或者设置local_listener参数

同时需要配tnsnames.ora文件
加上对listeners_1说明
listeners_1=
(address=(protocol=tcp)(host=10.1.1.78)(port=1521))

这样dispatchers就可以自动注册到listener,
就可以在客户端联接指定

sfssgbk2 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.78)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME =sfssgbk)
      (SERVER=shared)
      )
  )
  
  


再windows下面手工建库 需要先注册service
添加系统service
oradim -NEW -SID wzy -INTPWD wzy -STARTMODE manual -PFILE "d:\oracle\ora90\database\initwzy.ora"
否则会出现 sqlplus会出现 ORA-12560错误
oradim 可以创建 service,删除 service,修改 service，启动，关闭 service

如何创建 management server respos   emca

oemctl start oms   缺省 用户  sysman/oem_temp
oemctl stop oms
启动agent  
agentctl start 
agentctl stop
agentctl status 


可以通过 DBA_DEPENDENCIES察看系统对象的应用关系

select any dictionary select_catalog_role权限不一样


V$RESOURCE_LIMIT; 可以察看系统的得一些资源限制


DUMP 函数可以察看数据文件的系统的纪录
SELECT DUMP(POLICY_ID) FROM T_POLICY WHERE POLICY_ID=21;

SELECT DBMS_ROWID.ROWID_RELATIVE_FNO('AAAJboAAWAAAsbSAAU') FILE_NO,
DBMS_ROWID.ROWID_BLOCK_NUMBER('AAAJboAAWAAAsbSAAU') BLOCK_NO,
DBMS_ROWID.ROWID_ROW_NUMBER('AAAJboAAWAAAsbSAAU') ROW_NO
 FROM DUAL


v$option纪录系统的安装选项
V$version纪录数据库版本
dba_registry记录当前数据库安装选项(9iR2有)

如何让程序产生 core dump
ulimit -c unlimited
kill -11 pid
就会在当前目录产生core dump


ulimit [-SHacdfmstpnuv [limit]]  
ulimit提供了对shell的可获取资源控制的功能。  

-a : 报告目前所有限制。  
-c : 设定最大可产生的core档案。  
-d : 行程资料段(process's data segment)最大值。  
-f : 可被这个shell产生的最大档案。  
-m : resident set size最大值。  
-s : 堆叠最大值。  
-t : CPU TIME最大值(以秒计算)。  
-p : pipe size in 512-byte blocks的最大值。  
-n : 可开启的file descriptors最大值。  
-u : 单一使用者可使用的最大process数。  
-v : 该shell最大虚拟记忆体可用值。  



MAX_DUMP_FILE_SIZE
TIMED_STATISTICS 


所有项目是以1024做为单位。  



10046 dump 解释
PARSE #<CURSOR>:c=0,e=0,p=0,cr=0,cu=0,mis=0,r=0,dep=0,og=4,tim=0  
EXEC  #<CURSOR>:c=0,e=0,p=0,cr=0,cu=0,mis=0,r=0,dep=0,og=4,tim=0 
FETCH #<CURSOR>:c=0,e=0,p=0,cr=0,cu=0,mis=0,r=0,dep=0,og=4,tim=0 
UNMAP #<CURSOR>:c=0,e=0,p=0,cr=0,cu=0,mis=0,r=0,dep=0,og=4,tim=0

 	PARSE	Parse a statement.
 	EXEC 	Execute a pre-parsed statement.
 	FETCH	Fetch rows from a cursor.
 	UNMAP	If the cursor uses a temporary table, when the cursor is 		closed you see an UNMAP when we free up the temporary table		locks.(Ie: free the lock, delete the state object, free the 		temp segment)  		In tkprof, UNMAP stats get added to the EXECUTE statistics. 	SORT UNMAP 		As above, but for OS file sorts or TEMP table segments.
 	c	CPU time (100th's of a second).
 	e	Elapsed time (100th's of a second).
 	p	Number of physical reads.   
 	cr	Number of buffers retrieved for CR reads.
 	cu	Number of buffers retrieved in current mode.
 	mis	Cursor missed in the cache. 	
 	r	Number of rows processed. 	
 	dep	Recursive call depth (0 = user SQL, >0 = recursive).  	
 	og	Optimizer goal: 1=All_Rows, 2=First_Rows, 3=Rule, 4=Choose 	
 	tim	Timestamp (large number in 100ths of a second).  Use this to                  determine the time between any 2 operations.


BINDS #%d:   
bind 0: dty=2 mxl=22(22) mal=00 scl=00 pre=00 oacflg=03 oacfl2=0 size=24 offset=0   bfp=02fedb44 bln=22 avl=00 flg=05    value=10 


BIND        Variables bound to a cursor.   
bind N	The bind position being bound.     
dty		Data type (see <Glossary:DataTypes>).     
mxl		Maximum length of the bind variable (private max len in paren).     
mal		Array length.     
scl		Scale.     
pre		Precision.     
oacflg	Special flag indicating bind options     
oacflg2     Continuation of oacflg     
size        Amount of memory to be allocated for this chunk     
offset      Offset into this chunk for this bind buffer      
bfp         Bind address.     
bln	        Bind buffer length.      
avl	        Actual value length (array length too).     
flg	        Special flag indicating bind status     
value	The actual value of the bind variable.   		
Numbers show the numeric value, strings show the string etc...    
  It is also possible to see "bind 6: (No oacdef for this bind)", if no     separate bind buffer exists.  
  
  
PARSING IN CURSOR #<CURSOR> len=X dep=X uid=X oct=X lid=X tim=X hv=X ad='X' 
<statement> 
END OF STMT 
<CURSOR>	Cursor number.

 len		Length of SQL statement. 
 dep		Recursive depth of the cursor
 uid		Schema user id of parsing user. 
 oct		Oracle command type. 
 lid		Privilege user id
 tim		Timestamp. 		Pre-Oracle9i, the times recorded by Oracle only have a resolution                  of 1/100th of a second (10mS). As of Oracle9i some times are                  available to microsecond accuracy (1/1,000,000th of a second).                 The timestamp can be used to determine times between points                  in the trace file. 		The value is the value in V$TIMER when the line was written. 		If there are TIMESTAMPS in the file you can use the difference 		between 'tim' values to determine an absolute time. 
 hv		Hash id
 ad		SQLTEXT address (see <View:V$SQLAREA> and <View:V$SQLTEXT>). 
 <statement>	The actual SQL statement being parsed. 
        
WAIT #<CURSOR>: nam="<event name>" ela=0 p1=0 p2=0 p3=0
  WAIT	An event that we waited for.
  nam 	What was being waited for .	The wait events here are the same as are seen in  		<View:V$SESSION_WAIT>. For any Oracle release a full list of  		wait events and the values in P1, P2 and P3 below can be seen  		in <View:V$EVENT_NAME>     
  ela 	Elapsed time for the operation.  (1/100 s)   
  p1		P1 for the given wait event.      
  p2		P2 for the given wait event.     
  p3		P3 for the given wait event.  

如何获得oracle systemstate dump

$ sqlplus /nolog
connect / as sysdba
REM The select below is to avoid problems on some releases
select * from dual; 
oradebug unlimit 
oradebug setorapid 8  or oradebug setospid 25807    
oradebug dump systemstate 10  
do 3 times to analyse

获得PROCESSSTATE dump. 
sqlplus "/as sysdba"       
oradebug setospid <process ID>  
oradebug unlimit 
oradebug dump processstate 10 

Get errorstacks from the process. Do 3 times.
 This generates a trace          file in your user_dump_dest 
 
 
 oradebug dump errorstack 3   
 error dump
 
在user_dump下面产生log文件


设置系统一级的event
ALTER SYSTEM SET EVENTS '10046 trace name context forever, level 12'; 
ALTER SYSTEM SET EVENTS '10046 trace name context off'; 
ALTER session  SET EVENTS '10046 trace name context forever, level 12'; 

可以再session一级设置dump 

Some common immediate dump Events include :   

SYSTEMSTATE, ERRORSTACK, CONTROLF, FILE_HDRS and REDOHDR 
ALTER SESSION SET EVENTS 'IMMEDIATE trace name ERRORSTACK level 3'; 



HANGANALYZE use internal kernel calls to determine if a session
 is waiting for a resource, and reports the relationships
  between blockers and waiters.
   In addition, it determines which processes are “interesting” to
    be dumped, and may perform automatic PROCESSSTATE dumps and ERRORSTACKS 
    on those processes, based on the level used while executing the HANGANALYZE.
    
HANGANALYZE may be executed using the following syntax:

ALTER SESSION SET EVENTS 'immediate trace name HANGANALYZE level <level>';

Or when logged in with the “SYSDBA” role,

ORADEBUG hanganalyze <level>
3分钟后 再来一次

To perform cluster wide HANGANALYZE use the following syntax:

ORADEBUG setmypid
ORADEBUG setinst all
ORADEBUG -g def hanganalyze <level>


The levels are defined as follows:

10     Dump all processes (IGN state)
5      Level 4 + Dump all processes involved in wait chains (NLEAF state)
4      Level 3 + Dump leaf nodes (blockers) in wait chains (LEAF,LEAF_NW,IGN_DMP state)
3      Level 2 + Dump only processes thought to be in a hang (IN_HANG state)
1-2    Only HANGANALYZE output, no process dump at all


如何察看当前设置的event
dbms_system.read_ev call used 
in  works only for event name CONTEXT. 

ORADEBUG dump events N 
where N is 
1 for session 
2 for process 
4 for system 

oradebug setmypid
oradebug dump events 4 ;
产生的dump文件在udump下面

这个好像不电吗


dbms_support oracle新的trace包
$ORACLE_HOME/rdbms/admin/dbmssupp.sql 




Note that significantly more detailed information can be found by dumping systemstate  information for the instance:

ALTER SESSION SET EVENTS 'IMMEDIATE TRACE NAME SYSTEMSTATE LEVEL 10'; 

Session level:
alter session set events '10046 trace name context forever, level 12';

   Init.ora:
	event="10046 trace name context forever,level 4"
        WARNING: This will trace ALL database sessions
        

    From oradebug (7.3+):
        oradebug event 10046 trace name context forever, level 4

    Use 
      sys.dbms_system.set_ev(<sid>,<serial>,10046,4,'');
      sys.dbms_system.set_ev(<sid>,<serial>,10046,0,'');DBMS_SYSTEM.SET_EV w/ a level of 0. That will turn it off. 
      

10046 EVENT levels:         1  - Enable standard SQL_TRACE functionality (Default)  
                            4  - As Level 1 PLUS trace bind values
                            8  - As Level 1 PLUS trace waits              This is especially useful for spotting latch wait etc.               but can also be used to spot full table scans and index scans. 
                            12 - As Level 1 PLUS both trace bind values and waits  
也就是比sql_trace多了些东西dump出来
alter session set events '10046 trace name context off';
在trace文件中的计量单位是百万分一秒
PARSING IN CURSOR #1 len=1367 dep=0 uid=56 oct=3 lid=56 tim=1039273245943485 hv=1371123023 ad='eaadd170'


如何在sqlplus 中使用 autotrace 
用sys用户创建 PLUSTRACE role
cd $ORACLE_HOME
@sqlplus/admin/plustrce.sql




alter table table_name move tablespace tablespace_name;
做完之后需要重新编译相关的index

alter index index_name rebuild tablespace tablespace_name;


在peak时端，避免做ddl，回导致hard parse，成本很高
对sequence 的操作，需要做尽量大的cache,可以避免对dict的lock操作。

不要关闭cursor,尽量重用，通过bind value
通过v$sgastat的free memory来看是否需要增加shared_pool


The CIRCUITS initialization parameter specifies the
maximum number of concurrent shared server connections that the
database allows.

For best performance with sorts using shared servers, set
SORT_AREA_SIZE and SORT_AREA_RETAINED_SIZE to the same
value. This keeps the sort result in the large pool instead of having
it written to disk.


CURSOR_SPACE_FOR_TIME=true，可以稍许提高性能 但是内存不够会有问题



pga_aggregate_target这个参数

 For OLTP systems, the PGA memory typically accounts for a small fraction of
the total memory available (for example, 20%), leaving 80% for the SGA.

Good initial values for the parameter PGA_AGGREGATE_TARGET might be:
 For OLTP: PGA_AGGREGATE_TARGET = (<total_mem> * 80%) * 20%
For DSS: PGA_AGGREGATE_TARGET = (<total_mem> * 80%) * 50%


WORKAREA_SIZE_POLICY =manual 会使用sort_area_size，但是建议使用pga_aggregate_target


db_cache_advice set on 可以通过 V$DB_CACHE_ADVICE察看db_cache_size的设置情况



如果exp 的时候加上tables参数
则只有tables,constraint,index,trigger过去,function,procedure,view不会过去
exp full=y imp full=y 可能会出现很多错误，但是可以忽略，都是对象已经存在的问题
当tablespace已经存在的时候，他会忽略，如果没有，会创建，包括所有的用户都是如此。



reco  process 适用于分布实事务处理恢复用的
Queue Monitor Processes (QMNn)? 

Database Writer (DBW0 or DBWn)
 Log Writer (LGWR)
  Checkpoint (CKPT)  
 System Monitor (SMON)
 Process Monitor (PMON)
 Archiver (ARCH) 
 Recoverer (RECO)
Lock (LCKn)
Job Queue (SNPn)
Queue Monitor (QMNn) 
 Dispatcher (Dnnn)  
Server (Snnn)  


如何在linux上面用raw device
1.确认你的linux支持raw device,大部分linux都支持. 
2.分区,比方说你的 /dev/hdc1, 假设1000M 
3.#raw /dev/raw/raw1 /dev/hdc1  //这个在每个node上都做
  //这个在每个node上都做
chmod 600 /dev/raw/raw?    //这个在每个node上都做
 //这个在每个node上都做
chown oracle.dba /dev/raw/raw?  //这个在每个node上都做
  //这个在每个node上都做
4.sql> create tablespacce urtablesapce datafile '/dev/raw/raw1' size 1000M reuse; 
另外, 方便起见, 可以在第三步时做个link //这个在每个node上都做
$ln -s /dev/raw/raw1 /oradata/ursid/data01.dbf 

这样, 把第四步的 /dev/raw/raw1 改为 '/oradata/ursid/data01.dbf' 即可 


在

/etc/sysconfig/rawdevices加上raw device 信息，每次即可自动重新加载




(当有多个instance时，需要设置INSTANCE_NUMBER参数，第一个为一，依次类推
需要在init文件中指定其undo tablespace和thread参数）

数据库的恢复
如果数据文件坏了，但是当前的redo log，所有的archived log都在的话，
可以通过重建control file(用backup的control也可以完全恢复),手工完全恢复的
Unfortunately, there is no supported method to recover and open an online backup without the archived redo logs. 
There may be unsupported measures that may or may not be successful. 

可以通过如下方式恢复

startup mount 
recover database using backup controlfile 
CANCEL 

Add these two lines to your init.ora file: 
_allow_resetlogs_corruption=true 
fast_start_parallel_rollback=false  (这个上次试验的时候没有设置，也能恢复)

alert.log

RESETLOGS is being done without consistancy checks. This may result
in a corrupted database. The database should be recreated.
RESETLOGS after incomplete recovery UNTIL CHANGE 103386


shutdown 
startup 

然后exp/imp
Setting that parameter effectively disables instance recovery. 
That includes both roll forward and roll back of uncommitted transactions.
 While this can cause inconsistencies with application data,
  any inconsistencies in dictionary operations that may have been present can be fatal to the database.
   Therefore, the only resolution is to rebuild the database using whatever you have available. 



Error:  ORA 1152  Text:   file <name> was not restored from a sufficiently old backup
Cause:  An incomplete recovery session was started, but an  number 
         of redo logs were applied to make the database consistent.         This file is still in the future of the last redo log applied.         The most likely cause of this message is forgetting to restore the          file from backup before doing incomplete recovery. Action: Apply additional redo log files until the database is consistent or          restore the datafiles from an older backup and repeat recovery. 

如果只有数据文件的备份，没有控制文件，没有redo log
通过下面的恢复
重建控制文件
重建redo log
alter database  clear logfile group 2; 
alter database clear logfile group 1; 
alter database clear logfile group 3; 

当前的logfile不能clear，但是open resetlogs后，会自动创建的

 recover database until cancel using backup controlfile;
 recover database until change 11111 using backup controlfile;
 选则cancel
 
 alter database open resetlogs;


修改字符集

Oracle数据库的汉字显示问题
? 注意
在oracle的使用过程中,如果字符集出现错误.版本在 oracle7 以下的,则允许用以下方法修改;


如果是oracle8版本,则需要使用其他的命令修改,且原来设置的语言必须为美国英语;



对于9版本.则必须重新创建数据库.在创建数据库的过程中设置正确的字符集.
? 


Oracle7版本字符集修改办法
在SQL*Plus中insert进的都是中文的，为什么一存入服务器后，再select出的就是? ? ?了？
? 错误现象： 
1、 有的时候，服务器数据先导出，重装服务器，再导入数据，结果，发生数据查询是出现的是? ? ?。
2、 有时，服务器设置就有问题，字符集设成单字节了。 
? 错误原因： 
一般这种问题产生的原因是因为字符集设置不对造成的。 
? 解决方法： 
1、检查服务器上Oracle数据库的字符集，检查的方法如下：
SQL> connect /as sysdba
连接成功.
SQL> desc props$
列名 可空值否 类型
------------------------------- -------- ----
NAME NOT NULL VARCHAR2(30)
VALUE$ VARCHAR2(2000)
COMMENT$ VARCHAR2(2000)
SQL> col value$ format a40
SQL> select name,value$ from props$;
NAME VALUE$
------------------------------ -------------------------
DICT.BASE 2
NLS_LANGUAGE AMERICAN
NLS_TERRITORY AMERICA
NLS_CURRENCY $
NLS_ISO_CURRENCY AMERICA
NLS_NUMERIC_CHARACTERS .,
NLS_DATE_FORMAT DD-MON-YY
NLS_DATE_LANGUAGE AMERICAN
NLS_CHARACTERSET ZHS16GBK
NLS_SORT BINARY
NLS_CALENDAR GREGORIAN
NLS_RDBMS_VERSION 7.3.4.0.0
GLOBAL_DB_NAME ORACLE.WORLD
EXPORT_VIEWS_VERSION 3
查询出记录.
NLS_CHARACTERSET这个参数应该是ZHS16GBK，如不是，需要修改成此值，修改的方法如下，
SQL*Plus中修改方法：
SQL> update props$ set value$='新字符集' where name='NLS_CHARACTERSET';
操作系统中修改方法：
connect /as sysdba
alter database SID character set ZHS16GBK;
alter database SID national character set ZHS16GBK;
注意修改数据库字符集后需要重启数据库。
2、检查操作系统WINDOWS中Oracle汉字显示的字符集，检查方法如下：
运行regedit，定位到：
HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE
找到以下字符串：
NLS_LANG
检查是否以下内容，如不是，改之，修改方法如下：
SIMPLIFIED CHINESE_CHINA.ZHS16GBK
注意修改数据库字符集后需要重启数据库。





9i的export 可已制定FLASHBACK_SCN，和FLASHBACK_TIME 但是dbms_flashback必须授权给该用户

导数据时 需要用最低版本export,然后用高版本import


When an user gets an ORA-3106 error,
 this can be caused by a difference         in database and client character sets used
 
设置下面的环境变量

export ORA_NLS33=$ORACLE_HOME/ocommon/nls/admin/data 



如果操作系统打了patch,需要到oracle_home/bin下面执行 relink all

The V$PARAMETER view shows the current value for the session
performing the query. The V$SYSTEM_PARAMETER view shows the instance-wide
value for the parameter.


oracle的licence 问题
select name,value from v$parameter where name like 'licen%';

NAME                                                             VALUE
---------------------------------------------------------------- --------------------------------------------------------------------------------
license_max_sessions                                             3
license_sessions_warning                                         0
license_max_users                                                0

concurrent connect指所有可能能够连结到数据库的session,如果sys用户达到license_max_sessions，
其他用户不可以进来，其他用户连结时sys也算连接
1sys+3user不可以
2sys+1user+1sys可以
3user可以

named user包括系统所有的用户就是dba_user里面的所有用户(sys,system都算)



要执行job
需要修改下面的系统参数
ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 50;(是否需要restart)
同时job submit后，需要提交(commit);



oracle 说 transaction commit 时会导致 log switch ,尔 log switch 回导致
check point ，如果alter system set log_checkpoints_to_alert=true;
就会吧check point 得值写道laert中，可是没有

automatic segment-space managent 的tablespace不能有lob字段。

创建pkg时 要把/ 写在第一列
做 tnsname.ora是 名字也要写在第一列

创建db_link时 本机 机器的global_name为true，则db_link名字必须和remote database 的global_name一致
alter database rename global_name to bmm9.benz.com;
如果修改了global_name，restart 以后创建db_link则会和global_name的domain一致
入alter database rename global_name to bmm8.kk.com;
reboot
create database link tp6 connect to taipinglifemain identified by 123 using 'tpl9';
则db_link名字为
TP6.KK.COM  

select *from global_name

名字间的关系
select name,value from v$parameter where name like '%name%';

global_names                                                     FALSE
instance_name                                                    bmm9
service_names                                                    bmm8.my.com
db_name                                                          bmm8


select name,value from v$parameter where name like 'db_domain%';

NAME                                                             VALUE
---------------------------------------------------------------- --------------------------------------------------------------------------------
db_domain                                                        my.com


sid和db_name可以不一致，但是tnsnames.ora里面的service必须和lisner.ora中的sid一致

service_names=db_name.db_domain


赋予用户pkg或则procedure的权限，就等于该用户已pkg创建用户的权限执行（不需要单独授予表的权限）


linux 上的安装 需要修改下面的参数


cd  /proc/sys/kernel
cat sem 

The SEMMSL setting should be 10 plus the
largest PROCESSES parameter of any Oracle
database on the system.
SEMMSL, SEMMNS(256),SEMOPM(100) , SEMMNI(100)
250      32000     32    128


SHMMAX  One-half the size of your system’s physical memory.
echo SEMMSL_value SEMMNS_value SEMOPM_value SEMMNI_value > sem
echo 268435456 > shmmax(2g 2147483648)
echo 250 3200 100 128 >sem

vi /etc/sysctl.conf

生产系统数据库参数
kernel.sysrq = 1
kernel.shmmax = 2147483648 (2g) 268435456 (256M) 1073741824(1g)
kernel.msgmni = 1024
kernel.sem = 100 32000 100 100
fs.file-max = 65535
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 8192
vm.bdflush = 100 1200 128 512 15 5000 500 1884 2

编辑 /etc/rc.local 加上
ulimit -n 65535 ??这个参数没有用？


安装9ir2,配置好参数后(software only)
开始安装 04：02：49
         04:19:56
         需要12分钟
          
dbca 开始 所有可选项不选，不建tablespace
     04:19:56
     04:36:38
     17分钟


     