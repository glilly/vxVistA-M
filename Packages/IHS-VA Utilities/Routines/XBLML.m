XBLML ; IHS/ADC/GTH - ENTER OR RESET XB DISPLAY IN LIST TEMPLATE FILE FOR LIST MANAGER ; [ 02/07/97   3:02 PM ]
 ;;3.0;IHS/VA UTILITIES;;FEB 07, 1997
 ;
 W !,"'XB DISPLAY' List Template..."
 S DA=$O(^SD(409.61,"B","XB DISPLAY",0)),DIK="^SD(409.61,"
 D ^DIK:DA
 S DIC(0)="L",DIC="^SD(409.61,",X="XB DISPLAY"
 KILL DO,DD D FILE^DICN
 S VALM=+Y
 I VALM>0 D
 . S ^SD(409.61,VALM,0)="XB DISPLAY^2^^132^2^21^1^1^^^XB DISPLAY^1^^1"
 . S ^SD(409.61,VALM,1)="^VALM HIDDEN ACTIONS"
 . S ^SD(409.61,VALM,"ARRAY")=" ^TMP(""XBLM"",$J,XBNODE)"
 . S ^SD(409.61,VALM,"FNL")="D EXIT^XBLM"
 . S ^SD(409.61,VALM,"HDR")="D HDR^XBLM"
 . S ^SD(409.61,VALM,"HLP")="D HELP^XBLM"
 . S ^SD(409.61,VALM,"INIT")="D INIT^XBLM"
 . S DA=VALM,DIK="^SD(409.61,"
 . D IX1^DIK
 . KILL DA,DIK
 . W "Filed."
 .Q
 ;
 KILL DIC,DIK,VALM,X,DA
 Q
 ;
