function reglin, x, y, dy, coeff=coeff, dcoeff=dcoeff, chi2=chi2, $
                 covariance=covariance, goodness=goodness

; taken from Numerical Recipes in C, second edition, page 661-664

if not keyword_set(dy) then begin
    dy = 1.
    nody = 1
endif else nody = 0
if N_ELEMENTS(dy) eq 1 then dy = replicate(dy, n_elements(y))


; Compute intermediate quantities
S = total(1/dy^2)
Sx = total(x/dy^2)
Sy = total(y/dy^2)
Sxx = total((x/dy)^2)
Sxy = total(x*y/dy^2)
delta = S*Sxx - Sx^2

; Compute linear regression parameters
a = (Sxx*Sy - Sx*Sxy) / delta
b = (S*Sxy - Sx*Sy) / delta
coeff = [a, b]
model = a+ b*x

; Compute error on linear regression parameters
da = sqrt( Sxx / delta )
db = sqrt( S / delta )

; Compute chi square
chi2 = total( ( (y - a - b*x) / dy )^2 )

;  Correct error on linear regression parameters in the case where the uncertainties
; on Y values were not given
if nody then begin
    N = n_elements(y)
    factor = sqrt( chi2 / (N-2.) )
    da = da * factor
    db = db * factor
endif
dcoeff = [da, db]

; covariance
covariance = -1.*Sx/delta

; goodness of fit (probability that the measured chi2 could be that high or higher)
if nody then goodness = 1. else goodness = 1. - igamma(0.5*(n_elements(y)-2.), 0.5*chi2, /double)

return, model

end
