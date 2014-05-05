VFDXPDSQ ;DSS/JG - COMPILE LAST INSTALLED BUILD SEQ # ; 18 Oct 2010  12:09 PM
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 ; Compiles the last installed Patch Seq # for every Package in
 ; specified Namespace(s).
 ;
 ; Gets the Seq # from the Package File, Version multiple, Application
 ; History multiple.
 ;
 ; INPUTS: NMSP - Namespaces to be examined
 ;                  Options: "ALL" - all appropriate Namespaces or,
 ;                           single Namespace or,
 ;                           string of Namespaces delimited by ","
 ;                     NOTE: "-"_<Namespace string> for all Namespaces
 ;                           except the Namespace(s) in string
 ;         ARRAY - Name of array to store the compiled data
 ;
 ; OUTPUTS: ARRAY data if successful compile
 ;          (UCI^Namespace,Pkg Prefix)=Build Name^Seq #^Date Installed
 ;
 ;          ERR: Nil if successful compile
 ;               [-1^Error text] if not successful
 ;
 Q ; No bozos
 ;
