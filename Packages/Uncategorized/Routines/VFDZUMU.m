VFDZUMU ;DSS/SGM - TIED ROUTINE MULT NAMESPACES ; 6/4/2013 15:50
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine can be used in Intersystems' Cache environment for the
 ;purpose of prompting the user to select a namespace to go to.  Once
 ;in that namespace then invoke the VistA security routine ^ZU.  So,
 ;the user must have an authorized NEW PERSON account in that
 ;namespace.  The program will halt when the user is finished working
 ;in the namespace that they swapped to.
 ;
 Q:'$$CACHE
 N I,J,X,Y,Z,HOME,SRVNAME,VASK,VER,ZBLOFF,ZBLON,ZBOFF,ZBON,ZCE,ZIOF
 N ZOE,ZROFF,ZRON,ZVAR
 D SETVAR I VER<2009 D ERROR(1) Q 
 D GET Q:'$D(NMSP)
 D ASK X ZVAR
 I $D(VASK) X VASK(0) I $G(VASK)=-2 H
 Q
 ;
MOVE ;
 ;;How to edit this routine and move it to the USER namespace
 ;;
 ;; 1. Save this routine in a namespace other than USER
 ;;
 ;; 2. Using Cache Studio, edit the lines in this routine at the bottom
 ;;    of this routine.  Only lines following HD, L, and PORTS should
 ;;    be edited for this Cache configuration.
 ;;
 ;; 3. Save and Compile the routine when you are through with the edits
 ;;
 ;; 4. In Cache Mgmt Portal, configure the appropriate Cache user to be
 ;;    tied to the USER namespace and this routine, ^VFDZUMU
 ;;
 ;; 5. Answer Yes to the prompt asking if you wish to move the routine
 ;;    to the USER namespace.
 ;;$END
 ;
 Q:'$$CACHE
 N I,J,X,Y,Z,HOME,SRVNAME,VER,ZBLOFF,ZBLON,ZBOFF,ZBON,ZCE,ZIOF
 N ZKILL,ZOE,ZROFF,ZRON,ZVAR
 D SETVAR I VER<2009 D ERROR(1) Q 
 D GET
 W #,MENU(1),!,MENU(2),!
 F I=1:1 S X=$P($T(MOVE+I),";",3) Q:X="$END"  W !,X
 Q:'$$READ(1)
 Q:'$$READ(2)
 D ZMOVE
 W !!,"Routine VFDZUMU moved to the USER namespace",! 
 Q
 ;
 ;-----------------------  private subroutines  -----------------------
 ;=====================================================================
 ;            Ask For Namespace and Return Code to eXecute
 ;=====================================================================
ASK ;
 N I,J,X,Y,Z,CNT,NM
 S CNT=0 K VASK
 U $I:("":"-B") ;No break
LOOP ; quit VASK=#,VASK(0)=code to execute
 I CNT>2 D  Q
 . S VASK=-2
 . S VASK(0)="W !!?3,""Halting. . . "",! H"
 . Q
 W # F I=1:1:MENU W MENU(I),!
 W ?5,"Select Namespace (or number): "
 F  R X:60 S CNT=CNT+1 Q:$T  S X=-1 Q:CNT>2
 I X=-1 S CNT=3 G LOOP
 I "^"[X S VASK=-1,VASK(0)="Q" Q
 S:X?.E1L.E X=$$UP(X)
 I X="USER^" S VASK(0)=$$USER,VASK=1 Q
 I X["USER" D ERROR(2) G LOOP
 S NM="",Z=$S(X=+X:X,1:+$G(NMSP("B",X))) S:Z NM=$P($G(NMSP(Z)),U)
 I NM="" D ERROR(2) G LOOP
 I '$$NMSPEX(NM) D ERROR(4) G LOOP
 S VASK=2,VASK(0)=$$SWAP(NM)
 Q
 ;
 ;=====================================================================
 ;           Get All Namespace Names and Build a Menu Array
 ;=====================================================================
GET ;
 ; returns  NMSP(seq#) = nmsp ^ desc
 ;          NMSP("B",namespace)=seq#
 ;          NMSP("C",group-id,namespace)=seq#
 ;          MENU(n)=text   for n=1,2,3,4,...
 N A,I,J,K,L,T,X,Y,Z,DESC,GPID,HD,LEN,LINE,LIST,NM,PORT,RET,SP
 K MENU,NMSP
 S $P(SP," ",80)="",$P(LINE,"-",80)=""
  ; set first three rows of menu array
 D M1
 Q:'$$NMSPGET(.RET)  Q:'$$NMSPLIST(.RET)
 ; get length of longest namespace name
 S (LEN,NM)=0 F  S NM=$O(NMSP("B",NM)) Q:NM=""  S:$L(NM)>LEN LEN=$L(NM)
 ; get headers
 F I=1:1 S X=$P($T(HD+I),";",3) Q:X=""  S Z=+X S:'Z Z=1 S HD(Z)=$P(X,U,2)
 ; building a 2-columnar display (see example at bottom of routine)
 ; J = incrementor for line number
 S GPID=0,J=3 F  S GPID=$O(HD(GPID)) Q:'GPID  S Z=HD(GPID) D
 . I Z="" S Z=LINE
 . E  D
 . . S A=79-($L(Z)+4)\2
 . . S X=$$CODEIO($E(LINE,1,A),"B")
 . . S Z=X_$$CODEIO("  "_Z_"  ","BR")_X
 . . Q
 . S J=J+1 I J>4 S MENU(J)="",J=J+1
 . S MENU(J)=Z
 . S K=0,(L,NM)="" F  S NM=$O(NMSP("C",GPID,NM)) Q:NM=""  D
 . . S Y=NMSP("C",GPID,NM),Z=$P(NMSP(Y),U,2)
 . . S T="{"_$J(Y,2)_"} "_$E(NM_SP,1,LEN+1)_Z_SP,T=$E(T,1,34)
 . . S PORT=$E($G(NMSP(Y,"P"))_"    ",1,4),T=T_" "_PORT
 . . I '$L(L) S L=T_"|"
 . . E  S J=J+1,MENU(J)=L_T,L=""
 . . Q
 . I $L(L) S J=J+1,MENU(J)=L
 . Q
 S J=J+1,MENU(J)=LINE
 S X="ACCESS/VERIFY codes required for the account that you select"
 S J=J+1,MENU(J)=$E(SP,1,5)_X
 S MENU=J
 Q
 ;
 ;=====================================================================
 ;                               PROMPTER
 ;=====================================================================
READ(L) ; reader prompt
 ;;Have you edited this routine reflecting the namespaces to be displayed? No// 
 ;;Do you wish to move the VFDZUMU routine to the USER namespace? No// 
 ;;Are you sure? No// 
 ;;Press any key to continue 
 N I,X,Y,Z
 S Z=$P($T(READ+L),";",3)
 W !!,Z R X:120 E  Q ""
 S:X?.E1L.E X=$$UP(X)
 I L<4,$E(X)'="Y" Q ""
 Q 1
 ;
 ;---------------------------------------------------------------------
CACHE() ; check for Cache
 ; also called from HEADER field for Option VFD MULTI-ACCOUNT SIGN-ON
 Q $ZV["Cache"
 ;
CODEIO(ST,T) ;
 N X,Y,Z S T=$G(T)
 S (X,Y)="" I T["B" S X=ZBON,Y=ZBOFF
 I T["b" S X=X_ZBLON,Y=ZBLOFF_Y
 I T["R" S X=X_ZRON,Y=ZROFF_Y
 Q X_ST_Y
 ;
ERROR(L) ; error messages
 N T
 I L=1 S T="This program only supports Cache 2009 or greater"
 I L=2 S T="   ... Invalid selection"
 I L=3 S T="There are no selectable namespaces"
 I L=4 S T="This namespace is not currently available"
 I L=5 S T="No valid security routine found in "_X
 W !!?3,"SORRY: "_T_"   " R *Y:10
 Q
 ;
ISVISTA(X,F) ; check if namespace is a VistA system
 N A,Q,Z S Q=$C(34)
 S A="ZN "_Q_X_Q_" S Z=$L($T(+1^ZU)) ZN "_Q_HOME_Q
 I $G(F) Q A
 X A
 Q Z
 ;
M1 ; set up first three lines of MENU()
 N X,Y,Z
 S X="Server: "_SRVNAME_"   Cache: "_VER_SP,X=$E(X,1,79)
 I HOME'="USER" S Z="Nmsp: "_HOME,$E(X,79-$L(Z),79)=" "_Z
 S MENU(1)=X
 ; get server ports
 S X=$P($T(PORTS),";",3)
 S Y="" I +X S Y="Telnet: "_(+X)_"     "
 S Z=+$P(X,U,2) I Z S Y=Y_"Studio: "_Z_"     "
 S Z=+$P(X,U,3) I Z S Y=Y_"Web: "_Z
 S MENU(2)="" I $L(Y) S MENU(2)="Cache Ports:  "_Y
 S MENU(3)=""
 Q
 ;
NMSPEX(X,F) ; does namespace exist
 N Q S Q=$C(34)
 I $G(F) Q "I ##class(%SYS.Namespace).Exists("_Q_X_Q_")"
 Q ##class(%SYS.Namespace).Exists(X)
 ;
NMSPGET(RET) ; get list of available namespaces
 N I,J,X,Y,Z,TMP
 D List^%SYS.NAMESPACE(.TMP)
 ; exclude Cache namespaces
 ; exclude SQL namespaces
 ; exclude namespaces not mounted
 S X="" F  S X=$O(TMP(X)) Q:X=""  S Y=TMP(X) D
 . I "^%SYS^DOCBOOK^SAMPLES^USER^"[(U_X_U) K TMP(X) Q
 . I X["SQL" K TMP(X) Q
 . S J="" F I=1:1:$L(Y) S J=J_$A(Y,I)
 . I J=2424 K TMP(X) Q
 . Q
 S X="" F J=0:1 S X=$O(TMP(X)) Q:X=""
 I $D(TMP) M RET=TMP
 I 'J D ERROR(3)
 Q J 
 ;
NMSPLIST(RET) ; only show those namespaces listed under tag L
 ;;K T S T=0,R=$NA(^XWB(8994.1)) F  S R=$Q(@R) Q:R=""  Q:$QS(R,1)'=8994.1  I $QL(R)=8,$QS(R,6)="B" S T=T+1,T(0)=$QS(R,7)
 N I,J,L,R,T,X,Y,Z,CODE,GPID,LIST,NM
 S CODE=$P($T(NMSPLIST+1),";",3)
 ; order namespaces by group id and then by namespace
 F I=1:1 K X S X=$P($T(LIST+I),";",3) Q:X=""  D
 . F J=1:1:$L(X,U) S X(J)=$P(X,U,J)
 . ; no nmsp, nmsp not found, inactive flag set
 . Q:X(2)=""  Q:'$D(RET(X(2)))  Q:$G(X(4))
 . S GPID=+X(1) S:'GPID GPID=99
 . S LIST(GPID,X(2))=X(3)
 . Q
 ; build namespace array - see line GET for description
 S (I,J)=0,Z="LIST" F  S Z=$Q(@Z) Q:Z=""  D
 . S J=J+1,GPID=$QS(Z,1),NM=$QS(Z,2)
 . S HD(GPID)=""
 . S NMSP(J)=NM_U_@Z
 . S NMSP("B",NM)=J
 . S NMSP("C",GPID,NM)=J
 . ; swap to namespace and get Broker port number
 . D SWAPCODE(NM,CODE) I $G(T)=1 S NMSP(J,"P")=T(0)
 . Q
 Q J
 ;
SETVAR ; set up various variables
 ;;HOME,SRVNAME,VER,ZBLOFF,ZBLON,ZBOFF,ZBON,ZCE,ZIOF,ZOE,ZROFF,ZRON,ZVAR
 N X
 S U="^",X="K "_$P($T(SETVAR+1),";",3)
 X X S ZVAR=X ;                                kill vars defined here
 S ZIOF="W "_$C(35,27,91,50,74,27,91,72) ;     clear screen
 S ZOE="W "_$C(27,91,63,51,104)_" U $I:132" ;  vt132 open execute
 S ZCE="W "_$C(27,91,63,51,108)_"U $I:80" ;    vt132 close execute
 S ZRON=$C(27,91,55,109) ;                     reverse video on
 S ZROFF=$C(27,91,50,55,109) ;                 reverse video off
 S ZBON=$C(27,91,49,109) ;                     bold on
 S ZBOFF=$C(27,91,50,50,109) ;                 bold off
 S ZBLON=$C(27,91,53,109) ;                    blink on
 S ZBLOFF=$C(27,91,50,53,109) ;                blink off
 S ZNBK="U $I:("""":""-B"")" ;                 disable BREAK
 S VER=$TR($P($P($ZV,")",2),"(",1)," ")
 S HOME=$S(VER<2010:$ZU(5),1:$NAMESPACE)
 S SRVNAME=$S(VER<2010:$ZU(110),1:##class(%SYS.System).GetNodeName())
 Q
 ;
SWAPCODE(X,CODE) ; swap accounts, execute code, return home
 N A,Q S Q=$C(34)
 S A=$$NMSPEX(X,1)_" ZN "_Q_X_Q_" X CODE ZN "_Q_HOME_Q
 I $Q Q A
 X A
 Q
 ;
SWAP(X) ; set up executable code to swap namespace and run ZU
 N A,Q S Q=$C(34)
 S A=$$NMSPEX(X,1)_" ZN "_Q_X_Q_" N VASK D ^ZU"
 Q A
 ;
UP(X) Q $TR(X,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
USER() ;
 ;;ZN "USER" D ^%PMODE U $I:(:"+B+C+R") S $ZT="",$ET="" Q
 Q $P($T(USER+1),";",3)
 ;
ZMOVE ;
 ; get this current routine and put it in RTN(1)
 ; go to USER and get that version of the routine and put it in RTN(2)
 ; if version >= 2013.0 and there is a line EDIT, then merge the data
 ;    from the old USER routine into the new version of the routine
 N I,J,L,N,X,Y,Z,CODE,RTN,TAG
 S N=1,CODE="F I=1:1 S X=$T(+I^VFDZUMU) Q:X=""""  S RTN(N,I)=X"
 X CODE S N=2 X $$SWAPCODE("USER",CODE)
 I $P($G(RTN(2,2)),";",3)<2013 M RTN(3)=RTN(1)
 E  D  ; 2nd verification that USER routine correct version
 . S J=0,I="A" F  S I=$O(RTN(2,I),-1) Q:'I  D
 . . S Z=$P(RTN(2,I)," ") Q:Z=""  Q:Z["("
 . . I "^HD^LIST^PORTS^"'[(U_Z_U) S I=1 Q
 . . S J=J+1,TAGS(J)=Z I J=3 S I=1
 . . Q
 . Q:J'=3  S Z=U F J=1,2,3 S Z=Z_TAGS(J)_U
 . I "^PORTS^LIST^HD^"'=Z Q
 . F I=1:1 S X=$G(RTN(1,I)) Q:X=""  Q:$P(X," ")="HD"  S RTN(3,I)=X
 . S I=I-1,N=0 F J=1:1 S X=$G(RTN(2,J)) Q:X=""  D
 . . S:$P(X," ")="HD" N=3 S:N I=I+1,RTN(3,I)=X
 . . Q
 . Q
 Q:'$D(RTN(3))
 S CODE="ZR  X ""F I=1:1 Q:'$D(RTN(3,I))  ZI RTN(3,I)"" ZS VFDZUMU"
 D SWAPCODE("USER",CODE)
 Q
 ;
 ;
 ;=====================================================================
 ;              !!!!!  ONLY EDIT THESE LINES BELOW  !!!!!
 ;=====================================================================
 ; 1. The display is a fixed 2-columnar display
 ; 2. The Group ID links the HD lines to the data lines under LIST
 ;2a. Example display follows:
 ;------------------------  P A T C H I N G   A C C T S  ------------------------
 ;{ 5} PATCH  Patch Testing          9201|{ 6} XPD    Patch Build Export
 ;
 ; 3. EDIT the ' ;;. . . ' lines below labels HD and LIST
 ; 4. EDIT the line labelled PORTS
 ;4a. EXAMPLE:
 ;    HD    ;;<group id>^<header text>
 ;          ;;1^D E V E L O P M E N T   A C C T S
 ;          ;;2^P A T C H I N G   A C C T S
 ;          ;;3^E X P O R T - R E F E R E N C E   A C C T S
 ;          ;; 
 ;    LIST  ;
 ;          ;;1^DEVOS^vx2010.1 No CPT codes^9203
 ;          ;;1^ARRA^vx2010.1 New Dev^9304
 ;          ;;2^XPD^Patch Build Export
 ;          ;;3^V10^vx2011.1.1 Gold
 ;          ;;3^VX10^vx2011.1.1 Gold with CPT Codes
 ;          ;;
 ;    PORTS ;;8024^56774^57774
 ;
HD ;;<group id>^<header text>
 ;;
 ;
 ;     A - opt - group id           B - req - namespace
 ;     C - req - brief description
 ;     D - opt - Boolean switch to inactivate a namespace
 ;;A^B^C^D
LIST ;
 ;;
 ;
 ; for ports, ;;telnet port^studio port^web port
PORTS ;;
