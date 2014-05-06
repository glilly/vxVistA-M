APCDEFP1 ;cmi/sitka/maw - APCD Auto Print PCC Encounter Form  [ 12/22/03  11:24 AM ]
 ;;2.0;IHS RPMS PCC/Data Entry;**3,5,6,7**;MAR 09, 1999
 ;
 ;This routine will print out an automated PCC encounter form for
 ;a particular visit.  The visit IEN needs to be passed in for it
 ;to run.  This will typically be called after data entry.
 ;
 ;
WVSK ;EP-- write out v skin test
 W !,"Skin Tests",!
 S APCDTA=0 F  S APCDTA=$O(APCDSK(APCDTA)) Q:APCDTA=""  D
 . S APCDTRES=$P(APCDSK(APCDTA),U)
 . S APCDTREA=$P(APCDSK(APCDTA),U,2)
 . S APCDTDTR=$P(APCDSK(APCDTA),U,3)
 . W !,"Skin Test: ",APCDTA
 . W ?40,"Result: ",APCDTRES
 . W !,"Reading: ",APCDTREA
 . W ?40,"Date Read: ",APCDTDTR
 K APCDSK,APCDRES,APCDREA,APCDDTR,APCDTRES,APCDTA,APCDTREA,APCDTDTR
 X APCDLN
 Q
 ;
WVTRT ;EP-- write out v treatment
 W !,"Treatments",!
 S APCDTA=0 F  S APCDTA=$O(APCDTRT(APCDTA)) Q:APCDTA=""  D
 . S APCDTHM=$P(APCDTRT(APCDTA),U)
 . S APCDTPRV=$P(APCDTRT(APCDTA),U,2)
 . W !,"Treatment: ",APCDTA
 . W ?40,"How Many: ",APCDTHM
 . W ?57,"Provider: ",APCDTPRV
 K APCDTRT,APCDHM,APCDPRV,APCDTA,APCDTHM,APCDTPRV
 X APCDLN
 Q
 ;
WVCPT ;EP -- write out v cpt
 W !,"CPT codes:",!
 I $G(APCDVEM)]"" W !,"Evalulation and Management: ",APCDVEM
 S APCDTA=0 F  S APCDTA=$O(APCDCPT(APCDTA)) Q:APCDTA=""  D
 . W !?3,$P(APCDCPT(APCDTA),U),?10,"Units: ",$P(APCDCPT(APCDTA),U,2),?21,$S($P(APCDCPT(APCDTA),U,3)]"":"Modifier 1: "_$P(APCDCPT(APCDTA),U,3),1:""),?40,$S($P(APCDCPT(APCDTA),U,4)]"":"Modifier 2: "_$P(APCDCPT(APCDTA),U,4),1:"")
 K APCDCPT,APCDUNI,APCDMD1,APCDMD2
 X APCDLN
 Q
WVPED ;EP-- write out v patient education
 W !,"Patient Education",!
 S APCDTA=0 F  S APCDTA=$O(APCDPED(APCDTA)) Q:APCDTA=""  D
 . W !,"Topic: ",APCDTA
 . W ?45,"Level of Understanding: ",$P($G(APCDPED(APCDTA)),U)
 . W:$P($G(APCDPED(APCDTA)),U,5)]"" !,"Comment: ",$P(APCDPED(APCDTA),U,5)
 . W:$P($G(APCDPED(APCDTA)),U,8)]"" !,"Provider Narrative: ",$P(APCDPED(APCDTA),U,8)
 . I $P(APCDPED(APCDTA),U,6)]""!($P(APCDPED(APCDTA),U,7)]"") W !,"Behavior Code: ",$P(APCDPED(APCDTA),U,6),?40,"Objectives Met: ",$P(APCDPED(APCDTA),U,7)
 . I $P(APCDPED(APCDTA),U,2)]""!($P(APCDPED(APCDTA),U,3)]"")!($P(APCDPED(APCDTA),U,9)]"") W !,"Ind/Group: ",$P(APCDPED(APCDTA),U,2),?40,"Length of Educ: ",$P(APCDPED(APCDTA),U,3),?65,"CPT: ",$P(APCDPED(APCDTA),U,9)
 . W !
 K APCDPED,APCDLOU,APCDTA
 X APCDLN
 Q
 ;
WVPT ;EP-- write out v physical therapy
 W !,"Physical Therapy",!
 S APCDTA=0 F  S APCDTA=$O(APCDPT(APCDTA)) Q:APCDTA=""  D
 . W !,"Therapy: ",APCDTA
 . W ?40,"Quantity: ",$G(APCDPT(APCDPT))
 K APCDPT,APCDQTY,APCDTA
 X APCDLN
 Q
 ;
WVACT ;EP-- write out v activity time
 W !,"Activity Time",!
 S APCDTA=0 F  S APCDTA=$O(APCDACT(APCDTA)) Q:APCDTA=""  D
 . W !,"Activity Time: ",APCDTA
 . W ?30,"Travel Minutes: ",$G(APCDACT(APCDTA))
 K APCDACT,APCDTT,APCDTA
 X APCDLN
 Q
 ;
WVDXP ;EP-- write out v diagnostic procedure result
 W !,"Diagnostic Procedure Result",!
 S APCDTA=0 F  S APCDTA=$O(APCDDXP(APCDTA)) Q:APCDTA=""  D
 . W !,"Type: ",APCDTA
 . W ?40,"Value: ",$G(APCDDXP(APCDTA))
 K APCDDXP,APCDV,APCDTA
 X APCDLN
 Q
 ;
WVRAD ;EP-- write out v radiology
 W !,"Radiology",!
 S APCDTA=0 F  S APCDTA=$O(APCDRAD(APCDTA)) Q:APCDTA=""  D
 . W !,"Radiology Procedure: ",APCDRAD
 . W ?60,$S($G(APCDABN):"Abnormal",1:"")
 K APCDRAD,APCDABN,APCDTA
 X APCDLN
 Q
 ;
WVHF ;EP-- write out v health factors
 W !,"Health Factors: ",!
 S APCDTA=0 F  S APCDTA=$O(APCDHF(APCDTA)) Q:APCDTA=""  D
 . W !,"Health Factor: ",APCDTA
 . W ?50,"Level/Severity: ",$G(APCDHF(APCDTA))
 K APCDHF,APCDLS,APCDTA
 X APCDLN
 Q
 ;
WVMIC ;EP-- write out v microbiology
 W !,"Microbiology",!
 S APCDTA=0 F  S APCDTA=$O(APCDMIC(APCDTA)) Q:APCDTA=""  D
 . W !,"Culture: ",APCDTA
 . W ?40,"Organism: ",$G(APCDMIC(APCDTA))
 K APCDMIC,APCDORG,APCDTA
 X APCDLN
 Q
 ;
WVBB ;EP-- write out v blood bank
 W !,"Blood Bank",!
 S APCDTA=0 F  S APCDTA=$O(APCDBB(APCDTA)) Q:APCDTA=""  D
 . S APCDTRES=$P(APCDBB(APCDTA),U)
 . S APCDTAB=$P(APCDBB(APCDTA),U,2)
 . W !,"Lab Test: ",APCDTA
 . W ?40,"Result: ",APCDTRES
 . W ?60,"Antibody: ",APCDTAB
 K APCDBB,APCDRES,APCDABN,APCDTRES,APCDTAB
 X APCDLN
 Q
 ;
WVPHN ;EP-- write out v public health nurse
 W !,"Public Health Nursing",!
 S APCDTA=0 F  S APCDTA=$O(APCDPHN(APCDTA)) Q:APCDTA=""  D
 . S APCDTRES=$P(APCDPHN(APCDTA),U)
 . S APCDTLOI=$P(APCDPHN(APCDTA),U,2)
 . S APCDTTOD=$P(APCDPHN(APCDTA),U,3)
 . S APCDTR1=$P(APCDPHN(APCDTA),U,4)
 . S APCDTR2=$P(APCDPHN(APCDTA),U,5)
 . S APCDTR3=$P(APCDPHN(APCDTA),U,6)
 . S APCDTR4=$P(APCDPHN(APCDTA),U,7)
 . W !,"Form ID: ",APCDTA
 . W ?20,"Result: ",APCDTRES
 . W ?45,"Level of Intervention: ",APCDLOI
 . W !,"Type of Decision: ",APCDTTOD
 . W !,"Pscho/Social,Environ: ",APCDTR1
 . W !,"Nursing DX: ",APCDTR2
 . W !,"Short Term Goals: ",APCDTR3
 . W !,"Long Term Goals: ",APCDTR4
 K APCDPHN,APCDRES,APCDLOI,APCDTOD,APCDTA,APCDTREC,APCDTLOI,APCDTTOD
 K APCDREC0,APCDREC1,APCDREC2,APCDREC3,APCDREC4,APCDTR1,APCDTR2,APCDTR3
 K APCDTR4
 X APCDLN
 Q
 ;
WVNT ;EP-- write out v narrative text
 W !,"Narrative Text",!
 S APCDTA=0 F  S APCDTA=$O(APCDNT(APCDTA)) Q:APCDTA=""  D
 . W !,"Text Type: ",APCDTA
 . S APCDTNT=0 F  S APCDTNT=$O(APCDNT(APCDTA,APCDTNT)) Q:'APCDTNT  D
 .. W !,$G(APCDNT(APCDTA,APCDTNT))
 K APCDTVDF,APCDREC0,APCDNT,APCDUDA,APCDTNT
 X APCDLN
 Q
 ;
