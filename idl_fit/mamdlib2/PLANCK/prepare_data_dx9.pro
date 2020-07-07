pro prepare_data_dx9, nside, fwhm, version, allmaps, allnoise, betamap

  allfreq = [3000, 857, 545, 353] ; 3000 is IRIS, 3001 is DIRBE, 3002 is SFD 100 micron
  allfreq_noise=allfreq
  case version of
     'v1': begin
        rmco=1
        rmzody=1
        rmsources=0
     end
     'v2': begin
        rmco=1
        rmzody=1
        rmsources=0
     end
     'v3': begin
        rmco=1
        rmzody=0
        rmsources=0
     end
     'v4': begin
        rmzody=0
        rmco=0
        rmsources=0
        read_fits_map, !DATA+'/Planck/DX9/RESULTS/beta_ns2048_betafloat_fwhm35.0_v6.fits', betamap
        smt = sqrt(fwhm^2 - 35.^2)
        if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
        ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
     end
     'v5': begin                ; Planck rmzody + SFD1998
        rmco=0 
        rmzody=1
        rmsources=0
        allfreq = [3002, 857, 545, 353]
        allfreq_noise[0] = 3000
     end
     'v6': begin
        rmco=0 
        rmzody=0
        rmsources=0
     end
     'v7': begin
        rmzody=0
        rmco=0
        rmsources=0
        read_fits_map, !DATA+'/Planck/DX9/RESULTS/beta_ns2048_betafloat_fwhm35.0_v3.fits', betamap
        betamap = betamap*0.6+0.565
        smt = sqrt(fwhm^2 - 35.^2)
        if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
        ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
     end
     'v8': begin
        rmzody=0
        rmco=0
        rmsources=1
        read_fits_map, !DATA+'/Planck/DX9/RESULTS/beta_ns2048_betafloat_fwhm35.0_v9.fits', betamap
        smt = sqrt(fwhm^2 - 35.^2)
        if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
        ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
     end
     'v9': begin
        rmco=0
        rmzody=0
        rmsources=1
     end
     'v10': begin
        rmco=0
        rmzody=1
        rmsources=0
     end
     'v11': begin
        rmco=0
        rmzody=1
        rmsources=0
        hi_threshold=1.4
        fileoffset=!DATA+'/Planck/DX9/results_dipole_offset_1.4.txt'
     end
     'v12': begin
        rmco=0
        rmzody=0
        rmsources=0
        hi_threshold=1.4
        fileoffset=!DATA+'/Planck/DX9/results_dipole_offset_1.4.txt'
     end
     'v13': begin               ; Planck rmsource + SFD1998
        rmco=0 
        rmzody=0
        rmsources=1
        allfreq = [3002, 857, 545, 353]
        allfreq_noise[0] = 3000
     end
     'v14': begin               ; Planck rmzody rmsource + SFD1998
        rmco=0 
        rmzody=1
        rmsources=1
        allfreq = [3002, 857, 545, 353]
        allfreq_noise[0] = 3000
     end
     'v15': begin
        rmzody=0
        rmco=0
        rmsources=0
        read_fits_map, !DATA+'/Planck/DX9/RESULTS/beta_ns2048_betafloat_fwhm30.0_v6.fits', betamap
        smt = sqrt(fwhm^2 - 30.^2)
        if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
        ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
     end
     'v16': begin
        rmzody=0
        rmco=0
        rmsources=1
        read_fits_map, !DATA+'/Planck/DX9/RESULTS/beta_ns2048_betafloat_fwhm30.0_v9.fits', betamap
        smt = sqrt(fwhm^2 - 30.^2)
        if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
        ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
     end
     'v17': begin               ; Planck + SFD1998
        rmco=0 
        rmzody=0
        rmsources=0
        allfreq = [3002, 857, 545, 353]
        allfreq_noise[0] = 3000
     end
     'v18': begin
        rmco=0
        rmzody=1
        rmsources=0
        read_fits_map, !DATA+'/Planck/DX9/RESULTS/beta_ns2048_betafloat_fwhm30.0_v10.fits', betamap
        smt = sqrt(fwhm^2 - 30.^2)
        if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
        ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
     end
     'v19': begin               ; Planck rmzody + IRIS_combined_SFD
        rmco=0 
        rmzody=1
        rmsources=0
        allfreq = [3003, 857, 545, 353]
        allfreq_noise[0] = 3000
     end
     'v20': begin               ; Planck rmzody + IRIS-Zody
        rmco=0 
        rmzody=1
        rmsources=0
        allfreq = [3004, 857, 545, 353]
        allfreq_noise[0] = 3000
     end
     'v21': begin
        rmco=0
        rmzody=1
        rmsources=0
        allfreq = [3003, 857, 545, 353]
        allfreq_noise[0] = 3000
        read_fits_map, !DATA+'/Planck/DX9/RESULTS/beta_ns2048_betafloat_fwhm30.0_v19.fits', betamap
        smt = sqrt(fwhm^2 - 30.^2)
        if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
        ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
     end
     'v22': begin
        rmco=0
        rmzody=1
        rmsources=0
        allfreq = [3004, 857, 545, 353]
        allfreq_noise[0] = 3000
        read_fits_map, !DATA+'/Planck/DX9/RESULTS/beta_ns2048_betafloat_fwhm30.0_v20.fits', betamap
        smt = sqrt(fwhm^2 - 30.^2)
        if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
        ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
     end
     'v23': begin               ; Planck rmzody + IRIS_combined_SFD, RMSOURCES=1
        rmco=0 
        rmzody=1
        rmsources=1
        allfreq = [3003, 857, 545, 353]
        allfreq_noise[0] = 3000
     end
     'v24': begin
        rmco=0
        rmzody=1
        rmsources=1
        allfreq = [3003, 857, 545, 353]
        allfreq_noise[0] = 3000
        read_fits_map, !DATA+'/Planck/DX9/RESULTS/beta_ns2048_betafloat_fwhm30.0_v23.fits', betamap
        smt = sqrt(fwhm^2 - 30.^2)
        if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
        ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
     end
     'v25': begin               ; Planck + IRIS_combined_SFD
        rmco=0 
        rmzody=0
        rmsources=0
        allfreq = [3003, 857, 545, 353]
        allfreq_noise[0] = 3000
     end
  endcase

  if not keyword_set(version) then version='v0'
  if not keyword_set(fileoffset) then fileoffset=!DATA+'/Planck/DX9/results_dipole_offset.txt'
;  if not keyword_set(hi_threshold) then hi_threshold=2.

;------ read maps --------
  allmaps = read_planck_iras(allfreq, nside=nside, fwhm=fwhm, /ring, rmzody=rmzody, $
                             rmoffset=1, rmco=rmco, $
                             nominal=1, rmdipole=1, cmb='SMICA', rmsources=rmsources, $
                             fileoffset=fileoffset, $
                             offset_uncertainty=offset_uncertainty)
;if (nside eq 2048) then begin
  if (fwhm le 10.) then begin
     norescale = 1 
     fwhm_noise = 1.
  endif else begin
     norescale = 0
     fwhm_noise = fwhm
  endelse
  allnoise = noise_planck_iras(allfreq_noise, nside=nside, fwhm=fwhm_noise, /ring, nominal=1, $
                               rmzody=rmzody, norescale=norescale)

  cmb = read_cmb_map('SMICA', fwhm=fwhm, nside=nside, order='RING')

  nbfreq = n_elements(allfreq)
  gain_uncertainty = fltarr(nbfreq)
  conversion = fltarr(nbfreq)
  for i=0, nbfreq-1 do begin
     tt = map_properties(allfreq[i])
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



end
