PRO PRJ_HEADER_COO, header, x, y
;+ 
; NAME: PRJ_HEADER_COO
; PURPOSE: 
;      Create coordinates of all pixels of a map from its FITS header
; CATEGORY: III-10-b
; CALLING SEQUENCE: 
;   PRJ_HEADER_COO, header  [, x, y] 
; INPUTS: 
;   header    -- string array : FITS header (corresponding to a map) with
;                at least CRPIX(1/2), CRVAL(1/2), CDELT(1/2), NAXIS(1/2), 
;                CTYPE(1/2)
; OPTIONAL INPUT PARAMETERS: 
;   none
; KEYED INPUTS: 
;   none
; OUTPUTS: 
;   x, y      -- 2D arrays : pixels by pixels coordinates
; OPTIONAL OUTPUT PARAMETERS: 
;   none
; EXAMPLE: 
; ALGORITHM: 
;   straighforward call WCSXY2SPH
; DEPENDENCIES: 
;   Require Astrolib
; COMMON BLOCKS: 
;    SESSION_BLOCK, SESSION_MODE, ERROR_CURRENT, STATUS_BOOL 
; SIDE EFFECTS: 
;   none
; RESTRICTIONS: 
;   none
; CALLED PROCEDURES AND FUNCTIONS: 
;   Astrolib SXPAR and WCSXY2SPH
; MODIFICATION HISTORY: 
;    10-Nov-1995  written with template_gen                 FV IAS
;    28-Jul-2008 remove session control / now independant of ICE  MAMD IAS
;-
  
;------------------------------------------------------------
; initialization
;------------------------------------------------------------
 
  s_header = CONV_STRING(header)
  s_x = CONV_STRING(x)
  s_y = CONV_STRING(y)
 CALL_VAL = [s_header, s_x, s_y]
 
 x = -1 & y = -1

;------------------------------------------------------------
; parameters check
;------------------------------------------------------------
 
 IF N_PARAMS() LT 1 THEN BEGIN
   PRINT, 'CALLING SEQUENCE: ', $ 
    'PRJ_HEADER_COO, header  [, x, y] '
   GOTO, CLOSING
 ENDIF
 
;------------------------------------------------------------
; function body
;------------------------------------------------------------
 
; extract field of view, reference pixel position and coordinates
 cdelt1=sxpar(header,'cdelt1') &  cdelt2=sxpar(header,'cdelt2')
 crpix1=sxpar(header,'crpix1') &  crpix2=sxpar(header,'crpix2')
 crval1=sxpar(header,'CRVAL1') &  crval2=sxpar(header,'CRVAL2')

; extract map size and projection type
 naxis1=sxpar(header,'NAXIS1') &  naxis2=sxpar(header,'NAXIS2')
 ctype1=sxpar(header,'CTYPE1') &  ctype2=sxpar(header,'CTYPE2')

cdelt1 = float(cdelt1)
cdelt2 = float(cdelt2)

; initialize x and y with local coordinates
 x=(findgen(naxis1)-(crpix1-1))*(cdelt1)
 y=(findgen(naxis2)-(crpix2-1))*(cdelt2)

; fill 2D x and y
 xx=fltarr(naxis1,naxis2) & yy=xx
 for i=0,naxis2-1 DO xx(*,i)=x
 FOR j=0,naxis1-1 DO yy(j,*)=y

 x = 0 & y = 0

; reproject following projection type
 wcsxy2sph,temporary(xx), temporary(yy), coo1, coo2, crval=[crval1,crval2], ctype=[ctype1,ctype2]
 
 x = temporary(coo1) & y = temporary(coo2)

;------------------------------------------------------------
; closing
;------------------------------------------------------------
 
 CLOSING:
 
  RETURN
 
 END
