VFDXWBB ;DSS/LM/SGM - BROKER UTILITIES ; 3/25/2013 17:52
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is to be invoked only by the VFDXWB routine.
 ;Line tags called from VFDVZST
 ;  GETPORT, STRTOLD, STRTNEW, STOPOLD, STOPNEW
 ;
 ; ICR#   SUPPORTED DESCRPTIONS
 ;------  ------------------------------------------------------
 ;        FILE^DIE
 ;        ^DIR
 ;        GETS^DIQ
 ;        ^XWBTCP: STRT, STOP
 ;        ZISTCP^XWBTCPM1(PORT) (called with JOB command)
 ;        GETENV^%ZOSV
 ;        Fileman API calls to files
 ;           GETS^DIQ, FILE^DIE to file 8994.1
 ;
 ;------------  These next 5 line tags called from VFDXWB   -----------
 ;
SELECT() ; Select PORT and determine TYPE
 ; Used by STRT and STOP
 ; Return -1 or port#^(1:newstyle;0:oldstyle)^port_iens
 N X,Y,Z,IENS,PORT,TYPE
 S PORT=$$DIR Q:PORT<9000 -1
 ; Find port if it exists in RPC BROKER SITE PARAMETERS
 S X=$$VALIDATE(PORT) Q:X<1 -1
 S IENS=$P(X,U),TYPE=$P(X,U,2)
 S Y=$P("Old^New",U,1+TYPE)_" Style Listener"
 W !,"Port "_PORT_","_$P("Old^New",U,1+TYPE)_" Style Listener"
 K Z S Z(0)="SO^0:Original;1:New Style"
 S Z("A")="Start Listener Type",Z("B")=TYPE
 S X=$$DIR(,.Z)
 Q $S(X<1:-1,1:PORT_U_X_U_IENS)
 ;
STOPNEW ; Stop NEW Style RPC Broker Listener
 ; also called from ^VFDVZST
 I '$G(IENS)!'$G(PORT)  D  Q
 .I '$G(QUIET) W !,"Cannot stop unregistered new style listener."
 .Q
 N DIERR,VFDER,VFDFDA
 S VFDFDA(8994.171,IENS,1)=4 ;STATUS=STOP
 D FILE^DIE(,"VFDFDA","VFDER")
 W:'$G(QUIET) !,"New Style listener requested to stop on port "_PORT
 Q
 ;
STOPOLD ; Stop OLD Style RPC Broker Listener
 ; also called from ^VFDVZST
 W:'$G(QUIET) ! D STOP^XWBTCP(PORT)
 Q
 ;
STRTNEW ; Start NEW Style RPC Broker Listener
 ; also called from ^VFDVZST
 J ZISTCP^XWBTCPM1(PORT)
 W:'$G(QUIET) !,"New Style listener requested to start on port "_PORT
 Q
 ;
STRTOLD ; Start OLD Style RPC Broker Listener
 ; also called from ^VFDVZST
 W:'$G(QUIET) ! D STRT^XWBTCP(PORT)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
DIR(DEF,DIR) ; ask for port number
 ; DEF - opt - default port number
 N I,X,Y,Z,CH,DIROUT,DIRUT,DTOUT,DUOUT
 S CH=0 I '$D(DIR) D  S CH=1
 .S DEF=$G(DEF) I 'DEF S X=+$$GETPORT S:X>8999 DEF=X
 .S DIR(0)="NA^9000:65535:0",DIR("A")="PORT: "
 .S:DEF DIR("B")=DEF
 .Q
 D ^DIR I $S($D(DTOUT):1,$D(DUOUT):1,1:0) Q -1
 Q $S('CH:Y,Y<9000:-1,1:Y)
 ;
GETALL(VFDRET,FILT,BOXX) ; get box-pairs/port numbers
 ; FILT - opt - if FILT contains 1 then return new style
 ;              if FILT contains 0 then return new and old
 ;              if FILT="" or contains 0 and 1, then return both
 ; BOXX - opt - box-pair name - if passed only return ports for it
 ;              else return all box-pairs
 ; .VFDRET - return array
 ; If BOXX="" then VFDRET(box-pair)=listener_iens
 ;                 VFDRET(box-pair,port#)=port_iens^type (1:new,0:old)
 ; If BOXX'="" then VFDRET=listener_iens, VFDRET(port#)=port_iens^type
 ;
 N I,J,X,Y,Z,DIERR,BOX,PORT,TMP,TYPE,VFDE,VFDR
 K VFDRET S FILT=$G(FILT)
 D GETS^DIQ(8994.1,"1,","**","IE","VFDR","VFDE")
 S Y=0 F  S Y=$O(VFDR(8994.17,Y)) Q:Y=""  D
 .S BOX=VFDR(8994.17,Y,.01,"E"),VFDRET(BOX)=Y,TMP(Y)=BOX
 .Q
 S Y=0 F  S Y=$O(VFDR(8994.171,Y)) Q:Y=""  D
 .S Z=$P(Y,",",2,4) Q:Z=""  S BOX=$G(TMP(Z)) Q:BOX=""
 .S PORT=VFDR(8994.171,Y,.01,"E")
 .S TYPE=VFDR(8994.171,Y,.5,"I")
 .I FILT'="",FILT'[TYPE Q
 .S VFDRET(BOX,PORT)=Y_U_TYPE
 .Q
 Q:$G(BOXX)=""  Q:'$D(VFDRET(BOXX))
 K X M X=VFDRET(BOXX) K VFDRET M VFDRET=X
 Q
 ;
GETCURBX() ; return this server's box-pair name
 N X,Y D GETENV^%ZOSV Q $P(Y,U,4)
 ;
GETPORT(BOX,TFLG) ; return the lowest port number for box-pair
 ; also called from ^VFDVZST
 ; BOX - opt - name of box-pair from file 14.7
 ;             default to box-pair name for this server
 ;TFLG - opt - Boolean flag to determine whether to return listener
 ;             type.  Default to 0
 ; Return: port#^port_iens[^listener type]
 ;
 N I,J,X,Y,Z,PORT,VFD
 I $G(BOX)="" S BOX=$$GETCURBX I BOX="" Q -1
 D GETALL(.VFD,,BOX) S PORT=$O(VFD(0)) S:PORT="" PORT=-1
 I PORT>0,$G(TFLG) S PORT=PORT_U_VFD(PORT)
 Q PORT
 ;
VALIDATE(PORT,BOX) ; validate port# in box-pair file for this box
 ; PORT - req - port# to validate
 ;  BOX - opt - box-pair name to check for port# existence
 ;              default to current box-pair
 ; Return - port_multiple_iens^listener type  or  -1
 ;          listener type = 1:new style port  0:old style port
 N I,X,Y,Z,VFD
 I $G(PORT)="" Q -1
 S BOX=$G(BOX) I BOX="" S BOX=$$GETCURBX
 D GETALL(.VFD,,BOX)
 Q $S($D(VFD(PORT)):VFD(PORT),1:-1)
