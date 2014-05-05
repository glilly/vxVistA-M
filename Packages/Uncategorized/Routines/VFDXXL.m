VFDXXL ;DSS/LM - Exception handler User Interface ; 3/10/2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 Q
EN ;[Public] -- main entry point for List Template VFDXXLST
 N VFDXTMP D EN^VALM("VFDXXLST")
 Q
 ;
HDR ; -- header code
 S VALMHDR(1)="Exceptions List" I $L($G(VFDXSDT)) D
 .S VALMHDR(1)=VALMHDR(1)_" Starting "_VFDXSDT
 .Q
 S VALMHDR(1)=$$CJ^XLFSTR(VALMHDR(1),80)
 S VALMHDR(2)="" ;Reserved
 Q
 ;
INIT ; -- init variables and list array
 ;
 D INIT^VFDXXLU
 Q
 ;
HELP ; -- help code
 S X="?" D DISP^XQORM1 W !!
 Q
 ;
EXIT ; -- exit code
 Q
 ;
EXPND ; -- expand code
 Q
 ;
