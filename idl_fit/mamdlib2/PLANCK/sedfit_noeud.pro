pro sedfit_noeud, noeud, fitconfig, beta=beta, ciba=ciba

  nside = fitconfig.nside
  fwhm = fitconfig.fwhm
  type = fitconfig.type
  version = fitconfig.version
  dataversion = fitconfig.dataversion

if not keyword_set(beta) then beta=1.65
if not keyword_set(version) then version='v0'
if (type eq 'betafloat') then fixed=[0,0,0] else fixed=[0,0,1]
if not keyword_set(dataversion) then dataversion='DX9'

;------ read maps --------
filename = !DATA+'/Planck/'+dataversion+'/TMPDATA/data_ns'+strc(nside)+'_'+type+'_noeud_'+strc(noeud)+$
           '_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.idl'
restore, filename

;-------- Fit SEDs -------
sedfit_planck_iras, maps_noeud, noise_noeud, allfreq, param, err_param, chi2, $
                    fixed=fixed, beta=beta, ciba=ciba

;------- save results ------
file=!DATA+'/Planck/'+dataversion+'/RESULTS/sedfit_ns'+strc(nside)+'_'+type+'_noeud_'+$
      strc(noeud)+'_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version
if keyword_set(CIBA) then file=file+'_CIBA.idl' else file = file+'.idl' 

save, allfreq, list, param, err_param, chi2, file=file
      
end
