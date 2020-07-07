FUNCTION LA_ADD, var1, var2
;+ 
; NAME: LA_ADD
; PURPOSE:
;          add two cubes, or a scalar to every element of a cube, or
;          an "image" to every "image" of a cube or every element of a vector
;          to every "image" of a cube taking into
;          account undefined values (undef+undef=undef, undef+def=undef)
;          same function as ICCRED2 add_cube_cube, add_cube_constant and
;          add_cube_image and add_cube_vector, with possibility of a 4D cube
; CALLING SEQUENCE: 
;   var_out = LA_ADD(var1, var2)
; INPUTS: 
;   var1,   -- array of arithmetical type (byte, int, long, float or double)
;   var2,   -- either scalar or array with compatible dimension
; OPTIONAL INPUT PARAMETERS:
;   none 
; KEYED INPUTS:
;   none 
; OUTPUTS:
;   var_out -- array of same dimension than var1 with most precise type
; OPTIONAL OUTPUT PARAMETERS:
;   none 
; EXAMPLE:
;   ICE> print, la_add([1, 0, 2, 1], 6)
;          7       6       8       7
;   ICE> print, la_add([1, 0, 2, 1], [6,0,0,0])
;          7       0       2       1
;   ICE> print, la_add([[1, 0, 0],[ 2, 1, 0]], [6,0])
;          7       6      6
;          2       1      0
;   ICE> print, la_add([[1, 0, 0],[ 2, 1, 0]], [6,0,0])
;          7       6       6
;          2       1       0
; ALGORITHM:
;   check var2 size
;   if var1 and var2 have same size and dimensions then add arrays value by
;      value
;   if var2 is a scalar then add var2 to every value of var1
;   if var2 is a vector of n elements and var1 an array with n elements in
;      most internal dimension, then add var2(i) to every "plane" of var1
;   if var2 has one dimension less than var1, then add var2 to every "plane" of
;      var1 
; DEPENDENCIES:
;   none 
; SIDE EFFECTS:
;   none 
; RESTRICTIONS:
;   no overflow check
; CALLED PROCEDURES AND FUNCTIONS:
;   LA_UNDEF
; MODIFICATION HISTORY: 
;    6-Jul-1994  written with template_gen        FV IAS
;    3-Oct-1994  V.1.0 for configuration control  FV IAS
;    25-Apr-2008 remove session control / now independant of ICE  MAMD IAS
;-
 
;------------------------------------------------------------
; initialization
;------------------------------------------------------------
  var_out = -1
 
;------------------------------------------------------------
; parameters check
;------------------------------------------------------------
 
 IF N_PARAMS() LT 2 THEN BEGIN
   PRINT, 'CALLING SEQUENCE: var_out = LA_ADD(var1, var2)'
   GOTO, CLOSING
 ENDIF

 szv1= size(var1)
 tv1 = szv1(szv1(0) + 1)  
 szv2= size(var2)
 tv2 = szv2(szv2(0) + 1)

 ; check we have arithmetic types (1 to 5: byte, int, long int, float or
 ; double)
 IF (tv1 LT 1) or (tv1 GT 5) THEN BEGIN
    print, 'Wrong type for var1:'+CONV_STRING(tv1)
    GOTO, CLOSING
 ENDIF

 IF (tv2 NE tv1) and ((tv2 LE 1) or (tv2 GT 5)) THEN BEGIN
    print, 'Wrong type for var2:'+CONV_STRING(tv2)
    GOTO, CLOSING
 ENDIF 

 undef = la_undef(tv1 > tv2)
 
 ; check dimension consistency
 IF szv2(0) GT szv1(0) THEN BEGIN
    print, 'Wrong dimension for var2:'+strtrim(szv2(0),2)+' versus '+$
                 strtrim(szv1(0),2)
    GOTO, CLOSING
 ENDIF
 ok = 1
 FOR i=1, szv2(0) DO ok = ok and (szv1(i) eq szv2(i))
 ok = ok or ((szv2(0) EQ 1) and (szv2(1) EQ szv1(szv1(0)) ) )
 IF not OK THEN BEGIN
    print, 'Wrong size for var2:'+CONV_STRING(szv2)+ ' versus var1: '+$
                 CONV_STRING(szv1)
    GOTO, CLOSING
 ENDIF

 ; initialize output to undefined cube  
 IF szv1(0) NE 0 THEN var_out=make_array(dim=szv1(1:szv1(0)), value=undef)

;------------------------------------------------------------
; function body
;------------------------------------------------------------

; variables of same dimensions (extension of ICCRED2 add_cube_cube)
 IF szv2(0) EQ szv1(0) THEN BEGIN
    ; update output only on defined values
    good_values = where((var1 eq undef) or (var2 eq undef), cpt)
    IF cpt EQ 0 THEN BEGIN & var_out = var1 +var2 & GOTO, CLOSING & ENDIF
    good_values = where((var1 ne undef) and (var2 ne undef), cpt)
    IF cpt GT 0 THEN var_out(good_values) = var1(good_values)+var2(good_values)
    GOTO, CLOSING      
 ENDIF

; one array variable and one scalar value (previous add_cube_constant)
 IF (szv2(0) EQ 0) and (var2(0) NE undef) THEN BEGIN
    good_values = where(var1 eq undef, cpt) 
    IF cpt EQ 0 THEN BEGIN & var_out = var1 + var2 & GOTO, CLOSING & ENDIF
    good_values = where(var1 ne undef, cpt) 
    IF cpt GT 0 THEN var_out(good_values) = var1(good_values) + var2
    GOTO, CLOSING      
 ENDIF

; one dimension for var2  (previous add_cube_vector),
; we add a scalar value, var2(i) on every instance of last dimension
; (output(*...*,i) <- var1(*...*,i)+var2(i) -- mapping de l'addition d'une cste
; sur le "cube" avec -1 dimension
 IF (szv2(0) EQ 1) and (szv2(1) eq szv1(szv1(0))) THEN BEGIN
    bad_v1 = where(var1 eq undef, cpt)
    n_planes = szv1(szv1(0))
    nele1 = n_elements(var1) / n_planes ; number of elements within one "image"
    FOR i = 0l, n_planes-1 DO BEGIN
        index1= i * nele1
        index2= (i+1) * nele1 - 1
        IF var2(i) NE undef THEN $
           var_out(index1:index2) = var1(index1:index2) + var2(i)
    ENDFOR
    IF cpt NE 0 THEN var_out(bad_v1) = undef
    GOTO, CLOSING
 ENDIF 
 
; just one dimension less (previous add_cube_image), we add var2 on every
; instance of last dimension (output(*...*,i) <- var1(*...*,i)+var2(*...*)
 IF szv2(0) EQ szv1(0) - 1 THEN BEGIN
    bad_v1 = where(var1 eq undef, cpt)
    bad_v2 = where(var2 eq undef, cpt2)
    n_planes = szv1(szv1(0))
    nele1 = n_elements(var1) / n_planes    
    FOR i = 0l, n_planes-1 DO BEGIN
        index1= i * nele1
        index2= (i+1) * nele1 - 1
        plane = var1(index1:index2) + var2 
        IF cpt2 GT 0 THEN plane(bad_v2) = undef
        var_out(index1:index2) = plane
    ENDFOR
    IF cpt GT 0 THEN var_out(bad_v1) = undef
 ENDIF 
;------------------------------------------------------------
; closing
;------------------------------------------------------------
 
 CLOSING:
  
  RETURN, var_out
 
 END
