VFDATA ;DSS/LM - Data Table Utilities ;January 15, 2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
IMPORT(VFDRSLT,VFDFLDS,VFDFLGS) ;[Public] Import data from host file to VFD TABLE entry
 ; VFDFLDS=[Required] Array of File 21611 fields and values by reference
 ; 
 ;     (1)=.01^ENTRY NAME
 ;     (2)=.02^VERSION
 ;     Etc.
 ;     
 ;     Only subscript (1) is required.  All others are optional.
 ;     If the entry does not exist it will be created.
 ;     Otherwise, an existing entry will be edited, replacing
 ;     existing field values with new non-null values.
 ;     To leave a field unchanged, omit it from the array.
 ;     To delete a field value, set the value to null or "@".
 ;
 ; VFDFLGS=[Optional] UPDATE^DIE Flags ^ IMPORT flags
 ;     First "^"-piece will be passed through to UPDATE^DIE, for example,
 ;     "E" means "external format" data.
 ;     Second "^"-piece indicated IMPORT options, for example,
 ;     "U" means update file entry only and do not import data.
 ;     "D" means delete row headers, column headers and row x column data
 ;         when updating.  Note that data are always deleted prior to
 ;         importing from a file.
 ; 
 ; VFDRSLT=IEN of File 21611 entry or "-1^Error message"
 ; 
 N VFDIEN D UPDATE(.VFDIEN,.VFDFLDS,$P($G(VFDFLGS),U))
 I VFDIEN<0 S VFDRSLT=VFDIEN Q  ;Error in update
 ; Update complete - Check 'Delete' flag
 D:$P($G(VFDFLGS),U,2)["D" DELETE(VFDIEN) ;Delete data
 I ($P($G(VFDFLGS),U,2)["U") S VFDRSLT=VFDIEN Q  ;Update only
 ; Continue import
 N VFDATA D GETS^DIQ(21611,VFDIEN,"*","I",$NA(VFDATA))
 N VFDR S VFDR=$NA(VFDATA(21611,VFDIEN_","))
 I '$L(@VFDR@(.01,"I")) D  Q
 .S VFDRSLT="-1^VFD TABLE entry retrieval failed"
 .Q
 ; Sanity checks
 I $G(@VFDR@(.03,"I"))]"",@VFDR@(.03,"I")>$$DT^XLFDT D  Q
 .S VFDRSLT="-1^VFD TABLE entry has a future EFFECTIVE DATE"
 .Q
 I $G(@VFDR@(.04,"I"))]"",@VFDR@(.04,"I")<$$DT^XLFDT D  Q
 .S VFDRSLT="-1^VFD TABLE entry has expired"
 .Q
 I '$L(@VFDR@(.06,"I")) D  Q
 .S VFDRSLT="-1^Missing DELIMITER specification"
 .Q
 I '$L(@VFDR@(5,"I")) D  Q
 .S VFDRSLT="-1^Missing Host File specification"
 .Q
 ; End sanity checks
 ; Parse file specification
 N VFDFILE,VFDLEN,VFDPATH,VFDPDLM S VFDPDLM=$S($$OS^%ZOSV="NT":"\",1:"/")
 S VFDLEN=$L(@VFDR@(5,"I"),VFDPDLM)
 S VFDPATH=$P(@VFDR@(5,"I"),VFDPDLM,1,VFDLEN-1)
 S VFDFILE=$P(@VFDR@(5,"I"),VFDPDLM,VFDLEN)
 ; Copy file to global
 N VFD S VFD=$NA(^TMP("VFDATA",$J,@VFDR@(.01,"I"))) K @VFD
 I $$FTG^%ZISH(VFDPATH,VFDFILE,$NA(@VFD@(1)),4)
 E  S VFDRSLT="-1^File to global transfer failed. Verify HOST FILE." Q
 ; Delete previous data for entry
 D DELETE(VFDIEN) ;Required when importing data
 ; Prepare to file data
 N VFDCOL,VFDLIM,VFDROW S (VFDROW,VFDCOL)=0
 S VFDLIM=@VFDR@(.06,"I") S:VFDLIM?1"$C(".E @("VFDLIM="_VFDLIM)
 N VFDERR,VFDFDA,VFDI,VFDIENR,VFDMSG,VFDRR,VFDX,VFDXFRM,X
 S VFDXFRM=@VFDR@(6,"I") ;Data cell transform
 ; Process column headers
 S VFDERR=0 D:@VFDR@(.07,"I")
 .S VFDROW=VFDROW+1 I '$D(@VFD@(VFDROW)) D  Q
 ..S VFDRSLT="-1^No data found",VFDERR=1
 ..Q
 .S VFDX=@VFD@(VFDROW)
 .F VFDI=1:1:$L(VFDX,VFDLIM) D  Q:VFDERR
 ..S VFDRR=$NA(VFDFDA(21611.03,"?+"_VFDI_","_VFDIEN_","))
 ..S @VFDRR@(.01)=VFDI,@VFDRR@(.02)=$P(VFDX,VFDLIM,VFDI)
 ..S VFDIENR(VFDI)=VFDI
 ..D UPDATE^DIE(,$NA(VFDFDA),$NA(VFDIENR),$NA(VFDMSG))
 ..D:$D(DIERR) 
 ...S VFDERR=1
 ...S VFDRSLT="-1^UPDATE~DIE returned an error^"_$G(VFDMSG("DIERR",1,"TEXT",1))
 ...Q
 ..Q
 .Q
 ; Process data including row headers
 S VFDEOD=0 F  D  Q:VFDERR!VFDEOD
 .S VFDROW=VFDROW+1 I '$D(@VFD@(VFDROW)) S VFDEOD=1 Q  ;End of data
 .S VFDCOL=0,VFDX=@VFD@(VFDROW)
 .D:@VFDR@(.08,"I")  Q:VFDERR  ;Has row header
 ..S VFDCOL=1
 ..S VFDRR=$NA(VFDFDA(21611.02,"?+"_VFDROW_","_VFDIEN_","))
 ..S @VFDRR@(.01)=VFDROW,@VFDRR@(.02)=$P(VFDX,VFDLIM,VFDCOL)
 ..S VFDIENR(VFDROW)=VFDROW
 ..D UPDATE^DIE(,$NA(VFDFDA),$NA(VFDIENR),$NA(VFDMSG))
 ..D:$D(DIERR) 
 ...S VFDERR=1
 ...S VFDRSLT="-1^UPDATE~DIE returned an error^"_$G(VFDMSG("DIERR",1,"TEXT",1))
 ...Q
 ..Q  ;End row header
 .F VFDI=VFDCOL+1:1:$L(VFDX,VFDLIM) D  Q:VFDERR  ;Data
 ..S VFDRR=$NA(VFDFDA(21611.04,"+1,"_VFDIEN_",")) ;Always create new cell
 ..S @VFDRR@(.01)=VFDROW,@VFDRR@(.02)=VFDI
 ..S (@VFDRR@(.03),X)=$P(VFDX,VFDLIM,VFDI)
 ..I $L(VFDXFRM) X VFDXFRM S @VFDRR@(.03)=X ;Transform
 ..D UPDATE^DIE(,$NA(VFDFDA),,$NA(VFDMSG))
 ..D:$D(DIERR) 
 ...S VFDERR=1
 ...S VFDRSLT="-1^UPDATE~DIE returned an error^"_$G(VFDMSG("DIERR",1,"TEXT",1))
 ...Q
 ..Q
 .Q
 ; Cleanup and exit
 K @VFD S:'VFDERR VFDRSLT=VFDIEN
 Q
LOOKUP(VFDRSLT,VFDVAL) ;[Public] Lookup File 21611 and return array of matches
 ; VFDVAL=[Required] Lookup value
 ; 
 ; VFDRSLT=Array, subscripted (1), (2), etc. of matches to VFDVAL
 ;         IEN^.01^.02^.03^.04 =or= "-1^Error message"
 ; 
 I $L($G(VFDVAL)) N VFDTRGT,VFDMSG
 E  S VFDRSLT(1)="-1^Missing or invalid lookup value" Q
 D FIND^DIC(21611,,"@;.01;.02;.03;.04",,VFDVAL,,,,,$NA(VFDTRGT),$NA(VFDMSG))
 I $D(DIERR) S VFDRSLT(1)="-1^FIND~DIC returned an error^"_$G(VFDMSG("DIERR",1,"TEXT",1)) Q
 I '($G(VFDTRGT("DILIST",0))>0) S VFDRSLT(1)="-1^No matches found for '"_VFDVAL_"'" Q
 N VFDI,VFDJ,VFDR S VFDR=$NA(VFDTRGT("DILIST","ID"))
 F VFDI=1:1 Q:'$D(VFDTRGT("DILIST",2,VFDI))  D
 .S VFDRSLT(VFDI)=VFDTRGT("DILIST",2,VFDI) F VFDJ=.01:.01:.04 D
 ..S VFDRSLT(VFDI)=VFDRSLT(VFDI)_U_$G(VFDTRGT("DILIST","ID",VFDI,VFDJ))
 ..Q
 .Q
 Q
GET(VFDRSLT,VFDINPUT) ;[Public] Retrieve data from File 21611 entry
 ; VFDINPUT=[Required] Specification array
 ; 
 ;   Subscript n=1,2,3,... = TAG^VALUE, where TAG is one of the following:
 ;   
 ;     VAL  - [Required] - lookup value or `ien (backquote IEN)
 ;             Lookup value must resolve to exactly one entry
 ;             after optionally qualification by DATE and or VER
 ;     DATE - [Optional] - FM date format - default to DT
 ;     VER  - [Optional] - version number
 ;     ROW  - [Optional] - single number, if null return all rows
 ;     COL  - [Optional] - single number, if null return all columns
 ;
 ; VFDRSLT=Results array (local)
 ; 
 I '$D(VFDINPUT(1)) S VFDRSLT(1)="-1^Missing or invalid INPUT array" Q
 ; Parse input
 N VFDI,VFDX,VFDXIN F VFDI=1:1 Q:'$L($G(VFDINPUT(VFDI)))  D
 .S VFDX=VFDINPUT(VFDI) Q:'$L($P(VFDX,U))
 .S VFDXIN($P(VFDX,U))=$P(VFDX,U,2)
 .Q
 F VFDX="VAL","DATE","VER","ROW","COL" N @("VFD"_VFDX) D
 .S @("VFD"_VFDX_"="_""""_$G(VFDXIN(VFDX))_"""")
 .Q
 I '$L(VFDVAL) S VFDRSLT(1)="-1^INPUT array is missing required VAL tag)" Q
 ; Define screen
 N VFDSCR,VFDSCR1,VFDSCR2
 I $L(VFDVER) S VFDSCR1="I $P(^(0),U,2)=VFDVER"
 I $L(VFDDATE) S VFDSCR2="I '$P(^(0),U,3)!'(VFDDATE<$P(^(0),U,3))&('$P(^(0),U,4)!'(VFDDATE>$P(^(0),U,4)))"
 I $D(VFDSCR1),$D(VFDSCR2) S VFDSCR=VFDSCR1_" "_VFDSCR2
 E  I $D(VFDSCR1) S VFDSCR=VFDSCR1
 E  I $D(VFDSCR2) S VFDSCR=VFDSCR2
 ; Lookup entry
 N VFDTRGT,VFDMSG
 D FIND^DIC(21611,,"@;",,VFDVAL,,,.VFDSCR,,$NA(VFDTRGT),$NA(VFDMSG))
 I $D(DIERR) S VFDRSLT(1)="-1^FIND~DIC returned an error^"_$G(VFDMSG("DIERR",1,"TEXT",1)) Q
 I '($G(VFDTRGT("DILIST",0))>0) S VFDRSLT(1)="-1^No match found for specified input" Q
 I $G(VFDTRGT("DILIST",0))>1 S VFDRSLT(1)="-1^Input specification satisfies more than one entry" Q
 ; Process GET
 N VFDIEN S VFDIEN=$G(VFDTRGT("DILIST",2,1))
 I 'VFDIEN S VFDRSLT(1)="-1^Failed to identify requested entry" Q
 ; Data rows are *not* DINUM'ed (see specification)
 N VFDI,VFDJ,VFDK,VFDRBEG,VFDREND,VFDDIEN,VFDCBEG,VFDCEND,VFDERR
 S (VFDK,VFDERR)=0
 S VFDRBEG=$S(VFDROW:VFDROW,1:$O(^VFDV(21611,VFDIEN,4,"B",""))),VFDREND=$S(VFDROW:VFDROW,1:999999999999)
 S VFDCBEG=$S(VFDCOL:VFDCOL,1:$O(^VFDV(21611,VFDIEN,4,"C",VFDRBEG,""))),VFDCEND=$S(VFDCOL:VFDCOL,1:999999999999)
 F VFDI=VFDRBEG:1:VFDREND Q:'$D(^VFDV(21611,VFDIEN,4,"C",VFDI))!VFDERR  D
 .F VFDJ=VFDCBEG:1:VFDCEND Q:'$D(^VFDV(21611,VFDIEN,4,"C",VFDI,VFDJ))!VFDERR  D
 ..S VFDDIEN=$O(^VFDV(21611,VFDIEN,4,"C",VFDI,VFDJ,""))
 ..I 'VFDDIEN!'($D(^VFDV(21611,VFDIEN,4,VFDDIEN,0))#2) D  Q
 ...S VFDERR="-1^Corrupt cross-reference in DATA multiple"
 ...Q
 ..I $O(^VFDV(21611,VFDIEN,4,"C",VFDI,VFDJ,VFDDIEN)) D  Q
 ...S VFDERR="-1^Ambiguous ROW in DATA multiple"
 ...Q
 ..S VFDK=VFDK+1,VFDRSLT(VFDK)=^VFDV(21611,VFDIEN,4,VFDDIEN,0)
 ..Q
 .Q
 I VFDERR K VFDRSLT S VFDRSLT(1)=VFDERR
 S:'$D(VFDRSLT(1)) VFDRSLT(1)="-1^Requested data not found"
 Q
UPDATE(VFDRSLT,VFDFLDS,VFDFLGS) ;[Private] Update or create File 21611 entry
 ; Wraps UPDATE^DIE
 ; 
 ; VFDFLDS=[Required] Array of File 21611 fields and values by reference
 ; 
 ;     (1)=.01^ENTRY NAME
 ;     (2)=.02^VERSION
 ;     Etc.
 ;     
 ;     Only subscript (1) is required.  All others are optional.
 ;     If the entry does not exist it will be created.
 ;     Otherwise, an existing entry will be edited, replacing
 ;     existing field values with new non-null values.
 ;     To leave a field unchanged, omit it from the array.
 ;     To delete a field value, set the value to null or "@".
 ;
 ; VFDFLGS=[Optional] UPDATE^DIE Flags
 ; 
 ; VFDRSLT=IEN of File 21611 entry or "-1^Error message"
 ; 
 N VFDI,VFDIENR,VFDFDA,VFDMSG,VFDR S VFDR=$NA(VFDFDA(21611,"?+1,"))
 F VFDI=1:1 Q:'$G(VFDFLDS(VFDI))  D
 .S @VFDR@(+VFDFLDS(VFDI))=$P(VFDFLDS(VFDI),U,2)
 .Q
 I '$D(VFDFDA) S VFDRSLT="-1^Missing or invalid fields array" Q
 D UPDATE^DIE(.VFDFLGS,$NA(VFDFDA),$NA(VFDIENR),$NA(VFDMSG))
 I $G(VFDIENR(1))>0 S VFDRSLT=VFDIENR(1) Q
 I $D(DIERR) S VFDRSLT="-1^UPDATE~DIE returned an error^"_$G(VFDMSG("DIERR",1,"TEXT",1)) Q
 S VFDRSLT="-1^UPDATE Failed."
 Q
DELETE(VFDIEN) ;[Private] Delete ROW HEADER, COLUMN HEADER, and DATA multiples
 ; VFDIEN=[Required] File 21611 internal entry number
 ; 
 ; No return
 ; 
 Q:'($G(VFDIEN)?1.N)  N DA,DIK,VFDI S DA(1)=VFDIEN
 F VFDI=2,3,4 S DIK="^VFDV(21611,"_VFDIEN_","_VFDI_"," D
 .S DA=0 F  S DA=$O(@(DIK_DA_")")) Q:'DA  D ^DIK
 .Q
 Q
