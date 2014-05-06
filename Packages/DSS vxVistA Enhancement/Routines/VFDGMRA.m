VFDGMRA ;DSS/WLC - MAIN ENTRY TO VFDGMRA ROUTINES ;24 Mar 2011 17:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine will be the main entry point into all of the VFDGRMA*
 ;routines.  Starting Mar1, 2006 all new DSS applications should only
 ;call line labels in this routine.  As this routine will potentially
 ;have many entry points, detailed documentation for entry point will
 ;be in the VFDGRMA* routine that is invoked.
 ;
 ;All Integration Agreements for VFDGRMA*
 ;DBIA#  Supported Reference
 ;-----  ----------------------------------------------------
 ;
EDITSAVE(ORY,ORALIEN,ORDFN,OREDITED) ; Save Edit/Add of an allergy/adverse reaction
 ;following patch check is made via GUI RPC call to ORWU PATCH instead
 ;I '$$PATCH^XPDUTL("GMRA*4.0*21") S Y="-1^Not yet implemented" Q
 N ORNODE
 S ORNODE=$NAME(^TMP("GMRA",$J))
 K @ORNODE M @ORNODE=OREDITED
 S ORY=0
 S ^WLC("ORALIEN")=ORALIEN
 M ^WLC("ORNODE")=@ORNODE
 I $G(@ORNODE@("GMRAERR"))="YES" D EIE^GMRAGUI1(ORALIEN,ORDFN,ORNODE) Q  ;Handle entered in error
 I $G(@ORNODE@("GMRANKA"))="YES" D NKA^GMRAGUI1 Q
 D UPDATE^VFDGMRAA(ORALIEN,ORDFN,ORNODE) Q  ;Add/edit reactions
 Q
