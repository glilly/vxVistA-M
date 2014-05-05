VFDXTMTH ;DSS/SGM - MATH FUNCTIONS ; 06/20/2011 13:15
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via the VFDXT routine menu driver
 ;
MEDIAN(VFDLIST) ; Return median value for a list of number
 ; VFDLIST - req - named reference containing the list of number where
 ;           @vfdlist@(value) =  total number of instances of value
 ;           value must be a numeric
 ; Return -1^messagge if problems
 N D,I,J,L,X,Y,Z,ERR,MID,TOT
 I $G(VFDLIST)="" Q "-1^No list received"
 I $O(@VFDLIST@(""))="" Q "-1^No values received"
 S TOT=0,I="" F  S I=$O(@VFDLIST@(I)) Q:I=""  D  Q:$D(ERR)
 .I I'=+I S ERR="-1^Non-numeric values received"
 .E  S TOT=TOT+@VFDLIST@(I)
 .Q
 I $D(ERR) Q ERR
 S I="",Z=0,MID=TOT\2 I TOT#2 S MID=MID+1
 F  S I=$O(@VFDLIST@(I)) Q:I=""  S Y=@VFDLIST@(I),Z=Z+Y Q:Z'<MID
 ; in odd number of entries, then one entry is the mid point
 I TOT#2 Q I
 ; only even number of entries left
 ; mid is entry lower than the median, mid+1 is the entry above median
 I Z>MID Q I
 S J=$O(@VFDLIST@(I))
 S D=$L($P(I,".",2)) I $L($P(J,".",2))<D S D=$L($P(J,".",2))
 S X=I+J/2 I $L($P(X,".",2))'<(D+1) D
 .S Y="",$P(Y,"0",D+1)=5,Y="."_Y,X=(I+J)/2+Y
 .Q
 Q $J(X,0,D)
