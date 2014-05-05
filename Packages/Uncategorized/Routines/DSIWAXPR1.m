DSIWAXPR1 ;DSS/SGM - RPCs/APIs FOR PARAMETERS ;10/10/2012 15:46
 ;;1.5;VA CERTIFIED COMPONENTS - DSSI;;Jul 09, 2008;Build 9
 ;Copyright 1995-2012, Document Storage Systems, Inc., All Rights Reserved
 ;
 ;  Copyright 2012 Document Storage Systems, Inc. 
 ;
 ;  Licensed under the Apache License, Version 2.0 (the "License");
 ;  you may not use this file except in compliance with the License.
 ;  You may obtain a copy of the License at
 ;
 ;  http://www.apache.org/licenses/LICENSE-2.0
 ;
 ;  Unless required by applicable law or agreed to in writing, software
 ;  distributed under the License is distributed on an "AS IS" BASIS,
 ;  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ;  See the License for the specific language governing permissions and
 ;  limitations under the License.
 ;
 ;
 ;this routine is not directly invokable
 ;see corresponding line labels in DSIWAXPR
 ;DSIWAXPR also documents the input parameters for each call 
 ;
 ; DBIA#  Supported - Description
 ; -----  --------------------------------------------------
 ;  2051  $$FIND1^DIC
 ;  2263  ^XPAR: DEL,NDEL,GET,GETLIST,GETWP
 ;  3127  FM read of all fields in file 8989.51 [control sub IA]
 ;
 Q
 ;
OUT ;  common exit - if '$D(RET) then expects DSIERR to be defined
 I $G(RET)]"" Q:$G(FUN) RET Q
 S DSIERR=$G(DSIERR,"Unexpected problem encountered")
 I DSIERR[U S DSIERR=$P(DSIERR,U,2)
 S RET=$S(DSIERR=0:1,1:"-1^"_DSIERR)
 Q:$G(FUN) RET Q
 ;
DEL ;  delete existing parameter/entity/instance
 ;  VALUE is not expected
 ;  DBIA #2263 - DEL^XPAR
 N X,Y,Z,ARR,DSIERR
 S X=$$PARSE(13) I X<0 S DSIERR=X G OUT
 I ARR(3)="" S DSIERR="-1^No Instance received"
 E  D DEL^XPAR(ARR(1),ARR(2),ARR(3),.DSIERR)
 G OUT
 ;
DELALL ;  delete all instances for entity/parameter
 ;  neither INSTANCE nor VALUE expected
 N X,Y,Z,ARR,DSIERR
 S X=$$PARSE(13) I X<0 S DSIERR=X
 E  D NDEL^XPAR(ARR(1),ARR(2),.DSIERR)
 G OUT
 ;
GET ;  return values for all instances of an entity/param
 ;  Expects only ENTITY, PARAMETER
 ;               FORMAT is optional - default to B
 ;               FORMAT input is ignored and always set to B
 ;  ARR(6) = Q - return list(#)=iI^iV
 ;           E - return list(#)=eI^eV
 ;           B - return list(#,"N")=iI^eI
 ;                      list(#,"V")=iV^eV
 ;           N - return list(#,"N")=iV^eI
 ;  Return RET(#) = iI^eI^iV^eV
 ;     some of those pieces may be <null> depends upon ARR(6)
 ;     On error, return RET(1)=-1^error message
 N I,P,X,Y,Z,ARR,DSIERR,DSILIST
 S X=$$PARSE(234) I X<1 S RET(1)=X Q
 D GETLST^XPAR(.DSILIST,ARR(1),ARR(2),ARR(6),.DSIERR)
 I $G(DSIERR)'=0 S RET(1)="-1^"_$P(DSIERR,U,2) Q
 I '$G(DSILIST) S RET(1)="-1^No data found" Q
 ;  following FOR loop intentional.  Kill off return array element
 ;  after it has been processed.  Help to avoid <alloc> errors
 K P S Z=0,Y=ARR(6) F  S I=$O(DSILIST(0)) Q:'I  S Z=Z+1 D
 .F X=1:1:4 S P(X)=""
 .I Y="Q" S P(1)=$P(DSILIST(I),U),P(3)=$P(DSILIST(I),U,2)
 .I Y="E" S P(2)=$P(DSILIST(I),U),P(4)=$P(DSILIST(I),U,2)
 .I Y="N" S P(3)=$P(DSILIST(I,"N"),U),P(2)=$P(DSILIST(I),U,2)
 .I Y'="B" S RET(Z)=P(1)_U_P(2)_U_P(3)_U_P(4)
 .E  S RET(Z)=DSILIST(I,"N")_U_DSILIST(I,"V")
 .K DSILIST(I)
 .Q
 Q
 ;
GET1 ;  return value of a single entity/param/instance combo
 ;  Format codes [ARR(6)] = [Q]uick    - return iV
 ;                          [E]xternal - return eV
 ;                          [B]oth     - return iV^eV
 N X,Y,Z,ARR,DSIERR
 S X=$$PARSE(34) I X<1 S DSIERR=X G OUT
 I "N"[ARR(6) S DSIERR="-1^Invalid format parameter received" G OUT
 I ARR(3)="" S X=$$GET^XPAR(ARR(1),ARR(2),,ARR(6))
 I ARR(3)'="" S X=$$GET^XPAR(ARR(1),ARR(2),ARR(3),ARR(6))
 I X="" S DSIERR="-1^No value found"
 E  S RET=X
 G OUT
 ;
GETWP ;  Retrieve a word-processing type parameter value
 N I,X,Y,Z,ARR,DSIERR,DSILST
 S X=$$PARSE(34) I X<1 S RET(1)=X Q
 S:ARR(3)="" ARR(3)=1
 D GETWP^XPAR(.DSILST,ARR(1),ARR(2),ARR(3),.DSIERR)
 I $G(DSIERR)>0 G OUT
 I '$D(DSILST) K DSIERR G OUT
 S X=0,Y=0,RET(1)=DSILST
 F  S X=$O(DSILST(X)) Q:X=""  S Y=Y+1,RET(Y)=DSILST(X,0)
 Q
 ;
 ;--------------------  subroutines  -----------------------
 ;
NM(P) ;  return the ien for a parameter definition P (#8989.51)
 N DIERR,DSIERR Q $$FIND1^DIC(8989.51,,"QX",$G(P),"B",,"DSIERR")
 ;
PARSE(FLG) ;  parse up DATA string and set up ARR() array
 ;  FLG - optional
 ;    If FLG[1 then explicit entity required - default to USR
 ;    If FLG[4 then explicit entity required - default to ALL
 ;    If FLG[2 then set GET format to B
 ;    If FLG[3 then value not needed
 ;  Return: PARAMETER DEFINITION ien
 ;     else return -1^error message
 ;
 ;  ARR(1) = entity     ARR(2) = param name    ARR(3) = instance
 ;  ARR(4) = value      ARR(5) = new instance value
 ;  ARR(6) = format for GET1
 ;
 N I,X,Y,Z,RTN K ARR S FLG=$G(FLG)
 F I=1:1:6 S ARR(I)=$P($G(DATA),"~",I)
 I FLG[1,ARR(1)="" S ARR(1)="USR"
 I FLG[4,ARR(1)="" S ARR(1)="ALL"
 I ARR(6)="" S ARR(6)=$S(FLG[2:"B",1:"Q")
 I FLG[2 S ARR(6)="B"
 I "QEBN"'[ARR(6)!(ARR(6)'?1U) S ARR(6)=""
 I ARR(2)="" Q "-1^No parameter name received"
 S RTN=$$NM(ARR(2))
 I 'RTN S RTN="-1^Parameter Definition "_ARR(2)_" not found"
 I RTN>0,FLG'[3,ARR(4)="" S RTN="-1^No value received"
 Q RTN
