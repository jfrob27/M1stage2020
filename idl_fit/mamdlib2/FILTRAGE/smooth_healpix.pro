;+
;Provides a wrapper to the healpix c++ facility smoothing_cxx
;
; @author M-A Miville-Deschenes, 
; @history july 2007 : first version
; @history march 2011 : import the code from an intermediate PSM
;function it was previously calling. Add polarisation
;-
function smooth_healpix, input, fwhm_arcmin, nested=nested, ring=ring, ordering=order, lmax=lmax

si = size(input)
npix = si[1]
if (si[0] eq 2 and si[2] eq 3) then polarisation=1
nside = npix2nside( npix )

if not keyword_set(lmax) then lmax=3*nside-1
if keyword_set(nested) then order='nested'
if keyword_set(ring) then order='ring'
if not keyword_set(order) then order='ring'

; Check if size kernel is larger than pixel size
sphere = 4*!pi*3.2828e3*3600.  ; arcmin^2
sizekernel = sqrt( sphere / npix ) ; arcmin
if (fwhm_arcmin le sizekernel) then begin
   print, 'Convolution kernel smaller than pixel size'
   print, 'No smoothing done'
   return, input
endif 

tempo = reorder(input, in=order, out='RING')
file = 'tempo_smoothing_healpix.fits'
if keyword_set(polarisation) then begin
   write_tqu, file, tempo, ordering='RING'
endif else begin
   write_fits_map, file, tempo, ordering='RING'
endelse
;smoothing_cxx, file, fwhm_arcmin, lmax, /over, /double

;--- begin import
mapname = file
outname = '!'+strtrim(mapname,1)
  
  conf = gettmpfilename('tmp-psm_smoothing',suffix='.conf')
  openw, 1, conf
  if not keyword_set(weighted) then begin
      printf,1,'weighted = false'       
  endif else begin
      healpix_data=!HEALPIX_DIR+'/data/'
      print,healpix_data
      printf,1,'weighted = true'
      printf,1,'healpix_data = '+ healpix_data
  endelse
  printf,1, 'fwhm_arcmin = '+ strtrim(fwhm_arcmin, 2)  
  printf,1, 'nlmax = '+strtrim(lmax,2)
  printf,1, 'infile = '+ mapname
  printf,1, 'outfile = ' + outname
  if keyword_set(iter) then $
    printf,1, 'iter_order = '+strtrim(iter,2)
  if keyword_set(double) then $
    printf,1, 'double_precision = true'
  if keyword_set(polarisation) then $
     printf,1, 'polarisation = true' else $
     printf,1, 'polarisation = false'
  close,1
  
  spawn, 'smoothing_cxx '+ conf
  
  spawn, 'rm -f '+ conf
;--- end import

read_fits_map, file, tempo

; result of smoothing_cxx is in order=ring. Reorder to the ordering of
; the input map
result = reorder(tempo, in='RING', out=order)

spawn, 'rm -f ' + file

return, result

end

