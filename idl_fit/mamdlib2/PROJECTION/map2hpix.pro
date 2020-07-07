function map2hpix, m1, h1, h2, exact=exact
;+
; NAME:
;       MAP2HPIX
;
; PURPOSE:
;       Project a map m1 (with associated header h1) on healpix vector
;       of header h2
;
; CALLING SEQUENCE:
;       m2 = map2hpix( m1, h1, h2, exact=exact )
;
; INPUTS:
;       m1 : fltarr(2D) - map to project
;       h1 : header of m1
;       h2 : header of healpix vector
;
; KEYWORD PARAMETERS:
;       exact - if this keyword is set, the precession from B1950 to J2000
;               or from J2000 to B1950 is done using BPRECESS or JPRECESS
;               instead of PRECESS. Using the exact keyword slows down
;               significantly MPROJ but the astrometry is more accurate.
;
; OUTPUTS:
;       m2 : projected map
;
; COMMON BLOCKS:
;       none
;
; SIDE EFFECTS:
;       none
;
; RESTRICTIONS:
;       needs ASTRON library
;
; PROCEDURE:
;       get_equinox, extast, sxpar, xy2ad, get_cootype, euler, mprecess, ad2xy, mbilinear
;
; MODIFICATION HISTORY:
;       11 Feb 2012 - Creation Marc-Antoine Miville-Deschenes
;-

; extract astrometry information of the "FROM" map
equi1 = get_equinox(h1)
extast, h1, astr1
sysco1 = get_cootype(astr1)

; sky coordinates map of the "TO" map
nside = sxpar(h2, 'NSIDE')
ordering = strc(sxpar(h2, 'ORDERING'))
sysco2 = 2   ; Galactic
equi2 = 2000
ipix = lindgen(nside2npix(nside))
if (ordering eq 'RING') then begin
    pix2ang_ring, nside, ipix, theta, phi
endif else begin
    pix2ang_nest, nside, ipix, theta, phi
endelse
thetaphi2gal, theta, phi, a2, d2

; Transform the sky coordinates of the "TO" map in the coordinate
; system of the "FROM" map (i.e. celestial, ecliptic or galactic)
if (sysco1 eq 0 or sysco2 eq 0) then $
  return, -1                    ; abort if unknown coordinate system
if (sysco1 ne sysco2) then begin
    if (sysco2 eq 1 and sysco1 eq 2) then eulertype = 1
    if (sysco2 eq 2 and sysco1 eq 1) then eulertype = 2
    if (sysco2 eq 1 and sysco1 eq 3) then eulertype = 3
    if (sysco2 eq 3 and sysco1 eq 1) then eulertype = 4
    if (sysco2 eq 3 and sysco1 eq 2) then eulertype = 5
    if (sysco2 eq 2 and sysco1 eq 3) then eulertype = 6
    if (sysco2 eq 2) then equi2 = equi1 ; force to arrive in equi1 if galactic coordinates
    if (equi2 eq 1950) then fk4=1 else fk4=0
    euler, a2, d2, select=eulertype, fk4=fk4
endif

; Precess coordinates if TO and FROM map don't have the same equinox
mprecess, a2, d2, equi2, equi1, exact=exact

; pixel coordinates of the "TO" map in the "FROM" map
ad2xy, a2, d2, astr1, x1, y1

; bilinear interpolation (mbilinear needs a 2D array, create one artificially)
x = fltarr(1, n_elements(x1))
x[0,*] = x1
x1 = 0
y = fltarr(1, n_elements(y1))
y[0,*] = y1
y1 = 0
result = mbilinear(m1,x,y,silent=silent)
result = reform(result)

return, result

end
