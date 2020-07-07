pro blobparam, blobnum, amp, cent, sig, guess, minlimits, maxlimits, x=x, y=y, $
               nbmin=nbmin, nbsig=nbsig, nbpix=nbpix, ampmax=ampmax, twodfit=twodfit, sigsmooth=sigsmooth

; computes the average and standard deviation of the centroid and
; sigma for each component.
; 
; nbpix : is the number of pixel in the area investigated. If, for a
; given component, the number of occurence is larger than N*nbpix, the
; component is put N times in the output. It means that N similar
; components are needed in the fit.

  if not keyword_set(nbmin) then nbmin = 2
  if not keyword_set(nbsig) then nbsig = 1.
  if not keyword_set(nbpix) then nbpix = n_elements(amp) 
  if not keyword_set(sigsmooth) then sigsmooth = 32768.


  nbpoint = histogram(blobnum,min=0)
  idx = findgen(n_elements(nbpoint))
  first = 1
  parinfo = replicate({value:0., fixed:0, limited:[1,1], limits:[-10.,10.],step:0.},6)
  parinfo[0].limits(0) = 0.
  parinfo[0].limits(1) = 1.e6
  ; identify components with a number of occurence larger than NBMIN
  tempo = where(nbpoint ge nbmin, nbindmin)
  if (nbindmin gt 0) then begin
     ; sort components from large to small number of appearance
     idx = idx(tempo)
     nbpoint = nbpoint(tempo)
     tempo = sort(nbpoint)     
     idx = idx(tempo)
     idx = reverse(idx)

     for i=0, nbindmin-1 do begin
        ind = where(blobnum eq idx(i), nbind)
;        Savg = median(sig(ind))
        Atot = total(amp(ind))
        if (Atot gt 0.) then begin           
; fits amplitude 
           if keyword_set(twodfit) then begin
              xin = dblarr(nbind,2)
              xin(*,0)=x(ind)
              xin(*,1)=y(ind)
              functargs = {XVAL:xin, FVAL:amp(ind)}
              aguess = mpfit("binom2d_mpfit",functargs=functargs,parinfo=parinfo,perror=perror,/quiet)
              Aavg = aguess(0)
              Asig = perror(0)
              functargs = {XVAL:xin, FVAL:cent(ind)}
              aguess = mpfit("binom2d_mpfit",functargs=functargs,parinfo=parinfo,perror=perror,/quiet)
              Cavg = aguess(0)
              Csig = perror(0)
              functargs = {XVAL:xin, FVAL:sig(ind)}
              aguess = mpfit("binom2d_mpfit",functargs=functargs,parinfo=parinfo,perror=perror,/quiet)
              Savg = aguess(0)
              Ssig = perror(0)
           endif else begin
              Aavg = median(amp(ind))
              Cavg = total(cent(ind)*amp(ind))/Atot 
              Savg = total(sig(ind)*amp(ind))/total(amp(ind))
              Asig = stddev(amp(ind))
              Csig = sqrt( total(cent(ind)^2*amp(ind))/Atot - Cavg^2 )
              Ssig = sqrt( total(sig(ind)^2*amp(ind))/Atot - Savg^2 )
           endelse
;           if keyword_set(ampmax) then amplim = [0., ampmax] else amplim = [(Aavg-10.*Asig)>0., Aavg+10.*Asig]
;           if keyword_set(ampmax) then amplim = [0., ampmax] else amplim = [(Aavg-nbsig*Asig)>0., Aavg+nbsig*Asig]    
           guess_cur = [Aavg, Cavg, Savg]
           if keyword_set(Savg lt sigsmooth) then amplim = [(Aavg-10.*Asig)>0., Aavg+10.*Asig] else amplim = [(Aavg-nbsig*Asig)>0., Aavg+nbsig*Asig]
           minlim_cur = [amplim[0], (Cavg-nbsig*Csig)>0, (Savg-nbsig*Ssig)>0.]
           maxlim_cur = [amplim[1], Cavg+nbsig*Csig, Savg+nbsig*Ssig] 

           ;check for undefined values, NANs or equal limits
           nan2undef, guess_cur
           nan2undef, minlim_cur
           nan2undef, maxlim_cur
           test_undef = la_mul(la_mul(guess_cur, minlim_cur), maxlim_cur)
           bad = where(test_undef eq -32768. or minlim_cur eq maxlim_cur, nbbad)

           if (nbbad eq 0) then begin
              if (first) then begin
                 guess = guess_cur
                 minlimits = minlim_cur
                 maxlimits = maxlim_cur
                 first = 0
              endif else begin 
                 guess = [guess, guess_cur]
                 minlimits = [minlimits, minlim_cur]
                 maxlimits = [maxlimits, maxlim_cur]
              endelse
           endif
        endif
     endfor
  endif 

end

