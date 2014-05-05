VFDXTR09 ;DSS/SGM - DIR PROMPTING UTILITY ; 08/08/2011 15:47
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked from other VFDXTR routines
 ;
 ; ICR#  Supported Description
 ;-----  --------------------------------------------
 ; 2263  $$GET^XPAR
 ;10026  ^DIR
 ;10048  FM read of Package file (#9.4)
 ;10103  $$HTE^XLFDT
 ;
DIR(L,VFDY) ; DIR call
 ; L - req - line tag to use to set up DIR()
 ; return value of Y from DIR call
 ;   or if timeout return -3, if ^-out return -2
 ; .VFDY - passed by reference, return values of Y, ie., M VFDY=Y
 N I,J,X,Y,Z,DIR,DIROUT,DIRUT,DTOUT,DUOUT
 I $G(L)'?1.N Q $$ERR(1)
 I $T(@L)="" Q $$ERR(1)
 D @L W ! D ^DIR I $D(DUOUT)!$D(DIRUT)!$D(DIROUT) S Y=-2
 I $D(DTOUT) S Y=-3
 M VFDY=Y
 Q Y
 ;
 ;--------------  P R I V A T E   S U B R O U T I N E S  --------------
ERR(A) ;
 N T
 I A=1 S T="API called improperly"
 Q "-1^"_T
 ;
1 ; are you sure
 S DIR(0)="YOA",DIR("B")="No"
 S DIR("A")="Do you wish to continue? "
 Q
 ;
2 ; list routines?
 S DIR(0)="YOA",DIR("A")="Display the list of routines? "
 S DIR("B")="YES"
 Q
 ;
3 ; source where to get routine list
 ;;You can get the list of routines from KIDS Build file entry
 ;;Or you can select the routines from the routine select utility
 N I,X
 S DIR(0)="SO^F:Free Form;B:Build File",DIR("?")="   "
 S DIR("A")="Choose Routine Selection Method"
 F I=1,2 S X=$TR($T(3+I),";"," ") S DIR("?",I)=X
 D WR("Routine Selection Method")
 Q
 ;
4 ; hfs filename [askfile^vfdxtru]
 S DIR(0)="FO^3:80",DIR("A")="Enter file name"
 Q
 ;
5 ; ask for hfs path [askpath^vfdxtru]
 S DIR(0)="FO^3:150",DIR("A")="Enter directory name or path"
 S DIR("A",1)="Format of path name is not verified as valid"
 S DIR("A",2)="Examples:  c:\hfs\   SPL$:[SPOOL]"
 S DIR("A",3)="",DIR("B")=$G(VPATH)
 Q
 ;
6 ; update routine lines 1,2,3 [vfdxtr02]
 ;;Option 1 will replace version# on 2nd line and will clear out patch list
 ;;Option 2 will add a patch number to the patch list on the 2nd line
 ;;Option 3 will update the date/time on the 1st line of the routines in a VA
 ;;  SACC compliant format.
 ;;Option 4 will just add the Copyright statment to the routines as the 3rd
 ;;  line of that routine.  It will use the copyright statement on the 3rd
 ;;  line of this routine as the template for all routines.  This program will
 ;;  change the TO date to the current date before inserting the 3rd line.
 ;;SO^1:New version#;2:Add a patch#;3:First line date;4:Copyright only
 N I,X
 S DIR(0)=$P($T(6+9),";",3,99)
 S DIR("A")="Routine Update Option",DIR("?")="   "
 F I=1:1:8 S DIR("?",I)=$TR($T(6+I),";"," ")
 D WR("Routine Update Option")
 Q
 ;
7 ; ask if copyright to be updated [vfdxtr02]
 ;;This will add the Copyright statment to the routines as the 3rd of
 ;;those routines.  It will use the copyright statement on the 3rd of
 ;;this routine as the template for all routines.  This program will
 ;;change the TO date to the current date before inserting the 3rd line
 N I,X,Y,Z
 S DIR(0)="YOA",DIR("B")="YES",DIR("?")="   "
 S DIR("A")="Update Copyright on 3rd line? "
 F I=1:1:4 S DIR("?",I)=$TR($T(7+I),";"," ")
 D WR("Copyright Update")
 Q
 ;
8 ; ask for version number [vfdxtr02]
 ;;Enter a version number to be placed in the 3rd ";"-piece on the 2nd
 ;;line of routines.  Valid version numbers must contain at least one
 ;;decimal number.
 ;;  For VA, valid values are of the form nn.nn   If you wish to use
 ;;  test designations then you can append a Tnn or Vnn after the
 ;;  version number.
 ;;  For vxVistA, valid values are of the form nnnn.nn OR nnnn.nn.nnn
 ;;   1) nnnn should be the year of release
 ;;   2) .nn. should be the sequence number of release for that year
 ;;   3) .nnn is optional indicates an sequential number update to
 ;;      nnnn.nn and is not a full release of all components
 N I,J,X,VX
 ; Boolean check if this is a vxVistA system
 S VX=$$GET^XPAR("SYS","VFD VXVISTA VERSION",1,"Q")>1
 S J=0 I VX D
 .S DIR(0)="FO^1:15^K:'(X?1.4N1"".""1.2N.1(1"".""1.3N)) X"
 .F I=1,2,3,7:1:11 S J=J+1,DIR("?",J)=$TR($T(8+I),";"," ")
 .Q
 E  D
 .S DIR(0)="FO^1:8^K:'(X?1.N1"".""1.2N.1(1""T"",1""V"").2N) X"
 .F I=1:1:6 S DIR("?",I)=$TR($T(8+I),";"," ")
 .Q
 S DIR("A")="Enter New Version Number",DIR("?")="   "
 D WR("New Version Number For Routine Second Line")
 Q
 ;
9 ; ask for patch number [vfdxtr02]
 ;;Update Patch List With New Patch Number
 ;;This assumes that any existing patch list is in the proper syntax
 N X
 S DIR(0)="NO^1:9999:0",DIR("A")="Enter Patch Number"
 S DIR("?")="Enter the whole number for this patch"
 S X=$P($T(9+1),";",3) D WR(X)
 W !,$TR($T(9+2),";"," ")
 Q
 ;
10 ; ask for date [vfdxtr02]
 ;;The SACC standards do not specify the meaning of the date with
 ;;optional time on the first line of the routine.  But it requires a
 ;;date there nevertheless.  Many utilities presume that the date on the
 ;;first line is the date/time that this routine was last modified.
 ;;
 ;;The date on the second line of the routine should only be set when a
 ;;new version of the package has been released.  The date should be the
 ;;date that the package was released for customer use.  This is date
 ;;only, time is not allowed.
 N I,X,Y,DATE,NOW
 S NOW=$P($$HTE^XLFDT($H,9),":",1,2),DATE=$P(NOW,"@")
 S DIR(0)="DO^::AEX" I VFDCH=3 D
 .S DIR(0)=DIR(0)_"T"
 .S DIR("A")="Enter First Line Date(time)"
 .S DIR("B")=NOW,DIR("?")="   "
 .F I=1:1:4 S DIR("?",I)=$TR($T(10+I),";"," ")
 .S Y="First Line Date(time)"
 .Q
 I VFDCH=1 D
 .S DIR("A")="Enter Package Release Date"
 .S DIR("B")=DATE,DIR("?")="   "
 .F I=6:1:9 S DIR("?",I-5)=$TR($T(10+I),";"," ")
 .S Y="Package Release Date"
 .Q
 D WR(Y)
 Q
 ;
11 ; ask for package [vfdxtr02]
 ;;The 4th ";"-piece of the second line of routines must contain the
 ;;name of the package that is responsible for maintenance of this
 ;;routine.
 N I,X
 S DIR(0)="PO^9.4:QAEMZ"
 S X=$P($G(VFDCH("PKG")),U)
 I X="",$$LKPKG^XPDUTL("VEJD") S X="VENDOR - DOCUMENT STORAGE SYS"
 S DIR("B")=X,DIR("A")="Enter Package Name"
 F I=1:1:3 S DIR("?",I)=$TR($T(11+I),";"," ")
 D WR("Package Name")
 Q
 ;
12 ; sort by criteria for routine size [vfdxtr01]
 ;;You can sort the display by routine name or by the size of the
 ;;routines (# of characters) in descending order, that is, the routine
 ;;with the most characters will be displayed first
 ;;
 N I,X,Y,Z
 S DIR(0)="SO^N:Routine Name;S:Size of routine (descending)"
 S DIR("A")="Select sort type",DIR("B")="Routine Name",DIR("?")="   "
 F I=1:1:4 S DIR("?",I)=$TR($T(12+I),";"," ")
 Q
 ;
13 ; routine input/ouput [vfdxtrs]
 ;;   SAVE option: save the selected routines to individual HFS files
 ;;RESTORE option: restore routines from the selected HFS files
 ;;                previously saved using this option
 ;;This utility saves routines as HFS files using the filename syntax
 ;;of filename.rsv
 ;;
 N I,X,Y,Z
 S DIR(0)="SO^S:Save routines;R:Restore routines"
 S DIR("A")="   Option" F I=1:1:6 S DIR("A",I)=$TR($T(13+I),";"," ")
 Q
 ;
WR(X,CH) S CH=$G(CH) S:CH="" CH="-" D WR^VFDXTRU(X,CH) Q
