pro tau353, fitconfig

  nside = fitconfig.nside
  fwhm = fitconfig.fwhm
  type = fitconfig.type
  version = fitconfig.version
  dataversion = fitconfig.dataversion

  suffix = '_ns'+strc(nside)+'_'+type+'_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.fits'
  read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/amp'+suffix, amp
  read_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/beta'+suffix, beta

  lambda = 3.e5/353.
  tau = amp*lambda^(-beta)
  write_fits_map, !DATA+'/Planck/'+dataversion+'/RESULTS/tau353GHz'+suffix, tau,/ring

end
