XMCE ;ISC-SF/GMB-Edit Scripts ;04/17/2002  08:39
 ;;8.0;MailMan;;Jun 28, 2002
 ; Was (WASH ISC)/THM
 ;
 ; Entry points used by MailMan options (not covered by DBIA):
 ; VAL     XMEDIT-DOMAIN-VALIDATION#     (was VAL^XMC2)
 ; OUT     XMSCRIPTOUT                   (was OUT^XMC2)
 ; EDIT42  XMSCRIPTEDIT                  (was EDIT^XMC11)
 ; EDIT46  XMSUBEDIT                     (was EDITSC^XMC11)
 Q
OUT ; Toggle script out of service
 N XMINST,XMSITE,XMABORT,DA,DR,DIE,X,Y
 S XMABORT=0
 D ASKINST^XMCXU(.XMINST,.XMSITE,.XMABORT) Q:XMABORT
 S DA=XMINST
 S DR="1"         ; Flags
 S DR=DR_";4"     ; Scripts
 S DR(2,4.21)=1.5 ; Only the 'out of order' field in the Script multiple
 S DIE="^DIC(4.2,"
 D ^DIE
 Q:'$$BMSGCT^XMXUTIL(.5,XMINST+1000)  ; Quit if no msgs queued.
 D CHKTSK^XMCXU(XMINST,1,.XMABORT) Q:XMABORT
 D ASKSCR^XMCXU(XMINST,XMSITE,.XMB,.XMABORT)
 D QUEUE^XMCX(XMINST,XMSITE,.XMB)
 Q
VAL ; Edit domain validation number
 N XMINST,XMSITE,XMABORT,DA,DR,DIE,X,Y
 S XMABORT=0
 D ASKINST^XMCXU(.XMINST,.XMSITE,.XMABORT) Q:XMABORT
 S DIE=4.2,DA=XMINST,DR="1.6"
 D ^DIE
 Q
EDIT42 ; Edit fields in file 4.2, DOMAIN
 N XMINST,XMSITE,XMTSK,XMABORT,DA,DR,DIE,X,Y
 S XMABORT=0
 D ASKINST^XMCXU(.XMINST,.XMSITE,.XMABORT) Q:XMABORT
 S DIE=4.2,DA=XMINST,DR="17;1:4.2;6.2:6.9",DR(2,4.21)=".01;1:99"
 D ^DIE
 S XMTSK=$P($G(^XMBS(4.2999,DA,3)),U,7)
 S DIE=4.2999,DR=25
 D ^DIE
 Q:'XMTSK
 Q:'$P($G(^XMBS(4.2999,DA,3)),U,7)
 D KILLTSK^XMKPR(DA,XMTSK)
 Q
EDIT46 ; Edit TRANSMISSION SCRIPT name and text in file 4.6
 N DIC,DLAYGO,X,Y
 S (DLAYGO,DIC)=4.6,DIC(0)="AEQML"
 D ^DIC Q:Y<0
 N DIE,DR,DA
 S DA=+Y,DIE=4.6,DR=".01;1"
 D ^DIE
 Q