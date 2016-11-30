20131211
private network Ҫ�߽������������vlan������

The use of a switch (or redundant switches) is required for the private network (crossover cables are NOT supported).

20131206
In 10g and 11g databases, init parameter ACTIVE_INSTANCE_COUNT
 should no longer be set. This is because the RACG layer doesn't take this parameter into account. As an alternative, you should create a service with one preferred instance.



20110521

rac�����µ���ʱ��
-5s -10s ok -15 no(reboot)
+5s +10s ok  +14s ok 




20100915
String url="jdbc:oracle:thin:@" +
				"(DESCRIPTION=" +
				"(failover=on)"+
				"(load_balance=off)" +
		         "(ADDRESS_LIST=" +
						"(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.193.177)(PORT=1521))" +
						"(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.193.136)(PORT=1521))" +
					")"+
					"(CONNECT_DATA=" +
				    	"(SERVER=DEDICATED)" +
					    "(SERVICE_NAME=test)" +
					")" +
			   ")";
			   
20100824
�����Զ�����Դ������
�Զ���ĳ�����Ҫʵ�� profile ,action script (ȱʡ���� crs_home/crs/script)
template��crs_home/templateĿ¼��

�Զ����action script

#!/bin/sh

SCRIPT=$0
ACTION=$1                     # Action (start, stop or check)
. /home/oracle/.bash_profile
cd /npprod/oracle/product/crs/crs/public
export ORACLE_SID=standby
case $1 in
'start')
   sqlplus '/ as sysdba' < startup_standby.sql
    echo "Standby STARTTED"
   export ORACLE_SID=npprod2
   sqlplus '/ as sysdba'  < enable_archive.sql
   exit 0;
    ;;

'stop')
     sqlplus '/ as sysdba' < stop_standby.sql
    echo "Standby STOPPED"
    exit 0
    ;;
'check')
   
     v_ip=$(ps -ef |grep standby |wc -l)
			if [ $v_ip -gt 2 ]
			then
			echo "Standby  CHECKED successful"
			exit 0
			 else
			 echo "Standby  CHECKED failed"
			exit 1
			 fi
    ;;

*)
    echo "usage: $0 {start stop check}"
    ;;

esac

exit 0

����profile 
su -  
crs_profile -create standby -t application -a /npprod/oracle/product/crs/crs/public/standby.sh -d "Standby "  -h hknpdb02  -p restricted  -o as=always,ci=60,ft=2,fi=300,ra=2,st=120,rt=60,pt=120

validate profile 

crs_profile -print  standby        
NAME=standby
TYPE=application
ACTION_SCRIPT=/npprod/oracle/product/crs/crs/public/standby.sh
ACTIVE_PLACEMENT=0
AUTO_START=always
CHECK_INTERVAL=60
DESCRIPTION=Standby
FAILOVER_DELAY=0
FAILURE_INTERVAL=300
FAILURE_THRESHOLD=2
HOSTING_MEMBERS=hknpdb02
OPTIONAL_RESOURCES=
PLACEMENT=restricted
REQUIRED_RESOURCES=
RESTART_ATTEMPTS=2
SCRIPT_TIMEOUT=120
START_TIMEOUT=60
STOP_TIMEOUT=120
UPTIME_THRESHOLD=7d
USR_ORA_ALERT_NAME=
USR_ORA_CHECK_TIMEOUT=0
USR_ORA_CONNECT_STR=/ as sysdba
USR_ORA_DEBUG=0
USR_ORA_DISCONNECT=false
USR_ORA_FLAGS=
USR_ORA_IF=
USR_ORA_INST_NOT_SHUTDOWN=
USR_ORA_LANG=
USR_ORA_NETMASK=
USR_ORA_OPEN_MODE=
USR_ORA_OPI=false
USR_ORA_PFILE=
USR_ORA_PRECONNECT=none
USR_ORA_SRV=
USR_ORA_START_TIMEOUT=0
USR_ORA_STOP_MODE=immediate
USR_ORA_STOP_TIMEOUT=0
USR_ORA_VIP=

chmod a+x standby.* 
�޸�Ȩ��
crs_setperm standby -o root 
crs_setperm standby -u user:oracle:r-x

crs_getperm standby
Name: standby
owner:root:rwx,pgrp:dba:rwx,other::r--,user:oracle:r-x,


register  application
crs_register standby


start applicaiton
crs_start standby
crs_stop -f standby



-bash-3.2# crs_stat -t
Name           Type           Target    State     Host        
------------------------------------------------------------
ora....SM1.asm application    ONLINE    ONLINE    hknpdb01    
ora....01.lsnr application    ONLINE    ONLINE    hknpdb01    
ora....b01.gsd application    ONLINE    ONLINE    hknpdb01    
ora....b01.ons application    ONLINE    ONLINE    hknpdb01    
ora....b01.vip application    ONLINE    ONLINE    hknpdb01    
ora....SM2.asm application    ONLINE    ONLINE    hknpdb02    
ora....02.lsnr application    ONLINE    ONLINE    hknpdb02    
ora....b02.gsd application    ONLINE    ONLINE    hknpdb02    
ora....b02.ons application    ONLINE    ONLINE    hknpdb02    
ora....b02.vip application    ONLINE    ONLINE    hknpdb02    
ora.npprod.db  application    ONLINE    ONLINE    hknpdb01    
ora....d1.inst application    ONLINE    ONLINE    hknpdb01    
ora....d2.inst application    ONLINE    ONLINE    hknpdb02    
standby        application    ONLINE    ONLINE    hknpdb02    

����VIP
crs_profile -create appsvip  -t application  -a $ORA_CRS_HOME/bin/usrvip  -o oi=eth0,ov=138.2.237.23,on=255.255.254.0
crs_setperm appsvip -o root
20100802
����vip�ӹ�ʱ��
10:14:07 shutdown
10:14.19 evicting node hknpdb02
10:15:02 nodedown
10:15:04 tart of `ora.hknpdb02.vip` on member `hknpdb01` succeeded.

���ýű������� �µ�listener 
CRS_home/racg/usrco/callout.sh

#! /bin/bash
FAN_LOGFILE=/npprod/oracle/product/crs/racg/log/myuser.log
echo $* "reported="`date` >> $FAN_LOGFILE 
echo "run user" `whoami`  >> $FAN_LOGFILE 
v_ip=0;
v_count=0;
while [ $v_count -lt 10 -a $v_ip -eq 0 ] 
 do
   v_ip=$(ifconfig -a |grep 192.168.107.24 |wc -l)
     if [ $v_ip -eq 1 ] 
       then
       sh /npprod/oracle/product/crs/racg/userscript/start_vip.sh
      else
       print "count" $v_count " v_ip of 24 didn't started " >> $FAN_LOGFILE        
        v_count=$(($v_count+1))
        sleep 5
     fi
 ddone
 

cat  ../userscript/start_vip.sh        
#! /bin/bash
FAN_LOGFILE=/npprod/oracle/product/crs/racg/log/myuser.log
#su - oracle
. /home/oracle/.bash_profile
cd /npprod/oracle/product/crs/racg/userscript
lsnrctl start LISTENER_HKNPDB02
if [ $? -eq 0 ]
  then
    sqlplus '/ as sysdba ' < register.sql
    date  >> $FAN_LOGFILE 
    print "listener LISTENER_HKNPDB02 started " >> $FAN_LOGFILE &
else 
   print "start listener LISTENER_HKNPDB02 failed  " >> $FAN_LOGFILE &
fi

cat  ../userscript/register.sql 
alter system register;
exit





���Troubleshooting ORA-12545 / TNS-12545 Connect failed because target host or object does not exist  
����


alter system set LOCAL_LISTENER="(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.107.23)(PORT=1521))" scope=both sid='npprod1';
alter system set LOCAL_LISTENER="(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.107.24)(PORT=1521))" scope=both sid='npprod2';

alter system set REMOTE_LISTENER="(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.107.23)(PORT=1521))"  sid='npprod2';
alter system set REMOTE_LISTENER="(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.107.24)(PORT=1521))"  sid='npprod1';



20100719 
instance�޷��Զ�������ԭ��spfileû�д�����
����ͨ�����database_home/log/hknpdb02/racg/im*���ж�

20100621
linux�¶�̬ɨ�����
mppBusRescan
ls -lR /proc/mpp

ÿ��SAN��������ȥ�ֱ���������Controler 

20100613
������os��ʱ�򣬳���crs��ͣ������
/etc/init.crs disable crs
/etc/init.crs enable crs

�󾭹���ϣ��� û�м� -P
chdev -l hdisk7  -a reserve_policy=no_reserve -P
chdev -l hdisk8  -a reserve_policy=no_reserve -P
chdev -l hdisk9  -a reserve_policy=no_reserve -P
chdev -l hdisk10  -a reserve_policy=no_reserve -P
chdev -l hdisk11  -a reserve_policy=no_reserve -P
chdev -l hdisk12  -a reserve_policy=no_reserve -P

Ȼ����� hdisk7,8,�Ҳ��������

[    CSSD]2010-06-13 17:40:19.717 [3858] >TRACE:   clssgmReconfigThread:  completed for reconfig(2), with status(1)
[    CSSD]2010-06-13 17:42:07.398 [1544] >WARNING: clssnmDiskPMT: voting device hang at 50 0.000000atal, termination in 99654 ms disk (0//dev/rhdisk10)
[    CSSD]2010-06-13 17:42:57.400 [1544] >WARNING: clssnmDiskPMT: voting device hang at 75 0.000000atal, termination in 49652 ms disk (0//dev/rhdisk10)
[    CSSD]2010-06-13 17:43:27.403 [1544] >WARNING: clssnmDiskPMT: voting device hang at 90 0.000000atal, termination in 19650 ms disk (0//dev/rhdisk10)
[    CSSD]2010-06-13 17:43:28.403 [1544] >WARNING: clssnmDiskPMT: voting device hang at 90 0.000000atal, termination in 18650 ms disk (0//dev/rhdisk10)
[    CSSD]2010-06-13 17:43:29.403 [1544] >WARNING: clssnmDiskPMT: voting device hang at 90 0.000000atal, termination in 17650 ms disk (0//dev/rhdisk10)
[    CSSD]2010-06-13 17:43:30.403 [1544] >WARNING: clssnmDiskPMT: voting device hang at 90 0.000000atal, termination in 16650 ms disk (0//dev/rhdisk10)
[    CSSD]2010-06-13 17:43:31.403 [1544] >WARNING: clssnmDiskPMT: voting device hang at 90 0.000000atal, termination in 15650 ms disk (0//dev/rhdisk10)
[    CSSD]2010-06-13 17:43:32.403 [1544] >WARNING: clssnmDiskPMT: voting device hang at 90 0.000000atal, termination in 14650 ms disk (0//dev/rhdisk10)
[    CSSD]2010-06-13 17:43:33.403 [1544] >WARNING: clssnmDiskPMT: voting device hang at 90 0.000000atal, termination in 13650 ms disk (0//dev/rhdisk10)
[    CSSD]2010-06-13 17:43:34.403 [1544] >WARNING: clssnmDiskPMT: voting device hang at 90 0.000000atal, termination in 12649 ms disk (0//dev/rhdisk10)

����������ͬʱmount db��ʱ��data group �ֳ���һ�� failover 

 Logical Drive not on preferred path due to ADT/RDAC failover
 
 
 
 
RMAN���ݵ�ʱ��

ORA-27054: NFS file system where the file is created or resides is not mounted with correct options

���ò���
alter system set event='10298 trace name context forever, level 32' scope= spfile ;

20100602
���ڵ��뵽�£����ִ����� 
       SID       SEQ# EVENT                                                            P1TEXT                                                                   P1 P1RAW            P2TEXT                                                                   P2 P2RAW            P3TEXT                                                                   P3 P3RAW            WAIT_CLASS_ID WAIT_CLASS# WAIT_CLASS                                                        WAIT_TIME SECONDS_IN_WAIT STATE
---------- ---------- ---------------------------------------------------------------- ---------------------------------------------------------------- ---------- ---------------- ---------------------------------------------------------------- ---------- ---------------- ---------------------------------------------------------------- ---------- ---------------- ------------- ----------- ---------------------------------------------------------------- ---------- --------------- -------------------
      1059       2188 row cache lock                                                   cache id                                                                  5 0000000000000005 mode                                                                      0 00               request                                                                   5 0000000000000005    3875070507           4 Concurrency                                                              -1               1 WAITED SHORT TIME

�ر�DRM
_gc_affinity_time=0
_gc_undo_affinity=FALSE 

Ȼ����ִ����ģ�˫�ڵ��£�

gc current request


20100528
aix 6.1 
���������ֻ����ping down��vip��Ȼ��Żᱻ�ӹܹ�ȥ

HMC��Ȼ��dhcp server ���ܣ�

ctrl+x smit ����ɾ��



kfod  Disk Size Path User Group
================================================================================
1: 4294013257 Mb /dev/rhdisk15 oracle dba
2: 281 Mb /dev/rhdiskpower3 oracle dba
3: 4294013257 Mb /dev/rhdiskpower6 oracle dba ORACLE_SID ORACLE_HOME
================================================================================
+ASM1 /u01/app/oracle/product/11.1/db

it's obvious wrong size for rhdiskpower6 and rhdisk15.

but we can create a diskgroup with a 1023GB raw device successfully, and kfod report correct size.

Does anybody know the reason? Thanks for any feedback.


�޸�vip 
./srvctl modify nodeapps -n hknpdb01 -A hknpdb01-vip/255.255.255.128/eth8 

(address=(protocol=tcp)(host=node1-vip)(port=1521)(IP=FIRST))?
(address=(protocol=tcp)(host=node1-ip)(port=1521)(IP=FIRST)))



db01:/picclife/oracle/app/oracle$ onsctl  ping 
Number of onsconfiguration retrieved, numcfg = 2
onscfg[0]
   {node = db01, port = 6200}
Adding remote host db01:6200
onscfg[1]
   {node = db02, port = 6200}
Adding remote host db02:6200
ons is not running ...




20070407 crs_stat -t ����

db02:/picclife/oracle/app/oracle$ crs_stat -t
IOT/Abort trap (core dumped)


���ֽڵ��û�� /picclife/oracle/app/oracle/product/crs/crs/auth Ŀ¼
����֮��������


20061206  ���Ի��� 10.2.0.2
�� 10.��ַ,���Ǹ�,�Ǹ�������down
��192,������û������,�������Ӳ���ȥ,ϵͳ���ڲ��ɿ�״̬
rebootһ�ڵ�,����һ�ڵ��ܹ��ӹܹ���,����vipû�нӹܹ�ȥ

��װ���� node3,node4�����֣���hacmp��ԭ����


delete node direct  on aix 

delete oracle_home,crs_home

cd $CRS_HOME/install
rootdelete.sh 
rootdeinstall.sh 

cd /picclife
rm -rf oracle
rm /etc/oratab
rm /etc/oraInst.loc
rm -rf /etc/oracle

rm /etc/init.cssd 
	rm /etc/init.crs 
	rm /etc/init.crsd 
	rm /etc/init.evmd 
	rm /etc/rc.d/rc2.d/K96init.crs
	rm /etc/rc.d/rc2.d/S96init.crs

 rm -Rf /etc/oracle/oprocd 
	rm /etc/inittab.crs  (no)
	cp /etc/inittab.orig /etc/inittab

rm -rf /var/tmp/.oracle
rm -rf /tmp/.oracle/





rmlv racvod 
rmlv racocr
/usr/sbin/mklv -y racocr   -T O -w n   -r n oravg 1   hdisk3
/usr/sbin/mklv -y racvod  -T O -w n   -r n oravg 1    hdisk10
 
chown oracle:dba /dev/rracvod
chown oracle:dba /dev/rracocr
chmod 640 /dev/rracocr
chmod 660 /dev/rracvod


10.2  rac kill ocssd �ᵼ��  node reboot

init->init.cssd->ocssd

change public ip_private ip of clustware 
oifcfg getif
oifcfg delif -global eth0
oifcfg setif �Cglobal eth0/138.2.166.0:public

change vip of clustware
   	srvctl modify nodeapps -n <node_name> [-o <oracle_home>] [-A <new_vip_address>]
   	
After adding debug statements to the init.cssd, we were able to figure out
that the CRS was not starting up because the oprocd was erroring out with 


aix /etc/init.cssd
/etc/init.crs disable 
kill init.cssd or ocssd����node reboot

��� os clustware�� oracle clusterwareͬʱ���ڣ���ôoracle cluster�ᰴ��os clusterware���жϽڵ�����ǳ���10����

- On Unix, the CRS stack is run from entries in /etc/inittab with "respawn".

- If there is a network split (nodes lose communication with each other).  One
  or more nodes may reboot automatically to prevent data corruption.



clustware ����ֱ���޸Ļ���ip,���ǲ����޸�hostname

java.sql.SQLException: Io exception: The Network Adapter could not establish the connection

select username,inst_id from gv$session where username='WZY';


  url="jdbc:oracle:thin:@(DESCRIPTION =    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.1.120)(PORT = 1521)) (CONNECT_DATA =         (SERVICE_NAME = rac)  ) )"
  url="jdbc:oracle:thin:@(DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.1.120)(PORT = 1521))(ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.1.121)(PORT = 1521))(LOAD_BALANCE = off)(FAILOVER = ON)) (CONNECT_DATA = (SERVICE_NAME = rac) ))"
  
  
  ��jdbc thin taf��ʱ��,����һ�ڵ�down��ʱ��,�ֶ�ˢ�����еĽڵ�,�µ����ӻ����ӵ��ڶ����ڵ�
  
  
  http://xmlns.oracle.com/ias/dtds/data-sources-9_04.dtd
  
  
  data-sources.xml
clean-available-connections-threshold CDATA #IMPLIED
rac-enabled CDATA #IMPLIED

���� clean-available-connections-threshold ="3" 
     rac-enabled="true"
���²��� ��ʼ���Ӷ����ڵ�һ  ,abort node1,��Ҫˢ�ºܶ�β����л� 




rman ����
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of backup command at 10/30/2006 13:53:24
RMAN-06059: expected archived log not found, lost of archived log compromises recoverability
ORA-19625: error identifying file /picclife/arch2/2_4_604960154.dbf
ORA-27054: NFS file system where the file is created or resides is not mounted with correct options
Additional information: 6

aix 5.3
# /usr/sbin/vmo -o maxperm%=20
vmo: 1485-111 Invalid value 20 for tunable maxperm%
Value for tunable maxperm% must be greater than or equal to 80, value of tunable maxclient%


export error 
ORA-00600: internal error code, arguments:
[unable to load XDB library], [], [], [], [], [], [], []
ORA-06512: at "SYS.KUPW$WORKER", line 1276

set LIBPATH= export LIBPATH=$ORACLE_HOME/lib:$LIBPATH  on aix
set LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH on other os


To implement the solution, please execute the following steps:

From the erorrs that we see from the RMAN stack this looks like Bug 5146667 

This behaviour has been observed on Solaris and AIX Platform.

WORKAROUND:

As suggested in the bug  the workaround recommended is to use the Event 10298.


1) set the Event 10298 in the init file

event="10298 trace name context forever, level 32"

if you are using the spfile then the following can be done

SQL> alter system set event='10298 trace name context forever, level 32'scope= spfile ;

Once you set the above parameter check as follows

SQL> select name, value from v$parameter where name = 'event';

NAME VALUE
---------- ------------------------------------------------------------
Event 10298 trace name context forever, level 32

1 row selected.

Then try the backups again 


��������sequence(cache,noorder) job
Failover and failback and CLUSTER_INTERCONNECTS are
not supported on AIX systems.

��װ10.2.0.2��ʱ��,��ѡ��CRS��home��������,Ȼ��ѡ��database��home����

vip����Ҫ�ڲ���ϵͳ����,crs����
��������һ��ҪСд,hosts�ļ�һ��Ҫ���ú�

The Oracle Clusterware software must be at the same or newer level as the Oracle software in the Real Application Clusters (RAC) Oracle home. Therefore, you should always upgrade Oracle Clusterware before you upgrade RAC.


����service side��taf
don't set service_name
SHUTDOWN TRANSACTIONAL command with the LOCAL

crsctl enable crs
SRVM_TRACE=true
By default, Oracle enables traces for DBCA and the Database Upgrade Assistant
(DBUA). For the CVU, GSDCTL, SRVCTL, and VIPCA, you can set the SRVM_TRACE
environment variable to TRUE to make Oracle generate traces. Oracle writes traces to
log files. For example, Oracle writes traces to log files in Oracle
home/cfgtoollogs/dbca and Oracle home/cfgtoollogs/dbua for DBCA and
the Database Upgrade Assistant (DBUA) respectively.

10.2�� ocr.loc������ srvConfig.loc

oprocd: Process monitor for the cluster.
�� evmd: Event manager daemon that starts the racgevt process to manage callouts.
�� ocssd: Manages cluster node membership and runs as oracle user; failure of
this process results in node restart.
�� crsd: Performs high availability recovery and management operations such as
maintaining the OCR. Also manages application resources and runs as root user
and restarts automatically upon failure.

oifcfg


Due to dependencies, if you manually shutdown your database, then all of your
services automatically stop. If you then manually restart the database, then you must
also restart the database��s services. Use FAN callouts to automate starting the services
when the database starts.

You can configure your environment to use the load balancing advisory by defining
service-level goals for each service for which you want to enable load balancing.


racgwrap tracing. please edit the script to turn the tracing on  Uncomment the environment variable _USR_ORA_DEBUG=1 in the  $ORA_CRS_HOME/bin/racgwrap 



���crs��������,���Լ�� /var/log/messages, ͨ����ocrû����,����disk full

ͨ�� clsfmt.bin ����ʽ�� ocr
clscfg ����ʼ�� ocr

The Oracle Clusterware automatically creates OCR backups every four hours. At any
one time, Oracle always retains the last three backup copies of the OCR.

�� crs ͣ����ʱ��,����ͨ��crsctl -force ��ǿ���޸�ocr 	
crsctl debug log css CSSD:1 -force


We recommend that you only use this option to create 
     LVs within Big VG type volume groups.
when the "-T O"

Subject:  RACDDT User Guide 
  Doc ID:  Note:301138.1 Type:  BULLETIN 
  Last Revision Date:  10-MAR-2006 Status:  PUBLISHED 
RAC-DDT User Guide  


the ocrconfig command cannot modify OCR
configuration information for nodes that are shut down or for nodes
on which Oracle Clusterware is not running.


[root@rac01 bin]# crsctl add css votedisk /racdata/vot02
Cluster is not in a ready state for online disk addition
����ֹ�������

ocrconfig -repair ocr ���ܹ���
ocrconfig -replace ocr ���ܹ���
����ͨ���Զ����ݵ�ocr���ָ�
ocrconfig  -restore /oracle/10.2/crs/cdata/crs/backup00.ocr 
����exportȻ��
touch /racdata/ocr01
ocrconfig -import ocr.backup20060314 



/10.2.0/crs/bin/crsctl debug log crs OCRSRV:5 

Ҳ��һͨ�� crsctl start crs ������ crs


FAN has two methods for publishing events to clients, the Oracle Notification Service
(ONS), which is used by Java Database Connectivity (JDBC) clients including the
Oracle Application Server 10g, and Oracle Streams, Advanced Queueing which is used
by Oracle Call Interface (OCI) and Oracle Data Provider for .NET (ODP.NET) clients.
When using Advanced Queueing, you must enable the service to use the queue by
setting AQ_HA_NOTIFICATIONS to true.



Services simplify the deployment of TAF. You can define a TAF policy for a service
and all connections using this service will automatically have TAF enabled. This does
not require any client-side changes. The TAF setting on a service overrides any TAF
setting in the client connection definition.


create service 

execute dbms_service.create_service(service_name => 'wzysrv',
network_name => 'wzysrv',
goal =>DBMS_SERVICE.GOAL_THROUGHPUT,
failover_method => dbms_service.failover_method_basic,
failover_type => dbms_service. 
failover_type_select,
clb_goal => dbms_service.clb_goal_long);

���ͨ�� dbca����srvctl ������,��Ȼû��ha������. prefered��avial��ͨ��crs�����Ƶ�,����database

srvctl add service -d rac -s wzysrv3 -r "rac1" -a "rac2" -P BASIC

new view for service 
V$SERVICE_STATS, V$SERVICE_EVENTS, V$SERVICE_WAIT_CLASSES,V$SERVICEMETRIC,V$SERVICEMETRIC_HISTORY
v$active_services

���Դ�ģ�鼶��ļ��
EXECUTE DBMS_MONITOR.SERV_MOD_ACT_STAT_ENABLE(SERVICE_NAME => 'ERP', MODULE_NAME=>
'PAYROLL', ACTION_NAME => 'EXCEPTIONS PAY');
EXECUTE DBMS_MONITOR.SERV_MOD_ACT_STAT_ENABLE(SERVICE_NAME => 'ERP', MODULE_
NAME=>'PAYROLL', ACTION_NAME => NULL);

SELECT * FROM DBA_ENABLED_AGGREGATIONS ;


oifcfg ����������public ���� cluster_interconnect,�������������� global(���нڵ�ͬ����������һ������)���� node specific
vipca ����vip Ҳ��һͨ��srvctl modify nodeapps ���޸�vip



OCRDUMP also creates a log file in CRS_
Home/log/hostname/client. To change the amount of logging, edit the file CRS_
Home/srvm/admin/ocrlog.ini.

cluvfy����־�� crs_home/cv/log

olsnodes -n ���Թ��� lsnodes -n ����


EXECUTE DBMS_SERVICE.MODIFY_SERVICE (service_name => 'gl.us.oracle.com'
, aq_ha_notifications => TRUE
, failover_method => DBMS_SERVICE.FAILOVER_METHOD_BASIC
, failover_type => DBMS_SERVICE.FAILOVER_TYPE_SELECT
, failover_retries => 180
, failover_delay => 5
, clb_goal => DBMS_SERVICE.CLB_GOAL_LONG);

enable Load Balancing Advisory

EXECUTE DBMS_SERVICE.MODIFY_SERVICE (service_name => 'OE'
, goal => DBMS_SERVICE.GOAL_SERVICE_TIME -
, clb_goal => DBMS_SERVICE.CLB_GOAL_SHORT);
EXECUTE DBMS_SERVICE.MODIFY_SERVICE (service_name => 'sjob' -
, goal => DBMS_SERVICE.GOAL_SERVICE_TIME -
, clb_goal => DBMS_SERVICE.CLB_GOAL_LONG);


Setting the goal to NONE disables load balancing for the service

SELECT
TO_CHAR(enq_time, 'HH:MI:SS') Enq_time
, user_data
FROM sys.sys$service_metrics_tab
ORDER BY 1 ;

Oracle recommends that you configure both client-side and
server-side load balancing with Oracle Net Services, which is the default when you
use DBCA to create your database.

You must use the JDBC
Implicit Connection Cache to enable the FAN features of Fast Connection Failover and
Runtime Connection Load Balancing.


enable FAN for jdbc
1.add ons.jar to classpath
2.ods.setONSConfiguration("nodes=racnode1:4200,racnode2:4200"); Configure remote ONS subscription.
3.OracleDataSource ods = new OracleDataSource()
ods.setUser("Scott");
...
ods.setPassword("tiger");
ods.setConnectionCachingEnabled(True);      mush set
ods.setFastConnectionFailoverEnabled(True); mush set
ods.setConnectionCacheName("MyCache");
ods.setConnectionCacheProperties(cp);
ods.setURL("jdbc:oracle:thin:@(DESCRIPTION=
(LOAD_BALANCE=on)
(ADDRESS=(PROTOCOL=TCP)(HOST=VIP1)(PORT=1521))
(ADDRESS=(PROTOCOL=TCP)(HOST=VIP2)(PORT=1521))
(CONNECT_DATA=(service_name=service_name)))");



���һ���ڵ��һ��instance

srvctl add nodeapps -n rac02 -o /oracle/10.2/server -A rac02_vip/255.255.255.0


FAN  service status UP ,DOWN  also load balancing advisory events.

Through
server-side callouts, you can also use FAN to:
�� Log status information
�� Page DBAs or to open support tickets when resources fail to start
�� Automatically start dependent external applications that need to be co-located
with a service
�� Change resource plans or to shut down services when the number of available
instances decreases, for example, if nodes fail
�� Automate the fail back of a service to PREFERRED instances if needed



FAN events are published using ONS and an Oracle Streams Advanced Queuing. The
publication mechanisms are automatically configured as part of your RAC installation.

10g ouiͨ�� inventory.xml��ȷ�� rac �ڵ���

./runInstaller -updateNodeList -noClusterEnabled -local ORACLE_HOME=$ORACLE_HOME CLUSTER_NODES=rac01,rac02

dbca modify service ��ʱ��ͨ�� ocr��ȷ�� instance ��Ŀ





Connection Load Balancing
High Availability Framework
Fast Application Notification (FAN)
Load Balancing Advisory
Fast Connection Failover
Runtime Connection Load Balancing


10g:

Just set the environment variable SRVM_TRACE to true to trace all of the
SRVM files like gsd, srvctl, and ocrconfig.



������� state=UNKNOW ,ͨ������һ��crs��������
��ʱ��س��� vip �������������


[root@rac02 ~]# crs_stat -t
Name           Type           Target    State     Host        
------------------------------------------------------------
ora.rac.db     application    ONLINE    ONLINE    rac01       
ora....c1.inst application    ONLINE    ONLINE    rac01       
ora....c2.inst application    ONLINE    OFFLINE               
ora....srv2.cs application    ONLINE    UNKNOWN   rac01       
ora....ac1.srv application    ONLINE    UNKNOWN   rac01       
ora....srv3.cs application    OFFLINE   OFFLINE               
ora....ac1.srv application    OFFLINE   OFFLINE               
ora....01.lsnr application    ONLINE    UNKNOWN   rac01       
ora.rac01.gsd  application    ONLINE    UNKNOWN   rac01       
ora.rac01.ons  application    ONLINE    UNKNOWN   rac01       
ora.rac01.vip  application    ONLINE    ONLINE    rac01       
ora.rac02.gsd  application    ONLINE    ONLINE    rac02       
ora.rac02.ons  application    ONLINE    ONLINE    rac02       
ora.rac02.vip  application    ONLINE    OFFLINE        

crsctl debug log evm "EVMD:1"


/10.2.0/crs/bin/crsctl debug log crs OCRSRV:5 

Cluster Verification Utility
Oracle Load Balancing Advisory
Oracle Fast Connection Failover (FCF)
Dynamic RMAN Channel Allocation for RAC Environments
Changing the Archiving Mode



This is the safest method of stopping a reboot loop.  After the reboot finishes, 
quickly issue the following as the root user to stop the rebooting:

Sun or Linux:

	/etc/init.d/init.crs disable
	/etc/init.d/init.crs stop

HP-UX or HP Tru64::

	/sbin/init.d/init.crs disable
	/sbin/init.d/init.crs stop

IBM AIX:

	/etc/init.crs disable
	/etc/init.crs stop

Although Red Hat Enterprise Linux 3 and SUSE Linux Enterprise
Server provide a Logical Volume Manager (LVM), this LVM is not cluster-aware. For
this reason, on x86 and Itanium systems, Oracle does not support the use of logical
volumes with RAC for either Oracle Clusterware or database files.




Cloning is the process of copying an existing installation to a different location while
preserving its configuration. You can install multiple copies of the Oracle product
easily on different computers using cloning. During cloning, Oracle Universal Installer
is invoked in clone mode to adapt the home to the target environment. Oracle
Universal Installer in clone mode will replay all the actions that have been executed to
originally install the Oracle home. The difference between installation and cloning is
that, during cloning, Oracle Universal Installer will run the actions in the clone mode.
Each action will decide how to behave during clone time. 




If an application does not scale on an SMP machine, then
moving the application to a RAC database cannot improve
performance.

Consider using hash partitioning for insert-intensive online transaction processing
(OLTP) applications. Hash partitioning:
If you hash partitioned tables and indexes for OLTP environments, then you can
greatly improve performance in your RAC database. Note that you cannot use index
range scans on an index with hash partitioning.

catclustdb.sql

With Oracle Database 10g, you can define application workloads as services so that
you can individually manage and control them


crsctl add css votedisk path
crsctl delete css votedisk path

The OCR contains information
about the cluster node list, instance-to-node mapping information, and information
about Oracle Clusterware resource profiles for applications that you have customized


Oracle Clusterware software cannot be installed on Oracle
Cluster File System (OCFS). Oracle Clusterware can be installed on
network-attached storage (NAS).

You must have JDK 1.4.2 installed on your system before you can run CVU.

/dev/dvdrom/clusterware/cluvfy/runcluvfy.sh comp nodereach -n node1,node2 -verbose

Verify that the unprivileged user nobody exists on the system. The nobody user
must own the external jobs (extjob) executable after the installation.

This user must have the Oracle Inventory group as
its primary group. It must also have the OSDBA and OSOPER groups as
secondary groups.

UDP is the default interconnect protocol for RAC, and TCP is
the interconnect protocol for Oracle Clusterware.



After installation is completed and you have created the
database, if you decide that you want to install additional Oracle
Database 10g products in the 10g Release 2 (10.2) database, then
you must stop all processes running in the Oracle home before you
attempt to install the additional products.


OCR_HOME/cdata/crs/ ����Զ����ݵ�ocr

Use the NOPARALLEL clause of the RMAN RECOVER command or the ALTER
DATABASE RECOVER statement to force Oracle to use non-parallel media recovery.




By default, Oracle enables traces for the DBCA and the Database Upgrade Assistant
(DBUA). For the CVU, GSDCTL, SRVCTL, and VIPCA, you can set the SRVM_TRACE
environment variable to TRUE to make Oracle generate traces.


If the Oracle Clusterware is installed, then the CVU selects all of the configured
nodes from the Oracle Clusterware using the olsnodes utility.

The path for the configuration file is CV_HOME/cv/admin/cvu_config.


To disable parallel instance and crash recovery on a multi-CPU system, set the
RECOVERY_PARALLELISM parameter to 0.


You can run the ALTER DATABASE SQL statement to change the archiving mode in
RAC as long as the database is mounted by the local instance but not open in any
instances. You do not need to modify parameter settings to run this statement.


The resetlogs operation automatically archives online logs. This ensures that your
database has the necessary archived redo logs if recovery was done to a point in time
in the online or in the standby logs.

Oracle recommends that you
disable an object that should remain stopped after you issue a stop
command.


config the shared disk under vmware 

��װ����˵��
ģ����� vmware 3.2 (֧�� as4.0)��ͨ��vmware ��disk ��������ģ��������У�ʵ��RAC

����ϵͳ as4.0 u1

���������
rac01 �� rac02
rac01 ������������ ��eth0 ����public ,eth1 ���� private
rac02 ������������   eth0 ����public ,eth1 ���� private

rac01 ��������ip 
10.0.0.120 (public ip) 192.168.0.1 (private ip) 10.0.0.122(virtual ip)
rac02 ��������ip
10.0.0.121 (public ip) 192.168.0.2 (private ip) 10.0.0.123(virtual ip)

����vmware
�Ȱ�װ��vmware���ο������İ�װ�ĵ���
Ȼ��ֱ�װ����Ϊrac01��rac02����������ο������İ�װ�ĵ���
���ù������
��rac01������������һ�� hard disk(���ֽ� rac.vmdk) ������Ϊ4G,ѡ��Ϊ scsi���ͣ�����Ԥ�ȷ������еĿռ�
�������֮��ѡ�� rac.vmdk ��� advanced���޸�Ϊscsi1:0

�޸� ������������ļ� *.vmx������������仰���Ϳ���ʵ�� ���̱��������������


scsi1.sharedBus = "virtual"
disk.locking = "false"






10.2 rac install


install on redhat 4.0
requirement 

modify kernel parameter

kernel.shmall = 2097152       (8G)
kernel.shmmax = 2147483648    (2G)
kernel.shmmni = 4096         
kernel.sem = 250 32000 100 128
fs.file-max = 65536          
net.ipv4.ip_local_port_range = 1024 65000
net.core.rmem_default = 262144                 --default size of receive buffer used by TCP sockets
net.core.rmem_max = 262144   
net.core.wmem_default = 262144                --Amount of memory allowed for send buffers for TCP socket
net.core.wmem_max = 262144   

sysctl -p
vi /etc/security/limits.conf
oracle12 soft nproc 2047
oracle12 hard nproc 16384
oracle12 soft nofile 1024
oracle12 hard nofile 65536

vi /etc/pam.d/login

session required /lib/security/pam_limits.so
vi /etc/profile
if [ $USER = "oracle" ]; then
if [ $SHELL = "/bin/ksh" ]; then
ulimit -p 16384
ulimit -n 65536
else
ulimit -u 16384 -n 65536
fi
fi

require pacakge (not mandatory ,as4 can pass the universal installer's exam)

make-3.79.1
gcc-3.2.3-34
glibc-2.3.2-95.20
compat-db-4.0.14-5
compat-gcc-7.3-2.96.128    no 
compat-gcc-c++-7.3-2.96.128  no 
compat-libstdc++-7.3-2.96.128 no 
compat-libstdc++-devel-7.3-2.96.128  no
openmotif21-2.1.30-8 
setarch-1.3-1 


��װocfs
For database volumes, a cluster size
	of 128K or larger is recommended. For Oracle home, 32K to 64K.
	
	A cluster size is the smallest unit of space allocated to a file to
	hold the data
	
			/dev/sdX	/dir	ocfs2	noauto,_netdev	0	0


OCFS2 volumes containing the Voting diskfile (CRS), Cluster registry
	(OCR), Data files, Redo logs, Archive logs and control files must 
	be mounted with the "datavolume" and "nointr" mount options. The
	datavolume option ensures that the Oracle processes open these files
	with the o_direct flag. The "nointr" option ensures that the ios
	are not interrupted by signals.
	# mount -o datavolume,nointr -t ocfs2 /dev/sda1 /u01/db
	
Oracle home volume should be mounted normally, that is, without the
	"datavolume" and "nointr" mount options. These mount options are only
	relevant for Oracle files listed above.
	# mount -t ocfs2 /dev/sdb1 /software/orahome
	


No. OCFS2 does not need the o_direct enabled tools. The file system
	allows processes to open files in both o_direct and bufferred mode
	concurrently.
	
	


download the kernel 

http://oss.oracle.com/projects/rhel4kernels/dist/files/2.6.9-11.0.0.10.3.EL/i686/kernel-2.6.9-11.0.0.10.3.EL.i686.rpm
and the ocfs module

���� ocfs2��Ӧ�� module �� tools 
����tools��Ӧ����rpm����һ�����������õģ�һ����gui�ģ�����ʹ�á�
ocfs��Ӧ�������ļ��� /etc/ocfs2/cluster.conf�����Զ�̬�����µĽڵ㣬���������Ҫ�޸��Ѿ����úõ�ip��������ʲô��
��Ҫ��������ocfs�ķ���



http://oss.oracle.com/projects/ocfs2/files/
http://oss.oracle.com/projects/ocfs2tools/files/


ocfs2-tools-1.0.0-1.i386
ocfs2-2.6.9-11.0.0.10.3.EL-1.0.0-1.i686
ocfs2console-1.0.0-1.i386.rpm
�Ȱ�װ kernel �������󣬰�װ ocfs����������һ��Ҫ�Ȱ�װkernel��������Ȼ��װ ocfs)
rpm -ivh kernel-2.6.9-11.0.0.10.3.EL.i686.rpm



��װ���е� ocfs 


rpm -ivh ocfs*.rpm


Including the following module 
NM: Node Manager that keep track of all the nodes in the cluster.conf
HB: Heart beat service that issues up/down notifications when nodes join or leave the cluster
TCP: Handles communication between the nodes
DLM: Distributed lock manager that keeps track of all locks, its owners and status
CONFIGFS: Userspace driven config file system mounted at /config
DLMFS: Userspace interface to the kernel space DLM


execute ocfs2console config the cluster node and shared disk
su - 

export DISPLAY=10.0.0.226:0

first ,config the ocfs to start when os boot


����
parted /dev/sdc
mklabel msdos
mkpart primary 0 4090 

(parted) print                                                            
Disk geometry for /dev/sdc: 0.000-4096.000 megabytes
Disk label type: msdos
Minor    Start       End     Type      Filesystem  Flags
1          0.031   4086.848  primary 



��ʽ�� ocfs �� 
mkfs.ocfs2 -b 4K -C 128k -N 2 -L oracle_home /dev/sdc1
for datafile and voting disk and OCR disk partition



[root@rac01 ~]# mkfs.ocfs2 -b 4K -C 128k -N 2 -L oracle_home /dev/sdc1
mkfs.ocfs2 1.0.0
Filesystem label=oracle_home
Block size=4096 (bits=12)
Cluster size=131072 (bits=17)
Volume size=4285337600 (32694 clusters) (1046208 blocks)
2 cluster groups (tail covers 438 clusters, rest cover 32256 clusters)
Journal size=33554432
Initial number of node slots: 2
Creating bitmaps: done
Initializing superblock: done
Writing system files: done
Writing superblock: done
Writing lost+found: done
mkfs.ocfs2 successful


mkdir /racdata

ִ�� ocfs2console����ocfs
���ó�������
[root@rac01 ~]# /etc/init.d/o2cb  configure
Configuring the O2CB driver.

This will configure the on-boot properties of the O2CB driver.
The following questions will determine whether the driver is loaded on
boot.  The current values will be shown in brackets ('[]').  Hitting
<ENTER> without typing an answer will keep that current value.  Ctrl-C
will abort.

Load O2CB driver on boot (y/n) [y]: 
Cluster to start on boot (Enter "none" to clear) []: ocfs2
Writing O2CB configuration: OK


chkconfig --add o2cb




create /etc/ocfs2/cluster.conf  with the following text 

[root@rac01 ocfs2]# cat cluster.conf
node:
        ip_port = 7777
        ip_address = 10.0.0.120
        number = 0
        name = rac01
        cluster = ocfs2

node:
        ip_port = 7777
        ip_address = 10.0.0.121
        number = 1
        name = rac02
        cluster = ocfs2

cluster:
        node_count = 2
        name = ocfs2




start ocfs service
/etc/init.d/o2cb load
/etc/init.d/o2cb online ocfs2

mount -t ocfs2 -o datavolume /dev/sdc1 /racdata

vi /etc/fstab
�������µ��� ʹ����������

/dev/sdc1      /racdata                  ocfs2   _netdev,datavolume    0 0


����״̬
[root@rac01 ~]# /etc/init.d/o2cb status
Module "configfs": Loaded
Filesystem "configfs": Mounted
Module "ocfs2_nodemanager": Loaded
Module "ocfs2_dlm": Loaded
Module "ocfs2_dlmfs": Loaded
Filesystem "ocfs2_dlmfs": Mounted
Checking cluster ocfs2: Online
Checking heartbeat: Active


������node��ִ��һ�°�װocfs�Ķ�������cluster.conf copy���ڶ����ڵ㣬����ocfs,�ڶ����ڵ㲻��Ҫ�������Ķ�����

������ /config/cluster ���濴���Ƿ�������node ���Ѿ� ocfs������





1.create the clustware user and group(two nodes)
groupadd -g 500 oracle12
useradd -u 501 oracluster -g oracle12
2.create oracle software user
useradd -u 500 oracle12  -g oracle12

2.check nobody exist (two nodes)
id nobody
3.config the ssh for remote copy
node1 

su - oracluster
mkdir ~/.ssh
chmod 755 ~/.ssh
/usr/bin/ssh-keygen -t rsa
/usr/bin/ssh-keygen -t dsa

Ȼ��
Copy the contents of the ~/.ssh/id_rsa.pub and ~/.ssh/id_dsa.pub files to
the ~/.ssh/authorized_keys file on this node and to the same file on all other
cluster nodes.
cat id_dsa.pub >> authorized_keys 
cat id_rsa.pub >> authorized_keys 
chmod 600 ~/.ssh/authorized_keys

4.config profile
.bash_profile

export ORACLE_HOME=/oracle/10.2/crs
export ORACLE_BASE=/oracle
export NLS_LANG=american_america.AL32UTF8
export ORACLE_SID=db12
export DISPLAY=10.0.0.226:0
export PATH=$ORACLE_HOME/bin:$PATH
if [ -t 0 ]; then
stty intr ^C
fi

5.space check
/tmp more than 400m
oracle software need 4g
or u can reset temp
TEMP=/mount_point/tmp
TMPDIR=/mount_point/tmp
export TEMP TMPDIR

6.install 	cvuqdisk-1.0.0-1.i386.rpm
or u can disable the check with
adding the following line to the file
CRS_home/cv/admin/cvuconfig:
CV_RAW_CHECK_ENABLED=FALSE

7.hardware check
ram >=1g
swapspce if ram>=1g and <=2g ,1.5*ram
swapspce if ram>=2g  ,1*ram
8.network check
all node mush have two network adaptor,
one for public ,one for private
and all node must use the same nic for the same purpose.
9.ip config
need three ip
one for public ,one for private,and one for virtual 
vi /etc/hosts  add the following contents

10.0.0.120              rac01.wanzy.com rac01
10.0.0.122              rac01_vip.wanzy.com rac01_vip
10.0.0.121              rac02.wanzy.com rac02
10.0.0.123              rac02_vip.wanzy.com rac02_vip
192.168.0.1             rac01_priv.wanzy.com rac01_priv
192.168.0.2             rac02_priv.wanzy.com rac02_priv

10.�޸�Ŀ¼�û���two nodes)

chown oracle12:oracle12 /racdata/

���� oracle clustware���ܰ�װ�� ocfs �Ϲ���������Ҫ���������� Ŀ¼
���� oracle ��װ�ĳ����ļ�Ŀ¼ (clusterware and oracle database �ļ���

mkdir /oracle
chown oracle12:oracle12 /oracle

chmod 775 /racdata/
chmod 775 /oracle




11. ��װ clusterware
��Ҫ��Ҫ��ʹ������node��ʱ����Ҫ����Ϊһ����


./runcluvfy.sh stage -pre crsinst   -n rac01,rac02

���⣬���������ʱ��ocfs panic the kernel



[root@rac01 oraInventory]# ./orainstRoot.sh 
Changing permissions of /oracle/oraInventory to 770.
Changing groupname of /oracle/oraInventory to oracle12.
The execution of the script is complete



������root.sh

[root@rac01 crs]# sh root.sh 
WARNING: directory '/oracle/10.2' is not owned by root
WARNING: directory '/oracle' is not owned by root
Checking to see if Oracle CRS stack is already configured
/etc/oracle does not exist. Creating it now.

Setting the permissions on OCR backup directory
Setting up NS directories
Oracle Cluster Registry configuration upgraded successfully
WARNING: directory '/oracle/10.2' is not owned by root
WARNING: directory '/oracle' is not owned by root
assigning default hostname rac01 for node 1.
Successfully accumulated necessary OCR keys.
Using ports: CSS=49895 CRS=49896 EVMC=49898 and EVMR=49897.
node <nodenumber>: <nodename> <private interconnect name> <hostname>
node 1: rac01 rac01_priv rac01
Creating OCR keys for user 'root', privgrp 'root'..
Operation successful.
Now formatting voting device: /racdata/vot01
Format of 1 voting devices complete.
Startup will be queued to init within 90 seconds.
Adding daemons to inittab
Expecting the CRS daemons to be up within 600 seconds.
CSS is active on these nodes.
        rac01
CSS is active on all nodes.
Waiting for the Oracle CRSD and EVMD to start
Waiting for the Oracle CRSD and EVMD to start
Waiting for the Oracle CRSD and EVMD to start
Waiting for the Oracle CRSD and EVMD to start
Oracle CRS stack installed and running under init(1M)
Running vipca(silent) for configuring nodeapps
The given interface(s), "eth0" is not public. Public interfaces should be used to configure virtual IPs.

When verifying the IP addresses, VIP uses calls to determine if a IP address is valid or not. 
In this case, VIP finds that the IPs are non routable (For example IP addresses like 192.168.* and 10.10.*.)
rerun vipca under root 

12.��װdatabase 
�����û� oracle12
cat ~/.bash_profile
export PATH
unset USERNAME
export ORACLE_HOME=/oracle/10.2/server
export ORACLE_BASE=/oracle
export NLS_LANG=american_america.AL32UTF8
export ORACLE_SID=rac01
export DISPLAY=10.0.0.226:0
export PATH=$ORACLE_HOME/bin:$PATH

���ú� ssh 
[root@rac01 server]# sh root.sh
Running Oracle10 root.sh script...

The following environment variables are set as:
    ORACLE_OWNER= oracle12
    ORACLE_HOME=  /oracle/10.2/server

Enter the full pathname of the local bin directory: [/usr/local/bin]: 
The file "dbhome" already exists in /usr/local/bin.  Overwrite it? (y/n) 
[n]: 
The file "oraenv" already exists in /usr/local/bin.  Overwrite it? (y/n) 
[n]: 
The file "coraenv" already exists in /usr/local/bin.  Overwrite it? (y/n) 
[n]: 


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root.sh script.
Now product-specific root actions will be performed.


13.���� database
log file ���� $ORACLE_HOME/cfgtoollogs
��netca����listener
ִ��dbca

14.clone���ڶ���node
For all of the add node and delete node procedures for
UNIX-based systems, temporary directories such as /tmp, $TEMP, or
$TMP, should not be shared directories. If your temporary directories
are shared, then set your temporary environment variable, such as
$TEMP, to a non-shared location on a local node.

14.1 first clone the clusterware to rac02
1.on rac01
su - oracluster
cd $ORACLE_HOME/oui/bin
addNode.sh �����µ�node����

on rac02
ִ�� cd  oraInventory 
sh orainstRoot.sh 
on rac01 
cd /oracle/10.2/crs/install/

[root@rac01 install]# sh rootaddnode.sh 
clscfg: EXISTING configuration version 3 detected.
clscfg: version 3 is 10G Release 2.
Attempting to add 1 new nodes to the configuration
Using ports: CSS=49895 CRS=49896 EVMC=49898 and EVMR=49897.
node <nodenumber>: <nodename> <private interconnect name> <hostname>
node 2: rac02 rac02_priv rac02
Creating OCR keys for user 'root', privgrp 'root'..
Operation successful.
/oracle/10.2/crs/bin/srvctl add nodeapps -n rac02 -A rac02_vip/255.255.255.0/eth0 -o /oracle/10.2/crs


on rac02 
cd /oracle/10.2/crs/
sh root.sh
����ֺ�rac01һ�������⣬
��Ҫ�ֹ�ִ�� vipca ���� ���ִ���ignore

�����־ crs/log/db02/client/css.log  �ڼ�鰲װ��ʱ�򣬷ǳ���Ҫ


cd $ORACLE_HOME/opmn/conf
cat ons.config
2.on rac01
 
racgons add_config rac02:6200
3.check if the new node added successed
cluvfy comp clumgr -n all -verbose    verifying cluster manager integrity
cluvfy comp clu -verbose               verifying  cluster integrity
cluvfy comp stage -post crinst -n all perform an integrated validation

14.2 clone database software to rac02
1.on rac01
su - oracle12
cd $ORACLE_HOME/clone/bin


perl prepare_clone.pl

cp $ORACLE_HOME�������ݵ�rac02
2.on rac02

perl <Oracle_Home>/clone/bin/clone.pl  ORACLE_HOME==/oracle/10.2/server ORACLE_HOME_NAME=rac10g

[oracle12@rac02 bin]$ perl clone.pl ORACLE_HOME=/oracle/10.2/server ORACLE_HOME_NAME=rac10g
Properties file /config/cs.properties was not found. Failed loading correponding properties../runInstaller -silent -clone -waitForCompletion  "ORACLE_HOME=/oracle/10.2/server" "ORACLE_HOME_NAME=rac10g"  
Starting Oracle Universal Installer...

No pre-requisite checks found in oraparam.ini, no system pre-requisite checks will be executed.
Preparing to launch Oracle Universal Installer from /tmp/OraInstall2005-12-05_02-28-48PM. Please wait ...Oracle Universal Installer, Version 10.2.0.1.0 Production
Copyright (C) 1999, 2005, Oracle. All rights reserved.

You can find a log of this install session at:
 /oracle/oraInventory/logs/cloneActions2005-12-05_02-28-48PM.log
.................................................................................................... 100% Done.



Installation in progress (Mon Dec 05 14:45:11 EST 2005)
.......................................................................                                                         71% Done.
Install successful

Linking in progress (Mon Dec 05 14:45:39 EST 2005)
.                                                                72% Done.
Link successful

Setup in progress (Mon Dec 05 14:55:26 EST 2005)
................                                                100% Done.
Setup successful

End of install phases.(Mon Dec 05 14:55:44 EST 2005)
WARNING:The following configuration scripts 
/oracle/10.2/server/root.sh
need to be executed as root for configuring the system.
 
The cloning of rac10g was successful.
Please check '/oracle/oraInventory/logs/cloneActions2005-12-05_02-28-48PM.log' for more details.
[oracle12@rac02 bin]$ 
2.run root.sh on rac02

3.run netca on rac02 

14.3 add instance on rac02
run dbca 
dbca -silent -addInstance -nodeList rac02 -gdbName rac -instanceName rac2 -sysDBAUserName sysdba -sysDBAPassword sys


alter database add logfile thread 2 '/racdata/rac/log21' size 10m;
alter database add logfile thread 2 '/racdata/rac/log22' size 10m;
alter database enable thread 2;
create undo tablespace UNDOTBS2  datafile '/racdata/rac/undotbs2' size 100m;

ini.ora

*.audit_file_dest='/oracle/admin/rac/adump'
*.background_dump_dest='/oracle/admin/rac/bdump'
*.cluster_database_instances=2
*.cluster_database=true
*.compatible='10.2.0.1.0'
*.control_files='/racdata/rac/control01.ctl','/racdata/rac/control02.ctl','/racdata/rac/control03.ctl'
*.core_dump_dest='/oracle/admin/rac/cdump'
*.db_block_size=8192
*.db_domain=''
*.db_file_multiblock_read_count=16
*.db_name='rac'
*.db_recovery_file_dest='/racdata/flash_recovery_area'
*.db_recovery_file_dest_size=2147483648
*.dispatchers='(PROTOCOL=TCP) (SERVICE=racXDB)'
rac1.instance_number=1
rac2.instance_number=2
*.job_queue_processes=10
*.open_cursors=300
*.pga_aggregate_target=16777216
*.processes=150
*.remote_listener='LISTENERS_RAC'
*.remote_login_passwordfile='exclusive'
*.sga_target=167772160
rac1.thread=1
rac2.thread=2
*.undo_management='AUTO'
rac1.undo_tablespace='UNDOTBS1'
rac2.undo_tablespace='UNDOTBS2'
*.user_dump_dest='/oracle/admin/rac/udump'

initrac1.ora
spfile='/racdata/spfile'

rac =
  (DESCRIPTION =
    (ADDRESS_LIST =
    (load_balance=on)
    (failover=on)
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.0.122)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.0.123)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = rac)
      )
  )

RAC1 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.0.122)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = rac)
      (INSTANCE_NAME = rac1)
    )
  )
RAC2 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.0.123)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = rac)
      (INSTANCE_NAME = rac2)
    )
  )




15.�޸� clusterware�Զ����� database�� policy

srvctl config database -d rac -a
srvctl modify database -d rac  -y manual  (automatic manual)

�����:�ڰ�װclusterware��ʱ�� ִ��root.sh ���޷�����������


[root@rac01 oraInventory]# sh orainstRoot.sh 
Changing permissions of /oracle/oraInventory to 770.
Changing groupname of /oracle/oraInventory to oracle12.
The execution of the script is complete
[root@rac01 oraInventory]# cd /oracle/10.2/crs/
[root@rac01 crs]# sh root.sh 
WARNING: directory '/oracle/10.2' is not owned by root
WARNING: directory '/oracle' is not owned by root
Checking to see if Oracle CRS stack is already configured
/etc/oracle does not exist. Creating it now.

Setting the permissions on OCR backup directory
Setting up NS directories
Oracle Cluster Registry configuration upgraded successfully
WARNING: directory '/oracle/10.2' is not owned by root
WARNING: directory '/oracle' is not owned by root
assigning default hostname rac01 for node 1.
Successfully accumulated necessary OCR keys.
Using ports: CSS=49895 CRS=49896 EVMC=49898 and EVMR=49897.
node <nodenumber>: <nodename> <private interconnect name> <hostname>
node 1: rac01 rac01_priv rac01
Creating OCR keys for user 'root', privgrp 'root'..
Operation successful.
Now formatting voting device: /racdata/vot01
Format of 1 voting devices complete.
Startup will be queued to init within 90 seconds.


metalink answer

 If it does not change anything, set message_logging_level=5 in $CRS_HOME/srvm/admin/ocrlog.ini and then strace execute "sh -x root.sh" and capture the output. 



[oracluster@rac01 ~]$ /oracle/10.2/crs/bin/cluvfy stage -post crsinst -n rac01

Performing post-checks for cluster services setup 

Checking node reachability...
Node reachability check passed from node "rac01".


Checking user equivalence...
User equivalence check passed for user "oracluster".

Checking Cluster manager integrity... 


Checking CSS daemon...
Daemon status check failed for "CSS daemon".
Check failed on nodes: 
        rac01

Cluster manager integrity check failed.

Checking cluster integrity... 


Cluster integrity check failed. This check did not run on the following nodes(s): 
        rac01


Checking OCR integrity...

Checking the absence of a non-clustered configuration...
All nodes free of non-clustered, local-only configurations.


ERROR: 
Unable to obtain OCR integrity details from any of the nodes.


OCR integrity check failed.

Checking CRS integrity...

Checking daemon liveness...
Liveness check failed for "CRS daemon".
Check failed on nodes: 
        rac01

Checking daemon liveness...
Liveness check failed for "CSS daemon".
Check failed on nodes: 
        rac01

Checking daemon liveness...
Liveness check failed for "EVM daemon".
Check failed on nodes: 
        rac01

CRS integrity check failed.

Post-check for cluster services setup was unsuccessful on all the nodes. 
[oracluster@rac01 ~]$ 


init.crs stop start ���� clusterware



10.1



10grac

crs ��home�����db home��һ��

1.�����û�
groupadd -g 514 oracle12
useradd -u 514 -g oracluster  oracle12
2.����ssh����(����ftp123)
������node�ֱ�ִ��

su - oracle12
mkdir ~/.ssh
chmod 755 ~/.ssh
/usr/bin/ssh-keygen -t rsa
/usr/bin/ssh-keygen -t dsa

Ȼ��
Copy the contents of the ~/.ssh/id_rsa.pub and ~/.ssh/id_dsa.pub files to
the ~/.ssh/authorized_keys file on this node and to the same file on all other
cluster nodes.
cat id_dsa.pub >> authorized_keys 
cat id_rsa.pub >> authorized_keys 
chmod 644 ~/.ssh/authorized_keys
3.�޸Ļ�������
vi .bash_profile

ulimit -u 16384 -n 65536

4.crs�ô��̿ռ�

ͨ��ocfs mountһ��2000m�Ŀռ�
mkfs.ocfs -b 128 -C -F -g oracle12 -u oracle12 -L oracle12ocfs -m /tpdata/oracle12 -p 755 /dev/sde1
chown oracle12:oracle12 /tpdata/oracle12/
�޸�/etc/fstab����
/dev/sde1                /tpdata/oracle12/             ocfs      _netdev       0 0 

5����hangcheck-timer
insmod hangcheck-timer hangcheck_tick=30 hangcheck_margin=180
6.��װcrs
ͣ�����е�oracle���н���


����Ҫ����ORACLE_SID, ORACLE_HOME, or ORACLE_BASE
$ unset ORACLE_HOME
$ unset TNS_ADMIN

private name��public name������ͬ
��private������ip

You must classify at least one interconnect as Public
and one as Private.

��װ��ɺ�����
./olsnodesȷ������node����

��װ���ݵ�ʱ�������crs����
������vip,gsd,ons�����ýű�
init�ļ�

*.background_dump_dest='/tpdata/oracle12/admin/tprac/bdump'
*.cluster_database=true
*.cluster_database_instances=4
*.compatible='10.1.0.2.0'
*.control_files='/tpdata/oracle12/oradata/tprac'
*.core_dump_dest='/tpdata/oracle12/admin/tprac/cdump'
*.db_block_size=8192
*.db_cache_size=152428800
*.db_name='tprac'
*.java_pool_size=10485760
*.job_queue_processes=5
*.large_pool_size=1048576
*.log_archive_dest_1='LOCATION=/tpdata/oracle12/oradata/tprac/archive'
*.log_archive_format='%t_%s_%r.arc'
*.open_cursors=300
*.processes=250
*.remote_login_passwordfile='EXCLUSIVE'
*.shared_pool_size=152428800
*.sort_area_size=5242880
*.timed_statistics=TRUE
*.undo_management='AUTO'
*.user_dump_dest='/tpdata/oracle12/admin/tprac/udump'
rac01.undo_tablespace='UNDOTBS'
rac02.undo_tablespace='UNDOTBS2'
rac01.instance_name='rac01'
rac02.instance_name='rac02'
rac01.instance_number=1
rac02.instance_number=2
rac02.local_listener='LISTENER_RAC02'
rac01.local_listener='LISTENER_RAC01'
rac02.remote_listener='LISTENER_RAC01'
rac01.remote_listener='LISTENER_RAC02'
rac01.remote_login_passwordfile='exclusive'
rac02.remote_login_passwordfile='exclusive'
rac01.thread=1
rac02.thread=2

log_archive_start �Ѿ����Ƽ�ʹ��

orapwd file=/tpdata/rac/oracle12/10.1.0.2/dbs/orapwtprac1 password=sys
orapwd file=/tpdata/rac/oracle12/10.1.0.2/dbs/orapwtprac2 password=sys

vi $ORACLE_HOME/network/admin/tnsnames.ora
����
rac01 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.70)(PORT = 1521))
    )
    (CONNECT_DATA =
   (SERVICE_NAME = tprac)
   (instance_name=rac01)
   )
  )
rac02=
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.71)(PORT = 1521))
    )
    (CONNECT_DATA =
   (SERVICE_NAME = tprac)
   (instance_name=rac02)
   )
  )
rac =
  (DESCRIPTION =
    (ADDRESS_LIST =
    (load_balance=on)
    (failover=on)
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.70)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.71)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = tprac)
      )
  )
listeners_rac=
(address=(protocol=tcp)(host=10.1.1.70)(port=1521))
(address=(protocol=tcp)(host=10.1.1.71)(port=1521))
LISTENER_RAC01 =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.70)(PORT = 1521))
LISTENER_RAC02 =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.71)(PORT = 1521))
  
  vi $ORACLE_HOME/network/admin/listener.ora
  ����
  
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS_LIST =
        (ADDRESS = (PROTOCOL = TCP)(HOST = 10.1.1.70)(PORT = 1521))
      )
    )
  )

startup nomount exclusive

create database tprac
 maxinstances 10
 maxlogfiles 20
 maxlogmembers 3
 maxdatafiles 100
 archivelog
 character set AL32UTF8
 NATIONAL CHARACTER SET AL16UTF16
 datafile '/tpdata/oracle12/oradata/tprac/system01.dbf' size 350m EXTENT MANAGEMENT LOCAL
 SYSAUX DATAFILE '/tpdata/oracle12/oradata/tprac/systemaux01.dbf' size 100m
 undo tablespace UNDOTBS datafile '/tpdata/oracle12/oradata/tprac/undo01.dbf' size 95m
 default temporary tablespace temp tempfile '/tpdata/oracle12/oradata/tprac/temp01.dbf' size 95m
 logfile
 '/tpdata/oracle12/oradata/tprac/red01.log' size 10m,
 '/tpdata/oracle12/oradata/tprac/red02.log' size 10m
/


ORA-12720: operation requires database is in EXCLUSIVE mode

�޸� cluster_databaseΪfalse��Ϊ����archivelogģʽ


ȱʡ��ȻΪ  EXTENT MANAGEMENT DICTIONARY?
create tablespace SYSTEM datafile  '/tpdata/oracle12/oradata/tprac/system01.dbf' size 350m
  default storage (initial 10K next 10K) EXTENT MANAGEMENT DICTIONARY online
  
spool cat.log
@?/rdbms/admin/catalog.sql;
@?/rdbms/admin/catproc.sql;
@?/rdbms/admin/catclust.sql;        --Create all cluster database specific views
@?/rdbms/admin/catblock.sql;       --create views of oracle locks
@?/rdbms/admin/catexp7.sql;
@?/rdbms/admin/catoctk.sql;          --Contains scripts needed to use the PL/SQL Cryptographic Toolkit Interface

alter user system identified by system;    --sqlplus help
conn system/system;                         
@?/sqlplus/admin/pupbld.sql
@?/sqlplus/admin/help/hlpbld.sql helpus.sql;
spool off

create undo tablespace UNDOTBS2 datafile '/tpdata/oracle12/oradata/tprac/undo02.dbf' size 95m;
alter database add logfile thread 2 '/tpdata/oracle12/oradata/tprac/redo03.log' size 10m;
alter database add logfile thread 2 '/tpdata/oracle12/oradata/tprac/redo04.log' size 10m;

alter database enable thread 2;



����crs registry

ͨ��ocrconfig ����

vipca����VIRTUAL IP(��Ҫroot����)

ͨ��dbca������service?


��־�ļ�
<CRS Home>/crs/init
<CRS Home>/crs/<node name>.log
<CRS Home>/srvm/log/
<CRS Home>/css/log/ocssd<number>.log
<CRS Home>/css/init/<node_name>.log
<CRS Home>/evm/log/evmdaemon.log
<CRS Home>/evm/log/evmdaemon.log
$ORACLE_BASE/<database_name>/admin/hdump


<CRS Home>/bin/crs_stat���Բ쿴crs�ø�����Ϣ

kill -9 /etc/init.d/init.cssd fatal�ᵼ�¸ýڵ��vip�ᱻ����һ��node�ӹ�


��־�ļ����binary���쿴�����㣬��tail -f ���ǿ��Կ���(ʹ��ocfs�ù�ϵ)
