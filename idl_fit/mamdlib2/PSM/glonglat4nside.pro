pro glonglat4nside, nside, glon, glat, order=ordering, ring=ring, nested=nested

if keyword_set(nested) then ordering = 'NESTED'
if keyword_set(RING) then ordering = 'RING'
if not keyword_set(ordering) then ordering = 'RING'

pix = lindgen(nside2npix(nside))
IF strmid(STRTRIM(STRUPCASE(ordering),2),0,4) EQ 'NEST' THEN BEGIN
   PIX2ANG_NEST, nside, pix, theta, phi
endif else begin
   PIX2ANG_RING, nside, pix, theta, phi
endelse

glat = 90.-theta*180./!pi
glon = phi*180./!pi

end

