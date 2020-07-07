pro datamaps, fitconfig

  nside = fitconfig.nside
  fwhm = fitconfig.fwhm
  type = fitconfig.type
  version = fitconfig.version
  dataversion = fitconfig.dataversion
  allfreq = fitconfig.freq  
  ind = where(allfreq ge 3000 and allfreq le 3010, nbind)
  if (nbind gt 0) then allfreq[ind] = 3000

;if not keyword_set(allfreq) then allfreq = [353.,545.,857,3000]

  file = !DATA+'/Planck/'+dataversion+'/TMPDATA/data_ns'+strc(nside)+'_'+type+'_noeud_*'+$
         '_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.idl'
  res = file_search(file, count=nbnoeud)

  nbpix = nside2npix(nside)
  nbfreq = n_elements(allfreq)
  data = fltarr(nbpix, nbfreq)
  noise = fltarr(nbpix, nbfreq)
  for noeud=0, nbnoeud-1 do begin
     file = !DATA+'/Planck/'+dataversion+'/TMPDATA/data_ns'+strc(nside)+'_'+type+'_noeud_'+strc(noeud)+$
            '_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.idl'
     restore, file, /ver
     data[list,*] = maps_noeud
     noise[list,*] = noise_noeud
  endfor

  suffix = '_ns'+strc(nside)+'_'+type+'_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.fits'
  for i=0, nbfreq-1 do begin
     tmp = data[*,i]
     write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/data'+strc(allfreq[i])+'GHz'+suffix, tmp, /Ring
     tmp = noise[*,i]
     write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/noise'+strc(allfreq[i])+'GHz'+suffix, tmp, /Ring
  endfor

end
