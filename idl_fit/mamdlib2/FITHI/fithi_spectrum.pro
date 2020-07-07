pro fithi_spectrum, x, spectrum, noise, result, guess=guess, nbcomp=nbcomp, maxchi2=maxchi2, $
                    minlimits=minlimits, maxlimits=maxlimits, error=error, chi2=chi2, quiet=quiet, maxsigma=maxsigma

  m = max(spectrum, wmax)
  nbsample = n_elements(spectrum)
  if not keyword_set(nbcomp) then nbcomp=100   ; maximum number of Gaussian components
  if not keyword_set(maxchi2) then maxchi2 = 2.

  ;--  set initial guess if not given ---
  if not keyword_set(guess) then begin
     n = total(spectrum)
     c = total(x*spectrum)/n
     s = sqrt( total(x^2*spectrum)/n - c^2 )
     guess = [m/2, c, s]
  endif
  nb = n_elements(guess)/3.
  

  ;----  set limits -----

  ; extreme limits
  ext_min_lim = [0., min(x), 0.]
  ext_max_lim = [m, max(x), nbsample]

  if not keyword_set(minlimits) then begin
     for i=0, nb-1 do begin
        if (i eq 0) then minlimits = ext_min_lim else minlimits = [minlimits, ext_min_lim]
     endfor
  endif

  if not keyword_set(maxlimits) then begin
     for i=0, nb-1 do begin
        if (i eq 0) then maxlimits = ext_max_lim else maxlimits = [maxlimits, ext_max_lim]
     endfor
  endif

  chi2best = 32768.
  guessbest = [-32768., -32768., -32768.]
  functargs = {XVAL:x, YVAL:spectrum, ERRVAL:noise}              
  ni = 1
;  ni = nb
  chi2now=1.e6
  chi2previous=2.e6
  errorbest=-1

;  while (chi2best gt maxchi2 and ni le nbcomp) do begin
  while (chi2best gt maxchi2 and ni le nbcomp and chi2now lt chi2previous) do begin
     chi2previous = chi2now
     if (ni gt nb) then begin
        residu = la_sub(spectrum,model)
        maxresidu = max(residu, wmax) > ext_min_lim[0]
        guess = [guess, [maxresidu, wmax, 10.]]
;                    stop
;                    n_residu = total(residu)
;                    cent_residu = total(x*residu) / n_residu
;                    sig_residu = sqrt( total(x^2*residu) / n_residu - cent_residu^2 )
;                    Guess, [maxresidu, cent_residu, sig_residu]]
        minlimits = [minlimits, ext_min_lim]
        maxlimits = [maxlimits, ext_max_lim]
     endif

     if keyword_set(maxsigma) then begin
        isigma = indgen(n_elements(maxlimits)/3.)*3+2
        maxlimits[isigma] = maxlimits[isigma] < maxsigma
        guess[isigma] = guess[isigma] < 0.9*maxsigma
        minlimits[isigma] = minlimits[isigma] < 0.9*guess[isigma] 
     endif

     ; call to MPFIT
     parinfo = replicate({value:0., fixed:0, limited:[1,1], limits:[0.,0.], step:0.}, 3*ni)     
     parinfo.limits(0) = minlimits(0:3*ni-1)
     parinfo.limits(1) = maxlimits(0:3*ni-1)     
     parinfo(*).value = guess(0:3*ni-1)
     error=0

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
     nbfree = nbsample - n_elements(aguess)
     model = mgauss(x, aguess)
     chi2now = total( (spectrum-model)^2 / noise^2 ) / nbfree
     if (chi2now lt chi2best) then begin
        guessbest = aguess
        chi2best = chi2now
        errorbest = error
     endif
     ni = ni+1
     print, fix(ni), chi2now
  endwhile

  result = guessbest
  chi2 = chi2best
  error = errorbest

end
