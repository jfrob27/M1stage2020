pro fithi_cube_blob, cube, nbcomp, result, chi2, dcentroid=dcentroid, dsigma=dsigma, $
                     dwindow=dwindow, noise=noise, $ 
                     nodisplay=nodisplay, reb=reb, perror=perror, yrange=yrange, maxchi2=maxchi2, all=all, $
                     nbsigma=nbsig, nbmin=nbmin, verb=verb, maxsigma=maxsigma, velvec=v

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
  fmin = nbmin / (dwindow*2+1.)^2
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
     if (true3d) then window, 1, xs=reb*sicube(1), ys=reb*sicube(2)
     window, 2
  endif
  if not keyword_set(verb) then quiet=1 else quiet=0
  firstdisplay=1

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

  dv = abs(median(v-shift(v,-1)))
  ampvec = findgen(nbcomp)*3
  centvec = ampvec+1
  sigvec = centvec+1
  sigmax = la_max(result[*,*,sigvec], dim=-1)
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
        if (nb_nozero gt 0 and ((chi2(i,j) ge maxchi2 and chi2(i,j) gt 0.) or keyword_set(all)) or sigmax[i,j] ge maxsigma) then begin

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
           sub_sigmax = la_max(sig, dim=-1)

; keep only 
; 1) components at positions where the chi2 is good (less than 3 times the target chi2)
; 2) components that have an area greater than 5 times the noise
; 3) components that have a sigma lower than maxsigma
           rien = where(subchi2 gt 3*maxchi2 or sub_sigmax ge maxsigma, nbrien)
;           rien = where(subchi2 gt 2*maxchi2, nbrien)
           if (nbrien gt 0) then begin
              mask = subchi2
              mask(*) = 1
              mask(rien) = -32768.
              for k=0, nbcomp-1 do area(*,*,k) = la_mul(area(*,*,k), mask)
           endif
           good = where(area ge minArea and sig lt maxsigma, nbgood)
;           good = where(area ge minArea, nbgood)

                                ; extreme limits
           minlimit = [0., min(x[nozero]), 0.]
           a_max = max(spec, wmax)
           maxlimit = [a_max, max(x[nozero]), nb_nozero]
           guess = [a_max, x[wmax], 10.] 
           lim1 = minlimit
           lim2 = maxlimit

; Group Gaussian together (blob) to identify relevant components
           nb = 0
           if (nbgood gt 0) then begin
              blob = blobfind(cent(good), sig(good), dxmin=dcentroid, dymin=dsigma, /ypercent)
;              nbmin = fix(0.1*n_elements(good)/3.)>3
              rien = where(sub_sigmax ne -32768., nb_pixel_def)
              nbmin_i = fix(fmin*nb_pixel_def) > 3
              print, i, j, nbmin_i
              blobparam, blob, amp(good), cent(good), sig(good), guess, lim1, lim2, nbmin=nbmin_i, $
                         nbsig=nbsig, sigsmooth=8./dv

              nb = n_elements(guess)/3. ; make sure we do not have more components than NBCOMP 
              if (nb gt nbcomp) then begin
                 guess = guess(0:3*nbcomp-1)
                 lim1 = lim1(0:3*nbcomp-1)
                 lim2 = lim2(0:3*nbcomp-1)
              endif

           endif
           guess_in = guess

           ndet_plus_photon = reform(noise(i,j))*(1+spec/20.) ; from Boothroyd et al. (2011)
           
           if (nb_nozero gt 0) then begin
              
              nbguess = n_elements(guess)/3
              fithi_spectrum, x[nozero], spec[nozero], ndet_plus_photon[nozero], bestresult, $
                              guess=guess, error=error, chi2=bestchi2, nbcomp=nbcomp, minlimits=lim1, $
                              maxlimits=lim2, maxchi2=maxchi2, quiet=quiet, maxsigma=maxsigma
              
                                ; SAVE RESULT 
              chi2(i,j) = bestchi2
              result(i,j,*) = -32768.
              result(i,j,0:n_elements(bestresult)-1) = bestresult
              if keyword_set(error) then begin
                 perror(i,j,*) = -32768.
                 perror(i,j,0:n_elements(error)-1) = error
              endif

           endif
                                ; DISPLAY
           nbfound = n_elements(bestresult)/3
           if not keyword_set(nodisplay) then begin
              wset, 0
              plotresfit, v, spec, reform(result(i,j,*)), title=strc(i)+', '+strc(j), yrange=yrange, xtitle='v (km/s)', ytitle='T (K)'
              xyouts, 0.2, 0.8, 'chi2 before: ' + strc(chi2before), /normal
              xyouts, 0.2, 0.75, 'chi2 new: ' + strc(chi2(i,j)), /normal
              xyouts, 0.2, 0.7, 'nb guess: ' + strc(nbguess), /normal
              xyouts, 0.2, 0.65, 'nb found: ' + strc(nbfound), /normal
           endif

        endif
     endfor 

     if not keyword_set(nodisplay) and true3d then begin
        wset, 1
        tempo = chi2
        ind = where(tempo eq tempo(0))
        tempo(ind) = -32768
        imaffi, tempo, position=[0,0], imrange=compute_range(tempo, perc=1), reb=1

        wset, 2     
        allamp = result[0:i,*,ampvec]
        allcent = result[0:i,*,centvec]
        allsig = la_mul(result[0:i,*,sigvec], dv)
        xr = [la_min(allsig), max(allsig)]
        phisto, allsig, weight=allsig*allamp, xr=xr, bin=0.1, xtitle='sigma (km/s)'

        rien = where(result[0:i,*,*] ne -32768., ngood)
        if (ngood gt 0) then begin
           sr = [dv,max(allsig)]
           cr = [la_min(allcent), max(allcent)]
           sigcent = syntres(result[0:i,*,*], sigrange=sr, centrange=cr, /ylog, dcentroid=0.5)
           sigcent2 = syntres2(result[0:i,*,*], sigrange=sr, centrange=cr, /ylog, dcentroid=0.5)
           imr2 = range(sigcent2, 0.1)
           imr1 = range(sigcent, 0.1)

           if keyword_set(firstdisplay) then begin
              pos = multipos(1,2)
              reb=0.2
              p1 = pos[*,0]
              winnum = 8
           endif else begin
              p1 = pos[0:1,0]
              wset, 8
           endelse
           erase
           imaffi, sigcent2, /cadrenu, imr=imr2, $
                   xtitle='v (km/s)', ytitle='sigma (kms/s)', posi=p1, reb=reb, winn=winnum, title=strc(i)
           plot, [v(cr[0]), v(cr[1])], [sr[0]*dv,sr[1]*dv],xr=[v(cr[0]), v(cr[1])],/xs,/ys, $
                 /nodata,  posi=pos[*,0], /noerase, /ylog, col=mcol('white')
           plot, [v(cr[0]), v(cr[1])], [sr[0]*dv,sr[1]*dv],xr=[v(cr[0]), v(cr[1])],/xs,/ys, $
                 /nodata,  posi=pos[*,0], /noerase, /ylog, xticklen=1.e-6, yticklen=1.e-6, xtitle='v (km/s)', $
                 ytitle='!9s!3 (km/s)'

           imaffi, sigcent, imr=imr1, $
                   xtitle='v (km/s)', ytitle='sigma (km/s)', posi=pos[0:1,1], reb=reb, /cadrenu
           plot, [v(cr[0]), v(cr[1])], [sr[0]*dv,sr[1]*dv],xr=[v(cr[0]), v(cr[1])],/xs,/ys, $
                 /nodata,  posi=pos[*,1], /noerase, /ylog, col=mcol('white')
           plot, [v(cr[0]), v(cr[1])], [sr[0]*dv,sr[1]*dv],xr=[v(cr[0]), v(cr[1])],/xs,/ys, $
                 /nodata,  posi=pos[*,1], /noerase, /ylog, xticklen=1.e-6, yticklen=1.e-6, xchars=1.e-6, $
                 ytitle='!9s!3 (km/s)'
           firstdisplay=0
        endif
     endif

  endfor

end
