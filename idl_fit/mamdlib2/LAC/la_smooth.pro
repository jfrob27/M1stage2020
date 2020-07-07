FUNCTION LA_SMOOTH, data, nsmooth, dim=dim, mask=mask, $
                    edge_truncate=edge_truncate
;+ 
; NAME: LA_SMOOTH
; PURPOSE: 
;    Splitting mean on successive nsmooth values (like smooth function)
;    taking undefined values into account
;    If /dim compute it following last dim
; CALLING SEQUENCE: 
;   output=LA_SMOOTH(data, nsmooth, dim=dim, mask=mask)
; INPUTS: 
;   data,   -- integer or real array of any dim 
;   nsmooth -- integer 
; OPTIONAL INPUT PARAMETERS: 
;   none
; KEYED INPUTS: 
;   dim     -- 0/(1 or -1) : if 1 (or -1), data is considered as a cube and
;              smooth is comptued on all pixels (default is 0) 
;   mask    -- byte array : if given non zero masked values are considered
;              as undefined              
;   edge_truncate    --  SMOOTH EDGE_TRUNCATE keyword
;
; OUTPUTS: 
;    output -- 1 or 2D array, same type as data, same total of elements : 
;              smoothed data
; OPTIONAL OUTPUT PARAMETERS: 
;   none
; EXAMPLE: 
;   ICE>  print, la_smooth([2., 0., 1., 2.], 3)
;         2.00000      1.00000      1.00000      2.00000
;   ICE>  print, la_smooth([2., undef, 1., 2.], 3)
;         2.00000      1.50000      1.50000      2.00000
;   ICE>  print, la_smooth([[2., 2.],[undef, 0.],[1.,1.]], 3, /dim)
;         2.00000      2.00000
;         1.50000      1.00000
;         1.00000      1.00000
; ALGORITHM: 
;   Check data and nsmooth
;   If no dim, set it to 0
;   If dim eq 0 THEN
;   . set undefined values to 0
;   . apply smooth function
;   . get data weight as 1 for all defined values else 0
;   . apply smooth on weight
;   . correct output dividing by smoothed weight and reset undefined values
;   to undefined
;  Else select successive "plane" and apply same sequence on them 
; DEPENDENCIES: 
;   none
; SIDE EFFECTS: 
;   none
; RESTRICTIONS: 
;   nsmooth must be between 2 and data size
; CALLED PROCEDURES AND FUNCTIONS: 
;   LA_UNDEF
;   IDL routine SMOOTH
; MODIFICATION HISTORY: 
;    3-Nov-1995  written with template_gen          FV/FXD    IAS
;    25-Apr-2008 remove session control / now independant of ICE  MAMD IAS
;-
 
;------------------------------------------------------------
; initialization
;------------------------------------------------------------
  output= -1
 
;------------------------------------------------------------
; parameters check
;------------------------------------------------------------
 
 IF N_PARAMS() LT 2 THEN BEGIN
   PRINT, 'CALLING SEQUENCE: ', $ 
    'output=LA_SMOOTH(data, nsmooth, dim=dim, mask=mask)'
   GOTO, CLOSING
 ENDIF
 
 sdata= size( data) & td = sdata(sdata(0)+1)
 if td LT 1 or td GT 5 or sdata(0) eq 0 then BEGIN
    print, 'Wrong type or size data'
    GOTO, CLOSING
 ENDIF
 n_planes = sdata(sdata(0))
 nele = n_elements(data)
 nele1 = nele /n_planes

 sns= size(nsmooth) & tn = sns(sns(0)+1)
 if tn LT 1 or tn GT 5 or sns(0) ne 0 then BEGIN
    print, 'Wrong type or size for nsmooth'
    GOTO, CLOSING
 ENDIF

 IF nsmooth LE 1 or nsmooth ge nele THEN BEGIN
    print, 'Width must be > 2 and < array dim'
    GOTO, CLOSING
 ENDIF

 IF n_elements(mask) GT 0 THEN IF n_elements(mask) ne sdata(sdata(0)+2) $
 THEN BEGIN
    print, 'Inconsistent mask'
    GOTO, CLOSING
 ENDIF

 IF n_elements(dim) eq 0 THEN dim=0

 IF not keyword_set(edge_truncate) then edge_truncate=0

;------------------------------------------------------------
; function body
;------------------------------------------------------------
 
 undef= la_undef(td > 4)

 ; dim eq 0 result is formated as 1D array
 IF dim eq 0 THEN BEGIN
    inter= reform(data, nele)

    ; set undefined values to 0
    u=where(inter eq undef, nu)
    if nu gt 0 then inter(u)=0.
    inter= SMOOTH(temporary(inter), nsmooth, edge_truncate=edge_truncate)

    ; get real weight and compute correction factor
    weight= inter*0.+1.
    if nu gt 0 then weight(u)= 0.
    wout= SMOOTH(temporary(weight), nsmooth)

    ; correct weight for undefined values
    output = replicate(undef, nele)
    v= where( wout ne 0., nv)
    if nv ne 0 then output(v)= temporary(inter(v))/ temporary(wout(v))
 ENDIF ELSE BEGIN

 ; dim eq 1 or -1, result is formated as a 2D array, last dim of data
 ; is saved
    output = replicate(undef, nele1, n_planes)
    FOR i=0l,nele1-1 DO BEGIN
        inter= reform(data(indgen(n_planes)*nele1 + i))

        ; set undefined values to 0
        u=where(inter eq undef, nu)
        if nu gt 0 then inter(u)=0.
        inter= SMOOTH(temporary(inter), nsmooth)

        ; get real weight and compute correction factor
        weight= inter*0.+1.
        if nu gt 0 then weight(u)= 0.
        wout= SMOOTH(temporary(weight), nsmooth)

        ; correct weight for undefined values
        v= where( wout ne 0., nv)
        if nv ne 0 then output(i,v)= temporary(inter(v))/ temporary(wout(v))
    ENDFOR
ENDELSE 
 
;------------------------------------------------------------
; closing
;------------------------------------------------------------
 
 CLOSING:

  RETURN, output
 
 END
