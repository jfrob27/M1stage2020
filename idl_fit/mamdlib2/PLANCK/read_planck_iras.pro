function read_planck_iras, freq, nside=nside_out, ring=ring, nested=nested, ordering=order_out, $
                           fwhm=common_res, conversion=conv_out, nominal=nominal, $
                           rmzody=rmzody, rmoffset=rmoffset, rmco=rmco, cmbmap=cmbmap, rmdipole=rmdipole, $
                           rmsources=rmsources, fileoffset=fileoffset, $; hi_threshold=hi_threshold, $
                           offset_uncertainty=offset_uncertainty, dataversion=dataversion, $
                           ; the following are obsolete keywords
                           fix353=fix353, nozody=nozody, nooffset=nooffset, leavecmb=leavecmb

; - Read Planck and IRIS maps, 
; - Convert to requested ordering
; - remove CMB 
; - smooth to fwhm (default is 5 arcmin)
; - convert to MJy/sr
; - remove offset to adjust zero level of map
; - udgrade to requested NSIDE
;
; MAMD - October 9, 2012 : creation
;      - November 27, 2012 : modify to use 545 and 857 recalibrated
;        maps
;      - Dec 5, 2012 : use SMICA as CMB map, 353 GHz recalibration is
;        now 1.01 (1.0126 before)
;      - Dec 10, 2012 : add 100 to 217 GHz bands, update conv factors
;        and resolutions according to HFIdata4CIB post (Guilaine). Add
;        nominal keyowrd to use NOMINAL maps. Remove CO emission at
;        353 GHz
;      - June 13, 2013 : put all definition of map parameters in
;        map_properties.pro
;     - April 30 2014 : add filtered CO maps from M. Remazeille

; obsolete keywords
  if keyword_set(nozody) then rmzody=1
  if keyword_set(nooffset) then rmoffset=0

  if keyword_set(nested) then order_out='NESTED'
  if keyword_set(ring) then order_out='RING'
  if not keyword_set(order_out) then order_out='RING'
  if not keyword_set(nside_out) then nside_out=2048
  if (keyword_set(leavecmb) or not keyword_set(cmbmap)) then cmbmap=''
  if not keyword_set(cmbmap) then cmbmap='NONE'
  if not keyword_set(fileoffset) then fileoffset = ''
;  if not keyword_set(hi_threshold) then hi_threshold=2.
  if not keyword_set(dataversion) then dataversion = 'DX9'

  nbfreq = n_elements(freq)
  output = fltarr(nside2npix(nside_out), nbfreq)
  conv_out = fltarr(nbfreq)
  offset_uncertainty = fltarr(nbfreq)

  if keyword_set(nominal) then nominal=1 else nominal=0
  if keyword_set(rmzody) then rmzody=1 else rmzody=0
  if not keyword_set(common_res) then common_res = 5. ; arcmin max(resolution)

  for k=0, nbfreq-1 do begin
     mprop = map_properties(freq[k], rmzody=rmzody, rmsources=rmsources, fileoffset=fileoffset, $
                            nominal=nominal, cmbmap=cmbmap, dataversion=dataversion)
     if keyword_set(mprop.filename) then begin
        conv_out[k] = mprop.conversion

; read map
        print, 'reading ', mprop.filename
        read_fits_map, mprop.filename, m, h, exth
        units = strc(sxpar(exth, 'TUNIT1'))

; fill potential undefined values
        bad = where(m le -32768., nbbad)
        if (nbbad gt 0) then m[bad] = median(m)

; make sure map is in the right ORDERING
        order_map = strc(sxpar(exth, 'ORDERING'))
        ud_grade, m, m, nside_out=2048, order_in=order_map, order_out=order_out

; smooth to common resolution
        fwhm = sqrt(common_res^2 - mprop.resolution^2)
        if (fwhm gt 0.) then begin
           print, 'smoothing to ' + strc(common_res) + ' arcmin with fwhm = '+strc(fwhm) + ' arcmin'   
           ismoothing, m, m, fwhm_arcmin=fwhm, ordering=order_out, lmax=8192, /silent
        endif
; Convert to MJy/sr - Planck low frequency maps only
        if (freq[k] le 353) then begin
           m = la_mul(m, mprop.conversion)
        endif        

; remove CMB if Planck frequency
        ;; if (freq[k] le 857 and cmbmap ne 'NONE') then begin
        ;;    allcmb_name = ['GMCA', 'SMICA', 'NILC', 'SEVEM', 'WMAP']
        ;;    allcmb_file = !DATA+['/Planck/DX9/CMB/testmac_alm.fits', $
        ;;                       '/Planck/DX9/CMB/dx9_smica_harmonic_cmb.fits', $
        ;;                       '/Planck/DX9/CMB/deltadx9_nilc_v1_cmb.fits', $
        ;;                       '/Planck/DX9/CMB/dx9_sevem_cmb.fits', $
        ;;                       '/WMAP/wmap_ilc_7yr_v4.fits']
        ;;    if not keyword_set(cmb) then begin
        ;;       indcmb = where(allcmb_name eq cmbmap)
        ;;       cmb_file = allcmb_file[indcmb[0]]
        ;;       print, 'reading ', cmb_file
        ;;       read_fits_map, cmb_file, cmb, hcmb, exthcmb
        ;;       case strupcase(cmbmap) of
        ;;          'GMCA' : begin
        ;;             cmb_resolution = 5.
        ;;             cmb = cmb / 1.e6   ; from microK_CMB to K_CMB
        ;;          end
        ;;          'SMICA' : begin
        ;;             cmb = cmb / 1.e6   ; from microK_CMB to K_CMB
        ;;             cmb_resolution = 5.
        ;;          end
        ;;          'NILC' : begin
        ;;             cmb = cmb / 1.e6   ; from microK_CMB to K_CMB
        ;;             cmb_resolution = 5.
        ;;          end
        ;;          'SEVEM' : begin
        ;;             cmb_resolution = 5.
        ;;          end
        ;;          'WMAP' : begin
        ;;             cmb = cmb[*,0]
        ;;             cmb = cmb / 1.e3   ; from mK_CMB to K_CMB
        ;;             cmb_resolution = 60.
        ;;          end
        ;;          else : print, 'unknown cmbmap: ', strupcase(cmbmap)
        ;;       endcase
        ;;      ; make sure it is in the right ordering and at nside = 2048
        ;;       order_map = strc(sxpar(exthcmb, 'ORDERING'))
        ;;       ud_grade, cmb, cmb, nside_out=2048, order_in=order_map, order_out=order_out
        ;;       cmb = reform(cmb)              
        ;;       ; remove monopole and dipole from CMB map
        ;;       remove_dipole, cmb, noremove=0, nside=2048, ordering=order_out
        ;;       ; smooth to common resolution
        ;;       fwhm2 = (common_res^2 - cmb_resolution^2) > (mprop.resolution^2 - cmb_resolution^2)
        ;;       if (fwhm2 gt 0.) then ismoothing, cmb, cmb, fwhm_arcmin=sqrt(fwhm2), ordering=order_out
        ;;    endif

        if (freq[k] le 857 and cmbmap ne 'NONE') then begin
           if not keyword_set(cmb) then $
              cmb = read_cmb_map(cmbmap, order=order_out, fwhm=(common_res > mprop.resolution), nside=2048) ; K_CMB
           ; remove CMB in MJy/sr
           m = m - cmb*mprop.conversion
        endif

; Remove CO emission at 353 GHz
        if (freq[k] le 353 and keyword_set(rmco)) then begin
           dirCO = '/data/glx-mistic/data1/tghosh/DX11c/fg_templates/'
           case freq[k] of
              100 : begin
                 co_file = dirCO+'co10_type1_gnilc.fits'
                 reso_co = 9.64
                 conv_co = 1.42e-5 ; Kcmb/Kkms
              end
              217 : begin
                 co_file = dirCO+'co21_type1_gnilc.fits'
                 reso_co = 4.99
                 conv_co = 4.43e-5 ; Kcmb/Kkms
              end
              353 : begin
                 co_file = dirCO+'co32_type1_gnilc.fits'
                 reso_co = 4.82
                 conv_co = 1.72e-4  ; Kcmb/Kkms
              end
              else : co_file=''
           endcase
;           read_fits_map,!DATA+'/Planck/DX9/CO/345GHz_CO_J3-2_15arcmin_cleaned.fits', mco, h_co, exth_co  ; MJy/sr
           ; reso_co = 15.  ; arcmin

           ; make sure it is in the right ordering
           if (keyword_set(co_file)) then begin
              print, 'reading ', co_file
              read_fits_map, co_file, mco, h_co, exth_co ; K km/s
              order_map = strc(sxpar(exth_co, 'ORDERING'))
              ud_grade, mco, mco, nside_out=2048, order_in=order_map, order_out=order_out
              mco = reform(mco)
           ; smooth to common resolution
              fwhm2 = common_res^2 - reso_co^2
              if (fwhm2 gt 0.) then begin
                 print, 'smoothing to ' + strc(common_res) + ' arcmin with fwhm = '+strc(sqrt(fwhm2)) + ' arcmin'
                 ismoothing, mco, mco, fwhm_arcmin=sqrt(fwhm2), $
                             ordering=order_out, lmax=8192, /silent
              endif
           ; try to do higher resolution
;           if (fwhm2 gt 0.) then begin
;              ismoothing, mco, mco, fwhm_arcmin=sqrt(fwhm2), ordering=order_out, lmax=8192
;           endif else begin
;              fwhm2 = 15.^2 - common_res^2
;              if (fwhm2 gt 0) then ismoothing, m, m_15, fwhm_arcmin=sqrt(fwhm2), ordering=order_out, lmax=8192 else m_15=m
;              mco_15 = m*mco_15/m_15  ; estimate CO at higher resolution than 15 arcmin
;           endelse
           ; remove CO emission in MJy/sr
              m = m - mco*conv_co*mprop.conversion
           endif
        endif

; remove dipole
        if (keyword_set(rmdipole)) then begin
           GLON_WMAP = 263.99
           GLAT_WMAP = 48.26
           AMPLITUDE = mprop.dipole
           dipole = mapdipole(npix2nside(n_elements(m)), [AMPLITUDE, GLON_WMAP, GLAT_WMAP], ordering=order_out)
           m = m-dipole
           print, strc(freq[k])+', DIPOLE: ' + strc(mprop.dipole) + ' +- ' + strc(mprop.error_dipole)
        endif

; remove offset
        if keyword_set(rmoffset) then begin
           oao = mprop.offset
           sigoffset = mprop.error_offset
           m = la_sub(m, oao)
           offset_uncertainty[k] = sigoffset
           print, strc(freq[k])+', OFFSET: ' + strc(oao) + ' +- '+strc(sigoffset)
        endif

; degrade to NSIDE_OUT
        ud_grade, m, m, order_in=order_out, order_out=order_out, $
                  nside_out=nside_out, bad_data=-32768
        m = reform(m)

     endif else begin
        print, 'undefined frequency'
        m = -1
     endelse
     output[*,k] = m
     print, '------------------------------------'

  endfor

  return, output

end


     ;; if (nbind gt 0) then begin
     ;;    dir = !DATA
     ;;    if keyword_set(nominal) then nom = '_NOMINAL' else nom = ''
     ;;    files = dir+['/Planck/DX9/MAP_100GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits', $
     ;;                 '/Planck/DX9/MAP_143GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits', $
     ;;                 '/Planck/DX9/MAP_217GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits', $
     ;;                 '/Planck/DX9/MAP_353GHz_DX9'+nom+'_2048_GALACTIC_0240_27008.fits', $
     ;;                 '/Planck/DX9/MAP_545GHz_v53_MJyResca'+nom+'_2048_GALACTIC_0240_27008.fits', $
     ;;                 '/Planck/DX9/MAP_857GHz_v53_MJyResca'+nom+'_2048_GALACTIC_0240_27008.fits', $
     ;;                 '/DIRBE/DIRBE_ZSMA_10_240mic_256.fits', $
     ;;                 '/DIRBE/DIRBE_ZSMA_9_140mic_256.fits', $
     ;;                 '/DIRBE/DIRBE_ZSMA_8_100mic_256.fits', $
     ;;                 '/IRIS_Healpix/SFD_i100_healpix_2048_2.fits', $
     ;;                 '/IRIS_Healpix/IRIS_combined_SFD_really_nohole_4_2048.fits', $
     ;;                 '/IRIS_Healpix/IRIS_really_nohole_nozody_4_2048.fits', $
     ;;                 '/IRIS_Healpix/IRIS_really_nohole_4_2048.fits', $
     ;;                 '/IRIS_Healpix/iris_60_nohole_nozody_2048.fits']
     ;;    if keyword_set(rmzody) then begin
     ;;       files[0] = dir+'/Planck/DX9/MAP_100GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
     ;;       files[1] = dir+'/Planck/DX9/MAP_143GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
     ;;       files[2] = dir+'/Planck/DX9/MAP_217GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
     ;;       files[3] = dir+'/Planck/DX9/MAP_353GHz_v53_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
     ;;       files[4] = dir+'/Planck/DX9/MAP_545GHz_v53_MJyResca_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
     ;;       files[5] = dir+'/Planck/DX9/MAP_857GHz_v53_MJyResca_noZodi'+nom+'_2048_GALACTIC_0240_27008.fits'
     ;;    endif 
     ;;    if (keyword_set(nominal) and not keyword_set(rmzody) and keyword_set(rmsources)) then begin
     ;;       files[0] = dir+'/Planck/DX9/DIFFUSEMAPS/100GHz_diffusemap_KCMB.fits'           
     ;;       files[1] = dir+'/Planck/DX9/DIFFUSEMAPS/143GHz_diffusemap_KCMB.fits'           
     ;;       files[2] = dir+'/Planck/DX9/DIFFUSEMAPS/217GHz_diffusemap_KCMB.fits'           
     ;;       files[3] = dir+'/Planck/DX9/DIFFUSEMAPS/353GHz_diffusemap_KCMB.fits'           
     ;;       files[4] = dir+'/Planck/DX9/DIFFUSEMAPS/545GHz_diffusemap.fits'           
     ;;       files[5] = dir+'/Planck/DX9/DIFFUSEMAPS/857GHz_diffusemap.fits'           
     ;;       files[11] = dir+'/Planck/DX9/DIFFUSEMAPS/3000GHz_diffusemap.fits'           
     ;;       files[12] = dir+'/Planck/DX9/DIFFUSEMAPS/5000GHz_diffusemap.fits'     
     ;;    endif

;;        i = ind[0]
;;        conv_out[k] = conv[i]
