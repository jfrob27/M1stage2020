pro gauss, x, a, f, pder

;-----------------------------------------
;
; GAUSS.PRO
;
; fonction gaussienne utilisable par idl
; (entre autre avec curvefit).
;
; Utilise avec FIT_CUBE.PRO
;
; MAMD 7/1/97
;
;------------------------------------------

f = a(0)*exp(-((x-a(1))/a(2))^2/2.)

pder = dblarr(N_ELEMENTS(x), 3)
pder(*,0) = exp(-((x-a(1))/a(2))^2/2.)
pder(*,1) = a(0)*(x-a(1))*exp(-((x-a(1))/a(2))^2/2.)/a(2)^2.
pder(*,2) = a(0)*(x-a(1))^2.*exp(-((x-a(1))/a(2))^2/2.)/a(2)^3.

end
