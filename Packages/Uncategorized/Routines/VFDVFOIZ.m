VFDVFOIZ ;DSS/SGM - INITIALIZE A CACHE.DAT CLONE ; 12/05/2011 12:30
 ;;2010.1;DSS,INC VXVISTA OPEN SOURCE;**1**;05 Jan 2010;Build 92
 ;Copyright 1995-2010,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is designed to quickly set up a copy of an existing
 ;Cache.dat file on another Cache configuration.
 ;
 ; ICR#   Supported Description
 ; -----  -------------------------------------------------------------
 ;  2050  MSG^DIALOG
 ; 10006  ^DIC
 ; 10018  ^DIE
 ;  2053  FILE^DIE
 ;  2055  $$ROOT^DILFD
 ; 10103  DT^XLFDT
 ; 10104  $$CJ^XLFSTR
 ;  2171  $$STA^XUAF4
 ;  4129  DUZ^XUP - controlled subscription, not a subscriber
 ;  4409  DTIME^XUP
 ; 10086  HOME^%ZIS
 ; 10097  ^%ZOSV: GETENV,$$VERSION
 ; 10096  ^%ZOSF - referenceing any node
 ;        ------------ NO ICR SUPPORTING THESE REFERENCES ------------
 ;        SETUP^MPIFAPI - no ICR - 2702 is the standard ICR
 ;        ^%ZOSF - setting nodes not supported
 ;        ^%ZTSCH - read, write, delete
 ;        ^%ZTSK - read, write, delete
 ;        Fileman read/write/delete access and/or direct global read
 ;          to the following files
 ;          4, 4.2, 4.3, 14.5, 14.7, 40.8, 389.9, 984.1, 8989.3, 8994.1
 ;        Reference to Cache specific functions
 ;
 ; Description of DATA("OLD",subscript) and DATA("NEW",subscript)
 ;  Subscript         Value                  Source
 ; ------------  ---------------  -------------------------------------
 ; MGR,PROD,VOL  Cache namespace  ^%ZOSF(subscript)
 ; UV            nmsp,nmsp        PROD,VOL
 ; Values from the INSTITUTION file (#4)
 ;   4           ien              File 4
 ;   INST        Institute name   .01 field from file 4
 ;   STANUM      station number   99 field from file 4
 ; Values from the DOMAIN file (#4.2)
 ; sub = subordinate DOMAIN   par = parent DOMAIN
 ;   4.2,"SUB"   ien              File 4.2 for sub domain
 ;   4.2,"PAR"   ien              File 4.2 for parent domain 
 ;   DOM         subordinate      .01 field from 4.2
 ;   DOMPAR      parent           .01 field from 4.2
 ; Values from the VOLUME SET file (#14.5)
 ;   14.5        ien              File 14.5
 ;   VOLF        Vol Set name     .01 field from 14.5
 ; Values from the Taskman Site Parameter file (#14.7) - box-pair
 ;   14.7        ien              File 14.7
 ;   BOX         box-pair name    .01 field from 14.7
 ;   CONFG       Cache config     2nd ^-piece from $$GETENV^%ZOSV
 ;
 ; NMSP = current namespace name
 ;  BOX = NMSP_":"_$P($P(GETENV^%ZOSV,U,4),":",2)
 ;  
 Q:$$VERSION^%ZOSV(1)'["Cache"
 N I,J,R,X,Y,Z,BOX,DATA,EQ,LINE,MSG,NMSP,SUB,VERR
 N DUZ D INIT
 S R="DATA(SUB)"
 ; gather system information
 ; get cloned cache namespace
 S SUB="OLD" F X="MGR","PROD","VOL" S @R@(X)=^%ZOSF(X)
 S @R@("UV")=@R@("PROD")_","_@R@("VOL")
 ;
 ; get current cache namespace
 S SUB="NEW" F X="MGR","PROD","VOL" S @R@(X)=NMSP
 S @R@("UV")=NMSP_","_NMSP
 ;
 ; volume set name
 K Z S I=0
 F  S I=$O(^%ZIS(14.5,I)) Q:'I  S X=^(I,0),Z(I)=X,Z("B",$P(X,U))=I
 S Z=$G(Z("B",NMSP)) S:'Z Z=+$O(Z(0)) S X=$P($G(Z(Z)),U)
 ; expect at least one entry
 S Y="ERROR - Expected at least one entry in the VOLUME SET file"
 I 'Z W !!,Y Q
 S SUB="OLD",@R@(14.5)=Z,@R@("VOLF")=X
 S SUB="NEW",@R@(14.5)=Z,@R@("VOLF")=NMSP
 ;
 ; taskman site parameter name
 K Z S I=0
 F  S I=$O(^%ZIS(14.7,I)) Q:'I  S X=^(I,0),Z(I)=X,Z("B",$P(X,U))=I
 S Z=$G(Z("B",BOX)) S:'Z Z=+$O(Z(0)) S X=$P($G(Z(Z)),U)
 ; expected at least one entry
 S Y="ERROR - Expected at least one entry in the TASKMAN SITE PARAM file"
 I 'Z W !!,Y Q
 S SUB="OLD",@R@(14.7)=Z,@R@("BOX")=X,@R@("CONFG")=$P(X,":",2)
 S SUB="NEW",@R@(14.7)=Z,@R@("BOX")=BOX,@R@("CONFG")=$P(BOX,":",2)
 ;
 D HDR Q:'$$DIR
 D ZOSF
 D VOL
 D TSP
 D DOM I '$D(DATA("NEW","DOMPAR")) G OUT
 D INST I '$D(DATA("NEW","INST")) G OUT
 ; Next 3 files - DINUM=1 and pointers to subordinate domain
 D KSP
 D RPC
 D MSP
 ;
 D STA
 D MPI
 ; now go through taskman globals and clean up
 D ZTCLEAN(.DATA)
OUT ;
 W !,EQ
 I $O(MSG(0)) D
 .W !!,">>> Messages",!,LINE
 .S I=0 F  S I=$O(MSG(I)) Q:'I  W !,MSG(I)
 .Q
 I $O(VERR(0)) D
 .W !,EQ,!!,">>> Error Messages",!,LINE
 .S I=0 F  S I=$O(VERR(I)) Q:'I  W !,VERR(I)
 .Q
 Q
 ;
 ;--------------  doit - make the changes to the system  --------------
DOM ; create domain subordinate and parent
 ;;*** Edit DOMAIN file entries ***
 ;;    1. Edit the Domain first (e.g. vos.vxvista.org)
 ;;       > Edit the name of the entry from which this was cloned
 ;;       > Then edit the TRANSMISSION SCRIPT
 ;;    2. Edit the Parent Domain
 ;;       > Edit the parent domain of the Domain in (1)
 ;;       > If necessary, edit the TRANSMISSION SCRIPT
 ;;  
 ;;***** Edit the subordinate domain entry now *****
 ;;You must configure the subordinate Domain in order to continue
 ;;***** Edit the parent domain entry now *****
 ;;You must configure the parent Domain in order to continue
 N I,J,T,X,Y,Z,NEW,OLD,VIEN
 W !!,LINE F I=1:1:9 W !,$TR($T(DOM+I),";"," ")
 S X=$$DIC(4.2,1) I X<1 D ERR($TR($T(DOM+10),";"," ")) W !,EQ Q
 S VIEN=+X,OLD=$P(X,U,2)
 S DATA("OLD",4.2,"SUB")=$S('$P(X,U,3):VIEN,1:"")
 S DATA("OLD","DOM")=$S('$P(X,U,3):OLD,1:"")
 S DATA("NEW",4.2,"SUB")=VIEN
 D DIECLASS(4.2,VIEN,".01;4")
 S NEW=$P(^DIC(4.2,VIEN,0),U),DATA("NEW","DOM")=NEW
 S X="Subordinate Domain"
 I OLD=NEW D MSG(X,1)
 I OLD'=NEW D MSG(X_" changed from "_OLD_" to "_NEW)
 ; edit the parent domain
 W !!,LINE,!,$TR($T(DOM+11),";"," ")
 S X=$$DIC(4.2) I X<1 D ERR($TR($T(DOM+12),";"," ")) W !,EQ Q
 S VIEN=+X,OLD=$P(X,U,2)
 S DATA("OLD",4.2,"PAR")=$S('$P(X,U,3):VIEN,1:"")
 S DATA("OLD","DOMPAR")=$S('$P(X,U,3):OLD,1:"")
 S DATA("NEW",4.2,"PAR")=VIEN
 D DIECLASS(4.2,VIEN,".01;4")
 S NEW=$P(^DIC(4.2,VIEN,0),U),DATA("NEW","DOMPAR")=NEW
 S X="Parent Domain"
 I OLD=NEW D MSG(X,1)
 I OLD'=NEW D MSG(X_" changed from "_OLD_" to "_NEW)
 W !,LINE,!
 Q
 ;
INST ;
 ;;*** Select/Edit INSTITUTION file entry ***
 ;;    If you do not have a STATION NUMBER assigned, then STOP
 ;;    Get that assigned number before proceeding any further
 ;;You must select an INSTITUTION file entry in order to continue
 ;;The INSTITUTION file entry must have a station number
 N I,X,Y,Z,NM,OLD,STA,VIEN
 W !!,LINE F I=1:1:3 W !,$TR($T(INST+I),";"," ")
 Q:'$$DIR
 S X=$$DIC(4,1) I X<1 D ERR($TR($T(INST+4),";"," ")) W !,EQ Q
 S VIEN=+X,NM=$P(X,U,2),STA=$$STA^XUAF4(VIEN)
 I STA<1 D ERR($TR($T(INST+5),";"," ")) W !,EQ Q
 S DATA("NEW",4)=VIEN,DATA("NEW","INST")=NM
 S DATA("NEW","STANUM")=STA
 S Y=0,OLD=^DD("SITE"),X=$NA(^DD("SITE"))_": "
 I OLD'=NM S ^DD("SITE")=NM
 I  D MSG(X_"name changed from "_OLD_" to "_NM) S Y=1
 S OLD=^DD("SITE",1)
 I OLD'=STA S ^DD("SITE",1)=STA
 I  D MSG(X_"site number changed from "_OLD_" to "_STA) S Y=1
 I 'Y D MSG(X,1)
 W !,LINE
 Q
 ;
KSP ; kernel system parameters
 ;;9^9.8^31.1^51^202^203^204^205^206^209^210^211^214^218^230^320^501
 ;;0^a^999999^127.0.0.1^5^600^1^1^0^Y^300^0^90^d^3600^C:\HFS\^1
 N I,J,X,Y,Z,FLDS,FLDSX,TMP,VAL,VFDAT,VOL
 W !?3,"KERNEL SYSTEM PARAMETERS file . . ."
 ; file some data first before prompting for fields
 S FLDSX=$P($T(KSP+1),";",3),VAL=$P($T(KSP+2),";",3)
 F I=1:1:$L(FLDSX,U) S FLDSX($P(FLDSX,U,I))=$P(VAL,U,I)
 S FLDSX(.01)=DATA("NEW",4.2,"SUB")
 S FLDSX(217)=DATA("NEW",4)
 S FLDSX(502)=$$SID^%ZOSV
 S FLDSX("VOL",.01)=DATA("NEW","VOLF")
 S FLDSX("VOL",2)=256
 S X=$TR(FLDSX,U,";")_";.01;217;502"
 D DIQS(.VFDAT,8989.3,1,X) M TMP=VFDAT(8989.3,"1,")
 F I=1:1:$L(FLDSX,U) S J=$P(FLDSX,U,I) S:$G(TMP(I,"I"))="" FLDS(J)=FLDSX(J)
 S X=FLDSX(.01) I $G(TMP(.01,"I"))'=X S FLDS(.01)=X
 S X=FLDSX(217) I $G(TMP(217,"I"))'=X S FLDS(217)=X
 S FLDS(502)=FLDSX(502)
 ; update top level file
 I $D(^XTV(8989.3,1,0)) S X=$$DIE(8989.3,1,.FLDS)
 I '$D(^XTV(8989.3,1,0)) S X=$$UPDATE(8989.3,,.FLDS)
 I X<1 D ERR("KSP file: "_X)
 ; update the VOLUME multiple
 S Y=$O(^XTV(8989.3,1,4,"B",FLDSX("VOL",.01),0))
 I 'Y S Y=$O(^XTV(8989.3,1,4,0))
 K FLDS,TMP M FLDS=FLDSX("VOL")
 I 'Y S X=$$UPDATE(8989.304,"+1,1,",.FLDS)
 I Y S X=$$DIE(8989.304,Y_",1,",.FLDS)
 I X<1 D ERR("VOLUME field in KSP file: "_X)
 ; now allow editing of certain fields
 D DIECLASS(8989.3,1,"51;320;320.2")
 W !,LINE
 Q
 ;
MPI ;
 ; site^vasite must be setup first - file 389.9
 ; there is only one entry in this file (see MPIFAPI where DA=1)
 N I,X,Y,Z,STA
 S Z="MASTER PATIENT INDEX (LOCAL NUMBERS) file"
 S STA=$G(DATA("NEW","STANUM"))
 W !?3,Z_" . . ."
 I 'STA D ERR(Z_" - not updated as no station number found") Q
 D DIQS(.VFDAT,984.1,1)
 S X=$G(VFDAT(984.1,"1,",.01,"I"))
 I X=STA D MSG(Z,1) Q
 S Y=$P(^MPIF(984.1,0),U,1,2) K ^(0) S ^(0)=Y
 S X=$$MPIS
 D MSG(Z_" - initialized for station number "_STA)
 Q
 ; 
MPIS() ;
 N X,Y,Z,DD,D0,DIC,MPINUM
 G SETUP^MPIFAPI
 ;
MSP ; mailman site parameters
 ;;1^8.22^8.23^8.24^8.25^23^31^40
 ;;EST^1^TCP/IP-MAILMAN^TCPCHAN-SOCKET25/CACHE/NT^NULL^S^1^1
 N I,J,X,Y,Z,FLDSX,NEW,NM,OLD,TMP,VAL,VFDAT
 W !?3,"MAILMAN SITE PARAMETERS file . . ."
 S FLDSX=$P($T(MSP+1),";",3),VAL=$P($T(MSP+2),";",3)
 F I=1:1:$L(FLDSX,U) S FLDSX($P(FLDSX,U,I))=$P(VAL,U,I)
 S FLDSX(.01)=DATA("NEW",4.2,"SUB")
 S FLDSX(3)=DATA("NEW",4.2,"PAR")
 S FLDSX(4)=DT
 S FLDSX(217)=DATA("NEW",4)
 S Z=".01;3;4;217;"_$TR(FLDSX,U,";")
 D DIQS(.VFDAT,4.3,1,Z,"IE") M TMP=VFDAT(4.3,"1,")
 ; quit if already set for new domain
 I TMP(.01,"I")=FLDSX(.01),TMP(.01,"E")=$G(^XMB("NAME")) D  Q
 .D MSG("MAILMAN SITE PARAMETERS file",1)
 .Q
 ; build DR string updating only those fields necessary
 S Z="",X=FLDSX(.01) I $G(TMP(.01,"I"))'=X S Z=".01////"_X_";"
 S X=FLDSX(3) I $G(TMP(3,"I"))'=X S Z=Z_"3////"_X_";"
 S X=FLDSX(217) I $G(TMP(217,"I"))'=X S Z=Z_"217////"_X_";"
 I Z'="" S Z=Z_"4////"_DT_";"
 F I=1,8.23,8.24,8.25 I $G(TMP(I,"E"))="" S Z=Z_I_"///"_FLDSX(I)_";"
 F I=8.22,23,31,40 I $G(TMP(I,"I"))="" S Z=Z_I_"///"_FLDSX(I)_";"
 S Z=Z_"1" I $G(TMP(1,"E"))="" S Z=Z_"//"_FLDSX(1)_";"
 D DIECLASS(4.3,1,Z)
 ; verify that the indexes are correct
 S Z="",X=^XMB(1,1,0),Y=$P(X,U,3),X=+X,NM=$P(^DIC(4.2,X,0),U)
 I ^XMB("NAME")'=NM S ^("NAME")=NM,Z="NAME^"
 I ^XMB("NETNAME")'=NM  S ^("NETNAME")=NM,Z=Z_"NETNAME^"
 I ^XMB("NUM")'=X S ^("NUM")=X,Z=Z_"NUM^"
 I Y'="",^XMB("PARENT")'=Y S ^("PARENT")=Y,Z=Z_"PARENT^"
 I Z'="" D
 .D ERR("MAILMAN SITE PARAMETERS file indexes needed fixing:")
 .F I="NAME","NETNAME","NUM","PARENT" I Z[(I_U) D
 ..S J=$S(I["NAME":NM,I="NUM":X,1:Y)
 ..D ERR("   ^XMB("""_I_""") reset to "_J)
 ..Q
 .Q
 W !,LINE
 Q
 ;
RPC ; rpc broker site parameters
 ;;RPC BROKER SITE PARAMETERS file
 ;;  Edit or enter a new port number
 ;;  The port number must be unique on this server
 N I,J,X,Y,Z,DA,DIK,PORT,TMP,VFDAT
 W !!,LINE F I=1:1:3 W !,$TR($T(RPC+I),";"," ")
 D DIQS(.VFDAT,8994.1,1)
 S PORT=$G(VFDAT(8994.171,"1,1,1,",.01,"I"))
 S DIK="^XWB(8994.1,",DA=0 F  S DA=$O(^XWB(8994.1,DA)) Q:'DA  D ^DIK
 K VFDAT
 S VFDAT(8994.1,"+1,",.01)=DATA("NEW",4.2,"SUB")
 S VFDAT(8994.17,"+2,+1,",.01)=DATA("NEW",14.7)
 I PORT D
 .S VFDAT(8994.171,"+3,+2,+1,",.01)=PORT
 .S VFDAT(8994.171,"+3,+2,+1,",.5)=1
 .S VFDAT(8994.171,"+3,+2,+1,",2)=1
 .Q
 D UPDATE(,,,.VFDAT)
 D DIECLASS(8994.1,1,"2//IT SUPPORT;7")
 W !,LINE
 Q
 ;
STA ; check that station number is in needed files
 ;;No single Medical Center Division file entry has the Station Number
 ;;and the Institution that was selected.  There exists one entry which
 ;;has this INSTITUTION name.  Another entry has this Station Number.
 ;;STATION NUMBER (TIME SENSITIVE) file reinitialized
 N A,B,I,X,Y,Z,INST,STA,VDR
 N DLAYGO,VACNT,VADIV,VAPRIM,VASITE
 S Z="MEDICAL CENTER DIVISION file"
 W !?3,Z_" . . ."
 S INST=DATA("NEW",4),STA=DATA("NEW","STANUM")
 ; check if station num and institution in same record in file 40.8 
 S Y=$O(^DG(40.8,"C",STA,0))
 S X=$O(^DG(40.8,"AD",INST,0))
 I Y,X,Y=X D MSG(Z,1) Q
 ; check for error condition sta# in one record, inst in another
 I Y,X D  Q
 .F I=1:1:3 D ERR($TR($T(STA+I),";"," "))
 .Q
 ; update MCD file
 S A=$S('Y&'X:1,Y:2,1:3)
 I A<3 S VDR(.01)=DATA("NEW","INST"),VDR(.07)=INST
 I A'=2 S VDR(1)=STA
 I A=1 D
 .S VDR(3)=1,B=$$UPDATE(40.8,,.VDR)
 .I B>0 D MSG(Z_" - a new entry created")
 .I B<1 D ERR(Z_" - "_B)
 .Q
 I A>1 D
 .S B=$$DIE(40.8,$S(Y:Y,1:X),.VDR)
 .I B>0 D MSG(Z_" - record #"_$S(Y:Y,1:X)_" updated")
 .I B<1 D ERR(Z_" - "_B)
 .Q
 S X=$P(^VA(389.9,0),U,1,2) K ^(0) S ^(0)=X
 S DLAYGO=389.9 D ^VASITE1
 D MSG($TR($T(STA+4),";"," "))
 Q
 ;
TSP ; reset TASKMAN SITE PARAM file
 N X,Y,Z,NEW,OLD,VFDAT
 S Z="TASKMAN SITE PARAM file"
 W !?3,Z_" . . ."
 S OLD=DATA("OLD","BOX"),NEW=DATA("NEW","BOX")
 I OLD=NEW D MSG(Z,1)
 I OLD'=NEW D
 .S X=DATA("NEW",14.7),VFDAT(.01)=NEW
 .S Y=$$DIE(14.7,X,.VFDAT)
 .I Y<1 D ERR(Z_" - "_Y)
 .I Y>0 D MSG(Z_" entry changed from "_OLD_" to "_NEW)
 .Q
 Q 
 ;
VOL ; reset the VOLUME file
 N X,Y,Z,NEW,OLD,VFDAT
 S Z="VOLUME SET file"
 W !?3,Z_" . . ."
 S OLD=DATA("OLD","VOLF"),NEW=DATA("NEW","VOLF")
 I OLD=NEW D MSG(Z,1)
 I OLD'=NEW D
 .S X=DATA("NEW",14.5),VFDAT(.01)=NEW
 .S Y=$$DIE(14.5,X,.VFDAT)
 .I Y<1 D ERR(Z_" - "_Y)
 .I Y>0 D MSG(Z_" entry changed from "_OLD_" to "_NEW)
 .Q
 Q
 ;
ZOSF ; reset the %ZOSF global
 N A,X,Y,Z
 S Z="^%ZOSF()"
 W !?3,Z_" . . ."
 S Y=0 F X="MGR","PROD","VOL" D
 .S A=DATA("NEW",X)
 .I DATA("OLD",X)'=A S Y=Y+1,^%ZOSF(X)=A
 .Q
 I 'Y D MSG(Z,1)
 I Y D MSG(Z_" changed from "_DATA("OLD","VOL")_" to "_DATA("NEW","VOL"))
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
CJ(X,L) Q $$CJ^XLFSTR(X,L)
 ;
DIC(F,N) ;  classic ^dic call
 N X,Y,DIC,DLAYGO,DTOUT,XUMF
 S DIC=F,DIC(0)="QAEM"
 I $G(N) S DIC(0)="QAEML",DLAYGO=F,XUMF=1
 I F=4 S DIC("DR")=".01;11///Local;13;60;99"
 W ! D ^DIC S:$D(DTOUT) Y=-1
 Q Y
 ;
DIE(F,IEN,VDR) ;  file^die
 ; vdr(field#)=value  OR  vdr=field#^value
 N A,X,Y,Z,DIERR,VAL,VFD,VFDER,VFLDS,VIEN
 I '$G(F) Q -1
 I '$D(VDR) Q -1
 I '$G(IEN) Q -1
 S VIEN=IEN S:VIEN'["," VIEN=VIEN_","
 I $G(VDR)="" M VFD(F,VIEN)=VDR
 E  S VFD(F,VIEN,+VDR)=$P(VDR,U,2)
 D FILE^DIE(,"VFD","VFDER")
 Q $S('$D(DIERR):1,1:$$FMERR)
 ;
DIECLASS(DIE,DA,DR) ;  classic ^die
 N I,J,X,Y,Z,DTOUT,DUOUT
 I $G(DIE)=""!'$G(DA)!'$D(DR) Q
 I DIE=+DIE S DIE=$$ROOT(DIE)
 W ! D ^DIE
 Q
 ;
DIR() ;
 N X,Y,Z,DIR,DIROUT,DIRUT,DTOUT,DUOUT
 S DIR(0)="YA",DIR("A")="   Do you wish to continue? ",DIR("B")="NO"
 D ^DIR
 Q $S($D(DTOUT):0,$D(DUOUT):0,1:Y=1)
 ;
DIQS(VFDAT,F,IEN,VFLDS,FORMAT) ; gets^diq
 ; return all fields in internal format
 N I,X,Y,Z,DIERR,VFDER
 I $G(VFLDS)="" S VFLDS="**"
 I $G(FORMAT)="" S FORMAT="I"
 I '$G(F)!'$G(IEN) Q
 D GETS^DIQ(F,IEN_",",VFLDS,FORMAT,"VFDAT","VFDER")
 Q
 ;
ERR(T) S VERR=VERR+1,VERR(VERR)=T Q
 ;
FMERR(IN) ; IN - name of array holding error msg
 N I,X,Y,Z,DA,VFDOUT
 S:$G(IN)="" IN="VFDER" I '$D(@IN) Q ""
 D MSG^DIALOG("AE",.VFDOUT,,,IN)
 S Z="",I=0 F  S I=$O(VFDOUT(I)) Q:'I  S Z=Z_VFDOUT(I)_" "
 Q Z
 ;
MSG(T,NUR) S MSG=MSG+1 S:$E(T)'=" " T="   "_T
 S MSG(MSG)=T
 I $G(NUR) S MSG(MSG)=T_": no update required"
 Q
 ;
UPDATE(F,VIEN,VDR,VFDAR,VFDINUM) ; update^die
 ; vdr(field#)=value   If $g(vien) do not change it
 ; .vfdar - if $d(vfdar) then ignore F,VIEN,VDR
 ; .vfdinum - set up UPDATE call for dinum
 ;            only used if $d(vfdar)
 N A,I,J,X,Y,Z,DIERR,VAL,VFD,VFDER,VFDIEN,VFLDS
 I $D(VFDAR) M VFD=VFDAR I $D(VFDINUM) M VFDIEN=VFDINUM
 S Z=0 I '$D(VFD) D  I Z Q -1
 .I '$G(F) S Z=-1 Q
 .I '$D(VDR) S Z=-1 Q
 .I $G(VIEN)="" S VIEN="+1,"
 .M VFD(F,VIEN)=VDR
 .Q
 I '$D(VFDIEN) S VFDIEN(1)=1
 D UPDATE^DIE(,"VFD","VFDIEN","VFDER")
 Q $S('$D(DIERR):VFDIEN(1),1:$$FMERR)
 ;
HDR ;
 ;;                   OLD VALUES                 NEW VALUES
 ;;---------   ------------------------   ------------------------
 W @IOF,LINE,!,$$CJ("Current Box-Pair Name: "_BOX,80),!
 W !,$TR($T(HDR+1),";"," "),!,$TR($T(HDR+2),";"," ")
 S Y=$$CJ(DATA("OLD","VOL"),24),Z=$$CJ(DATA("NEW","VOL"),24)
 W !,"   Namespace   "_Y_"   "_Z
 S Y=$$CJ(DATA("OLD","BOX"),24),Z=$$CJ(DATA("NEW","BOX"),24)
 W !,"   Box-Pair    "_Y_"   "_Z
 W !,EQ
 Q
 ;
INIT ;
 S U="^" D DUZ^XUP(.5) S DUZ(0)="@"
 S DTIME=$$DTIME^XUP(.5)
 S DT=$$DT^XLFDT
 D HOME^%ZIS
 S (MSG,VERR)=0
 S $P(LINE,"-",81)=""
 S $P(EQ,"=",81)=""
 X ^%ZOSF("UCI") S NMSP=$P(Y,",")
 D GETENV^%ZOSV S BOX=NMSP_":"_$P($P(Y,U,4),":",2)
 Q
 ;
ROOT(F) Q $$ROOT^DILFD(F)
 ;
ZTCLEAN(VDAT) ;
 ; expects VDAT() = DATA()
 ;;Clean up of Taskman Expected input variable values not found
 N A,B,I,J,X,Y,Z,NEW,OLD
 I $G(LINE)="" N LINE S $P(LINE,"-",81)=""
 I $G(EQ)="" N EQ S $P(EQ,"=",81)=""
 S Z="Clean up of Taskman globals"
 W !?3,Z_" . . ."
 ; validate input values present
 F X="BOX","CONFG","PROD","VOL","UV" S OLD(X)=$G(VDAT("OLD",X))
 F X="BOX","CONFG","PROD","VOL","UV" S NEW(X)=$G(VDAT("NEW",X))
 I OLD("UV")="" S OLD("UV")=OLD("PROD")_","_OLD("VOL")
 I OLD("CONFG")="" S OLD("CONFG")=$P(OLD("BOX"),":",2)
 I NEW("UV")="" S NEW("UV")=NEW("PROD")_","_NEW("VOL")
 I NEW("CONFG")="" S NEW("CONFG")=$P(NEW("BOX"),":",2)
 S Y=0 F X="BOX","CONFG","PROD","VOL","UV" I OLD(X)'=NEW(X) S Y=1
 I 'Y D MSG(Z,1) Q
 S Y=0 F X="BOX","PROD","VOL" I OLD(X)=""!(NEW(X)="") S Y=Y+1
 I Y D ERR(Z_" not done as expected input variables not found") Q
 ;
 ; clean up the task scheduler
 F X="C","DEVTRY","DLG","ER","IDLE","MON","STATUS","STOP","SUB","UPDATE" K ^%ZTSCH(X)
 S X="OR" F  S X=$O(^%ZTSCH(X)) Q:$E(X,1,2)'="OR"  K ^%ZTSCH(X)
 S X=0 F  S X=$O(^%ZTSCH("STARTUP",X)) Q:X=""  D:X'=NEW("UV")
 .M ^%ZTSCH("STARTUP",NEW("UV"))=^%ZTSCH("STARTUP",X)
 .K ^%ZTSCH("STARTUP",X)
 .Q
 ; clean up the Task globalS
 S Z=$NA(^%ZTSCH("TASK"))
 F  S Z=$Q(@Z) Q:Z=""  Q:$QS(Z,1)'="TASK"  S (A,X)=@Z D
 .F I=1:1:$L(X,U) S Y=$P(X,U,I) I Y'="" D
 ..F J="BOX","CONFG","PROD","VOL","UV" I Y=OLD(J) S $P(X,U,I)=NEW(J) Q
 ..Q
 .I A'=X S @Z=X
 .Q
 ; clean up ^%ZTSK
 S Z="^%ZTSK" F  S Z=$Q(@Z) Q:Z=""  S (A,X)=@Z D
 .F I=1:1:$L(X,U) S Y=$P(X,U,I) I Y'="" D
 ..F J="BOX","CONFG","PROD","VOL","UV" I Y=OLD(J) S $P(X,U,I)=NEW(J) Q
 ..Q
 .I A'=X S @Z=X
 .Q
 D MSG("Clean up of Taskman globals completed")
 Q
 ;
 ;
LAB ; update the lab file institution file pointers
 N I,X,Y,Z,DA,INST,ROOT,VDR
 S INST=$G(DATA("NEW",4)) Q:'INST  Q:'$D(^DIC(4,INST,0))
 S ROOT=$$ROOT(60)
 ; update inst name and ptr in 69.9
 K Z S VDR(.01)=DATA("NEW","INST"),VDR(3)=INST
 S X=$$DIE(69.9,1,.VDR) I X'="" W !!,X
 ; accession area in lab 60 file dinum'd
 K VDR S DA(1)=0 F  S DA(1)=$O(^LAB(60,DA(1))) Q:'DA(1)  D
 .N ACC S ACC=$$LABDEL(DA(1))
 .S X=$$LABADD(DA(1),ACC)
 .I X'="" S Y=$P(^LAB(60,DA(1),0),U),VDR(DA(1))=Y_U_X
 .Q
 I $D(VDR) D
 .W !!,$$MSG(18)
 .S I=0 F  S I=$O(VDR(I)) Q:'I  S X=VDR(I) D
 ..W !,"ien: "_$J(I,8)_" ==> "_$P(X,U) S Y=$P(X,U,2)
 ..F  W !?3,$E(Y,1,70) S Y=$E(Y,71,999) Q:Y=""
 ..Q
 .Q
 W !,EQ
 Q
 ;
LABADD(I,ACC) ; add new institution to access area
 N X,Y,Z,DA,DIERR,VFDA,VFDER,VFDI,VIEN
 S VFDI="+1,"_I_",",VIEN=INST
 S VFDA(60.11,VFDI,.01)=INST
 I $G(ACC)>0,$D(^LRO(68,ACC,0)) S VFDA(60.11,VFDI,1)=ACC
 D UPDATE^DIE(,"VFDA","VIEN","VFDER")
 S X="" I $D(VFDER) S X=$$FMERR
 Q X
 ;
LABDEL(I) ; delete all accession area
 N X,Y,Z,ACC,DA,DIK
 S DA(1)=I,ACC=0
 F  S DA=$O(^LAB(60,DA(1),8,DA)) Q:'DA  S X=^(DA,0) D
 .K DIK S:'ACC ACC=$P(X,U,2) S DIK=ROOT_DA(1)_",8," D ^DIK
 .Q
 Q ACC
 ;
SCHEDOPT ;
 ;;HLO SYSTEM STARTUP^S^^
 ;;ORMTIME RUN^^Dec 11, 2007@19:00^
 ;;ORMTIME RUN CHECK^^Dec 11, 2007@19:30^
 ;;VFDSD APPOINTMENT PURGE^S^Oct 17, 2008@20:00^
 ;;XMAUTOPURGE^^Dec 11, 2007@19:30^
 ;;XMMGR-IN-BASKET-PURGE^^Dec 11, 2007@20:00^
 ;;XMMGR-PURGE-AI-XREF^^Dec 11, 2007@19:30^
 ;;XMMGR-START-BACKGROUND-FILER^S^^
 ;;XOBV LISTENER STARTUP^S^^
 ;;XQ XUTL $J NODES^^Dec 11, 2007@19:00^
 ;;XQALERT DELETE OLD^^Dec 11, 2007@19:00^30
 ;;XQBUILDTREEQUE^^Dec 11, 2007@19:00^
 ;;XTRMONITOR^^Dec 11, 2007@19:00^
 ;;XUERTRP AUTO CLEAN^^Dec 11, 2007@19:30^
 ;;XUSER-CLEAR-ALL^S^^
 ;;XUSERAOLD^^Dec 11, 2007@19:00^
 ;;XUTM QCLEAN^^Dec 11, 2007@19:30^
 ;;XWB LISTENER STARTER^S^^
 Q
