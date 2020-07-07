function linindgen, nb, minv, maxv

;
; Create a findgen with linearly-spaced values
;
; MAMD 30/03/2004

dx = maxv-minv
x = (findgen(nb))/(nb-1.)*dx+minv

return, x

end
