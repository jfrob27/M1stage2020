function acr1d_test, image, lagmax, nbpoint=nbpoint

si_im = size(image)
acr = fltarr(lagmax)
nbpoint = fltarr(lagmax)
acr(0) = (la_sigma(image))^2

xymap, si_im(1), si_im(2), xmap, ymap

dl = 0.5
for k=1, lagmax-1 do begin 
    for j = 0, si_im(2)-1 do begin
        print, k, j
        for i=0, si_im(1)-1 do begin
            dist = sqrt((xmap-i)^2 + (ymap-j)^2)
            ind = where(dist gt k-dl and dist le k+dl, nbind)
            if (nbind gt 0) then begin
                nbpoint(k) = nbpoint(k)+nbind
                acr(k) = acr(k)+total(image(i)*image(ind))
            endif
        endfor
    endfor
endfor

acr = acr/nbpoint
return, acr

end
