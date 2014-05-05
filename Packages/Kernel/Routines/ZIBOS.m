ZIBOS ;IHS/ITSC/TPF - PERFORM HOST OS FUCTIONS VIA $ZF CALL FOR CACHE ONLY [ 03/18/2005  10:48 AM ]
 NEW
 S U="^"
 S OPSYS=$$VERSION^%ZOSV(1)   ;e.g. Cache for Windows NT
 ;                                  Cache for UNIX
 I OPSYS'[("Cache") W !,"This utility for Cache only!)" Q 
 S WINDOWS=$S(OPSYS["Windows":1,1:0)
 I WINDOWS S DEFDIR="E:\FTP_FILES\",TEMPFILE="C:\TEMP\XB_TEMPFILE.TXT"
 E  S DEFDIR="/usr/spool/uucppublic/",TEMPFILE="/usr/spool/uucppublic/xbtempfile.txt"
 S X=$$SETDIR(DEFDIR)
 ;S $ZT="ERR^ZIBOS"
O S MENU="TXT",PREV="EXIT" G MENU
EXIT ;
 Q
ERR ;
 I $F($ZE,"<INRPT>") U 0 W !!,"...Aborted." D EXIT ZQ 0
 ZQ 1
MENU ;DISPLAY MENU
 W !!,"ISTC Host File Operations Utility"
 W !,"for Cache on Windows and Unix Platforms"
 D CURDIR  ;DISPLAY CURRENT DIRECTORY
 W !!,"Available options:",! F I=0:1 S T=$P($T(@MENU+I),";",2) Q:T="*"  W !?4,I+1," - ",T
OPT W !!,"Select option: " R OPT G:OPT="^Q" EXIT
 I OPT=""!(OPT="^") G:MENU="TXT" EXIT S MENU="TXT" G MENU
 I OPT="?" DO  G MENU
 .W !!,"Select option by specifying the option number of supplying enough"
 .W !?4,"enough characters to uniquely identify the option."
 .W !,"To get help information specific to an option, enter a '?' followed"
 .W !?4,"by the option number."
 .W !,"Enter '^', '^Q', or <RETURN> to exit this utility."
 I OPT?1.A F F=0:1 S T=$T(@MENU+F) Q:T["*"  I $ZB(OPT,"_",1)=$E($ZB($P(T,";",2),"_",1),1,$L(OPT)) S OPT=F+1 W $E($P(T,";",2),$L(OPT)+1,99) Q
 S F=OPT'?1.N!(OPT<1)!(OPT>I) I F W *7,! W !,"Enter the option number to select an option, or",!,"enter enough characters to identify the option." G MENU
 S T=$T(@MENU+OPT-1) I $P(T,";",4)="" D @($P(T,";",3)) G MENU
 S MENU=$P(T,";",4) G MENU
TXT ;Directory Functions;MENU;TXT1
 ;Show Cache Platform;O2
 ;Available Disk Space;O3
 ;Change Default Path;O4
 ;File Functions;MENU;TXT2
 ;*
TXT1 ;Create Directory;O11
 ;Delete Directory;O12
 ;List Directory;O13
 ;List available Drives;O14
 ;*
TXT2 ;Delete File;O51
 ;Rename/Move File;O52
 ;Copy File;O54
 ;Set File Attributes;O53
 ;List File;LIST("")
 ;*
 ;DISPLAY CURRENT DIRECTORY
CURDIR W !!,"Your current working directory is ",$$GETDIR Q
 ;DISPLAY PLATFORM
O2 W !!,"Currently running under "_$ZV
 G HIT
 ;DISPLAY DISK SPACE
O3 ;S X=$ZF(-1,$S(WINDOWS:"dir "_%X,1:"ll "_C:\)_" > "_TEMPFILE)
 ;D LIST(TEMPFILE)
 W !!,"To get the available space on a drive"
 W !,"use option 1 then option 3 and enter"
 W !,"c:\ (d:\,e:\) as the directory"
 G HIT
 ;DISPLAY/CHANGE DEFAULT DIR OR WORKING DIRECTORY
O4 W !!,"Current working directory is, ",$$GETDIR
 W !!,"Change working directory to: " R %X
 Q:(%X[U)!(%X="")
 I $$ISCOLON(%X),WINDOWS G O4A
 I '$$ISSLASH(%X),%X'="",'$$ISCOLON S %X=$$GETDIR_%X
 E  S %X=$E($$GETDIR,1,$L($$GETDIR)-1)
O4A I '$$ISFILE(%X) W !!,"Directory does not exist!",!,"Create the directory then choose it as the default." G O4
 I $$DIROFF(%X) W !!,"Permission denied! Try again." G O4
 S $ZT="DIRERR"
 I $$SETDIR(%X) W !!,"Working/default directory changed to, ",%X S DEFDIR=%X S $ZT="ERR^ZIBOS" G HIT
DIRERR ;
 W !!,"Problem with directory entered"
 W !!,"Working/default directory still ",$ZU(168)
 G HIT
 ;
 ;CREATE DIRECTORY
O11 ;
 W !!,"Create what directory <"_$$GETDIR_">: " R %X
 Q:(%X[U)
 I %X="" S %X=$E($$GETDIR,1,$L($$GETDIR)-1) G O11A
 I $$ISCOLON(%X),WINDOWS G O11A
 I '$$ISSLASH(%X) S %X=$$GETDIR_%X
 E  S %X=$E($$GETDIR,1,$L($$GETDIR)-1)
O11A I $$ISFILE(%X) W !!,"Directory ",%X," already exists!" G O11
 I $$WDIROFF(%X) W !!,"Input contains directory which is off limits! Try again." G O11
 I $$MKDIR(%X) W !!,"Directory ",%X," created!" G HIT
 W !!,"Directory could not be created!! Try again"
 G O11
 ;DELETE DIRECTORY
O12 ;
 W !!,"Delete what directory <"_$$GETDIR_">: " R %X
 Q:(%X[U)
 I %X="" S %X=$E($$GETDIR,1,$L($$GETDIR)-1) G O12A
 I $$ISCOLON(%X),WINDOWS G O12A
 I '$$ISSLASH(%X) S %X=$$GETDIR_%X
 E  S %X=$E($$GETDIR,1,$L($$GETDIR)-1)
O12A I '$$ISFILE(%X) W !!,"Directory ",%X," does not exist!" G O12
 I $$DIROFF(%X) W !!,"Permission denied! Try another directory." G O12
 W !!,"Delete Directory ",%X,!!,"Are you sure (Y/N)?" R %YN
 I %YN'="YES" W !!,"You must type ""YES"" for the delete to be confirmed!" G O12
 I $$DELDIR(%X) W !!,"Directory ",%X," deleted!" G HIT
 W !!,"Directory could not be deleted!! Try again"
 G HIT
 ;GET DIR LISTING
O13 ;
 W !!,"List directory <",$$GETDIR,">: " R %X
 D O131(%X,0)
 Q
 ;CALLED FROM 013 AND O14
 ;DRIVELST MEANS CALLED FROM OPTION TO LIST AVAILABEL DRIVES
O131(%X,DRIVELST) Q:(%X[U)
 I %X="" S %X=$E($$GETDIR,1,$L($$GETDIR)-1) G O13A
 I $$ISSTAR(%X) G O13A1
 I $$ISCOLON(%X),WINDOWS G O13A
 I '$$ISSLASH(%X) S %X=$$GETDIR_%X
 E  S %X=$E($$GETDIR,1,$L($$GETDIR)-1)
O13A I '$$ISFILE(%X) W !!,"Directory ",%X," does not exist!" G HIT
O13A1 I $$RDIROFF(%X) W !!,"Permission denied! Try again." G O13
 S X=$ZF(-1,$S(WINDOWS:"dir "_%X,1:"ll "_%X)_" > "_TEMPFILE)
 I X'=0 W !,"Problem creating temp file!" Q
 D LIST(TEMPFILE)
 I $$DELFILE(TEMPFILE) W !!,"Deleting temporary list file"
 Q:DRIVELST
 G O13
 ;
 ;LIST AVAILABLE DRIVES
O14 ;
 I 'WINDOWS W !!,"Only for Windows systems!" Q
 N LETTER,DEC,DRIVE
 F DEC=65:1:90 S LETTER=$C(DEC) D
 .S DRIVE=LETTER_":\"
 .I $$ISFILE(DRIVE),'$$DIROFF(DRIVE) W !,"Drive ",DRIVE," is available"
 .;I $$ISFILE(DRIVE),'$$DIROFF(DRIVE) W !,"Drive ",DRIVE," is available" D O131(DRIVE,1) G HIT  ;USE TO LIST DIRECTORY
 G HIT
 Q
 ;DELETE FILE
O51 W !!,"Delete what file <"_$$GETDIR_">: " R %X
 Q:(%X[U)
 I %X="" S %X=$E($$GETDIR,1,$L($$GETDIR)-1) G O15A
 I $$ISCOLON(%X),WINDOWS G O15A
 I '$$ISSLASH(%X) S %X=$$GETDIR_%X
 E  S %X=$E($$GETDIR,1,$L($$GETDIR)-1)
O15A I '$$ISFILE(%X) W !!,"File "_%X_" does NOT exist" G O51
 I $$DDIROFF(%X) W !!,"Permission denied! Try again." G O51
 I $$DELFILE(%X) W %X,"  ...Deleted."
 G HIT
 ;RENAME A FILE
O52 W !!,"Rename/Move what file <"_$$GETDIR_">: " R %X
 Q:(%X[U)
 I %X="" S %X=$E($$GETDIR,1,$L($$GETDIR)-1) G O152A
 I $$ISCOLON(%X),WINDOWS G O152A
 I '$$ISSLASH(%X) S %X=$$GETDIR_%X
 E  S %X=$E($$GETDIR,1,$L($$GETDIR)-1)
O152A I '$$ISFILE(%X) W !!,"File "_%X_" does NOT exist" G O52
 I $$RDIROFF(%X) W !!,"Permission denied! Try again." G O52
O521 W !!,"New name/location <"_$$GETDIR_">: " R %NX
 G:(%NX[U) O52
 I %X="" S %X=$E($$GETDIR,1,$L($$GETDIR)-1) G O521A
 I $$ISCOLON(%X),WINDOWS G O521A
 I '$$ISSLASH(%NX) S %NX=$$GETDIR_%NX
 E  S %X=$E($$GETDIR,1,$L($$GETDIR)-1)
O521A I $$ISFILE(%NX) W !!,"New file "_%X_" already  exists" G O521
 I $$WDIROFF(%NX) W !!,"Permission denied! Try again." G O521
 ;W !!,"Renaming/Moving ",%X," to ",%NX
 I $$MVRENAME(%X,%NX) W !!,"File ",%X," has been Renamed/Moved to ",%NX G HIT
 E  W !!,"Problem encountered in Rename/Moving"
 G HIT
 ;
 ;SET FILE ATTRIBUTES
O53 ;
 W !!,"Option inactive at this time!" R %X
 G HIT
 ;
 ;COPY FILE
O54 ;
 W !!,"Enter file to copy <"_$$GETDIR_"> :" R %X
 Q:(%X[U)!(%X="")
 ;I %X="" S %X=$E($$GETDIR,1,$L($$GETDIR)-1) G O154A
 I $$ISCOLON(%X),WINDOWS G O154A
 I '$$ISSLASH(%X) S %X=$$GETDIR_%X
 E  S %X=$E($$GETDIR,1,$L($$GETDIR)-1)
O154A I '$$ISFILE(%X) W !!,"File ",%X," does not exist!" G O54
 I $$RDIROFF(%X) W !!,"Permission denied! Try again." G O54
O541 W !!,"Enter directory to copy file to <"_$$GETDIR_">: " R %D
 G:%D[U O54
 I %D["." W !!,"Do not enter a file name!" G O541
 I %D="" S %D=$E($$GETDIR,1,$L($$GETDIR)-1) G O541A
 I $$ISCOLON(%D),WINDOWS G O541A
 I '$$ISSLASH(%D) S %D=$$GETDIR_%D
O541A I %D=$E(%X,1,$L(%D)) W !!,"Copy cannot be made into same directory!" G O541
 ;
 I $$ISFILE(%D_$P(%X,$S(WINDOWS:"\",1:"/"),$L(%X,$S(WINDOWS:"\",1:"/")))) W !!,"File already exists in destination directory!" G O541
 I '$$ISFILE(%D) W !!,"Directory ",%X," does not exist!" G O541
 I $$WDIROFF(%X) W !!,"Permission denied! Try again." G O541
 I $$COPYFILE(%X,%D) W !!,"Copy of ",%X," placed in ",%D G O541
 W !!,"Problem copying ",%X
 ;W !!,%D_$P(%X,$S(WINDOWS:"\",1:"/"),$L(%X,$S(WINDOWS:"\",1:"/")))
 
HIT ;
 Q:$D(INTERNAL)  R !!,"Press any key to continue",*I
 Q
HIT1 ;
 R !!,"Enter <RETURN> to continue, '^' to quit",*%I F %J=$X:-1:0 W $C(8,32,8)
 Q
 ;IS THERE A SLASH IN THE INPUT (IF NOT THEY ARE ENTERING A FILENAME
ISSLASH(X) ;
 Q X[("\")!(X["/")
 ;
 ;IS THERE A COLON IN THE INPUT (IF SO THEY ARE ENTERING A WHOLE NEW PATH FOR WINDOWS)
ISCOLON(DIR) ;
 Q DIR[(":")
 ;
 ;IS THERE A ASTERISK IN THE INPUT (IF SO THIS IS A WILDCARD)
ISSTAR(DIR) 
 Q DIR[("*")
 ;
 ;THIS IS FOR READING A FILE AND LISTING TO THE SCREEN
LIST(FNAME) 
REDO ;
 S %X=FNAME
 I FNAME="" S ABORT=0 D  Q:ABORT=1  G:ABORT=2 REDO
 .W !!,"Enter filename: "_$$GETDIR R %X
 .I (%X[U) S ABORT=1 Q
 .I %X="" W !!,"Enter filename or ""^"" to exit" S ABORT=2 Q
 .I $$ISCOLON(%X),WINDOWS G REDOA
 .I '$$ISSLASH(%X) S %X=$$GETDIR_%X
 .E  S %X=$E($$GETDIR,1,$L($$GETDIR)-1)
REDOA .I '$$ISFILE(%X) W !!,"File does not exist!" S ABORT=2 Q
 S FNAME=$P(%X,$S(WINDOWS:"\",1:"/"),$L(%X,$S(WINDOWS:"\",1:"/")))
 S DIR=$P(%X,$S(WINDOWS:"\",1:"/"),1,$L(%X,$S(WINDOWS:"\",1:"/"))-1)_$S(WINDOWS:"\",1:"/")
 ;W !!,"FILENAME= ",DIR_FNAME
 D OPEN^%ZISH(,DIR,FNAME,"R")
 F CNT=1:1 D READNXT^%ZISH(.REC) Q:($ZEOF)  S LINE(CNT)=REC 
 D CLOSE^%ZISH("HFS")
 W !!
 S LN="",%I=0
 F  S LN=$O(LINE(LN)) Q:LN=""!(%I=94)  D
 .W !,LN,?5,LINE(LN)
 .D:'(LN#15) HIT1
 K DIR,FNAME,%I,LINE
 G HIT
 Q
 ;FILE EXISTS
ISFILE(FNAME) ;
 Q '$ZU(140,4,FNAME)
 ;
 ;DELETE FILE
DELFILE(FNAME) ;
 Q '$ZU(140,5,FNAME)
 ;
 ;MOVE/RENAME
MVRENAME(FNAME,NNAME) 
 Q '$ZU(140,6,FNAME,NNAME)
 ;
 ;CREATE DIR
MKDIR(DIRNAME) 
 Q '$ZU(140,9,DIRNAME)
 ;
 ;DELETE DIR
DELDIR(DIRNAME) 
 Q '$ZU(140,10,DIRNAME)
 ;
 ;GET WORKING DIR
GETDIR() 
 Q $ZU(168)
 ;
 ;DIRECTORIES OFF LIMITS TO READ TO, WRITE TO OR DELETE
DIROFF(DIR) 
 ;IN WINDOWS CASE DOESN'T MATTER
 ;IN UNIX IT DOES
 I WINDOWS S DIR=$$UPPER(DIR)
 I DIR="C:\CACHESYS" Q 1  ;CONTAINS CACHE SYSTEM
 I DIR[("R:\") Q 1  ;CONTAINS DATABASE BACKUPS TIER 1
 I DIR[("H:\") Q 1  ;CONTAINS DATABASE BACKUPS TIER 1
 I DIR[("MSMDBASES") Q 1  ;CONTAINS MSM DATABASES
 I DIR[("MSM") Q 1  ;CONTAINS MSM DATABASES
 I DIR[("ZIPPED") Q 1     ;CONTAINS CACHE BACKUPS 
 I DIR="C:\INETPUB" Q 1    ;CONTAINS GENERAL
 I DIR="C:\INETPUB\FTPROOT" Q 1
 I DIR="C:\INETPUB\FTPROOT\PUB" Q 1
 I DIR="/usr/spool/uucppublic/" Q 1  ;i think there is protection on this in unix
 Q 0
 ;
 ;DIRECTORIES OFF LIMITS TO WRITE TO OR CREATE
WDIROFF(DIR) 
 ;IN WINDOWS CASE DOESN'T MATTER
 ;IN UNIX IT DOES
 I WINDOWS S DIR=$$UPPER(DIR)
 I DIR[("C:\INETPUB"),($L(DIR,"\")=3) Q 1    ;CONTAINS GENERAL
 I DIR[("C:\INETPUB\FTPROOT"),($L(DIR,"\")=4) Q 1
 I DIR[("R:\") Q 1  ;CONTAINS DATABASE BACKUPS TIER 1
 I DIR[("H:\") Q 1  ;CONTAINS DATABASE BACKUPS TIER 1
 I DIR[("MSMDBASES") Q 1  ;CONTAINS MSM DATABASES
 I DIR[("MSM") Q 1  ;CONTAINS MSM DATABASES
 I DIR[("ZIPPED") Q 1     ;CONTAINS CACHE BACKUPS
 I DIR[("C:\CACHESYS") Q 1
 ;I DIR[("I") Q 1
 Q 0
 ;
 ;DIRCETORIES OFF LIMITES TO DELETE FILES
DDIROFF(DIR) 
 ;IN WINDOWS CASE DOESN'T MATTER
 ;IN UNIX IT DOES
 I WINDOWS S DIR=$$UPPER(DIR)
 I DIR[("C:\INETPUB"),($L(DIR,"\")=3) Q 1    ;CONTAINS GENERAL
 I DIR[("C:\INETPUB\FTPROOT"),($L(DIR,"\")=4) Q 1
 I DIR[("R:\") Q 1  ;CONTAINS DATABASE BACKUPS TIER 1
 I DIR[("H:\") Q 1  ;CONTAINS DATABASE BACKUPS TIER 1
 I DIR[("MSMDBASES") Q 1  ;CONTAINS MSM DATABASES
 I DIR[("MSM") Q 1  ;CONTAINS MSM DATABASES
 I DIR[("ZIPPED") Q 1     ;CONTAINS CACHE BACKUPS
 I DIR[("C:\CACHESYS") Q 1
 ;I DIR[("I") Q 1
 Q 0
 ;DIRECTORIES OFF LIMITS TO READ FROM
RDIROFF(DIR) 
 ;IN WINDOWS CASE DOESN'T MATTER
 ;IN UNIX IT DOES
 I WINDOWS S DIR=$$UPPER(DIR)  
 I DIR[("MSMDBASES") Q 1  ;CONTAINS MSM DATABASES
 I DIR[("MSM") Q 1  ;CONTAINS MSM DATABASES
 I DIR[("ZIPPED") Q 1     ;CONTAINS CACHE BACKUPS
 I DIR[("C:\CACHESYS") Q 1
 ;
 Q 0
 ;SET WORKING DIR
SETDIR(DIRNAME) 
 ;PUT ERROR TRAP IN IF <DIRECTORY> THEN IT DOESN'T EXIST
 Q '$ZU(168,DIRNAME)
 ;COPY FILE
COPYFILE(ORG,DEST) 
 S CMD=$S(WINDOWS:"copy",1:"cp")
 Q '$ZF(-1,CMD_" "_ORG_" "_DEST)
UPPER(STR) 
 Q $TR(STR,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 
