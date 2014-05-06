VFDRPARC ;DSS\MBS - CPOE Utilities; APR 18, 2011 ; 5/3/11 10:51am
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;Entry points for APIs:
 ; 170.302 (n) CPOE Report - CPOEIN
 ; l70.302 (n) Lab Report - ILTR
 Q
EN ; CPOE Menu Option Entry
 N STDT,EDT,DATA
 D GETDATE K DIR Q:$D(DIRUT)
 S DATA=$$CNTCPOE(STDT,EDT)
 D OUTFILE($P(DATA,U),$P(DATA,U,2),"ArraCPOERpt.csv")
 W !,"Numerator:   "_$P(DATA,U)
 W !,"Denominator: "_$P(DATA,U,2)
 W !,"Ratio:       "_($P(DATA,U)/$P(DATA,U,2))
 Q
ILTREN ; Incorporate lab test results Menu Option Entry
 N STDT,EDT,DATA
 D GETDATE K DIR Q:$D(DIRUT)
 D ILTR(STDT,EDT)
 S DATA=$NA(^TMP("VFDRPARC",$J,"LABTOTALS"))
 W !,"Numerator:   "_$G(@DATA@("MEETS"))
 W !,"Denominator: "_$G(@DATA@("ELIG"))
 W !,"Ratio:       "_($G(@DATA@("MEETS"))/$G(@DATA@("ELIG")))
 Q
 ;
GETDATE ;Prompt for start and end dates
 S DIR(0)="DO^:DT:AE",DIR("A")="Enter starting date",DIR("?")="Enter date to begin searching from" D ^DIR Q:$D(DIRUT)  S STDT=Y
 S DIR(0)="DOA^"_STDT_":DT:AE",DIR("A")="Enter ending date: ",DIR("?")="Enter date to stop searching.  Must be between "_$$FMTE^XLFDT(STDT,2)_" and "_$$FMTE^XLFDT(DT,2) D ^DIR Q:$D(DIRUT)
 ;S EDT=Y_.24,STDT=STDT-.1 ;Set end date to end of day, start date back to include current day
 S EDT=Y
 Q  ;End GETDATE
 ;
CNTCPOE(STDT,EDT) ;Extrinsic function for getting CPOE numerator/denominator data
 ;INPUT:
 ; STDT - Start of date range
 ; EDT - End of date range
 ;OUTPUT:
 ; A string of the format:
 ;  numerator^denominator
 ;
 ; Numerator: patients with a medication order entered using CPOE
 ; Denominator: all unique patients with at least one medication in their medication list
 ; Returns: numerator^denominator
 N VFDDATA,VFDTOTS,ORDT,ORED,ORIEN,VFDPAT,VFDMRN,VFDRET
 S VFDRET=-1
 S ORDT=STDT,ORED=EDT
 S VFDDATA=$NA(^TMP("VFDRPARC",$J,"DATA")),(VFDDENOM,VFDNUMER)=0
 S VFDTOTS=$NA(^TMP("VFDRPARC",$J,"TOTALS"))
 K @VFDDATA,@VFDTOTS
 ;Order through orders in ORDER file by "AF" index
 ;(Couldn't find a good x-ref by patient)
 F  S ORDT=$O(^OR(100,"AF",ORDT)) Q:'ORDT!(ORDT>ORED)  S ORIEN="" F  S ORIEN=$O(^OR(100,"AF",ORDT,ORIEN)) Q:'ORIEN  I $O(^OR(100,"AF",ORDT,ORIEN,0))=1 D
 . ;If OBJECT OF ORDER is not a patient, skip
 . I '($P($P(^OR(100,ORIEN,0),U,2),";",2)["DPT") Q
 . ;If we have already counted this patient as numerator, skip
 . S VFDPAT=$P($P(^OR(100,ORIEN,0),U,2),";")
 . I +$G(@VFDDATA@(VFDPAT,"N")) Q
 . ;If has not been counted as denom and meds in time frame...
 . I '+$G(@VFDDATA@(VFDPAT,"D")),$$HASMEDS(VFDPAT,STDT,EDT) D
 . . ;Count as denominator
 . . S VFDDENOM=VFDDENOM+1
 . . S @VFDDATA@(VFDPAT,"D")=1
 . ;If patient is denom'd and order is CPOE
 . I +$G(@VFDDATA@(VFDPAT,"D")),$$ISCPOE(ORIEN) D
 . . ;Count as numerator
 . . S VFDNUMER=VFDNUMER+1
 . . S @VFDDATA@(VFDPAT,"N")=1
 ;Print patient list to screen
 ;Clean up
 K @VFDDATA,@VFDTOTS
 ;Return data as 'num^denom'
 Q VFDNUMER_U_VFDDENOM
 ;
HASMEDS(DFN,BGN,END) ;Does the patient have meds in the time frame?
 ;Get list of inpatient meds
 N TFN,MVIEW,RET
 S (TFN,MVIEW)=0
 K ^TMP("PS",$J) D OCL^PSJORRE(DFN,BGN,END,.TFN,MVIEW)
 ;Set return to 1 if list exists, 0 if empty
 S RET=$S($D(^TMP("PS",$J)):1,1:0)
 ;Clean up and return
 K ^TMP("PS",$J)
 Q RET
 ;
ISCPOE(ORIEN) ;Is this a CPOE order?
 N RET,SGNDUZ,PRVDUZ,WEDUZ,ORACT0
 ;Default return is 0
 S RET=0
 ;Get the DUZs of the signer and of the provider listed in the first action
 S ORACT0=$G(^OR(100,ORIEN,8,1,0))
 S SGNDUZ=$P(ORACT0,U,5)
 S PRVDUZ=$P(ORACT0,U,3)
 ;Get the DUZ from WHO ENTERED at the top level
 S WEDUZ=$P($G(^OR(100,ORIEN,0)),U,6)
 ;If the provider DUZ matchies the signer DUZ or the WE DUZ, set return to 1
 I (SGNDUZ=PRVDUZ)!(PRVDUZ=WEDUZ) S RET=1
 ;Return
 Q RET
 ;
CPOEOLD(STDT,EDT) ;OLD CODE NOT NEEDED
 ; Numerator: patients with a medication order entered using CPOE
 ; Denominator: all unique patients with at least one medication in their medication list
 N ORDT,ORED,ORPROV,ORTYPE,ORPT,RPTNAMES,VFDPAT,VFDDATA,VFDDENOM,VFDNUMER,VFDTOTS
 S RPTNAMES("OUTPATIENT")="CPOEOUT",RPTNAMES("INPATIENT")="CPOEIN"
 S ORDT=STDT,ORED=EDT,ORPROV="ALL",ORTYPE="P",ORPT="I"
 S VFDDATA=$NA(^TMP("VFDRPARC",$J,"DATA")),(VFDDENOM,VFDNUMER)=0
 S VFDTOTS=$NA(^TMP("VFDRPARC",$J,"TOTALS"))
 K @VFDDATA,@VFDTOTS
 ;Order through orders in ORDER file by "AF" index
 F  S ORDT=$O(^OR(100,"AF",ORDT)) Q:'ORDT!(ORDT>ORED)  S ORIEN="" F  S ORIEN=$O(^OR(100,"AF",ORDT,ORIEN)) Q:'ORIEN  I $O(^OR(100,"AF",ORDT,ORIEN,0))=1 I $D(^OR(100,ORIEN,8,1,0)) D  ;D CHECK^ORPRPM
 . ;If order does not meet requirements, skip
 . I '$$CHECK(ORIEN) Q
 . ;If no data already stored for patient..
 . S VFDPAT=$P($P(^OR(100,ORIEN,0),U,2),";")
 . I '$D(@VFDDATA@(VFDPAT)) D
 . . ;Add to denominator
 . . S VFDDENOM=VFDDENOM+1
 . . ;Add indicator that patient has been denominated
 . . S @VFDDATA@(VFDPAT,"D")=1
 . ;If patient not already numerated...
 . I '$D(@VFDDATA@(VFDPAT,"N")) D
 . . ;If order meets counting requirements...
 . . I $$COUNT(ORIEN) D
 . . . ;Add to numerator
 . . . S VFDNUMER=VFDNUMER+1
 . . . ;Add indicator that patient has been numerated
 . . . S @VFDDATA@(VFDPAT,"N")=1
 ;Compile report data
 S @VFDTOTS@("ELIG")=VFDDENOM
 S @VFDTOTS@("MEETS")=VFDNUMER
 S (@VFDTOTS@("EXCL"),@VFDTOTS@("NOTMET"))=0 ;Don't know what to do with these
 S @VFDTOTS@("PQRI")="X" ;?????
 S @VFDTOTS@("REPRT")=0
 I '(@VFDTOTS@("ELIG")=0) D
 . S @VFDTOTS@("REPRT")=(@VFDTOTS@("MEETS")+@VFDTOTS@("EXCL")+@VFDTOTS@("NOTMET"))/(@VFDTOTS@("ELIG"))
 D OUTFILE(VFDNUMER,VFDDENOM,"ArraCPOERpt.csv")
 K @VFDDATA ;This doesn't need to hang around
 Q
CHECK(ORIEN) ;If order matches requirements then save
 ;COPIED from CHECK^ORPRPM
 N ORPFILE,ORPTST,ORNS,ORACT0,ORORD,ORPVID,ORPVNM
 S ORPFILE=$P($G(^OR(100,ORIEN,0)),"^",2) Q:ORPFILE="" 0 ;Quit if no object of order
 Q:'($P(ORPFILE,";",2)["DPT") 0 ;Quit if order not for a patient
 I $P(ORPFILE,";",2)["DPT" Q:$P($G(^DPT(+$P($G(^OR(100,ORIEN,0)),"^",2),0)),"^",21) 0 ;Quit if test patient
 Q:+$P($G(^OR(100,ORIEN,3)),"^",11)'=0 0 ;190 quit if order type not standard
 S ORPTST=$P($G(^OR(100,ORIEN,0)),"^",12) ;patient status (in/out)
 I ORPT'="B" Q:ORPTST'=ORPT 0 ;Quit if patient status is not 'both' and status doesn't match selected status
 S ORNS=$$NMSP^ORCD($P($G(^OR(100,ORIEN,0)),"^",14))
 I ORTYPE'="A"&(ORNS'="PS") Q 0 ;if not getting all types of orders then quit if order is not from pharmacy
 I ORPTST="O",ORNS="PS",$G(^OR(100,ORIEN,4))=+$G(^OR(100,ORIEN,4)),$L($T(EN^PSOTPCUL)) Q:$$EN^PSOTPCUL($G(^OR(100,ORIEN,4))) 0 ;196 Don't count if outpatient pharm order is a transitional pharmacy benefit order
 S ORACT0=$G(^OR(100,ORIEN,8,1,0)),ORORD=$P(ORACT0,"^",12) ;ORORD holds nature of order ien
 S ORPVID=$P(ORACT0,"^",3) I ORPROV'="ALL" Q:'$D(ORPROV(ORPVID)) 0 ;quit if ordering provider doesn't match user selected provider
 S ORPVNM=$P($G(^VA(200,ORPVID,0)),"^") ;get provider name
 Q:'$D(^XUSEC("ORES",ORPVID)) 0 ;quit if ordering provider doesn't have ORES key DBIA # 10076 allows direct read of XUSEC
 Q:"^1^2^3^5^8^"'[("^"_ORORD_"^") 0 ;quit if NATURE OF ORDER is not verbal, written, telephoned, policy, or electronically entered
 Q 1 ;D COUNT ;Count order
 ;
COUNT(ORIEN) ;This section determines if the order should be counted
 N VFDNAT,VFDEE,VFDEB,VFDPVID
 ;Get IEN for "ELECTRONICALLY ENTERED" nature (to protect against DB cahnges)
 S VFDEE=$$FIND1^DIC(100.02,,"QX","ELECTRONICALLY ENTERED")
 ;If failed to get IEN, quit with false
 I '+VFDEE Q 0
 ;If order not by provider and provider not have ORES key, quit false
 S VFDEB=$$GET1^DIQ(100.008,"1,"_ORIEN_",",13,"I")
 S VFDPVID=$$GET1^DIQ(100.008,"1,"_ORIEN_",",3,"I")
 I '($D(^XUSEC("ORES",VFDEB))&(VFDEB=VFDPVID)) Q 0
 ;If NATURE OF ORDER is not ELECTRONICALLY ENTERED, quit failure
 I '($$GET1^DIQ(100.008,"1,"_ORIEN_",",12,"I")=VFDEE) Q 0
 ;Passed all checks, so quit true to count
 Q 1
 ;
ILTR(VFDSDT,VFDEDT) ; Incorporate lab test results (170.302(n)m9)
 ;INPUT
 ; VFDSDT - Start Date
 ; VDTEDT - End Date
 ;OUTPUT
 ; This API will write the numerator/denominator/ratio to a host file (ArraLabReport.csv) and will also return the data in an ^TMP global in the format:
 ;  ^TMP("VFDRPARC",$J,"LABTOTALS","ELIG") = denominator
 ;  ^TMP("VFDRPARC",$J,"LABTOTALS","MEETS")= numerator
 ;  ^TMP("VFDRPARC",$J,"LABTOTALS","REPRT")= ratio
 ; Other nodes may be present in the return; they are inconsequential.
 ;
 ;Numerator: clinical lab tests with positive/negative or numeric format results incorporated into EHR.
 ;Denominator: all clinical lab tests ordered during the reporting period
 N VFDTOTS S VFDTOTS=$NA(^TMP("VFDRPARC",$J,"LABTOTALS")) K @VFDTOTS
 ;Copied from LR1^VFDSTAT1
 ;
 ; Acquire data
 N VFDA,VFDI,VFDA,VFDJ,VFDDEN,VFDNUM,VFDORD,VFDORF,VFDSPEC,VFDTEST,VFDZ,VFLRDFN,VFLOC
 S (VFDDEN,VFDNUM)=0
 S VFDA=VFDSDT-.1 F  S VFDA=$O(^LRO(69,"B",VFDA)) Q:'VFDA!(VFDA>VFDEDT)  D  ;DATE ORDERED
 .S VFDSPEC=0 F  S VFDSPEC=$O(^LRO(69,VFDA,1,VFDSPEC)) Q:'VFDSPEC  D  ;SPECIMEN
 ..S VFLRDFN=$P($G(^LRO(69,VFDA,1,VFDSPEC,0)),U)
 ..S VFDTEST=0 F  S VFDTEST=$O(^LRO(69,VFDA,1,VFDSPEC,2,VFDTEST)) Q:'VFDTEST  D  ;TEST
 ...;Check for Denominator
 ...S VFDZ=$G(^LRO(69,VFDA,1,VFDSPEC,2,VFDTEST,0))
 ...Q:$P(VFDZ,U,9)="CA"  ;Cancelled
 ...S VFDORD=$P(VFDZ,U,7) Q:'VFDORD  ;OERR INTERNAL FILE #
 ...S VFDORF=$G(^OR(100,VFDORD,4))
 ...S VFDDEN=VFDDEN+1
 ...;Check for Numerator
 ...Q:'($P(VFDORF,";",4)="CH")  ;ORDER : PACKAGE REFERENCE
 ...S VFLOC=$$GET1^DIQ(60,$P(VFDZ,U)_",",5,"I") Q:VFLOC=""
 ...Q:('+VFLRDFN)!($P(VFLOC,";")="")!($P(VFLOC,";",2)="")!($P(VFDORF,";",5)="")
 ...I +$G(^LR(VFLRDFN,$P(VFLOC,";"),$P(VFDORF,";",5),$P(VFLOC,";",2))) D
 ....S VFDNUM=VFDNUM+1
 ...Q
 ..Q
 .Q
 ;Compile report data
 S @VFDTOTS@("ELIG")=VFDDEN
 S @VFDTOTS@("MEETS")=VFDNUM
 S (@VFDTOTS@("EXCL"),@VFDTOTS@("NOTMET"))=0 ;Don't know what to do with these
 S @VFDTOTS@("PQRI")="X" ;?????
 S @VFDTOTS@("REPRT")=0
 I '(@VFDTOTS@("ELIG")=0) D
 . S @VFDTOTS@("REPRT")=(@VFDTOTS@("MEETS")+@VFDTOTS@("EXCL")+@VFDTOTS@("NOTMET"))/(@VFDTOTS@("ELIG"))
 D OUTFILE(VFDNUM,VFDDEN,"ArraLabRpt.csv")
 Q
OUTFILE(VFDNUMER,VFDDENOM,FILEN) ;Outputs the numerator and denominator to a host file
 N VFDRAT
 S VFDRAT=$S(VFDDENOM:VFDNUMER/VFDDENOM,1:0)
 D OPEN^%ZISH("OUTFILE",,FILEN,"W")
 I POP D  Q
 . W !,"Error opening file "_FILEN
 U IO W VFDNUMER_","_VFDDENOM_","_VFDRAT
 D CLOSE^%ZISH("OUTFILE")
 Q
