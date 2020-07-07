function mkhdr_iris, image, _Extra=extra
;+
; NAME:
;      MKHDR_IRIS
;
; PURPOSE:
;      Create a basic header for an image
;
; CALLING SEQUENCE:
;      header = mkhdr_iris( image, KEYWORD=VALUE )
;
; INPUTS:
;      image : the 2D array corresponding to the header
;
; KEYWORD PARAMETERS:
;      This function makes use of the _Extra keyword of IDL
;      which allows here to pass any keyword that one wants to have
;      in the header (see example).
;
; OUTPUTS:
;      Header 
;
; PROCEDURE:
;      sxaddpar, mkhdr (both from ASTRON)
;
; EXAMPLE:
;      map = fltarr(200, 200)
;      header = mkhdr_iris( map, CRVAL1=100., CRPIX1=1., CDELT1=-0.05, CTYPE1='RA---TAN', $
;                           CRVAL2=40., CRPIX2=1., CDELT2=0.05, CTYPE2='DEC--TAN')
;
;
; MODIFICATION HISTORY:
;      24/04/2006 Marc-Antoine Miville-Deschenes, creation
;-


mkhdr, header, image

if keyword_set( extra ) then begin
    fieldname = tag_names( extra )
    for i=0, n_tags( extra )-1 do sxaddpar, header, fieldname( i ), extra.( i )
endif

return, header

end
