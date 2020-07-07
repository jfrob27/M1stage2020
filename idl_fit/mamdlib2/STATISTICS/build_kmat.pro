function build_kmat, na, nb

;na1 = fix(na/2.)
;na2 = na-na1
;k1d_x = [((findgen(na1)+1.) / na1), reverse((findgen(na2)+1.) / na2)]
;nb1 = fix(nb/2.)
;nb2 = nb-nb1
;k1d_y = [((findgen(nb1)+1.) / nb1), reverse((findgen(nb2)+1.) / nb2)]

;kmat = fltarr(na, nb)
;FOR i=0, nb-1 DO kmat(*,i) =k1d_x
;FOR i=0, na-1 DO kmat(i,*) = kmat(i,*)*k1d_y

xymap, na, nb, xmap, ymap

xmap = xmap - median(xmap)
ymap = ymap - median(ymap)
xmap = 1.*xmap/na
ymap = 1.*ymap/nb
kmat = sqrt(xmap^2 + ymap^2)

return, kmat

end
