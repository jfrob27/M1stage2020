;+
; NAME: FITGAUSS
;
; PURPOSE: 
;         multiple gaussian fitting routine
;
; CALLING SEQUENCE: 
;         result = fitgauss(spectrum [, comp=comp, nbcomp=nbcomp,
;                          chi2=chi2, nodisplay=nodisplay, yfit=yfit])
;
; INPUTS:
;         spectrum : a 1D array to be fitted
;
; OPTIONAL INPUTS:
;         nbcomp : number of Gaussian components to be fitted
;         comp : initial guess for the components. 
;                If set, superseeds value given by NBCOMP.
;                Must have the following structure : comp = fltarr(9, NBCOMP)
;                where comp(*,i) is [ A_min, A_guess, A_max, x0min, x0_guess, x0_max, sig_min, sig_guess, sig_max ]
;                For a gaussian defined as : 
;                y = A * exp ( -(x-x0)^2 / (2*sig^2) )
;                the *_guess values are the estimated guess for each
;                parameter and the *_min (*_max) are the minimum
;                (maximum) limits (i.e. the fit will reject
;                any solution outside these limits).
;
; KEYWORD PARAMETERS:
;         nodisplay : if set does not plot fit
;
; OUTPUTS:
;         result : fltarr(3, NBCOMP) 
;                  result from fit : [A, x0, sig] for each component
;
; OPTIONAL OUTPUTS:
;         chi2 : chi-square of the fit
;         yfit : y array corresponding to the fit
;         perror : uncertainty on each parameter
;
; PROCEDURE:
;         mpfit, mgauss, plotresfit
;
; MODIFICATION HISTORY:
;         28/06/2007 - Creation Marc-Antoine Miville-Deschenes
;         20/12/2007 - MAMD; add perror, guess, damplitude, dcentroid
;                      and dsigma keywords
;         30/09/2010 - MAMD; add xvec keyword
;-


function fitgauss, spectrum, comp=comp, nbcomp=nbcomp, chi2=chi2, nodisplay=nodisplay, yfit=yfit, $
                   perror=perror, guess=guess, damplitude=damplitude, dcentroid=dcentroid, dsigma=dsigma, $
                   xvec=xvec

  nbpix = n_elements(spectrum)

  ; SET COMPONENT GUESS AND LIMITS
  if keyword_set(comp) then nbcomp = n_elements(comp)/9
  if keyword_set(guess) then nbcomp = n_elements(guess)/3
  if not keyword_set(nbcomp) then nbcomp=1
  if not keyword_set(comp) then begin
     comp = fltarr(9*nbcomp)
     if keyword_set(guess) then begin
        comp(3*findgen(3*nbcomp)+1) = guess
     endif else begin
        comp(9*findgen(nbcomp)+1) = median(spectrum)
        comp(9*findgen(nbcomp)+4) = nbpix/2.
        comp(9*findgen(nbcomp)+7) = nbpix/2.
     endelse

     if keyword_set(damplitude) then begin
        comp(9*findgen(nbcomp)) = comp(9*findgen(nbcomp)+1)/damplitude
        comp(9*findgen(nbcomp)+2) = comp(9*findgen(nbcomp)+1)*damplitude
     endif else begin
        comp(9*findgen(nbcomp)) = min(spectrum)
        comp(9*findgen(nbcomp)+2) = max(spectrum)
     endelse

     if keyword_set(dcentroid) then begin
        comp(9*findgen(nbcomp)+3) = comp(9*findgen(nbcomp)+4)/dcentroid
        comp(9*findgen(nbcomp)+5) = comp(9*findgen(nbcomp)+4)*dcentroid
     endif else begin
        comp(9*findgen(nbcomp)+3) = 0.
        comp(9*findgen(nbcomp)+5) = nbpix-1.
     endelse

     if keyword_set(dsigma) then begin
        comp(9*findgen(nbcomp)+6) = comp(9*findgen(nbcomp)+7)/dsigma
        comp(9*findgen(nbcomp)+8) = comp(9*findgen(nbcomp)+7)*dsigma
     endif else begin
        comp(9*findgen(nbcomp)+6) = 0.
        comp(9*findgen(nbcomp)+8) = nbpix-1.
     endelse
  endif
  minguess = comp(3*findgen(3*nbcomp))
  guess = comp(3*findgen(3*nbcomp)+1)
  maxguess = comp(3*findgen(3*nbcomp)+2)             

  ; FILL STRUCTURE FOR MPFIT
  parinfo = replicate({value:0., fixed:0, limited:[1,1], limits:[0.,0.], step:0.}, n_elements(guess))
  parinfo.limits(0) = minguess
  parinfo.limits(1) = maxguess
  parinfo(*).value = guess
  if not keyword_set(xvec) then xvec = findgen(nbpix)
  functargs = {XVAL:xvec, YVAL:spectrum} 

  ; COMPUTE FIT
  result = mpfit("gauss_mpfit", functargs=functargs, parinfo=parinfo, /quiet, perror=perror) 
  yfit = mgauss(xvec,result)
  chi2 = total( (spectrum-yfit)^2 )

  ; DISPLAY
  if not keyword_set(nodisplay) then begin
     plotresfit, xvec, spectrum, result
     print, result
  endif

  perror = reform(perror, 3, nbcomp)
  result = reform(result, 3, nbcomp)
  return, result

end
