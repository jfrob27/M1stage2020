pro prepare_data, str, allmaps, allnoise, onlyinstnoise=onlyinstnoise ;, betamap

;betamap = str.betamap

;------ read data --------
  allmaps = read_planck_iras(str.freq, $
                             nside=str.nside, $
                             fwhm=str.fwhm, $
                             rmzody=str.rmzody, $
                             rmco=str.rmco, $
                             rmsources=str.rmsources, $
                             nominal=str.nominal, $
                             ring=1, $
                             rmoffset=1, $
                             rmdipole=1, $
                             cmb='SMICA', $
                             fileoffset=str.fileoffset, $
                             offset_uncertainty=offset_uncertainty, $
                             dataversion=str.dataversion)

;------ read noise -----
  if (str.fwhm le 10.) then begin
     norescale = 1 
     fwhm_noise = 1.
  endif else begin
     norescale = 0
     fwhm_noise = str.fwhm
  endelse
  allnoise = noise_planck_iras(str.freq_noise, $
                               nside=str.nside, $
                               nominal=str.nominal, $
                               rmzody=str.rmzody, $
                               ring=1, $
                               fwhm=fwhm_noise, $
                               norescale=norescale, $
                               dataversion=str.dataversion)

  if not keyword_set(onlyinstnoise) then begin
;----- read CMB ------
     cmb = read_cmb_map('SMICA', fwhm=str.fwhm, nside=str.nside, order='RING') ; K_CMB

;----- compute uncertainty maps -----
     allfreq = str.freq
     nbfreq = n_elements(allfreq)
     gain_uncertainty = fltarr(nbfreq)
     conversion = fltarr(nbfreq)
     for i=0, nbfreq-1 do begin
        tt = map_properties(allfreq[i], dataversion=str.dataversion)
        gain_uncertainty[i] = tt.gain_uncertainty
        conversion[i] = tt.conversion
     endfor

     for j=0, nbfreq-1 do begin
        tmpmaps = allmaps[*,j]
        tmpnoise = allnoise[*,j]
        if (allfreq[j] le 857) then cmb_nu = cmb*conversion[j] else cmb_nu=0.
        allnoise[*,j] = sqrt( (gain_uncertainty[j]*tmpmaps)^2 + $
                              (gain_uncertainty[j]*cmb_nu)^2 + $
                              (tmpnoise)^2 + $
                              (offset_uncertainty[j])^2 )
     endfor

  endif

end
