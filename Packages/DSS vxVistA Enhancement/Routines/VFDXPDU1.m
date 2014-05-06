VFDXPDU1 ;DSS/LM - Build/Transport/Install support ;14 Sep 2010
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via the ^VFDXPDU routine
 ;
 ;ICR #  SUPPORTED REFERENCE
 ;-----  -------------------------------------------------------------
 ; 2172  ^XPDID: INIT, EXIT, TITLE, UPDATE - only supported within the
 ;          context of the KIDS software.  Not supported outside KIDS.
 ;
 ;----------------------  CALLS TO XPDID ROUTINE  ---------------------
XPDIDIN ; initialize the KIDS graphic progress bar display screen
 D INIT^XPDID,XPDIDEX():'$G(XPDIDVT)
 Q
 ;
XPDIDEX(TEXT) ; exit graphic mode, clean up variables, write last msg
 D EXIT^XPDID($G(TEXT))
 Q
 ;
XPDIDTIT(TEXT) ; update the graphic title
 I $G(TEXT)'="" D TITLE^XPDID(TEXT)
 Q
 ;
XPDIDUP(NUM,XPDIDTOT) ;update the progress bar
 ; NUM - opt - the current count, default to zero
 ; XPDIDTOT - opt - total number, display %-progress of num/xpdidtot
 ;                  default to 100
 S NUM=+$G(NUM),XPDIDTOT=+$G(XPDIDTOT) S:'XPDIDTOT XPDIDTOT=100
 I '$G(XPDIDVT) W "." Q
 D UPDATE^XPDID(NUM)
 Q
 ;
 ;---------  CAPTURE XINDEX INVOKED BY LIST AND ROUTINE SIZES  --------
XINDEX ;
 ;; | Total | Execute | Non-Execute |         |
 ;; | Size  | Size    | Size        | # Lines |
 N A,I,J,L,T,X,Y,Z,TAG,VFDINDEX
 S VFDINDEX=0
 S X="^VFDINDEX" X ^%ZOSF("TEST") S X=$S($T:"^VFDINDEX",1:"^XINDEX")
 D @X
 Q:'$D(VFDINDEX)
 S $P(L,"-",71)=""
 ; routine invoked by list
 I '$D(VFDINDEX(1,0)) G X1
 F I=1:1:3 S A(I)=$P(VFDINDEX(1,0),U,I)
 S X="Tag Invoked" S:$L(X)>A(1) A(1)=$L(X)
 S Y="Rtn Invoked" S:$L(Y)>A(2) A(2)=$L(Y)
 S Z="Invoked By" S:$L(Z)>A(3) A(3)=$L(Z)
 S T=" "_X,$E(T,A(1)+3)="| "_Y
 S $E(T,A(1)+A(2)+6)="| "_Z
 S $E(T,A(1)+A(2)+A(3)+9)="|" W !!,T
 W !," "_$E(L,1,A(1)+1)_"|"_$E(L,1,A(2)+2)_"|"_$E(L,1,A(3)+2)_"|"
 F I=1:1 S X=$G(VFDINDEX(1,I)) Q:X=""  D
 .S T=" "_$$RJ^XLFSTR($P(X,U),A(1))_" | "_$P(X,U,2)
 .S $E(T,A(1)+A(2)+6)="| "_$P(X,U,3),$E(T,A(1)+A(2)+A(3)+9)="|" W !,T
 .Q
X1 ; routine size
 I '$D(VFDINDEX(2,0)) G X2
 K Y F I=1:1:5 S Y(I)=0
 S X=0 F  S X=$O(VFDINDEX(2,X)) Q:X=""  S A=+VFDINDEX(2,X) D
 .S:$L(X)>Y(1) Y(1)=$L(X)
 .S J=$L(A) F I=2,3,4 S:J>Y(I) Y(I)=J
 .Q
 S:Y(1)<8 Y(1)=8
 S J=$L(+VFDINDEX(2,0)) F I=2,3,4 S:J>Y(I) Y(I)=J
 S:Y(2)<5 Y(2)=5
 S:Y(3)<7 Y(3)=7
 S:Y(4)<11 Y(4)=11
 S T="",$P(T," ",Y(1)+3)="| Total" S $E(T,Y(1)+Y(2)+6)="| Execute"
 S $E(T,Y(1)+Y(2)+Y(3)+9)="| Non-Execute"
 S $E(T,Y(1)+Y(2)+Y(3)+Y(4)+12)="|         |"
 W !!,T
 S T=" Routine",$E(T,Y(1)+3)="| Size"
 S $E(T,Y(1)+Y(2)+6)="| Size"
 S $E(T,Y(1)+Y(2)+Y(3)+9)="| Size"
 S $E(T,Y(1)+Y(2)+Y(3)+Y(4)+12)="| # Lines |"
 W !,T
 S T=" "_$E(L,1,Y(1)+1) F I=2,3,4 S T=T_"|"_$E(L,1,Y(I)+2)
 S T=T_"|"_$E(L,1,9)_"|" W !,T
 S Z=0 F  S Z=$O(VFDINDEX(2,Z)) Q:Z=""  S A=VFDINDEX(2,Z) D
 .S A(2)=$P(A,U)
 .S A(3)=$P(A,U,3)
 .S A(4)=A(2)-A(3)
 .S A(5)=$P(A,U,2)
 .S T=" "_Z,$E(T,Y(1)+3)="| "
 .F J=2,3,4 S T=T_$J(A(J),Y(J))_" | "
 .S T=T_$J(A(5),7)_" |" W !,T
 .Q
 S T=" "_$E(L,1,Y(1)+1) F I=2,3,4 S T=T_"|"_$E(L,1,Y(I)+2)
 S T=T_"|"_$E(L,1,9)_"|" W !,T
 S A=VFDINDEX(2,0)
 S A(2)=$P(A,U)
 S A(3)=$P(A,U,3)
 S A(4)=A(2)-A(3)
 S T="",$P(T," ",Y(1)+3)="| "
 F J=2,3,4 S T=T_$J(A(J),Y(J))_" | "
 S T=T_"        |" W !,T
X2 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
MISS() Q "-1^Required parameter missing or invalid"
