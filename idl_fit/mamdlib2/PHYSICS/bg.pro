function colour_correction, ccmaps, tdvec, betavec, t_bg, beta, ind

  ii = interpol(indgen(n_elements(tdvec)), tdvec, T_bg)
  jj = interpol(indgen(n_elements(betavec)), betavec, beta)
  cc = interpolate(ccmaps, ii, jj, ind, /grid)

  return, cc

end



;==================================================================
function bg, x, a, tdvec=tdvec, betavec=betavec, ccmaps=ccmaps, reflambda=x0

; computes modified black body dust spectrum 
;
; x : fltarr; wavelength (micron)
; a : model parameter. 3 values = compute a single beta model, 
;     5 values = two beta model
;     6 values = two modified black bodies
;
; MAMD
; 22/08/2010 : creation
; 15/02/2013 : add colour correction and 2 modified black body model


if not keyword_set(x0) then x0=1.

E_bg = a[0]
T_bg1 = a[1]
beta1 = a[2]
nbparam = n_elements(a)
if (nbparam gt 3) then begin
   beta2 = a[nbparam-1]
   if (nbparam eq 5) then T_bg2 = T_bg1 else T_bg2 = a[4]
endif

; compute colour correction
cc1 = fltarr(n_elements(x))
cc2 = fltarr(n_elements(x))
if keyword_set(tdvec) then begin ; colour correction
   indx = indgen(n_elements(x))
   cc1 = colour_correction(ccmaps, tdvec, betavec, t_bg1, beta1, indx)
   if (nbparam gt 3) then cc2 = colour_correction(ccmaps, tdvec, betavec, t_bg2, beta2, indx)
endif else begin
   cc1[*] = 1.
   cc2[*] = 1.
endelse

; compute model
case nbparam of
   3: begin
;      model = 1.e20*E_bg*x^(-1*Beta1)*bnu_planck(x, T_bg1)      
      model = 1.e20*E_bg*(x/x0)^(-1*Beta1)*bnu_planck(x, T_bg1) 
      model = model*reform(cc1) ; colour correction
   end
   5: begin
      lc = a[3]
      model = dblarr(n_elements(x))
      ind = where(x le lc, nbind, compl=compl, ncompl=ncompl)
      if (nbind gt 0) then begin
         model[ind] = 1.e20*E_bg*x[ind]^(-1*Beta1)*bnu_planck(x[ind], T_bg1)
         model[ind] = model[ind]*reform(cc1[ind]) ; colour correction
      endif
      if (ncompl gt 0) then begin
         E2 = E_bg*lc^(beta2-beta1)
         model[compl] = 1.e20*E2*x[compl]^(-1*Beta2)*bnu_planck(x[compl], T_bg2)
         model[compl] = model[compl]*reform(cc2[compl]) ; colour correction
      endif
   end
   6: begin
      model = 1.e20*E_bg*x^(-1*Beta1)*bnu_planck(x, T_bg1)      
      model = model*reform(cc1)
      E_bg = a[3]
      model2 = 1.e20*E_bg*x^(-1*Beta2)*bnu_planck(x, T_bg2)
      model2 = model2*reform(cc2)
      model = model + model2
   end
endcase

return, model

end

