VFDIOR01 ;DSS/LM - Core CPRS Pre/Post-Install ; 8/26/08 7:42am
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;** Standard vxVistA pre- and post- install routine **
 ;  Include in build, whether or not code is present.
 ;
 Q
 ; Code below is duplicated from routine ^VFDCORE
ISMOD(X) ;Return 1=TRUE if and only if VistA routine is modified
 ; X=[Required] Name of routine to check
 ;
 Q:'$L($G(X)) "" ;Invalid argument
 N DIF,XCNP S DIF="^TMP($J,""VFDCORE""" K @(DIF_")") S DIF=DIF_",",XCNP=0
 X ^%ZOSF("LOAD")
 N VFDI,VFDX,VFDY S VFDY=0,$E(DIF,$L(DIF))=")"
 F VFDI=1:1 Q:VFDY!'$D(@DIF@(VFDI))  S VFDX=$G(^(VFDI,0)) D
 .S VFDX=$TR($$LOW^XLFSTR(VFDX)," "),VFDY=VFDX[";dss"&(VFDX["beginmod")
 .Q
 K @DIF Q VFDY
 ;
PRE ;
 ; This CPRS build will be installed first!
 ; The following is copied from the master build pre-install
 Q:$$ISMOD("XPDET")  ;Nothing to do
 ;
 N DIF,X,XCNP S DIF="^TMP($J,""VFDCORE""" K @(DIF_")") S DIF=DIF_",",X="XPDET",XCNP=0
 X ^%ZOSF("LOAD")
 N VFDB,VFDI,VFDX,VFDY S (VFDB,VFDY)=0,$E(DIF,$L(DIF))=")"
 F VFDI=1:1 Q:VFDY!'$D(@DIF@(VFDI))  S VFDX=$G(^(VFDI,0)) D
 .S:VFDX?1"INPUTB".E VFDB=1 Q:'VFDB
 .S:VFDX?1"INPUTE".E VFDB=0 Q:'VFDB
 .; Modify XPDET in INPUTB block
 .I VFDX?1." "1"I $L(X)>50!($L(X)<3)!$D(^XPD(9.6,""B"",X))".E D  Q
 ..S @DIF@(VFDI_".1",0)=" ; DSS/LM Begin modification permitting 1.4N1"".""1.2N version"
 ..Q
 .I VFDX?1." "1"I X[""*"" K:$P(X,""*"",2,3)'?1.2N1"".""1.2N".E D  Q
 ..S @DIF@(VFDI,0)=$P(VFDX,"1.2")_"1.4"_$P(VFDX,"1.2",2,99)
 ..Q
 .I VFDX?1." "1"S %=$P(X,"" "",%) K:%'?1.2N1"".""1.2N".E D  Q
 ..S @DIF@(VFDI,0)=$P(VFDX,"1.2")_"1.4"_$P(VFDX,"1.2",2,99)
 ..S @DIF@(VFDI_".1",0)=" ; DSS/LM End modification"
 ..S VFDB=0 ;Done
 ..Q
 .Q
 ; Re-save routine here after modifying
 S @DIF@($O(@DIF@(""),-1)+1,0)="$" ;End mark
 N DIE,XCM,XCN S DIE=$E(DIF,1,$L(DIF)-1)_",",XCN=0
 X ^%ZOSF("SAVE") K ^TMP($J,"VFDCORE")
 Q
POST ;
 Q
