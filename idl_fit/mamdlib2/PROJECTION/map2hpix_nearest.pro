function map2hpix, m1, h1, nside, exact=exact, ring=ring, nested=nested
;+
; NAME:
;       MAP2HPIX
;
; PURPOSE:
;       Project a square map m1 (with associated header h1) on a
;       healpix map of a given nside and in Galactic coordinate.
;
; CALLING SEQUENCE:
;       m2 = map2hpix( m1, h1, nside, [/exact, /ring, /nested] )
;
; INPUTS:
;       m1 : square map to project
;       h1 : header of m1
;       nside : nside of healpix map
;
; KEYWORD PARAMETERS:
;       exact - if this keyword is set, the precession from B1950 to J2000
;               or from J2000 to B1950 is done using BPRECESS or JPRECESS
;               instead of PRECESS. Using the exact keyword slows down
;               significantly MPROJ but the astrometry is more
;               accurate.
;
;       ring - if set, output healpix map will be in RING ordering
;              
;       nested - if set, output healpix map will be in NESTED ordering (default)
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
;       needs ASTRON and HEALPIX libraries
;
; PROCEDURE:
;       get_equinox, extast, sxpar, xy2ad, get_cootype, euler, mprecess, ang2pix_ring, ang2pix_nest
;
; MODIFICATION HISTORY:
;       2 April 2008 - Creation Marc-Antoine Miville-Deschenes
;-

; check ordering
if keyword_set(ring) then ordering = 'RING'
if keyword_set(nested) then ordering = 'NESTED'
if not keyword_set(ordering) then ordering = 'NESTED'

; astrometry of healpix map
equi2 = 2000.
sysco2 = 2   ; we assume Galactic coordinate for the Healpix map

; extract astrometry structure of square map
extast, h1, astr1
equi1 = get_equinox(h1)
sysco1 = get_cootype(astr1)

; pixel coordinates map of the "FROM" map
xsize = sxpar(h1, 'NAXIS1')
ysize = sxpar(h1, 'NAXIS2')
x1 = findgen(xsize)#replicate(1,ysize)
y1 = replicate(1,xsize)#findgen(ysize)

; sky coordinates map of the "FROM" map
xy2ad, x1, y1, astr1, a1, d1

; Precess coordinates if TO and FROM map don't have the same equinox
; Precess coordinates if TAN map does not have the same equinox as the
; Healpix map.
if (sysco1 ne 2 and equi1 ne equi2) then begin
   mprecess, a1, d1, equi1, equi2, exact=exact
   equi1 = equi2
endif

; Transform the sky coordinates of the "FROM" map in the coordinate
; system of the Healpix map (i.e. celestial, ecliptic or galactic)
if (sysco1 eq 0 or sysco2 eq 0) then $
  return, -1                    ; abort if unknown coordinate system
if (sysco1 ne sysco2) then begin
    if (sysco1 eq 1 and sysco2 eq 2) then eulertype = 1
    if (sysco1 eq 2 and sysco2 eq 1) then eulertype = 2
    if (sysco1 eq 1 and sysco2 eq 3) then eulertype = 3
    if (sysco1 eq 3 and sysco2 eq 1) then eulertype = 4
    if (sysco1 eq 3 and sysco2 eq 2) then eulertype = 5
    if (sysco1 eq 2 and sysco2 eq 3) then eulertype = 6
    if (equi1 eq 1950) then fk4=1 else fk4=0
    euler, a1, d1, select=eulertype, fk4=fk4
endif

a1 = a1*!pi/180.
d1 = (90-d1)*!pi/180.

if (ordering eq 'RING') then begin
    ang2pix_ring, nside, d1, a1, ipix
endif else begin
    ang2pix_nest, nside, d1, a1, ipix
endelse

; fill result map with closer neighbor (average of pixels)
result = fltarr(nside2npix(nside))
mask = result

for i=0L, n_elements(a1)-1 do begin
   result(ipix[i]) = result(ipix[i]) + m1[i]
   mask(ipix[i]) = mask(ipix[i])+1
endfor
ind = where(mask gt 1, nbind)
if (nbind gt 0) then result(ind) = result(ind)/mask(ind)

return, result

end
