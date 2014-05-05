NVSPDS1 ;emciss/maw-scramble patient data (continued) ; 09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 ; called from ^NVSPDS
 ; Note:  the variable NVSDFN is set in the main loop through ^DPT(...)
 ;        that begins in routine ^NVSPDS.
 ;
 I '$D(NVSDFN) Q
 ;
 ; delete any aliases on file for this patient (we'd have to scramble them and
 ; basically make them completely useless, so let's get rid of them)...
 S NVSX=NVSDFN
 S NVSY=0
 F  S NVSY=$O(^DPT(NVSX,.01,NVSY)) Q:'NVSY  D
 .S DA=NVSY
 .S DA(1)=NVSX
 .S DIK="^DPT("_DA(1)_",.01,"
 .D ^DIK
 .K DA,DIK
 K NVSX,NVSY
 ;
 ; retrieve the zero-eth node of the patient's record...
 S NVSDATA(0)=^DPT(NVSDFN,0)
 ;
 ; make sure the patient's unscrambled name is in the VistA standard format...
 S NVSNAME=$P(NVSDATA(0),U)
 D STDNAME^XLFNAME(.NVSNAME,"FGP",.NVSNAUD)
 S $P(NVSDATA(0),U)=NVSNAME
 K NVSNAME,NVSNAUD
 ; 
 ; scramble patient's name...
 ;DSS/RAC - BEGIN MODS-If using Vx Scrambler send Sex to scramble name
 ;S $P(NVSDATA(0),U)=$$REVN^NVSPDSU($P(NVSDATA(0),U))
 I '$D(^TMP("VFDNVS01",$J)) S $P(NVSDATA(0),U)=$$REVN^NVSPDSU($P(NVSDATA(0),U))
 I $D(^TMP("VFDNVS01",$J)) S $P(NVSDATA(0),U)=$$NAME^VFDNVS02($P(NVSDATA(0),U,2))
 ;DSS/RAC END MODS
 ;
 ; set scrambled name into $P(1) of patient's record...
 S $P(^DPT(NVSDFN,0),U)=$P(NVSDATA(0),U)
 ;
 ; pull the other data nodes we want to work with...
 F NVSX=.11,.111,.12,.121,.13,.24 S NVSDATA(NVSX)=$G(^DPT(NVSDFN,NVSX))
 ;
 ; change place of birth (city and state)... 
 I $P(NVSDATA(0),U,11)'="" S $P(^DPT(NVSDFN,0),U,11)=$$CITY^NVSPDSU
 I $P(NVSDATA(0),U,12)'="" S $P(^DPT(NVSDFN,0),U,12)=+$$ST^NVSPDSU
 ;
 ; change current address node...
 I NVSDATA(.11)'="" D
 .S $P(NVSDATA(.11),U,4)=$$CITY^NVSPDSU
 .S $P(NVSDATA(.11),U,5)=+$$ST^NVSPDSU
 .I $P(NVSDATA(.11),U,6)'="" D
 ..S $P(NVSDATA(.11),U,6)=$$ZIP^NVSPDSU($P(NVSDATA(.11),U,6))
 .S $P(NVSDATA(.11),U,7)=$$CTY^NVSPDSU(+$P(NVSDATA(.11),U,5))
 .I $P(NVSDATA(.11),U,12)'="" D
 ..S $P(NVSDATA(.11),U,12)=$$ZIP^NVSPDSU($P(NVSDATA(.11),U,12))
 .S ^DPT(NVSDFN,.11)=NVSDATA(.11)
 ;
 ; change legal residence node...
 I NVSDATA(.111)'="" D
 .S $P(NVSDATA(.111),U,4)=$$CITY^NVSPDSU
 .S $P(NVSDATA(.111),U,5)=+$$ST^NVSPDSU
 .I $P(NVSDATA(.111),U,6)'="" D
 ..S $P(NVSDATA(.111),U,6)=$$ZIP^NVSPDSU($P(NVSDATA(.111),U,6))
 .S $P(NVSDATA(.111),U,7)=$$CTY^NVSPDSU($P(NVSDATA(.111),U,5))
 .S ^DPT(NVSDFN,.111)=NVSDATA(.111)
 ;
 ; change prior address node...
 I NVSDATA(.12)'="" D
 .S $P(NVSDATA(.12),U,4)=$$CITY^NVSPDSU
 .S $P(NVSDATA(.12),U,5)=+$$ST^NVSPDSU
 .I $P(NVSDATA(.12),U,6)'="" D
 ..S $P(NVSDATA(.12),U,6)=$$ZIP^NVSPDSU($P(NVSDATA(.12),U,6))
 .I $P(NVSDATA(.12),U,7)'="" D
 ..;
 ..; up to now, NVSNCNTY=a number, this county field requires free text...
 ..S NVSNST=+$$ST^NVSPDSU
 ..S NVSNCNTY=+$$CTY^NVSPDSU(NVSNST)
 ..S NVSNCNTY=$P(^DIC(5,NVSNST,1,NVSNCNTY,0),U)
 ..I NVSNCNTY="" S NVSNCNTY="SOMECOUNTY"
 ..S $P(NVSDATA(.12),U,7)=NVSNCNTY
 ..K NVSNCNTY,NVSNST
 .S ^DPT(NVSDFN,.12)=NVSDATA(.12)
 ;
 ; change temporary address node...
 I NVSDATA(.121)'="" D
 .S $P(NVSDATA(.121),U,5)=$$CITY^NVSPDSU
 .S $P(NVSDATA(.121),U,6)=+$$ST^NVSPDSU
 .I $P(NVSDATA(.121),U,7)'="" D 
 ..S $P(NVSDATA(.121),U,7)=$$ZIP^NVSPDSU($P(NVSDATA(.121),U,7))
 .S $P(NVSDATA(.121),U,10)=$$PHONE^NVSPDSU
 .S $P(NVSDATA(.121),U,11)=$$CTY^NVSPDSU($P(NVSDATA(.121),U,6))
 .I $P(NVSDATA(.121),U,12)'="" D
 ..S $P(NVSDATA(.121),U,12)=$$ZIP^NVSPDSU($P(NVSDATA(.121),U,12))
 .S ^DPT(NVSDFN,.121)=NVSDATA(.121)
 ;
 ; change phone number(s) node...
 I NVSDATA(.13)'="" D
 .I $P(NVSDATA(.13),U,1)'="" S $P(NVSDATA(.13),U,1)=$$SCR^NVSPDSU($P(NVSDATA(.13),U,1))
 .I $P(NVSDATA(.13),U,2)'="" S $P(NVSDATA(.13),U,2)=$$SCR^NVSPDSU($P(NVSDATA(.13),U,2))
 .I $P(NVSDATA(.13),U,3)'="" S $P(NVSDATA(.13),U,3)=$$SCR^NVSPDSU($P(NVSDATA(.13),U,3))
 .I $P(NVSDATA(.13),U,4)'="" S $P(NVSDATA(.13),U,4)=$$SCR^NVSPDSU($P(NVSDATA(.13),U,4))
 .S ^DPT(NVSDFN,.13)=NVSDATA(.13)
 ;
TEMP ;
 ; change parents' names node...
 I NVSDATA(.24)'="" D
 .; father's name...
 .I $P(NVSDATA(.24),U)'="" S $P(NVSDATA(.24),U)=$$REVN^NVSPDSU($P(NVSDATA(.24),U))
 .; mother's name...
 .I $P(NVSDATA(.24),U,2)'="" S $P(NVSDATA(.24),U,2)=$$REVN^NVSPDSU($P(NVSDATA(.24),U,2))
 .; mother's maiden name...
 .I $P(NVSDATA(.24),U,3)'="" S $P(NVSDATA(.24),U,3)=$$REVN^NVSPDSU($P(NVSDATA(.24),U,3))
 .S ^DPT(NVSDFN,.24)=NVSDATA(.24)
 ;
 K NVSDATA,NVSX
 Q
