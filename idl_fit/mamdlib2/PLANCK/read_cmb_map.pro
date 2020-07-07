function read_cmb_map, cmbmap, order=order_out, fwhm=common_res, nside=nside_out

  if not keyword_set(order_out) then order_out='RING'
  if not keyword_set(nside_out) then nside_out=2048

  dir = !DATA
  allcmb_name = ['GMCA', 'SMICA', 'NILC', 'SEVEM', 'WMAP']
  allcmb_file = dir+['/Planck/DX9/CMB/testmac_alm.fits', $
                     '/Planck/DX9/CMB/dx9_smica_harmonic_cmb.fits', $
                     '/Planck/DX9/CMB/deltadx9_nilc_v1_cmb.fits', $
                     '/Planck/DX9/CMB/dx9_sevem_cmb.fits', $
                     '/WMAP/wmap_ilc_7yr_v4.fits']
  indcmb = where(allcmb_name eq cmbmap)
  cmb_file = allcmb_file[indcmb[0]]
  print, 'reading ', cmb_file
  read_fits_map, cmb_file, cmb, hcmb, exthcmb
  case strupcase(cmbmap) of
     'GMCA' : begin
        cmb_resolution = 5.
        cmb = cmb / 1.e6        ; from microK_CMB to K_CMB
     end
     'SMICA' : begin
        cmb = cmb / 1.e6        ; from microK_CMB to K_CMB
        cmb_resolution = 5.
     end
     'NILC' : begin
        cmb = cmb / 1.e6        ; from microK_CMB to K_CMB
        cmb_resolution = 5.
     end
     'SEVEM' : begin
        cmb_resolution = 5.
     end
     'WMAP' : begin
        cmb = cmb[*,0]
        cmb = cmb / 1.e3        ; from mK_CMB to K_CMB
        cmb_resolution = 60.
     end
     else : print, 'unknown cmbmap: ', strupcase(cmbmap)
  endcase
                                ; make sure it is in the right ordering and at nside = 2048
  order_map = strc(sxpar(exthcmb, 'ORDERING'))
  ud_grade, cmb, cmb, nside_out=2048, order_in=order_map, order_out=order_out
  cmb = reform(cmb)              
                                ; remove monopole and dipole from CMB map
  remove_dipole, cmb, noremove=0, nside=2048, ordering=order_out
              ; smooth to common resolution
  fwhm2 = (common_res^2 - cmb_resolution^2) 
  if (fwhm2 gt 0.) then begin
     print, 'smoothing to ' + strc(common_res) + ' arcmin with fwhm = '+strc(sqrt(fwhm2)) + ' arcmin'     
     ismoothing, cmb, cmb, fwhm_arcmin=sqrt(fwhm2), ordering=order_out, /silent
  endif

; degrade to NSIDE_OUT
  ud_grade, cmb, cmb, order_in=order_out, order_out=order_out, $
            nside_out=nside_out, bad_data=-32768
  cmb = reform(cmb)

return, cmb

end
