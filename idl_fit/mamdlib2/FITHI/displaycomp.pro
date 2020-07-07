pro displaycomp, result, comp, nbcomp, _extra=Extra

if not keyword_set(psym) then psym=3

num = reverse(sort(histogram(comp,min=1)))+1
if not keyword_set(nbcomp) then nbcomp = 15

si = size(result)
nbgauss = si[3]/3.

allamp = result(*,*,findgen(nbgauss)*3)
allcent = result(*,*,findgen(nbgauss)*3+1)
allsig = result(*,*,findgen(nbgauss)*3+2)
ntot = la_mul(allamp, allsig)
mask = intarr(si(1), si(2), nbgauss)

nbx = floor(sqrt(nbcomp))
nby = ceil(1.*nbcomp/nbx)
pos = multipos(nbx, nby)

for i=0, nbcomp-1 do begin
   ind = where(comp eq num(i))
   title = 'cent: ' + strc(min(allcent(ind)), format='(F5.1)') + ';' + strc(max(allcent(ind)), format='(F5.1)') + $
           ' sig: ' + strc(min(allsig(ind)), format='(F5.1)') + ';' + strc(max(allsig(ind)), format='(F5.1)')
   mask(*) = 0
   mask(ind) = 1
   map = la_tot(la_mul(ntot, mask), dim=-1)
;   map = la_max(la_mul(allsig, mask), dim=-1)
   if (i eq 0) then position=pos(*,i) else position=pos(0:1,i)
   imaffi, map, position=position, _extra=Extra, /cadrenu, title=title
   print, i, num(i), [minmax(allcent(ind)), minmax(allsig(ind))]
endfor

end
