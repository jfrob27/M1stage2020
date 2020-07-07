function noise_planck_iras, freq, nside=nside_out, ring=ring, nested=nested, $
                            fwhm=common_res, conversion=conv_i, ordering=order_out, $
                            nominal=nominal, rmzody=rmzody, norescale=norescale, nosmoothing=nosmoothing, $
                            dataversion=dataversion

; - Read Planck and IRIS maps (COVAR or Coverage), 
; - Convert to requested ordering
; - smooth to fwhm (default is 5 arcmin)
; - convert to MJy/sr if necessary
; - udgrade to requested NSIDE
; - scale noise corresponding to smoothing / degrade
;
; MAMD - December 10, 2012 : creation
;      - April 30, 2014 : add DX11

; obsolete keywords
  if keyword_set(nested) then order_out='NESTED'
  if keyword_set(ring) then order_out='RING'
  if not keyword_set(order_out) then order_out='RING'
  if not keyword_set(nside_out) then nside_out=2048

  nbfreq = n_elements(freq)
  output = fltarr(nside2npix(nside_out), nbfreq)

  if not keyword_set(common_res) then common_res = 5.  ; arcmin max(resolution)

  for k=0, nbfreq-1 do begin
     mprop = map_properties(freq[k], rmzody=rmzody, nominal=nominal, dataversion=dataversion)

;     ind = where(allfreq eq freq[k], nbind)
     if keyword_set(mprop.noisemap) then begin
        conv_i = mprop.conversion

; read map
        print, 'reading ', mprop.noisemap
        read_fits_map, mprop.noisemap, m, h, exth
        units = strc(sxpar(exth, 'TUNIT1'))

; fill potential undefined values
        bad = where(m lt 0., nbbad, compl=compl)
        if (nbbad gt 0) then begin
           if (freq[k] ge 3000) then begin
              tmp = m[compl]
              compl = sort(tmp)              
              ilast = n_elements(compl)/100
              m[bad] = avg(tmp[compl[0:ilast]])
           endif else begin
              m[bad] = median(m)
           endelse
        endif

; Convert IRAS coverage map to covariance (i.e. noise^2)
        if (freq[k] ge 3000 and freq[k] le 3100) then m = median(m) / m * 0.06^2
        if (freq[k] ge 5000 and freq[k] le 5100) then m = median(m) / m * 0.03^2

; make sure map is in the right ORDERING
        order_map = strc(sxpar(exth, 'ORDERING'))
        if (order_map ne order_out) then begin
           if (order_map eq 'RING' and order_out eq 'NESTED') then m = reorder(m, /R2N) else m = reorder(m, /N2R)
        endif

; smooth to common resolution
        fwhm = sqrt(common_res^2 - mprop.resolution^2) / sqrt(2.)
        if (fwhm gt 0. and not keyword_set(nosmoothing)) then begin
           print, 'smoothing to ' + strc(common_res) + ' arcmin with fwhm = '+strc(fwhm) + ' arcmin'
           ismoothing, m, m, fwhm_arcmin=fwhm, ordering=order_out, lmax=4096, /silent
        endif
; scale corresponding to smoothing and degrade
        if not keyword_set(norescale) then begin
           Neff = 2.27 * fwhm^2 / (nside2pixsize(2048, /arcmin))^2
;           effective_res = common_res > nside2pixsize(nside_out, /arcmin) ; effective resolution of final map
;           factor = effective_res / resolution[i]
;           if (factor gt 1) then m = m / factor
           Neff = Neff > 1.
           print, 'NEFF: ', Neff
           m = m/Neff
        endif

; degrade to NSIDE_OUT
        ud_grade, m, m, order_in=order_out, order_out=order_out, nside_out=nside_out, bad_data=-32768

; Convert covariance to noise
        m = sqrt(m)             ; covariance map to noise

; Convert to MJy/sr Planck low frequency maps
        if (freq[k] le 353) then begin
           m = la_mul(m, mprop.conversion)
        endif        

     endif else begin
        print, 'undefined frequency'
        m = -32768
     endelse

     output[*,k] = m
     print, '------------------------------------'

  endfor

  return, output

end
