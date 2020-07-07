function gauss_mpfit, a, XVAL=x, YVAL=y, ERRVAL=err, model_out=model_out

;-----------------------------------------
;
; GAUSS_MPFIT.PRO
;
; fonction gaussienne avec 3 composantes utilisable par MPFIT
;
; MAMD 18/05/1999
;
;------------------------------------------

if not keyword_set(err) then begin
    err = x
    err(*) = 1.
endif

model = mgauss(x, a)

if keyword_set(model_out) then return, model else begin
;   vec = 3*findgen(n_elements(a)/3.)
;   area = a(vec)*a(vec+2)
;   rien = where(area ge 5*err(0), nbparam)
;   nbfree = n_elements(x)-nbparam
;   res = (y-model)/err/nbfree
   res = (y-model)/err
   return, res
endelse

end
