function hpixproj, m1, h1, h2, exact=exact, ring=ring, nested=nested
;+
; NAME:
;       HPIXPROJ
;
; PURPOSE:
;       Project a Healpix map m1 (with associated header h1) on header h2
;
; CALLING SEQUENCE:
;       m2 = hpixproj( m1, h1, h2, /exact )
;
; INPUTS:
;       m1 : Healpix vector to project
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
;       needs ASTRON and HEALPIX libraries
;
; PROCEDURE:
;       get_equinox, extast, sxpar, xy2ad, get_cootype, euler, mprecess, ang2pix_ring, ang2pix_nest
;
; MODIFICATION HISTORY:
;       2 June 2006 - Creation Marc-Antoine Miville-Deschenes
;       23 July 2009 - correct precession bug
;-

if (n_elements(h1) gt 1) then begin
    nside = sxpar(h1, 'NSIDE')
    ordering = strcompress(sxpar(h1, 'ORDERING'), /rem)
    equi1 = get_equinox(h1)
endif else begin
    ordering = 'NESTED'
    nside = sqrt(n_elements(m1)/12.)
endelse
if keyword_set(ring) then ordering = 'RING'
if keyword_set(nested) then ordering = 'NESTED'
if not keyword_set(equi1) then begin
    print, "Equinox of Healpix vector undefined, take J2000"
    equi1 = 2000.
endif
equi2 = get_equinox(h2)

; extract astrometry structure of "TO" headers
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
coordsys = strc(sxpar(h1, 'COORDSYS'))
case coordsys of
    'C' : sysco1 = 1
    'G' : sysco1 = 2
    'E' : sysco1 = 3
    else : sysco1 = 2
endcase

sysco2 = get_cootype(astr2)
if (sysco1 eq 0 or sysco2 eq 0) then $
  return, -1                    ; abort if unknown coordinate system

; Precess coordinates if TAN map does not have the same equinox as the
; Healpix map.
if (sysco2 ne 2 and equi2 ne equi1) then begin
   mprecess, a2, d2, equi2, equi1, exact=exact
   equi2=equi1
endif

if (sysco1 ne sysco2) then begin
    if (sysco2 eq 1 and sysco1 eq 2) then eulertype = 1
    if (sysco2 eq 2 and sysco1 eq 1) then eulertype = 2
    if (sysco2 eq 1 and sysco1 eq 3) then eulertype = 3
    if (sysco2 eq 3 and sysco1 eq 1) then eulertype = 4
    if (sysco2 eq 3 and sysco1 eq 2) then eulertype = 5
    if (sysco2 eq 2 and sysco1 eq 3) then eulertype = 6
    if (equi2 eq 1950) then fk4=1 else fk4=0
    euler, a2, d2, select=eulertype, fk4=fk4
endif

; find pixel numbers of "FROM" map for each coordinates of the "TO" map 
a2 = a2*!pi/180.
d2 = (90.-d2)*!pi/180.

if (ordering eq 'RING') then begin
    ang2pix_ring, nside, d2, a2, ipix
endif else begin
    ang2pix_nest, nside, d2, a2, ipix
endelse

; fill result map with closer neighbor
result = reform(m1(ipix), xsize, ysize)

return, result

end
