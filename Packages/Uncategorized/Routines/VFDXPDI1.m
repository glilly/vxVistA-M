VFDXPDI1 ;DSS/SMP - ENV/PRE/POST KIDS ;12/10/2012 14:50 PM
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 37
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 ; If either of the program's associated files (21692 or 21692.1)
 ; exist the enviroment check routine will set XPDQUIT, haulting
 ; the installation of the Patch Utility.
 ;
ENV ; Check for the existence of 21692 and 21692.1
 ;
 N X,Y,Z,DIR,DTOUT,DUOUT,FILE
 ;I $$VFILE^DILFD(21692)!($$VFILE^DILFD(21692.1)) S XPDQUIT=1
 I $$EXIST(21692) S FILE(21692)=""
 I $$EXIST(21692.1) S FILE(21692.1)=""
 ;
 ; If coming from the load only inform the user
 ; that the files exist
 Q:'$D(FILE)
 I $D(FILE(21692))&(($D(FILE(21692.1)))) D
 .W !!,"  Files 21692 and 21692.1 exist on this system.",!,"  They need to be deleted before installing this build.",!
 .S FILE=1
 I '$G(FILE),$D(FILE(21692)) W !!,"  File 21692 exists on this system.",!,"  It needs to be deleted before installing this build.",!
 I '$G(FILE),$D(FILE(21692.1)) W !!,"  File 21692.1 exists on this system.",!,"  It needs to be deleted before installing this build.",!
 Q:'XPDENV  ;Quit if loading
 S FILE=$S(+$G(FILE):"files",1:"file")
 W !!,"If you continue with the install, the "_FILE_" will be deleted.",!
 S DIR(0)="Y^A",DIR("A")="Would you like to continue",DIR("B")="NO"
 D ^DIR W !! I 'Y S XPDQUIT=2 D
 .W "Quitting the install, but the transport global will not be unloaded.",!
 Q 
 ;
 ; The Uninstall build uses the DELETE subroutine to delete the data 
 ; dictionary, sub data dictionary, data, and files (^DIC entries)
 ; 21692 and 21692.1.
 ;
DELETE ; Postinstall for VFDXPD UNINSTALL PATCH UTILITY
 N DIU
 W !!," Delteing Data Dictionaries and Data for files 21692 and 21692.1",!
 S DIU="^VFDV(21692,",DIU(0)="DS" D EN^DIU2
 K DIU S DIU="^VFDV(21692.1,",DIU(0)="DS" D EN^DIU2
 Q
 ;
PRED ; preinstall for VFDXPD DATA DESC
 Q:'$$VFILE^DILFD(21692)
 N X S X=$P($G(^VFDV(21692,0)),U,1,2) Q:X=""
 D BMES^XPDUTL("     >>> Deleting file 21692 <<<")
 K ^VFDV(21692) S ^VFDV(21692,0)=X
 Q
 ;
POSTD ; postinstall for VFDXPD DATA DESC
 Q
 ;
PREB ; preinstall for VFDXPD DATA BATCH
 Q:'$$VFILE^DILFD(21692.1)
 N X S X=$P($G(^VFDV(21692.1,0)),U,1,2) Q:X=""
 D BMES^XPDUTL("     >>> Deleting file 21692.1 <<<")
 K ^VFDV(21692.1) S ^VFDV(21692.1,0)=X
 Q
 ;
POSTB ; postinstal for VFDXPD DATA BATCH
 Q
 ;
PRE101 ;
 D:$$VFIELD^DILFD(21692,.14) DEL(21692)
 D:$$VFILE^DILFD(21692.1) DEL(21692.1)
 Q
 ;
DBCONV ;
 N IEN,VFDFDA
 S IEN=0 F  S IEN=$O(^VFDV(21692,IEN)) Q:'IEN  D
 .N NA,DATA D GETS^VFDXPDA("DATA",21692,IEN_",",".11;.12;2;3","IN")
 .Q:'$D(DATA)  S NA=$NA(DATA(21692,IEN_","))
 .I $D(@NA@(2)) D  ; If PRE INSTALL INSTRUCTIONS
 ..I $G(@NA@(.11,"I"))=1 S VFDFDA(21692,IEN_",",.11)=2 Q
 ..S VFDFDA(21692,IEN_",",.11)=1
 I $D(VFDFDA) D FILE^DIE(,"VFDFDA","VFDERR")
 Q
 ;
 ;-----------------------  private subroutines  -----------------------
DEL(VFD) ; Delete data dictionary if old version
 N I,X,Y,Z,DIU
 S DIU=VFD,DIU(0)="D",X="     >>> Deleting file "_VFD_" <<<"
 D BMES^XPDUTL(X),EN^DIU2
 Q
 ;
EXIST(FILE) ; Check if a file exists
 I $D(^DIC(FILE))!($D(^DD(FILE))) Q 1
 Q 0
