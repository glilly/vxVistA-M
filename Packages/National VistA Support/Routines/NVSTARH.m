NVSTARH ;emciss/maw-brief documentation/help ;08/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITY; 01 Jun 1999;;Build 24
 ;
 N DIR,DIROUT,DIRUT,X,Y
 W @IOF
 F NVSX=1:1 S NVSTEXT=$P($T(DESC+NVSX),";;",2) Q:NVSTEXT["@@"!($D(DIRUT))  D
 .I $Y>(IOSL-3) D  Q:$D(DIRUT)
 ..S DIR(0)="E"
 ..W !
 ..D ^DIR K DIR
 ..I '$D(DIRUT) W @IOF
 .W !,NVSTEXT
 I '$D(DIRUT) D
 .S DIR(0)="EA"
 .S DIR("A")="Press <enter> to continue..."
 .W ! D ^DIR K DIR
 K NVSTEXT,NVSX
 Q
 ;        
DESC ;;
 ;;ENTERPRISE MANAGEMENT CENTER :: TEST ACCOUNT RESET UTILITY v6.0
 ;;
 ;;This utility is used to reset various file parameters in order for you
 ;;to use a restored production system as a "test" system.  Following are
 ;;the actions that will be taken.  Note that this utility uses all published
 ;;conventions for file settings, domain naming, and "production" namespace
 ;;(or UCI).  If any errors are encountered during the running of this utility,
 ;;please log a NOIS and seek assistance in getting things set up correctly.
 ;;
 ;;The NVSTAR* routines perform the following actions:
 ;;
 ;; 1. Rename the domain so that it begins with "TEST" (for example:
 ;;    DOMAIN.VA.GOV would be changed to TEST.DOMAIN.VA.GOV).  The introductory
 ;;    text is replaced with something that is meant to scream out to anyone
 ;;    logging onto the system that this is the TEST system.
 ;;
 ;; 2. Close, remove any relay domains, and disable "turn" for ALL domains.
 ;;    If you want to open mail communications from your Test system to your
 ;;    production domain, you will need to do that manually.  You should be
 ;;    very careful, however, to make sure that domains are left closed.
 ;;
 ;; 3. Disable all devices that contain a printer subtype (for example, any device
 ;;    that has a subtype of P-anything will be disabled).  "Disabled" means that
 ;;    the $I values are set equal to the NULL device's $I (the NULL device's $I
 ;;    is retrieved from your Device file automatically).  Also, the OUT-OF-SERVICE
 ;;    DATE field is set to today's date.  Lastly, the QUEUEING field is set to
 ;;    NOT ALLOWED.  (Note that the BROWSER device and the HFS devices are screened
 ;;    out of this process and are NOT disabled.)
 ;;
 ;; 4. Clean up HL7/CIRN/MPI data.  Following are the clean up actions:
 ;;    -In HL LOWER LEVEL PROTOCOL PARAMETER (file 869.2):  deletes TCP/IP
 ;;     addresses from field 400.01.
 ;;    -In HL COMMUNICATION SERVER PARAMETERS (file 869.3):  deletes TCP/IP
 ;;     addresses from field .03.
 ;;    -In HL LOGICAL LINK (file 870):  sets field 4.5 (AUTOSTART) to DISABLED,
 ;;     field 14 (SHUTDOWN LLP?) to YES, and clears TCP/IP addresses from field
 ;;     400.01.  Also, devices listed in file 870 are pointers to the Device file
 ;;     (#3.5), so these device entries in file 3.5 are also disabled using the
 ;;     same reset process described in Step 3 above.
 ;;    -In HL7 MESSAGE ADMINISTRATION (file 773):  sets field 20 (STATUS) to
 ;;     SUCCESSFULLY COMPLETED, and deletes the "AC" cross reference.
 ;;
 ;; 5. Clean up RAI/MDS data.
 ;;    This module loops through the WARD LOCATION file (#42) and sets the
 ;;    RAI/MDS WARD field (#.035) to 0 (zero) to disable any possible HL7
 ;;    transmissions to a COTS database (reference patch DG*5.3*190).
 ;;
 ;; 6. DELETE CIRN MPI DATA"
 ;;    This call loops through ^DPT and deletes CIRN MPI data brought over from
 ;;    a Production account refresh of a mirrored Test account.  Only CMOR
 ;;    activity scores with be left intact.  It will also kill several CIRN-related
 ;;    cross references.  Finally, it will delete the entries in the following
 ;;    files:
 ;;      SUBSCRIPTION CONTROL file (#774)
 ;;      TREATING FACILITY file (#391.91)
 ;;      PATIENT DATA EXCEPTION file (#391.98)
 ;;      PATIENT DATA ELEMENT file (#391.99)
 ;;   
 ;; 7. Reset selected %Z globals.  All the entries in the schedule file (^%ZTSCH),
 ;;    the task file (^%ZTSK), the failed access attempts log (^%ZUA(3.05)), and
 ;;    the programmer mode log (^%ZUA(3.07)) are deleted and the top levels of the
 ;;    globals reset appropriately.  NOTE:  All scheduled tasks are deleted.  If
 ;;    you have any scheduled options that you wish to run, you will have to use
 ;;    the Task Manager option "Schedule/Unschedule Options" (XUTM SCHEDULE) to
 ;;    reschedule the options to run at your desired dates and times.
 ;;
 ;; 8. Reset RPC Broker Parameters file -- so that Broker will start up correctly
 ;;    once TaskMan is started.  Note:  this procedure examines the RPC BROKER
 ;;    PARAMETERS file (file number 8994.1, global ^XWB(8994.1,...)).  If this
 ;;    file is not present on your system, or if you have not set it up correctly,
 ;;    you will receive a message stating that fact.  If the file is not present,
 ;;    or it is not set up correctly, THIS IS NOT A FAILURE EVENT.  Whatever Broker
 ;;    startup procedure you currently have in place will have to be used to
 ;;    restart the RPC Broker listener.
 ;;
 ;; 9. Clean up outgoing network mail.  This module processes through POSTMASTER's
 ;;    network mail baskets and cleans out any messages pending transmission to
 ;;    the remote site.
 ;;   
 ;;10. Re-enable logons in the Volume Set file.  This is an optional step.  When
 ;;    you start the reset procedures (DO ^NVSTAR), you are asked whether you wish
 ;;    this particular part to run automatically.  If you choose not to allow this
 ;;    part to run automatically, logons will remain disabled.  Otherwise, this
 ;;    part processes all entries in the Volume Set file (#14.5) and re-enables
 ;;    logons.
 ;;
 ;;IMPORTANT NOTE:  If a fatal error occurs, fix the problem that caused the
 ;;error (remember, log a NOIS if you need help) and then restart the entire
 ;;reset procedure by DO ^NVSTAR.  The entire reset procedure can be done
 ;;repeatedly without problems because the software is designed to know what
 ;;reset procedures have already been accomplished.
 ;;@@
