VFDVUTL2 ;DSS/LM - KIDS COMPARE ; 08/04/2011 10:13
 ;;2010.1;DSS,INC VXVISTA;;06 Apr 2010;
 ; 
 ;
 Q
 ;
RCMP(VFDRSLT,VFDLIST,VFDFLAG) ; Compare Loaded KIDS Routines to System
 ; EXPECTS the variable XPDA to be defined to a Loaded Kids Build
 ; This will compare the second line of routines in a loaded KIDS build
 ;   in ^XTMP() to that in the routines on the system. 
 ;
 ; .VFDLIST - opt - list of rotutines to compate
 ;                  default to all routines in the Build
 ;                  EXPECTS VFDLIST(n)=routine name where n=1,2,3,4,...
 ;                    and the values of n MUST be sequential
 ;  VFDFLAG - opt - Boolean, 1:exclude from compare
 ;                  Default is 0:include
 ; .VFDRSLT - opt - Results of comparison
 ;    Returns VFDRSLT(1)=0 if there are no differences, else return
 ;                  Returns VFDRSLT(n)=-1^message where n=1,2,3,4,...
 ;
 N VFDI,VFDJ,VFDNDX,VFDRTN,VFDRTV,VFDRTX,VFDX
 I '$G(VFDA) S VFDRSLT(1)="-1^Invalid context" D ERR Q  ;Requires loaded KID
 S VFDFLAG=$G(VFDFLAG)
 S VFDNDX=$NA(^TMP("VFDNDX",$J)) K @VFDNDX
 F VFDI=1:1 Q:'$L($G(VFDLIST(VFDI)))  S @VFDNDX@(VFDLIST(VFDI))="" ;cross-ref
 S VFDX=$NA(^XTMP("XPDI",XPDA,"RTN"))
 S VFDJ=0,VFDRTN="",VFDRSLT(1)=0
 F  S VFDRTN=$O(@VFDX@(VFDRTN)) Q:VFDRTN=""  D  ;For each routine
 .I VFDFLAG,$D(@VFDNDX@(VFDRTN)) Q  ;Explicitly excluded
 .I 'VFDFLAG,$D(VFDLIST)>1,'$D(@VFDNDX@(VFDRTN)) Q  ;Not explicitly included
 .; Fall through here if ALL routines, OR explicitly included OR not excluded
 .; VFDRTV=Line 2 of routine in environment.. VFDRTX=Line 2 of routine in KID
 .S VFDRTV=$T(@("+2^"_VFDRTN)),VFDRTX=$G(@VFDX@(VFDRTN,2,0))
 .I VFDRTV="" S VFDJ=VFDJ+1,VFDRSLT(VFDJ)="-1^"_VFDRTN_"^does not exist." Q
 .I $P(VFDRTV,";",3)=$P(VFDRTX,";",3) ;Compare VERSION
 .E  S VFDJ=VFDJ+1,VFDRSLT(VFDJ)="-1^"_VFDRTN_"^Version differs." Q
 .I $P(VFDRTV,";",5)=$P(VFDRTX,";",5) ;Compare PATCHES
 .E  S VFDJ=VFDJ+1,VFDRSLT(VFDJ)="-1^"_VFDRTN_"^Patch level differs."
 .Q
 I VFDJ S VFDRSLT(1)=VFDJ D ERR
 Q
 ;
ERR ;
 W !,"The environment check reported one or more problems!" S XPDQUIT=2
 Q
