function map_properties_dx11, freq, $
                              rmsources=rmsources, $
                              rmzody=rmzody, $
                              fileoffset=fileoffset, $
                              cmbmap=cmbmap

  if not keyword_set(fileoffset) then fileoffset = !DATA+'/Planck/DX11c/results_dipole_offset.txt'
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

  nominal = 0

  if keyword_set(rmzody) then zody='_noZodi' else zody=''
  case freq of
     857: begin
        str.gain_uncertainty = 0.0108+0.05  ; 0.08
        str.conversion = 2.26907
        str.resolution = 4.63
        str.offset = 0.64 ; MJy/sr
        ;data
        if keyword_set(rmsources) then begin
           str.filename = ''
        endif else begin
           str.filename = !DATA+'/Planck/DX11c/HFI_SkyMap_857_2048_DX11c'+zody+'_full_I.fits'
        endelse
        ; noise
        str.noisemap = !DATA+'/Planck/DX11c/HFI_SkyMap_857_2048_DX11c'+zody+'_full_II.fits'
     end
     545: begin
        str.gain_uncertainty = 0.0133+0.05 ; 0.08
        str.conversion = 57.9766
        str.resolution = 4.84
        str.offset = 0.35 ; MJy/sr
        ; data
        if keyword_set(rmsources) then begin
           str.filename = ''
        endif else begin
           str.filename = !DATA+'/Planck/DX11c/HFI_SkyMap_545_2048_DX11c'+zody+'_full_I.fits'
        endelse
        ; noise
        str.noisemap = !DATA+'/Planck/DX11c/HFI_SkyMap_545_2048_DX11c'+zody+'_full_II.fits'
     end
     353: begin
        str.gain_uncertainty = 0.012
        str.conversion = 287.2262
        str.resolution = 4.86
        str.offset = 0.13 ; MJy/sr
        ;data
        if keyword_set(rmsources) then begin
           str.filename = ''
        endif else begin
           str.filename = !DATA+'/Planck/DX11c/HFI_SkyMap_353_2048_DX11c'+zody+'_full_I.fits'
        endelse
        ; noise
        str.noisemap = !DATA+'/Planck/DX11c/HFI_SkyMap_353_2048_DX11c'+zody+'_full_II.fits'
     end
     217: begin
        str.gain_uncertainty = 0.005
        str.conversion = 483.4835
        str.resolution = 5.01
        str.offset = 0.033 ; MJy/sr
        ;data
        if keyword_set(rmsources) then begin
           str.filename = ''
        endif else begin
           str.filename = !DATA+'/Planck/DX11c/HFI_SkyMap_217_2048_DX11c'+zody+'_full_I.fits'
        endelse
        ; noise
        str.noisemap = !DATA+'/Planck/DX11c/HFI_SkyMap_217_2048_DX11c'+zody+'_full_II.fits'
     end
     143: begin
        str.gain_uncertainty = 0.005
        str.conversion = 371.666
        str.resolution = 7.27
        str.offset = 0.0079 ; MJy/sr
        ;data
        if keyword_set(rmsources) then begin
           str.filename = ''
        endif else begin
           str.filename = !DATA+'/Planck/DX11c/HFI_SkyMap_143_2048_DX11c'+zody+'_full_I.fits'
        endelse
        ; noise
        str.noisemap = !DATA+'/Planck/DX11c/HFI_SkyMap_143_2048_DX11c'+zody+'_full_II.fits'
     end
     100: begin
        str.gain_uncertainty = 0.005
        str.conversion = 244.07
        str.resolution = 9.66
        str.offset = 0.0030 ; MJy/sr
        ; data
        if keyword_set(rmsources) then begin
           str.filename = ''
        endif else begin
           str.filename = !DATA+'/Planck/DX11c/HFI_SkyMap_100_2048_DX11c'+zody+'_full_I.fits'
        endelse
        ; noise
        str.noisemap = !DATA+'/Planck/DX11c/HFI_SkyMap_100_2048_DX11c'+zody+'_full_II.fits'
     end
     else: print, 'ERROR : FREQUENCY NOT RECOGNIZED IN MAP_PROPERTIES'
  endcase
  
  rr = findfile(fileoffset)
  if (rr[0] ne '') then begin
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
     
     offset_planck = offset857_dipolerm[ind] + coeff857_dipolerm[ind]*offset_857                        ; MJy/sr
     err_offset_planck = sqrt( err_offset857_dipolerm[ind]^2 + (coeff857_dipolerm[ind]*err_offset_857)^2 ) ; MJy/sr
     
     dipole_planck = dipole_coeff[ind]      ; MJy/sr
     err_dipole_planck = err_dipole_coeff[ind] ; MJy/sr
     freq_planck = freq_planck[ind]
     ind = where(freq_planck eq 857)
     offset_planck[ind] = offset_857
     err_offset_planck[ind] = err_offset_857
     
     ind_planck_freq = where(freq_planck eq freq)
     str.dipole = dipole_planck[ind_planck_freq[0]]
     str.error_dipole = err_dipole_planck[ind_planck_freq[0]]
     str.offset = offset_planck[ind_planck_freq[0]] ; MJy/sr
; str.offset are CIB values (defined above for each frequency)
     str.error_offset = err_offset_planck[ind_planck_freq[0]]
  endif else begin
     print, 'WARNING. Offset-dipole file '+fileoffset+ ' does not exist'
  endelse

return, str

 end

