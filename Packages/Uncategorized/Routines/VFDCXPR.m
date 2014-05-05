VFDCXPR ;DSS/SGM - RPCs/APIs FOR PARAMETERS ;01/29/2013 19:25
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**16**;11 Jun 2013;Build 1
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine provides APIs for parameter manipulation; their original
 ;entry points (alternate input parameter configuration required)
 ;reside within the XPAR routine.
 ;
 ;***** NOTES *****
 ;  01/29/2013 - FUN deprecated in favor of $Q
 ;
 Q
 ;
ADD(VFDRET,DATA,FUN) ;  RPC: VFDC XPAR ADD
 ;  add a new parameter
 ;  Exception: instance is optional even for multiple - see above
 G ADD^VFDCXPR1
 ;
CHG(VFDRET,DATA,FUN) ;  RPC: VFDC XPAR EDIT
 ;  edit a Value for an existing parameter
 G CHG^VFDCXPR1
 ;
DEL(VFDRET,DATA,FUN) ;  RPC: VFDC XPAR DEL
 ;  delete an existing parameter value
 ;  Exception: value is optional, but if passed must be equal to @
 G DEL^VFDCXPR1
 ;
GET(VFDRET,DATA) ;  RPC: VFDC XPAR GET ALL FOR ENT
 ;  this will return values for all instances of an entity/param
 ;  Exception: only needed elements: entity, parameter, format
 ;  ARR(6) = input value ignored, always use 'B'
 ;           B - return list(#,"N")=iI^eI
 ;                      list(#,"V")=iV^eV
 ;  Return VFDRET(#) = iI^eI^iV^eV
 ;     On error, return VFDRET(1)=-1^error message
 G GET^VFDCXPR1
 ;
GET1(VFDRET,DATA,FUN) ;  RPC: VFDC XPAR GET VALUE
 ;  this will return the value of a single entity/param/instance combo
 ;  Format codes [ARR(6)] = [Q]uick    - return iV
 ;                          [E]xternal - return eV
 ;                          [B]oth     - return iV^eV
 G GET1^VFDCXPR1
 ;
GETALL(VFDRET,DATA) ;  RPC: VFDC XPAR GET ALL
 ;  Return VALUE for all ENTITYs for a parameter/instance combination
 ;  Exception: only need parameter, instance
 ;  Return @VFDRET@(1) = -1^error message, or
 ;  @VFDRET@(#)=3-char code^entity ien^value
 ;  return data will be sorted by 3-char code, entity
 G GETALL^VFDCXPR1
 ;
GETWP(VFDRET,DATA) ;  RPC: VFDC XPAR GETWP
 ;  return a parameter's value which is defined as word-processing
 ;  Returns: VFDRET(#) = text or on error return
 ;           VFDRET(1) = -1^error message
 G GETWP^VFDCXPR1
 ;
CHGWP(VFDRET,DATA,VFDCLIST) ;  RPC:  VFDC XPAR CHGWP
 ;  change an instance of a word-processing field inside a parameter.
 ;  Returns: VFDRET(0) = text or on error return -1^error message
 ;  convert VFDCLIST
 N VFDCLT F I=1:1 Q:'$D(VFDCLIST(I))  S VFDCLT(I,0)=VFDCLIST(I)
 G CHGWP^VFDCXPR1
 ;
REPL(VFDRET,DATA,FUN) ;  RPC: VFDC XPAR REPL INST
 ;  change an instance value for an existing entry
 ;  requires entity, parameter, current instance, new instance
 G REPL^VFDCXPR1
 ;
NMALL(VFDC,X,EXACT,FLDS) ;  API
 ;     X - req - parameter name lookup value (can be partial match)
 ; EXACT - opt - Boolean 1/0 - return param whose name matches X exactly
 ;               honored starting 9/20/2005
 ;  FLDS - opt - ';'-delimited field values from 8989.51 to return
 ;               default is ien^name - added 9/20/2005
 ;               If the FLDS list does not contain .01, it will be added
 ;               If the .01 field is not the first one in the FLDS list,
 ;               then it will be moved to the front
 ;               This program is not expecting FLDS to contain a ':'
 ;RETURN: VFDC(#) = ien ^ name - or - values for FLDS
 ;                  if problems, VFDC(1) = -1 ^ message
 ;                               VFDC(n) = additional text if needed
 ;Extrinsic function returns 1 if data found, -1^error message
 ;  If $G(EXACT) and match found, then ext funct returns field values
 G NMALL^VFDCXPR1
 ;
EDIT(P) ; interactive prompt to select parameter then edit 8989.5
 ; P - req
 ; This can be the name or namespace of parameter to be used as a screen
 ; This can be an array of names (or namespaces) to be used in screen
 ; 
 G EDIT^VFDCXPR3
 ;
