XUSHSH ;SF-ISC/STAFF - PASSWORD ENCRYPTION ;3/23/89  15:09 ; 2/16/07 9:41am
 ;;8.0;KERNEL;;Jul 10, 1995
 ;;DSS Version: 1.0
 ;
 ;;DSS/LM – entire routine modified to support MD5 encryption
 ;
A ;;
 S X=$$EN(X)
 Q
 ;
EN(X) ;;
 D X^VFDXTX("ONE-WAY HASH") Q X
 ;
UC(X) ;;
 Q $$UP^XLFSTR(X)
 ;
