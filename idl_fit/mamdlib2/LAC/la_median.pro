FUNCTION LA_MEDIAN, var1, dim=dim, mask=mask
;+ 
; NAME: LA_MEDIAN
; PURPOSE:
;   compute median value without taking into account undefined value
;   If mask given extract median only inside good values of mask  
; CALLING SEQUENCE: 
;   output=LA_MEDIAN(var1, dim=dim, mask=mask)
; INPUTS: 
;   var1
; OPTIONAL INPUT PARAMETERS:
;   none 
; KEYED INPUTS: 
;   dim     -- dimension of the result 
;                0 : return median of every elementary defined values (default)
;                1 : return vector with median values of every "planes". (with
;                    as many elements as in the last dimension)
;               -1 : return median "plane" (one dimension less than var1)
;   mask    -- byte array : dimensions should be
;                if dim eq 0 : same as var1
;                if dim eq 1 : same as var1 but possibly 1 on last one
;                if dim eq -1 : same as var1 or vector 
;              should follow SCD mask conventions : good values are 0 masked
;              values.
; OUTPUTS: 
;  output   -- median value 
; OPTIONAL OUTPUT PARAMETERS:
;  none 
; EXAMPLE:
;  ICE> print, la_median([[1, 2], [0, 3]])
;         3
;  ICE> print, la_median([[1, 2], [0, 3]], dim=1)
;             2           3
;  ICE> print, la_median([[1, 2], [0, 3]], dim=-1)
;             1           3
; ALGORITHM:
;   straightforward 
; DEPENDENCIES:
;   none 
; SIDE EFFECTS:
;   none 
; RESTRICTIONS: 
;   the routine la_undef should be up to date
; CALLED PROCEDURES AND FUNCTIONS: 
;    LA_UNDEF
; MODIFICATION HISTORY: 
;    1-Aug-1994  written with template_gen          FV IAS
;    3-Oct-1994  V.1.0 for configuration control    FV IAS
;   13-Feb-1994  add KEY mask                       FV IAS
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
   PRINT, 'CALLING SEQUENCE: output=LA_MEDIAN(var1, dim=dim, mask=mask)'
   GOTO, CLOSING
 ENDIF

 szv1 = size(var1)
 tv1 = szv1(szv1(0)+1)

 ; check we have arithmetic type
 IF (tv1 LT 1) or (tv1 GT 5) THEN BEGIN
    print, 'Wrong type for var1:'+CONV_STRING(tv1)
    GOTO, CLOSING
 ENDIF
 undef = la_undef(tv1)
 output = undef

 IF n_elements(dim) eq 0 THEN dim = 0

 ; check mask
 szm = size(mask)
 tm = szm(szm(0)+1)
 IF (tm GT 3 ) THEN BEGIN
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

 IF szv1(0) EQ 0 THEN BEGIN
    output = var1
    GOTO, CLOSING
 ENDIF

 IF n_elements(mask) LE 0 THEN mask = 0 

 n_planes = szv1(szv1(0))
 nele1 = n_elements(var1) / n_planes
 CASE dim OF
      0 : BEGIN
            output = undef
            good_values = where((var1 ne undef) and (mask eq 0), cpt)
            IF cpt NE 0 THEN output = MEDIAN(var1(good_values))
          END
      1 : BEGIN
            output = replicate(undef, n_planes)
            IF szm(0) EQ szv1(0) -1 THEN mask0 = mask
            IF szm(0) EQ 0 THEN mask0 = 0
            FOR i = 0l, n_planes-1 DO BEGIN
                index1= i * nele1
                index2= (i+1) * nele1 - 1
                plane = var1(index1:index2)
                IF szm(0) eq szv1(0) THEN mask0 = mask(index1:index2)
                good_values = where((plane NE undef) and (mask0 eq 0), cpt)
                IF cpt GT 0 THEN output(i) = MEDIAN(plane(good_values))
            ENDFOR
          END
       -1 : BEGIN
            odim = szv1(1:szv1(0)-1)
            output = make_array(dimension=odim, value=undef)
            IF szm(0) EQ 1 THEN mask0 = mask
            IF szm(0) EQ 0 THEN mask0 = 0
            FOR i = 0l, nele1-1 DO BEGIN
                index = indgen(n_planes) * nele1 + i
                var_array = var1(index)
                IF szm(0) eq szv1(0) THEN mask0 = mask(index)
                index = where((var_array NE undef) and (mask0 eq 0), cpt)
                IF cpt GT 0 THEN output(i) = MEDIAN(var_array(index))
            ENDFOR
          END
        ELSE : print, 'Irrelevant key dim ' + CONV_STRING(dim)
   END

;------------------------------------------------------------
; closing
;------------------------------------------------------------
 
 CLOSING:
  
  RETURN, output
 
 END
