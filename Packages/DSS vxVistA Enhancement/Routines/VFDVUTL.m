VFDVUTL ;DSS/SGM,LM - COMMON UTILITIES FOR COMMON CODE; 2/26/2013 18:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 13
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 ; ICR# Supported Reference
 ;----- ---------------------
 ; 2198 $$BROKER^XWBLIB
 ;10104 ^XLFSTR: $$LOW, $$UP
 ;
BROKER(RPC) ; api to determine if in Broker context
 ; RPC - opt - full exact name of RPC
 ;       if RPC is passed, then not only check for broker context, but
 ;       also check to see if this RPC is the one running
 ; Return: 1:Broker context, no RPC check or RPC check failed
 ;         2:Broker context and RPC check is true
 ;         0:Not Broker context
 ;
 N X S X=$$BROKER^XWBLIB I 'X Q 0
 Q 1+$S($G(RPC)="":0,1:$G(XWB(2,"NAME"))=RPC)
 ;
CACHE() ; Boolean ext funct - 1:cache sys  0:not a cache sys
 Q $$VERSION^%ZOSV(1)["Cache"
 ;
CNVT(INPUT,STR,FLAGS) ;  check input string for certain characters only
 G CNVT^VFDVUTL1
 ;
DEBUG(X) ;LM - from SISUTL with permission
 N % S (%,^(0))=1+$G(^XTMP("VFDV",0)),^(%,0)=$H_"%%"_$G(X)
 M:$D(X)>1 ^XTMP("VFDV",%,"SUBS")=X
 Q
 ;
FILENAME(FNM,DPATH) ; generate a unique HFS file name
 ; assumes FNM is a valid IO value for HFS type device
 ;         FNM has a xxxxxx.ext [.ext extension at end of name]
 G FILENAME^VFDVUTL1
 ;
GETENV(VFDR) ; return value of GETENV^%ZOSV
 ; return VFDR = getenv and VFDR(n) = $P(GETENV,U,n)
 D GETENV^VFDVUTL1
 Q
 ;
LOW(X) Q $$LOW^XLFSTR($G(X))
UP(X) Q $$UP^XLFSTR($G(X))
 ;
MVOS() ; return M_type^M_version^OS
 Q $$OS^VFDVUTL1
 ;
OPT(NM) ; run option=NM
 G OPT^VFDVUTL1
 ;
RPC(VFDR,PAR1,PAR2,PAR3,PAR4,PAR5) ; temporary RPC holder
 ; this line is linked to the RPC definition (#8994) as a place holder.
 ; It assumes the RPC is configured as a list array type RPC.
 ; It is used to allow the export of menu context for which nothing is
 ;  as the real M code has not been finished yet.
 S VFDR(0)="-1^Not implemented at this time"
 Q
