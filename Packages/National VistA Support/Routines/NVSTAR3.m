NVSTAR3 ;emc/maw-disable all print devices ;09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 ; this routine goes through the Device file and examines the sub-type
 ; for each device.  If the device's sub-type contains "P-", then the $I field
 ; is set equal to the NULL device, the OUT-OF-SERVICE DATE is set to DT, and
 ; the QUEUING field is set to NOT ALLOWED.  Note, however, that there is a
 ; screen so that devices with the sub-type of P-MESSAGE, P-BROWSER, P-HFS
 ; *AND* P-OTHER are NOT disabled.  You should specifically check devices that
 ; use the P-OTHER sub-type to make sure that you get all actual printers
 ; disabled.
 ;
 W !!,"DISABLE PRINT DEVICES"
 W !?2
 ; see if we can retrieve the null device's $I from the device file...
 S NVSNULDV=$G(^XTMP("NVSTAR","NULL DEVICE"))
 I NVSNULDV="" W !?2,"No $I for NULL device!  Aborted!" K NVSNULDV Q
 ;
 S NVSDEV=0
 F  S NVSDEV=$O(^%ZIS(1,NVSDEV)) Q:'NVSDEV  D
 .;
 .; for all devices, remove any data in the volume set(cpu) field...
 .S NVSFILE(3.5,NVSDEV_",",1.9)="@"
 .D FILE^DIE("E","NVSFILE","NVSDIERR")
 .K NVSDIERR,NVSFILE
 .;
 .; check device's subtype -- we're looking for printer subtypes...
 .S NVSSTYPE=+$G(^%ZIS(1,NVSDEV,"SUBTYPE"))
 .S NVSSTYPE=$P($G(^%ZIS(2,NVSSTYPE,0)),U)
 .I $E(NVSSTYPE)'="P" D  Q
 ..S $P(^XTMP("NVSTAR",3,0),U,4)=NVSDEV
 .;
 .; if subtype is P-OTHER, check TYPE.  if TYPE'=TRM then leave it alone...
 .S NVSTCHK=0
 .I NVSSTYPE["OTHER"&($G(^%ZIS(1,NVSDEV,"TYPE"))'="TRM") S NVSTCHK=1
 .; *but*, if the device type is network channel, let's reset the check
 .; flag and continue with disabling it...
 .I $G(^%ZIS(1,NVSDEV,"TYPE"))="CHAN" S NVSTCHK=0
 .I NVSTCHK=1 K NVSTCHK Q
 .K NVSTCHK
 .;
 .; don't disable the null device...
 .I NVSDEV=+NVSNULDV Q
 .;
 .; don't disable P-MESSAGE, P-BROWSER, and P-HFS devices...
 .I NVSSTYPE["MESSAGE"!(NVSSTYPE["BROWSER")!(NVSSTYPE["HFS") Q
 .;
 .; edit the record...
 .D DEDIT(NVSDEV,NVSNULDV)
 .I $X>(IOM-10) W !?2
 .W "."
 ;
 K NVSDEV,NVSSTYPE
 Q
 ;
DEDIT(DEVIEN,NULLDEV)   ; edit device file fields...
 ; DEVIEN  = device file record number
 ; NULLDEV = the $I value for this system's NULL device
 ;
 I $G(DEVIEN)'>0 Q
 N NVSDIERR,NVSFILE
 ;
 ; set OUT-OF-SERVICE DATE field to today's date...
 S NVSFILE(3.5,DEVIEN_",",6)=$$FMTE^XLFDT($$DT^XLFDT)
 ;
 ; set QUEUEING field to not allowed...
 S NVSFILE(3.5,DEVIEN_",",5.5)="NOT ALLOWED"
 ;
 ; edit $I to that of the null device...
 I $P($G(NULLDEV),"^",2)'="" S NVSFILE(3.5,DEVIEN_",",1)=$P(NULLDEV,"^",2)
 ;
 ; delete anything in the OPEN PARAMETERS field...
 S NVSFILE(3.5,DEVIEN_",",19)="@"
 ;
 ; call FM DBS to update the record...
 D FILE^DIE("E","NVSFILE","NVSDIERR")
 Q
 Q
