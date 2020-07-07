function syntres, result, dsigma=dsigma, dcentroid=dcentroid, xrange=xrange, sigrange=sigrange, centrange=centrange, ylog=ylog
  
; this produce a synthetic view of the result : a 2D array which shows
; the area of the components in the sigma-centroid plane

if not keyword_set(dsigma) then dsigma=0.1
if not keyword_set(dcentroid) then dcentroid=0.1

si = size(result)
nbcomp = si(3)/3.

allsig = result(*,*,findgen(nbcomp)*3+2)
allcent = result(*,*,findgen(nbcomp)*3+1)
allamp = result(*,*,findgen(nbcomp)*3)

if not keyword_set(xrange) then xrange = [0, max(allcent)]
x = findgen(xrange[1]-xrange[0])+xrange[0]

ind = where(allsig ne -32768., nbind)
allsig = allsig(ind)
allcent = allcent(ind)
allamp = allamp(ind)

if not keyword_set(sigrange) then sigrange = minmax(allsig)
if not keyword_set(centrange) then centrange = minmax(allcent)

nby = fix( (sigrange(1)-sigrange(0))/dsigma )
nbx = fix( (centrange(1)-centrange(0))/dcentroid )

sigvec = findgen(nby)*dsigma+sigrange(0)
if keyword_set(ylog) then sigvec = logindgen(nby, sigrange[0], sigrange[1])
centvec = findgen(nbx)*dcentroid+centrange(0)

output = fltarr(nbx, nby)
for i=0L, nbind-1 do begin
   rien = min(abs(sigvec-allsig(i)), wy)
   rien = min(abs(centvec-allcent(i)), wx)
   if (wx gt 0 and wx lt nbx and wy gt 0 and wy lt nby) then begin
      nh = total(mgauss(x, [allamp(i), allcent(i), allsig(i)]))
      output(wx,wy) = output(wx,wy)+nh
   endif
endfor

return, output

end
