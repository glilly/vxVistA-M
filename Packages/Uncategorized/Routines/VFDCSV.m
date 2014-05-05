VFDCSV ;DSS/LM - GATEWAY TO "SAVE STATE" RPC's ;6/12/07  08:57
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
ADD(VFDCRSLT,VFDCARRY) ;Add new entry to File 21651
 ; VFDCARRY - Input array by reference
 ;            FieldName~Value
 ;            FieldName~Value
 ;            . . .
 ;            . . .
 ;            $TEXT
 ;            State Text (WP)
 ;            
 ; VFDCRSLT - IEN of new entry or -1^Error
 ;
 D ADD^VFDCSV01(.VFDCRSLT,.VFDCARRY)
 Q
MOD(VFDCRSLT,VFDCARRY) ;Modify existing entry in File 21651
 ; VFDCARRY - Input array by reference - Must include complete key
 ;            FieldName~Value
 ;            FieldName~Value
 ;            
 D MOD^VFDCSV01(.VFDCRSLT,.VFDCARRY)
 Q
DEL(VFDCRSLT,VFDCARRY) ;Delete existing entry in File 21651
 ; VFDCARRY - Input array by reference - Must include complete key
 ;            FieldName~Value
 ;            FieldName~Value
 ;            
 ; VFDCRSLT - 0 (zero) for success or -1^Error
 ;
 D DEL^VFDCSV01(.VFDCRSLT,.VFDCARRY)
 Q
GET(VFDCRSLT,VFDCARRY) ;Retrieve data for existing entry in File 21651 (From GET^VFDCSV)
 ; VFDCARRY - Input array by reference - Must include complete key
 ;            FieldName~Value
 ;            FieldName~Value
 ;            
 ; VFDCRSLT - Array of return data or -1^Error
 ;
 D GET^VFDCSV01(.VFDCRSLT,.VFDCARRY)
 Q
LIST(VFDCRSLT,VFDCFROM,VFDCPART,VFDCSCR,VFDCNDX,VFDCNUM) ;Retrieve list of entries from File 21651
 ; VFDCFROM - See LIST^DIC
 ; VFDCPART - [Optional] See LIST^DIC
 ; VFDCSCR  - [Optional] Array of screen field-value pairs
 ;            PATIENT~DFN
 ;            APPLICATION~IEN
 ;            NEW PERSON~DUZ
 ;            
 ; VFDCNDX  - Index to select/sort by PATIENT=D, NEW PERSON=E
 ; VFDCNUM  - [Optional] Maximum number of entries to return
 ; 
 ; VFDCRSLT - Array of return data or -1^Error
 ;            DFN^PATIENT NAME^KEY1^KEY2^KEY3
 ;            DFN^PATIENT NAME^KEY1^KEY2^KEY2
 ;            Etc.
 ;
 D LIST^VFDCSV01(.VFDCRSLT,.VFDCFROM,.VFDCPART,.VFDCSCR,.VFDCNDX,.VFDCNUM)
 Q
PURGE ;;Option VFDC INTERPROCESS COM PURGE
 ; Delete obsolete entries, as indicated by PURGE DATE/TIME field value 
 D PURGE^VFDCSV02
 Q
