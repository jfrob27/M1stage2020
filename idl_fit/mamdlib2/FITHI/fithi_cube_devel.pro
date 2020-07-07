pro fithi_cube_devel, cube, comp, result, chi2, damplitude=damplitude, dcentroid=dcentroid, dsigma=dsigma, $
                      dwindow=dwindow, strict=strict, chisquare=chisquare, noise=noise, $
                      median=median, nodisplay=nodisplay, reb=reb, perror=perror, yrange=yrange, maxchi2=maxchi2

; maxchi2 : use only spectra where the chi2 is lower than maxchi2

  if not keyword_set(damplitude) then damplitude=100.
  if not keyword_set(dcentroid) then dcentroid=10.
  if not keyword_set(dsigma) then dsigma=1.5
  if not keyword_set(dwindow) then dwindow=1
  if not keyword_set(reb) then reb=1
  if not keyword_set(yrange) then begin
     ind = where(cube ne -32768.)
     yrange = minmax(cube(ind))
  endif
  if not keyword_set(maxchi2) then maxchi2=-1.e8

  if not keyword_set(noise) then noise = la_sigma(cube(*,*,0:10), dim=-1)

  sicube = size(cube)
  if (sicube(1) gt 1 and sicube(2) gt 1) then true3d=1 else true3d=0
  if not keyword_set(nodisplay) then begin
     window, 0
     if (true3d) then window, 1, xs=reb*sicube(1), ys=reb*sicube(2)
  endif

; Initialisation
  nbval = n_elements(comp)/3
  nbcomp = n_elements(comp)/9
  minguess0 = comp(3*findgen(nbval))
  guess0 = comp(3*findgen(nbval)+1)
  maxguess0 = comp(3*findgen(nbval)+2)             
  mamp = [min(minguess0(3*findgen(nbcomp))), max(maxguess0(3*findgen(nbcomp)))]
  mcent = [min(minguess0(3*findgen(nbcomp)+1)), max(maxguess0(3*findgen(nbcomp)+1))]
  msig = [min(minguess0(3*findgen(nbcomp)+2)), max(maxguess0(3*findgen(nbcomp)+2))]
  parinfo = replicate({value:0., fixed:0, limited:[1,1], limits:[0.,max(cube)], step:0.}, n_elements(guess0))
  nbfree = sicube(3)-n_elements(guess0)

  if not keyword_set(perror) then perror = fltarr(sicube(1), sicube(2), n_elements(guess0))

  if not keyword_set(chi2) then begin
     chi2 = fltarr(sicube(1), sicube(2))
     chi2(*) = 32768.
  endif
  if not keyword_set(result) then begin
     result = fltarr(sicube(1),sicube(2),n_elements(guess0))
     result(*) = -32768.
  endif 

; loop on spectra
  sicube = size(cube)
  x = findgen(sicube(3))
  for i=0, sicube(1)-1 do begin 
     i0 = (i-dwindow)>0
     i1 = (i+dwindow)<(sicube(1)-1) 
     for j=0, sicube(2)-1 do begin 
        if (chi2(i,j) ge maxchi2) then begin
           print, i, j
           spec = reform(cube(i,j,*)) 
           if (spec(0) ne -32768.) then begin
              j0 = (j-dwindow)>0 
              j1 = (j+dwindow)<(sicube(2)-1) 
                                ;--- here we take guess from spectrum
                                ;    where chi2 is minimum

              if (keyword_set(chisquare) or keyword_set(median)) then begin
                 if keyword_set(chisquare) then begin
                    tchi2 = chi2(i0:i1,j0:j1)
                    rien = min(tchi2, wmin)
                    pos = indtopos(wmin, tchi2)
                    guess = reform(result(i0+pos(0), j0+pos(1), *))
;stop
                    for k=0, nbcomp-1 do begin 
                       if (guess(3*k) ne -32768.) then begin
                          if (guess(3*k)*guess(3*k+2) lt 5*noise(i,j)) then begin   ; allow to explore the whole range if component is meaningless
                             print, 'ici', k
                             parinfo(3*k).limits = mamp  ; amplitude
                             parinfo(3*k+1).limits = mcent ; centroid
                             parinfo(3*k+2).limits = msig       ; sigma
                          endif else begin
                             parinfo(3*k).limits = [(guess(3*k)/damplitude)>mamp(0), (damplitude*guess(3*k))<mamp(1)]  ; amplitude
                             parinfo(3*k+1).limits = [(guess(3*k+1)-dcentroid)>mcent(0), (guess(3*k+1)+dcentroid)<mcent(1)] ; centroid
                             parinfo(3*k+2).limits = [(guess(3*k+2)/dsigma)>msig(0), (dsigma*guess(3*k+2))<msig(1)]       ; sigma
                          endelse
                       endif else begin
                          parinfo(3*k).limits = [minguess0(3*k), maxguess0(3*k)] 
                          parinfo(3*k+1).limits = [minguess0(3*k+1), maxguess0(3*k+1)] 
                          parinfo(3*k+2).limits = [minguess0(3*k+2), maxguess0(3*k+2)] 
                          guess(3*k:(3*k+2)) = guess0(3*k:(3*k+2))
                       endelse
                    endfor
                 endif
                 if keyword_set(median) then begin
;                  guess = la_median(result(i0:i1,j0:j1,*), dim=1)
                    getmedianguess, result(i0:i1,j0:j1,*), perror(i0:i1,j0:j1,*), $
                                    chi2(i0:i1,j0:j1), guess, limits, chi2max=maxchi2, $
                                    damplitude=damplitude, dcentroid=dcentroid, dsigma=dsigma
                    parinfo.limits = limits
                 endif

              endif else begin
                 guess = guess0
                 parinfo.limits(0) = minguess0
                 parinfo.limits(1) = maxguess0
              endelse
                                ; make sure we do not exceed global limits
              if keyword_set(strict) then begin
                 parinfo.limits(0) = parinfo.limits(0) > minguess0
                 parinfo.limits(1) = parinfo.limits(1) < maxguess0
                 checklimits, guess, parinfo
              endif

;stop
              parinfo(*).value = guess
              functargs = {XVAL:x, YVAL:spec}
              error = 0
              aguess = mpfit("gauss_mpfit", functargs=functargs, parinfo=parinfo, /quiet, perror=error, bestnorm=chisq) 
              chi2before = chi2(i,j)
              model = mgauss(x, aguess)
              chi2now = total( (spec-model)^2 ) / noise(i,j)^2 / nbfree
;              chi2now = chisq/nbfree/noise(i,j)^2
;              if (chi2now le chi2before) then begin
                 chi2(i,j) = chi2now
                 result(i,j,*) = aguess 
                 if keyword_set(error) then perror(i,j,*) = error
;              endif
              if not keyword_set(nodisplay) then begin
                 wset, 0
                 plotresfit, x, spec, result(i,j,*), title=strc(i)+', '+strc(j), yrange=yrange
                 xyouts, 0.2, 0.8, 'chi2 before: ' + strc(chi2before), /normal
                 xyouts, 0.2, 0.7, 'chi2 new: ' + strc(chi2(i,j)), /normal
              endif
           endif 
        endif
     endfor 

     if not keyword_set(nodisplay) and true3d then begin
        wset, 1
        tempo = chi2
        ind = where(tempo eq tempo(0))
        tempo(ind) = -32768
        imaffi, tempo, reb=reb, position=[0,0], imrange=compute_range(tempo, perc=1)
     endif

  endfor

end
