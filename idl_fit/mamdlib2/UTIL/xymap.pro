pro xymap, xsize, ysize, xima, yima

;xima = intarr(xsize, ysize)
;yima = intarr(xsize, ysize)
;for i=0, xsize-1 do xima(i,*)=i
;for i=0, ysize-1 do yima(*,i)=i

xima = findgen(xsize)#replicate(1,ysize)
yima = replicate(1,xsize)#findgen(ysize)

end
