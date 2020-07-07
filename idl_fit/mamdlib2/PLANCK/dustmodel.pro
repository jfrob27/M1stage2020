pro dustmodel, fitconfig

  nside = fitconfig.nside
  fwhm = fitconfig.fwhm
  type = fitconfig.type
  version = fitconfig.version
  dataversion = fitconfig.dataversion
  allfreq = fitconfig.freq  
  ind = where(allfreq ge 3000 and allfreq le 3010, nbind)
  if (nbind gt 0) then allfreq[ind] = 3000

;if not keyword_set(allfreq) then allfreq = [353.,545.,857,3000]

suffix = '_ns'+strc(nside)+'_'+type+'_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.fits'
read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/amp'+suffix, amp
read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/t'+suffix, t
read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/beta'+suffix, beta
param = fltarr(nside2npix(nside), 3)
param[*,0] = amp
param[*,1] = t
param[*,2] = beta

allmodel = sedmodel_planck_iras(allfreq, param)
for i=0, n_elements(allfreq)-1 do begin
   map = allmodel[*,i]
   write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/model'+strc(fix(allfreq[i]))+'GHz'+suffix, map, /ring
endfor

end
