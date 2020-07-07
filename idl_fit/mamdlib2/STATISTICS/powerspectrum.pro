function powerspectrum, image, nb_k=nb_k, maxlag=maxlag, lag=disvec, weight=weight

;----------------------------------------------------------
;
; POWERSPECTRUM
;
;----------------------------------------------------------

si_image = size(image)

toto = (abs(fft(image)))^2
image_ft = shift(toto, fix(si_image(1)/2.), fix(si_image(2)/2.))

X = fltarr(si_image(1), si_image(2))
Y = fltarr(si_image(1), si_image(2))
for i=0, si_image(2)-1 do X(*,i) = findgen(si_image(1))-fix(si_image(1)/2.)
for i=0, si_image(1)-1 do Y(i,*) = findgen(si_image(2))-fix(si_image(2)/2.)

distance = sqrt(X^2 + Y^2)
lag = distance(UNIQ(distance, sort(distance)))
weight = fltarr(n_elements(lag))

pas = findgen(nb_k)+1.
if not keyword_set(maxlag) then maxlag = float(max(distance))
norm = total(2*pas)/float(maxlag)
pas = pas/norm
disvec = fltarr(nb_k)
result = fltarr(nb_k)
weight = fltarr(nb_k)
disvec(0) = pas(0)

for i=1, nb_k-1 do begin
    disvec(i) = disvec(i-1)+pas(i-1)+pas(i)
    indice = where(distance ge disvec(i)-pas(i) and distance lt disvec(i)+pas(i), nb_found)
    if (nb_found gt 0) then begin
        result(i) = total(image_ft(indice))/float(nb_found)
        weight(i) = float(nb_found)
    endif
endfor

result(0) = max(image_ft)
;stop

return, result

end





