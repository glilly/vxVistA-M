DSIWAXPR2 ;DSS/SGM - NON-GUI INTERACTIVE PARAMETER EDIT ;10/10/2012 07:59
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
 ;This is only called from DSIWAXPR routine
 ;This routine encapsulates the Parameter terminal interactive tools for
 ;editing Kernel Parameters.
 ;
 ;DBIA#  Supported Reference
 ;-----  ---------------------------------------------------------------
 ;       ADD^XPAR
 ;       INTERN^XPAR1
 ; 3127  FM read access to all of file 8989.51 [controlled subscription]
 ;
ADDWP ;  add a new entity/parameter/instance
 ; for a word-processing type parameter
 ; INSTANCE is optional
 N I,X,Y,Z,ARR,DSIERR
 N ENT,PAR,ERR,INST,WPA
 S (ERR,DSIERR,RET)=""
 I DATA']"" S RET="-1^No Data String defined" Q
 S ENT=$S($P(DATA,"~",1)'="":$P(DATA,"~",1),1:"SYS")
 S PAR=$P(DATA,"~",2) I PAR="" S RET="-1^No parameter defined in Data string" Q
 S INST=$P(DATA,"~",3),INST=$G(INST,1)
 D INTERN^XPAR1 I ERR S RET="-1^Parameter not defined" Q
 D ADD^XPAR(ENT,PAR,INST,.DSIWALT,.WPA) I +WPA S RET="-1^"_$P(WPA,U,2) Q
 S RET="1^Parameter added successfully"
 Q
 ;
