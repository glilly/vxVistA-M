VFDLADUZ ;DSS/JDB - DUZ UTILITY ; 4/9/10 2:28pm
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 25
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;DSSBUILD - VFDLA 2011.1 * 03/21/11 * vxdev64v2k8_DEVXOS * 2011.1-2
 ;
 ;       DUZ^XUP/4129 [c]
 ;      SITE^VASITE/10112
 ;
 Q
 ;
 ;
SWAPDUZ(R200,DOLD,NOKILL,D2) ;
 ; Changes (Swaps) DUZ array.
 ;
 ; Inputs
 ;    R200:<opt> #200 IEN (DUZ) If present, creates new DUZ from R200.
 ;    DOLD:<byref><opt> Input & Output.  If present, used to restore
 ;        : the DUZ array from (if R200 not specified).
 ;  NOKILL:<opt><dflt=0> Kill DOLD array after reset? 1=dont kill
 ;        :  Used when restoring (R200=0)
 ;      D2:<opt> The #4 IEN used to set DUZ(2).
 ; Outputs
 ;   I R200, DOLD holds copy of DUZ array before the change.
 ;   I 'R200, DOLD is killed.
 ;
 S R200=$G(R200)
 S NOKILL=$G(NOKILL)
 S D2=$G(D2)
 I R200>0 D  Q  ;
 . K DOLD
 . M DOLD=DUZ
 . K DUZ ; See exemption statement
 . D DUZ^XUP(R200)
 . I D2'="" S DUZ(2)=D2
 ;
 ; Restore from old DUZ array
 I R200'="" Q  ;dont kill DUZ if any DUZ passed.
 ; dont restore from DOLD if not good DUZ array
 I $G(DOLD)'>0 Q
 I $D(DOLD)'>1 Q
 K DUZ ; See exemption statement
 M DUZ=DOLD
 I D2'="" S DUZ(2)=D2
 ; Failsafe.  Set DUZ(2) if missing (from DUZ^XUP).
 I $G(DUZ(2))="" D  ;
 . N X
 . S X=$$SITE^VASITE()
 . S DUZ(2)=$P(X,"^",1) ;#4 IEN
 ;
 I 'NOKILL K DOLD
 Q
