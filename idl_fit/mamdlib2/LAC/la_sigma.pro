FUNCTION LA_SIGMA, var1, dim=dim, mask=mask, mean=x, ndef=ndef, $ 
 n_sigma= n_sigma, median_first= median_first
;+ 
; NAME: LA_SIGMA
; PURPOSE:
;   compute sigma as 
;        sqrt( total((var1 - mean)^2) / n_elements(var1))
;   undefined values are discarded from calculus
; CALLING SEQUENCE: 
;   sigma=LA_SIGMA(var1 [, dim=dim, mask=mask, mean=x, n_sigma= n_sigma, 
;                  /median_first])
; INPUTS: 
;   var1   -- array of arithmetic type
; OPTIONAL INPUT PARAMETERS:
;   none 
; KEYED INPUTS: 
;   dim    -- dimension of result :
;             0 : return sigma of every elementary defined values (default)\\
;             1 : return vector with sigma of every "planes". (with as
;                many elements as in the last dimension) \\
;            -1 : return sigma "plane" (one dimension less than var1) 
;   mask   -- byte array : dimensions should be
;                if dim eq 0 : same as var1
;                if dim eq 1 : same as var1 but possibly 1 on last one
;                if dim eq -1 : same as var1 or vector
;              should follow SCD mask conventions : good values are 0 masked
;              values.
;  n_sigma -- integer or real : if given, compute sigma and mean after
;             discarding all values where abs(values- mean) gt n_sigma*sigma
;  median_first -- 0/1 : if set, a median value is taken as a first estimate of 
;	      the mean value, then make a n_sigma filtering and compute
;	      a mean value
; OUTPUTS: 
;   sigma  -- real, scalar, vector or array of one dim less than var1 : rms
; OPTIONAL OUTPUT PARAMETERS:
;   none 
; KEYED OUTPUT:
;   mean   -- real, scalar, vector or array of one dim less than var1 : mean
; EXAMPLE:
;   ICE> print, la_sigma([[1, 2], [0, 3]])
;          1
;   ICE> print, la_sigma([[1, 2], [0, 3]], /dim)
;          0       1
;   ICE> print, la_sigma([[1, 2], [0, 3]], dim=-1)
;          0       0
; ALGORITHM:
;   straightforward 
; DEPENDENCIES:
;   none 
; SIDE EFFECTS:
;   none 
; RESTRICTIONS:
;   none
; CALLED PROCEDURES AND FUNCTIONS:      
;    LA_UNDEF 
; MODIFICATION HISTORY: 
;    13-Jul-1994  written with template_gen             FV IAS
;     3-Oct-1994  V.1.0 for configuration control       FV IAS
;    14-Avr-1995  rewrite without SIGMA function for efficiency FV IAS
;    15-May-1997  n_sigma added AA IAS
;    16-May-1997  median_first added AA IAS
;    25-Apr-2008 remove session control / now independant of ICE  MAMD IAS
;-      
 
;------------------------------------------------------------
; initialization
;------------------------------------------------------------
  output=-1
 
;------------------------------------------------------------
; parameters check
;------------------------------------------------------------
 
 IF N_PARAMS() LT 1 THEN BEGIN
   PRINT, 'CALLING SEQUENCE:'
   print, ' sigma=LA_SIGMA(var1, dim=dim, mask=mask, n_sigma= n_sigma, ', $
          '/median_first)'
   GOTO, CLOSING
 ENDIF

 szv1= size(var1)
 tv1 = szv1(szv1(0) + 1)
 ; check we have an arithmetical type
 IF (tv1 LE 0) or (tv1 GT 5) THEN BEGIN
    print, 'Wrong type for var1:'+ strtrim(tv1,2)
    GOTO, CLOSING
 ENDIF
 undef = la_undef(tv1)

 IF n_elements(dim) eq 0 THEN dim = 0
 dim = dim(0)
 IF (dim NE 0) and (dim NE 1) and (dim NE -1) THEN BEGIN
    print, 'Irrelevant value for dim '+strtrim(dim)
    GOTO, CLOSING
 ENDIF

 ; check mask
 IF n_elements(mask) eq 0 THEN mask = byte(var1) * 0
 szm = size(mask)
 tm = szm(szm(0)+1)
 IF (tm GT 3) THEN BEGIN
    print, 'Wrong type for mask:'+CONV_STRING(tm)
    GOTO, CLOSING
 ENDIF

 OK = 1
 FOR i=1,szm(0) DO OK = OK and (szm(i) eq szv1(i))
 IF (not ok) and ((dim ne -1) or (szm(0) ne 1) or (szm(1) ne szv1(szv1(0)))) $
 THEN BEGIN
    print, 'WRONG dimensions for mask:'+CONV_STRING(szm)
    GOTO, CLOSING
 ENDIF

;------------------------------------------------------------
; function body
;------------------------------------------------------------

 IF n_elements(mask) LE 0 THEN mask = 0

; general case sigma is computed from all values in var1
 IF (dim eq 0) or (szv1(0) LE 1) THEN BEGIN 
    good_values = where((var1 NE undef) and (mask eq 0), cpt)
    output = la_undef(tv1 > 4) & ndef=cpt
    IF cpt eq n_elements(var1) THEN BEGIN
       if keyword_set( median_first) then  x = median(var1) else $ 
        x = total(var1) / cpt
       y = total((var1 - x)^2)
       output(0) = sqrt(y / cpt)
       if keyword_set( n_sigma) then begin 
         good= where( abs(var1-x) lt n_sigma* output(0), count) 
         if count gt 0 then begin 
           x = total(var1(good)) / count
           y = total((var1(good) - x)^2)
           output(0) = sqrt(y / count)
           ndef= count
         endif 
       endif
    ENDIF ELSE IF cpt GT 0 THEN BEGIN
       if keyword_set( median_first) then  x = median(var1(good_values)) else $ 
        x = total(var1(good_values)) / cpt
       y = total((var1(good_values) - x)^2)
       output(0) = sqrt(y / cpt)
       if keyword_set( n_sigma) then begin 
         good= where( abs(var1(good_values)-x) lt n_sigma* output(0), count) 
;         if count lt n_elements( var1) then begin 
           x = total(var1(good_values(good))) / count
           y = total((var1(good_values(good)) - x)^2)
           output(0) = sqrt(y / count)
           ndef= count
;         endif 
       endif
    ENDIF
    GOTO, CLOSING
 ENDIF

; we compute one value by element of the last dim. (map on last dim)
 IF (dim EQ 1) THEN BEGIN
    IF szv1(0) LT 2 THEN GOTO, CLOSING
    n_planes = szv1(szv1(0))
    output = make_array(n_planes, value=la_undef(tv1 > 4))
    x = output & ndef = output
    IF szm(0) EQ szv1(0) -1 THEN mask0 = mask
    IF szm(0) EQ 0 THEN mask0 = 0
    nele1 = n_elements(var1) / n_planes      ; number of elements
    FOR i =0l, n_planes-1 DO BEGIN
        var2 = var1(indgen(nele1) + i*nele1) ; value of interest
        IF szm(0) eq szv1(0) THEN mask0 = mask(indgen(nele1) + i * nele1)
        good_values = where(var2 NE undef and (mask0 eq 0), cpt)
        ndef(i) =cpt
        IF cpt GT 0 THEN BEGIN
          if keyword_set( median_first) then $ 
           x(i) = median(var2(good_values)) else $ 
           x(i) = total(var2(good_values)) / cpt
           y = total((var2(good_values) - x(i))^2)
           output(i) = sqrt(y / cpt)
           IF keyword_set( n_sigma) then begin 
              good= where( abs(var2(good_values)-x(i)) lt n_sigma* output(i), $ 
		count) 
;              IF count lt n_elements( var1) then begin 
                x(i) = total(var2(good_values(good))) / count
                y = total((var2(good_values(good)) - x)^2)
                output(0) = sqrt(y / count)
                ndef(i)= count
;              ENDIF 
           ENDIF
        ENDIF
    ENDFOR
 ENDIF

 ; one value by elements but on last dimension (map on every dim but the last
 ; one)
 IF (dim EQ -1) THEN BEGIN
    n_planes = szv1(szv1(0))
    nele1 = n_elements(var1) / n_planes         ; number of elements
    output = make_array(dim=szv1(1:szv1(0)-1), value=la_undef(tv1 > 4))
    x = output & ndef = output
    IF szm(0) EQ 1 THEN mask0 = mask
    IF szm(0) EQ 0 THEN mask0 = 0
    FOR i =0l, nele1-1 DO BEGIN
        var2 = var1(indgen(n_planes)*nele1 + i) ; value of interest
        IF szm(0) eq szv1(0) THEN mask0 = mask(indgen(n_planes)*nele1 + i)
        good_values = where(var2 NE undef and (mask0 eq 0), cpt)
        ndef(i) = cpt
        IF cpt GT 0 THEN BEGIN
           if keyword_set( median_first) then  $ 
            x(i) = median(var2(good_values)) else $ 
            x(i) = total(var2(good_values)) / cpt
           y = total((var2(good_values) - x(i))^2)
           output(i) = sqrt(y / cpt)
           IF keyword_set( n_sigma) then begin 
              good= where( abs(var2(good_values)-x(i)) le n_sigma* output(i), $ 
		count) 
;              IF count lt n_elements( var1) then begin 
                x(i) = total(var2(good_values(good))) / count
                y = total((var2(good_values(good)) - x)^2)
                output(0) = sqrt(y / count)
                ndef(i)= count
;              ENDIF 
           ENDIF
        ENDIF
    ENDFOR
 ENDIF

;------------------------------------------------------------
; closing
;------------------------------------------------------------
 
 CLOSING:
 
  RETURN, output
 
 END
