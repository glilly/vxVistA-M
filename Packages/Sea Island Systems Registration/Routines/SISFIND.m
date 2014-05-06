SISFIND ;SIS/LM - Sea Island Systems Object FIND Utilities ; 09/21/2012
 ;;1.01;SIS PATIENT REGISTRATION;;;Build 92
 ;
 ; The SISFIND* routine set relies upon Cache-specific language constructs.
 ;
 Q
FM(SISRSLT,SISFILE,SISENTRY,SISFLGS) ;[Public] Find entry in FileMan file
 ; SISRSLT=Results array by reference
 ; 
 ; SISFILE=[Required]File number
 ; SISENTRY=[Required]Entry lookup value
 ; SISFLGS=[Optional]Flags
 ;
 I $L($G(SISFILE)),'(SISFILE>0) S SISFILE=$$LOOKUP(SISFILE)
 I $G(SISFILE)>0,$L($G(SISENTRY)) N SISI,SISHOME,SISNMSP
 E  S SISRSLT(1)="-1^Invalid file or entry specification" Q
 S SISHOME=$ZU(5) N $ETRAP,$ESTACK S $ETRAP="ZN SISHOME D ERR^SISFIND"
 ; Substitute computed namespace list - 9/18/2012
 ;F SISI=1:1 S SISNMSP=$P($T(DATA+SISI),";;",2) Q:'$L(SISNMSP)  D
 N SIS D FMLIST(.SIS) F SISI=1:1 Q:'$D(SIS(SISI))  S SISNMSP=SIS(SISI) D
 .ZN SISNMSP D FIND(.SISRSLT,SISFILE,SISENTRY,.SISFLGS)
 .Q
 ZN SISHOME
 I '$D(SISRSLT) S SISRSLT(1)="-1^No results found"
 Q
DD(SISRSLT,SISDD) ;[Public] Find DD entry
 ; SISRSLT=Results array by reference
 ; 
 ; SISDD=[Required] DD# or DD#,Field#
 ;
 I $L($G(SISDD)) S SISDD=$TR(SISDD,":",",") N SISI,SISHOME,SISNMSP,SISP,SISQ
 I  S SISQ=0 F SISI=1:1:$L(SISDD,",") D  Q:SISQ
 .S SISP=$P(SISDD,",",SISI) S SISQ='(SISP=+SISP)
 .Q
 I $T,'SISQ
 E  S SISRSLT(1)="-1^Invalid DD specification" Q
 S SISHOME=$ZU(5) N $ETRAP,$ESTACK S $ETRAP="ZN SISHOME D ERR^SISFIND"
 ; Substitute computed namespace list - 9/18/2012
 ;F SISI=1:1 S SISNMSP=$P($T(DATA+SISI),";;",2) Q:'$L(SISNMSP)  D
 N SIS D FMLIST(.SIS) F SISI=1:1 Q:'$D(SIS(SISI))  S SISNMSP=SIS(SISI) D
 .ZN SISNMSP D DDFIND(.SISRSLT,SISDD)
 .Q
 ZN SISHOME
 I '$D(SISRSLT) S SISRSLT(1)="-1^No results found"
 Q
BLD(SISRSLT,SISCOM,SISENTRY,SISFLGS) ;[Public] Find entry in BUILD component
 ; SISRSLT=Results array by reference
 ; 
 ; SISCOM=[Optional]COMPONENT type (e.g. OPTION, ROUTINE, ...)
 ;        FILE type components (subfile, field, etc.) not currently supported
 ; SISENTRY=[Required]Entry lookup value
 ; SISFLGS=[Optional]Flags -
 ;         "H"=Search Home namespace only
 ;         "X"=Exact match required for SISENTRY (Default is SISENTRY*)
 ;
 I $L($G(SISENTRY)) S SISCOM=$G(SISCOM),SISFLGS=$TR($G(SISFLGS),"hx","HX")
 E  S SISRSLT(1)="-1^Invalid entry specification" Q
 N SISHOME,SISI,SISL,SISNMSP S SISL=$L(SISENTRY)
 I 'SISCOM,$L(SISCOM) S SISCOM=$$FIND1^DIC(1,,"X",SISCOM,"B")
 S SISHOME=$ZU(5) N $ETRAP S $ETRAP="ZN SISHOME D ERR^SISFIND"
 I '$G(SISQUIET) D WAIT^DICD W ! ;Could take a few minutes
 I SISFLGS["H" S SISNMSP=SISHOME D FBLD(.SISRSLT,SISCOM,SISENTRY,.SISFLGS)
 I '(SISFLGS["H") N SIS D
 .; Substitute computed namespace list - 9/18/2012
 .;F SISI=1:1 S SISNMSP=$P($T(DATA+SISI),";;",2) Q:'$L(SISNMSP)  D
 .D FMLIST(.SIS) F SISI=1:1 Q:'$D(SIS(SISI))  S SISNMSP=SIS(SISI) D
 ..ZN SISNMSP D FBLD(.SISRSLT,SISCOM,SISENTRY,.SISFLGS)
 ..Q
 .Q
 ZN SISHOME
 I '$D(SISRSLT) S SISRSLT(1)="-1^No results found"
 Q
REF(BEG,END,STR,CS) ;[Public] Search for string in DD range
 ; Home namespace only
 ;
 ; BEG=[Required] Beginning file number
 ; END=[optional] Ending file number (default=BEG)
 ; STR=[optional] Search string (default 'veteran')
 ; CS=[optional] Flag indicating case-sensitive (default=NOT case-sensitive)
 ; 
 I $G(BEG)?1.N.1".".N S END=$G(END,BEG),STR=$G(STR,"veteran"),CS=$G(CS)
 E  W !,"Error: Invalid input parameter!" Q
 N X S X=$NA(^DD(BEG-.0000001)),STR=$S(CS:STR,1:$$UP^XLFSTR(STR))
 F  S X=$Q(@X) Q:X=""  Q:$QS(X,1)>END  D
 .I $S(CS:@X,1:$$UP^XLFSTR(@X))[STR W !,X,!,@X,!
 .Q
 Q
COMPARE(SISRSLT,SISFILE,SISENTRY,SISFLGS) ;[Public] Compare object across namespaces
 ; SISOBJ=[Required]File#^IEN
 ; SISRSLT=Results array by reference
 ; 
 ; SISFILE=[Required]File number
 ; SISENTRY=[Required]Entry lookup value (Exact match required)
 ; SISFLGS=[Optional]Flags
 ;
 I SISFILE=9.8 S SISRSLT(1)="-1^Routine compare not implemented. Use ROUCI^%." Q
 N SISHOME S SISHOME=$ZU(5)
 S SISFLGS=$G(SISFLGS) S:'(SISFLGS["X") SISIFLGS=SISFLGS_"X"
 N SISTEMP D FM(.SISTEMP,.SISFILE,.SISENTRY,SISFLGS)
 I $G(SISTEMP(1))?1"-1".E M SISRSLT=SISTEMP Q
 N SISFLD,SISI,SISIENS,SISJ,SISK,SISLEFT,SISR,SISRIGHT,SISRR,SISX,SISY
 S SISK=0 S SISR=$NA(^[SISHOME]TMP("SISFIND",$J)) K @SISR
 F SISI=1:1 Q:'$D(SISTEMP(SISI))  F SISJ=SISI+1:1 Q:'$D(SISTEMP(SISJ))  D
 .S SISLEFT=$P(SISTEMP(SISI),U),SISRIGHT=$P(SISTEMP(SISJ),U)
 .S SISK=SISK+1,SISRSLT(SISK)="$COMPARE^"_SISTEMP(SISI)_U_SISTEMP(SISJ)
 .ZN $P(SISTEMP(SISI),U) D GETS($NA(@SISR@(SISLEFT)),SISFILE,$P(SISTEMP(SISI),U,2))
 .ZN $P(SISTEMP(SISJ),U) D GETS($NA(@SISR@(SISRIGHT)),SISFILE,$P(SISTEMP(SISJ),U,2))
 .ZN SISHOME
 .; First cut compare - Simplified
 .S SISX=$NA(@SISR@(SISLEFT,SISFILE),$P(SISTEMP(SISI),U,2)_",")
 .S SISY=$NA(@SISR@(SISRIGHT,SISFILE),$P(SISTEMP(SISJ),U,2)_",")
 .S SISFLD="" F  S SISFLD=$O(@SISX@(SISFLD)) Q:'SISFLD  D
 ..Q:$G(@SISX@(SISFLD))=$G(@SISY@(SISFLD))
 ..S SISK=SISK+1,SISRSLT(SISK)="$FIELD^"_SISFLD
 ..S SISK=SISK+1,SISRSLT(SISK)=SISLEFT_U_@SISX@(SISFLD)
 ..S SISK=SISK+1,SISRSLT(SISK)=SISRIGHT_U_@SISY@(SISFLD)
 ..; To do: Generalize to include subfiles and fields
 ..; Use $query to traverse arrays (See ACMP() below)
 ..Q
 .Q
 Q
LOOKUP(SISFILE) ;[Private] Lookup file in FILE file
 Q $$FIND1^DIC(1,,"X",$G(SISFILE))
 ;
FIND(SISRSLT,SISFILE,SISENTRY,SISFLGS) ;[Private] Wraps FIND^DIC
 ; with reduced parameters list.  Appends results.
 ; SISRSLT=Results array by reference
 ; 
 ; SISFILE=[Required]File number
 ; SISENTRY=[Required]Entry lookup value
 ; SISFLGS=[Optional]Flags
 ; 
 ; Assume parameters are properly defined, since procedure is private
 ;
 I $T(FIND^DIC)]"" N SISI,SISN,SISTRGT S SISN=+$O(SISRSLT(" "),-1)
 E  Q  ;Not FileMan environment
 D FIND^DIC(SISFILE,,"@;.01",.SISFLGS,$G(SISENTRY),,,,,$NA(SISTRGT))
 N SISR S SISR=$NA(SISTRGT("DILIST")) F SISI=1:1 Q:'$D(@SISR@(2,SISI))  D
 .S SISRSLT(SISN+SISI)=$ZU(5)_U_@SISR@(2,SISI)_U_@SISR@("ID",SISI,.01)
 .Q
 Q
DDFIND(SISRSLT,SISDD) ;[Private] Continuation of DD
 ; Appends results
 ;
 N SISNAM,SISD S SISNAM="^DD("_SISDD_")" S SISD=$D(@SISNAM) Q:'SISD
 N SISI S SISI=1+$O(SISRSLT(" "),-1)
 S SISRSLT(SISI)=$ZU(5)_U_$S(SISD#2:"exists",1:"has descendent(s)")_U_$G(@SISNAM)
 Q
FBLD(SISRSLT,SISCOM,SISENTRY,SIFLGS) ;[Private] Come here from BLD
 ; Find component in BUILD file (one namespace). Assume valid context.
 ; 
 ; SISRSLT=Results array by reference
 ; 
 ; SISCOM=[Required]COMPONENT type IEN (e.g. 19, 9.8, ...) or NULL
 ; SISENTRY=[Required]Entry lookup value
 ; SISFLGS=[Optional]Flags
 ;
 N SISBIEN,SISBNM,SISCIEN,SISCNM,SISDIEN,SISX,SISX1 S SISBIEN=" "
 F  S SISBIEN=$O(^XPD(9.6,SISBIEN),-1) Q:'SISBIEN  D
 .S SISBNM=$P($G(^XPD(9.6,SISBIEN,0)),U)
 .I SISCOM S SISCIEN=SISCOM D FBLDCONT Q
 .S SISCIEN=0 F  S SISCIEN=$O(^XPD(9.6,SISBIEN,"KRN",SISCIEN)) Q:'SISCIEN  D FBLDCONT
 .Q
 Q
FBLDCONT ;[Private] Common continuation of FBLD
 ; Assume valid context
 ;
 S SISCNM=$P($G(^DIC(SISCIEN,0)),U)
 S SISDIEN=0 F  S SISDIEN=$O(^XPD(9.6,SISBIEN,"KRN",SISCIEN,"NM",SISDIEN)) Q:'SISDIEN  D
 .S SISX=$G(^(SISDIEN,0)),SISX1=$P(SISX,U)
 .Q:'$S(SISFLGS["X":SISX1=SISENTRY,1:$E(SISX1,1,SISL)=SISENTRY)
 .S SISRSLT($O(SISRSLT(""),-1)+1)=SISNMSP_U_SISBNM_U_SISCNM_U_$P(SISX,U)_U_$$GET1^DIQ(9.6,SISBIEN,.02) ;*** PDW
 .Q
 Q
GETS(SISRSLT,SISFILE,SISENTRY) ;[Private] Wraps GETS^DIQ
 ; with reduced parameters list.
 ; 
 ; SISRSLT=[Required]$NAME(results array)
 ; SISFILE=[Required]File number
 ; SISENTRY=[Required]Entry lookup value
 ; 
 ; Omit parameter validation (private procedure)
 ;
 D GETS^DIQ(.SISFILE,+$G(SISENTRY)_",","**",,.SISRSLT)
 Q
ACMP(SISRSLT,SISARY1,SISARY2) ;[Private] Compare two GETS results arrays
 ;
 ; SISRSLT=[Required]Results array by reference
 ; SISARY1=[Required]$NAME(array 1)
 ; SISARY2=[Required]$NAME(array 2)
 ; 
 ; Structure of SISARY1 and SISARY2 ->
 ; 
 ;     NAME("SISFIND",$JOB,NAMESPACE,[SUB]FILE,IENS,FIELD)
 ;     
 ; Omit parameter validation (private procedure)
 ;
 ; Append results
 ; 
 N SISI,SISJ,SISK,SISUBX,SISUBY,SISX,SIXY
 S SISK=+$O(SISRSLT(" "),-1),SISX=SISARY1,SISY=SISARY2
 F  S SISX=$Q(@SISX)  Q:'(SISX["SISFIND")  D
 .S SISY=$Q(@SISY)
 .F SISI=4:1:6 S SISUBX(SISI)=$QS(SISX,SISI)
 .F SISI=4:1:6 S SISUBY(SISI)=$QS(SISY,SISI)
 .S SISS=0 F SISI=4:1:6 I '(SISUBX(SISI)=SISUBY(SISI)) S SISS=1 Q
 .I SISS=1  D  Q  ;Difference in subscripts
 ..Q
 .Q:@SISX=@SISY  ;Same value
 .S SISK=SISK+1,SISRSLT(SISK)="$[SUB]FIELD^"_U_SISUBX(4)_"^#"_SISUBX(6)
 .S SISK=SISK+1,SISRSLT(SISK)=$QS(SISX,3)_U_@SISX
 .S SISK=SISK+1,SISRSLT(SISK)=$QS(SISY,3)_U_@SISY
 .Q
 Q
MLIST(SISRSLT,SISDD) ;[Public] Return tree path information for DD#
 ;SISDD=[Required] DD file# or field#, canonic numeric
 ;
 ;SISRSLT=   Number of levels from File (top) to DD# (bottom)
 ;        (1)=File level (file number)
 ;        (2)=First multiple level  (DD number)
 ;        (3)=Second multiple level (DD number)
 ;        Etc. (Last is the argued SISDD)
 ;
 Q:'$G(SISDD) 0
 I $D(^DIC(SISDD,0)) S SISRSLT(1)=SISDD Q 1
 N SISI,SISJ,SISX S (SISX,SISX(1))=SISDD
 F SISI=2:1 S SISX=$G(^DD(SISX,0,"UP")) Q:'SISX  S SISX(SISI)=SISX
 F SISJ=1:1:SISI-1 S SISRSLT(SISJ)=SISX(SISI-SISJ)
 Q SISJ
 ;
XALL(SISRSLT,SISDD,SISXCMD) ;[Public] Traverse all (sub)-entries and
 ; do something (SISXCMD)
 ; 
 ;SISDD=[Required] DD file# or field#, canonic numeric
 ;SISXCMD=[Optional] M code to XECUTE for each (sub) entry traversed
 ;       (I)         M code to XECUTE after Ith loop (e.g. QUIT:CONDITION)
 ;                   Caller's Xecute code can refer to subscripts,
 ;                   SIS(1),SIS(2), etc. or to naked ^(SIS(SISN),0), etc.
 ;                   
 ;SISRESULT= 0 for success or -1^Text
 ;
 I '($G(DUZ(0))="@") S SISRSLT="-1^PROGRAMMER ACCESS DUZ(0)=""@"" is required" Q
 I '$G(SISDD) S SISRSLT="-1^Invalid DD#" Q
 N SIS,SISI,SISLOOPS,SISN,SISX S SISRSLT=0,SISXCMD=$G(SISXCMD),SISN=$$MLIST(.SISX,SISDD)
 ; Construct outermost loop
 S SISLOOPS(1)="S SIS(1)=0 F  S SIS(1)=$O("_$$ROOT^DILFD(SISX(1))_"SIS(1))) Q:'SIS(1)"
 I $L($G(SISXCMD(1))) S SISLOOPS(1)=SISLOOPS(1)_"  "_SISXCMD(1)
 S SISIENS=",SIS(1),"
 F SISI=2:1:SISN D  ;Add nested loops
 .S SISLOOPS(SISI-1)=SISLOOPS(SISI-1)_"  X SISLOOPS("_SISI_")"
 .S SISLOOPS(SISI)="S SIS("_SISI_")=0 F  S SIS("_SISI_")=$O("_$$ROOT^DILFD(SISX(SISI),SISIENS)_"SIS("_SISI_"))) Q:'SIS("_SISI_")"
 .I $L($G(SISXCMD(SISI))) S SISLOOPS(SISI)=SISLOOPS(SISI)_"  "_SISXCMD(SISI)
 .S SISIENS=",SIS("_SISI_")"_SISIENS
 .Q
 S SISLOOPS(SISN)=SISLOOPS(SISN)_"  "_SISXCMD
 ; Check syntax
 S SISOK=1 N X
 F SISI=1:1 S X=$G(SISLOOPS(SISI)) Q:'$L(X)  D ^DIM S SISOK=$D(X) Q:'SISOK
 I 'SISOK S SISRSLT="-1^SYNTAX ERROR in generated code" Q
 X SISLOOPS(1)
 Q
 ;
CIENS(SISIENS) ;[Public] - Convert SIS variables to constants in IENS
 ; IENS=[Required] IENS including variables of the form SIS(I)
 ;
 S SISIENS=$G(SISIENS) N SISI,SISX F SISI=1:1:$L(SISIENS,",") D
 .S SISX=$P(SISIENS,",",SISI)
 .S:SISX?1"SIS("1.N1")" @("SISX="_SISX),$P(SISIENS,",",SISI)=SISX
 .Q
 Q SISIENS
 ;
ERR ;[Private] Error handler
 S (SISRSLT(0),SISRSLT(1+$O(SISRSLT(" "),-1)))="-1^"_$ZE_"^["_$G(SISNMSP)_"]"
 Q
FMLIST(SIS) ;[Platform-specific] - Return list of Cache namespaces
 ; that include the Fileman data dictionary global and routine %ZOSV.
 ;
 ; SIS=Result [by reference]
 ; 
 I $$VERSION^%ZOSV(1)?1"Cache".E N I,X
 E  Q
 S I=0,X=""
 F  S X=$O(^|"%SYS"|SYS("CONFIG","CACHE","Namespaces",X)) Q:X=""  D
 .Q:'$D(^|X|DD)!'$D(^|X|ROUTINE("%ZOSV"))  S I=I+1,SIS(I)=X,SIS("B",X)=I
 .Q
 Q
DATA ;;List of namespaces to search - Deprecated 9/18/2012
 ;;
