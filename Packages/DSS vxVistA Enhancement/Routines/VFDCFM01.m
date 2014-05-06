VFDCFM01 ;DSS/SGM - COMMON FILEMAN UTILITIES ; 01/30/2013 13:27
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 13
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;  this contains common Fileman utilities that is often repeated
 ;
 ; DBIA#   SUPPORTED
 ; -----   -----------------------------
 ;  2050   MSG^DIALOG
 ; 10006   ^DIC
 ; 10026   ^DIR
 ;         ^%DT
 ;
DATE(VFDXSD,VFDXED) ; uitilty to prompt for start/end date
 ; can be called as an extrinsic function or DO w/params
 ; INPUT PARAMS: .VFDXSD() and .VFDXED()
 ;   1. Both parameters will merged into the %DT variable
 ;   2. Both will set up call to >D ^%DT
 ;   3. See FM documentation on how to call ^%DT
 ;   4. Both SD and ED are optional
 ;   4  Default values (if no value passed):
 ;       SD: %DT="AET"   %DT("A")="Start Date: "
 ;       ED: %DT="AET"   %DT("A")="  End Date: "   %DT("B")="TODAY"
 ;
 ; RETURN VALUES:
 ;   1. API will K VFDXSD,VFDXED
 ;   2. Upon timeout, "^"-out, or no date entered:
 ;        VFDXSD=-1    $D(VFDXED)=0   Extrinsic function value = -1
 ;   3. If both a starting date and ending entered, return:
 ;        VFDXSD    = start date(time) in FM format
 ;        VFDXSD(0) = start date(time) in human readable format
 ;        VFDXED    = end date(time) in FM format
 ;        VFDXED(0) = end date(time) in human readable format
 ;          if VFDXED entered as date only, then return VFDXED_".24"
 ;        Extrinsic function returns:
 ;           VFDXSD_U_VFDXSD(0)_U_VFDXED_U_VFDXED(0) or -1
 ;
 N %,%DT,A,I,X,Y,Z,DTOUT,DUOUT
 ;
 M %DT=VFDXSD K VFDXSD
 S:$G(%DT)="" %DT="AET"
 S:$G(%DT("A"))="" %DT("A")="Start Date: "
 W ! D ^%DT I Y=-1 S VFDXSD=-1 Q Y
 S VFDXSD=Y,VFDXSD(0)=$$FMTE^XLFDT(Y,"5Z")
 ;
 K %DT M %DT=VFDXED K VFDXED
 S:$G(%DT)="" %DT="AET"
 S:$G(%DT("A"))="" %DT("A")="  End Date: "
 S:$G(%DT("B"))="" %DT("B")="TODAY"
 W ! D ^%DT I Y=-1 K VFDXSD S VFDXSD=-1 Q Y
 S:Y'["." Y=Y_".24"
 S VFDXED=Y,VFDXED(0)=$$FMTE^XLFDT(Y,"5Z")
 S X=VFDXSD_U_VFDXSD(0)_U_VFDXED_U_VFDXED(0)
 Q X
 ;
DIC(A) ;  utility to invoke ^DIC
 ;  pass by reference DIC() array
 ;  Return Y from ^DIC or -1 on ^out or -2 on timeout
 N X,Y,DIC,DTOUT,DUOUT
 M DIC=A K A
 I '$D(DIC) Q -1
 W ! D ^DIC
 S X=$S($D(DUOUT):-1,$D(DTOUT):-2,1:Y)
 K A M A=Y
 Q X
 ;
DIR(DIR) ;  utility to invoke ^DIR
 ;  pass by reference DIR() array
 ;  Return the value of Y from ^DIR
 ;  On up-arrow out or time-out, return -1 for ^-out, -2 for time out
 N X,Y,DIROUT,DIRUT,DTOUT,DUOUT
 I '$D(DIR) Q -1
 W ! D ^DIR
 Q $S($D(DUOUT):-1,$D(DTOUT):-2,1:Y)
 ;
MSG(FLGS,VFDROUT,WIDTH,LEFT,INPUT) ;
M ; called from MSG^VFDCFM
 ;  this api will format the text using the MSG^DIALOG api
 ;
 ;  FLGS - opt - default = "AE"
 ;    FLGS [ A - return results in OUT - passed by ref
 ;           W - write to current device
 ;           S - save ^TMP or INPUT (don't kill)
 ;           E - process error array
 ;           H - process help array
 ;           M - process message array
 ;           B - blank lines suppressed between error msgs
 ;           T - Return Total number of lines in the top level of OUT
 ;    OUT - opt/req - local array passed by reference
 ;          to return messages.  See FLGS parameter
 ;  WIDTH - opt - default= 72  max length of each line to return
 ;   LEFT - opt - default=0   pad LEFT spaces to return array
 ;  INPUT - opt - default assumes ^TMP("DIxxx",$J)
 ;          Closed root name of local input array where text resides
 ;
 ;  If called as an Extrinsic Function then the input parameters OUT,
 ;    WIDTH, and LEFT are meaningless.
 ;  If no input array, return error message
 ;
 N I,X,Y,Z,VFDMSG,VFDOUT
 ; 3/12/2012 - SGM - V flag deprecated in favor of $Q intrinsic var
 S X=$TR($G(FLGS),"V") D
 . S:X="" X="AE"
 . I $Q S:X'["B" X=X_"B"
 . E  S:X'["A" X=X_"A"
 . S FLGS(0)=(X["A")
 . S:X'["A" X=X_"A" S FLGS=X ; get output in OUT() to manipulate
 . Q
 S WIDTH=$G(WIDTH) S:'WIDTH WIDTH=72
 S LEFT=+$G(LEFT) S:$Q LEFT=0
 I FLGS["E" D M1("DIERR")
 I FLGS["H" D M1("DIHLP")
 I FLGS["M" D M1("DIMSG")
 I $Q S Z="" D
 . F I=1:1 Q:'$D(VFDMSG(I))  S Z=Z_VFDMSG(I)_" "
 . I Z="" S Z="No Data found"
 . S VFDROUT=Z
 . Q
 I FLGS["A" M VFDROUT=VFDMSG
 I FLGS'["S" K:$G(INPUT)'="" @INPUT D CLEAN^DILF
 Q:$Q VFDROUT Q
 ;
M1(VFDSUB) ;
 N I,J,X,Y,Z,VFDI,VFDTMP
 I $G(INPUT)'="" M VFDI(VFDSUB)=INPUT(VFDSUB)
 I '$D(VFDI) M VFDI(VFDSUB)=^TMP(VFDSUB,$J)
 Q:'$D(VFDI)
 S Z="AE" S:FLGS["B" Z=Z_"B" S:FLGS["W" Z=Z_"W"
 D MSG^DIALOG(Z,.VFDTMP,WIDTH,LEFT,"VFDI")
 S I=0,J=$O(VFDMSG(" "),-1)
 F  S I=$O(VFDTMP(I)) Q:'I  S J=J+1,VFDMSG(J)=VFDTMP(I)
 Q
 
