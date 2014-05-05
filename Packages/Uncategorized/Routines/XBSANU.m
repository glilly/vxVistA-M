XBSANU ;IHS/ITSC/LAB/FJE;SANITIZE RPMS DATABASE; [ 01/29/2005  11:10 AM ]
 ;;1.0T3
 W !,"This routine sanitizes and deletes RPMS New Person file data.  To use you must type:  D START^XBSANU"
 W !,"For help and an explanation of this utility type D HELP^XBSANU",!!
 Q
START ;
 S (XBDUZ,XBDEL,XBPAT,XBPHR,XBBH,XBCHR,XBPOS,XB3PB,XBAR,XBLAB,XBMMDEL,XBAUDEL,XBNCDEL)=0
 K ^XTMP("SAN")
 S ^XTMP("SAN","LASTDFN")=0
 W !,"This routine will sanitize AND randomize the NEW PERSON file in the RPMS database."
 S DIR(0)="Y",DIR("A")="Do you want to convert the new person data?",DIR("B")="N" KILL DA D ^DIR KILL DIR
 S:Y=1 XBDUZ=1
 W !,"All failed fileman update data can be found in: ^XTMP(""SAN"",""DUZFAILURE"", GLOBAL"
 W !,"?? display usually means that there was a fileman update failure"
 W !,"If a hard error like an UNDEFINED occurs during the scrambling,"
 W !,"   you can restart at the next patient by typing:  RESTART^XBSANU    "
 W !,"When finished...don't forget to manually address the failures"
 W !,"D LIST^XBSANU will list the errors",!!
 W !!,"This routine is about to scramble the RPMS database."
 S DIR(0)="Y",DIR("A")="Last chance: Do you want your RPMS NEW PERSON file data SANITIZED?",DIR("B")="N" KILL DA D ^DIR KILL DIR
 Q:Y'=1
 D ^XBKVAR
 W !,"Collecting random names" D CLEAN
FJE ;
 I XBDUZ W !,"SCRAMBLING FILE 200" D DUZ
 S ^XTMP("SAN","DUZPROCESS","XBSAN")="FINISHED"
 W !,"FINISHED"
 D LIST
 D EOJ
 Q
 ;
EOJ ;
 D EN^XBVK("XB")
 K DFN,XBH,OTDFN,XBB,AUPNSEX,X,X2,XB3PB,XBAR,XBAUDEL
 K DA,DIE,DIK,DIR,DR,XBDUZSSN,I,XBA,XBADDR,XBADL1
 K XBBH,XBC,XBCHART,XBCHR,XBD,XBDAD,XBDEANUM,XBDEL,XBDFIRST,XBDLAST,XBDNAME
 K XBDOB,XBDUZ,XBFIRST,XBFNAME,XBH,XBLAB,XBLNAME,XBMDFN,XBMMDEL,XBMOM
 K XBNAME,XBNCDEL,XBNOK,XBNOKADL,XBP,XBPAT,XBPHN,XBPHR,XBPOS,XBS
 K XBSCR,XBSEX,XBSSN,XBTEN,XBVAL,XBVANUM,XBX,Y,Z
 W !,"If all data appears correct and you have chaecked failures, kill the ^XTMP(""SAN"") global",!!
 Q
 ;
CLEAN ;
 K ^XTMP("SAN","DLAST")
 K ^XTMP("SAN","DFIRST")
 K ^XTMP("SAN","PROCESS","DUZ")
 K ^XTMP("SAN","DUZFAILURE")
 D ^XBKVAR
 S (XBC(1),XBC(2))=0,XBX=1 F  S XBX=$O(^VA(200,XBX)) Q:+XBX=0  D
 .S XBNAME=$P($G(^VA(200,XBX,0)),U,1)
 .S XBLAST=$P(XBNAME,",",1) S:'$L(XBLAST) XBLAST="MOUSE" S:$L(XBLAST)<3 XBLAST=XBLAST_"AAA"
 .S XBFIRST=$P(XBNAME,",",2) S:'$L(XBFIRST) XBFIRST="MICKEY"_+XBX
 .S XBC(1)=XBC(1)+1,^XTMP("SAN","DLAST")=XBC(1),^XTMP("SAN","DLAST",XBC(1))=XBLAST
 .S XBC(2)=XBC(2)+1,^XTMP("SAN","DFIRST")=XBC(2),^XTMP("SAN","DFIRST",XBC(2))=XBFIRST
 Q
R S X2=$R(X) I X2=0 G R
 S X=X2
 Q
 ;
DUZ ;SCRAMBLES USER NAMES
 D ^XBFMK
 I '$D(^XTMP("SAN","LASTDUZ")) S ^XTMP("SAN","LASTDUZ")=1
 S XBX=+^XTMP("SAN","LASTDUZ") 
 F  S XBX=$O(^VA(200,XBX)) Q:+XBX=0  D
 .S DA=XBX,DIE=200,DR="53.2///@" D ^DIE I $D(Y) S ^XTMP("SAN","DUZFAILURE","DUZDEA",XBX)=""
 .D ^XBFMK
RESTART ;RESTARTS IF HARD FAILURE WITH DUZ (COMMON BECAUSE OF 3,6,16 PROBLEMS)
 S XBX=+^XTMP("SAN","LASTDUZ")
 F  S XBX=$O(^VA(200,XBX)) Q:+XBX=0  D
 .S ^XTMP("SAN","LASTDUZ")=XBX
 .S X=^XTMP("SAN","DLAST") D R S XBLAST=^XTMP("SAN","DLAST",X)
 .S X=^XTMP("SAN","DFIRST") D R S XBFIRST=^XTMP("SAN","DFIRST",X)
 .D DUZSSN
 .I XBDUZSSN S DA=XBX,DIE=200,DR=".01///"_XBLAST_","_XBFIRST_";9///"_XBDUZSSN D ^DIE I $D(Y) S ^XTMP("SAN","DUZFAILURE","DUZ IEN FAILURE",XBX)=""
 .I 'XBDUZSSN S DA=XBX,DIE=200,DR=".01///"_XBLAST_","_XBFIRST D ^DIE I $D(Y) S ^XTMP("SAN","DUZFAILURE","DUZ IEN FAILURE",XBX)=""
 .S DA=XBX,DIE=200,DR="1///"_$E(XBLAST,1,3)_";13///"_$E(XBLAST,1,8) D ^DIE I $D(Y) S ^XTMP("SAN","DUZFAILURE","DUZINITIALS",XBX)=""
 .S XBVANUM=1000000+XBX
 .S XBDEANUM=200000+XBX
 .S XBDEAIL=$E(XBLAST,1)
 .S XBDEAN=$E(XBDEANUM,1)+$E(XBDEANUM,3)+$E(XBDEANUM,5)+(2*($E(XBDEANUM,2)+$E(XBDEANUM,4)+$E(XBDEANUM,6)))
 .S XBDEAN=XBDEAN#10
 .S XBDEA="A"_XBDEAIL_XBDEANUM_XBDEAN
 .S DA=XBX,DIE=200,DR="53.2///"_XBDEA D ^DIE I $D(Y) S ^XTMP("SAN","DUZFAILURE","DUZDEA",XBX)=""
 .D ^XBFMK
 .S DA=XBX,DIE=200,DR="53.3///"_XBVANUM D ^DIE I $D(Y) S ^XTMP("SAN","DUZFAILURE","DUZVA",XBX)=""
 .D ^XBFMK
 S ^XTMP("SAN","DUZPROCESS","DUZ")="FINISHED"
 Q
DUZSSN ;CHANGES SSN FOR USER FILE
 S XBDUZSSN=$P($G(^VA(200,XBX,1)),"^",9)
 I XBDUZSSN D DUZSSNR S XBDUZSSN=XBSSN
 Q
DUZSSNR ;FIND RANDOM SSN
 F  S XBSSN=$R(999999999) Q:XBSSN>100000000&(XBSSN<800000000)
 I $D(^VA(200,"SSN",XBSSN)) G DUZSSNR
 Q
ALLSSN ;ADDS SSN TO EVERY DUZ
 D ^XBFMK
 S XBX=0 F  S XBX=$O(^VA(200,XBX)) Q:+XBX=0  D
 .Q:$L($P($G(^VA(200,XBX,0)),"^",9))
 .D SSNR
 .S DA=XBX,DIE=200,DR=".09///"_XBSSN D ^DIE K DIE,DA
 .D ^XBFMK
 S ^XTMP("SAN","DUZPROCESS","DUZ SSN-ALL")="FINISHED"
 Q
SSNR ;FIND RANDOM SSN
 F  S XBSSN=$R(999999999) Q:XBSSN>100000000&(XBSSN<800000000)
 I $D(^VA(200,"SSN",XBSSN)) G SSNR
 Q
 ;
LIST ;
 W !,"Listed below are the nodes and number of records that did not"
 W !,"update properly."  
 W !,"XTMP(""SAN"",""DUZFAILURE"") nodes:"
 S X="" F  S X=$O(^XTMP("SAN","DUZFAILURE",X)) Q:X=""  D
 .S (Y,Z)=0 F  S Y=$O(^XTMP("SAN","DUZFAILURE",X,Y)) Q:+Y=0  D
 ..S Z=Z+1
 .W !,"Failure:  "_X_"  "_Z
 W !,"FINISHED" 
LISTD ;
 W !,"Listed below are the processes completed."
 W !,"XTMP(""SAN"",""PROCESS"") nodes:"
 S X="" F  S X=$O(^XTMP("SAN","PROCESS",X)) Q:X=""  D
 .W !,"Process:  "_X
 W !,"FINISHED" Q 
STU ;SETS STUDENT NAMES
 K ^XTMP("SAN","DUZFAILURE","STU")
 K ^XTMP("SAN","DUZFAILURE","STUA")
STUA D ^XBFMK
 S XBX=50 F  S XBX=$O(^VA(200,XBX)) Q:+XBX>76  D
 .S XBLAST=$E("ABCDEFGHIJKLMNOPQRSTUVWXYZ",XBX-50,XBX-50)_"STUDENT"
 .S XBFIRST="USER"
 .S DA=XBX,DIE=200,DR=".01///"_XBLAST_","_XBFIRST D ^DIE I $D(Y) S ^XTMP("SAN","FAILURE","STU",XBX)=""
 .S DA=XBX,DIE=200,DR="1///"_$E(XBLAST,1,2)_"U;13///"_$E(XBLAST,1,8) D ^DIE I $D(Y) S ^XTMP("SAN","FAILURE","STUINITIALS",XBX)=""
 .S DA=XBX,DIE=200,DR="201///`29" D ^DIE I $D(Y) S ^XTMP("SAN","FAILURE","STUMENU",XBX)=""
 .D ^XBFMK
 W !,"FINISHED"
 Q
HELP ;
 W !,"Notes for sanitizing file 200."
 W !,"START^XBSANU will start the sanitizing.  The last names and first names"
 W !,"of file 200 are captured and then randomly combined to form a new name"
 W !,"If the user has a SSN regestered then that number is also ramdomized."
 W !,"The internal entry is added to 1000000 to create the VA number and"
 W !,"2000000 is added to make the DEA number"
 W !,"The first three letters of the last name make up the initials and"
 W !,"the first eight characters of the last name make up the nick name."
 W !,"To fix hard errors you should look at the following:"
 W !,"File 200 (^VA(200,IEN,0)) piece 16 points to file 16 (^DIC(16)).  If"
 W !,"^DIC(16,pointer,0) does not exist, you will get a hard error.  File 16"
 W !,"and file 6 (^DIC(6)) are generally dinumed and in file 16 the "
 W !,"^DIC(16,pointer,""A6"" and ""A3"" point to file 6 and 3 (^DIC(3))"
 W !,"respectfully.  If either is missing you will get an error.  File 3's IEN"
 W !,"generally is dinumed to file 200.",!!
 W !,"You can run this utility over and over without problems.  The result is"
 W !,"randomized again.  User IEN 1 remains as ADAM,ADAM and is unchanged" 
 W !,"LIST^XBSANU will list the errors found"
 W !,"ALLSSN^XBSANU will add a random SSN to all file 200 users"
 W !,"STU^XBSANU will create 26 student accounts starting with ASTUDENT,USER"
 W !,"and ending with ZSTUDENT,USER for IENS 51-76."
 Q
