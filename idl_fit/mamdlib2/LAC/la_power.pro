FUNCTION LA_POWER, var1, var2
;+ 
; NAME: LA_POWER
; PURPOSE:
;   compute var1(*)^var2 on every element of var1
; CALLING SEQUENCE: 
;   output=LA_POWER(var1, var2)
; INPUTS: 
;   var1,    -- array variable of arithmetic type
;   var2     -- scalar variable
; OPTIONAL INPUT PARAMETERS:
;   none 
; KEYED INPUTS:
;   none 
; OUTPUTS: 
;    output  -- float (or double) array variable with same dimension as var1
; OPTIONAL OUTPUT PARAMETERS:
;   none 
; EXAMPLE:
;   ICE> print, la_power([[6,3,2,1], [8,6,0,0]] , 4)
;         1296.00      81.0000      16.0000      1.00000
;         4096.00      1296.00     0.000000     0.000000
; ALGORITHM:
;   straightforward
; DEPENDENCIES:
;   none 
; SIDE EFFECTS:
;    none 
; RESTRICTIONS: 
;    No overflow check
; CALLED PROCEDURES AND FUNCTIONS: 
;    LA_UNDEF 
; MODIFICATION HISTORY: 
;    8-Jul-1994  written with template_gen              FV IAS
;    7-Oct-1994  V.1.0 for configuration control        FV IAS
;    25-Apr-2008 remove session control / now independant of ICE  MAMD IAS
;-

;------------------------------------------------------------
; initialization
;------------------------------------------------------------
  output = -1
 
;------------------------------------------------------------
; parameters check
;------------------------------------------------------------
 IF N_PARAMS() LT 2 THEN BEGIN
   PRINT, 'CALLING SEQUENCE: output = LA_POWER(var1, var2)'
    GOTO, CLOSING
 ENDIF

 szv1= size(var1)
 tv1 = szv1(szv1(0) + 1)
 szv2= size(var2)
 tv2 = szv2(szv2(0) + 1)

 ; check we have arithmetic types 
 IF (tv1 LT 1) or (tv1 GT 5) THEN BEGIN
    print, 'Wrong type for var1:'+CONV_STRING(tv1)
    GOTO, CLOSING
 ENDIF

 ; convert into float for integer types
 IF tv1 LE 3 THEN szv1(szv1(0)+1) = 4

 undef = la_undef(4)
 output = undef

 IF ((tv2 LE 1) or (tv2 GT 5)) THEN BEGIN
    print, 'Wrong type for var2:'+CONV_STRING(tv2)
    GOTO, CLOSING
 ENDIF

 ; check dimension
 IF szv2(0) NE 0 THEN BEGIN
    print, 'Var2 should be a scalar:'+CONV_STRING(szv2)
    GOTO, CLOSING
 ENDIF

;------------------------------------------------------------
; function body
;------------------------------------------------------------

 IF szv1(0) EQ 0 THEN $
    IF (var1 ne undef) and (var2 ne undef) THEN BEGIN
       IF (var1 GT 0) or (float(var2) eq fix(var2)) THEN output = var1 ^ var2
       IF (var1 EQ 0) and (var2 GT 0) THEN output = var1 ^ var2
       GOTO, CLOSING
    ENDIF

 output = make_array(size=szv1, value=undef) 

; 0 power is always defined but on undefined values
 IF (var2 eq 0) THEN BEGIN
    index_values = where(var1 NE undef, cpt)
    IF (cpt GT 0) THEN output(index_values)= 1
    GOTO, CLOSING
 ENDIF

; for efficiency test if all var1 values are positive
 index_values = where((var1 EQ undef) and (var1 LE 0), cpt) 
 IF (cpt EQ 0) THEN BEGIN & output = var1 ^ var2 & GOTO, CLOSING & ENDIF

; on positive defined values, powers are always defined
 index_values = where((var1 NE undef) and (var1 GT 0), cpt) 
 IF (cpt GT 0) THEN output(index_values)= var1(index_values) ^ var2

; 0 ^ * is only defined for positive values of var2
 IF var2 GT 0 THEN BEGIN 
    index_values = where(var1 EQ 0, cpt)
    IF (cpt GT 0) THEN output(index_values)= 0
 ENDIF

; on negative values, only integer powers are defined
 IF float(var2) eq fix(var2) THEN BEGIN
    index_values = where((var1 NE undef) and (var1 LT 0), cpt)
    IF (cpt GT 0) THEN output(index_values)= var1(index_values) ^ var2
 ENDIF

; and releaving values are left undefined 
  
;------------------------------------------------------------
; closing
;------------------------------------------------------------
 
 CLOSING:
 
  RETURN, output
 
 END
