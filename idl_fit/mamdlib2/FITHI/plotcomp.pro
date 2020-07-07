pro plotcomp, result, comp, nbcomp, psym=psym, _extra=Extra

if not keyword_set(psym) then psym=3

num = reverse(sort(histogram(comp,min=1)))+1
if not keyword_set(nbcomp) then nbcomp = 15

nbgauss = (size(result))[3]/3.

allsig = result(*,*,findgen(nbgauss)*3+2)
allcent = result(*,*,findgen(nbgauss)*3+1)
for i=0, nbcomp-1 do begin
   ind = where(comp eq num(i))
   col=256/16.*i
   if (i eq 0) then plot, allcent(ind), allsig(ind), psym=psym, _extra=Extra else oplot, allcent(ind), allsig(ind), psym=psym, col=col, _extra=Extra
   xyouts, 0.9, 0.9-i*0.03, strc(i), col=col, /normal
   print, i, num(i), [minmax(allcent(ind)), minmax(allsig(ind))]
endfor


nbx = floor(sqrt(nbcomp))
nby = ceil(1.*nbcomp/nbx)
pos = multipos(nbx, nby)
window, 2
for i=0, nbcomp-1 do begin
   ind = where(comp eq num(i))
   if (i lt nbx) then xchars=-1 else xchars=1.e-6
   plot, allcent(ind), allsig(ind), psym=psym, position=pos(*,i), title=strc(i), $
         xchars=xchars, _extra=Extra, /noerase
endfor


end
