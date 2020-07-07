pro fithi_cube_blob, cube, nbcomp, result, chi2, dcentroid=dcentroid, dsigma=dsigma, $
                     dwindow=dwindow, noise=noise, $ 
                     nodisplay=nodisplay, reb=reb, perror=perror, yrange=yrange, maxchi2=maxchi2, all=all, $
                     nbsigma=nbsig, nbmin=nbmin, verb=verb, maxsigma=maxsigma

; maxchi2 : use only spectra where the chi2 is lower than maxchi2
; dcentroid : distance in channel used to group component


;---------- KEYWORDS ------------
  sicube = size(cube)
  ampmax = max(cube)

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
  if not keyword_set(maxsigma) then maxsigma = sicube[3]

  if not keyword_set(noise) then noise = la_sigma(cube(*,*,0:10), dim=-1)

  if (sicube(1) gt 1 and sicube(2) gt 1) then true3d=1 else true3d=0
  if not keyword_set(nodisplay) then begin
     window, 0
;     if (true3d) then window, 1, xs=reb*sicube(1), ys=reb*sicube(2)
;     window, 2
  endif
  if not keyword_set(verb) then quiet=1 else quiet=0


; Initialisation
  parinfo = replicate({value:0., fixed:0, limited:[1,1], limits:[0.,max(cube)], step:0.}, 3*nbcomp)

  if not keyword_set(perror) then perror = fltarr(sicube(1), sicube(2), 3*nbcomp)

  if not keyword_set(chi2) then begin
     chi2 = fltarr(sicube(1), sicube(2))
     chi2(*) = 32768.
  endif
  if not keyword_set(result) then begin
     result = fltarr(sicube(1),sicube(2), 3*nbcomp)
     result(*) = -32768.
  endif 

  xymap, sicube(1), sicube(2), xmap, ymap
  xcube = fltarr(sicube(1), sicube(2), nbcomp)
  ycube = xcube
  for i=0, nbcomp-1 do begin
     xcube(*,*,i) = xmap
     ycube(*,*,i) = ymap
  endfor

  ampvec = findgen(nbcomp)*3
  centvec = ampvec+1
  sigvec = centvec+1
; loop on spectra
  sicube = size(cube)
  x = findgen(sicube(3))
  for i=0, sicube(1)-1 do begin 
     i0 = (i-dwindow)>0
     i1 = (i+dwindow)<(sicube(1)-1) 
     for j=0, sicube(2)-1 do begin 
        spec = reform(cube(i,j,*))

; Make sure the spectrum is defined and needs to be fitted 
        nozero = where(spec ne 0. and spec ne -32768., nb_nozero)
        if (nb_nozero gt 0 and ((chi2(i,j) ge maxchi2 and chi2(i,j) gt 0.) or keyword_set(all)) ) then begin

; extract information from neighbouring pixels
           j0 = (j-dwindow)>0 
           j1 = (j+dwindow)<(sicube(2)-1)                                         
           amp = result(i0:i1,j0:j1,ampvec)
           cent = result(i0:i1,j0:j1,centvec)
           sig = result(i0:i1,j0:j1,sigvec)
           xmap = xcube(i0:i1,j0:j1,*)-xcube(i,j,0)
           ymap = ycube(i0:i1,j0:j1,*)-ycube(i,j,0)
           subchi2 = chi2(i0:i1,j0:j1)
           chi2before = chi2(i,j)
           area = la_mul(amp, sig)
           minArea = 5*noise(i,j)

; keep only 
; 1) components at positions where the chi2 is good (less than 3 times the target chi2)
; 2) components that have an area greater than 5 times the noise
; 3) components that have a sigma lower than maxsigma
           rien = where(subchi2 gt 3*maxchi2, nbrien)
           if (nbrien gt 0) then begin
              mask = subchi2
              mask(*) = 1
              mask(rien) = -32768.
              for k=0, nbcomp-1 do area(*,*,k) = la_mul(area(*,*,k), mask)
           endif
           good = where(area ge minArea and sig le maxsigma, nbgood)

           ; extreme limits
           minlimit = [0., min(x[nozero]), 0.]
           maxlimit = [ampmax, max(x[nozero]), nb_nozero]
           guess = (minlimit+maxlimit)/2.
           lim1 = minlimit
           lim2 = maxlimit

; Group Gaussian together (blob) to identify relevant components
           if (nbgood gt 0) then begin
              blob = blobfind(cent(good), sig(good), dxmin=dcentroid, dymin=dsigma, /ypercent)
              blobparam, blob, amp(good), cent(good), sig(good), $; xmap(good), ymap(good), $
                         guess, lim1, lim2, nbmin=nbmin, nbsig=nbsig

              nb = n_elements(guess)/3. ; make sure we do not have more components than NBCOMP 
              if (nb gt nbcomp) then begin
                 guess = guess(0:3*nbcomp-1)
                 lim1 = lim1(0:3*nbcomp-1)
                 lim2 = lim2(0:3*nbcomp-1)
              endif

           endif 

           nb = n_elements(guess)/3.
           print, i, j

           chi2best = 32768.
           guessbest = [-32768., -32768., -32768.]
           if (nb_nozero gt 0) then begin
              functargs = {XVAL:x[nozero], YVAL:spec[nozero], ERRVAL:noise(i,j)}              
;              ndet_plus_photon = reform(noise(i,j))*(1+spec/20.)  ; from Boothroyd et al. (2011)
;              functargs = {XVAL:x[nozero], YVAL:spec[nozero], ERRVAL:ndet_plus_photon[nozero]} 
;              ni = 1
              ni = nb
              while (chi2best gt maxchi2 and ni le nbcomp) do begin
                 if (ni gt nb) then begin
                    residu = la_sub(spec,model)
;                    stop
;                    n_residu = total(residu[nozero])
;                    cent_residu = total(x[nozero]*residu[nozero]) / n_residu
;                    sig_residu = sqrt( total(x[nozero]^2*residu[nozero]) / n_residu - cent_residu^2 )

                    maxresidu = max(residu, wmax)
                    guess = [guess, [maxresidu, wmax, 10.]]
;                    guess = [guess, [maxresidu, cent_residu, sig_residu]]


                    lim1 = [lim1, minlimit]
                    lim2 = [lim2, maxlimit]
                 endif
                 parinfo = replicate({value:0., fixed:0, limited:[1,1], limits:[0.,max(cube)], step:0.}, 3*ni)
                 
                                ; MPFIT
                 parinfo.limits(0) = lim1(0:3*ni-1)
                 parinfo.limits(1) = lim2(0:3*ni-1)
                 parinfo(*).value = guess(0:3*ni-1)
                 error = 0
                 
                 aguess = mpfit("gauss_mpfit", functargs=functargs, parinfo=parinfo, quiet=quiet, perror=error, bestnorm=chisq) 

                                ; check for Gaussian with zero
                                ; amplitude or zero sigma
                 amplitude = aguess(findgen(ni)*3)
                 sigma = aguess(findgen(ni)*3+2)
                 izero = where(amplitude eq 0. or sigma eq 0., nzero, complement=inozero, ncomplement=nib)
                 idx = [3*inozero, 3*inozero+1, 3*inozero+2]
                 idx = idx(sort(idx))
                 aguess = aguess(idx)              

                                ; CHI SQUARE
                 nbfree = nb_nozero-n_elements(aguess)
                 model = mgauss(x, aguess)
                 chi2now = total( (spec[nozero]-model[nozero])^2 ) / noise(i,j)^2 / nbfree
;                 stop
;                 chi2now = total( (spec[nozero]-model[nozero])^2 / ndet_plus_photon[nozero]^2 ) / nbfree
                 if (chi2now lt chi2best) then begin
                    guessbest = aguess
                    chi2best = chi2now
                 endif
                 ni = ni+1
              endwhile

                                ; SAVE RESULT 
;           chi2(i,j) = chi2now
              chi2(i,j) = chi2best
              result(i,j,*) = -32768.
;           result(i,j,0:n_elements(aguess)-1) = aguess
              result(i,j,0:n_elements(guessbest)-1) = guessbest
              if keyword_set(error) then begin
                 perror(i,j,*) = -32768.
                 perror(i,j,0:n_elements(error)-1) = error
              endif

           endif
                                ; DISPLAY
           if not keyword_set(nodisplay) then begin
              wset, 0
              if (nb le nbcomp) then BEGIN
                 plotresfit, x, spec, reform(result(i,j,*)), title=strc(i)+', '+strc(j), yrange=yrange
                 xyouts, 0.2, 0.8, 'chi2 before: ' + strc(chi2before), /normal
                 xyouts, 0.2, 0.7, 'chi2 new: ' + strc(chi2(i,j)), /normal
                 xyouts, 0.2, 0.6, 'nb components: ' + strc(n_elements(guessbest)/3), /normal
              endif else begin
                 plotresfit, x, spec, aguess, title=strc(i)+', '+strc(j), yrange=yrange
                 xyouts, 0.2, 0.8, 'FIT FAILED', /normal
                 xyouts, 0.2, 0.7, 'chi2 new: ' + strc(chi2now), /normal
                 xyouts, 0.2, 0.6, 'nb components: ' + strc(n_elements(guessbest)/3), /normal
              endelse
           endif
        endif
     endfor 

     ;; if not keyword_set(nodisplay) and true3d then begin
     ;;    wset, 1
     ;;    tempo = chi2
     ;;    ind = where(tempo eq tempo(0))
     ;;    tempo(ind) = -32768
     ;;    imaffi, tempo, reb=reb, position=[0,0], imrange=compute_range(tempo, perc=1)
     ;;    wset, 2     
     ;;    allamp = result[0:i,*,ampvec]
     ;;    allsig = result[0:i,*,sigvec]
     ;;    phisto, allsig, weight=allsig*allamp, xr=[0,30], bin=0.1
     ;; endif


  endfor

end
