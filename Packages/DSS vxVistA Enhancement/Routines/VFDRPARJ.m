VFDRPARJ ;DSS/LM - ARRA VTE Studies (driver) ; 5/4/11 9:08am
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 Q
EN ;[Option]
 N DIR,VFDEDT,VFRR,VFDSDT,VFDVTE,VFDXRES,X,Y
 W !,"Please select date range of DISCHARGE movements for study...",!
 Q:$$DATE^VFDCFM(.VFDSDT,.VFDEDT,1)<1
 ;
 S DIR(0)="S^1:VTE-1 prophylaxis or documentation (adm);2:VTE-2 prophylaxis or documentation (ICU);"
 S DIR(0)=DIR(0)_"3:VTE-3 overlap of .. anticoagulation and warfarin therapy;4:VTE-4 UFH therapy .. platelet monitoring;"
 S DIR(0)=DIR(0)_"5:VTE-5 dischaged home .. on warfarin ..;6:VTE-6 hospital dx .. no pre-dx prophylaxis"
 S DIR(0)=DIR(0)_"" ;Place holder for additional reports / computations
 S DIR("A")="Select report" D ^DIR Q:$D(DIRUT)
 ;
 S VFDXML=$NA(^TMP("VFDRPARJ",$J)) K @VFDXML
 S @VFDXML@("COLL")="A"
 D:+Y=1 VTE1 ;Only supported entry at this time.
 D XML^VFDRPARX(.VFDXRES,"VFDRPARJ",.VFDSDT,.VFDEDT,VFDXML)
 Q
DEN(VFDRSLT,VFDSDT,VFDEDT,VFDFG) ;[Private] Main denominator for multiple reports
 ; Discharges filtered by age, and LOS, and ...
 ;
 S VFDFG=$G(VFDFG,1)
 N VFDDEN S VFDDEN=$NA(^TMP("VFDRPARJ","DIS",$J))
 D:VFDFG=1 GET^VFDRPARL(VFDDEN,.VFDSDT,.VFDEDT,"A")  ;Master list
 D:VFDFG=2 GET^VFDRPARL(VFDDEN,.VFDSDT,VFDEDT,"D")  ;Master list
 D:VFDFG=3 GET^VFDRPARL(VFDDEN,.VFDSDT,.VFDEDT,"T") ;Master list
 ;
 ; Optionally check here for 0 records returned
 N VFDAGE ;Filter out AGE<18 - $NAME of age list will be returned by API
 D AGE^VFDRPARK(.VFDAGE,VFDDEN)
 N VFDI,VFDJ,VFDTMP S VFDJ=0,VFDTMP=$NA(^TMP("VFDRPARJ","TMP",$J))
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:@VFDAGE@(VFDI)<18
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI) ;Reduced list
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ;
 ; Exclude by LOS
 N VFDLOS S VFDLOS=$NA(^TMP("VFDRPARL","LOS",$J))
 S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDLOS@(VFDI)=$P(@VFDDEN@(VFDI),U,2)_U_$P(@VFDDEN@(VFDI),U,3)
 .Q
 N VFDOK ;$NAME of LOS inclusion / exclusion list will be returned by API 
 D LOS^VFDRPARK(.VFDOK,VFDLOS,$S(VFDFG=1:1,1:0))
 S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D  ;Create sublist 2 <= LOS < 180
 .Q:$G(@VFDOK@(VFDI))  ;0=EXCLUDE
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ;
 ; At this point @VFDDEN has DENOMINATOR reduced by AGE and LOS exclusions
 ;
 ; Exclude by diagnosis
 ;
 ; Create INPUT array of VISIT IEN ^ PATIENT IEN for call to POV^VFDRPARK
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDTMP@(VFDI)=$P(@VFDDEN@(VFDI),U,4)_U_$P(@VFDDEN@(VFDI),U)
 .Q
 ;
 N VFDDX ;POV^VFDRPARK will return $name of the diagnoses list in VFDDX
 D POV^VFDRPARK(.VFDDX,VFDTMP,"A") ;diagnoses
 ; Check each table - NOTE: The following calls ASSUME THAT THE REFERENCED TABLES EXIST
 ;                          To do: Handle the non-existent table case.
 N VFDEXC S VFDEXC=$NA(^TMP("VFDRPARJ","EXC",$J))
 D ISINTBL^VFDRPARL(VFDEXC,VFDDX,"CMS TABLE 7.01 MENTAL DISORDERS")
 N VFDXALL S VFDXALL=$NA(^TMP("VFDRPARJ","XALL",$J)) K @VFDXALL
 M @VFDXALL=@VFDEXC ;@VFDXALL will have Logical OR of ALL diagnoses exclusions
 K @VFDEXC D ISINTBL^VFDRPARL(VFDEXC,VFDDX,"CMS TABLE 7.02 OBSTETRICS")
 F VFDI=1:1 Q:'$D(@VFDXALL@(VFDI))  S:@VFDEXC@(VFDI) @VFDXALL@(VFDI)=@VFDEXC@(VFDI)
 K @VFDEXC D ISINTBL^VFDRPARL(VFDEXC,VFDDX,"CMS TABLE 8.1 ISCHEMIC STROKE (STK)")
 F VFDI=1:1 Q:'$D(@VFDXALL@(VFDI))  S:@VFDEXC@(VFDI) @VFDXALL@(VFDI)=@VFDEXC@(VFDI)
 K @VFDEXC D ISINTBL^VFDRPARL(VFDEXC,VFDDX,"CMS TABLE 8.2 HEMORRHAGIC STROKE (STK)")
 F VFDI=1:1 Q:'$D(@VFDXALL@(VFDI))  S:@VFDEXC@(VFDI) @VFDXALL@(VFDI)=@VFDEXC@(VFDI)
 ;
 ; Create sublist NOT excluded by DIAGNOSIS
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:$G(@VFDXALL@(VFDI))  ;1=included in diagnosis list = Exclude from denominator
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ;
 ; At this point @VFDDEN has DENOMINATOR reduced by AGE, LOS and diagnoses exclusions
 ;
 ; Exclude by procedure
 ; Additional filters here
 ;
 ; Exclude -  Comfort care
 ;            JC TABLE 3-63 PALLIATIVE CARE MEASURE-PROCEDURE
 ;            JC TABLE 3-66 PALLIATIVE CARE MEASURES ONLY-FIND
 ;
 ;         -  Clinical trial
 ;            JC TABLE 3-60 CLINICAL TRIAL VALUE SET DEFINITION
 ;
 ; Create reuseable VISIT list -
 N VFDVST S VFDVST=$NA(^TMP("VFDRPARJ","VFDVST",$J)) K @VFDVST
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S:$P(@VFDDEN@(VFDI),U,4) @VFDVST@(VFDI)=$P(@VFDDEN@(VFDI),U,4)
 .Q
 ;
 N VFD240 S VFD240=$NA(^TMP("VFDRPARJ",21240,$J)) K @VFD240
 D IS21640^VFDRPARL(VFD240,VFDVST,"JC TABLE 3-63 PALLIATIVE CARE MEASURE-PROCEDURE")
 ;
 ; Create sublist NOT excluded by palliative care
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:$G(@VFD240@(VFDI))  ;1=included in palliative care = Exclude from denominator
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ;
 ; Do the same here for 3-66 and 3-60 (should be in a wrapper sub-routine)
 ; 3-66
 K @VFD240 D IS21640^VFDRPARL(VFD240,VFDVST,"JC TABLE 3-66 PALLIATIVE CARE MEASURES ONLY-FIND")
 ;
 ; Create sublist
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:$G(@VFD240@(VFDI))  ;1=included = Exclude from denominator
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ;
 ; 3-60 (Clinical trial)
 K @VFD240 D IS21640^VFDRPARL(VFD240,VFDVST,"JC TABLE 3-60 CLINICAL TRIAL VALUE SET DEFINITION")
 ;
 ; Create sublist
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:$G(@VFD240@(VFDI))  ;1=included in clinical trial = Exclude from denominator
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ;
 N VFDLOC S VFDLOC=$NA(^TMP("VFDRPARJ","LOC",$J))  ;$NAME of Location inclusion / exclusion list will be returned by API 
 D LOC^VFDRPARK(.VFDLOC,VFDSDT,VFDEDT)
 I $D(@VFDLOC) S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D  ;Create sublist
 .Q:$G(@VFDLOC@(VFDI))  ;0=EXCLUDE
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 E  M @VFDTMP=@VFDDEN
 ;
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 K @VFDLOC   ;$NAME of Location inclusion / exclusion list will be returned by API 
 D STOP^VFDRPARK(.VFDLOC,VFDSDT,VFDEDT)
 I $D(@VFDLOC) D
 .S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D  ;Create sublist
 ..Q:$G(@VFDLOC@(VFDI))  ;0=EXCLUDE
 ..S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 E  M @VFDTMP=@VFDDEN
 ;
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ;
 K @VFDRSLT M @VFDRSLT=@VFDDEN K @VFDDEN ;Move to result
 Q
NUM1(VFDRSLT,VFDSDT,VFDEDT) ; Numerator for VTE-1
 ;
 N VFDNUM S VFDNUM=$NA(^TMP("VFDRPARJ","NUM",$J)) K @VFDNUM
 D DEN1(VFDNUM,VFDSDT,VFDEDT) ;Start with DENOMINATOR
 ; Create INPUT array of VISIT IEN for call to VTEP^VFDRPARK (VTE prophylaxis)
 N VFDI,VFDJ,VFDTMP S VFDTMP=$NA(^TMP("VFDRPARJ","TMP",$J)) K @VFDTMP
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDTMP@(VFDI)=@VFDDEN@(VFDI)_U_$P(@VFDDEN@(VFDI),U,4)
 .Q
 N VFDPXS ;VTEP^VFDRPARK will return $name of the 'prophylaxis' list in VFDPXS
 D VTEP^VFDRPARK(.VFDPXS,VFDTMP) ;Returns '1' if prophylaxis
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDNUM@(VFDI))  D
 .Q:$G(@VFDPXS@(VFDI))  ;If not prophylaxis
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDNUM@(VFDI)
 .Q
 ; Subset the numerator
 K @VFDNUM M @VFDNUM=@VFDTMP K @VFDTMP
 ; 
 ; Additional numerator inclusions here
 N VFDI,VFDJ,VFDTMP S VFDTMP=$NA(^TMP("VFDRPARJ","TMP",$J)) K @VFDTMP
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDTMP@(VFDI)=@VFDDEN@(VFDI)_U_$P(@VFDDEN@(VFDI),U,4)
 ;
 N VFDMPXS ;NOVTE^VFDRPARK will return $name of the 'prophylaxis' list in VFDMPXS
 D NOVTE^VFDRPARK(.VFDMPXS,VFDTMP) ;Returns '1' if prophylaxis
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDNUM@(VFDI))  D
 .Q:$G(@VFDMPXS@(VFDI))  ;If not prophylaxis
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDNUM@(VFDI)
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDTMP@(VFDI)=@VFDDEN@(VFDI)_U_$P(@VFDDEN@(VFDI),U,4)
 ;
 N VFDMPXS1 ;NOVTE1^VFDRPARK will return $name of the 'prophylaxis' list in VFDMPXS1
 D NOVTE1^VFDRPARK(.VFDMPXS1,VFDTMP) ;Returns '1' if prophylaxis
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDNUM@(VFDI))  D
 .Q:$G(@VFDMPXS1@(VFDI))  ;If not prophylaxis
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDNUM@(VFDI)
 ;
 N VFDMRV ;MRV^VFDRPARK will return $name of the 'Medical Reason' list in VFDMRV
 D MRV^VFDRPARK(.VFDMRV,VFDTMP) ;Returns '1' if Medical Reason
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDNUM@(VFDI))  D
 .Q:$G(@VFDMRV@(VFDI))  ;If not Medical Reason
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDNUM@(VFDI)
 ;
 N VFDMND ;MND^VFDRPARK will return $name of the 'Mental Disorders' list in VFDMRV
 D MND^VFDRPARK(.VFDMRV,VFDTMP) ;Returns '1' if Mental Disorders
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDNUM@(VFDI))  D
 .Q:$G(@VFDMRV@(VFDI))  ;If not Medical Reason
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDNUM@(VFDI)
 ;
 K @VFDRSLT M @VFDRSLT=@VFDNUM K @VFDNUM ;Move to result
 ;
 Q
DEN1(VFDRSLT,VFDSDT,VFDEDT) ; Denominator for VTE-1 (prophylaxis study) excludes VTE diagnoses
 ;
 D DEN(VFDRSLT,VFDSDT,VFDEDT,1)
 N VFDDEN S VFDDEN=$NA(^TMP("VFDRPARJ","DIS",$J)) M @VFDDEN=@VFDRSLT K @VFDRSLT
 ;
 N VFDI,VFDJ,VFDTMP S VFDTMP=$NA(^TMP("VFDRPARJ","TMP",$J)) K @VFDTMP
 ;
 N VFDICU S VFDICU=$NA(^TMP("VFDRPARJ",$J,"ICU"))  ;ICUSTAY^VFDRPARK will return $name of the 'ICU LOS' list
 D ICUSTAY^VFDRPARK(.VFDICU,VFDSDT,VFDEDT) ;Returns '1' if ICU LOS
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:$G(@VFDICU@(VFDI))  ;If not ICU LOS
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 ;
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ;
 ; ; Create INPUT array of VISIT IEN ^ PATIENT IEN for call to POV^VFDRPARK
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDTMP@(VFDI)=$P(@VFDDEN@(VFDI),U,4)_U_$P(@VFDDEN@(VFDI),U)
 .Q
 N VFDDX ;POV^VFDRPARK will return $name of the diagnoses list in VFDDX
 D POV^VFDRPARK(.VFDDX,VFDTMP,"A") ;diagnoses
 ; Check each table - NOTE: The following calls ASSUME THAT THE REFERENCED TABLES EXIST
 ;                          To do: Handle the non-existent table case.
 N VFDEXC S VFDEXC=$NA(^TMP("VFDRPARJ","EXC",$J))
 ;
 ; Exclude VTE diagnoses from denominator of VTE-1 and VTE-2 studies
 K @VFDEXC D ISINTBL^VFDRPARL(VFDEXC,VFDDX,"CMS TABLE 7.03 VENOUS THROMBOEMBOLEBITIS (VTE)")
 N VFDXALL S VFDXALL=$NA(^TMP("VFDRPARJ","XALL",$J)) K @VFDXALL
 M @VFDXALL=@VFDEXC ;@VFDXALL will have Logical OR of ALL diagnoses exclusions
 K @VFDEXC D ISINTBL^VFDRPARL(VFDEXC,VFDDX,"CMS TABLE 7.04 OBSTETRICS - VTE")
 F VFDI=1:1 Q:'$D(@VFDXALL@(VFDI))  S:@VFDEXC@(VFDI) @VFDXALL@(VFDI)=@VFDEXC@(VFDI)
 ;
 ; Create sublist NOT excluded by DIAGNOSIS
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:$G(@VFDXALL@(VFDI))  ;1=included in diagnosis list = Exclude from denominator
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ; 
 ;
 N VFDDX ;VTECON^VFDRPARK will return $name of the diagnoses list in VFDDX
 D VTECON^VFDRPARK(.VFDDX,VFDDEN) ; VTE Confirmed
 ; Check each table - NOTE: The following calls ASSUME THAT THE REFERENCED TABLES EXIST
 ;                          To do: Handle the non-existent table case.
 N VFDEXC S VFDEXC=$NA(^TMP("VFDRPARJ","EXC",$J))
 ;
 ; Exclude VTE diagnoses from denominator of VTE-1 and VTE-2 studies
 K @VFDEXC D ISINTBL^VFDRPARL(VFDEXC,VFDDX,"CMS TABLE 3-240 JOINT COMMISSION VTE CONFIRMED VALUE SET")
 N VFDXALL S VFDXALL=$NA(^TMP("VFDRPARJ","XALL",$J)) K @VFDXALL
 M @VFDXALL=@VFDEXC ;@VFDXALL will have Logical OR of ALL diagnoses exclusions
 F VFDI=1:1 Q:'$D(@VFDXALL@(VFDI))  S:@VFDEXC@(VFDI) @VFDXALL@(VFDI)=@VFDEXC@(VFDI)
 ; Additional denominator exclusions here
 ;
 ;
 K @VFDRSLT M @VFDRSLT=@VFDDEN K @VFDDEN ;Move to result
 Q
VTE1 ;
 ; VFDSDT and VFDEDT are defined by caller (EN^VFDRPARJ)
 ; 
 N VFDDEN,VFDNUM
 S VFDDEN=$NA(^TMP("VFDRPARJ","D",$J)),VFDNUM=$NA(^TMP("VFDRPARJ","N",$J))
 K @VFDDEN,@VFDNUM
 ;
 D DEN1(VFDDEN,VFDSDT,VFDEDT) ;VTE-1 Denominator List
 D NUM1(VFDNUM,VFDSDT,VFDEDT) ;VTE-1 Numerator List
 ;
 D  ; set up XML totals
 .N MDT,DIF,DFN,PROV,VAIP,VLP
 .S VLP=0 F  S VLP=$O(@VFDDEN@(VLP)) Q:'VLP  D
 ..K VAIP S VAIP("E")=$P(@VFDDEN@(VLP),U,7),DFN=+@VFDDEN@(VLP) D IN5^VADPT
 ..I $G(VAIP(18))>0 S PROV=+VAIP(18)  ; attending physician
 ..I $G(VAIP(17,5))>0 S PROV=+VAIP(17,5)  ; discharge physician
 ..I $G(VAIP(13,5))>0 S PROV=+VAIP(13,5)  ; admitting physician
 ..S @VFDXML@(1,PROV,"ELIG")=$G(@VFDXML@(1,PROV,"ELIG"))+1
 .S VLP=0 F  S VLP=$O(@VFDNUM@(VLP)) Q:'VLP  D
 ..K VAIP S VAIP("E")=$P(@VFDNUM@(VLP),U,7),DFN=+@VFDNUM@(VLP) D IN5^VADPT
 ..I $G(VAIP(18))>0 S PROV=+VAIP(18)  ; attending physician
 ..I $G(VAIP(17,5))>0 S PROV=+VAIP(17,5)  ; discharge physician
 ..I $G(VAIP(13,5))>0 S PROV=+VAIP(13,5)  ; admitting physician
 ..S @VFDXML@(1,PROV,"MEETS")=$G(@VFDXML@(1,PROV,"MEETS"))+1
 .S VLP=0 F VLP=$O(@VFDXML@(VLP)) Q:'VLP  D
 ..I +$G(@VFDXML@(1,VLP,"ELIG"))=0 S @VFDXML@(1,VLP,"ELIG")=1
 ..I $G(@VFDXML@(1,VLP,"MEETS"))'=$G(@VFDXML@(1,VLP,"ELIG")) S @VFDXML@(1,VLP,"EXCL")=$G(@VFDXML@(1,VLP,"ELIG"))-$G(@VFDXML@(1,VLP,"MEETS"))
 .S @VFDXML@("PQRI")="NQF 0371"
 Q
 ;
 ;
 ; 
 ;D  ; Debug Output (Comment-out this line to delete)
 .N VFDD,VFDI,VFDN
 .S VFDD=+$O(@VFDDEN@(" "),-1),VFDN=+$O(@VFDNUM@(" "),-1)
 .W !!,"The VTE-1 denominator has ",VFDD," data points.",!
 .F VFDI=1:1:VFDD W !,@VFDDEN@(VFDI)
 .W !!,"The VTE-1 numerator has ",VFDN," data points.",!
 .F VFDI=1:1:VFDN W !,@VFDNUM@(VFDI)
 .Q:'VFDD
 .W !!,$J(VFDN/VFDD*100,3,2),"%"
 Q
 ;
 ; VTE-2 VENOUS THROMBOEMBOLISM VTE-2 MEASURE DESCRIPTION
 ;
VTE2 ;
 ; VFDSDT and VFDEDT are defined by caller (EN^VFDRPARJ)
 ; 
 N VFDDEN,VFDNUM
 S VFDDEN=$NA(^TMP("VFDRPARJ","D",$J)),VFDNUM=$NA(^TMP("VFDRPARJ","N",$J))
 K @VFDDEN,@VFDNUM
 ;
 D DEN2(VFDDEN,VFDSDT,VFDEDT) ;VTE-1 Denominator List
 D NUM2(VFDNUM,VFDSDT,VFDEDT) ;VTE-1 Numerator List
 ;
 D  ; Debug Output (Comment-out this line to delete)
 .N VFDD,VFDI,VFDN
 .S VFDD=+$O(@VFDDEN@(" "),-1),VFDN=+$O(@VFDNUM@(" "),-1)
 .W !!,"The VTE-1 denominator has ",VFDD," data points.",!
 .F VFDI=1:1:VFDD W !,@VFDDEN@(VFDI)
 .W !!,"The VTE-1 numerator has ",VFDN," data points.",!
 .F VFDI=1:1:VFDN W !,@VFDNUM@(VFDI)
 .Q:'VFDD
 .W !!,$J(VFDN/VFDD*100,3,2),"%"
 Q
 ;
DEN2(VFDRSLT,VFDSDT,VFDEDT) ; Denominator for VTE-2 (prophylaxis in ICU) excludes VTE diagnoses
 ;
 D DEN(VFDRSLT,VFDSDT,VFDEDT)
 N VFDDEN S VFDDEN=$NA(^TMP("VFDRPARJ","DIS",$J)) M @VFDDEN=@VFDRSLT K @VFDRSLT
 ;
 N VFDI,VFDJ,VFDTMP S VFDTMP=$NA(^TMP("VFDRPARJ","TMP",$J)) K @VFDTMP
 ;
 ; Create INPUT array of VISIT IEN ^ PATIENT IEN for call to POV^VFDRPARK
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDTMP@(VFDI)=$P(@VFDDEN@(VFDI),U,4)_U_$P(@VFDDEN@(VFDI),U)
 .Q
 N VFDDX ;POV^VFDRPARK will return $name of the diagnoses list in VFDDX
 D POV^VFDRPARK(.VFDDX,VFDTMP,"A") ;diagnoses
 ; Check each table - NOTE: The following calls ASSUME THAT THE REFERENCED TABLES EXIST
 ;                          To do: Handle the non-existent table case.
 N VFDEXC S VFDEXC=$NA(^TMP("VFDRPARJ","EXC",$J))
 ;
 ; Exclude VTE diagnoses from denominator of VTE-1 and VTE-2 studies
 K @VFDEXC D ISINTBL^VFDRPARL(VFDEXC,VFDDX,"CMS TABLE 7.03 VENOUS THROMBOEMBOLEBITIS (VTE)")
 N VFDXALL S VFDXALL=$NA(^TMP("VFDRPARJ","XALL",$J)) K @VFDXALL
 M @VFDXALL=@VFDEXC ;@VFDXALL will have Logical OR of ALL diagnoses exclusions
 K @VFDEXC D ISINTBL^VFDRPARL(VFDEXC,VFDDX,"CMS TABLE 7.04 OBSTETRICS - VTE")
 F VFDI=1:1 Q:'$D(@VFDXALL@(VFDI))  S:@VFDEXC@(VFDI) @VFDXALL@(VFDI)=@VFDEXC@(VFDI)
 ;
 ; Create sublist NOT excluded by DIAGNOSIS
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:$G(@VFDXALL@(VFDI))  ;1=included in diagnosis list = Exclude from denominator
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ; 
 ; Exclude -  Comfort care
 ;            JC TABLE 3-63 PALLIATIVE CARE MEASURE-PROCEDURE
 ;            JC TABLE 3-66 PALLIATIVE CARE MEASURES ONLY-FIND
 ;
 ;         -  Clinical trial
 ;            JC TABLE 3-60 CLINICAL TRIAL VALUE SET DEFINITION
 ;
 ; Create reuseable VISIT list -
 N VFDVST S VFDVST=$NA(^TMP("VFDRPARJ","VFDVST",$J)) K @VFDVST
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDVST@(VFDI)=$P(@VFDDEN@(VFDI),U,4)
 .Q
 ;
 N VFD240 S VFD240=$NA(^TMP("VFDRPARJ",21240,$J)) K @VFD240
 D IS21640^VFDRPARL(VFD240,VFDVST,"JC TABLE 3-63 PALLIATIVE CARE MEASURE-PROCEDURE")
 ;
 ; Create sublist NOT excluded by palliative care
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:$G(@VFD240@(VFDI))  ;1=included in palliative care = Exclude from denominator
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ;
 ; Do the same here for 3-66 and 3-60 (should be in a wrapper sub-routine)
 ; 3-66
 K @VFD240 D IS21640^VFDRPARL(VFD240,VFDVST,"JC TABLE 3-66 PALLIATIVE CARE MEASURES ONLY-FIND")
 ;
 ; Create sublist
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:$G(@VFD240@(VFDI))  ;1=included = Exclude from denominator
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ;
 ; 3-60 (Clinical trial)
 K @VFD240 D IS21640^VFDRPARL(VFD240,VFDVST,"JC TABLE 3-60 CLINICAL TRIAL VALUE SET DEFINITION")
 ;
 ; Create sublist
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .Q:$G(@VFD240@(VFDI))  ;1=included in clinical trial = Exclude from denominator
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDDEN@(VFDI)
 .Q
 K @VFDDEN M @VFDDEN=@VFDTMP K @VFDTMP ;Replace VFDDEN with reduced list
 ; 
 ; Additional denominator exclusions here
 ;
 ;
 K @VFDRSLT M @VFDRSLT=@VFDDEN K @VFDDEN ;Move to result
 Q
 ;
NUM2(VFDRSLT,VFDSDT,VFDEDT) ; Numerator for VTE-1
 ;
 N VFDNUM S VFDNUM=$NA(^TMP("VFDRPARJ","NUM",$J)) K @VFDNUM
 D DEN1(VFDNUM,VFDSDT,VFDEDT) ;Start with DENOMINATOR
 ; Create INPUT array of VISIT IEN for call to VTEP^VFDRPARK (VTE prophylaxis)
 N VFDI,VFDJ,VFDTMP S VFDTMP=$NA(^TMP("VFDRPARJ","TMP",$J)) K @VFDTMP
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDTMP@(VFDI)=@VFDDEN@(VFDI)_U_$P(@VFDDEN@(VFDI),U,4)
 .Q
 N VFDPXS ;VTEP^VFDRPARK will return $name of the 'prophylaxis' list in VFDPXS
 D VTEP^VFDRPARK(.VFDPXS,VFDTMP) ;Returns '1' if prophylaxis
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDNUM@(VFDI))  D
 .Q:'$G(@VFDPXS@(VFDI))  ;If not prophylaxis
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDNUM@(VFDI)
 .Q
 ; Subset the numerator
 K @VFDNUM M @VFDNUM=@VFDTMP K @VFDTMP
 ; 
 ; Additional numerator inclusions here
 N VFDI,VFDJ,VFDTMP S VFDTMP=$NA(^TMP("VFDRPARJ","TMP",$J)) K @VFDTMP
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDTMP@(VFDI)=@VFDDEN@(VFDI)_U_$P(@VFDDEN@(VFDI),U,4)
 ;
 N VFDMPXS ;NOVTE^VFDRPARK will return $name of the 'prophylaxis' list in VFDMPXS
 D NOVTE^VFDRPARK(.VFDMPXS,VFDTMP) ;Returns '1' if prophylaxis
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDNUM@(VFDI))  D
 .Q:'$G(@VFDMPXS@(VFDI))  ;If not prophylaxis
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDNUM@(VFDI)
 F VFDI=1:1 Q:'$D(@VFDDEN@(VFDI))  D
 .S @VFDTMP@(VFDI)=@VFDDEN@(VFDI)_U_$P(@VFDDEN@(VFDI),U,4)
 ;
 N VFDMPXS1 ;NOVTE1^VFDRPARK will return $name of the 'prophylaxis' list in VFDMPXS1
 D NOVTE1^VFDRPARK(.VFDMPXS1,VFDTMP) ;Returns '1' if prophylaxis
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDNUM@(VFDI))  D
 .Q:'$G(@VFDMPXS1@(VFDI))  ;If not prophylaxis
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDNUM@(VFDI)
 ;
 N VFDMRV ;MRV^VFDRPARK will return $name of the 'Medical Reason' list in VFDMRV
 D MRV^VFDRPARK(.VFDMRV,VFDTMP) ;Returns '1' if Medical Reason
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDNUM@(VFDI))  D
 .Q:'$G(@VFDMRV@(VFDI))  ;If not Medical Reason
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDNUM@(VFDI)
 ;
 N VFDMND ;MND^VFDRPARK will return $name of the 'Mental Disorders' list in VFDMRV
 D MND^VFDRPARK(.VFDMRV,VFDTMP) ;Returns '1' if Mental Disorders
 K @VFDTMP S VFDJ=0 F VFDI=1:1 Q:'$D(@VFDNUM@(VFDI))  D
 .Q:'$G(@VFDMRV@(VFDI))  ;If not Medical Reason
 .S VFDJ=VFDJ+1,@VFDTMP@(VFDJ)=@VFDNUM@(VFDI)
 ;
 K @VFDRSLT M @VFDRSLT=@VFDNUM K @VFDNUM ;Move to result
 ;
 Q
