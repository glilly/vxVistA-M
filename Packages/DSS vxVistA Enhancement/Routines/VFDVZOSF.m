VFDVZOSF ;VSA/SGM - INTERFACE TO %ZOSF GLOBAL ; 07/28/2011 18:15
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 86
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;DBIA# Supported Reference
 ;----- --------------------------------
 ;10096 All ^%ZOSF() nodes are useable
 ;
ZOSF(NODE,NOEX,X,ROU,ROOT) ; access ^%ZOSF nodes [Extrinsic Function]
 ; retired on 12/28/2009, please use the ZOSF1 line tag
 N A,VINPUT
 S VINPUT("NODE")=$G(NODE)
 F A="X","NOEX","ROU","ROOT" I $D(@A)#2 S VINPUT(A)=@A
 Q $$ZOSF1(.VINPUT)
 ;
ZOSF1(VINPUT) ; access ^%ZOSF nodes [Extrinsic Function]
 ; VINPUT(subscript)=value where subscript can be:
 ; NODE - req - subscript name of node in %ZOSF global
 ;    X - opt - required for those %zosf nodes expecting X (see ROU)
 ; NOEX - opt - 0:eXecute the node or return value of node - default
 ;              1:node must contain eXecutable code, return a string
 ;                which is eXecutable
 ;  ROU - opt - valid only for those nodes which expect a routine
 ;              only used if NOEX=1
 ;              I $G(ROU)'="" then you wish the executable code in that
 ;              %zosf node to be returned with the following logic
 ;              appended to that executable string.  The executable
 ;              string returned will expect that the calling routine
 ;              will defined the variable ROU prior to X STRING.
 ;              Return:
 ;         N X S X=$G(ROU) I X'="" X ^%ZOSF("TEST") I  X ^%ZOSF(node)
 ; ROOT - opt - required for LOAD and SAVE nodes.  ROOT must be of
 ;              closed form such that @ROOT@(n)=nth line of routine
 ;              where n is expected to start with a value of 1.  ROOT
 ;              may be a local or global array.
 ; XCNP - opt - only for the %ZOSF("LOAD") calls.  XCNP is the whole
 ;              number incrementer value such that LOAD will put the
 ;              data in the XCNP+1, XCNP+2, XCNP+3, ... nodes.
 ;
 ;RETURN VALUES
 ;If problems, return -1^message
 ;If ^%ZOSF(NODE) just contains a value (i.e., not executable), then
 ;  just return that value
 ;If NOEX return a string which is the argument of an Xecute command
 ;If 'NOEX then actually execute the node and return an appropriate
 ;  value which will be 1 for those nodes which do not generate a value
 ;
 N X,NODE,NOEX,ROOT,ROU,XCNP
 N I,Y,Z,CODE,GVAL,TEST,TYPE
 F Z="X","NODE","NOEX","ROOT" S @Z=$G(VINPUT(Z))
 F Z="ROU","XCNP" I $D(VINPUT(Z)) S @Z=VINPUT(Z)
 I 'NOEX K ROU
 S TYPE=$$CKNODE(NODE) I +TYPE=-1 Q TYPE
 S GVAL=^%ZOSF(NODE)
 ; return value of node if non-executable
 I TYPE["V" Q GVAL
 ; get executable string
 S CODE=$$BUILDEX
 ; if NOEX then do not execute but return a executable string
 I NOEX Q CODE
 ; actually execute node and return appropriate answer
 X CODE
 Q $S(TYPE["Y":$G(Y),1:1)
 ;
 ;------------------------ PRIVATE SUBROUTINES ------------------------
ERR(A) ;
 N T
 I A=1 S T="No %ZOSF node name received"
 I A=2 S T=NAM_" not found"
 I A=3 S T="This API does not support calling "_NAM
 I A=4 S T="The parameter X is required but had no value"
 I A=5 S T="No routine name received"
 I A=6 S T=NAM_" requires that DX,DY be defined"
 I A=7 S T="Invalid NODE value received: "_NODE
 I A=8 S T="No value for input param ROOT received"
 I A=9 S T="Input param ROOT is not in closed form"
 I A=10 S T="Expect data in the ROOT input parameter"
 Q "-1^"_T
 ;
BUILDEX() ; build executable string
 I TYPE'["R" Q GVAL
 I TYPE["L" Q $$LOAD
 I TYPE["S" Q $$SAVE
 I NODE["RSUM" Q $$TEST
 Q GVAL
 ;
LOAD() ; build exectuable string for LOAD a routine
 N STR
 S STR="K "_ROOT_" N %,%N,DIF,RG,TMP,XCNP S XCNP=0,"
 S STR=STR_"RG=$NA("_ROOT_"),DIF=""TMP("" "
 I $D(ROU) S STR=STR_"N X S X=ROU "
 S STR=STR_^%ZOSF("TEST")_" X ^%ZOSF(""LOAD"")"
 S STR=STR_" F %=1:1 Q:'$D(TMP(%,0))  S @RG@(%)=TMP(%,0)"
 Q STR
 ;
SAVE() ; build executable string for SAVE a routine
 ;;N %,J,DIE,GLB,RG,XCM,XCN,XCS S (J,XCN)=0,RG=$NA(
 ;;),GLB=$NA(^TMP("VFDZOSF",$J)),DIE=$E(GLB,1,$L(GLB)-1)_",",%=0 K @GLB
 ;; X "F  S %=$O(@RG@(%)) Q:'%  S J=J+1,@GLB@(J,0)=
 ;;$S($D(@RG@(%,0)):@RG@(%,0),1:@RG@(%))" X ^%ZOSF("SAVE")
 ;; K ^UTILITY("ROU",X),@GLB
 N I,STR,VCD
 I $O(@ROOT@(0))<1
 F I=1:1:5 S STR(I)=$P($T(SAVE+I),";",3,99)
 S STR(1)=STR(1)_ROOT
 S STR="" F I=1:1:5 S STR=STR_STR(I)
 Q STR
 ;
TEST(A) ; test existence of routine ROU
 I '$D(ROU) Q GVAL
 Q "N X S X=ROU "_^%ZOSF("TEST")_" "_GVAL
 ;
 ;-------------------- CLASSIFY TYPE OF %ZOSF NODE --------------------
CKNODE(N) ; check for valid node
 ; return code(s)
 ;   where code [ X if node expects an input value in X
 ;              [ Y if node returns a value in Y
 ;              [ V if node is not executable but only contains a value
 ;              [ M if node is of other types than in this list
 ;              [ R if node is one that works on a routine
 ;              [ L if node = LOAD
 ;              [ S if node = SAVE
 ; return -1 if problems or node not supported
 ;Notes: if code["R" & $G(X)="" then ROU must defined
 N Y,Z,NAM
 S Z="" I $G(N)="" Q $$ERR(1)
 S NAM=$NA(^%ZOSF(N)) I $G(@NAM)="" Q $$ERR(2)
 I $$NOTSUPP(N) Q $$ERR(3)
 I $$NONEX(N) S Z="V"
 I $$ONODE(N) D  I +Z=-1 Q Z
 .I 'NOEX,N="XY" I $G(DX)'?1.N!($G(DY)'?1.N) S Z=$$ERR(6) Q
 .S Z=Z_"M"
 .Q
 I $$RNODE(N) S Z=Z_"R"
 I $$XNODE(N) D  I +Z=-1 Q Z
 .I 'NOEX,$G(X)="",Z["R",'$D(ROU) S Z=$$ERR(5) Q
 .I 'NOEX,$G(X)="",Z'["R" S Z=$$ERR(4) Q
 .S Z=Z_"X"
 .Q
 I $$YNODE(N) S Z=Z_"Y"
 I N="LOAD"!(N="SAVE") D  I +Z=-1 Q Z
 .I $G(ROOT)="" S Z=$$ERR(8) Q
 .S Y=$E(ROOT,$L(ROOT)) I Y?1P,Y'=")" S Z=$$ERR(9) Q
 .S Z=Z_$E(N)
 .Q
 I Z="" S Z=$$ERR(7)
 Q Z
 ;
NONEX(N) ; nodes which contain a value and are not executable
 Q "^MGR^OS^PROD^VOL^"[(U_N_U)
 ;
NOTSUPP(N) ; nodes not supported
 Q "^ERRTN^ETRP^TMP^TRAP^"[(U_N_U)
 ;
ONODE(N) ; misc nodes
 Q "^RSEL^XY^"[(U_N_U)
RNODE(N) ; nodes which deal with routines
 Q "^DEL^LOAD^RSUM^RSUM1^SAVE^"[(U_N_U)
 ;
XNODE(N) ; nodes which expect a value in X
 I $$RNODE(N) Q 1
 Q "^LPC^MAXSIZ^PRIORITY^RM^TEST^UCICHECK^UPPERCASE^ZD^"[(U_N_U)
 ;
YNODE(N) ; nodes which return a value in Y
 ;;^ACTJ^AVJ^EOT^JOBPARAM^LPC^MTBOT^MTERR^MTONLINE^MTWPROT^PRIINQ^
 ;;^PROGMODE^SIZE^TMK^TRMRD^UCI^UCICHECK^UPPERCASE^ZD^
 I $T(YNODE+1)[(U_N_U) Q 1
 Q $T(YNODE+2)[(U_N_U)
