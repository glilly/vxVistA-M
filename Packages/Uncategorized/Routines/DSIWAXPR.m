DSIWAXPR ;DSS/SGM - RPCs/APIs FOR PARAMETERS ;10/10/2012 07:59
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
 ;DBIA#: 10086 - D HOME^%ZIS - supported
 ;
 ;For documentation of the entry points and input parameters: D ^DSIWAXPR0
ADDWP(RET,DATA,DSIWALT) ;  RPC:  DSIWA XPAR ADD WP
 ;  Add an instance of a word-processing field inside a parameter.
 ;  Returns: RET(0) = text or on error return RET(0) = -1^error message
 ;
 ; convert DSIWACLT
 ; 
 N DSIWA,I
 F I=1:1 Q:'$D(DSIWALT(I))  S DSIWA(I,0)=DSIWALT(I)
 K DSIWALT M DSIWALT=DSIWA K DSIWA
 G ADDWP^DSIWAXPR2
 ;
DEL(RET,DATA,FUN) ;  RPC: DSIWA XPAR DEL
 ;  delete an existing parameter value
 ;  Exception: value is optional, but if passed must be equal to @
 G DEL^DSIWAXPR1
 ;
DELALL(RET,DATA,FUN) ;  RPC: DSIWA XPAR DEL ALL
 ;  this will delete all instances for a given entity/parameter
 ;  Exception: instance and value are not required for this call
 G DELALL^DSIWAXPR1
 ;
GET(RET,DATA) ;  RPC: DSIWA XPAR GET ALL FOR ENT
 ;  this will return values for all instances of an entity/param
 ;  Exception: only needed elements: entity, parameter, format
 ;  ARR(6) = input value ignored, always use 'B'
 ;           B - return list(#,"N")=iI^eI
 ;                      list(#,"V")=iV^eV
 ;  Return RET(#) = iI^eI^iV^eV
 ;     On error, return RET(1)=-1^error message
 G GET^DSIWAXPR1
 ;
GET1(RET,DATA,FUN) ;  RPC: DSIWA XPAR GET VALUE
 ;  this will return the value of a single entity/param/instance combo
 ;  Format codes [ARR(6)] = [Q]uick    - return iV
 ;                          [E]xternal - return eV
 ;                          [B]oth     - return iV^eV
 G GET1^DSIWAXPR1
 ;
GETWP(RET,DATA) ;  RPC: DSIWA XPAR GET WP
 ;  return a parameter's value which is defined as word-processing
 ;  Returns: RET(#) = text or on error return RET(1) = -1^error message
 G GETWP^DSIWAXPR1
 ;
