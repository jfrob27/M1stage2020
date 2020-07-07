pro power_acr, image, power, kvec, lag_max=lag_max, indef=indef, reso=reso, acr2d=resacr2d, median=powermed, $
               power1d=power1d, acr1d=acr2

si_im = size(image)

if not keyword_set(lag_max) then lag_max = fix(min(si_im(1:2))/2.)
if not keyword_set(indef) then indef=-32768
if not keyword_set(reso) then reso=0.

;acr2d, image, lag_max, resacr2d, nbpoint_out, indef=indef
res = acr1d(image, lag_max, indef=indef, acr2dim=resacr2d, dl=1)
acr = [rotate(reform(res(1,1:*)), 2), reform(res(1,*))]

;n = ceil(alog(n_elements(acr))/alog(2.))
;n = 2.^n
;acr2 = fltarr(n)
;dx = fix((n-n_elements(acr))/2.)
;acr2(dx:dx+n_elements(acr)-1) = acr
acr2 = acr
power1d = abs(fft(acr2))
power1d = power1d(0:lag_max-1)
;resacr2d = resacr2d-sfit(resacr2d, 3)
;good_ps, resacr2d, power, kvec, reso=reso, med=powermed, /rem

resacr2d1 = resacr2d
tempo = resacr2d1(lag_max+1:*, lag_max+1:*)
resacr2d1(0:lag_max-1,0:lag_max-1) = rotate(tempo, 2)
resacr2d1(0:lag_max-1,lag_max+1:*) = rotate(tempo, 5)
resacr2d1(lag_max+1:*,0:lag_max-1) = rotate(tempo, 7)
good_ps, resacr2d1, power1, kvec, reso=reso, med=powermed

resacr2d1 = resacr2d
tempo = resacr2d(0:lag_max-1, lag_max+1:*)
resacr2d1(0:lag_max-1,0:lag_max-1) = rotate(tempo, 7)
resacr2d1(lag_max+1:*,lag_max+1:*) = rotate(tempo, 5)
resacr2d1(lag_max+1:*,0:lag_max-1) = rotate(tempo, 2)
good_ps, resacr2d1, power2, kvec, reso=reso, med=powermed

power = (power1+power2)/2.
power = sqrt(power)*lag_max
powermed = sqrt(powermed)*lag_max


;kvec = (findgen(lag_max)+1)/(2*lag_max)/reso

end


