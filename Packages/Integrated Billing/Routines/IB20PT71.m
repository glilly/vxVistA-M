IB20PT71 ;ALB/CPM - REMOVE OPTIONS FROM MENUS ; 11-FEB-94
 ;;Version 2.0 ; INTEGRATED BILLING ;; 21-MAR-94
 ;
 D DEL ;    Delete 'IB UB-82 TEST PATTERN PRINT' from output menu
 D NEWF ;   Delete 'New Features of Integrated Billing' from menus
 D NEWCR ;  Add new cancellation reasons into file #350.3
 Q
 ;
 ;
DEL ; Delete 'IB UB-82 TEST PATTERN PRINT' from 'IB OUTPUT PATIENT REPORT MENU'
 S Y=$O(^DIC(19,"B","IB OUTPUT PATIENT REPORT MENU",0)) Q:Y=""
 S X=$O(^DIC(19,"B","IB UB-82 TEST PATTERN PRINT",0)) Q:X=""
 S X=$O(^DIC(19,+Y,10,"B",X,0)) Q:'X
 S DA(1)=+Y,DA=+X,DIK="^DIC(19,"_+Y_",10," D ^DIK K DA,DIK
 W !!,">>> Deleted IB UB-82 TEST PATTERN PRINT from IB OUTPUT PATIENT REPORT MENU..."
 Q
 ;
NEWF ; Delete 'New Features of Integrated Billing' from menus
 S IBX=$O(^DIC(19,"B","IB NEW FEATURES 1.5",0)) I 'IBX G NEWFQ
 S IBN=0 F  S IBN=$O(^DIC(19,"AD",IBX,IBN)) Q:'IBN  D
 .S IBNAME=$G(^DIC(19,IBN,0)) Q:IBNAME=""
 .S IBY=0 F  S IBY=$O(^DIC(19,"AD",IBX,IBN,IBY)) Q:'IBY  D
 ..S DA(1)=IBN,DA=IBY,DIK="^DIC(19,"_IBN_",10," D ^DIK K DA,DIK
 ..W !!,">>> Deleted 'IB NEW FEATURES 1.5' from '",$P(IBNAME,"^"),"'"
NEWFQ K DA,DIK,IBN,IBNAME,IBX,IBY
 Q
 ;
NEWCR ; Add new cancellation reasons into file #350.3
 W !!,">>> Adding new cancellation reasons into file #350.3..."
 F IBI=1:1 S IBCR=$P($T(CRES+IBI),";;",2) Q:IBCR="QUIT"  D
 .S X=$P(IBCR,"^")
 .I $O(^IBE(350.3,"B",X,0)) W !," >> '",X,"' is already on file..." Q
 .K DD,DO S DIC="^IBE(350.3,",DIC(0)="" D FILE^DICN Q:Y<0
 .S DIE=DIC,DA=+Y,DR=".02////"_$P(IBCR,"^",2)_";.03////"_$P(IBCR,"^",3) D ^DIE
 .W !," >> '",$P(IBCR,"^"),"' has been filed..."
 K DA,DIC,DIE,DR,IBI,IBCR,X,Y
 Q
 ;
 ;
CRES ; Cancellation Reasons to add into file #350.3
 ;;MT CATEGORY CHANGED FROM C^NOT C^2
 ;;COMP & PENSION VISIT RECORDED^CNP VST^2
 ;;CHAMPVA ADMISSION DELETED^CVA DEL^2
 ;;RECD INPATIENT CARE^INP CARE^2
 ;;CHECK OUT DELETED^CO DEL^2
 ;;CLASSIFICATION CHANGED^CLS CHNG^2
 ;;RESEARCH VISIT/ADMISSION^RES VST^2
 ;;SERVICE CONNECTED VISIT/ADM^SER CONN^2
 ;;HARDSHIP GRANTED^HRDSHP^2
 ;;ADJUDICATED AS CATEGORY A^ADJ A^2
 ;;TREATED AT OTHER FACILITY^OTH FAC^2
 ;;AGENT ORANGE RELATED VISIT^AO VST^2
 ;;IONIZING RAD RELATED VISIT^IO VST^2
 ;;ENV CONTAMINANT RELATED VISIT^EC VST^2
 ;;CLASS II DENTAL VISIT^DENTL^2
 ;;QUIT