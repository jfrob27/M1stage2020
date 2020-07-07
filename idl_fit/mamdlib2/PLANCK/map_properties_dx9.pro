function map_properties_DX9, freq, $
                             rmsources=rmsources, $
                             nominal=nominal, $
                             rmzody=rmzody, $
                             fileoffset=fileoffset, $
                             cmbmap=cmbmap

  if not keyword_set(fileoffset) then fileoffset = !DATA+'/Planck/DX9/results_dipole_offset.txt'
  if keyword_set(nominal) then nominal=1 else nominal=0
  if keyword_set(rmzody) then rmzody=1 else rmzody=0
  if not keyword_set(cmbmap) then cmbmap='NONE'

  str = {gain_uncertainty:-32768., $
         conversion:-32768., $
         resolution:-32768., $
         filename:'', $
         noisemap:'', $
         offset:0., $
         error_offset:0., $
         dipole:0., $
         error_dipole:0.}

  if keyword_set(nominal) then nom = '_NOMINAL' else nom = ''
  case freq of
     857: begin
        str.gain_uncertainty = 0.10
        str.conversion = 2.26907
        str.resolution = 4.63
                                ;data
        if keyword_set(rmsources) then begin
           if keyword_set(rmzody) then begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/857GHz_diffusemap_ZErm.fits'
              endif else begin
                 str.filename = ''
              endelse
           endif else begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/857GHz_diffusemap.fits'
              endif else begin
                 str.filename = ''
              endelse
           endelse
        endif else begin
           if keyword_set(rmzody) then begin
              str.filename = !DATA+'/Planck/DX9/MAP_857GHz_v53_MJyResca_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
           endif else begin
              str.filename = !DATA+'/Planck/DX9/MAP_857GHz_v53_MJyResca'+nom+'_2048_GALACTIC_0240_27008.fits'
           endelse
        endelse
                                ; noise
        if keyword_set(rmzody) then $
           str.noisemap = !DATA+'/Planck/DX9/COVAR_857GHz_v53_MJyResca_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits' $
        else str.noisemap = !DATA+'/Planck/DX9/COVAR_857GHz_v53_MJyResca'+nom+'_2048_GALACTIC_0240_27008.fits'
     end
     545: begin
        str.gain_uncertainty = 0.10
        str.conversion = 57.9766
        str.resolution = 4.84
                                ; data
        if keyword_set(rmsources) then begin
           if keyword_set(rmzody) then begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/545GHz_diffusemap_ZErm.fits'
              endif else begin
                 str.filename = ''
              endelse
           endif else begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/545GHz_diffusemap.fits'
              endif else begin
                 str.filename = ''
              endelse
           endelse
        endif else begin
           if keyword_set(rmzody) then begin
              str.filename = !DATA+'/Planck/DX9/MAP_545GHz_v53_MJyResca_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
           endif else begin
              str.filename = !DATA+'/Planck/DX9/MAP_545GHz_v53_MJyResca'+nom+'_2048_GALACTIC_0240_27008.fits'
           endelse
        endelse
                                ; noise
        if keyword_set(rmzody) then $
           str.noisemap = !DATA+'/Planck/DX9/COVAR_545GHz_v53_MJyResca_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits' $
        else str.noisemap = !DATA+'/Planck/DX9/COVAR_545GHz_v53_MJyResca'+nom+'_2048_GALACTIC_0240_27008.fits'
     end
     353: begin
        str.gain_uncertainty = 0.012
        str.conversion = 287.2262
        str.resolution = 4.86
                                ;data
        if keyword_set(rmsources) then begin
           if keyword_set(rmzody) then begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/353GHz_diffusemap_ZErm_KCMB.fits'
              endif else begin
                 str.filename = ''
              endelse
           endif else begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/353GHz_diffusemap_KCMB.fits'
              endif else begin
                 str.filename = ''
              endelse
           endelse
        endif else begin
           if keyword_set(rmzody) then begin
              str.filename = !DATA+'/Planck/DX9/MAP_353GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
           endif else begin
              str.filename = !DATA+'/Planck/DX9/MAP_353GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits'
           endelse
        endelse
                                ; noise
        if keyword_set(rmzody) then $
           str.noisemap = !DATA+'/Planck/DX9/COVAR_353GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits' $
        else str.noisemap = !DATA+'/Planck/DX9/COVAR_353GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits'
     end
     217: begin
        str.gain_uncertainty = 0.005
        str.conversion = 483.4835
        str.resolution = 5.01
                                ;data
        if keyword_set(rmsources) then begin
           if keyword_set(rmzody) then begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/217GHz_diffusemap_ZErm_KCMB.fits'
              endif else begin
                 str.filename = ''
              endelse
           endif else begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/217GHz_diffusemap_KCMB.fits'
              endif else begin
                 str.filename = ''
              endelse
           endelse
        endif else begin
           if keyword_set(rmzody) then begin
              str.filename = !DATA+'/Planck/DX9/MAP_217GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
           endif else begin
              str.filename = !DATA+'/Planck/DX9/MAP_217GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits'
           endelse
        endelse
                                ; noise
        if keyword_set(rmzody) then $
           str.noisemap = !DATA+'/Planck/DX9/COVAR_217GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits' $
        else str.noisemap = !DATA+'/Planck/DX9/COVAR_217GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits'
     end
     143: begin
        str.gain_uncertainty = 0.005
        str.conversion = 371.666
        str.resolution = 7.27
                                ;data
        if keyword_set(rmsources) then begin
           if keyword_set(rmzody) then begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/143GHz_diffusemap_ZErm_KCMB.fits'
              endif else begin
                 str.filename = ''
              endelse
           endif else begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/143GHz_diffusemap_KCMB.fits'
              endif else begin
                 str.filename = ''
              endelse
           endelse
        endif else begin
           if keyword_set(rmzody) then begin
              str.filename = !DATA+'/Planck/DX9/MAP_143GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
           endif else begin
              str.filename = !DATA+'/Planck/DX9/MAP_143GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits'
           endelse
        endelse
                                ; noise
        if keyword_set(rmzody) then $
           str.noisemap = !DATA+'/Planck/DX9/COVAR_143GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits' $
        else str.noisemap = !DATA+'/Planck/DX9/COVAR_143GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits'
     end
     100: begin
        str.gain_uncertainty = 0.005
        str.conversion = 244.07
        str.resolution = 9.66
                                ; data
        if keyword_set(rmsources) then begin
           if keyword_set(rmzody) then begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/100GHz_diffusemap_ZErm_KCMB.fits'
              endif else begin
                 str.filename = ''
              endelse
           endif else begin
              if keyword_set(nominal) then begin
                 str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/100GHz_diffusemap_KCMB.fits'
              endif else begin
                 str.filename = ''
              endelse
           endelse
        endif else begin
           if keyword_set(rmzody) then begin
              str.filename = !DATA+'/Planck/DX9/MAP_100GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
           endif else begin
              str.filename = !DATA+'/Planck/DX9/MAP_100GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits'
           endelse
        endelse
                                ; noise
        if keyword_set(rmzody) then $
           str.noisemap = !DATA+'/Planck/DX9/COVAR_100GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits' $
        else str.noisemap = !DATA+'/Planck/DX9/COVAR_100GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits'
     end
     else: print, 'ERROR : FREQUENCY NOT RECOGNIZED IN MAP_PROPERTIES'
  endcase

  read_planck_monopole_dipole, monodipo, file=fileoffset
  nominal_monodipo = monodipo.nominal
  freq_planck = monodipo.freq
  rmzody_monodipo = monodipo.rmzody
  cmbname = monodipo.cmbname
  offset_nodipolerm = monodipo.offset_nodipolerm
  err_offset_nodipolerm = monodipo.err_offset_nodipolerm
  offset857_dipolerm = monodipo.offset857_dipolerm
  err_offset857_dipolerm = monodipo.err_offset857_dipolerm
  coeff857_dipolerm = monodipo.coeff857_dipolerm
  dipole_coeff = monodipo.dipole_coeff
  err_dipole_coeff = monodipo.err_dipole_coeff

  ind = where(cmbname eq strc(strupcase(cmbmap)) and $
              rmzody_monodipo eq rmzody and $
              nominal_monodipo eq nominal and $
              freq_planck eq 857)
  offset_857 = float(offset_nodipolerm[ind[0]])  
  err_offset_857 = float(err_offset_nodipolerm[ind[0]])
  ind = where(cmbname eq strc(strupcase(cmbmap)) and $
              rmzody_monodipo eq rmzody and $
              nominal_monodipo eq nominal)  
  offset_planck = offset857_dipolerm[ind] + coeff857_dipolerm[ind]*offset_857                              ; MJy/sr
  err_offset_planck = sqrt( err_offset857_dipolerm[ind]^2 + (coeff857_dipolerm[ind]*err_offset_857)^2 )    ; MJy/sr
  dipole_planck = dipole_coeff[ind]                                                                        ; MJy/sr
  err_dipole_planck = err_dipole_coeff[ind]                                                                ; MJy/sr
  freq_planck = freq_planck[ind]
  ind = where(freq_planck eq 857)
  offset_planck[ind] = offset_857
  err_offset_planck[ind] = err_offset_857
  
  ind_planck_freq = where(freq_planck eq freq)
  str.dipole = dipole_planck[ind_planck_freq[0]]
  str.error_dipole = err_dipole_planck[ind_planck_freq[0]]
  str.offset = offset_planck[ind_planck_freq[0]] ; MJy/sr
  str.error_offset = err_offset_planck[ind_planck_freq[0]]

  return, str

end

