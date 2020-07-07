function totalspectrum, x, amp, cent, sig

n = n_elements(amp)
result = fltarr(n_elements(x))
for i=0L, n-1 do begin
   g = mgauss(x, [amp[i], cent[i], sig[i]])
   result = result+g
endfor

return, result

end
