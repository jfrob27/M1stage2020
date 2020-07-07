pro fithi_cube_var, cube, comp, result, chi2, damplitude=damplitude, dcentroid=dcentroid, dsigma=dsigma, $
                    dwindow=dwindow, changed=changed, strict=strict, chisquare=chisquare, $
                    median=median, nodisplay=nodisplay, reb=reb, remcomp=remcomp, best=best

  if not keyword_set(damplitude) then damplitude=100.
  if not keyword_set(dcentroid) then dcentroid=100.
  if not keyword_set(dsigma) then dsigma=100.
  if not keyword_set(dwindow) then dwindow=1
  if not keyword_set(reb) then reb=1

  sicube = size(cube)
  if not keyword_set(nodisplay) then begin
     window, 0
     window, 1, xs=reb*sicube(1), ys=reb*sicube(2)
  endif

  nbval = n_elements(comp)/3
  minguess0 = comp(3*findgen(nbval))
  guess0 = comp(3*findgen(nbval)+1)
  maxguess0 = comp(3*findgen(nbval)+2)             
  if not keyword_set(remcomp) then remcomp=replicate(0, n_elements(guess0))
  parinfo = replicate({value:0., fixed:0, limited:[1,1], limits:[0.,max(cube)], step:0.}, n_elements(guess0))
  x = findgen(sicube(3))

; Compute normalised Chi2 from cube and result if available
  chi_cutoff=5
  if not keyword_set(chi2) then begin 
     chi2 = dblarr(sicube(1), sicube(2))
     chi2(*) = 32768.
  endif
  best = dblarr(sicube(1), sicube(2))
  best(*) = 32768.
  if not keyword_set(result) then begin
     result = fltarr(sicube(1),sicube(2),n_elements(guess0))
     result(*) = -32768.
  endif


  for i=0, sicube(1)-1 do begin 
     i0 = (i-dwindow)>0
     i1 = (i+dwindow)<(sicube(1)-1) 
     for j=0, sicube(2)-1 do begin 
        print, i, j
        spec = reform(cube[i,j,*]) 
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
              endif
              if keyword_set(median) then $
                 guess = la_median(result(i0:i1,j0:j1), dim=1)

              for k=0, fix(n_elements(guess)/3.)-1 do begin 
                 parinfo(3*k).limits = [guess(3*k)/damplitude, damplitude*guess(3*k)]        ; amplitude
                 parinfo(3*k+1).limits = [guess(3*k+1)-dcentroid, guess(3*k+1)+dcentroid]    ; centroid
                 parinfo(3*k+2).limits = [guess(3*k+2)/dsigma, dsigma*guess(3*k+2)]          ; sigma
              endfor

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

           chi2r=1e8
           mask = where(remcomp eq 1, cmax)

           if cmax gt 0 then begin        ; some components are flaged as removable
              for c=0,2^cmax-1 do begin   ; loop through posibilities
                 parinfo(*).value = guess
                 parinfo(*).fixed = 0
                 parinfo(*).limited = [1,1]
                 cmask = where(binary(c,arrsize=cmax) eq 0, count) ; explore combinations ([1,0],[1,1],[0,0], etc) 
                 if count gt 0 then begin
                    for cc = 0,n_elements(cmask)-1 do begin
                       index = mask[cmask[cc]]*3
                       parinfo[index:index+2].fixed = 1
                       parinfo[index:index+2].limited = [0,0]
                       parinfo[index].value = 0.
                    endfor
                 endif
                 aguess0 = mpfit("gauss_mpfit", functargs=functargs, parinfo=parinfo, /quiet, bestnorm=chisq)            
                 df = n_elements(x)-(n_elements(aguess)-3*count)
                 chi2r0 = chisq / (df)

                 if chi2r0 lt chi2r then begin ; keep best chi2
                    chi2r = chi2r0
                    best(i,j) = c
                    aguess = aguess0
                 endif

              endfor
           endif else begin     ; no components are flagged
              aguess = mpfit("gauss_mpfit", functargs=functargs, parinfo=parinfo, /quiet, bestnorm=chisq)           
              df = n_elements(x)-n_elements(aguess)
              chi2r = chisq/df
           endelse
           
                                ; keep new result if chi2 is better, or if both the median and chisquare keywords are unset
           if (not keyword_set(chisquare) and  not keyword_set(median)) or  chi2r lt chi2[i,j] then begin 
              result(i,j,*) = aguess            
              chi2(i,j) = double(chi2r)
           endif
           if not keyword_set(nodisplay) then begin
              wset, 0
              plotresfit, x, spec, result(i,j,*) ;, title=strc(i)+', '+strc(j)
              print,""
           endif
        endif
     endfor

     if not keyword_set(nodisplay) then begin
        wset, 1
        tempo = chi2
        ind = where(tempo eq tempo(0))
        tempo(ind) = -32768
        imaffi, tempo, reb=reb, position=[0,0], imrange=compute_range(tempo, perc=1)
     endif

  endfor



end
