VFDXPD1 ;DSS/SGM - TEXT FOR VFDXPD ROUTINES ;07 Oct 2010 15:52
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only invoked via VFDXPD
 ;
EN ; called from VFDXPD0
 ; expects SP,TAG and returns .VFDTXT
 N I,X,Y F I=1:1 S X=$P($T(@TAG+I),";",3,99) Q:X="END"  D
 .I SP S X="   "_X
 .I WR W !,X
 .E  S VFDTXT(I)=X
 .Q
 Q
 ;
1 ; called from DEL^VFDXPDH
 ;;You will now see the M implementation routine select prompt.
 ;;Copy and paste the above columnar display of the routines into that
 ;;routine selection prompt.  This was necessary as you have groups of
 ;;routines selected which are those in the list that end in '*'.
 ;;
 ;;END
 ;
3 ; called from EXCEL^VFDXPDA
 ;;The report can be displayed as delimited text with '^' as the
 ;;delimiter or as formatted text.  Delimited text will make it easier
 ;;to import the text into Excel
 ;;
 ;;END
 ;
API ; values from XINDEX on 7/12/2010 @ 11:20
