pro fithi_test, cube, comp, result, chi2, damplitude=damplitude, dcentroid=dcentroid, dsigma=dsigma, $
                dwindow=dwindow, changed=changed, strict=strict, chisquare=chisquare, $
                median=median, nodisplay=nodisplay, reb=reb, perror=perror

if not keyword_set(damplitude) then damplitude=100.
if not keyword_set(dcentroid) then dcentroid=100.
if not keyword_set(dsigma) then dsigma=100.
if not keyword_set(dwindow) then dwindow=1
if not keyword_set(reb) then reb=1

sicube = size(cube)
if (sicube(1) gt 1 and sicube(2)) gt 1 then true3d=1 else true3d=0
if not keyword_set(nodisplay) then begin
    window, 0
    if (true3d) then window, 1, xs=reb*sicube(1), ys=reb*sicube(2)
endif

nbval = n_elements(comp)/3
minguess0 = comp(3*findgen(nbval))
guess0 = comp(3*findgen(nbval)+1)
maxguess0 = comp(3*findgen(nbval)+2)             
parinfo = replicate({value:0., fixed:0, limited:[1,1], limits:[0.,max(cube)], step:0.}, n_elements(guess0))

perror = fltarr(sicube(1), sicube(2), n_elements(guess0))

; Compute normalised Chi2 from cube and result if available
chi2 = fltarr(sicube(1), sicube(2))
chi2(*) = 32768.
if not keyword_set(result) then begin
    result = fltarr(sicube(1),sicube(2),n_elements(guess0))
    result(*) = -32768.
endif else begin
    x = findgen(sicube(3))
    for j=0, sicube(2)-1 do begin
        for i=0, sicube(1)-1 do begin
            if (cube(i,j,0) ne -32768. and result(i,j,0) ne -32768.) then begin
                tempo = mgauss(x, result(i,j,*))
                chi2(i,j) = total( (cube(i,j,*)-tempo)^2 ) / total(cube(i,j,*)^2)
            endif
        endfor
    endfor
endelse


changed = 0
chi2seuil = 0.1
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
                    dguess = reform(perror(i0+pos(0), j0+pos(1), *))
                    for k=0, fix(n_elements(guess)/3.)-1 do begin 
                       parinfo(3*k).limits = [guess(3*k)-dguess(3*k), guess(3*k)+dguess(3*k)]  ; amplitude
                       parinfo(3*k+1).limits = [guess(3*k+1)-dguess(3*k+1), guess(3*k+1)+dguess(3*k+1)] ; centroid
                       parinfo(3*k+2).limits = [guess(3*k+2)-dguess(3*k+2), guess(3*k+2)+dguess(3*k+2)]       ; sigma
                    endfor
                endif

                if keyword_set(median) then begin
                  guess = la_median(result(i0:i1,j0:j1,*), dim=1)
                  for k=0, fix(n_elements(guess)/3.)-1 do begin 
                     parinfo(3*k).limits = [guess(3*k)/damplitude, damplitude*guess(3*k)]    ; amplitude
                     parinfo(3*k+1).limits = [guess(3*k+1)-dcentroid, guess(3*k+1)+dcentroid] ; centroid
                     parinfo(3*k+2).limits = [guess(3*k+2)/dsigma, dsigma*guess(3*k+2)]       ; sigma
                  endfor
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
            aguess = mpfit("gauss_mpfit", functargs=functargs, parinfo=parinfo, /quiet, perror=error) 
            result(i,j,*) = aguess 
            perror(i,j,*) = error
            chi2(i,j) = total( (spec-mgauss(x,aguess))^2 ) / total( spec^2 )

            if not keyword_set(nodisplay) then begin
                wset, 0
                plotresfit, x, spec, result(i,j,*), title=strc(i)+', '+strc(j)
;                print, result(i,j,nbval-1)
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
