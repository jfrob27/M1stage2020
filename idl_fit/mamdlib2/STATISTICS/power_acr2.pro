pro power_acr2, image, power, kvec, lag_max=lag_max, indef=indef, reso=reso, acr2d=acr2dim, median=median

si_im = size(image)

if not keyword_set(lag_max) then lag_max = min(si_im(1:2))/2.
if not keyword_set(indef) then indef=-32768
if not keyword_set(reso) then reso=1.

res = acr1d(image, lag_max, indef=indef, acr2dim=acr2dim, dl=1)
acr = [rotate(reform(res(1,*)), 2), reform(res(1,*))]
power = abs(fft(acr))
power = power(0:lag_max-1)
kvec = (findgen(lag_max)+1)/(2*lag_max)/reso

end



;acr2d, image, lag_max, resacr2d, nbpoint_out, indef=indef
;acr2d = resacr2d(lag_max:*, lag_max:*)
;fft2d = complexarr(lag_max+1, lag_max+1)
;xymap, lag_max+1, lag_max+1, l1, l2
;for j=0, lag_max do begin & $
;  print, j & $
;  for i=0, lag_max do begin & $
;    fft2d(i,j) = total(exp(complex(0.,(2*!pi*l2*j/lag_max))) * $
;                       exp(complex(0.,(2*!pi*l1*i/lag_max))) * $
;                       acr2d) & $
;  endfor & $
;endfor
