FUNCTION LA_HISTO, var, X, binsize=binsize, max=max, min=min, $
                   omax=omax, omin=omin, reverse_indices=reverse_indices
;+ 
; NAME: LA_HISTO
; PURPOSE:
;   apply IDL function HISTOGRAM to a lacunar array, discarding first undefined
;   values.
;   HISTOGRAM compute the density function of var.
;   var must be an array with at least two different defined values.  
; CALLING SEQUENCE: 
;   output=LA_HISTO(var, binsize=binsize, max=max, min=min, $
;          omax=omax, omin=omin, reverse_indices=reverse_indices)
; INPUTS: 
;   var
; OPTIONAL INPUT PARAMETERS: 
;   none
; KEYED INPUTS: 
;   binsize, max, min, omax, omin, reverse_indices : HISTOGRAM keywords
;   see IDL reference guide.
; OUTPUTS: 
;    output
; OPTIONAL OUTPUT PARAMETERS: 
;   X         -- array : var values
; EXAMPLE: 
; ALGORITHM:
;   set output to 0
;   scan array for defined values
;   call histogram on defined values
; DEPENDENCIES:
;   none 
; SIDE EFFECTS: 
;   none
; RESTRICTIONS: 
;   none
; CALLED PROCEDURES AND FUNCTIONS:
;   LA_UNDEF
;   LA_MIN, LA_MAX
;   IDL routine HISTOGRAM 
; MODIFICATION HISTORY: 
;    13-Feb-1995  written with template_gen              FV IAS 
;    19-Feb-1995  set output to number of defined values
;                 in case of constant var                FV IAS
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
   PRINT, 'CALLING SEQUENCE: ', $ 
    'output=LA_HISTO(var, [X,] binsize=binsize, max=max, $'
   PRINT, '                   min=min, omax=omax, omin=omin, ', $
          ' reverse_indices=reverse_indices)'
   GOTO, CLOSING
 ENDIF
 
 s_var = size(var)
 tva = s_var(s_var(0)+1)

 IF tva LT 1 or (tva GT 5) THEN BEGIN
    print, 'Wrong type for var :' + strtrim(tva)
    GOTO, CLOSING
 ENDIF

 IF n_elements(var) LE 1 THEN BEGIN
    print, 'var should be an array of more than one value'
    GOTO, CLOSING
 ENDIF

 undef = LA_UNDEF(tva)

;------------------------------------------------------------
; function body
;------------------------------------------------------------

; set output to 0 (zero density, if no defined value found)
 output = 0

; extract defined values location and apply histogram
 good_pixels = where(var ne undef, cpt)

 IF n_elements(binsize) eq 0 THEN binsize=1
 IF n_elements(max) eq 0 THEN max=LA_MAX(var)
 IF n_elements(min) eq 0 THEN min=LA_MIN(var)
 omax = max & omin = min

 IF min eq max THEN BEGIN
    print, 'Cannot apply HISTOGRAM on constant array'
    output = [cpt]
    GOTO, CLOSING
 ENDIF

 IF cpt GT 0 THEN output = HISTOGRAM(var(good_pixels), binsize=binsize, $
                           max=max, min=min, reverse_indices=reverse_indices) 
 
 X = (INDGEN( FIX( (MAX- MIN) / BINSIZE+ 1.5)) + 0.5)* BINSIZE + MIN

;------------------------------------------------------------
; closing
;------------------------------------------------------------
 
 CLOSING:
 
  RETURN, output
 
 END


