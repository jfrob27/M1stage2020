function mapdipole, nside, param, ordering=ordering, ring=ring, nested=nested

if keyword_set(nested) then ordering='NESTED'
if keyword_set(ring) then ordering='RING'
if not keyword_set(ordering) then begin
   print, 'ordering not set, assumes RING'
   ordering='RING'
endif

amplitude = param[0]
GLON = param[1]
GLAT = param[2]

id_pix = lindgen(nside2npix(nside))

if ordering eq 'RING' then PIX2VEC_RING, nside, id_pix, vec else PIX2VEC_NEST, nside, id_pix, vec 

ang2vec, GLAT, GLON, dipole, astro = 1
dipole = reform(dipole)*amplitude
result = dipole ## vec 

return, result

end
