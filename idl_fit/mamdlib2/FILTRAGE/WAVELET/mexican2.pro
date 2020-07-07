function mexican2, xsize, ysize, teta, scale, a=a, b=b

;-----------------------------------------------------------
; 
; MEXICAN
;
; Compute a 2D Mexican Hat function of size (XSIZE, YSIZE) and scale A
;
; keyword:
;
;  AXE_RATION: rapport d'axe A/B
;
;---------------------------------------------------------


if not keyword_set(a) then a=1.
if not keyword_set(b) then b=1.

j = scale
mex = fltarr(xsize, ysize)
;if (j le 0.) then begin
    xymap, xsize, ysize, x, y
    x = (x-fix(xsize/2.))
    y = (y-fix(ysize/2.))
    mat_x = 2^(1.*j)*x
    mat_y = 2^(1.*j)*y
    x=1d*((mat_x*cos(teta))+(mat_y*sin(teta)))
    y=1d*(-(mat_x*sin(teta))+(mat_y*cos(teta)))
    mag = sqrt((a*x)^2 + (b*y)^2)
    mex = (2.-mag^2)*exp(-1.d*mag^2/2.)
    ind = where(abs(mex) lt 1.e-8, nbind)
    if (nbind gt 0) then mex(ind) = 0.
    if (j eq 1) then begin
        mex = mex-avg(mex)
    endif
;mex = 2^(1.*j/2.)*mex
;mex = 0.185*2^(2.*j)*mex
    mex = 2^(2.*j)*mex
;endif 
;if (j eq 1) then begin
;    noyau = reform([0., -0.25, 0., -0.25, 1., -0.25, 0., -0.25, 0.], 3,3 )
;    mex(fix(xsize/2.)-1:fix(xsize/2.)+1, fix(ysize/2.)-1: fix(ysize/2.)+1) = noyau
;endif

print, total(mex)

;stop

;mex = mex-avg(mex)
norm = total(abs(mex))
mex = 1.73*mex/norm

;------------------------
; CALCUL DE LA CONSTANTE

;xymap, xsize, ysize, kx, ky
;kx = (kx-xsize/2.)/(xsize/2.)
;ky = (ky-ysize/2.)/(ysize/2.)
;k2 = kx^2 + ky^2 
;mexfft = shift(fft(mex, 1), fix(xsize/2.), fix(ysize/2.))
;ind = where(k2 ne 0.)
;const = (2*!pi)^2*total(abs(mexfft(ind))^2/k2(ind))
;print, const

return, mex

end
