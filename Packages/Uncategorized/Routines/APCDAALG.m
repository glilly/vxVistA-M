APCDAALG ;IHS/CMI/LAB - ALLERGY ENTRY INTO ALLERGY PACKAGE [ 02/04/04  2:26 PM ]
 ;;2.0;IHS RPMS/PCC Data Entry;**7**;MAR 09, 1999
 ;
 ;
EP ;
 I '$D(^XUSEC("GMRA-USER",DUZ)) W !!,"You have not been assigned the Allergy Tracking verifier key.",!,"Please see your supervisor.",! Q
 I $T(EN21^GMRAPEM0)="" W !!,"The Allergy tracking system has not been installed.",!,"Enter allergies through the problem list.",! Q
 S DFN=APCDPAT
 D EN^XBNEW("EP1^APCDAALG","DFN")
 I '$G(DFN) S DFN=APCDPAT
 Q
EP1 ;
 D EN21^GMRAPEM0
 D EN^XBVK("GMRA"),EN^XBVK("VA")
 Q
