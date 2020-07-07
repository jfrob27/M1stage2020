pro fithi_healpix_blob, cube, nbcomp, result, chi2, dcentroid=dcentroid, dsigma=dsigma, $
                        dwindow=dwindow, noise=noise, radius=radius, $ 
                        nodisplay=nodisplay, reb=reb, perror=perror, yrange=yrange, maxchi2=maxchi2, all=all, $
                        nbsigma=nbsig, nbmin=nbmin, verb=verb, maxsigma=maxsigma, velvec=v

; maxchi2 : use only spectra where the chi2 is lower than maxchi2
; dcentroid : distance in channel used to group component


;---------- KEYWORDS ------------
  sicube = size(cube)
  nside = npix2nside(sicube[1])
  ampmax = max(cube)
  if not keyword_set(radius) then radius = 3.                   ; degree
  dv = abs( median(v-shift(v,-1)) )

;  if not keyword_set(damplitude) then damplitude=100.
  if not keyword_set(dsigma) then dsigma=1
  if not keyword_set(dcentroid) then dcentroid=3.
  if not keyword_set(nbsig) then nbsig=1
  if not keyword_set(dwindow) then dwindow=1
  if not keyword_set(nbmin) then nbmin = floor((dwindow*2+1.)^2/2.)
  nbmin = nbmin < (dwindow*2+1.)^2
  if not keyword_set(reb) then reb=1
  if not keyword_set(yrange) then begin
     ind = where(cube ne -32768.)
     yrange = minmax(cube(ind))
  endif
  if not keyword_set(maxchi2) then maxchi2=-1.e8
  if not keyword_set(maxsigma) then maxsigma = sicube[2]

  if not keyword_set(noise) then noise = la_sigma(cube[*,0:10], dim=-1)

  if not keyword_set(nodisplay) then begin
     window, 0
;     window, 1
  endif
  if not keyword_set(verb) then quiet=1 else quiet=0


; Initialisation
  parinfo = replicate({value:0., fixed:0, limited:[1,1], limits:[0.,max(cube)], step:0.}, 3*nbcomp)

  if not keyword_set(perror) then perror = fltarr(sicube(1), 3*nbcomp)

  if not keyword_set(chi2) then begin
     chi2 = fltarr(sicube(1))
     chi2(*) = 32768.
  endif
  if not keyword_set(result) then begin
     result = fltarr(sicube(1), 3*nbcomp)
     result(*) = -32768.
  endif 

  ampvec = findgen(nbcomp)*3
  centvec = ampvec+1
  sigvec = centvec+1
; loop on spectra
  x = findgen(sicube(2))
  for i=0L, sicube(1)-1 do begin 
     spec = reform(cube[i,*])

; Make sure the spectrum is defined and needs to be fitted 
     nozero = where(spec ne 0. and spec ne -32768., nb_nozero)
     if (nb_nozero gt 0 and ((chi2(i) ge maxchi2 and chi2(i) gt 0.) or keyword_set(all)) ) then begin

; extract information from neighbouring pixels
        pix2vec_ring, nside, i, vector        
        query_disc, nside, vector, radius, ind_i, nn, /Deg

        subchi2 = chi2(ind_i)
        chi2before = chi2[i]
        minArea = 5*noise[i]

        good = where(subchi2 le 2*maxchi2, nbgood)
        if (nbgood gt 0) then begin
           ind_i = ind_i[good]
           for j=0, n_elements(ind_i)-1 do begin
              if (j eq 0) then amp = result(ind_i[j],ampvec) else amp = [amp, result(ind_i[j],ampvec)]
              if (j eq 0) then cent = result(ind_i[j],centvec) else cent = [cent, result(ind_i[j],centvec)]
              if (j eq 0) then sig = result(ind_i[j],sigvec) else sig = [sig, result(ind_i[j],sigvec)]
           endfor        
           area = la_mul(amp, sig)
; keep only 
; 1) components at positions where the chi2 is good (less than 3 times the target chi2)
; 2) components that have an area greater than 5 times the noise
; 3) components that have a sigma lower than maxsigma
           good = where(area ge minArea and sig le maxsigma, nbgood)
        endif else nbgood = 0

                                ; extreme limits
        minlimit = [0., min(x[nozero]), 0.]
        a_max = max(spec, wmax)
        maxlimit = [a_max, max(x[nozero]), nb_nozero]
        guess = [a_max, x[wmax], 10.] 
;        maxlimit = [ampmax, max(x[nozero]), nb_nozero]
;        guess = (minlimit+maxlimit)/2.
        lim1 = minlimit
        lim2 = maxlimit

; Group Gaussian together (blob) to identify relevant components
        if (nbgood gt 0) then begin
           blob = blobfind(cent(good), sig(good), dxmin=dcentroid, dymin=dsigma, /ypercent)
           blobparam, blob, amp(good), cent(good), sig(good), $
                      guess, lim1, lim2, nbmin=nbmin, nbsig=nbsig, sigsmooth=8./dv

           nb = n_elements(guess)/3. ; make sure we do not have more components than NBCOMP 
           if (nb gt nbcomp) then begin
              guess = guess(0:3*nbcomp-1)
              lim1 = lim1(0:3*nbcomp-1)
              lim2 = lim2(0:3*nbcomp-1)
           endif

        endif 

        nb = n_elements(guess)/3.
        print, i
;        print, lim1
;        print, guess
;        print, lim2

        if (nb_nozero gt 0) then begin

           ndet_plus_photon = reform(noise[i])*(1+spec/20.) ; from Boothroyd et al. (2011)
           fithi_spectrum, x[nozero], spec[nozero], ndet_plus_photon[nozero], bestresult, $
                           guess=guess, error=error, chi2=bestchi2, nbcomp=nbcomp, minlimits=lim1, $
                           maxlimits=lim2, maxchi2=maxchi2, quiet=quiet, maxsigma=maxsigma
  

           ;; functargs = {XVAL:x[nozero], YVAL:spec[nozero], ERRVAL:ndet_plus_photon[nozero]} 
           ;; ni = 1
           ;; chi2now=1.e6
           ;; chi2previous=2.e6
           ;; while (chi2best gt maxchi2 and ni le nbcomp and chi2now lt chi2previous) do begin
           ;;    chi2previous = chi2now
           ;;    if (ni gt nb) then begin
           ;;       residu = la_sub(spec,model)
           ;;       maxresidu = max(residu, wmax)
           ;;       guess = [guess, [maxresidu, wmax, 10.]]
           ;;       lim1 = [lim1, minlimit]
           ;;       lim2 = [lim2, maxlimit]
           ;;    endif
           ;;    parinfo = replicate({value:0., fixed:0, limited:[1,1], limits:[0.,max(cube)], step:0.}, 3*ni)
              
           ;;                      ; MPFIT
           ;;    parinfo.limits(0) = lim1(0:3*ni-1)
           ;;    parinfo.limits(1) = lim2(0:3*ni-1)
           ;;    parinfo(*).value = guess(0:3*ni-1)
           ;;    error = 0
              
           ;;    aguess = mpfit("gauss_mpfit", functargs=functargs, parinfo=parinfo, quiet=quiet, perror=error, bestnorm=chisq) 

           ;;                      ; check for Gaussian with zero
           ;;                      ; amplitude or zero sigma
           ;;    amplitude = aguess(findgen(ni)*3)
           ;;    sigma = aguess(findgen(ni)*3+2)
           ;;    izero = where(amplitude eq 0. or sigma eq 0., nzero, complement=inozero, ncomplement=nib)
           ;;    idx = [3*inozero, 3*inozero+1, 3*inozero+2]
           ;;    idx = idx(sort(idx))
           ;;    aguess = aguess(idx)              

           ;;                      ; CHI SQUARE
           ;;    nbfree = nb_nozero-n_elements(aguess)
           ;;    model = mgauss(x, aguess)
           ;;    chi2now = total( (spec[nozero]-model[nozero])^2 / ndet_plus_photon[nozero]^2 ) / nbfree              
           ;;    if (chi2now lt chi2best) then begin
           ;;       guessbest = aguess
           ;;       chi2best = chi2now
           ;;    endif
           ;;    ni = ni+1
           ;;    print, ni, chi2now
           ;; endwhile

                                ; SAVE RESULT 
           chi2[i] = bestchi2
           result[i,*] = -32768.
           result[i,0:n_elements(bestresult)-1] = bestresult
           if keyword_set(error) then begin
              perror[i,*] = -32768.
              perror[i,0:n_elements(error)-1] = error
           endif

        endif
                                ; DISPLAY
        if not keyword_set(nodisplay) then begin
           wset, 0
           plotresfit, x, spec, reform(result[i,*]), title=strc(i) ;, yrange=yrange
           xyouts, 0.2, 0.8, 'chi2 before: ' + strc(chi2before), /normal
           xyouts, 0.2, 0.75, 'chi2 new: ' + strc(chi2[i]), /normal
           xyouts, 0.2, 0.7, 'nb guess: ' + strc(n_elements(guess)/3), /normal
           xyouts, 0.2, 0.65, 'nb found: ' + strc(n_elements(bestresult)/3), /normal
        endif
     endif

;  if not keyword_set(nodisplay) then begin
;     wset, 1
;     tempo = chi2
;     ind = where(tempo eq tempo(0))
;     tempo(ind) = -32768
;     imaffi, tempo, reb=reb, imrange=compute_range(tempo, perc=1)
;  endif

endfor

end
