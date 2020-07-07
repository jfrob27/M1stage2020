function pdfincr_im2, image, lag, values

sim = size(image)
w = fltarr(sim(1), sim(2))
result = fltarr(sim(1), sim(2))
values = [0.]

xymap, 2*(lag+1.)+1., 2*(lag+1)+1., sxmap, symap
sxmap = sxmap-(lag+1)
symap = symap-(lag+1)
distance = sqrt(sxmap^2+symap^2)
indice = where((distance ge lag-0.5) and (distance lt lag+0.5) and sxmap gt 0., nbind)

for i = 0, nbind-1 do begin
    a = sxmap(indice(i))
    b = symap(indice(i))
    image2 = shift(image, a, b)
    if a lt 0 then begin
        a1 = sim(1)-1+a
        a2 = sim(1)-1
    endif else begin
        a1 = 0.
        a2 = a
    endelse
    if b lt 0 then begin
        b1 = sim(2)-1+b
        b2 = sim(2)-1
    endif else begin
        b1 = 0.
        b2 = b
    endelse
    image2(a1:a2,*) = -32768.
    image2(*,b1:b2) = -32768.
    
    ind = where(image2 ne -32768 and image ne -32768)
    w(ind) = w(ind)+1.
    result(ind) = result(ind) + abs(image(ind)-image2(ind))
    values = [values, image(ind)-image2(ind)]
endfor

values = values(1:*)

ind = where(w gt 0.)
result(ind) = result(ind)/w(ind)

ind = where(w eq 0.)
result(ind) = -32768.

return, result

end
    
