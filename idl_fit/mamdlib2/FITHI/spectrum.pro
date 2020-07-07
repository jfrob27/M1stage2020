function spectrum, densite, vitesse, T=T, dv=dv, depth=depth, velvec=velvec, vsize=vsize, nogauss=nogauss, grad=grad

nb = n_elements(densite)
if not keyword_set(T) then T = 150. ; gas temperature
if n_elements(t) eq 1 then T = replicate(t, nb)
if not keyword_set(dv) then dv=1./3. ; channel width in km/s - default is 0.33 km/s
if not keyword_set(depth) then depth=3.09e18 ; depth of the line of sight (in cm) - default is 1 pc

if not keyword_set(velvec) then begin
    if not keyword_set(vsize) then vsize=nb 
    velvec =  (findgen(vsize)-vsize/2.) * dv 
end else begin
    vsize = n_elements(velvec)
endelse
result =  fltarr(vsize)         ; initialize result

kplanck =  1.39e-23             ; Boltzmann constant
m =  1.67e-24                   ; proton mass
sig_therm = sqrt(kplanck*t/1.e3 / m) ; thermal velocity dispersion in km/s
dz = 1.*depth / nb ; depth of a single cell on the line of sight (in cm)

for k=0, nb-1 do begin 
    if not keyword_set(nogauss) then begin
        vz = velvec + vitesse(k)
        if keyword_set(grad) then begin
            nb_grad = 0.
            if k gt 0 then begin
                grad_v_1 = vitesse(k) - vitesse(k-1)
                nb_grad = nb_grad+1.
            endif else grad_v_1 = 0.
            if k lt nb-1 then begin
                grad_v_2 = vitesse(k+1) - vitesse(k)
                nb_grad = nb_grad+1.
            endif else grad_v_2 = 0.
            grad_v = ( grad_v_1 + grad_v_2 ) / nb_grad
        endif else grad_v = 0.
        sig = sqrt( sig_therm(k)^2 + grad_v^2 )
        if sig ne 0. then begin
            tempo = exp(-1.d*(vz - vitesse(k))^2/(2.*sig^2)) 
            tempo = tempo / total(tempo) * densite(k) * dz / 1.823e18 
            gauss_k = interpol( tempo, vz, velvec )
        endif else gauss_k = 0.
        result = result +  gauss_k 
    endif else begin
        rien = min(abs(velvec-vitesse(k)), indmin)
        result(indmin(0)) = result(indmin(0)) + densite(k) * dz / 1.823e18
    endelse
endfor

return, result / dv

end
