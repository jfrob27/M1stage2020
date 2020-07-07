function fithi_chisq, data, result, x=x, noise=noise

sidata = size(data)

if not keyword_set(x) then x = findgen(sidata(3))
if not keyword_set(noise) then noise = la_sigma(data(*,*,0:10), dim=-1)
output = fltarr(sidata(1), sidata(2))
output(*) = -32768.

for j=0, sidata(2)-1 do begin
   for i=0, sidata(1)-1 do begin
      if (noise(i,j) gt 0.) then begin
         spectrum = data(i,j,*)
         a = result(i,j,*)
         model = mgauss(x, a)
         nbfree = sidata(3) - n_elements(a)
         output(i,j) = total( (spectrum-model)^2 ) / noise(i,j)^2 / nbfree
      endif
   endfor
endfor

return, output

end
