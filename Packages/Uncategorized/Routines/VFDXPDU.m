VFDXPDU ;DSS/LM - Build/Transport/Install support ;06 Sep 2010
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;----------------------  CALLS TO XPDID ROUTINE  ---------------------
INIT ; initialize the KIDS graphic screen showing the progress bar
 ; Also, INIT^XPDID will set the Boolean variable XPDIDVT indicating
 ; whether or not the terminal supports graphics mode.  The variable
 ; XPDIDVT will be used as a flag in the other calls below
 D XPDIDIN^VFDXPDU1
 Q
 ;
TITLE(TEXT) ; update the title bar in the progress bar display
 I $G(XPDIDVT),$G(TEXT)'="" D XPDIDTIT^VFDXPDU1(TEXT)
 Q
 ;
UPDATE(COUNT,TOTAL) ; update progress bar
 ; COUNT - opt - the current count, default to zero
 ; TOTAL - opt - total number, display %-progress of count/total
 ;               default to 100
 D XPDIDUP^VFDXPDU1($G(COUNT),$G(TOTAL))
 Q
 ;
EXIT(TEXT) ; exit progress bar screen, clean up variables, write
 ; parting text
 D XPDIDEX^VFDXPDU1($G(TEXT))
 Q
