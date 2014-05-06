SISP8 ;SIS/LM - Clone and optionally modify routine DGRP8
 ;;1.0;NON-VA REGISTRATION;;;Build 15
 ;Copyright 2008 - 2009, Sea Island Systems, Inc.  Rights are granted as follows:
 ;Sea Island Systems, Inc. conveys this modified VistA routine to the PUBLIC DOMAIN.
 ;This software comes with NO warranty whatsoever.  Sea Island Systems, Inc. will NOT be
 ;liable for any damages that may result from either the use or misuse of this software.
 ;
DGRP8 ;ALB/MIR - FAMILY DEMOGRAPHIC SCREEN DISPLAY ; 12 FEB 92
 ;;5.3;Registration;**45,54,487**;Aug 13, 1993
 ;
 ; Screen to display current spouse and dependents
 ;
EN I $D(DVBGUI) G ENQ ; IF CALLED BY CAPRI, SKIP SCREEN 8
 ;
 ; Start display
 N DGMTYPT,DGMTCP,DGXR,DGSCR8
 S DGSCR8=1 D EN^DGDEP
 ;
ENQ S X=132 X ^%ZOSF("RM")
 N I,X F I=9:1 S X=$E(DGRPVV,I) Q:'X
 S DGRPANN="^"_I
 G JUMP^SISPP ; jumps to next 'on' screen
