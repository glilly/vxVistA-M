VFDXPD2 ;DSS/SMP - DIR PROMPTER ; 02/23/2013 11:10
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only invoked via ^VFDXPD
 ;
DIR ;
 N I,J,X,Y,Z,DIR,DIROUT,DIRUT,DTOUT,DUOUT
 Q:$G(LINE)="" -1 Q:$T(@LINE)="" -1 D @LINE
 W:LINE'=1 ! D ^DIR S Y=$S($D(DUOUT):-1,$D(DTOUT):-1,Y="":-1,1:Y)
 Q Y
 ;
CR ; press return to continue prompt
 S DIR(0)="E"
 Q
 ;
1 ; called from 4^VFDXPDD
 ;;SOM^A:add an existing Build to batch;D:delete a Build from batch;
 ;;E:edit a Build description;W:worksheet
 ;;      Add - a Build name already exists in the Patch Description
 ;;            file and you wish to select that Build to add to a batch
 ;;
 ;;     Edit - a Build name already exists in the Batch profile and you
 ;;            wish to edit/verify the data in the Patch Description
 ;;
 ;;   Delete - remove an existing Build in a batch from that batch
 ;;
 ;;Worksheet - create a stub Patch Descritpion record with the flags
 ;;            indicating the status of the retrieval from the VA both
 ;;            FORUM and download.med.va.gov
 ;;
 S DIR(0)=$P($T(1+1),";",3,9)_$P($T(1+2),";",3,9)
 S DIR("A")="Select option"
 F I=3:1:14 S DIR("A",I-2)=$TR($T(1+I),";"," ")
 W @IOF
 Q
 ;
2 ; called from 2^VFDXPDD
 ;;The Build you have selected does not have an unclassified STATUS.
 ;;Are you sure you want to add this Build to the batch profile?
 ;;
 S DIR(0)="YOA",DIR("B")="NO",DIR("A")="Add to the batch? "
 F I=1:1:3 S DIR("A",I)=$TR($T(2+I),";"," ")
 Q
 ;
3 ; called from 42^VFDXPDD
 ;;Create - select this option if you want to create a new entry in the
 ;;         Build Description file (#21692).  Choose this option if you
 ;;         are on FORUM and sending yourself a patch description
 ;;  Edit - select this option if you wish to update an existing Build
 ;;         Description file entry for the data related to retrieving
 ;;         patches and files from the VA
 S DIR(0)="SOM^C:create new entry;E:edit existing entry"
 S DIR("B")="C",DIR("A")="   Option",DIR("?")="  "
 S DIR("A",1)="   Patch Description File Action",DIR("A",2)="  "
 F I=1:1:6 S DIR("?",I)=$TR($T(3+I),";"," ")
 Q
 ;
4 ; called from 11^VFDXPDE
 ;;A:all builds regardless of retrieve status
 ;;O:only those builds which have pending retrieves
 ;;F:list of associated files only still to be retrieved
 ;; All - this will return all builds in a batch with their current
 ;;       STATUS and RETRIEVE state.  It will also display all files
 ;;       and their current retrieval status
 ;;Only - this will display only those builds in a batch which still
 ;;       have an outstanding retrieval status or have a file still
 ;;       marked as needing to be retrieved
 ;;File - this will list only those ASSOCIATED FILES for builds in a
 ;;       batch which are marked as needed to be retrieved
 S DIR(0)="SOM^" F I=1:1:3 S DIR(0)=DIR(0)_$P($T(4+I),";",3)_";"
 S DIR("B")="O",DIR("A")="   Select report option",DIR("?")="  "
 F I=4:1:11 S DIR("?",I-3)=$TR($T(4+I),";"," ")
 Q
 ;
5 ; called from EN^VFDXPDY
 S DIR(0)="YOA",DIR("B")="YES",DIR("A")="Install "_NM_"? "
 W !
 Q
 ;
6 ; called from EN^VFDXPDJ
 ;;There are Loaded Installs with statuses of 
 ;;INSTALLs with one of these statuses will be deleted from file 9.7
 ;;INSTALLs with one of these statuses will only have the ^XTMP("XPDI")
 ;;  global deleted: 
 S DIR(0)="YOA",DIR("B")="NO",DIR("A")="Delete all loaded install? "
 S (I,X)="" F  S I=$O(VFDL("SB",I)) Q:I=""  S X=X_XPDSTAT(I)_"; "
 I X'="" D
 .S I=1,Z(1)=$TR($T(6+1),";"," ")_X
 .S X="" F J=0,1,2 S:$D(VFDL("SB",J)) X=X_XPDSTAT(J)_";"
 .I X'="" S I=I+1,Z(I)=$TR($T(6+2),";"," "),I=I+1,Z(I)="     "_X
 .S X="" F J=3,4 S:$D(VFDL("SB",J)) X=X_XPDSTAT(J)_";"
 .I X'="" S I=I+1,Z(I)=$TR($T(6+3),";"," ")
 .I  S I=I+1,Z(I)=$TR($T(6+4),";"," ")_X
 .W ! F I=1:1 Q:'$D(Z(I))  W !,Z(I)
 .W !
 .Q
 Q
 ;
7 ; called from 1^VFDXPDF
 ;;0:No overwrite;1:Overwrite, purge Req Builds;2:Overwrite, don't purge Req Builds
 ;;Update behavior for importing HFS files and how it affects the data
 ;;in file 21692 [Build Description]:
 ;;
 ;;   i. ALWAYS add that Build to the Batch Group if not present
 ;;  ii. ALWAYS add any new Builds found in the HFS files to file 21692
 ;; iii. ALWAYS update any field for an existing entry in file 21692
 ;;      which is null if that data exists in the HFS files
 ;;  iv. Behavior when data ALREADY EXISTS in a 21692 file entry
 ;;      a. Option 0 - do not overwrite any existing data
 ;;      b. Options 1&2 - if existing data is found in 21692 file AND
 ;;          in the HFS file, then overwrite data in file 21692
 ;;      c. Option 1 - purge 21692 entry of required builds and add
 ;;          any required builds found in HFS file
 ;;      d. Option 2 - do not purge 21692 entry of required builds and
 ;;          add any new required builds found in HFS file
 ;;
 ;;For VA VistA the preferred default answer is 1
 ;;For vxVistA  the preferred default answer is 0
 ;;
 S DIR(0)="SOM^"_$P($T(7+1),";;",2),DIR("B")=1
 S DIR("A")="Update Option" F I=2:1:20 S DIR("?",I)=$TR($T(7+I),";"," ")
 S DIR("?")="  ",DIR("?",1)="  "
 W @IOF S I=0 F  S I=$O(DIR("?",I)) Q:'I  W !,DIR("?",I)
 W !!,"Press any key to continue " R X:DTIME W !
 Q
 ;
8 ; called from ^VFDXPD01
 ;;Enter 1 to display the text in Fileman's Browser
 ;;Enter 2 to display the text on the screen
 ;;Enter 3 to send to a HFS file
 S DIR(0)="SO^1:Fileman Browser;2:Terminal;3:HFS Device"
 S DIR("B")=2,DIR("A")="Select display mode",DIR("?")="   "
 F I=1:1:3 S DIR("?",I)=$TR($T(8+I),";"," ")
 Q
 ;
9 ; called from 10^VFDXPDH
 S DIR(0)="YOA",DIR("B")="NO",DIR("A")=" Delete these routines? "
 S DIR("?")="Answer YES to delete the above routines from this system"
 Q
 ;
10 ; called from 10^VFDXPDH
 ;;You will now see the M implementation routine select prompt.
 ;;Copy and paste the following columnar display of the routines into
 ;;that routine selection prompt.  This was necessary as you have
 ;;groups of routines selected which are those in the list that end
 ;;in '*'.  If the routine selector prompt asks for all routines,
 ;;answer no.
 F I=1:1:6 W !,$TR($T(10+I),";"," ")
 G CR
 ;
11 ; called from 13^VFDXPDY
 ;;This tool will assist in the installation of the Builds associated
 ;;with this Batch Group.  It will install the patches in the proper
 ;;sequence.  It presumes that the Builds have already been Loaded.
 ;;It will loop through all the Builds in the batch and then enter the
 ;;KIDS INSTALL A BUILD option.  Since it has the name of the Build to
 ;;be installed, you will NOT be prompted to enter a Build name but
 ;;will proceed as normal for KIDS as if you had entered the Build name
 ;;
 F I=1:1:8 W !,$TR($T(11+I),";"," ")
 S DIR(0)="YOA",DIR("B")="YES",DIR("A")="   Do you wish to continue? "
 Q
 ;
12 ; called from 8^VFDXPDL
 S DIR(0)="YOA",DIR("B")="NO",DIR("A")="Would you like to continue with load? "
 Q
 ;
13 ; called from ASKRPT^VFDXPD01
 ;;You have chosen to display this to the terminal screen.
 ;;Specify the number of columns to use in displaying the report.
 ;;
 F I=1:1:3 W !,$TR($T(13+I),";"," ")
 S DIR(0)="SO^0:80 Columns;1:132 Columns"
 S DIR("B")=0,DIR("A")="Select number of columns for display"
 Q
 ;
14 ; called from XXXXXXXXXXXXXX
 ;;There may be some checksums in these files that are already recorded
 ;;in file 21692.2.  If you want, this utility can overwrite that
 ;;stored information.
 ;;
 ;;NOTE:  New entires will ALWAYS be added to the file.
 ;;
 F I=1:1:5 W !,$TR($T(14+I),";"," ")
 S DIR(0)="Y",DIR("A")="Would you like to update existing entries"
 S DIR("B")="YES"
 Q
