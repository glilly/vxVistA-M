XBFLD ; DICTIONARY LISTING  [ 02/15/95  12:25 PM ]
 ;;2.6;IHS/VA UTILITIES;;JUN 28, 1993
 ;
 ; This routine lists dictionaries which may be selected individually
 ; or by a range of dictionary numbers.
 ;
 ; This routine requires the 89 MUMPS Standard, FileMan Version 17.7
 ; or greater, Kernel Version 6 or greater, and the following routines
 ; must exist in the UCI in which this routine is running:
 ;
 ;  XBKVAR, XBSFGBL
 ;
START ;
 D LOOP ;                  List files until user says stop
 D EOJ ;                   Clean up
 Q
 ;
LOOP ; LIST FILES UNTIL USER SAYS STOP
 NEW QFLG
 W !,"^XBFLD - This routine lists FileMan dictionaries."
 F  D INIT Q:QFLG  D LIST W ! X ^%ZIS("C") Q:QFLG
 Q
 ;
LIST ; LIST RANGE OF FILES
 NEW COMP,FILE,FLD,LF,NAME,PC,PG,PSUB,PSUBOLD,SUBFILE,SUB,TAB,TYPE,WPC,WPSUB
 S QFLG=0
 F FILE=0:0 S FILE=$O(^UTILITY("XBDSET",$J,FILE)) Q:FILE=""  D FILE Q:QFLG
 Q
 ;
FILE ; LIST ONE FILE
 S (COMP,LF,PG,TAB)=0,SUB="D0,",PSUBOLD=""
 D HEADING
 D FIELDS
 Q:QFLG
 D PAUSE
 Q
 ;
FIELDS ; LIST ALL FIELDS IN ONE FILE/SUBFILE (CALLED RECURSIVELY)
 F FLD=0:0 S FLD=$O(^DD(FILE,FLD)) Q:FLD'=+FLD  D FIELD Q:QFLG
 Q
 ;
FIELD ; LIST ONE FIELD
 S (NAME,PC,PSUB,TYPE)=""
 S X=^DD(FILE,FLD,0)
 S NAME=$P(X,U,1)
 S Y=$P(X,U,2)
 S TYPE=$S(+Y:"",Y["C":"C",Y["F":"F",Y["N":"N",Y["P":"P",Y["S":"S",Y["V":"V",Y["K":"K",Y["W":"W",Y["D":"D",1:"?")
 I TYPE="C" D COMPUTED Q
 I COMP S COMP=0 D WRITELF ; Extra lf after computed fields
 I TYPE="" D MULTIPLE Q
 S Y=$P(X,U,4)
 S PSUB=SUB_$S($P(Y,";",1)=+$P(Y,";",1):$P(Y,";",1),1:""""_$P(Y,";",1)_"""")
 S PC=$S(TYPE="K":" ",1:$P(Y,";",2)) ; MUMPS field has no piece
 D WRITE
 Q
 ;
COMPUTED ; COMPUTED FIELD
 ; The variable COMP prevents multiple lfs between adjacent
 ; computed fields.
 ;
 D:'COMP WRITELF
 S PSUB="COMPUTED",TYPE="",COMP=1
 S PSUB=PSUB_$S(Y["B":" (BOOLEAN)",Y["D":" (DATE)",1:"")
 D WRITE
 Q
 ;
MULTIPLE ; LIST MULTIPLE, THEN FIELDS IN SUBFILE
 S NAME=NAME_"  ("_+Y_")",SUBFILE=+Y
 D WRITELF,WRITE
 Q:QFLG
 NEW FILE,FLD,SUB
 S FILE=SUBFILE
 D ^XBSFGBL(FILE,.SUB,2) S SUB="D0"_$P(SUB,"D0",2),SUB=$P(SUB,")",1)
 S TAB=TAB+2
 D FIELDS ;        Recurse
 S TAB=TAB-2
 Q:QFLG
 D WRITELF
 Q
 ;
WRITE ; WRITE ONE LINE
 S LF=0
 D PAGE:$Y>(IOSL-3)
 Q:QFLG
 S WPSUB=$S(FLD=.001:"",PSUB]""&(PSUB=PSUBOLD):"  """,1:PSUB)
 S WPC=$S(PC:$J(PC,5,0),1:PC) ;S:$E(WPC)="E" WPC=$E("       ",1,7-$L(WPC))_WPC
 W !,?TAB,FLD,?13+TAB,$S(TYPE="":NAME,1:$E(NAME,1,31-TAB)),?46,$E(WPSUB,1,21),?68,WPC,?77,TYPE
 I TYPE'="" I $L(NAME)>(31-TAB)!($L(WPSUB)>25) W !,?13+TAB,$E(NAME,32-TAB,$L(NAME)),?46,$E(WPSUB,22,$L(WPSUB))
 ;S S="" S:TAB $P(S," ",TAB)=" "
 ;W !,S_FLD,?13,S_NAME,?42,$S(FLD=.001:"",PSUB]""&(PSUB=PSUBOLD):"  """,1:PSUB),?70,$S(PC:$J(PC,2,0),1:""),?77,TYPE
 S PSUBOLD=PSUB
 Q
 ;
WRITELF ; WRITE ONE LINE FEED
 ; The variable LF prevents multiple lfs when backing out of
 ; deep recursion.
 ;
 Q:LF
 I $Y>2,$Y'>(IOSL-3) W ! S LF=1
 Q
 ;
HEADING ; DICTIONARY HEADERS
 NEW HR,MIN,TITLE,TM,TME,UCI
 S PG=1
 W @IOF
 D HEADING2
 W ?80-$L("FILE: "_$P(^DIC(FILE,0),"^",1))\2,"FILE: ",$P(^DIC(FILE,0),"^",1),!,?80-$L("GLOBAL: "_^DIC(FILE,0,"GL"))\2,"GLOBAL: ",^DIC(FILE,0,"GL"),!,?80-$L("FILE #: "_FILE)\2,"FILE #: ",FILE,!!
 D PAGE
 Q
 ;
HEADING2 ; HARD COPY HEADERS
 I IO=IO(0),$E(IOST,1,2)="C-" Q
 S TITLE="I.H.S.  DICTIONARY FIELDS",TM=$P($H,",",2),HR=TM\3600,MIN=TM#3600\60 S:MIN<10 MIN="0"_MIN S TME=HR_":"_MIN
 W TME,?80-$L(TITLE)\2,TITLE,?72,"page ",PG,!,?80-$L(^DD("SITE"))\2,^DD("SITE"),!
 X ^%ZOSF("UCI") S UCI="UCI: "_$P(Y,",",1) W ?80-$L(UCI)\2,UCI
 I '$D(DT) S %DT="",X="T" D ^%DT S DT=Y
 S Y=DT X ^DD("DD") W !!,?80-$L("as of "_Y)\2,"as of ",Y,!!
 Q
 ;
PAGE ; PAGE HEADERS
 D:PG>1 PAUSE
 Q:QFLG
 I PG>1 W:$D(IOF) @IOF
 S PG=PG+1
 S X="",$P(X,"=",79)="=" W "FIELD #",?13,"FIELD NAME",?46,"SUBSCRIPT",?69,"PIECE",?75,"TYPE",!,X,! S X=""
 S PSUBOLD=""
 Q
 ;
PAUSE ; GIVE USER A CHANCE TO SEE LAST PAGE AND QUIT
 I IO=IO(0),$E(IOST,1,2)="C-" S DIR(0)="E" D ^DIR K DIR S:$D(DIRUT)!($D(DUOUT)) QFLG=1 K DIRUT,DUOUT
 Q
 ;
INIT ; INITIALIZATION
 S XBFLDP=$S($D(XBFLDP):1,1:0)
 S:XBFLDP XBDSND=1
 D ^XBFLD2 ;       Get device and files to list
 Q
 ;
EN ; EXTERNAL ENTRY POINT
 ; To use this entry point ^UTILITY("XBDSET",$J, must contain
 ; the list of dictionaries.  All device variables must be set
 ; and, if appropriate, the U IO executed prior to the call.
 ; It is the callers responsibility to close the device.
 ;
 NEW QFLG
 I $D(IO)#2,$D(IO(0))#2,$D(IOF)#2,$D(IOSL)#2 D LIST
 D EOJ
 Q
 ;
EOJ ; END OF JOB
 K XBFLDP
 K ^UTILITY("XBDSET",$J)
 K DIR,DIRUT,DTOUT,DUOUT,POP,S,X,Y
 I $D(ZTQUEUED) S ZTREQ="@" Q
 I $D(ZTSK),ZTSK K ^%ZTSK(ZTSK) ; ***** For old Kernel *****
 Q
