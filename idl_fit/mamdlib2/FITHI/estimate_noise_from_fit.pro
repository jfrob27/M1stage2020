function estimate_noise_from_fit, c, result

si = size(c)
x = findgen( si(3) )
noise = fltarr(si(1), si(2))
noise(*) = -32768.
nbgauss = (size(result))(3)/3.
avec = findgen(nbgauss)*3
for j=0, si(2)-1 do begin
   for i=0, si(1)-1 do begin      
      spec = reform(c(i,j,*))
      good = where(spec ne -32768., nbgood)
      amp = result(i,j,avec)
      ind = where(amp ne -32768., nbcomp)
      if (nbgood gt 0 and nbcomp gt 0) then begin
         aguess = reform(result(i,j,*))
         model = mgauss(x, aguess)
         residu = spec[good] - model[good]
         
         noise[i,j] = robust_sigma(residu)
;          tmp = statmamd(residu, 1)
;          xr = range(residu, 0.3)
;          bin = sqrt(tmp[1])/5.
;          reshisto = histogram(residu, min=xr[0], max=xr[1], bin=bin)
;          nbvalues = n_elements(reshisto)
;          xvec = findgen(nbvalues)*bin+xr[0]
;          histo = 1.d*reshisto
;          yfit = gaussfit(xvec, histo, coeff, nterms=3)
;          noise[i,j] = coeff[2]
;          if (coeff[2] le 0.) then noise[i,j] = sqrt(tmp[1])
      endif
   endfor
endfor

return, noise

end
