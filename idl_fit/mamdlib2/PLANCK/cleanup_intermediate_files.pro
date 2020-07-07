pro cleanup_intermediate_files, fitconfig ;nside, fwhm, type, version, dataversion=dataversion

;if not keyword_set(dataversion) then dataversion='DX9'

  nside = fitconfig.nside
  fwhm = fitconfig.fwhm
  type = fitconfig.type
  version = fitconfig.version
  dataversion = fitconfig.dataversion

if keyword_set(fwhm) and keyword_set(nside) and keyword_set(type) and keyword_set(version) then begin
   file = !DATA+'/Planck/'+dataversion+'/TMPDATA/data_ns'+strc(nside)+'_'+type+$
                   '_noeud_*_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.idl'
   f = file_search(file, count=count)
   for i=0, count-1 do begin
      print, 'rm '+f[i]
      spawn, 'rm '+f[i]
   endfor

   file = !DATA+'/Planck/'+dataversion+'/RESULTS/sedfit_ns'+strc(nside)+'_'+type+$
                   '_noeud_*_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.idl'
   f = file_search(file, count=count)
   for i=0, count-1 do begin
      print, 'rm '+f[i]
      spawn, 'rm '+f[i]
   endfor
endif else begin
   print, 'parameters not all set....nothing was done'
endelse

end
