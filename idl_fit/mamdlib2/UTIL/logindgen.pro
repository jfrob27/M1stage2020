function logindgen, nb, minv, maxv

;
; Create a findgen with log-spaced values
;
; MAMD 11/11/2003

eminv = alog10(minv)
emaxv = alog10(maxv)
dx = emaxv-eminv
x = (findgen(nb))/(nb-1.)*dx+eminv
x = 10.^x

return, x

end
