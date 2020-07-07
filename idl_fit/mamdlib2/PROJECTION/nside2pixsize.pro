function nside2pixsize, nside, degree=degree, arcmin=arcmin

; gives the linear angular size of a healpix pixel
; for a given NSIDE.
;
; M.-A. Miville-Deschenes, Jan 24, 2012

factor = 1.
if keyword_set(degree) then factor = 1.
if keyword_set(arcmin) then factor = 60.

res = sqrt(41253./nside2npix(nside))*factor

return, res

end
