RMPR37A ;PHX/JLT-CONTINUATION OF POST 2237 TO 10-2319 RMPR37 ;8/29/1994
 ;;3.0;PROSTHETICS;;Feb 09, 1996
A ;DISPLAY ITEMS INFORMATION ON 2237
 Q:'$D(R410("IT"))  W !?5,ITN,">"
 S D1=0 F I=0:0 S D1=$O(R410("IT",ITN,1,D1)) Q:D1'>0  W ?10,$P(R410("IT",ITN,1,D1,0),U,1),!
 D A1
 K R1,RZZZ,QT,CT Q
A1 S RTN=R410("IT",ITN,0)
 W ?10,"QTY: ",$P(RTN,U,2),?20,"UNIT OF ISSUE: "
 S UN=$P(RTN,U,3)
 W:+UN $P(^PRCD(420.5,UN,0),U,1)
 W ?40,"UNIT COST:"
 S (X,CT)=$P(RTN,U,7),X2="2$" D COMMA^%DTC
 W X,!
 S QT=$P(RTN,U,2),CTT=CTT+(CT*QT)
 Q
NUM ;CHECK FOR ITEMS BY NUMBER ENTRY
 I $D(^RMPR(661,"B",RMPRY)) S X=RMPRY,DIC(0)="NMZ",DIC=441 D ^DIC I +Y S RIT(RMPRY,$P(Y(0),U,2))=""
 I '$D(R410("IT",RMPRY,1))&($D(RIT)) Q
 I '$D(R410("IT",RMPRY,1)) W $C(7),"??" Q
 F RI=0:0 S RI=$O(R410("IT",RMPRY,1,RI)) Q:RI'>0  S RZ=R410("IT",RMPRY,1,RI,0) I RZ'="" D EXT
 Q
EXT S (CI,C1)=1,GI=$L(RZ,",")
 I GI>0 F I=1:1:GI-1 S RAT=$F(RZ,",") S RZ=$E(RZ,1,RAT-2)_" "_$E(RZ,RAT,99)
 F RT=1:1 S RE=$E(RZ,RT) Q:$A(RE)'>0  I $A(RE)=32 S CI=CI+1
 F RT=1:1:CI S RD=$P(RZ," ",RT) S:$L(RD)>2 RD(RD)=RD
 D PAR Q
CHK ;CHECK FOR ITEMS IN 661 BY SHORT DESCRIPTION X-REF
 S AZL=$L(RMPRY)
 I $D(^PRC(441,"C",RZ)) F RG=0:0 S RG=$O(^PRC(441,"C",RZ,RG)) Q:RG'>0  S:$D(^RMPR(661,"B",RG)) RIT(RG,RZ)="" G:'$D(^RMPR(661,"B",RG)) EXT
 S RD(RZ)="" G EXT
PAR S RXX="" F RF=0:0 S RXX=$O(RD(RXX)) Q:RXX=""  I $D(^PRC(441,"C",RXX)) F RNI=0:0 S RNI=$O(^PRC(441,"C",RXX,RNI)) Q:RNI'>0  I $D(^RMPR(661,"B",RNI)) S RIT(RNI,RXX)=""
 S RB="" F RF=0:0 S RB=$O(RD(RB)) Q:RB=""  S:RMPRY AZL=3 S RJ=$E(RB,1,AZL) F KK=0:0 S RJ=$O(^PRC(441,"C",RJ)) Q:$E(RB,1,AZL)'=$E(RJ,1,AZL)  F RIN=0:0 S RIN=$O(^PRC(441,"C",RJ,RIN)) Q:RIN'>0  I $D(^RMPR(661,"B",RIN)) S RIT(RIN,RJ)=""
 Q
