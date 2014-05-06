VFDRPARD ;DSS/RAC - ARRA LIST OF WARD TRANSFERS ; 05/25/2011 12:15
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 ;This RPC returns data regarding the movement file
 ;Input start and end dates of movements.
 ;All movement that are not admission or discharges
 ;
 ; Input:
 ;    Start Date in FM format
 ;    End Date in FM format
 ;
 ; Output:
 ;  A cvs file named PT_MOV.csv that contains the following:
 ;  Patient DFN
 ;  Movement Date/Time
 ;  Next Movement Date/Time
 ;  Movement_Location
 ;  Length of Stay = Next Movement Date/Time (or Now)
 ;                   - Movement Date/Time in days
 ;
 Q
EN ; entry point with no dates-D EN^VFDARLPM
 N END,START,VFD
 Q:$$DATE^VFDCFM(.START,.END,1)<1
 D GETPT(.VFD,START,END)
 Q
 ;
GETPT(VFDRET,START,END,VFDFILN,VFDPATH) ; RPC - VFD ARRA MOVE LIST
 ; get list of all interward transfers for date range
 ;   START - req - FM start date for report
 ;     END - opt - FM end date for report
 ; VFDFILN - opt - name of .CSV HFS file to create
 ;                 default to PT_TRANS.CSV
 ; VFDPATH - opt - directory or folder to place the HFS file
 ;                 default to $$PWD^%ZISH
 ; return VFDRET = 1^filename OR -1^error_msg
 ;
 N X,Y,Z,CNT,DFN,VFDDTS,VFDTR,VFDX,VIEN,VIN,VOUT
 S X=$$DATE^VFDRPARU($G(START),$G(END)) I +X=-1 S VFDRET=X Q
 S START=+X,END=$P(X,U,2)
 S:$G(VFDPATH)="" VFDPATH=$$PWD^%ZISH
 S:$G(VFDFILN)="" VFDFILN="PT_TRANS.CSV"
 S VFDX=$NA(^TMP("VFDRPARD",$J)) K @VFDX
 S CNT=1,@VFDX@(1)="PT_IEN^IN_DT^OUT_DT^MV_LOC^LOS"
 S VFDTR="" F  S VFDTR=$O(^DGPM("CA",VFDTR)) Q:'VFDTR  D
 .S VIEN=0 F  S VIEN=$O(^DGPM("CA",VFDTR,VIEN)) Q:'VIEN  D
 ..S X=^DGPM(VIEN,0) Q:$P(X,U,2)'=2  Q:$P(X,U,4)'=11  S DFN=$P(X,U,3)
 ..; movement is an interward transfer
 ..N LOC,LOS,VA,VAIP S VAIP("E")=VIEN D IN5^VADPT
 ..Q:VAIP(13,1)>END  ;              admit date > report end date
 ..S Y=+VAIP(17,1) I Y,Y<START Q  ; discharge date < report start date
 ..S VIN=+VAIP(3) ;                 movement transfer in date
 ..S VOUT=$P(VAIP(16,1),U) ;        movement transfer out date
 ..S LOS=$$LOSMV(VIN,VOUT)
 ..S LOC=$P(VAIP(14,4),U,2)
 ..S X=DFN_U_VIN_U_VOUT_U_LOC_U_LOS
 ..S CNT=1+CNT,@VFDX@(CNT)=X
 ..Q
 .Q
 I CNT=1 S VFDRET="-1^No transfer movements found for date range" Q
 S VFDDTS(0)=2,VFDDTS(1)=3
 D CSVOUT^VFDRPARI(VFDFILN,VFDX,U,U,.VFDDTS,VFDPATH)
 K @VFDX D KVAR^VADPT,KVA^VADPT
 S VFDRET="1^"_VFDFILN
 Q
 ;
LOSMV(X1,X2,MV,DFN) ; calculate LOS for an individual movement
 ; Either X1 is required  OR  MV is required
 ;  X1 - FM date for first movement
 ;  X2 - FM date for next movement - required if X1 is passed in
 ;       if 'X2 then use NOW
 ;  MV - Movement ien (#405)
 ; DFN - required if movement ien passed in
 N X,Y,Z,VA,VAIP
 I $G(MV)>0,$G(DFN)<1 Q 0
 I $G(MV)>0 D
 .S VAIP("E")=MV D IN5^VADPT
 .S X1=+VAIP(3)
 .S X2=$P(VAIP(16,1),U)
 .Q
 I '$G(X1) Q 0
 S:'X2 X2=$$NOW^XLFDT
 Q $$FMDIFF^XLFDT(X2,X1)
