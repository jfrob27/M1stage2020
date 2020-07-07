function mproj, m1, h1, h2, exact=exact
;+
; NAME:
;       MPROJ
;
; PURPOSE:
;       Project a map m1 (with associated header h1) on header h2
;
; CALLING SEQUENCE:
;       m2 = mproj( m1, h1, h2, exact=exact )
;
; INPUTS:
;       m1 : fltarr(2D) - map to project
;       h1 : header of m1
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
;       get_equinox, extast, sxpar, xy2ad, get_cootype, euler, mprecess, ad2xy, my_bilinear2
;
; MODIFICATION HISTORY:
;       25 Nov 2005 - Creation Marc-Antoine Miville-Deschenes
;-

equi1 = get_equinox(h1)
equi2 = get_equinox(h2)

; extract astrometry structure from both headers
extast, h1, astr1
extast, h2, astr2

; pixel coordinates map of the "TO" map
xsize = sxpar(h2, 'NAXIS1')
ysize = sxpar(h2, 'NAXIS2')
x2 = findgen(xsize)#replicate(1,ysize)
y2 = replicate(1,xsize)#findgen(ysize)

; sky coordinates map of the "TO" map
xy2ad, x2, y2, astr2, a2, d2

; Transform the sky coordinates of the "TO" map in the coordinate
; system of the "FROM" map (i.e. celestial, ecliptic or galactic)
sysco1 = get_cootype(astr1)
sysco2 = get_cootype(astr2)
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

; bilinear interpolation
;result = my_bilinear2(m1,x1,y1,silent=silent)
result = mbilinear(m1,x1,y1,silent=silent)

return, result

end
