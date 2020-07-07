; QU2EB
;
; Create E and B from Q and U.
;
; October 28, 2011 - M.-A. Miville-Deschenes

pro qu2eb, Q, U, E, B, ordering=ordering, nested=nested, ring=ring, lmax=lmax

if keyword_set(nested) then ordering='NESTED'
if keyword_set(ring) then ordering='RING'
npix = n_elements(Q)
nside = npix2nside(npix)
if not keyword_set(lmax) then lmax = 3*nside

mapIQU = fltarr(npix,3)
mapIQU[*,1] = Q
mapIQU[*,2] = U

psm_map2alm, mapIQU, alm, /polar, ordering=ordering, lmax=lmax

psm_alm2map, alm[*,*,1], E, ordering=ordering, hpx_nside=nside, /over
psm_alm2map, alm[*,*,2], B, ordering=ordering, hpx_nside=nside, /over

end

