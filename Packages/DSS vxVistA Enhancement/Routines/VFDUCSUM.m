VFDUCSUM ;DSS/JDB - Verhoeffs Dihedral Checksum ;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
 ;
 ;
VHOK(NUM,VDT) ;
 ; Does this number pass the Verhoeff Check?
 ; Inputs
 ;    NUM: The complete number (with checksum)
 ;    VDT: <opt><byref> The Verhoeff Diehedral arrays
 ;       : If the array is specified it will be available for
 ;       : another SCTVCHK call (eliminates building array every call)
 ;       : If not specified the VD array is created automatically.
 ; Output
 ;    1 = Passes
 ;    0 = Fails
 ;
 N CHECK,POS,I,VAL,CSUM,X
 S NUM=$G(NUM)
 Q:+NUM<1 0
 I $D(VDT) I '$D(VDT(1))!'$D(VDT(2))!'$D(VDT(3)) D  ;
 . K VDT
 ;
 I '$D(VDT) D  ;
 . D VCARRAY(.VDT)
 S CSUM=$E(NUM,$L(NUM),$L(NUM)) ;check digit
 S X=$E(NUM,1,$L(NUM)-1) ;number less check digit
 S CHECK=$$VHCSUM(X,.VDT)
 Q CSUM=CHECK
 ;
 S CHECK=0
 S POS=0
 F I=$L(NUM):-1:1 D  ;
 . S VAL=LRVDT(1,CHECK,LRVDT(2,POS#8,$E(NUM,I,I)))
 . S CHECK=VAL
 . S POS=POS+1
 Q 'CHECK
 ;
 ;
VCARRAY(LRVDT) ;
 ; Build the three tables (arrays) for the Verhoeff check
 ; Private methos
 ; Inputs
 ;   LRVDT: <byref> The array that will hold the Verhoeff data
 ; Outputs
 ;   LRVDT: The three tables needed to compute the Verhoeff check
 ;    LRVDT(I,Y,X)
 ; I=Table id (1=Dihedral multiplication, 2=Function F
 ;             3=Inverse D5)  Y=Row  X=Column
 N DATA,C,R
 K LRVDT
 ; table 1
 S DATA="0123456789"
 F C=0:1:9 S LRVDT(1,0,C)=$E(DATA,C+1,C+1)
 S DATA="1234067895"
 F C=0:1:9 S LRVDT(1,1,C)=$E(DATA,C+1,C+1)
 S DATA="2340178956"
 F C=0:1:9 S LRVDT(1,2,C)=$E(DATA,C+1,C+1)
 S DATA="3401289567"
 F C=0:1:9 S LRVDT(1,3,C)=$E(DATA,C+1,C+1)
 S DATA="4012395678"
 F C=0:1:9 S LRVDT(1,4,C)=$E(DATA,C+1,C+1)
 S DATA="5987604321"
 F C=0:1:9 S LRVDT(1,5,C)=$E(DATA,C+1,C+1)
 S DATA="6598710432"
 F C=0:1:9 S LRVDT(1,6,C)=$E(DATA,C+1,C+1)
 S DATA="7659821043"
 F C=0:1:9 S LRVDT(1,7,C)=$E(DATA,C+1,C+1)
 S DATA="8765932104"
 F C=0:1:9 S LRVDT(1,8,C)=$E(DATA,C+1,C+1)
 S DATA="9876543210"
 F C=0:1:9 S LRVDT(1,9,C)=$E(DATA,C+1,C+1)
 ;
 ; table #2
 S DATA="0123456789"
 F C=0:1:9 S LRVDT(2,0,C)=$E(DATA,C+1,C+1)
 S DATA="1576283094"
 F C=0:1:9 S LRVDT(2,1,C)=$E(DATA,C+1,C+1)
 F R=2:1:7 F C=0:1:9 S LRVDT(2,R,C)=LRVDT(2,R-1,LRVDT(2,1,C))
 ;
 ;table #3
 S DATA="0432156789"
 F C=0:1:9 S LRVDT(3,C)=$E(DATA,C+1,C+1)
 Q
 ;
 ;
VHCSUM(NUM,VDT) ;
 ; Calculate Verhoeffs checksum for number
 ; Inputs
 ;   NUM: Number to generate checksum for
 ;   VDT:<byref><opt> The Viredohf tables (from VCARRAY above)
 ; Outputs
 ;  The single checksum digit for the number.
 ;  VDT array will hold the tables (if VDT passed in).
 N NUM2,CSUM,I,POS,T1,T2
 S NUM=$G(NUM)
 I NUM'=+NUM Q ""
 I $D(VDT) I '$D(VDT(1))!'$D(VDT(2))!'$D(VDT(3)) D  ;
 . K VDT
 ;
 I '$D(VDT) D  ;
 . D VCARRAY(.VDT)
 ;
 S CSUM=0
 S NUM2=$RE(NUM)
 F POS=1:1:$L(NUM2) D  ;
 . S I=$E(NUM2,POS,POS) ;current digit
 . S T2=VDT(2,(POS)#8,I)
 . S T1=VDT(1,CSUM,T2)
 . S CSUM=T1
 ;
 Q VDT(3,CSUM)
