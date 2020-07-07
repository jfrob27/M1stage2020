FUNCTION LA_LOG, var1, b10=b10
;+ 
; NAME: LA_LOG
; PURPOSE:
;   compute natural logarithm of var1 taking into account undefined values
;   (IDL routine ALOG). 0 or negative values produces undefined values in the
;   output.
; CALLING SEQUENCE: 
;   output=LA_LOG(var1, /b10)
; INPUTS: 
;   var1,    -- array variable of arithmetic type
; OPTIONAL INPUT PARAMETERS:
;   none 
; KEYED INPUTS:
;   b10      -- 0/1 : ask for base 10 log     
; OUTPUTS: 
;    output  -- float (or double) array variable with same dimension as var1
; OPTIONAL OUTPUT PARAMETERS:
;   none 
; EXAMPLE:
;   ICE> print, la_log([[6,3,2,1], [8,6,0,0]])
;      
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
;    13-Feb-1995 written from LA_POWER                     FV IAS
;    25-Apr-2008 remove session control / now independant of ICE  MAMD IAS
;-

;------------------------------------------------------------
; initialization
;------------------------------------------------------------
 
 output = -1
 
;------------------------------------------------------------
; parameters check
;------------------------------------------------------------
 IF N_PARAMS() LT 1 THEN BEGIN
   PRINT, 'CALLING SEQUENCE: output = LA_LOG(var1)'
   GOTO, CLOSING
 ENDIF

 szv1= size(var1)
 tv1 = szv1(szv1(0) + 1)

 ; check we have arithmetic types 
 IF (tv1 LT 1) or (tv1 GT 5) THEN BEGIN
    print, 'Wrong type for var1:'+CONV_STRING(tv1)
    GOTO, CLOSING
 ENDIF

 ; convert into float for integer types
 IF tv1 LE 3 THEN szv1(szv1(0)+1) = 4

 undef = la_undef(4)
 output = undef

;------------------------------------------------------------
; function body
;------------------------------------------------------------


; log is only defined on positive defined values

; scalar case
 IF szv1(0) EQ 0 THEN BEGIN
    IF (var1(0) ne undef) and (var1(0) GT 0) THEN $
    IF KEYWORD_SET(b10) THEN output = ALOG10(var1) ELSE output = ALOG(var1)
    GOTO, CLOSING
 ENDIF

; array case
 output = make_array(size=szv1, value=undef) 
 index_values = where((var1 NE undef) and (var1 GT 0), cpt) 
 IF (cpt GT 0) THEN BEGIN
    IF KEYWORD_SET(b10) THEN $
       output(index_values) = ALOG10(var1(index_values)) $
    ELSE output(index_values) = ALOG(var1(index_values))
 ENDIF

;------------------------------------------------------------
; closing
;------------------------------------------------------------
 
 CLOSING:
 
  RETURN, output
 
 END
