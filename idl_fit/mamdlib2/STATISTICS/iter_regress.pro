function iter_regress, x, y, nbiter=nbiter, const=const, sigma=sigma, good=good, guess=guess, _Extra=extra
if not keyword_set(nbiter) then nbiter=1

if keyword_set(guess) then begin
   diff = y-(x*guess[1] + guess[0])
   ss = robust_sigma(diff)
   good = where(abs(diff) lt 3*ss)
endif else begin
   good = lindgen(n_elements(x))
endelse

for i=0, nbiter-1 do begin
   res = regress(x[good], y[good], const=const, sigma=sigma, _Extra=extra)
   diff = y-(x*res[0] +const)
   ss = robust_sigma(diff)
;   phisto, diff, bin=0.01, /gauss, coeff=coeff, /silent
   good = where(abs(diff) lt 3*ss)
endfor

return, res


end
