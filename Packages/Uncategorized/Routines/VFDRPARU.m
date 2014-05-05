VFDRPARU ;DSS/WLC - ARRA STANDARD REPORTING UTILIITIES ; 05/25/2011 14:40
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
SUB  ; submission generation
 W "<submission xmlns:xsi=""http://www3.org/2001/XMLSchema-instance"" xsi:noNamespacesSchemaLocation=""Registry_Payment.xsd"" type=""PQRI-REGISTRY"" option=""TEST"" Version=""1.0"">",!
 Q
 ;
FILEA  ; file-audit record
 W " <file-audit-data>",!
 Q
 ;
EFILEA  ; end file-audit record
 W " </file-audit-data>",!
 Q
 ;
CRDATE  ; create-date generation
 N X S X=$P(DATTIME,".",1)
 W "  <create-date>"_$TR($$FMTE^XLFDT(X,"6Z"),"/","-")_"</create-date>",!
 Q
 ;
CRTIME  ; create-time generation
 N X S X=$E($P(DATTIME,".",2)_"0000",1,4),X=$E(X,1,2)_":"_$E(X,3,4)
 W "  <create-time>"_X_"</create-time>",!
 Q
 ;
CRBY  ; create-by generation
 W "  <create-by>VxVISTA.org</create-by>",!
 Q
 ;
VERS  ; version generation
 W "  <version>1.0</version>",!
 Q
 ;
FILN  ; file-number generation
 W "  <file-number>",FILEN,"</file-number>",!
 Q
 ;
NUMFL  ; number-of-files generation
 W "  <number-of-files>",TOTFLE,"</number-of-files>",!
 Q
 ;
REG  ; registry generation
 W " <registry>",!
 W "  <registry-name>VxVista.org</registry-name>",!
 W "  <registry-id>123456</registry-id>",!
 W "  <submission-method>B</submission-method>",!
 W " </registry>",!
 Q
 ;
MGI(DATA,PROV)  ; measure-group-id generation
 W " <measure-group ID=""X"">",!
 Q
 ;
MGP(DATA,IEN)  ; measure-group provider generation
 D PRV(IEN)
 D ENC(VFDFR,VFDTO)
 D PQRI(.DATA,IEN)
 Q
 ;
END  ; end tags
 W "</submission>",!
 Q
 ;
PRV(IEN)  ; provider generation
 N NPI,TIN,X
 I IEN=2956 D IPRV(IEN) Q  ;Inpatient reporting
 S X=$$NPI^XUSNPI("Individual_ID",IEN)
 I $P(X,U,1)'<0 S NPI=$P(X,U,1),TIN=$$GET1^DIQ(200,IEN_",",53.92),RELEASE=$S($$GETRLNPI^XUSNPI(IEN)=1:"Y",1:"N")
 ;S X=$$NPI^XUSNPI("Organization_ID",IEN),NPI=$P(X,U,1),TIN=$$GET1^DIQ(200,IEN_",",53.92),RELEASE=$S($$GETRLNPI^XUSNPI(IEN)=1:"Y",1:"N")
 W "  <provider>",!
 W "   <npi>",NPI,"</npi>",!
 W "   <tin>",TIN,"</tin>",!
 W "   <waiver-signed>",RELEASE,"</waiver-signed>",!
 Q
 ;
IPRV(IEN)  ; provider generation
 S X=$$NPI^XUSNPI("Organization_ID",IEN),NPI=$P(X,U,1),TIN="12-7564837",RELEASE="Y"
 W "  <provider>",!
 W "   <npi>",NPI,"</npi>",!
 W "   <tin>",TIN,"</tin>",!
 W "   <waiver-signed>",RELEASE,"</waiver-signed>",!
 Q
 ;
ENC(VFDFR,VFDTO)  ; encouter date geneation
 W "   <encounter-from-date>",($E(VFDFR,1,3)+1700),"-",$E(VFDFR,4,5),"-",$E(VFDFR,6,7),"T00:00:00","</encounter-from-date>",!
 W "   <encounter-to-date>",($E(VFDTO,1,3)+1700),"-",$E(VFDTO,4,5),"-",$E(VFDTO,6,7),"T00:00:00","</encounter-to-date>",!
 Q
 ;
PQRI(DATA,IEN)  ; pqri-measure generation
 I IEN=2956 S DATA=$NA(^TMP(REPORT,$J,FILEN))
 W "   <pqri-measure>",!
 W "    <pqri-measure-number>",@DATA@("PQRI"),"</pqri-measure-number>",!
 W "    <collection-method>","A","</collection-method>",!
 W "    <eligible-instances>",@DATA@("ELIG"),"</eligible-instances>",!
 W "    <meets-performance-instances>",@DATA@("MEETS"),"</meets-performance-instances>",!
 W "    <performance-exclusion-instances>",$G(@DATA@("EXCL"),0),"</performance-exclusion-instances>",!
 W "    <performance-not-met-instances>",$G(@DATA@("NOTMET"),0),"</performance-not-met-instances>",!
 ;W "    <reporting-rate>",@DATA@("RPRATE"),"</reporting-rate>",!
 W "    <performance-rate",$S(@DATA@("PERATE")'=0:">"_@DATA@("PERATE")_"</performance-rate>",1:" xsi:nil=""true""/>"),!
 W "   </pqri-measure>",!
 W "  </provider>",!
 I IEN=2956 S DATA=$NA(^TMP(REPORT,$J))
 Q
MGPEND  ;
 W " </measure-group>",!
 Q
 ;
FIX  ; module to correct check-in dates inside HOSPITAL LOCATION (#44) file.
 N X,Y,APDT,CLIN
 S CLIN=0 F  S CLIN=$O(^SC(CLIN)) Q:'CLIN  D
 . W !,CLIN S APDT=0 F  S APDT=$O(^SC(CLIN,"S",APDT)) Q:'APDT  D
 . . I $D(^SC(CLIN,"S",APDT,1,1,"C")) S X=$P(^SC(CLIN,"S",APDT,1,1,"C"),U,4),$P(^SC(CLIN,"S",APDT,1,1,"C"),U,1)=APDT,$P(^SC(CLIN,"S",APDT,1,1,"C"),U,2)=$S(X:X,1:75)
 Q
 ;
EXTRACT(VFDR,VFDSDT,VFDEDT,VFDPATH)  ; RPC:  VFD ARRA EXTRACT RUN
 ; This RPC will run all of the extracts needed by the SQL application
 ; to generate each, or all, of the ARRA Inpatient reports.  Each of
 ; the below calls have been defined in separate convenience builds.
 ; INPUT:
 ;    VFDSDT - Start Date for extracts
 ;    VFDEDT - End Date for Extracts
 ;   VFDPATH - Path Name for Extract files.
 ; OUTPUT:  VFDR = 1^Success  or  -1^Error Text
 ;
 N X,Y,Z,VFD,VFDNSDT,VFDMSG
 I $G(VFDPATH)="" S VFDPATH=$$DEFDIR^%ZISH("")
 ; adjust start date for Lab and Med extracts
 S VFDNSDT=$$FMADD^XLFDT(VFDSDT,-30)
 ; get patient admin/disch movements
 D GETPT^VFDRPARB(.VFD,VFDSDT,VFDEDT,"PT_ADMT.CSV",VFDPATH)
 S X="PAT_MOVE" I +VFD=-1 S VFDMSG(0,X)=$P(VFD,U,2)
 E  S VFDSMG(1,X)=""
 ; get list of lab values
 K VFD D LABLST^VFDRPARI(.VFD,VFDNSDT,VFDEDT,"PT_LAB.CSV",VFDPATH)
 S X="LAB_LIST" I VFD<1 S VFDMSG(0,X)=$P(VFD,U,2)
 E  S VFDMSG(1,X)=""
 ; get list of medications
 K VFD D DUMP^VFDORDP(.VFD,VFDNSDT,VFDEDT,"PT_MEDS.CSV",VFDPATH)
 S X="MEDS LIST" I $D(VFD(0)) S VFDMSG(0,X)=$P(VFD(0),U,2)
 E  S VFDMSG(1,X)=""
 ; get list of health factors
 K VFD D HFLST^VFDRPARI(.VFD,VFDSDT,VFDEDT,"PT_HFACTOR.CSV",VFDPATH)
 S X="HF LIST" I +VFD<1 S VFDMSG(0,X)=$P(VFD,U,2)
 E  S VFDMSG(1,X)=""
 ; get list of snomed codes
 K VFD D SNOLST^VFDRPARI(.VFD,VFDSDT,VFDEDT,"PT_SNOMED.CSV",VFDPATH)
 S X="SNOMED LIST" I +VFD<0 S VFDMSG(0,X)=$P(VFD,U,2)
 E  S VFDMSG(1,X)=""
 ; get list of diagnoses
 K VFD D EN1^VFDRPARQ(.VFD,VFDSDT,VFDEDT,"PT_VPOV.CSV",VFDPATH)
 S X="POV",VFDMSG(1,X)=""
 K @VFD
 ; get list of all transfer to ward movements
 K VFD D GETPT^VFDRPARD(.VFD,VFDSDT,VFDEDT,"PT_TRANS.CSV",VFDPATH)
 S X="PAT_TRANSFER" I VFD<1 S VFDMSG(0,X)=$P(VFD,U,2)
 E  S VFDMSG(1,X)=""
 ;
 I '$D(VFDMSG(0)) S VFDR="1^Success" Q
 I '$D(VFDMSG(1)) S VFDR="-1^None of the extracts generated files" Q
 S Y="These extracts successfully created files: ",X=""
 F  S X=$O(VFDMSG(1,X)) Q:X=""  S Y=Y_X_", "
 S Y=$E(Y,1,$L(Y)-2)_".  These extracts had problems: "
 F  S X=$O(VFDMSG(0,X)) Q:X=""  S Y=Y_"["_X_" - "_VFDMSG(0,X)_"], "
 S VFDR=$E(Y,1,$L(Y)-2)
 Q
 ;
DATE(SD,ED) ; strip of times, check for proper dates
 N X,Y,Z
 S SD=$G(SD)\1,ED=$G(ED)\1
 I 'SD Q "-1^No start date received"
 S SD=SD-.1 S:'ED ED=DT S ED=ED_".24"
 I ED<SD Q "-1^Ending date is prior to starting date"
 Q SD_U_ED
