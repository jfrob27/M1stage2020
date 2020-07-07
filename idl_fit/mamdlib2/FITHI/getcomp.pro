pro getcomp, result, comp, test, _extra=Extra, nbcomp=nbcomp

;if not keyword_set(test) then test = componentfind(result, _extra=Extra)
;componentfind2, result, test, _extra=Extra
;dsigmin=0.1, /sigpercent, dcent=0.5, distmin=5.)

num = reverse(sort(histogram(test,min=1)))+1
if not keyword_set(nbcomp) then nbcomp = 15
;x = findgen(131)
si = size(result)
nbgauss = si[3]/3.
comp = fltarr(si(1), si(2), nbcomp)

for i=0, nbcomp-1 do begin
   print, i
   tempo = result
   mask = test
   mask(*) = 0.
   ind = where(test eq num(i))
   mask(ind) = 1.
   for j=0, nbgauss-1 do comp(*,*,i) = comp(*,*,i) + tempo(*,*,3*j)*mask(*,*,j)*tempo(*,*,3*j+2)*sqrt(2*!pi)
;   for j=0, nbgauss-1 do tempo(*,*,3*j) = tempo(*,*,3*j)*mask(*,*,j)
;   tempo2 = tbfromfit(tempo, x)
;   comp(*,*,i) = la_tot(tempo2, dim=-1)
endfor
end
