APCDVD ; IHS/CMI/TUCSON - NO DESCRIPTION PROVIDED 18-MAY-1995 ; [ 12/21/03  1:08 PM ]
 ;;2.0;IHS RPMS/PCC Data Entry;**7**;MAR 09, 1999
 ;; ;
EN ;PEP -- main entry point for APCD VISIT DISPLAY
 K ^TMP("APCDVDSG",$J)
 Q:'$G(APCDVSIT)
 I '$G(APCDLIML) D EN^APCDVDSG(APCDVSIT)
 I $G(APCDLIML)=1 D EN^APCDVDSB(APCDVSIT) K APCDLIML
 D EN^VALM("APCD VISIT DISPLAY")
 K ^TMP("APCDVDSG",$J),APCDBROW
 D CLEAR^VALM1
 D FULL^VALM1
 Q
 ;
EN1 ;EP - called from input templates
 D EN^XBNEW("EN^APCDVD","APCDVSIT")
 K Y
 Q
HDR ; -- header code
 Q
 ;
INIT ; -- init variables and list array
 S VALMCNT=$O(^TMP("APCDVDSG",$J,""),-1)
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
