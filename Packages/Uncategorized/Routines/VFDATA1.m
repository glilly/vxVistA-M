VFDATA1 ;DSS/LM - Data Table Utilities ;January 15, 2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
MPORT ;[PUBLIC] VFD TABLE IMPORT interactive OPTION
 ;
 ;
 N DIC,X,Y
 W !,"This option imports data to a VFD TABLE file entry.",!
 S DIC=21611,DIC(0)="AEQM" D ^DIC Q:Y<0
 N VFDHFS,VFDIEN,VFDNAM S VFDIEN=+Y,VFDNAM=$P(Y,U,2)
 S VFDHFS=$$GET1^DIQ(21611,+Y,5)
 I '$L(VFDHFS) D  Q
 .W !!,"Table '"_VFDNAM_"' does not have a HOST FILE defined."
 .W !,"Please edit this entry using option 'Enter/Edit VFD TABLE'"
 .W !,"and supply a value for the HOST FILE field.  Then retry."
 .W !
 .Q
 N DIR S DIR(0)="Y",DIR("A")="Are you sure"
 W !!,"Import and replace data for table "_VFDNAM_" from"
 W !,VFDHFS,! D ^DIR Q:$D(DIRUT)
 I '(Y=1) W !,"Import aborted." Q
 N VFDARY,VFDRSLT S VFDARY(1)=".01^`"_VFDIEN
 D IMPORT^VFDATA(.VFDRSLT,.VFDARY)
 I VFDRSLT<0 D  Q
 .W !,"The import request failed with the following error:"
 .W !,$P(VFDRSLT,U,2)
 .Q
 W !,"Data imported to table IEN="_VFDIEN
 Q
MDLTE ;[PUBLIC] VFD TABLE DELETE DATA interactive OPTION
 ;
 ;
 N DIC,X,Y
 W !,"This option deletes data from a VFD TABLE file entry."
 W !,"Row and column headers and data cell values are deleted."
 W !,"Non-data fields are not changed.",!
 S DIC=21611,DIC(0)="AEQM" D ^DIC Q:Y<0
 N VFDIEN,VFDNAM S VFDIEN=+Y,VFDNAM=$P(Y,U,2)
 N DIR S DIR(0)="Y",DIR("A")="Are you sure"
 W !!,"Imported data will be deleted from table "_VFDNAM
 D ^DIR Q:$D(DIRUT)
 I '(Y=1) W !,"Import aborted." Q
 D DELETE^VFDATA(VFDIEN)
 W !,"Delete request has been processed."
 Q
