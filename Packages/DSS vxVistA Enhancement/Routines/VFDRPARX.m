VFDRPARX ;DSS/WLC - ARRA XML GENERATOR ; 05/21/2011 19:14
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q  ; call by line tag only
 ;
 ;  This RPC is expecting an array passed in populated with the data necessary for ARRA reporting.
 ;  The data should be in the format as outlined in the INPUT description.  This routine will produce
 ;  a standard XML document in the format as outlined in the "PQRI 2010 Registry XML Specifications"
 ;  document.
 ;
 ;  INPUT:
 ;   REPORT = Report Routine Name
 ;   VFDFR  = Report Starting date
 ;   VFDTO  = Report End Date
 ;   VFDAR array where:
 ;     VFDAR(Report Routine name, $J, File number, Provider IEN, "PQRI")=PQRI measure number (i.e.:  NQF 0435)
 ;     VFDAR(Report Routine name, $J, File number, Provider IEN, "EXCL")=Number of performance exclusions for the PQRI measure group
 ;     VFDAR(Report Routine name, $J, File number, Provider IEN, "ELIG")=number of instances (denominator)
 ;     VFDAR(Report Routine name, $J, File number, Provider IEN, "MEETS")=number of instances of quality service performed. (numerator)
 ;     VFDAR(Report Routine name, $J, File number, Provider IEN, "NOTMET")=Number of instances not meeting the performance criteria,
 ;                                                                         even though reporting occurred.
 ;
 ;     following elements are calculated from file values above:
 ; 
 ;     VFDAR(Report Routine name, $J, File number, Provider IEN, "RPRATE")=reporting rate (RATE + EXCL + NOTMET / ELIG)
 ;     VFDAR(Report Routine name, $J, File number, Provider IEN, "PERATE")=Performance rate (MEETS / ELIG)
 ;
 ;   OUTPUT:
 ;     VFDRET = -1^Error Text or
 ;               1^Success     
 ;    
XML(VFDRET,REPORT,VFDFR,VFDTO,VFDAR)  ; RPC:  VFD ARRA XML GENERATOR
 N DTFLE,FILEN,TFLE,TOTFLE,VFDFLE,VFDPRV,VFDFILE,X
 S REPORT=$G(REPORT) I REPORT']"" S VFDRET="-1^Invalid Report Name." Q
 I '$D(@VFDAR) S VFDRET="-1^No Data Array sent." Q
 S FILEN=0 F  S FILEN=$O(@VFDAR@(FILEN)) Q:'FILEN  D  Q:$D(VFDRET)
 . N VFDXR I $$FILENAME S VFDRET=VFDXR Q
 . D SUB^VFDRPARU  ; generate submission record
 . D FILEA^VFDRPARU  ; generate File Audit record
 . D CRDATE^VFDRPARU  ; create-date record
 . D CRTIME^VFDRPARU  ; create-time record
 . D CRBY^VFDRPARU  ; create-by record
 . D VERS^VFDRPARU  ; Version record
 . D FILN^VFDRPARU  ; file-number record
 . S TFLE=0 F  S TFLE=$O(@VFDAR@(TFLE)) Q:'TFLE  S TOTFLE=TFLE
 . D NUMFL^VFDRPARU  ; number-of-files record
 . D EFILEA^VFDRPARU  ; end file-audit-data record
 . D REG^VFDRPARU  ; registry section
 . D MGI^VFDRPARU  ; measure-group record
 . S PROV=0 F  S PROV=$O(@VFDAR@(FILEN,PROV)) Q:'PROV  D
 . . S @VFDAR@(FILEN,PROV,"RPRATE")=$G(@VFDAR@(FILEN,PROV,"MEETS"))+$G(@VFDAR@(FILEN,PROV,"NOTMET"))+$G(@VFDAR@(FILEN,PROV,"EXCL"))/($G(@VFDAR@(FILEN,PROV,"ELIG")))
 . . S @VFDAR@(FILEN,PROV,"PERATE")=$G(@VFDAR@(FILEN,PROV,"MEETS"))/($G(@VFDAR@(FILEN,PROV,"MEETS"))-$G(@VFDAR@(FILEN,PROV,"EXCL")))
 . . N LOP F LOP="RPRATE","PERATE" S @VFDAR@(FILEN,PROV,LOP)=$FN(@VFDAR@(FILEN,PROV,LOP)*100,"",2)
 . . D MGP^VFDRPARU(.VFDAR,PROV)  ; measure-group provider record
 . D MGPEND^VFDRPARU  ; measure-group end record
 . D END^VFDRPARU
 . D CLOSE^%ZISH
 S VFDRET="1^Success"
 Q
 ;
IXML(VFDXR,REPORT,VFDFR,VFDTO,VFDAR)  ; RPC:  VFD ARRA XML GENERATOR
 N X,Y,Z,FILEN,TFLE,TOTFLE,VFDFLE,VFDPRV
 S REPORT=$G(REPORT) I REPORT="" S VFDXR="-1^Invalid Report Name." Q
 S X="-1^No Data Array Received"
 I $G(VFDAR)="" S VFDXR=X Q
 I '$D(@VFDAR) S VFDXR=X Q
 S FILEN=0 F  S FILEN=$O(@VFDAR@(FILEN)) Q:'FILEN  D  Q:$D(VFDXR)
 . Q:$$FILENAME
 . D SUB^VFDRPARU ;    generate submission record
 . D FILEA^VFDRPARU ;  generate File Audit record
 . D CRDATE^VFDRPARU ; create-date record
 . D CRTIME^VFDRPARU ; create-time record
 . D CRBY^VFDRPARU ;   create-by record
 . D VERS^VFDRPARU ;   Version record
 . D FILN^VFDRPARU ;   file-number record
 . S TFLE=0 F  S TFLE=$O(@VFDAR@(TFLE)) Q:'TFLE  S TOTFLE=TFLE
 . D NUMFL^VFDRPARU  ; number-of-files record
 . D EFILEA^VFDRPARU ; end file-audit-data record
 . D REG^VFDRPARU ;    registry section
 . D MGI^VFDRPARU ;    measure-group record
 . I +($G(@VFDAR@(FILEN,"MEETS"))) D
 . . S @VFDAR@(FILEN,"RPRATE")=$G(@VFDAR@(FILEN,"MEETS"))+$G(@VFDAR@(FILEN,"NOTMET"))+$G(@VFDAR@(FILEN,"EXCL"))/($G(@VFDAR@(FILEN,"ELIG")))
 . . S @VFDAR@(FILEN,"PERATE")=$G(@VFDAR@(FILEN,"MEETS"))/(($G(@VFDAR@(FILEN,"ELIG"))-$G(@VFDAR@(FILEN,"EXCL")))*(@VFDAR@(FILEN,"RPRATE")))
 . . N LOP F LOP="RPRATE","PERATE" S @VFDAR@(FILEN,LOP)=$FN(@VFDAR@(FILEN,LOP)*100,"",2)
 . E  S @VFDAR@(FILEN,"PERATE")="100.00"
 . D MGP^VFDRPARU(.VFDAR,2956)  ; measure-group provider record
 . D MGPEND^VFDRPARU ; measure-group end record
 . D END^VFDRPARU
 . D CLOSE^%ZISH
 S VFDXR="1^Success"
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
FILENAME() ; return a filename
 N X,Y,Z,FILE,IOP,POP
 S DATTIME=$$NOW^XLFDT,X=$P(DATTIME,".",1)
 S Y="-"_$E($P(DATTIME,".",2)_"0000",1,4)
 S Z=" "_$TR($$FMTE^XLFDT(X,"7Z"),"/","-")_Y_"("_FILEN_")"
 S IOP=$TR(@VFDAR@(FILEN,"PQRI")," ","")_Z_".XML"
 D OPEN^%ZISH(,"C:\HFS",IOP,"W") I 'POP U IO
 E  S VFDXR="-1^Unable to open HFS file."
 Q POP
