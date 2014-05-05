VFDWDPT ;DSS/SGM/LM - DESKTOP PATIENT LOOKUP
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This program is designed to provide a list of patients to display
 ;in a standard GUI list box. It accommodates the concept of MORE.
 ;That is if the GUI wishes to display x number of entries matching
 ;a user input value, then the return will provide the data needed
 ;to get additional entries matching the input starting from the
 ;last record returned in a previous call.
 ;
LOOKUP(VFDWDPT,VFDWA) ; RPC: VFDW PATIENT LOOKUP
 ; VFDWA(n) - req where VFDWA(n) = code ^ value for n=1,2,3,...
 ; 
 ; **** Original specification ****
 ; 
 ; CODE  REQ VALUE
 ; ----- --- -----------------------------------------------------------
 ; VAL    Y  lookup value [start with a <space> if lookup is other than
 ;             NAME to indicate not to use name lookup but other index
 ;             lookup.  In this case caller must pass the INDEX input
 ;             Param]
 ;           (Changed to 'not required' in build T5)
 ; FLDS   N  ';' delimited string of additional field values to be
 ;              returned with each record.  Default to DOB;age;SEX;id
 ;              where DOB = field .03 in file 2 (human readable form)
 ;                    age = DSS age field.  If this does not exist, then
 ;                          field .033
 ;                    SEX = internal value (coded text M/F) field .02
 ;                     ID = computed:
 ;                          If default Alternate ID exists, then this
 ;                          Else if 1 & only 1 Alt ID exists, then this
 ;                          Else if more than 1 Alt ID exists, then null
 ;                          Else if SSN (.09) exists, then SSN
 ; INDEX  N  ';' delimited string of index acronyms
 ;               --see note below
 ; MAX    N  maximum number of records to return
 ;             --default to 44 (current CPRS behavior)
 ; FROM   N  starting Fileman index value based on last record returned
 ;             from previous RPC call.  Should have a leading <space> if
 ;             the original input value had a leading <space>.
 ;             Optional starting IEN as 3rd "^"-piece--used when list
 ;             has many entries with the same index value, for example,
 ;             FROM^SMITH^123
 ; LINX   N  starting index name based on the last record returned from
 ;             previous RPC call. You should pass in original index
 ;             string from the previous call.
 ; RPL    N  Restricted Patient List.  Causes the personal list only to
 ;           be returned, provided a personal list is defined.  If no OE/RR
 ;           LIST is defined for the user, this parameter is ignored.
 ;           Qualifying values (e.g. list ID) are not currently supported.
 ;
 ;Notes on Index Input Parameter
 ;ACRONYM   MEANING (lookup using index if it exists on the system)
 ;-------   ----------------------------------------------------------
 ; PARAM    If the VFDW PATIENT INDEX Kernel Parameter is defined then
 ;            use that value for the Fileman INDEX input
 ; DEF      Use the B^BS^BS5^SSN indexes - current behavior of the
 ;            VFDCFM05 routine used in the VA
 ; ADR      Primary address index
 ; ALTID    Alternate ID index
 ; BS5      1st letter of last name + last 4 of SSN
 ; BS       Last 4 of SSN
 ; DOB      Date of Birth
 ; NAME     B index (name)
 ; SSN      SSN
 ; TEL      Primary phone index
 ; '-'      If first character is '-', traverse index backwards (added T6)
 ;
 ; If the INDEX parameter is not supplied, the default will be the same
 ; as DEF.  Note that the INDEX parameter is required when the lookup
 ; is prefixed by <space>.
 ;
 ;RETURN DESCRIPTION
 ; VFDWDPT(n) for n=1,2,3,4,...
 ; If no matches found, then VFDWDPT(1) = -1^message
 ; Otherwise, VFDWDPT(n) = p1^p2^p3^p4^p5^p6^... where
 ; p1 = dfn - ien in file 2
 ; p2 = patient's name
 ; p3 = <intentionally left blank for GUI to populate>
 ; p4 = if possible, the subscript value from the index that resulted in
 ;      this entry being added to the list.  It is possible that this
 ;      index value may not be exactly the same as the field value.  If
 ;      the original input value had a leading space then this value
 ;      should have a leading space appended to it.
 ; p5 = if possible, index name used to find match that resulted in this
 ;      entry being added to the list
 ; p6,p7,p8,... these will be the values of the fields in the FLDS input
 ;      parameter in the order that they were entered in the FLDS value
 ;
 ; **** Expanded specification from Steve's EMail, 12-15-2006 ****
 ; 
 ;<DEFINITONS>
 ;
 ;MORE STATE := the application had previously called this API with a
 ;lookup starting value.  The user has not changed that lookup starting
 ;value but the application has determined that the user is requesting
 ;more matches to those characters other than what is in the list of names
 ;they presently are viewing.  A MORE STATE is defined as the application
 ;passing in values for LINX,LIEN,LTXT
 ;
 ;<Input Parameters>
 ;
 ;LINX := the PATIENT file index name from the last record from a previous
 ;        call
 ;LIEN := the IFN of the last record from a previous call
 ;LTXT := the index subscript value of the last record from previous call
 ;        Remember, the value in the index subscript may not be equal to
 ;        the corresponding value stored in the field for that patient
 ;        record.
 ;
 ;NOTE: LINX,LIEN,LTXT should not be passed or should be <null> if the
 ;call to this API is not coming from a MORE STATE within the application
 ;Example of values of these: if the last index record returned was
 ;   ^DPT("B","HURRY,UP",34544)="" then
 ;    LINX="B", LIEN=34544, and LTXT="HURRY,UP"
 ;
 ;VAL := Optional, the string of characters to be used as the basis of a
 ;       lookup starting value within Fileman APIs.  Exact matches will be
 ;       returned except in the MORE STATE.  If VAL has a leading <space>
 ;       character, then the API will use the 2nd to the last character
 ;       of the VAL input parameter as the lookup starting value. The
 ;       leading <space> character indicates that the user is entering a
 ;       lookup value other than the patient's name.  In this case this
 ;       API will ignore the B index even if it is passed in the INDEX
 ;       input parameter.
 ;
 ;INDEX := a '^'-delimited string of index names to be used in the Fileman
 ;         APIs.  Optional.  Default value is B^BS^BS5^SSN (note this
 ;         mimics the behavior of the VFDCFM and VFDCDDR calls)
 ;
 ;FIELDS := a ';'-delimited string of file 2 field numbers.  Each record
 ;          returned will have that record's value returned in the order
 ;          that the field number resides within the FIELDS input
 ;          parameter.  Fields which are multiples or word processing will
 ;          not be accepted.
 ;
 ;<Business Rules>
 ;1. For all indexes, if VAL is passed, then VAL will be used as the
 ;   starting value in that index to retrieve a list of patients.
 ;   a. Not in a MORE STATE, then exact matches to VAL will be returned
 ;   b. In a MORE STATE, then values returned will be those that collated
 ;      in the index after the L* input parameters which may or may not be
 ;      exact matches to VAL
 ;
 ;2. If the index is the B (and B only), then
 ;   a. The results returned will similar to the way LIST^DIC behaves
 ;   b. VAL is the starting lookup value
 ;   c. Results returned will collate after VAL
 ;   d. Records can be returned for which the starting characters of the
 ;      name do not match VAL
 ;3. If the index is any other index than the B index, then
 ;   a. The results returned are similar to the way FIND^DIC behaves
 ;   b. The only records returned will be those records whose leading
 ;      characters in the index subscript value exactly matches VAL
 ;
 ;<Return Value(s)>
 ;RET(n) = p1^p2^p3^p4^p5^p6... where n=1,2,3,4,5,...
 ; p1 := DFN (pointer to file 2)
 ; p2 := patient name (.01 field value)
 ; p3 := <null> - space reserved for GUI app to use as needed
 ; p4 := last index name from previous call (see LINX)
 ; p5 := last index subscript value from previous call (see LTXT)
 ; p6 := ien from last entry previously returned (see LIEN)
 ; p7 := field value for the field in the 1st ";"-piece of FIELDS
 ; p8 := field value for the field in the 2nd ";"-piece of FIELDS
 ; Etc for all the fields specified in the FIELDS input parameter
 ;
 ;If an error is encountered, then RET(1)=-1^error message
 ;If no records were found to be returned, then RET(1)=0^No records found
 ;
 ;
 D LOOKUP^VFDWDPT1(.VFDWDPT,.VFDWA)
 Q
