NVSPDSU ;emciss/maw-patient data scrambler functions/utilities ; 09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
REVN(X) ; scramble a patient name...
 ; new algorithm: first letter of last name is NOT changed
 ; X = a patient name
 ; returns patient name scrambled using $TRANSLATE for
 ; letter-by-letter exchange of all characters after the first
 ;
 N L1,LX
 I $G(X)="" Q "ERROR--NO NAME PASSED"
 S L1=$E(X)
 S LX=$E(X,2,99)
 Q L1_$TR(LX,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","LKJIHGFEDCBAZYXWVUTSRQPONM")
 ;
SSN(NAME,DOB,PSSN)      ; generate a pseudo-SSN...
 ; NAME = passed by value = client's name
 ; DOB  = passed by value = client's date of birth
 ; PSSN = passed by reference = ""
 ; returns PSSN = a valid pseudo-SSN based upon the parameters passed
 ; NOTE:  this is only used as a last resort.      
 ;
 N DOB1,FIRSTI,I,LASTI,MIDFIND,MIDLI,NAME2
 S LASTI=$E(NAME)
 S NAME2=$P(NAME,",",2)
 S FIRSTI=$E(NAME2)
 S MIDFIND=$F(NAME2," ")
 I MIDFIND=0 S MIDLI=""
 I MIDFIND>0 S MIDLI=$E(NAME2,MIDFIND)
 S PSSN=""
 F I="FIRSTI","MIDLI","LASTI" D
 .S PSSN=PSSN_$$SSN2(@I)
 F I=1:1:3 D
 .S DOB1=$S(I=1:+$E(DOB,4,5),I=2:+$E(DOB,6,7),1:+$E(DOB,2,3))
 .I DOB1<10 S DOB1="0"_DOB1
 .S PSSN=PSSN_DOB1
 S PSSN=PSSN_"P"
 Q
 ;
SSN2(X) ; convert alphas to digits...
 ; (only called from SSN module above)
 ; X = an alpha character
 ; returns X converted into a specific numeric value
 ;
 I $G(X)="" Q 0
 I "ABC"[X Q 1
 I "DEF"[X Q 2
 I "GHI"[X Q 3
 I "JKL"[X Q 4
 I "MNO"[X Q 5
 I "PQR"[X Q 6
 I "STU"[X Q 7
 I "VWX"[X Q 8
 I "YZ"[X Q 9
 Q 0
 ;
SSND(X) ; format an SSN into nnn-nn-nnnn...
 ; X = an SSN in a format with no dashes
 ; returns X in the format indicated above
 I $G(X)="" Q ""
 S X=$TR(X,"-","")
 Q $E(X,1,3)_"-"_$E(X,4,5)_"-"_$E(X,6,9)
 ;
SSNS(X) ; get short ID (last 4-5 characters of SSN)...
 ; X = an SSN in a format with no dashes
 ; returns X as the last 4 digits of SSN
 I $G(X)="" Q ""
 I X["-" Q X
 Q $E(X,6,9)
 ;
PFEDIT(DFN,FIELD,VALUE) ; edit a particular field in the patient file...
 ; call VA FileMan DBS to edit/update a field in the Patient file
 ;   DFN = patient record number
 ; FIELD = the field number to be edited
 ; VALUE = the value that will be stuffed into the field
 ; nothing is returned from this call
 ;
 I $G(DFN)=""!($G(FIELD)="")!($G(VALUE)="") Q
 N NVSDIERR,NVSFILE,NVSMSG,NVSVAL,NVSX,NVSY,X,Y
 N VAFCFLG
 S VAFCFLG=1
 S NVSFILE(2,DFN_",",FIELD)=VALUE
 ;
 ; validate the edit.  quit if we can't edit it...
 D VAL^DIE(2,DFN_",",FIELD,"EFHR",VALUE,.NVSVAL,"NVSFILE","NVSDIERR")
 I NVSVAL="^" Q
 ;
 D FILE^DIE("E","NVSFILE","NVSDIERR")
 I $D(NVSDIERR("DIERR")) D
 .S NVSX=0
 .F  S NVSX=$O(NVSDIERR("DIERR",NVSX)) Q:'NVSX  D
 ..S NVSY=0
 ..F  S NVSY=$O(NVSDIERR("DIERR",NVSX,"TEXT",NVSY)) Q:'NVSY  D
 ...S NVSMSG=NVSDIERR("DIERR",NVSX,"TEXT",NVSY)
 ...D ERR^NVSPDSU(NVSMSG_" DFN="_DFN_" Field: "_FIELD)
 I $D(NVSDIERR("DIMSG")) D
 .S NVSX=0
 .F  S NVSX=$O(NVSDIERR("DIMSG",NVSX)) Q:'NVSX  D
 ..S NVSMSG=NVSDIERR("DIMSG",NVSX)
 ..D ERR^NVSPDSU(NVSMSG_" DFN="_DFN_" Field: "_FIELD)
 Q
 ;        
CITY() ; city...
 ; returns a bogus city name randomly selected from the temporary array
 ;
 N C1,C2,NVSCITY,CITY
 S NVSCITY("CITY",0)="MAYBERRY^BEDROCK^METROPOLIS^GOTHAM CITY^ST ELSEWHERE^ELM RIDGE^RED PLAINS^WEST FALLS^ELDORADO^PICKLETON^STEELTOWN^MINOPOLIS^NEW KRANSTON^FOREST HILLS^BUCHANAN^GUCCHI^PADDLETON^OAK LEAF^WATERFALL^PORTSEND"
 S NVSCITY("CITY",1)="COALHILL^LITTLETON^CREEK JUNCTION^CAPISTRANO^MYOPIA^SUBURBIA^GOLD RIDGE^COPPER CITY^BLOUNT^MEGOPOLIS^BLUEVILLE^ACRETON^ST RICHARDS^EL TORRO^SUN GROVE^MAYBERRY^CACTUS^COLLEGE TOWN^PAPERMILL^WINNEBEGO"
 S NVSCITY("CITY",2)="SHADY GROVE^HARDING^CLOVER^SHOSHONE HILL^PLANKTON^PULLOVER^LOST LAKE^FARM HILL^SEDGEBRUSH^LOS NUEVOS^PORTERVILLE^IRONTON^PINE HILL^DIAMOND^ZULU^WHISTLE JUNCT.^CORNER GROVE^WOLVINGTON^PAPERMILL^DEEP LAKE"
 S NVSCITY("CITY",3)="NOD HILL^NEWTOPIA^STARWOOD^KING ARTHUR^SAN BERNADA^ST BERNARD^BUTTERVILLE^CASA BLANCA^CHEROKEE^EVERGREEN^CRESTWOOD^FARMSTEAD^GLOVER^LAKEPINE^HIGHLAND^MANCHESTER^COVE CITY^OAKSHIRE^RUSHTOWN^TWIN PEAKS"
 S NVSCITY("CITY",4)="SPEEDTRAP^HOVINGTON^BEAVERSTON^LONGLY^TOONTOWN^TRANSYLVANIA^BEEHIVE^TINSYLTOWN^STARCREEK^EDENS GARDEN^KANE COVE^BAGDAD^MECCAH^EERIE^GOLDRUSH^LOS DIABLOS^CASA GRANDA^SHANGRILA^VALHALIA^TIMBUKTUU"
 S NVSCITY("CITY",5)="NIRVANA^WEST GOLDRUSH^RIVER CITY^URBANTOWN^GULCH^SMOCKSTACK^VENICIA^HOMBERG^NESTELVILLE^SERIA LEONE^COVALLA^TOMBSTONE^MILE CITY^KRYPTON^UPTON^KOKERVILLE^BOONVILLE^CANYON^LAST CHANCE^GEYSER"
 S CITY=""
 S C1=$R(6)
 S C2=$R(20)
 I C2=0 S C2=1
 S CITY=$P($G(NVSCITY("CITY",C1)),"^",C2)
 I CITY="" S CITY="SOMECITY"
 Q CITY
 ;
CTY(ST) ; get a county...
 ; ST = a valid entry in the State file -or- null.  if null, this module
 ;        calls $$ST to randomly select a state.
 ; returns a randomly selected county from the entries for the specified
 ;   state
 ;
 N CTY,CTYX
 I +$G(ST)=0 S ST=$$ST()
 I ST=0 S CTY=""
 I ST>0 D
 .S CTY=0
 .S CTYX=+$P($G(^DIC(5,ST,1,0)),"^",4)-1
 .I CTYX'>0 S CTY=0 Q
 .F  Q:$D(^DIC(5,ST,1,CTY,0))  S CTY=$R(CTYX)+1
 I +CTY'>0 S CTY=1
 Q CTY
 ;
ST() ; get a state name...
 ; returns a randomly-selected state name from the State file.
 N ST
 S ST="0^"
 I $D(^DIC(5)) D
 .S ST="0^"
 .F  Q:$D(^DIC(5,+ST,0))  S $P(ST,U)=$R(51)+1
 I +ST'>0 S ST=$O(^DIC(5,0))
 S $P(ST,U,2)=$P($G(^DIC(5,+ST,0)),U)
 I +ST=0 D
 .S ST=$O(^DIC(5,"B",""))
 .S $P(ST,U)=+$O(^DIC(5,"B",ST,0))
 Q ST
 ;               
ZIP(X) ; scrambled zip code...
 ; X = a zip code (passed only for the purpose of determining
 ;                 whether it is a straight 5-digit zip code or
 ;                 a zip+4 format zip code)
 ; returns either a 5-digit zip code of 12345, or a zip+4 format
 ;   zip code of 12345-1234
 N ZIP
 S ZIP=12345
 I $L(X)>5 S ZIP=ZIP_"-1234"
 Q ZIP
 ;
PHONE(X) ; set a bogus phone number that will be used everywhere...
 Q "800-555-1212"
 ;
SCR(X) ; scramble a given string...
 ; this algorithm can be used for mixed alpha/numeric strings
 ; X = string to be scrambled
 ; returns string scrambled:  alpha characters are replaced with other
 ;                            alphas, numbers are replaced with numbers
 I $G(X)="" Q ""
 N L,ST,Y
 S Y=""
 F L=1:1:$L(X) D
 .S ST=$E(X,L)
 .S Y=Y_$S(ST?1A:$C($A(ST)-64+$R(26)#26+65),ST?1N:$R(9),1:ST)
 ;
 ; make sure we haven't inserted a bogus character to the string...
 S Y=$TR(Y,"^;_"," ")
 Q Y
 ;
ERR(MSG)        ; set error message in tracking global...
 I $G(MSG)="" Q
 N NVSECT
 S NVSECT=+$O(^XTMP("NVSPDS","E",""),-1)+1
 S ^XTMP("NVSPDS","E",NVSECT,0)=MSG
 W !?5,MSG
 Q
 ;
ET ; come here on fatal error...
 N NVSNOW
 S NVSNOW=$H
 S ^XTMP("NVSPDS","FATAL_ERROR",NVSNOW)="Record #"_$G(NVSDFN,"UNKNOWN")
 S ^XTMP("NVSPDS","FATAL_ERROR",NVSNOW,1,0)=$ZE
 G RESTART^NVSPDS
 ;
DPTTOT()        ; get count of total records in ^DPT...
 N COUNT,DFN
 S (COUNT,DFN)=0
 F  S DFN=$O(^DPT(DFN)) Q:'DFN  S COUNT=COUNT+1
 Q COUNT
  
