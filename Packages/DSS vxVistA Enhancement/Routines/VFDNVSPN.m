VFDNVSPN ;DSS/LM - Remove Progress Notes
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;;Build 24
 ;
 ;
SIGSET(VFDIEN) ;Wraps SIGSET^TIUPNCV
 ;
 ; VFDIEN=[Required] TIU Document IEN
 ; Sets ^TIU(8925 signature fields
 ; 
 I $G(VFDIEN) Q:'$D(^TIU(8925,VFDIEN))  N TIU,TIUIFN,I,Y S Y=0
 E  Q
 S Y=$$INVSIG($G(^TIU(8925,VFDIEN,15))) Q:'$L($TR(Y,U))  F I=1:1:13 S TIU(1500+I)=$P(Y,U,I)
 S TIUIFN=VFDIEN D SIGSET^TIUPNCV
 Q
WP(VFDIEN,VFDFLD) ;Wraps WP^DIE
 ;
 ; VFDIEN=[Required] TIU Document IEN
 ; VFDFLD=[Optional] Field. Defaults to #2 REPORT TEXT
 ;                          Override to #3 EDIT TEXT BUFFER
 ; 
 I $G(VFDIEN) S VFDFLD=$G(VFDFLD,2) I "^2^3^"[(U_VFDFLD_U) N VFDIENS,VFDTXT
 E  Q
 S VFDIENS=+VFDIEN_","
 S VFDTXT(1,0)=" "
 S VFDTXT(2,0)="<<"_$S(VFDFLD=2:"Report",VFDFLD=3:"Edit buffer",1:"?")_" text goes here>>"
 S VFDTXT(3,0)=" "
 D WP^DIE(8925,VFDIENS,VFDFLD,,$NA(VFDTXT))
 Q
INVSIG(VFDY) ;Invert [CO]SIGNATURE BLOCK NAME and TITLE fields in VFDY
 ; VFDY=Subscript 15 of TIU document entry.
 ; 
 S VFDY=$G(VFDY) N VFDDUZ,VFDX
 S VFDDUZ=$P(VFDY,U,2) D:VFDDUZ&($P(VFDY,U,5)="E")
 .S VFDX=$G(^VA(200,+VFDDUZ,20))
 .S $P(VFDY,U,3)=$P(VFDX,U,2)
 .S $P(VFDY,U,4)=$P(VFDX,U,3)
 .Q
 S VFDDUZ=$P(VFDY,U,8) D:VFDDUZ&($P(VFDY,U,11)="E")
 .S VFDX=$G(^VA(200,+VFDDUZ,20))
 .S $P(VFDY,U,9)=$P(VFDX,U,2)
 .S $P(VFDY,U,10)=$P(VFDX,U,3)
 .Q
 Q VFDY
 ;
TEXT(VFDIEN) ;Convert text and re-sign one signed note.
 ; VFDIEN=[Required] TIU Document IEN
 Q:'$G(VFDIEN)  D WP(VFDIEN),SIGSET(VFDIEN)
 Q
TEMP(VFDIEN) ;Convert temp and optionally text of unsigned note.
 ; VFDIEN=[Required] TIU Document IEN
 Q:'$G(VFDIEN)  D:$O(^TIU(8925,VFDIEN,"TEMP",0)) WP(VFDIEN,3)
 Q:$D(^TIU(8925,VFDIEN,15))  ;Signed
 D:$O(^TIU(8925,VFDIEN,"TEXT",0)) WP(VFDIEN)
 Q
BOTH(VFDIEN) ;Convert text of signed note and re-sign
 ; If note has data in EDIT TEXT BUFFER, convert that also
 ; If note has unsigned data in REPORT TEXT, convert that
 ; 
 Q:'$G(VFDIEN)
 D:$D(^TIU(8925,VFDIEN,15)) TEXT(VFDIEN)
 D TEMP(VFDIEN)
 Q
ALL ;Process all File 8925 entries
EN ;Main entry
 ;
 W !!,"** WARNING ** This option modifies all TIU DOCUMENT entries!"
 W !,"              REPORT TEXT and EDIT TEXT BUFFER contents will be deleted"
 W !,"              and replaced with generic stub entries."
 W !!,"              TIU DOCUMENT report contents CANNOT BE RECOVERED after"
 W !,"              running this option."
 W !!,"              Do not run this option in any production environment!"
 W !
 N DIR,DIRUT,X,Y S DIR(0)="Y",DIR("A")="Are you sure you want to proceed",DIR("B")="N"
 D ^DIR Q:$D(DIRUT)
 I '(Y=1) W !!,"Conversion of documents aborted.",! Q
 W !!,"**  INFO.  ** This process may take considerable time, depending upon the"
 W !,"              size of the TIU DOCUMENT file.  Progress is indicated by dots."
 W !,"              One dot is displayed for every 100 documents processed."
 W !
 K DIR S DIR(0)="E" D ^DIR Q:$D(DIRUT)
 W ! D WAIT^DICD W !! N VFDA,VFDI
 S VFDA=0 F VFDI=1:1 S VFDA=$O(^TIU(8925,VFDA)) Q:'VFDA  D
 .D BOTH(VFDA) ;Process entry
 .W:'(VFDI#100) "."
 .Q
 Q
