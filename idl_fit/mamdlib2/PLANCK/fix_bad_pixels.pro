pro fix_bad_pixels, fitconfig, chi2max=chi2max


  if not keyword_set(chi2max) then chi2max=32768
  nside = fitconfig.nside
  fwhm = fitconfig.fwhm
  type = fitconfig.type
  version = fitconfig.version
  dataversion = fitconfig.dataversion

suffix = '_ns'+strc(nside)+'_'+type+'_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.fits'
read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/amp'+suffix, amp
read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/t'+suffix, t
read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/beta'+suffix, beta
read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/chi2'+suffix, chi2
;bad = where(finite(amp) eq 0 or t lt 0 or amp lt 0, nbad)
bad = where(finite(amp) eq 0 or t le 8.12 or amp lt 0 or t gt 60. or chi2 gt chi2max, nbad)
if (nbad gt 0) then begin & $
   amp[bad] = !healpix.bad_value & $
   t[bad] = !healpix.bad_value & $
   beta[bad] = !healpix.bad_value  & $
   hpx_fill_bad_pixels, amp, order='RING' & $
   hpx_fill_bad_pixels, t, order='RING' & $
   hpx_fill_bad_pixels, beta, order='RING' & $
   hpx_fill_bad_pixels, chi2, order='RING' & $
   write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/amp'+suffix, amp, /ring & $
   write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/t'+suffix, t, /ring & $
   write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/beta'+suffix, beta, /ring & $
   write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/chi2'+suffix, chi2, /ring & $
   endif

;other_files = ['chi2', 'err_amp', 'err_t', 'err_beta']
other_files = ['err_amp', 'err_t', 'err_beta']
for i=0, N_ELEMENTS(other_files)-1 do begin
   read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/'+other_files[i]+suffix, map
   map[bad] = !healpix.bad_value 
   hpx_fill_bad_pixels, map, order='RING'
   write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/'+other_files[i]+suffix, map, /ring
endfor
   
end

