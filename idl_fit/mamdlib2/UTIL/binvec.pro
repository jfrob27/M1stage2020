pro binvec, vec1, vec2, xvec, avgvec, stdvec, xrange=xrange, nbbin=nbbin, log=log, $
            ndata=ndata, median=median, equalnumber=equalnumber, xlimit=x, percent=percent, $
            robustsigma=robustsigma, maximum=maximum

if not keyword_set(nbbin) then nbbin = 100
if not keyword_set(xrange) then xrange=minmax(vec1)
if keyword_set(median) then med=1
if not keyword_set(percent) then percent=0.

if keyword_set(equalnumber) then begin
   ind_limit = where(vec1 ge xrange[0] and vec1 le xrange[1], nb)
   ind = sort(vec1[ind_limit])
   nb_in_bin = round(nb / nbbin)
   x = fltarr(nbbin+1)
   for i=0, nbbin-1 do x[i] = vec1[ind_limit[ind[i*nb_in_bin]]]
   x[nbbin] = xrange[1]
endif else begin
   if keyword_set(log) then x = logindgen(nbbin+1, xrange[0], xrange[1]) else $
      x = linindgen(nbbin+1, xrange[0], xrange[1])
endelse

xvec = fltarr(nbbin)
avgvec = fltarr(nbbin)
stdvec = fltarr(nbbin)
ndata = lonarr(nbbin)

for i=0, nbbin-1 do begin
   ind = where(vec1 ge x[i] and vec1 lt x[i+1], nbind )
   xvec[i] = (x[i]+x[i+1])/2.
   if (nbind gt 1) then begin
      stat = statmamd(vec2[ind], percent, median=med)
      avgvec[i]=stat[0]
      if keyword_set(median) then avgvec[i] = med 
      if keyword_set(maximum) then avgvec[i] = max(vec2[ind])
      if keyword_set(robustsigma) then begin
         stdvec[i] = robust_sigma(vec2[ind])
      endif else begin         
         stdvec[i] = sqrt(stat[1])
      endelse
;      if keyword_set(median) then avgvec[i] = median(vec2[ind]) else avgvec[i] = avg(vec2[ind])  
;      stdvec[i] = stddev(vec2[ind])
   endif
   if (nbind eq 1) then avgvec[i] = vec2[ind[0]]
   ndata[i] = nbind
endfor

end
