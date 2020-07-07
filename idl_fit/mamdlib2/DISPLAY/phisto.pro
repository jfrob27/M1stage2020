pro phisto, vinput, mini=mini, maxi=maxi, bin=bin, indef=indef, yrange=yrange, ylog=ylog, $
            gauss=gauss, gcolor=gcolor, psym=psym, normal=normal, log=log, areanorm=areanorm, $
            xrange=xrange, coeff=coeff, _Extra=extra, histo=histo, xvec=xvec, weight=weight, $
            fill=fill, oplot=oplot, fcolor=fcolor, lnormal=lnormal, silent=silent, noplot=noplot, $
            xval=x, yval=y


;--- CHECK INPUT DATA ----
if not keyword_set(indef) then indef=-32768.
ind = where(vinput ne indef, nbind)
if (nbind eq 0) then begin
    print, 'No good value'
    goto, closing
endif

;---- KEYWORDS -------------
if not keyword_set(xrange) then xrange=minmax(vinput)
if not keyword_set(mini) then mini = xrange(0) ;min(vinput(ind)) 
if not keyword_set(maxi) then maxi = xrange(1) ;max(vinput(ind)) 
if not keyword_set(bin) then bin=1
if not keyword_set(psym) then psym=10
if not keyword_set(gcolor) then gcolor=10

;-- COMPUTE HISTOGRAM ----
if not keyword_set(weight) and not keyword_set(log) then begin
    tempo = histogram(vinput, min=mini, max=maxi, bin=bin)  
    nbvalues = n_elements(tempo)
    xvec = findgen(nbvalues)*bin+mini
    histo = 1.d*tempo
    binv=replicate(bin, n_elements(tempo))
    tempo = 0.
endif else begin
   if keyword_set(log) then begin
      nbvalues = fix(1.*(alog10(maxi)-alog10(mini)) / bin )
      if not keyword_set(weight) then weight = replicate(1., nbvalues)
      xvec = logindgen(nbvalues, mini, maxi)
      binv = shift(xvec, -1)-xvec
      binv(nbvalues-1) = binv(nbvalues-2)
   endif else begin
      nbvalues = fix(1.*(maxi-mini) / bin )
      binv = replicate(bin, nbvalues)
      xvec = findgen(nbvalues)*binv+mini
   endelse
   histo = dblarr(nbvalues)      
   for i=0, nbvalues-1 do begin
      ind = where(vinput ge xvec(i) and vinput lt xvec(i)+binv(i), nbind)
      if (nbind gt 0) then histo(i)=total(weight(ind))
   endfor
endelse
if keyword_set(areanorm) then begin
   histo=1.*histo/total(histo)
endif else begin
   if keyword_set(normal) then histo=1.*histo/max(histo)
endelse


;---- PLOT HISTOGRAM -----
ind = sort(xvec)

x = fltarr(2*n_elements(xvec)+2)
xtempo = xvec(ind)
x(0) = xtempo(0)-binv[0]/2.

y = fltarr(2*n_elements(xvec)+2)
ytempo = histo(ind)
y(0) = !Y.CRANGE[0]

for i=0., n_elements(xvec)-1 do begin
    x(2*i+1) = xtempo(i)-binv[i]/2.
    x(2*i+2) = xtempo(i)+binv[i]/2.
    y(2*i+1:2*i+2) = ytempo(i)
endfor
x(2*n_elements(xvec)+1) =  xtempo(n_elements(xvec)-1)+binv[n_elements(xvec)-1]/2.
y(2*n_elements(xvec)+1) =  !Y.CRANGE[0]


;---- SET X and Y RANGES----------
if not keyword_set(yrange) then begin
    yrange=[0., max(histo)]
    if keyword_set(ylog) then BEGIN
       IF keyword_set(normal) THEN yrange(0) = min(histo(where(histo NE 0.))) ELSE yrange(0) = 1
    endif
endif

if not keyword_set(noplot) then begin
   if keyword_set(oplot) then oplot, x, y, psym=psym, _extra=extra else $
      plot, x, y, /xs, /ys, psym=psym, yrange=yrange, xrange=xrange, _extra=extra, ylog=ylog
   if keyword_set(fill) then begin
      POLYFILL, x>xrange(0)<xrange(1), y>yrange(0)<yrange(1), color=fcolor, _extra=extra
      oplot, x, y
;    if not keyword_set(oplot) then axis, 0, 0, xax=0, /data, xr=xr, /xs
   endif
endif

;--- OVERPLOT GAUSS -----
if keyword_set(gauss) then begin
    yfit = gaussfit(xvec, histo, coeff, nterms=3)
    if not keyword_set(silent) then print, 'Gaussian coefficients: ', coeff
    if not keyword_set(noplot) then oplot, xvec, yfit, color=gcolor, _Extra=extra
endif

if keyword_set(lnormal) then begin
    yfit = gaussfit(alog(xvec), histo, coeff, nterms=3)
    yfit = coeff[0]*exp(-1*(alog(xvec)-coeff[1])^2/(2*coeff[2]^2))
    IF NOT KEYWORD_SET(SILENT) THEN print, 'lognormal coefficients: ', coeff
    if not keyword_set(noplot) then oplot, xvec, yfit, color=gcolor, _Extra=extra
endif


closing:

end
