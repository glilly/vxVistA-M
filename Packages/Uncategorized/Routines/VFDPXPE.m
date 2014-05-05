VFDPXPE ;CFS - Main Routine for Data Capture ;05/21/2013
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**1**;08 Aug 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;+This routine is responsible for:
 ;+
 ;+LOCAL VARIABLE LIST:
 ;+ PXFG     = Stop flag with duplicate of delete
 ;+ PXKAFT   = After node
 ;+ PXKBEF   = Before node
 ;+ PXKAV    = Pieces from the after node
 ;+ PXKBV    = Pieces from the before node
 ;+ PXKERROR = Set when there is an error
 ;+ PXKFGAD  = ADD flag
 ;+ PXKFGED  = EDIT flag
 ;+ PXKFGDE  = DELETE flag
 ;+ PXKSEQ   = Sequence number in PXK tmp global
 ;+ PXKCAT   = Category of entry (CPT,MSR,VST...)
 ;+ PXKREF   = Root of temp global
 ;+ PXKPIEN  = IEN of v file or the visit file
 ;+ PXKREF   = The original reference we are ordering off of
 ;+ PXKRT    = name of the node in the v file
 ;+ PXKRTN   = routine name for the file routine
 ;+ PXKSOR   = the data source for this entry
 ;+ PXKSUB   = the subscript the data is located on the v file
 ;+ PXKVST   = the visit IEN
 ;+ PXKDUZ   = the DUZ of the user
 ;+ *PXKHLR* = A variable set by calling routine so that duplicate
 ;+            PXKERROR messages aren't produced.
 ;
 W !,"This is not an entry point" 
 Q
 ;
 ;+Main entry point to read ^TMP("PXK", Global
 ;+ Partial ^TMP Global Structure when called:
 ;+ ^TMP("PXK",$J,"SOR") = Source ien
 ;+
 ;+ ^TMP("PXK",$J,"VFDPXSN4",1,0,"BEFORE") = the 0-node of the visit file
 ;+ ^TMP("PXK",$J,"VFDPXSN4",1,0,"AFTER") = 0-node after changes.
 ;+ ^TMP("PXK",$J,"VFDPXSN4",counter,"IEN") = ""
 ;+
VFDLOOP(PXKREF,PXKCAT,PXKSOR,PXKERROR) ;--$ORDER Through the ^TMP("PXK", global setting variables
 ; PXKREF   = ^TMP(""PXK"",$J)
 ; PXKCAT   = Category from CPRS such as 'VFDPXSN4' for SnoMed codes.
 ;            PXKCAT should match the routine that has data about the ^DD
 ;            with the first 5 characters being 'VFDPX' for vxVistA
 ;            Patient Encounter routines.
 ; PXKSOR   = Package Source
 ; PXKERROR = Error array
 ;
 N PXKAFT,PXKAV,PXKBV,PXKBEF,PXDFG,PXFG,PXKFGAD,PXKFGDE,PXKFGED
 N PXKPIEN,PXKRTN,PXKSEQ,PXKSUB,X
 S PXKRTN=PXKCAT  ;Generic variable for vxVistA description name.
 S X=PXKRTN X ^%ZOSF("TEST") Q:'$T
 S PXKSEQ=0 F  S PXKSEQ=$O(@PXKREF@(PXKCAT,PXKSEQ)) Q:'PXKSEQ  D
 .K PXKAV,PXKBV
 .S PXKPIEN=$G(@PXKREF@(PXKCAT,PXKSEQ,"IEN"))
 .S (PXDFG,PXFG,PXKFGAD,PXKFGDE,PXKFGED)=0
 .S PXKSUB="" F  S PXKSUB=$O(@PXKREF@(PXKCAT,PXKSEQ,PXKSUB)) Q:PXKSUB["IEN"  Q:PXFG=1  Q:PXDFG=1  D
 ..;Set up After array (Data sent from CPRS).
 ..S PXKAFT(PXKSUB)=$G(@PXKREF@(PXKCAT,PXKSEQ,PXKSUB,"AFTER"))
 ..;Set up Before array (Data in V file).
 ..S PXKBEF(PXKSUB)=$G(@PXKREF@(PXKCAT,PXKSEQ,PXKSUB,"BEFORE"))
 ..D LOOP^VFDPXPE1(.PXKAV,.PXKBV) S PXDFG=0 I $G(PXKAV(0,1))["@"!('$D(PXKAV(0,1))) D
 ...S PXKAFT(PXKSUB)="" K PXKAV(0) S PXDFG=1
 .I '$D(PXKAV),$D(PXKBV) S PXKFGDE=1,PXKFVDLM="" D DELETE(.PXFG)
 .I $D(PXKAV),'$D(PXKBV) S PXKFGAD=1 D ADD(.PXKAV,.PXFG)
 .I 'PXKFGAD,'PXKFGDE S PXKFGED=1 D EDIT(.PXKAV,.PXKBV,.PXFG,.PXKPIEN)
 .D SPEC^VFDPXPE2
 .K PXKAFT,PXKBEF
 Q
 ;
ADD(PXKAV,PXFG) ;
 N PXKSORR
 I '$D(PXKAV) Q
 D ERROR^VFDPXPE1(.PXKAV,.PXKERROR)
 I $D(PXKERROR(PXKCAT,PXKSEQ)) S PXFG=1
 D:'PXFG DUP^VFDPXPE1(.PXFG)
 S PXKSORR=PXKSOR_"-A "_PXKDUZ
 D:'PXKPIEN FILE^VFDPXPE1(PXKSORR,.PXKPIEN,.PXKAV)  ;Add to the V File.
 D EN1^VFDPXMAS
 Q
 ;
EDIT(PXKAV,PXKBV,PXFG,PXKPIEN) ;
 N DA,PXKRT,PXKSORR
 D ERROR^VFDPXPE1(.PXKAV,.PXKERROR),CLEAN^VFDPXPE1(.PXKAV,.PXKBV)
 I '$D(PXKAV) Q  ;No updating required. All data is the same as before.
 S DA=PXKPIEN
 S PXKRT=$P($T(GLOBAL^@PXKRTN),";;",2)_DA_")" Q:'$D(@PXKRT)
 D DUP^VFDPXPE1(.PXFG)
 Q:PXFG=1
 S PXKSORR=PXKSOR_"-E "_PXKDUZ  
 D DRDIE^VFDPXPE1(PXKSORR,.PXKAV)  ;Do the update.
 D EN1^VFDPXMAS
 Q
 ;
DELETE(PXFG) ;
 N PXKRT
 S PXKRT=$P($T(GLOBAL^@PXKRTN),";;",2)_PXKPIEN_")" 
 I $D(@PXKRT) D DELETE^VFDPXPE1(PXKPIEN) 
 S PXFG=1 K PXKRT
 D EN1^VFDPXMAS 
 Q
 ;-----------------SUBROUTINES-----------------------
ERR ;
 ;+  PXANOT   (optional) set to 1 if errors are to be displayed to the screen should only be set while writing and debugging the initial code.
 ;
 ;
 I '$D(PXADI("DIALOG")) Q
 N NODE,SCREEN
 S PXAERR(1)=$G(PXADATA),PXAERR(2)=$G(PXAPKG),PXAERR(3)=$G(PXASOURC)
 S PXAERR(4)=$G(PXAVISIT),PXAERR(5)=$G(PXAUSER)_"  "_$P($G(^VA(200,PXAUSER,0)),"^",1)
 ;I $G(PXANOT)=1 D EXTERNAL
 D INTERNAL
 D ARRAY
 K PXADI("DIALOG")
 Q
 ;
EXTERNAL ;---SEND ERRORS TO SCREEN
 W !,"-----------------------------------------------------------------"
 D BLD^DIALOG($G(PXADI("DIALOG")),.PXAERR,"","SCREEN","F")
 D MSG^DIALOG("ESW","",50,10,"SCREEN")
 ;
 Q
INTERNAL ;---SET ERRORS TO GLOBAL ARRAY
 S NODE=PXADATA
 D BLD^DIALOG($G(PXADI("DIALOG")),.PXAERR,.PXAERR,NODE,"F")
 S NODE=$NA(@PXADATA@("DIERR",$J)) D MSG^DIALOG("ESW","",50,10,NODE)
 Q
  ;---------------------SUBROUTINE------------------------------
ARRAY ;--SET ERRORS AND WARNINGS INTO AN ARRAY TO RETURN TO CALLER
 I PXADI("DIALOG")=8390001.001 D
 .S PXASUB=PXASUB+1
 .S PXAPROB($J,PXASUB,"ERROR1",PXAERR(7),PXAERR(9),PXAK)=$G(PXAERR(12))
 I PXADI("DIALOG")=8390001.002 D
 .S PXASUB=PXASUB+1
 .S PXAPROB($J,PXASUB,"WARNING2",PXAERR(7),PXAERR(9),PXAK)=$G(PXAERR(12))
 I PXADI("DIALOG")=8390001.003 D
 .S PXASUB=PXASUB+1
 .S PXAPROB($J,PXASUB,"WARNING3","ENCOUNTER",1,"SC")=$G(PXAERR("6W"))
 .S PXAPROB($J,PXASUB,"WARNING3","ENCOUNTER",1,"AO")=$G(PXAERR("7W"))
 .S PXAPROB($J,PXASUB,"WARNING3","ENCOUNTER",1,"IR")=$G(PXAERR("8W"))
 .S PXAPROB($J,PXASUB,"WARNING3","ENCOUNTER",1,"EC")=$G(PXAERR("9W"))
 .S PXAPROB($J,PXASUB,"WARNING3","ENCOUNTER",1,"MST")=$G(PXAERR("10W"))
 .S PXAPROB($J,PXASUB,"WARNING3","ENCOUNTER",1,"HNC")=$G(PXAERR("17W"))
 .S PXAPROB($J,PXASUB,"WARNING3","ENCOUNTER",1,"CV")=$G(PXAERR("18W"))
 .S PXAPROB($J,PXASUB,"WARNING3","ENCOUNTER",1,"SHAD")=$G(PXAERR("19W"))
 I PXADI("DIALOG")=8390001.004 D
 .S PXASUB=PXASUB+1
 .S PXAPROB($J,PXASUB,"ERROR4","PX/DL",PXAK)=$G(PXAERR("PL1"))
 Q
PROVNARR(PXPNAR,PXFILE,PXCLEX) ;Convert external Provider Narrative to internal.
 ;Input:
 ;  PXPNAR    Is the text of the provider narrative.
 ;  PXFILE  Is the file that the returned pointer will be stored in.
 ;              If a new entry is created then this tells the context
 ;              that it was created under by the file using it.
 ;  PXCLEX  Is and optional pointer to the Lexicon for this narrative.
 ;
 ;Returns:
 ;  Pointer to the provider narrative file ^ narrative
 ;  or pointer to the provider narrative file ^ narrative ^1
 ;    where 1 indicates that the entry has just been added
 ;  or -1 if was unsuccessful.
 ;
 N DIC,Y,DLAYGO,DD,DO,DA
 S DIC="^AUTNPOV(",DIC(0)="L",DLAYGO=9999999.27
 S (DA,Y)=0
 S X=$E(PXPNAR,1,245)
 Q:X="" -1
 L +^AUTNPOV(0):60
 E  W !,"The Provider Narrative is LOCKED try again." Q -1
 F  S DA=$O(^AUTNPOV("B",$E(X,1,30),DA)) Q:DA'>0  I $P(^AUTNPOV(DA,0),"^")=X S Y=DA_"^"_X Q
 I '(+Y) D
 . K DA,Y
 . D FILE^DICN
 . I +Y>0,($G(PXCLEX)!$G(PXFILE)) S ^AUTNPOV(+Y,757)=$G(PXCLEX)_"^"_$G(PXFILE)
 L -^AUTNPOV(0)
 Q $S(+Y>0:Y,1:-1)
 ;
