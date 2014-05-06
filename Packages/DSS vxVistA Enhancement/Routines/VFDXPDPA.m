VFDXPDPA ;DSS/SGM - FILE HFS FILES TO FILE 21692*
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only invoked via the VFDXPDP routine
 ;
 ;Description of ^TMP nodes
 ;  ^TMP($J,1,n) = contents of HFS file
 ;  ^TMP($J,2,n) = contents of .TXT HFS file
 ;  ^TMP($J,3,n) = contents of .KID HFS file
 ;  ^TMP($J,4,uppercase_dat_filename) = P1^P2^P3^P4  where
 ;     p1 = Y if TXT file created    p3 = Y if DAT file deleted
 ;     p2 = Y if KID file created    p4 = error message
 ;
 ;ICR#  SUPPORTED DESCRIPTION
 ;----  ------------------------------------------
 ;      ^%DT
 ;      FMTE^XLFDT
 ;      ^XLFSTR: $$TRIM,$$UP
 ;      %ZISH: $$GTF,$$DEL
 ;
A(DEL) ; move HFS files in path to files 21692, 21692.1
 ; see description of ^TMP($J) above
 ; DEL - opt - default to 1
 ;       if 0 then leave subscripts 2,3,4 in ^TMP($J)
 ;       if 1 then leave ^TMP($J,4) only
 ;       if 2 then K ^TMP($J)
 ;
 N I,X,Y,Z,FILE,KID,LIST,PATH,VFDADD,VLIST
 D DEL(2)
 I $G(DEL)="" N DEL S DEL=1
 ; ask whether to overwrite data in file 21692
 S X=$$ASK^VFDXPDP0(1) Q:X<0  S VFDADD=X
 ;
 ; ask for path where the HFS files reside
 S X=$$ASK^VFDXPDP0("PATH") Q:X=""  Q:X<0  S PATH=X
 ;
 ; get list of files from path
 F X="DAT","KID","TXT" S LIST(X)=""
 S X=$$LIST^VFDXPDP1(.VLIST,PATH,"E",.LIST)
 I +X=-1 D ERRWR($P(X,U,2)) Q
 I X=0 D ERRWR("No files found in "_PATH) Q
 S VLIST=X
 ;
 ; convert mailman packman files
 S X="" F  S X=$O(VLIST("DAT",X)) Q:X=""  D
 .S FILE=$P(VLIST("DAT",X),U)
 .S Y=$$CONVERT(PATH,FILE,1,1),FILE=$P(VLIST("DAT",X),U,2)
 .I Y>0 S ^TMP($J,4,FILE)=$P(Y,U,2,4)
 .E  S $P(^TMP($J,4,FILE),U,4)=$P(Y,U,2)
 .Q
 D DEL(DEL)
 Q
 ;
 ;======================================================================
 ;           CONVERT MAILMAN PACKMAN FILE TO TXT & KID FILES
 ;======================================================================
CONVERT(PATH,FILE,NODEL,REMOVE) ;
 ; Return 1_U_P2_U_P3_U_P4 if successful, else -1^message
 ;   P2 = Y/N if TXT file created   P3 = Y/N if KID file created
 ;   P4 = Y/N if DAT file deleted
 ; PATH - req - directory where the file resides
 ; FILE - req - name of file to convert
 ; NODEL - opt - Boolean, default to 0, if 0 K ^TMP($J)
 ;REMOVE - opt - Boolean, if 1 then delete the .DAT HFS file if the
 ;         .TXT and .KID HFS files are sucessfully created
 ;
 N I,J,R,X,Y,Z,CNT,FILEUP,LINECNT,LENDTXT,PTXT,VFDZ
 D DEL(1)
 I $G(PATH)="" Q $$ERRMSG(1)
 I $G(FILE)="" Q $$ERRMSG(2)
 S FILEUP=$$UP(FILE)
 ; get DAT file
 S X=$$FTG^VFDXPDP1(PATH,FILE,$NA(^TMP($J,1,1)))
 I X=0 Q $$ERRMSG(4)
 S (CNT,LINECNT,STOP)=0
 ;
 ; validate that source is a valid Packman mail message
 S X=$$VALID1($NA(^TMP($J,1)),"PTXT") I X<2 D DEL(0) Q $$ERRMSG(5)
 S LENDTXT=X
 ;
 ; valid packman mailman message - continue processing
 ; get header info before patch description
 D DATHEAD
 ;
 ; move patch description to ^TMP($J,2)
 F I=1:1:LENDTXT S ^TMP($J,2,I)=^TMP($J,1,I)
 ;
 ; move kids portion to ^TMP($J,3)
 S I=LENDTXT+1,J=0
 S Y=$G(PTXT("MSGDT")) I Y'="" S Y=$P(Y,U,2)
 I Y="" S Y=$G(PTXT("REL")) I Y'="" S Y=$P(Y,U,2)
 I Y="" S Y=$$FMTE^XLFDT(DT)
 S J=J+1,^TMP($J,3,J)="KIDS Distribution saved on "_Y
 S X=$G(PTXT("MSGSUBJ")) I X="" S X="Processed "_FILEUP
 S J=J+1,^TMP($J,3,J)=X
 S X=^TMP($J,1,I),X=$P(X,": ",2,9),X=$$TRIM(X)
 S J=J+1,^TMP($J,3,J)="**KIDS**:"_X_U
 S J=J+1,^TMP($J,3,J)=""
 S Z="$END KID"
 F  S I=$O(^TMP($J,1,I)) Q:'I  S X=^(I) Q:$P(X," ",1,2)=Z  S J=J+1,^TMP($J,3,J)=X
 S X="**END**" S J=J+1,^TMP($J,3,J)=X,J=J+1,^TMP($J,3,J)=X
 ;
 ; create txt and kid files
 S Z=$P(FILEUP,".DAT")_".TXT",PTXT("TXTFILE")=Z
 S X=$$GTF^%ZISH($NA(^TMP($J,2,1)),3,PATH,Z)
 S VFDZ="1^"_$E("NY",X+1)
 ;
 S Z=$P(FILEUP,".DAT")_".KID",PTXT("KIDFILE")=Z
 S X=$$GTF^%ZISH($NA(^TMP($J,3,1)),3,PATH,Z)
 S $P(VFDZ,U,3)=$E("NY",X+1)
 ;
 ; delete .dat file
 I +$G(REMOVE) S $P(VFDZ,U,4)="N" I $P(VFDZ,U,2,3)="Y^Y" D
 .S VFDZ(FILE)="",X=$$DEL^%ZISH(PATH,"VFDZ") S:X $P(VFDZ,U,4)="Y"
 .Q
 I '$G(NODEL) D DEL(2)
 Q VFDZ
 ;
 ;===========  HEADER LINES FOR DISPLAY OF PATCH BUILD ADD  ===========
HDR(A) ;
 ;;Converting All .DAT Files to Corresponding .TXT and .KID Files
 ;;Mining .TXT and .KID Files To File Data To File 21692
 ;;Error Message While Processing HFS Files
 N I,L,X
 S $P(L,"=",80)=""
 S X=$P($T(HDR+A),";",3),$E(T,80-$L(X)\2)=X
 D SETRPT(A,L),SETRPT(A,X),SETRPT(A,L)
 Q 
 ;
 ;========================== SET REPORT NODE  =========================
 ; Report 1 = conversion of DAT files to KID and TXT file
 ;            ^TMP($J,"RPT",1,n) = p1^p2^p3^p4^p5
 ;            p1 = DAT filename             p2 = KID file created (Y/N)
 ;            p3 = TXT file created (Y/N)   p4 = DAT file deleted (Y/N)
 ;            p5 = error message
SETRPT(N,T) N I S I=1+$O(^TMP($J,"RPT",N," "),-1),^(I)=T Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
DATHEAD ; get mail message header info
 N I,J,X,Y,Z,EQ,STOP,VRET
 S (I,STOP)=0,EQ=$$EQ,VRET="PTXT"
 F  S I=$O(^TMP($J,1,I)) Q:'I  S X=^(I) Q:STOP
 .S Y=$$UP(X),Z=$P(Y,":")
 .I Y?1"$TXT ".E S STOP=1 Q
 .I X=EQ S STOP=1 Q
 .Q:"^DATE^MESSAGE-ID^SENT^SUBJECT^"'[(U_Z_U)
 .S Y=$P(X," ",2,99)
 .S J=$S(Z="SUBJECT":"MSGSUBJ",Z="MESSAGE-ID":"MSGID",1:"MSGDT")
 .D VAL1(Y,J)
 .Q
 Q
 ;
DEL(T) ; delete ^TMP($J) nodes - see DEL description for line tag A()
 S T=$G(T) I T=2 K ^TMP($J)
 I T=1 K ^TMP($J,1),^(2),^(3)
 I T=0 K ^TMP($J,1)
 Q
 ;
EQ() N X S $P(X,"=",78)="" Q X
 ;
ERRMSG(A) ;
 ;;Input parameter path (directory) not received
 ;;Input parameter filename not received
 ;;Input parameter ROOT not received
 ;;Failed to retrieve file
 ;;File is not a valid patch message
 Q "-1^"_$P($T(ERRMSG+A),";",3)
 ;
ERRWR(T) W !!,T Q
 ;
NEXT() K X S I=I+1 S:$D(@ROOT@(I)) X=^(I) Q $D(X)
 ;
UP(T) Q $$UP^XLFSTR(T)
 ;
 ;=====================================================================
 ;       VALIDATE SOURCE IS PATCH DESCRIPTION OR PACKMAN MESSAGE
 ;=====================================================================
VALID1(ROOT,VRET) ;
 ; ROOT - req - @root@(n)=message contents
 ; VRET - opt - $NA() of return array to return patch info description
 ; @VRET(x) NAME = patch designation     SEQ = seq#
 ;           PKG = package namespace     VER = version
 ;           REL = release date FM^external
 ;          SUBJ = patch subject
 ; Return 1 if valid patch description only
 ;        subscript of '$END TXT' line for Packman message
 I $S($G(ROOT)="":1,1:'$O(@ROOT@(0))) Q $$ERRMSG(3)
 N I,J,K,X,Y,Z,ERR,EQ,FLG,MM,MSG
 S EQ=$$EQ,(I,J,K,FLG)=0,MM=""
 S MSG=$$ERRMSG(5)
 F  Q:'$$NEXT  D  Q:FLG
 .I X=EQ S J=J+1,FLG=1 Q
 .I $E(X,1,5)="$TXT ",X["(KIDS)" S J=J+1
 .Q
 I 'FLG!(12'[J) Q MSG
 ; examine lines between equal sign borders
 Q:'$$NEXT MSG
 I $P(X,":")'="Run Date"!($P(X,":",2)'["Designation") Q MSG
 S Y=$P(X,"Designation: ",2) D VAL1(Y,"NAME")
 Q:'$$NEXT MSG I $P(X," :")'="Package"!($P(X,":",2)'["Priority") Q MSG
 S Y=$P($P(X,":",2),"Priority:") D VAL1(Y,"PKG")
 Q:'$$NEXT MSG I $P(X," :")'="Version"!($P(X,":",2)'["Status") Q MSG
 S Y=$P($P(X,":",2),"SEQ") D VAL1(Y,"VER")
 I X["SEQ" D VAL1(+$P(X,"#",2),"SEQ")
 Q:'$$NEXT MSG I X["Compliance Date" Q:'$$NEXT MSG
 I X'=EQ Q MSG
 ; find line number of line equal to $END TXT
 F  Q:'$$NEXT  Q:X="$END TXT"  D
 .I J=2,X?1"Subject: ".E S Y=$P(X," ",2,99) D VAL1(Y,"SUBJ")
 .I X=EQ S J=J+1 Q
 .Q:J<3  Q:$P(X," ",1,2)'="Released By"
 .S Y=$P(X,"Date Released :",2) D VAL1(Y,"REL")
 .Q
 I '$D(X) Q 1 ; a patch description only
 ; verify last line is '$KID'
 S J=" ",K=0 F  S J=$O(@ROOT@(J),-1) Q:'J  S K=K+1,X=^(J) D  Q:FLG=2
 .I $P(X," ",1,2)="$END KID" S FLG=2 Q
 .I K>20 S FLG=-1
 .Q
 Q $S(FLG=2:I,1:$$ERRMSG(5))
 ;
VAL1(T,S) ;
 N V Q:$G(VRET)=""  S V=$$TRIM(T)
 I S="PKG" S V=$P(V," ")
 I "^MSGDT^REL^"[(U_S_U) S V=$$ETFM(V)
 S @VRET@(S)=V
 Q
 ;
TRIM(T) N M,X,Y,Z S T=$$TRIM^XLFSTR(T) Q T
 ;
ETFM(X) ; convert external date.time to FM format
 ; expects X to be in format 'mmm dd, yyyy'
 N I,J,Y,Z,%DT,DATE,TIME
 S DATE=$P(X," ",1,3) I DATE="" Q ""
 S TIME=$S(X["@":$P(X,"@",2),1:$P(X," ",4,5))
 S TIME=$P(TIME," "),Z=$P(TIME," ",2)
 I Z'="AM",Z'="am",Z'="PM",Z'="pm" S Z=""
 S X=DATE S:TIME'="" X=X_"@"_TIME S:Z'="" X=X_" "_Z
 S %DT="TS" D ^%DT S:Y<1 Y=""
 Q $TR(X,"@"," ")_U_Y
