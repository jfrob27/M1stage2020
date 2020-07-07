pro sedfit_combine, fitconfig, CIBA=CIBA

  nside = fitconfig.nside
  fwhm = fitconfig.fwhm
  type = fitconfig.type
  version = fitconfig.version
  dataversion = fitconfig.dataversion

  nbnoeud = 1
  file = !DATA+'/Planck/'+dataversion+'/RESULTS/sedfit_ns'+strc(nside)+'_'+type+'_noeud_*'+$
         '_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version
  if keyword_set(CIBA) then file=file+'_CIBA.idl' else file = file+'.idl' 

  res = file_search(file, count=nbnoeud)

  nbpix = nside2npix(nside)
  nbeach = ceil(1.*nbpix/nbnoeud)

  for noeud=0, nbnoeud-1 do begin
     file = !DATA+'/Planck/'+dataversion+'/RESULTS/sedfit_ns'+strc(nside)+'_'+type+'_noeud_'+strc(noeud)+$
            '_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version
     if keyword_set(CIBA) then file=file+'_CIBA.idl' else file = file+'.idl' 
     restore, file, /ver
     if keyword_set(param) then nbparam=(size(param))[2] else nbparam=3 
     if (noeud eq 0) then begin
        param_all = fltarr(nbpix, nbparam)
        err_param_all = fltarr(nbpix, nbparam)
        chi2_all = fltarr(nbpix)
     endif
     if keyword_set(param) then begin
        param_all[list,*] = param
        err_param_all[list,*] = err_param
     endif else begin
        list = lindgen(nbeach)+noeud*nbeach
        ind = where(list lt nbpix, nbind)
        list = list[ind]
        param_all[list,0] = amp
        param_all[list,1] = t
        param_all[list,2] = beta
        err_param_all[list,0] = err_amp
        err_param_all[list,1] = err_t
        err_param_all[list,2] = err_beta
     endelse
     chi2_all[list] = chi2
  endfor

  suffix = '_ns'+strc(nside)+'_'+type+'_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.fits'
  write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/chi2'+suffix, chi2_all, /Ring
  write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/amp'+suffix, reform(param_all[*,0]), /Ring
  write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/t'+suffix, reform(param_all[*,1]), /Ring
  write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/beta'+suffix, reform(param_all[*,2]), /Ring
  write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/err_amp'+suffix, reform(err_param_all[*,0]), /Ring
  write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/err_t'+suffix, reform(err_param_all[*,1]), /Ring
  write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/err_beta'+suffix, reform(err_param_all[*,2]), /Ring
  if (nbparam eq 5) then begin
     write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/beta_mm'+suffix, reform(param_all[*,4]), /Ring
     write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/err_beta_mm'+suffix, reform(err_param_all[*,4]), /Ring
  endif
  if (nbparam eq 6) then begin
     write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/ciba'+suffix, reform(param_all[*,3]), /Ring
     write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/err_ciba'+suffix, reform(err_param_all[*,3]), /Ring
  endif


;suffix = '_ns'+strc(nside)+'_'+type+'_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.idl'
;save, param_all, file=!DATA+'/Planck/'+dataversion+'/RESULTS/param'+suffix
;save, err_param_all, file=!DATA+'/Planck/'+dataversion+'/RESULTS/err_param'+suffix


end
