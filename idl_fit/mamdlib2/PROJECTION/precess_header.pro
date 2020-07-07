;+
; NAME:
;       precess_header
;
; PURPOSE:
;       compure precession in the header (from B1950 to J2000 or J2000 to B1950) 
;
; CATEGORY:
;      ISO, IRAS data processing
;
; CALLING SEQUENCE:
;      precess_header, hs
; 
; INPUTS:
;      hs: header
;	
; OUTPUTS:
;      hs: modified header
;
; PROCEDURE:
;      SXPAR, SXADDPAR, JPRECESS, BPRECESS, GET_EQUINOX
;
; EXAMPLE:
;      default: 2000. -> 1950. precess_header, hs
;
; MODIFICATION HISTORY:
;      ? Written by JP Bernard, G. Lagache, IAS
;      20-Mar-98 adapted  H. Dole, IAS
;      10-Aug-2005 M.A. Miville-Deschenes, IAS
;                  Add silent keyword. 
;                  Use of get_equinox, jprecess and bprecess. 
;-

PRO precess_header, hs, silent=silent

crval1= sxpar(hs,'crval1')
crval2= sxpar(hs,'crval2')
equinox = get_equinox(hs, c)
if (c eq -1) then begin
    print, "EQUINOX, EPOCH or RADECSYS keyword not found in header"
    goto, sortie
endif

case equinox of
    1950: begin
        if not keyword_set(silent) then print, "precess header from B1950 to J2000"
        jprecess, crval1, crval2, crval1new, crval2new
        sxaddpar,hs,'crval1',crval1new
        sxaddpar,hs,'crval2',crval2new
        sxaddpar,hs,'equinox', '2000'
        sxaddpar,hs,'epoch', '2000'
    end
    2000: begin
        if not keyword_set(silent) then print, "precess header from J2000 to B1950"
        bprecess, crval1, crval2, crval1new, crval2new
        sxaddpar,hs,'crval1',crval1new
        sxaddpar,hs,'crval2',crval2new
        sxaddpar,hs,'equinox','1950'
        sxaddpar,hs,'epoch','1950'
    end
    else: print, "Equinox unknown:", equinox
endcase

sortie:

END

