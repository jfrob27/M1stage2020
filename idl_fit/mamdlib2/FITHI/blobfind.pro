function blobfind, x, y, dxmin=dxmin, dymin=dymin, ypercent=ypercent, xpercent=xpercent

if not keyword_set(dxmin) then dxmin=1
if not keyword_set(dymin) then dymin=1

nb = n_elements(x)
blobnum =fltarr(nb)

ind = findgen(nb)
nextval = 0
while (ind[0] ne -1) do begin
   good = [ind(0)]
   nextval = nextval+1
   blobnum(good) = nextval
   if (n_elements(ind) eq 1) then ind=-1 else ind = ind(1:*)
   j = 0
   while (j lt n_elements(good) and ind[0] ne -1) do begin
      if keyword_set(ypercent) then dy = dymin*y(good(j)) else dy=dymin
      if keyword_set(xpercent) then dx = dxmin*x(good(j)) else dx=dxmin
      tempo = where(abs(x(ind)-x(good(j))) le dx and abs(y(ind)-y(good(j))) le dy, nbgood, comp=bad, ncomp=nbbad)
      if (nbgood gt 0) then begin
         good = [good, ind(tempo)]
         blobnum(good) = nextval
      endif
      if (nbbad gt 0) then ind = ind(bad) else ind=-1
      j = j+1
   endwhile
endwhile

return, blobnum

end

