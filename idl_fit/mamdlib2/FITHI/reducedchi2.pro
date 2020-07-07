function reducedchi2, c, result, noise, gbt=gbt

si = size(c)
x = findgen( si(3) )
chi2 = fltarr(si(1), si(2))
chi2(*) = -32768.
nbgauss = (size(result))(3)/3.
avec = findgen(nbgauss)*3
for j=0, si(2)-1 do begin
   for i=0, si(1)-1 do begin
      amp = result(i,j,avec)
      ind = where(amp ne -32768., nbcomp)
      if (nbcomp gt 0) then begin
         aguess = reform(result(i,j,*))
         model = mgauss(x, aguess)
         spec = reform(c(i,j,*))
         good = where(spec ne -32768., nbgood)
         nbfree = nbgood-3*nbcomp
         n = noise[i,j]
         if keyword_set(gbt) then n = n*(1+model/20.)
         if (nbgood gt 0) then chi2(i,j) = total( (spec[good]-model[good])^2 / n[good]^2) / nbfree
      endif
   endfor
endfor

return, chi2

end

