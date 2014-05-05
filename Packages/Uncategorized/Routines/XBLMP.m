XBLMP ; ; 16-MAY-1995
 ;; ;
EN ; -- main entry point for XB DISPLAY (PROTOCAL)
 D EN^VALM("XB DISPLAY (PROTOCAL)")
 Q
 ;
HDR ; -- header code
 S VALMHDR(1)="This is a test header for XB DISPLAY (PROTOCAL)."
 S VALMHDR(2)="This is the second line"
 Q
 ;
INIT ; -- init variables and list array
 F LINE=1:1:30 D SET^VALM10(LINE,LINE_"     Line number "_LINE)
 S VALMCNT=30
 Q
 ;
HELP ; -- help code
 S X="?" D DISP^XQORM1 W !!
 Q
 ;
EXIT ; -- exit code
 Q
 ;
EXPND ; -- expand code
 Q
 ;
