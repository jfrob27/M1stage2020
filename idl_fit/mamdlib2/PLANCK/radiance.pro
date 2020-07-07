pro radiance, fitconfig 

  nside = fitconfig.nside
  fwhm = fitconfig.fwhm
  type = fitconfig.type
  version = fitconfig.version
  dataversion = fitconfig.dataversion

  suffix = '_ns'+strc(nside)+'_'+type+'_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.fits'
;read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/amp'+suffix, amp
  read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/tau353GHz'+suffix, tau353
  read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/t'+suffix, t
  read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/beta'+suffix, beta
;l = luminosity(amp, t, beta)

  R = radiance_analytical(tau353, t, beta, nu0=353.)
  R = float(R)
  write_fits_map,  !DATA+'/Planck/'+dataversion+'/RESULTS/radiance'+suffix, R, /RING

end

