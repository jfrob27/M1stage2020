pro fithi_cube, cube, comp, result, chi2, damplitude=damplitude, dcentroid=dcentroid, dsigma=dsigma, $
                dwindow=dwindow, changed=changed, strict=strict, chisquare=chisquare, $
                median=median, nodisplay=nodisplay, reb=reb, perror=perror, yrange=yrange, minchi2=minchi2

if not keyword_set(damplitude) then damplitude=1.5
if not keyword_set(dcentroid) then dcentroid=10.
if not keyword_set(dsigma) then dsigma=1.5
if not keyword_set(dwindow) then dwindow=1
if not keyword_set(reb) then reb=1
if not keyword_set(yrange) then begin
   ind = where(cube ne -32768.)
   yrange = minmax(cube(ind))
endif
if not keyword_set(minchi2) then minchi2=1.e8

sicube = size(cube)
if (sicube(1) gt 1 and sicube(2)) gt 1 then true3d=1 else true3d=0
if not keyword_set(nodisplay) then begin
    window, 0
    if (true3d) then window, 1, xs=reb*sicube(1), ys=reb*sicube(2)
endif

; Initialisation
nbval = n_elements(comp)/3
minguess0 = comp(3*findgen(nbval))
guess0 = comp(3*findgen(nbval)+1)
maxguess0 = comp(3*findgen(nbval)+2)             
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
        print, i, j
        spec = reform(cube(i,j,*)) 
        if (spec(0) ne -32768.) then begin
            j0 = (j-dwindow)>0 
            j1 = (j+dwindow)<(sicube(2)-1) 
            ;--- here we take guess from spectrum where chi2 is minimum
            if (keyword_set(chisquare) or keyword_set(median)) then begin
                if keyword_set(chisquare) then begin
                    tchi2 = chi2(i0:i1,j0:j1)
                    minchi2 = min(tchi2, wmin)
                    pos = indtopos(wmin, tchi2)
                    guess = reform(result(i0+pos(0), j0+pos(1), *))
                    for k=0, fix(n_elements(guess)/3.)-1 do begin 
                       parinfo(3*k).limits = [guess(3*k)/damplitude, damplitude*guess(3*k)]  ; amplitude
                       parinfo(3*k+1).limits = [guess(3*k+1)-dcentroid, guess(3*k+1)+dcentroid] ; centroid
                       parinfo(3*k+2).limits = [guess(3*k+2)/dsigma, dsigma*guess(3*k+2)]       ; sigma
                    endfor
                endif
                if keyword_set(median) then begin
;                  guess = la_median(result(i0:i1,j0:j1,*), dim=1)
                   getmedianguess, result(i0:i1,j0:j1,*), perror(i0:i1,j0:j1,*), $
                                   chi2(i0:i1,j0:j1), guess, limits, chi2min=minchi2, $
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
            parinfo(*).value = guess
            functargs = {XVAL:x, YVAL:spec}
            error = 0
            aguess = mpfit("gauss_mpfit", functargs=functargs, parinfo=parinfo, /quiet, perror=error, bestnorm=chisq) 
            result(i,j,*) = aguess 
            if keyword_set(error) then perror(i,j,*) = error
            chi2(i,j) = chisq/nbfree

            if not keyword_set(nodisplay) then begin
                wset, 0
                plotresfit, x, spec, result(i,j,*), title=strc(i)+', '+strc(j), yrange=yrange
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
