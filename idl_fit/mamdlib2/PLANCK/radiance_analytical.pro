function radiance_analytical, tau, t, beta, nu0=nu0

if not keyword_set(nu0) then nu0=353 ; GHz
nu0_Hz = nu0*1.e9 ; Hz

k = 1d*1.38e-16  ; erg K-1
h = 1d*6.63e-27  ; erg s
; c = 1d*2.997e10  ; cm s-1

; Stefan-Boltzmann constant = 2 PI^5 k^4 / 15 h^3 c^2
sigma_s = 5.67e-5 ; erg cm^-2 s-1 K-4

; Factorial term
fact_3_plus_beta = factorial(3+beta)

; Rieman zeta function term
range_beta = [la_min(beta), la_max(beta)]
if (range_beta[1] gt range_beta[0]) then begin
   dbeta = 0.01
   nbeta = (range_beta[1]-range_beta[0])/dbeta+1
   vecbeta = findgen(nbeta)*dbeta+range_beta[0]
   vec_zeta_4_plus_beta = zeta(4+vecbeta)
   zeta_4_plus_beta = interpol(vec_zeta_4_plus_beta, vecbeta, beta)
endif else begin
   zeta_4_plus_beta = zeta(4+beta)
endelse

; Radiance
R = 1.5e-2 * tau * sigma_s * T^4 * ( k*T/h/nu0_Hz )^beta * fact_3_plus_beta * zeta_4_plus_beta / !PI^5 ; W m^-2 sr^-1

return, R

end
