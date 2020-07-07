function mgauss, x, a

nbcomp = fix(n_elements(a)/3.)

y = fltarr(n_elements(x))
for i=0, nbcomp-1 do begin
   if (a(3*i+2) > 0.) then y = y +  1.d*(a(3*i)*exp(-((x-a(3*i+1))/a(3*i+2))^2/2.))
endfor

if (n_elements(a)-nbcomp*3) gt 0 then y = y+a(3*nbcomp)

return, y

end

