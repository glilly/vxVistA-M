VFDPSOLL ;DSS/SGM - OUTPATIENT PHARMACY LASER SHEET CONTROL CODES ; 11/29/2012 20:00
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; The outpatient pharmacy package had problems with updating the
 ; control code multiple in the TERMINAL TYPE file.  Several patches
 ; were released which must be run in the proper sequence.  There
 ; were bugs in the code that cause duplicate control codes to be
 ; entered for the entry.  This is a clone and combination of the
 ; three routines.  Here are the 3 routines and their patch level:
 ;   PSOLLU2   **120,138,141,135**
 ;   PSOLLU3   **141,135**
 ;   PSOLLU4   **161**
 ; The control code is entered in this routine only once.  It will
 ; always be the latest control code value from the multiple PSOLLU*
 ; routines.  Instead of filing each control code separately, a single
 ; edit call will be made with all of them in a standard FDA array.
 ; Also, since the original code introduced duplicates, this code
 ; will delete all the codes in the array that may exist and then
 ; refile the updated codes.
 ;
 ; Oddity in original program logic of those three patches.  Only the
 ; first patch prompted for HP versus Lexmark printer.  Yet the third
 ; patch replaces PFI without respect for HP versus Lexmark.  Thus,
 ; this routine removes the PFI codes from the Lexmark specific section
 ; PFI was not part of the common codes from PSOLLU2.
 ;
 N I,J,X,Y,Z,TYPE,VFDAX,VFDIEN,VFDMSG,VFDX
 M VFDX=DUZ N DUZ M DUZ=VFDX S DUZ(0)="@" S:'$G(DUZ) DUZ=.5
 S VFDIEN=$$TT I VFDIEN<1 Q
 S TYPE=$$TYPE I TYPE=-1 Q
 Q:$$CONT'=1
EN ; entry point with answers above
 D CC,@TYPE
 D CLEAN(+VFDIEN),UPDATE(+VFDIEN)
 I $D(VFDMSG) D MES^XPDUTL(.VFDMSG)
 Q
 ;
POST ; VFD VXVISTA UPDATE post install
 N I,J,X,Y,Z,TYPE,VFDAX,VFDIEN,VFDMSG,VFDX
 M VFDX=DUZ N DUZ M DUZ=VFDX S DUZ(0)="@" S:'$G(DUZ) DUZ=.5
 S X="P-HP-LASER",Y=$O(^%ZIS(2,"B",X,0)) Q:Y<1
 S VFDIEN=Y_U_X,TYPE="H"
 G EN
 ;
 ;-----  LIST OF CONTROL CODES <control code>^<name>^<M commands>  ----
CC ;
 ;;LL^LASER LABEL^Q
 ;;LLI^LASER LABEL INIT^W $C(27),"&r1F",$C(27),"E",$C(27),"&l0O",$C(27),"&u300D",$C(27),"&l3A",$C(27),"&l0E",!
 ;;F10^TEN POINT FONT - NO BOLD^W $C(27),"(10U",$C(27),"(s1p10v0s0b16602T"
 ;;F8^EIGHT POINT FONT - NO BOLD^W $C(27),"(10U",$C(27),"(s1p8v0s0b16602T"
 ;;F12^TWELVE POINT FONT - NO BOLD^W $C(27),"(10U",$C(27),"(s1p12v0s0b16602T"
 ;;F9^NINE POINT FONT - NO BOLD^W $C(27),"(10U",$C(27),"(s1p9v0s0b16602T"
 ;;ST^START OF TEXT^S PSOY=PSOY+PSOYI W $C(27),"*p",PSOX,"x",PSOY,"Y"
 ;;CDII^CRITICAL DRUG INTERACTION INITIALIZATION^S PSOX=0,PSOY=1400,PSOYI=50,PSOFONT="F10"
 ;;PMII^PMI SECTION INITIALIZATION^S PSOX=0,PSOY=1350,PSOYI=50,PSOFONT="F10",PSOYM=3899
 ;;F6B^SIX POINT FONT, BOLDED^W $C(27),"(10U",$C(27),"(s1p6v0s3b16602T"
 ;;F8B^EIGHT POINT FONT, BOLDED^W $C(27),"(10U",$C(27),"(s1p8v0s3b16602T"
 ;;F9B^NINE POINT FONT, BOLDED^W $C(27),"(10U",$C(27),"(s1p9v0s3b16602T"
 ;;F10B^TEN POINT FONT, BOLDED^W $C(27),"(10U",$C(27),"(s1p10v0s3b16602T"
 ;;F12B^12 POINT FONT BOLDED^W $C(27),"(10U",$C(27),"(s1p12v0s3b16602T"
 ;;MLI^MAILING LABEL INITIALIZATION^S PSOFONT="F10",PSOX=1680,PSOY=175,PSOYI=50
 ;;ACI^ADDRESS CHANGE INITIALIZATION^S PSOHFONT="F12",PSOX=1210,PSOY=700,PSOFY=1270
 ;;ALI^ALLERGY SECTION INITIALIZATION^S PSOFONT="F10",PSOX=0,PSOY=1350,PSOYI=50,PSOYM=2700
 ;;FWU^FONT WITH UNDERLINE^W $C(27),"&d0D"
 ;;FDU^FONT DISABLE UNDERLINE^W $C(27),"&d@"
 ;;RMI^RETURN MAIL INITIALIZATION^S PSOHFONT="F8",PSOFONT="F10",PSOX=1680,PSOY=35,PSORYI=40,PSOHYI=40,PSOTFONT="F8",PSOTY=550
 ;;SPI^SUSPENSE PRINT INITIALIZATION^S PSOFONT="F10",PSOX=1210,PSOY=1350,PSOYI=50,PSOCX=1775,PSOYM=2700
 ;;WLI^WARNING LABEL INITIALIZATION^S PSOX=1050,PSOY=55
 ;;RNI^REFILL NARRATIVE INITIALIZATION^S PSOY=2860,PSOFONT="F10",PSOX=0,PSOYI=50,PSOYM=3950
 ;;CNI^COPAY NARRATIVE INITIALIZATION^S PSOY=2860,PSOX=1210,PSOYM=3950,PSOFONT="F10",PSOYI=50
 ;;PII^PATIENT INSTRUCTION INITIALIZATION^S PSOX=1210,PSOY=760,PSOFONT="F12"
 ;;RPI^REFILL PRINT INITIALIZATION^S PSOFONT="F10",PSOBYI=65,PSOTYI=50,PSOLX=0,PSORX=1210,PSOY=1350,PSOYM=3650,PSOXI=90,PSOSYI=135
 ;;BLH^BOTTLE LABEL HEADER INITIALIZATION^S PSOX=100,PSOY=50,PSOYI=30,PSOFONT="F9"
 ;;BLB^BOTTLE LABEL BODY INITIALIZATION^S PSOX=0,PSODX=275,PSOY=140,PSOYI=40,PSOYM=379,PSOFONT="F10"
 ;;BLF^BOTTLE LABEL FOOTER INITIALIZATION^S PSODY=460,PSOX=0,PSOCX=280,PSOQY=550,PSOTY=600,PSOFONT="F10",PSOQFONT="F8",PSODFONT="F9",PSOTFONT="F10"
 ;;RT^ROTATE TEXT^W $C(27),"&a90P"
 ;;NR^NORMAL ROTATION^W $C(27),"&a0P"
 ;;PFDI^PHARMACY FILL DOCUMENT INITIALIZATION^S PSOFONT="F10",PSOX=0,PSOY=690,PSOYI=40,PSOYM=969
 ;;PFDQ^PHARMACY FILL DOCUMENT QUANTITY^S PSOX=0,PSOCX=200,PSOY=970,PSOYI=50,PSOQFONT="F8",PSOFONT="F10"
 ;;PFDW^PHARMACY FILL DOCUMENT WARNING^S PSOY=1258,PSOX=660,PSOYI=30,PSOFONT="F8",PSOYM=1329
 ;;AWI^ALLERGY WARNING INITIALIZATION^S PSOX=0,PSOY=1400,PSOYI=50,PSOFONT="F10"
 ;;F6^SIX POINT FONT - NO BOLD^W $C(27),"(10U",$C(27),"(s1p6v0s0b16602T"
 ;;EBT^END OF BARCODE TEXT^W $C(27),"(8U",$C(27),"(s1p8v0s0b16602T",!
 ;;PFI^PATIENT FILL INITIALIZATION^S PSOFONT="F10",PSOX=1210,PSOY=710,PSOYI=45,PSOHFONT="F12",PSOBYI=100
 ;;
 N I,J,X,Y,Z,CC K VFDAX
 F I=1:1 S X=$P($T(CC+I),";",3,999) Q:X=""  D SET
 Q
 ;
H ; HP laser specific codes
 ;;BLBC^BOTTLE LABEL BARCODE^W $C(27),"(9Y",$C(27),"(s1p18v0s0b28677T",$C(27),"&a90P",$C(27),"*p3700x1000Y"
 ;;PFDT^PHARMACY FILL DOCUMENT TRAILER^S PSOY=1015,PSOYI=45,PSOX=0,PSOFONT="F10",PSOBYI=50,PSOTFONT="F9",PSOBY=1260
 ;;EBLBC^END OF BOTTLE LABEL BARCODE^W $C(27),"(10U",$C(27),"(s1p10v0s0b16602T",$C(27),"&a0P",!
 ;;SBT^START OF BARCODE TEXT^S PSOY=PSOY+PSOYI W $C(27),"*p",PSOX,"x",PSOY,"Y",$C(27),"(9Y",$C(27),"(s1p18v0s0b28683T"
 ;;
 N I,J,X,Y,Z,CC
 F I=1:1 S X=$P($T(H+I),";",3,999) Q:X=""  D SET
 Q
 ;
L ; Lexmark laser specific code
 ;;BLBC^BOTTLE LABEL BARCODE^W $C(27),"(s1p10.4v4,12b4,12s24670T",$C(27),"&a90P",$C(27),"*p3650x1000Y"
 ;;PFDT^PHARMACY FILL DOCUMENT TRAILER^S PSOY=1015,PSOYI=45,PSOX=0,PSOFONT="F10",PSOBYI=50,PSOTFONT="F9",PSOBY=1280
 ;;EBLBC^END OF BOTTLE LABEL BARCODE^W $C(27),"(10U",$C(27),"(s1p10v0s0b16602T",$C(27),"&a0P",!
 ;;SBT^START OF BARCODE TEXT^S PSOY=PSOY+PSOYI W $C(27),"*p",PSOX,"x",PSOY,"Y",$C(27),"(s1p14.4v6,18b6,18s24670T"
 ;;
 N I,J,X,Y,Z,CC
 F I=1:1 S X=$P($T(L+I),";",3,999) Q:X=""  D SET
 Q
 ;
 ;-------------  CLEAN-UP EXISTING CONTROL CODE MULTIPLE  -------------
CLEAN(VFIEN) ;
 Q:$G(VFIEN)<1  S VFIEN=+VFIEN  Q:'$O(^%ZIS(2,VFIEN,55,0))
 N I,J,DA,DIC,DIE,DIK,VFDCC,VFDLAST
 ; first if update array has new control code to import then delete any
 ; existing control code entries
 I $D(VFDAX) D
 . K DA,DIK
 . S DA(1)=VFIEN,DIK=$P($NA(^%ZIS(2,VFIEN,55)),")")_","
 . S VFDCC="" F  S VFDCC=$O(VFDAX(VFDCC)) Q:VFDCC=""  D
 . . Q:$O(^%ZIS(2,VFIEN,55,"B",VFDCC,0))<1
 . . S DA=0 F  S DA=$O(^%ZIS(2,VFIEN,55,"B",VFDCC,DA)) Q:'DA  D ^DIK
 . . Q
 . Q
 ;
 ; clean up PSO bug that caused duplicate control codes to be filed
 K DA,DIC,DIE,DIK
 D MSG(3)
 S DA(1)=VFIEN,DIK=$P($NA(^%ZIS(2,VFIEN,55)),")")_","
 S VFDCC="" F  S VFDCC=$O(^%ZIS(2,VFIEN,55,"B",VFDCC)) Q:VFDCC=""  D
 . S I=$O(^%ZIS(2,VFIEN,55,"B",VFDCC,0)),I=$O(^(I)) Q:'I
 . S DA=$O(^%ZIS(2,VFIEN,55,"B",VFDCC," "),-1)
 . F  S DA=$O(^%ZIS(2,VFIEN,55,DA),-1) Q:'DA  D ^DIK
 . Q
 Q
 ;
CONT() ;
 N X,Y,DA,DIC,DIE,DIR,DIROUT,DIRUT,DR,DTOUT,DUOUT
 W !!?3,"Update Terminal Type "_$P(VFDIEN,U,2)_" with OP Control Codes",!!
 S DIR(0)="YOA",DIR("B")="NO",DIR("A")="  Are you sure? "
 D ^DIR I $D(DTOUT)!$D(DUOUT) S Y=-1
 Q Y=1
 ;
MSG(T) ;
 ;;Deleting all existing control codes
 ;;Creating Outpatient Pharmacy PCL5 Laser Printer Control Codes
 ;;Remove any duplicate control codes that may exist
 ;;Terminal Type updated with Outpatient Pharm PCL5 Laser codes
 ;;Problems encountered trying to update terminal type
 N I,J,X,Y
 S I=1+$O(VFDMSG(" "),-1) I I=1 D
 . S Y="Updating Control Codes for Terminal Type: "_$P(VFDIEN,U,2)
 . S I=3,VFDMSG(1)="   ",VFDMSG(2)=Y
 . Q
 S VFDMSG(I)=$TR($T(MSG+T),";"," ")
 Q
 ;
SET ;
 K Z S CC=$P(X,U),Z(2)=$P(X,U,2),Z(3)=$P(X,U,3,999)
 K:$D(VFDAX(CC)) VFDAX(CC)
 S VFDAX(CC,.01)=CC,VFDAX(CC,1)=Z(2),VFDAX(CC,2)=Z(3)
 Q
 ;
 ;----------------------- ASK FOR TERMINAL TYPE  ----------------------
TT() ; return ien^name or -1
 N X,Y,DIC,DTOUT,DUOUT
 S DIC=3.2,DIC(0)="QAEM",DIC("B")="P-HP-LASER"
 S DIC("S")="I $E(^(0),1,2)=""P-""" W ! D ^DIC
 S:$D(DTOUT)!$D(DUOUT) Y=-1
 Q Y
 ;
 ;---------------  ASK FOR HP OR LEXMARK LASER PRINTER  ---------------
TYPE() ;
 N X,Y,DA,DIC,DIE,DIR,DIROUT,DIRUT,DR,DTOUT,DUOUT
 S DIR(0)="SO^H:HP;L:Lexmark"
 S DIR("A")="Select Laser Printer type"
 S DIR("B")="HP"
 S X="   If your laser printer is not one of these two, then select HP"
 S DIR("A",1)=X,DIR("A",2)="   "
 W ! D ^DIR I $D(DTOUT)!$D(DUOUT)!(Y'="H"&(Y'="L")) S Y=-1
 Q Y
 ;
 ;----------  UPDATE CONTROL CODE MULTIPLE FOR TERMINAL TYPE  ---------
UPDATE(IEN) ;
 N I,J,X,Y,Z,DIERR,VFDA,VFDER,VIEN
 Q:'$D(VFDAX)  S VIEN=0,X=""
 F  S X=$O(VFDAX(X)) Q:X=""  D
 . S VIEN=1+VIEN,Y="+"_VIEN_","_IEN_"," M VFDA(3.2055,Y)=VFDAX(X)
 . Q
 D UPDATE^DIE(,"VFDA",,"VFDER")
 S X=4+($D(DIERR)>0) D MSG(X)
 Q
