; 29/02/2008 - MAMD - adapation de anafast_cxx.pro (dans PSM/tools)
;-
pro myanafast, map, l, cl, nested=nested, ring=ring, $
               double=double, polarisation=polarisation, $
               iter=iter, weighted=weighted, dir=dir

if not keyword_set(dir) then dir = '.'
nside = npix2nside(n_elements(map))
lmax = 2*nside
mapname = dir+'/myanafast_input.fits'
outname = dir+'/myanafast_output.fits'
tmp = file_search(mapname,count=nb)
if (nb eq 1) then spawn, 'rm -f '+mapname
tmp = file_search(outname,count=nb)
if (nb eq 1) then spawn, 'rm -f '+outname
if (not keyword_set(nested) and not keyword_set(ring)) then nested=1

if keyword_set(ring) then write_fits_map, mapname, map, /ring
if keyword_set(nested) then write_fits_map, mapname, map, /nested

;conf = gettmpfilename('tmp-psm_anafast',suffix='.conf')
conf = 'myanafast.conf'
openw, 1, conf
if not keyword_set(weighted) then begin
   printf,1,'weighted = false'       
endif else begin
   healpix_data=!HEALPIX_DIR+'/data/'
   print,healpix_data
   printf,1,'weighted = true'
   printf,1,'healpix_data = '+ healpix_data
endelse
  
printf,1, 'nlmax = '+strtrim(lmax,2)
printf,1, 'infile = '+ mapname
printf,1, 'outfile = ' + outname
  
if keyword_set(polarisation) then $
   printf,1, 'polarisation = true' $
else printf,1, 'polarisation = false'
if not keyword_set(iter) then iter=0
printf,1, 'iter_order = '+strtrim(iter,2)
if keyword_set(double) then $
   printf,1, 'double_precision = true'
close,1
  
;spawn, 'anafast_cxx '+conf
spawn, 'anafast '+conf
  
read_fits_map, outname, result

cl = result[1:*]
l = lindgen(n_elements(cl))+1
;l = reform(result(1:*,0))
;cl = reform(result(1:*,1))

;spawn, 'rm -f '+conf
;spawn, 'rm -f '+outname
;spawn, 'rm -f '+mapname

end
