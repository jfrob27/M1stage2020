function rmsource_wmap, map, ordering

npix = n_elements(map)
nside = npix2nside(npix)

; read point source catalog
data = readmamd(!DATA+'/WMAP/data_yr7/wmap_ptsrc_catalog_p4_7yr_v4.txt')

; create mask map
glon = reform(float(data[2,*]))
glat = reform(float(data[3,*]))
gal2thetaphi, glon, glat, theta, phi
mask = intarr(nside2npix(nside))
case ordering of
   'RING': begin
      ang2pix_ring, nside, theta, phi, idx
   end
   'NESTED': begin
      ang2pix_nest, nside, theta, phi, idx
   end
   else: begin
      print, 'ordering '+ordering+' unknown'
      map_ns = map
      goto, sortie
   endelse
endcase
mask[idx] = 1
fwhm = 60.  ; approximate WMAP beam - arcmin
masks = smooth_healpix(mask, fwhm, ordering=ordering)  
mask = 0

; identify pixels with point sources
map_ns = map
ind = where(masks gt 0.01)

; iterative smoothing to improve filling of point sources
map_ns(ind) = median(map)
for i=0, 4 do begin
    tempo = smooth_healpix(map_ns, 2*(5-i)*60., ordering=ordering) 
    map_ns(ind) = tempo(ind) 
endfor

sortie:

return, map_ns

end


