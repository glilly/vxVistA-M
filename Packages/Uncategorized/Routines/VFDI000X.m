VFDI000X ;DSS/LM/SGM - Build/Transport/Install support ; 12/14/2012 14:40
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 4
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only invoked via the VFDI0000 routine
 ;Reference: ICR 1157 - entry points intO XPDMENU
 ;
 ;-------------- ADD OPTIONS TO A MENU OR EXTENDED ACTION -------------
ADD(MENU,OPT,SYN,ORD) ;
 ; MENU - Req - Target option NAME
 ;  OPT - Req - Option NAME to add
 ;  SYN - Opt - Synonym
 ;  ORD - Opt - Display order
 ;Returns 0=success or -1^Message on failure
 N I,X,Y,Z
 S MENU=$G(MENU),(OPT)=$G(OPT),SYN=$G(SYN),ORD=$G(ORD)
 I MENU=""!(OPT="") Q "-1^"_$$T(1)
 S X=$$ADD^XPDMENU(MENU,OPT,SYN,ORD)
 I 'X S X="-1^"_$$T(2)_$P(X,U,2)
 Q X
 ;
 ;-------------- DELETE ITEM FROM MENU OR EXTENDED ACTION -------------
DELETE(MENU,OPT) ;
 ; MENU - Req - target option NAME
 ;  OPT - Req - option NAME to delete
 ;Returns 0=success or -1^Message on failures
 ;
 N I,X,Y,Z
 S MENU=$G(MENU),OPT=$G(OPT)
 I MENU=""!(OPT="") Q "-1^"_$$T(1)
 S X=$$DELETE^XPDMENU(MENU,OPT)
 I 'X S X="-1^"_$$T(3)_$P(X,U,2)
 Q X
 ;
 ;---------------------- LOOKUP OPTION ON B INDEX ---------------------
LKOPT(X) ;
 ; X - Req - Option NAME
 ;RETURN - <OPTION ien> OR <0> OR <-1^message>
 ;
 I $G(X)="" Q "-1^"_$$T(1)
 N I,Y,Z S Z=$$LKOPT^XPDMENU(X) S:Z="" Z=0 Q Z
 ;
 ;--------- SET OR REMOVE OUT-OF-ORDER MESSAGE IN OPTION FILE ---------
OUT(OPT,TXT) ;
 ; OPT - Req - NAME of option to set out of order
 ; TXT - Opt - If TXT'="" then set out-of-order message
 ;             If TXT="" or not defined then delete out-of-order msg
 ;No return value
 ;
 I $L($G(OPT)) N I,X,Y,Z D OUT^XPDMENU(OPT,$G(TXT))
 Q
 ;
 ;-------------------------- RENAME AN OPTION -------------------------
RENAME(OLD,NEW) ;
 ; OLD - Req - Old option NAME
 ; NEW - Req - New option NAME
 ;No return value
 ;
 I $L($G(OLD)),$L($G(NEW)) N I,X,Y,Z D RENAME^XPDMENU(OLD,NEW)
 Q
 ;
 ;------------------------ CHECK TYPE OF OPTION -----------------------
TYPE(IEN,VAL) ;
 ; IEN - Req - file 19 ien
 ; VAL - Opt - set of code to check
 ;Return: if VAL is passed, then Boolean return 1:option type=VAL
 ;        else just return the option type (set of code value)
 ;        if problems return null
 N I,X,Y S X=$$TYPE^XPDMENU($G(IEN)) I X'="",$G(VAL)'="" S X=X=VAL
 Q X
 ;
 ;------------------- ADD RPC TO BROKER MENU CONTEXT ------------------
RPC ;
 ; If $D(VFDATA)=0 then VFDOPT = full name of Broker type Option
 ;                  and VFDRPC = full name of RPC
 ; If $D(VFDATA) then VFDATA(option_name,rpc_name)=""
 ;
 ; ----- VFDRET RETURN VALUES ------
 ;  If VFDRET is passed by named reference, then $G(VFDRET)'="" AND
 ;     this call will be silent and will not do any writes
 ;  If VFDRET called by reference [.VFDRET], then $G(VFDRET)="" AND
 ;     this call will write report via MES^XPDUTL
 ;   VFDRET("RPT",#) = report written MES^XPDUTL
 ;   VFDRET("DATA",option_name) = file 19 ien  OR
 ;                                -1 if option does not exist  OR
 ;                                -2 if other problems encountered  OR
 ;                                -3 if option is not a Broker type
 ;   VFDRET("DATA",option_name,rpc_name) = p1 [^p2] where
 ;          p1 = file 8994 ien  OR  -1 if RPC does not exist  OR
 ;               -2 if other probems encountered
 ;          p2 = null  OR  1 if rpc added to menu context  OR
 ;               0 if rpc already registered to menu context  OR
 ;               -2 if other problems encountered trying to add rpc
 ;
 N I,J,X,Y,Z,BL,OPT,RPC,VFDMSG,VFDMSGE,VFDX,VIENS
 S $P(BL," ",51)=""
 I '$D(VFDATA) N VFDATA
 I $G(VFDOPT)'="",$G(VFDRPC)'="" S VFDATA(VFDOPT,VFDRPC)=""
 ; QA input
 I '$D(VFDATA) D ERR(2,1)
 ; validate OPTION(S) of Broker Type
 I $D(VFDATA) S OPT=0 F  S OPT=$O(VFDATA(OPT)) Q:OPT=""  D
 . S Y=$$LKOPT(OPT) I Y<1 S VFDX(OPT)=-1 D ERR(3,1) Q
 . I $$TYPE(Y,"B")'=1 D ERR(4,1) S VFDX(OPT)=-3 Q
 . S VFDX(OPT)=Y,VIENS="?+1,"_Y_","
 . ; validate whether RPCs exist
 . S RPC=0 F  S RPC=$O(VFDATA(OPT,RPC)) Q:RPC=""  D
 . . S Y=$$FIND1^VFDI000A(8994,,"QX",RPC,"B")
 . . I Y<1 S VFDX(OPT,RPC)=-1 D ERR(5,1) Q
 . . S VFDX(OPT,RPC)=Y
 . . ; add RPCs to menu context
 . . N DIERR,VFDA,VFDERR,VFDIEN
 . . S VFDA(19.05,VIENS,.01)=Y,VFDIEN(1)=""
 . . D UPDATE^DIE(,"VFDA","VFDIEN","VFDERR")
 . . I $D(DIERR) D ERR(6,1) S X=-2
 . . E  S X=$S(VFDIEN(1,0)["+":1,1:0)
 . . S $P(VFDX(OPT,RPC),U,2)=X
 . . Q
 . . Q
 . Q
 ; build message array
 K VFDMSG
 S OPT=0 F  S OPT=$O(VFDX(OPT)) Q:OPT=""  S Z=1 I VFDX(OPT)>-1 D
 . S RPC=0 F  S RPC=$O(VFDX(OPT,RPC)) Q:RPC=""  D
 . . S Y=VFDX(OPT,RPC) Q:Y<0  Q:$P(Y,U,2)<0
 . . S X="" I Z S Z=0,X=OPT
 . . D MSG(X,RPC,$P(Y,U,2))
 . . Q
 . Q
 I $D(VFDMSG) D MSG(,,,1)
 I $D(VFDMSGE) D
 . S I=1+$O(VFDMSG(" "),-1),VFDMSG(I)="   "
 . F J=1:1 Q:'$D(VFDMSGE(J))  S I=I+1,VFDMSG(I)=VFDMSGE(J)
 . Q
 I $G(VFDRET)'="" M @VFDRET@("DATA")=VFDX,@VFDRET@("RPT")=VFDMSG
 E  M VFDRET("DATA")=VFDX,VFDRET("RPT")=VFDMSG D MSG^VFDI0000(.VFDMSG)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
ERR(N,PAD) ;
 N L,T S L=1+$O(VFDMSGE(" "),-1) I L=1 D 1 S VFDMSGE(1)=T,L=2
 D @N S:$G(PAD) T="    "_T S VFDMSGE(L)=T
 Q
 ;
1 S T=">>> Error(s) encountered when adding RPC(s) to OPTION(s) <<<" Q
2 S T="Required input parameter(s) missing or invalid" Q
3 S T="Option "_OPT_" does not exist" Q
4 S T="Option "_OPT_" is not a Broker type" Q
5 S T="RPC "_RPC_" does not exist" Q
6 S T="Problems encountered trying to add "_RPC_" to "_OPT Q
 ;
MSG(OPT,RPC,ST,LGD) ;
 N A,L,T,Z S L=+$O(VFDMSG(" "),-1)
 I 'L F L=1:1:4 D M(L) S VFDMSG(L)=T
 I $G(RPC)'="" D
 . S L=L+1,VFDMSG(L)=$E($G(OPT)_BL,1,32)_$E(RPC_BL,1,35)_$E("RA",ST+1)
 . Q
 I $G(LGD) F A=5,6,7 D M(A) S L=L+1,VFDMSG(L)=T
 Q
 ;
M(A) ;
 ;;             >>>>>> RPCs Registered To Menu Context <<<<<<
 ;;                                                                Status
 ;;          Option Name                      RPC Name             RPC Add
 ;;------------------------------  ------------------------------  -------
 ;;>>> Status Legend:
 ;;    A = RPC added to menu context
 ;;    R = RPC already registered to menu context
 S T=$P($T(M+A),";",3) Q
 ;
T(N,PAD) ;
 ;;Required parameter missing or invalid
 ;;ADD~XPDMENU returned an error: 
 ;;DELETE~XPDMENU returned an error: 
 ;;   >>>>>  ERRORS ENCOUNTERED  <<<<<
 ;;No GUI menu option name received
 ;;No RPC name(s) received to add to menu context
 ;;GUI menu option not found: 
 ;;Option is not a Broker type: 
 ;;RPC does not exist on system: 
 ;;Error encountered trying to add RPC
 ;;Added to menu context
 ;;Already registered
 ;;RPCs Registered to Menu Context: 
 N T S T=$T(T+N) S:'$G(PAD) T=$P(T,";",3) S T=$TR(T,";"," ")
 Q T
 ;
 ;------------------------- UNDER DEVELOPMENT -------------------------
 ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 ;
DELMENU ; delete a menu item from an OPTION and OPTION
 ; expects VFDOPT(option_name)=action
 ;         VFDOPT(option_name,menu_item_name)=action
 ; RETURNS:
 ;         VFDOPT(option_name)=action^file 19 ien
 ;         VFDOPT(option_name,menu_item_name)=action^file 19 ien
 ;         if no file 19 ien then option or menu item did not exist
 ;         VFDOPT(option_name,"MSG",i)=text
 ;
 N A,B,I,J,X,Y,Z,CNT,VFD,VFDEL,VFDT,VFDX
 D DEL1 ; see DEL1 for description of VXDEL()
 ; now delete menu items
 S (I,VFD)=0 F  S VFD=$O(VFDOPT(VFD)) Q:VFD=""  D
 . S VFDX=$P(VFDOPT(VFD),U,2)
 . I 'VFDX D  Q
 . . S X=""
 . I 'Y S X=">>> Option "_VFD_" not found, no action taken" D D1(X) Q
 .S X="    Updates to Option: "_VFD D D1(X)
 .S Z=0 F  S Z=$O(VFDOPT(VFD,Z)) Q:Z=""  D
 ..S A=$P(VFDOPT(VFD,Z),U,2)
 ..I 'A S X=">>>   Menu item "_Z_" not found, no action taken" D D1(X) Q
 ..S A=$$DIK(19,A),B="   Menu Item "_Z_" "
 ..I A S X="   "_B_"removed from "_VFD D D1(X)
 ..I 'A S X=">>>"_B_"not removed from "_VFD D D1(X)
 ..Q
 .Q
 Q
 ;
D1(A) Q  ; see D1^VFDI000A
DIK(A,B) Q  ; see DIK^VFDI000A
 ;
DEL1 ; count number to be deleted, convert to FM pointers
 ; vfdel(1,19_ien)        = menu option name ^ Boolean delete flag
 ; vfdel(1,19_ien,19_ien) = option name within a menu ^ Boolean del
 ; vfdel(2,19_ien)        = option name within a menu to be deleted
 ; vfdel(-1,option_name)  = menu_opt_name or "" for OPTIONs not found
 ;                          "" if menu_opt_name itself was not found
 ;                           else option_name = item in a menu option
 N I,X,Y,Z,DEL,VFD,VFDX
 S VFD=0 F  S VFD=$O(VFDOPT(VFD)) Q:VFD=""  D
 .S X=$$FIND1^VFDI000A(19,,"Q",VFD,"B")
 .S VFDX=X,DEL=$P(VFDOPT(VFD),U)="del"
 .I X<1 S VFDEL(-1,VFD)=""
 .E  S VFDEL(1,X)=VFD_U_DEL
 .; now convert menu options to Fileman pointers
 .S Z=0 F  S Z=$O(VFDOPT(VFD,Z)) Q:Z=""  D
 ..S X=$$FIND1^VFDI000A(19,,"Q",Z,"B"),DEL=$P(VFDOPT(VFD,Z),U)="del"
 ..I X<1 S VFDEL(-1,Z)=VFD Q
 ..S VFDEL(1,VFDX,X)=Z_U_DEL,VFDEL(2,X)=Z
 ..Q
 .Q
 Q
 ;
DEL2 ; delete menu items from menu options
 N I,X,Y,Z,VFDI,VFDO
 S VFDO=0 F  S VFDO=$O(VFDEL(1,VFDO)) Q:'VFDO  D
 .Q
 Q
 ;
DEL11(X) N I S I=1+$O(VFDOPT(VFD,"MSG"," "),-1),VFDOPT(VFD,"MSG",I)=X Q
 ; remove all options from menu
 S VFD=0 F  S VFD=$O(^DIC(19,VOPT,10,VFD)) Q:'VFD  D
 .N DA,DIK S DA(1)=VOPT,DA=VFD,DIK="^DIC(19,"_VOPT_",10,"
 .D ^DIK
 .Q
 ; delete old options
 S VFD=0 F  S VFD=$O(VOPT(VFD)) Q:'VFD  D
 .N DA,DIK S DA=VOPT,DIK="^DIC(19," D ^DIK
 .Q
 Q
