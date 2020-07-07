function dustcolor, lambda1, lambda2, ratio, beta=beta

;-----------------------------------------------
; Compute the dust temperature for the ratio of two wavelength
;
; lambda1 : first wavelength (in micron)
; lambda2 : second wavelength (in micron)
; ratio : ratio of B(lambda1)/B(lambda2)
; beta : spectral index (default is beta=2)
;
; result = dust temperature (in K)
;
; MAMD, 21/01/2005
;------------------------------------------------

if not keyword_set(beta) then beta=2

T = dindgen(500)*0.1+5.
B1 = 1. / ((1.d*lambda1)^(3+beta) * (exp(14387.7/lambda1/T) - 1.))
B2 = 1. / ((1.d*lambda2)^(3+beta) * (exp(14387.7/lambda2/T) - 1.))
r = B1/B2
res = interpol(T, R, ratio)

return, res

end
