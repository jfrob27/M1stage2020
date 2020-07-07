; EB2QU
;
; Create Q and U from E and B
;
; October 28, 2011 - M.-A. Miville-Deschenes

pro eb2qu, E, B, Q, U, ordering=ordering, nested=nested, ring=ring, lmax=lmax

if keyword_set(nested) then ordering='NESTED'
if keyword_set(ring) then ordering='RING'
npix = n_elements(E)
nside = npix2nside(npix)
if not keyword_set(lmax) then lmax = 3*nside

psm_map2alm, E, almE, ordering=ordering, lmax=lmax
psm_map2alm, B, almB, ordering=ordering, lmax=lmax
si = size(almE)
alm_out = fltarr(si[1], si[2], 3)
alm_out[*,*,1] = almE
alm_out[*,*,2] = almB
psm_alm2map, alm_out, qumap_out, ordering=ordering, hpx_nside=nside, /polar

Q = qumap_out[*,1]
U = qumap_out[*,2]

end

