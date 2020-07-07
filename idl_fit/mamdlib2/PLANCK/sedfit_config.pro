function sedfit_config, version, nside, fwhm, type, dataversion=dataversion

  if not keyword_set(dataversion) then dataversion = 'DX9'

;======  default values ======
  allfreq = [3000, 857, 545, 353] ; 3000 is IRIS, 3001 is DIRBE, 3002 is SFD 100 micron, 3003 is SFD+IRIS
  allfreq_noise = allfreq
  fileoffset = !DATA+'/Planck/DX11c/results_dipole_offset.txt'
  betamap=''
;  hi_threshold = 2.

;============ DX11 ===============
  if (dataversion eq 'DX11' or dataversion eq 'DX11c') then begin
     nominal = 0
     case version of
        'v1': begin
           rmco=1
           rmzody=1
           rmsources=0
        end
        'v2': begin
           rmco=0
           rmzody=1
           rmsources=0
           allfreq = [3003, 857, 545, 353]
        end
        'v3': begin
           rmco=0
           rmzody=1
           rmsources=0
           allfreq = [3003, 857, 545, 353, 217, 143]
           allfreq_noise = [3000, 857, 545, 353, 217, 143]
        end
     endcase
  endif

;============ DX9 ===============
  if (dataversion eq 'DX9') then begin
     nominal = 1
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
           read_fits_map, !DATA+'/Planck/DX11c/RESULTS/beta_ns2048_betafloat_fwhm35.0_v6.fits', betamap
           smt = sqrt(fwhm^2 - 35.^2)
           if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
           ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
        end
        'v5': begin             ; Planck rmzody + SFD1998
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
           read_fits_map, !DATA+'/Planck/DX11c/RESULTS/beta_ns2048_betafloat_fwhm35.0_v3.fits', betamap
           betamap = betamap*0.6+0.565
           smt = sqrt(fwhm^2 - 35.^2)
           if (smt gt 0.) then ismoothing, betamap, betamap, fwhm=smt, /ring
           ud_grade, betamap, betamap, nside=nside, order_in='RING', order_out='RING'
        end
        'v8': begin
           rmzody=0
           rmco=0
           rmsources=1
           read_fits_map, !DATA+'/Planck/DX11c/RESULTS/beta_ns2048_betafloat_fwhm35.0_v9.fits', betamap
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
        'v13': begin            ; Planck rmsource + SFD1998
           rmco=0 
           rmzody=0
           rmsources=1
           allfreq = [3002, 857, 545, 353]
           allfreq_noise[0] = 3000
        end
        'v14': begin            ; Planck rmzody rmsource + SFD1998
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
        'v17': begin            ; Planck + SFD1998
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
        'v19': begin            ; Planck rmzody + IRIS_combined_SFD
           rmco=0 
           rmzody=1
           rmsources=0
           allfreq = [3003, 857, 545, 353]
           allfreq_noise[0] = 3000
        end
        'v20': begin            ; Planck rmzody + IRIS-Zody
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
        'v23': begin            ; Planck rmzody + IRIS_combined_SFD, RMSOURCES=1
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
        'v25': begin            ; Planck + IRIS_combined_SFD
           rmco=0 
           rmzody=0
           rmsources=0
           allfreq = [3003, 857, 545, 353]
           allfreq_noise[0] = 3000
        end
     endcase
  endif

; put information in structure
  sedfit_param = {rmco:rmco, $
                  rmzody:rmzody, $
                  rmsources:rmsources, $
                  nside:nside, $
                  fwhm:fwhm, $
                  freq:allfreq, $
                  freq_noise:allfreq_noise, $
                  betamap:betamap, $
                  fileoffset:fileoffset, $
                  nominal:nominal, $
;                  hi_threshold:hi_threshold, $
                  version:version, $
                  type:type, $
                  dataversion:dataversion}

  return, sedfit_param

end
