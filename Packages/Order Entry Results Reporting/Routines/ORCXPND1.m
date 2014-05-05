ORCXPND1 ; SLC/MKB - Expanded Display cont ;08/31/09  09:18
 ;;3.0;ORDER ENTRY/RESULTS REPORTING;**26,67,75,89,92,94,148,159,188,172,215,243,280**;Dec 17, 1997;Build 7
 ;
 ; External References
 ;   DBIA  2387  ^LAB(60
 ;   DBIA  3420  ^DPT(  file #2
 ;   DBIA 10035  ^DPT(  file #2
 ;   DBIA 10037  EN^DGRPD
 ;   DBIA   700  DIS^DGRPDB
 ;   DBIA  2926  RT^GMRCGUIA
 ;   DBIA  2925  DT^GMRCSLM2                     ^TMP("GMRCR"
 ;   DBIA  2503  RR^LR7OR1                       ^TMP("LRRR"
 ;   DBIA  2951  EN1^LR7OSBR                     ^TMP("LRC"
 ;   DBIA  2952  EN^LR7OSMZ0
 ;   DBIA  2400  OEL^PSOORRL                     ^TMP("PS"
 ;   DBIA  2877  EN3^RAO7PC3
 ;   DBIA  2877  EN30^RAO7PC3
 ;   DBIA  1252  $$OUTPTPR^SDUTL3
 ;   DBIA  1252  $$OUTPTTM^SDUTL3
 ;   DBIA  2832  RPC^TIUSRV
 ;   DBIA 10061  DEM^VADPT
 ;   DBIA 10061  KVAR^VADPT
 ;   DBIA 10061  OAD^VADPT
 ;   DBIA 10103  $$FMTE^XLFDT
 ;   DBIA  4408  DISP^DGIBDSP
 ;
COVER ; -- Cover Sheet
 N PKG S PKG=$P($G(^TMP("OR",$J,ORTAB,"IDX",NUM)),U,4)
 D ALLERGY^ORCXPND2:PKG="GMRA",NOTES:PKG="TIU"
 Q
NOTES ; -- Progress Notes
 N I,ORY,DATE,AUTHOR,PTLOC,SUBJ K ^TMP("TIUAUDIT",$J)
 D RPC^TIUSRV(.ORY,ID)
 S I=0 F  S I=$O(@ORY@(I)) Q:I'>0  S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=$G(@ORY@(I,0))
 K @ORY
 Q
PROBLEMS ; -- Problem List
 D PL^ORCXPND4
 Q
MEDS ; -- Pharmacy
 ;N NODE,ORIFN
 K ^TMP("PS",$J)
 D OEL^PSOORRL(+ORVP,ID) ;S NODE=$G(^TMP("PS",$J,0)),ORIFN=+$P(NODE,U,11)
 S ID=+$P($G(^TMP("PS",$J,0)),U,11) D ORDERS  ;DBIA 2400
 ;D @($S($P($G(^OR(100,ORIFN,0)),U,11)=$O(^ORD(100.98,"B","IV RX",0)):"IV",1:"DRUG")_"^ORCXPND2")
 K ^TMP("PS",$J)
 Q
LABS ; -- Laboratory [RESULTS ONLY for ID=OE order #]
 N ORIFN,X,SUB,TEST,NAME,SS,IDE,IVDT,TST,CCNT,ORCY,IG,TCNT
 K ^TMP("LRRR",$J)  ;DBIA 2503
 ;DSS/RAF - BEGIN MOD - fix for undef error on AP result when viewing
 ;   from the coversheet in CPRS.  Original VA code commented out and
 ;   then reinserted as argument of line starting with I 'X.
 ;   11/02/2012 - temporary check for vxInterface package
 ;I (ID?2.5U1" "2N1" "1.N1"-"7N1"."1.4N)!(ID?2.5U1" "2N1" "1.N1"-"7N) D AP^ORCXPND3 Q  ;ID=Accession #-Date/time specimen taken
 N VFDVX S VFDVX=$$VX("VFDLA7O")
 S X=0
 I VFDVX S X=$$VFD Q:X=1
 I 'X I (ID?2.5U1" "2N1" "1.N1"-"7N1"."1.4N)!(ID?2.5U1" "2N1" "1.N1"-"7N) D AP^ORCXPND3
 ;DSS/SGM - END MODS 
 S ORIFN=+ID,IDE=$G(^OR(100,+ID,4)) Q:'$L(IDE)  ; OE# -> Lab#
 I +IDE  D RR^LR7OR1(+ORVP,IDE) I '$D(^TMP("LRRR",$J,+ORVP)) S $P(IDE,";",1,3)=";;" ;Order possibly purged, reset to lookup on file 63
 I '+IDE,$P(IDE,";",5)  D RR^LR7OR1(+ORVP,,9999999-$P(IDE,";",5),9999999-$P(IDE,";",5),$P(IDE,";",4))
 K ORCY D TEXT^ORQ12(.ORCY,ORIFN,80)
 S IG=0 F  S IG=$O(ORCY(IG)) Q:IG<1  S X=ORCY(IG) D ITEM^ORCXPND(X)
 D BLANK^ORCXPND I '$D(^TMP("LRRR",$J,+ORVP)) S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)="No data available." Q
 M TEST=^TMP("LRRR",$J,+ORVP) S CCNT=0,SS=""
 F  S SS=$O(TEST(SS)) Q:SS=""  S IVDT=0 F  S IVDT=$O(TEST(SS,IVDT)) Q:'IVDT  D
 . I SS="BB" D
 .. I $$GET^XPAR("DIV^SYS^PKG","OR VBECS ON",1,"Q"),$L($T(EN^ORWLR1)),$L($T(CPRS^VBECA3B)) D  Q  ;Transition to VBEC's interface
 ... K ^TMP("ORLRC",$J)
 ... D EN^ORWLR1(DFN)
 ... I '$O(^TMP("ORLRC",$J,0)) S ^TMP("ORLRC",$J,1,0)="",^TMP("ORLRC",$J,2,0)="No Blood Bank report available..."
 ... N I S I=0 F  S I=$O(^TMP("ORLRC",$J,I)) Q:I<1  S X=^(I,0),LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=X
 ... K ^TMP("ORLRC",$J)
 .. K ^TMP("LRC",$J) D EN1^LR7OSBR(+ORVP) Q:'$D(^TMP("LRC",$J))  D  Q  ;DBIA 2951
 ... N I S I=0 F  S I=$O(^TMP("LRC",$J,I)) Q:I<1  S X=^(I,0),LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=X
 ... K ^TMP("LRC",$J)
 . I SS="MI" K ^TMP("LRC",$J) D EN^LR7OSMZ0(+ORVP) Q:'$D(^TMP("LRC",$J))  D  Q
 .. N I S I=0 F  S I=$O(^TMP("LRC",$J,I)) Q:I<1  S X=^(I,0),LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=X
 .. K ^TMP("LRC",$J)
 . I SS="CH" D  Q
 .. S (TCNT,TST)=0 F  S TST=$O(TEST(SS,IVDT,TST)) Q:TST=""  S CCNT=0,TCNT=TCNT+1 D
 ... ;DSS/CFS - BEGIN MOD
 ... I VFDVX D VFD1 Q
 ... ;DSS/CFS - END MOD
 ... I TCNT=1 D
 .... S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)="   Collection time:          "_$$FMTE^XLFDT(9999999-IVDT,1)
 .... S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=$$S(1,CCNT," ")_$$S(3,CCNT,"Test Name")_$$S(29,CCNT,"Result")_$$S(39,CCNT,"Units")_$$S(55,CCNT,"Range") D:$D(IOUON) SETVIDEO^ORCXPND(LCNT,1,70,IOUON,IOUOFF)
 ... I TST S X=TEST(SS,IVDT,TST),CCNT=0 I +X D
 .... S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=$$S(1,CCNT,$P(^LAB(60,+X,0),U))_$$S(26,CCNT,$J($P(X,U,2),7))_$$S(34,CCNT,$S($L($P(X,U,3)):$P(X,U,3),1:""))_$$S(39,CCNT,$P(X,U,4))_$$S(45,CCNT,$J($P(X,U,5),15))
 .... I $L($P(X,U,3)),$D(IOINHI) D SETVIDEO^ORCXPND(LCNT,26,8,IOINHI,IOINORM)
 .... I $P(X,U,3)["*",$D(IOBON),$D(IOINHI) D SETVIDEO^ORCXPND(LCNT,26,8,IOBON_IOINHI,IOBOFF_IOINORM)
 ... I TST="N" S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=" Comments: " D
 .... N CMT S CMT=0 F  S CMT=$O(TEST(SS,IVDT,"N",CMT)) Q:'CMT  S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=" "_TEST(SS,IVDT,"N",CMT)
 K ^TMP("LRRR",$J)
 Q
 ;
DELAY ; -- Delayed Orders
NEW ; -- New Orders
ORDERS ; -- Orders
 I '$G(ORESULTS) D ORDERS^ORCXPND2 Q
 ; -- Results Display (Add more packages as available)
 N PKG,TAB,ORIFN
 S PKG=+$P($G(^OR(100,+ID,0)),"^",14),PKG=$$NMSP^ORCD(PKG)
 S TAB=$S(PKG="LR":"LABS",PKG="GMRC":"CONSULTS",PKG="RA":"XRAYS",1:"")
 I '$L(TAB)!(ID'>0) D  Q  ; no display available
 . N ORY,I D TEXT^ORQ12(.ORY,+ID,80)
 . S I=0 F  S I=$O(ORY(I)) Q:I'>0  D ITEM^ORCXPND(ORY(I))
 . D BLANK^ORCXPND
 . S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)="There are no results to report."
 I $O(^OR(100,+ID,2,0)) S ORIFN=+ID,ID=0 F  S ID=$O(^OR(100,ORIFN,2,ID)) Q:ID<1  I $D(^OR(100,ID,0)) D @TAB
 I '$O(^OR(100,+ID,2,0)) D @TAB
 Q
REPORTS ; -- Patient Profiles
 D EN^ORCXPNDR ; Reports
 Q
CONSULTS ; -- Consults
 N I,X,SUB,ORTX ;,VALMAR
 I $G(ORTAB)="CONSULTS" S X=$P($G(^TMP("OR",$J,ORTAB,"IDX",NUM)),U,4)
 E  D TEXT^ORQ12(.ORTX,+ID) S X=ORTX(1),ID=+$G(^OR(100,+ID,4)) ; OE->GMRC order#
 D ITEM^ORCXPND(X),BLANK^ORCXPND
 I ID'>0 S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)="No data available." Q
 I '$G(ORESULTS) D  ;DT action
 . S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)="Consult No.:           "_ID
 . N GMRCOER S GMRCOER=2 D DT^GMRCSLM2(ID) S SUB="DT"  ;DBIA 2925
 I $G(ORESULTS) D RT^GMRCGUIA(ID,"^TMP(""GMRCR"",$J,""RT"")") S SUB="RT"
 S I=0 F  S I=$O(^TMP("GMRCR",$J,SUB,I)) Q:I'>0  S X=$G(^(I,0)),LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=X  ;DBIA 2925
 K ^TMP("GMRCR",$J)
 Q
XRAYS ; -- Radiology
 I '$G(ORESULTS) S ID=+ORVP_U_$TR(ID,"-","^") D EN3^RAO7PC3(ID)
 I $G(ORESULTS) S ID=+$G(^OR(100,+ID,4)) D EN30^RAO7PC3(ID)
 N CASE,PROC,PSET S PSET=$D(^TMP($J,"RAE3",+ORVP,"PRINT_SET"))
 S CASE=0 F  S CASE=$O(^TMP($J,"RAE3",+ORVP,CASE)) Q:CASE'>0  D
 . I PSET S PROC=$O(^TMP($J,"RAE3",+ORVP,CASE,"")) D ITEM^ORCXPND(PROC) Q
 . S PROC="" F  S PROC=$O(^TMP($J,"RAE3",+ORVP,CASE,PROC)) Q:PROC=""  D ITEM^ORCXPND(PROC),BLANK^ORCXPND,XRPT,BLANK^ORCXPND
 I PSET S CASE=$O(^TMP($J,"RAE3",+ORVP,0)),PROC=$O(^(CASE,"")) D BLANK^ORCXPND,XRPT,BLANK^ORCXPND ;printset=list all procs, then one report
 K ^TMP($J,"RAE3",+ORVP),^UTILITY($J,"W")
 S VALM("RM")=81
 Q
 ;
XRPT ; -- Body of Report for CASE, PROC
 N ORD,X,I
 S ORD=$S($L($G(^TMP($J,"RAE3",+ORVP,"ORD"))):^("ORD"),$L($G(^("ORD",CASE))):^(CASE),1:"") I $L(ORD),ORD'=PROC S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)="Proc Ord: "_ORD
 S I=1 F  S I=$O(^TMP($J,"RAE3",+ORVP,CASE,PROC,I)) Q:I'>0  S X=^(I),LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=X ;Skip pt ID on line 1
 Q
 ;
SUMMRIES ; -- Discharge Summaries
 N I,ORY,DATE,AUTHOR,PTLOC,SUBJ K ^TMP("TIUAUDIT",$J)
 D RPC^TIUSRV(.ORY,ID)
 S I=0 F  S I=$O(@ORY@(I)) Q:I'>0  S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=$G(@ORY@(I,0))
 K @ORY
 Q
PTINQ ; Print Patient Inquiry in List Manager
 N DFN,ORI,X
 S DFN=+ORVP
 D DGINQ(DFN)
 S ORI=4,LCNT=0
 F  S ORI=$O(^TMP("ORDATA",$J,1,ORI)) Q:'ORI  S X=^(ORI) D
 . S LCNT=LCNT+1
 . S ^TMP("ORXPND",$J,LCNT,0)=X
 K ^TMP("ORDATA",$J,1)
 Q
 ;
DGINQ(DFN) ; Patient Inquiry
 D START^ORWRP(80,"DGINQB^ORCXPND1(DFN)")
 Q
DGINQB(DFN) ; Build Patient Inquiry
 N CONTACT,ORDOC,ORTEAM,ORVP,XQORNOD,ORSSTRT,ORSSTOPT,VAOA
 S ORVP=DFN_";DPT(",XQORNOD=1
 D EN^DGRPD ; MAS Patient Inquiry
 ;
 S ORDOC=$$OUTPTPR^SDUTL3(DFN)
 S ORTEAM=$$OUTPTTM^SDUTL3(DFN)
 I ORDOC!ORTEAM  D
 . W !!,"Primary Care Information:"
 . I ORDOC W !,"Primary Practitioner:  ",$P(ORDOC,"^",2)
 . I ORTEAM W !,"Primary Care Team:     ",$P(ORTEAM,"^",2)
 W !!,"Health Insurance Information:"
 D DISP^DGIBDSP  ;DBIA #4408
 ;DSS/CFS - BEGIN MOD - Deveteranization
 ; original VA lines now argument of ELSE command
 I $$VX
 E  W !!,"Service Connection/Rated Disabilities:"
 E  D DIS^DGRPDB
 ;DSS/CFS - END MOD - Deveteranization
 F CONTACT="N","S" D
 .S VAOA("A")=$S(CONTACT="N":"",1:3)
 .D OAD^VADPT ;   Get NOK Information
 .I VAOA(9)]"" D
 .. W !!,$S(CONTACT="N":"Next of Kin Information:",1:"Secondary Next of Kin Information:")
 .. W !,"Name:  ",VAOA(9)                          ;     NOK Name
 .. I VAOA(10)]"" W " (",VAOA(10),")"              ;     Relationship
 .. I VAOA(1)]"" W !?7,VAOA(1)                     ;     Address Line 1
 .. I VAOA(2)]"" W !?7,VAOA(2)                     ;     Line 2
 .. I VAOA(3)]"" W !?7,VAOA(3)                     ;     Line 3
 .. I VAOA(4)]"" D
 .. . W !?7,VAOA(4)                                ;     City
 .. . I VAOA(5)]"" W ", "_$P(VAOA(5),"^",2)        ;     State
 .. . W "  ",$P(VAOA(11),"^",2)                    ;     Zip+4
 .. I VAOA(8)]"" W !!?7,"Phone number:  ",VAOA(8)  ;     Phone
 .. I CONTACT="N",$P($G(^DPT(DFN,.21)),U,11)]"" W !?7,"Work phone number:  ",$P(^DPT(DFN,.21),U,11)
 .. I CONTACT="S",$P($G(^DPT(DFN,.211)),U,11)]"" W !?7,"Work phone number:  ",$P(^DPT(DFN,.211),U,11)
 D KVAR^VADPT
 Q
TRIM(X) ;   Trim Spaces
 S X=$G(X) F  Q:$E(X,1)'=" "  S X=$E(X,2,$L(X))
 F  Q:$E(X,$L(X))'=" "  S X=$E(X,1,($L(X)-1))
 Q X
S(X,Y,Z) ; Pad Over
 ;   X=Column #
 ;   Y=Current Length
 ;   Z=Text
 ;   SP=Text Sent
 ;   CCNT=Line Position After Input Text
 I '$D(Z) Q ""
 N SP S SP=Z I X,Y,X>Y S SP=$E("                                                                             ",1,X-Y)_Z
 S CCNT=$$INC(CCNT,SP)
 Q SP
INC(X,Y) ; Character Position Count
 ;   X=Current Count
 ;   Y=Text
 N INC S INC=X+$L(Y)
 Q INC
 ;
 ;DSS/RAF - BEGIN MOD needed to determine anatomic path data
VFD() ;
 ; Extrinsic function, QUIT 1 if do not continue
 N X,Y,Z,DD63,IENS,OUT,PKGREF,XQADATA
 I $D(DFN) D  I $D(OUT) Q 1
 . S PKGREF=$$VFDGET1(100,+ID,33,"I")
 . S X=$P(PKGREF,";",4)
 . I X]"","SPCYEM"[X D
 . . ;if subscript exists in piece 4 the LRIDT exists in piece 5
 . . S DD63=$S(X="SP":63.08,X="CY":63.09,X="EM":63.02,1:"")
 . . S OUT("LRSS")=X
 . . S OUT("LRDFN")=$$VFDGET1(2,DFN,63,"I")
 . . S OUT("LRIDT")=$P(PKGREF,";",5)
 . . S IENS=OUT("LRIDT")_","_OUT("LRDFN")_","
 . . S OUT("LRACC")=$$VFDGET1(DD63,IENS,.06)
 . . Q
 . Q:'$D(OUT)
 . S ID=OUT("LRACC")_"-"_OUT("LRIDT"),XQADATA=OUT("LRSS") D AP^ORCXPND3
 . Q
 ; if get to this point, then if accession area is SP,CY, or EM then do
 ; this vxVistA code, else continue processing through the LABS module.
 S OUT=$P($$VFDGET1(100,+ID,33,"I"),";",4)
 I OUT'="","SPCYEM"[OUT S ^TMP("ORXPND",$J,1,0)="No data available." Q 1
 Q -1
 ;
VFD1 ;
 ; Clone of LABS+26:LABS+34 in unmodified FOIA version.  To see the
 ; difference compare lines above to these lines below.  Improved AP
 ; result reporting.
 N X,Y,Z,VFDLRDFN,VIENS
 I TCNT=1 D
 . S X="   Collection time:          "_$$FMTE^XLFDT(9999999-IVDT,1) D VFDSET
 . S VFDLRDFN=$$VFDGET1(2,+ORVP_",",63,"I")
 . S VIENS=IVDT_","_VFDLRDFN_","
 . S X="   Ref Lab Acc#:             "_$$VFDGET1(63.04,VIENS,.34) D VFDSET
 . S X="   Lab Arrival Date/Time:    "_$$VFDGET1(63.04,VIENS,.21601) D VFDSET
 . S X="   Report Date/time:         "_$$VFDGET1(63.04,VIENS,.03) D VFDSET
 . S X=" " D VFDSET
 . S X=$$S(1,CCNT," ")_$$S(3,CCNT,"Test Name")_$$S(51,CCNT,"Result")_$$S(69,CCNT,"Units")_$$S(86,CCNT,"Range")
 . D VFDSET
 . D:$D(IOUON) SETVIDEO^ORCXPND(LCNT,1,70,IOUON,IOUOFF)
 . Q
 I TST S X=TEST(SS,IVDT,TST),CCNT=0 I +X D
 . S X=$$S(1,CCNT,$P(^LAB(60,+X,0),U))_$$S(51,CCNT,$J($P(X,U,2),7))_$$S(63,CCNT,$S($L($P(X,U,3)):$P(X,U,3),1:""))_$$S(69,CCNT,$P(X,U,4))_$$S(86,CCNT,$J($P(X,U,5),15))
 . D VFDSET
 . I $L($P(X,U,3)),$D(IOINHI) D SETVIDEO^ORCXPND(LCNT,26,8,IOINHI,IOINORM)
 . I $P(X,U,3)["*",$D(IOBON),$D(IOINHI) D SETVIDEO^ORCXPND(LCNT,26,8,IOBON_IOINHI,IOBOFF_IOINORM)
 I TST="N" N CMT S CMT=0,X=" Comments: " D VFDSET D
 . F  S CMT=$O(TEST(SS,IVDT,"N",CMT)) Q:'CMT  S X=" "_TEST(SS,IVDT,"N",CMT) D VFDSET
 Q
 ;
VFDGET1(FILE,VIEN,FLD,FLG) ;
 ; only optional parameter is FLG
 N X,Y,Z,DIERR,VFDERR
 I $G(VIEN)'="",$E(VIEN,$L(VIEN))'="," S VIEN=VIEN_","
 Q $$GET1^DIQ(FILE,VIEN,FLD,$G(FLG),"VFDERR")
 ;
VFDSET S LCNT=LCNT+1,^TMP("ORXPND",$J,LCNT,0)=X Q
 ;
VX(RTN) ; vxVistA check
 Q:$T(VX^VFDI0000)="" 0 Q:$$VX^VFDI0000'["VX" 0 Q:$G(RTN)="" 1
 S:$E(RTN)'=U RTN=U_RTN Q $T(@RTN)'=""
