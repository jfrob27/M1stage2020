pro hpx_fill_bad_pixels, map, order=order

if not keyword_set(order) then order='RING'

nside = npix2nside(n_elements(map))
nside_cur = nside
ind = where(map eq !healpix.bad_value, nbad)
if (nbad gt 0) then begin
   map2 = map
   while (nbad gt 0) do begin
      nside_cur = nside_cur/2.
      print, nside_cur
      ud_grade, map2, map2, nside=nside_cur, order_in=order, order_out=order
      bad = where(map2 eq !healpix.bad_value, nbad)
   end
   ud_grade, map2, map2, nside=nside, order_in=order, order_out=order
   map[ind] = map2[ind]
endif

end
