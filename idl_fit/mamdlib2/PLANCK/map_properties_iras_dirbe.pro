function map_properties_iras_dirbe, freq, rmsources=rmsources

  str = {gain_uncertainty:-32768., $
         conversion:-32768., $
         resolution:-32768., $
         filename:'', $
         noisemap:'', $
         offset:0., $
         error_offset:0., $
         dipole:0., $
         error_dipole:0.}

  case freq of
     5000: begin ; IRIS 60 micron
        str.gain_uncertainty = 0.104
        str.conversion = 1.
        str.resolution = 4.0
        str.offset = 0.410108
        str.error_offset = 0.00211438
        str.filename = !DATA+'/IRIS_Healpix/IRIS_really_nohole_3_2048.fits'
        if keyword_set(rmsources) then str.filename = !DATA+'IRIS_Healpix/IRIS_really_nohole_nosource_3_2048.fits'
     end
     5002: begin ; IRIS 60 micron
        str.gain_uncertainty = 0.104
        str.conversion = 1.
        str.resolution = 4.0
        str.offset = 0.344161
        str.error_offset = 0.00144133
        str.filename = !DATA+'/IRIS_Healpix/iris_60_nohole_nozody_2048.fits'
        if keyword_set(rmsources) then str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/5000GHz_diffusemap.fits'
     end
     5004: begin ; IRIS 60 micron, zody removed (using SFD100micron as reference)
        str.gain_uncertainty = 0.104
        str.conversion = 1.
        str.resolution = 4.0
        str.offset = 0.0  ; offset removed when map was created
        str.error_offset = 0.00161716
        str.filename = !DATA+'/IRIS_Healpix/IRIS_really_nohole_nozody_3_2048.fits'
        if keyword_set(rmsources) then $
           str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/5000GHz_diffusemap_nozody.fits'
     end
     3000: begin ; IRIS 100 micron
        str.gain_uncertainty = 0.135
        str.conversion = 1.
        str.resolution = 4.30
        str.offset = 0.538761
        str.error_offset = 0.00710680
        str.filename = !DATA+'/IRIS_Healpix/IRIS_really_nohole_4_2048.fits'
        if keyword_set(rmsources) then str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/3000GHz_diffusemap_repaired.fits'
        str.noisemap = !DATA+'/IRIS_Healpix/IRIS_cov0_4_cov_2048.fits'
     end
     3001: begin  ; DIRBE 100 micron
        str.gain_uncertainty = 0.135
        str.conversion = 1.
        str.resolution = 42.
        str.offset = 0.584093
        str.error_offset = 0.00499196
        str.filename = !DATA+'/DIRBE/DIRBE_ZSMA_8_100mic_256.fits'
        str.noisemap = !DATA+'/IRIS_Healpix/IRIS_cov0_4_cov_2048.fits'
     end
     3002: begin ; SFD 100 micron
        str.gain_uncertainty = 0.135
        str.conversion = 1.
        str.resolution = 6.0       
        str.offset = -0.185658
        str.error_offset = 0.00493626
        str.filename = !DATA+'/IRIS_Healpix/SFD_i100_healpix_2048_2.fits'
        str.noisemap = !DATA+'/IRIS_Healpix/IRIS_cov0_4_cov_2048.fits'
     end
     3003: begin ; IRIS and SFD Combined
        str.gain_uncertainty = 0.135
        str.conversion = 1.
        str.resolution = 4.30
        str.offset = -0.174316 
        str.error_offset = 0.00496405
        str.filename = !DATA+'/IRIS_Healpix/IRIS_combined_SFD_really_nohole_4_2048.fits'
        if keyword_set(rmsources) then $
           str.filename = !DATA+'/IRIS_Healpix/IRIS_combined_SFD_really_nohole_nosource_4_2048.fits'
        str.noisemap = !DATA+'/IRIS_Healpix/IRIS_cov0_4_cov_2048.fits'
     end
     3004: begin ; IRIS - Zody (SFD100micron reference)
        str.gain_uncertainty = 0.135
        str.conversion = 1.
        str.resolution = 4.30
        str.offset = 0.0  ; already removed when map was built
        str.error_offset = 0.00502749
        str.filename = !DATA+'/IRIS_Healpix/IRIS_really_nohole_nozody_4_2048.fits'
        if keyword_set(rmsources) then $
           str.filename = !DATA+'/Planck/DX9/DIFFUSEMAPS/3000GHz_diffusemap_repaired_nozody.fits'
        str.noisemap = !DATA+'/IRIS_Healpix/IRIS_cov0_4_cov_2048.fits'
     end
     2140: begin ; DIRBE 140 micron
        str.gain_uncertainty = 0.106
        str.conversion = 1.
        str.resolution = 42.
        str.offset = 0.908782
        str.error_offset = 0.0147821
        str.filename = !DATA+'/DIRBE/DIRBE_ZSMA_9_140mic_256.fits'
     end
     1250: begin ; DIRBE 240 micron
        str.gain_uncertainty = 0.116
        str.conversion = 1.
        str.resolution = 42.
        str.offset = 0.849838 
        str.error_offset = 0.00850448
        str.filename = !DATA+'/DIRBE/DIRBE_ZSMA_10_240mic_256.fits'
     end
     else: print, 'ERROR : FREQUENCY NOT RECOGNIZED IN MAP_PROPERTIES'
  endcase

return, str

 end

