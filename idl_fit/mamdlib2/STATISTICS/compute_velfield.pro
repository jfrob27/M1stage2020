pro compute_velfield, cube, bruit, velfieldu, snramapu, ntotu, nbu, dc, sigmavelu, dv=dv, V0=V, maxsnr=maxsnr, seuil=seuil, $
                      nb=nb, vitesse=vitesse

if not keyword_set(nb) then nb=10.     ; minimum number of consecutive channels to be considered as a spectral feature
si_cube = size(cube)
if not keyword_set(seuil) then seuil = 2.                            
if not keyword_set(dv) then dv = 1.                                  ;dv=-0.412
;if not keyword_set(V) then V = -1.*si_cube(3)/2.              ;V=19.364
if not keyword_set(V) then V = 0.

if not keyword_set(vitesse) then vitesse = findgen(si_cube(3))*dv + V
print, v, dv, minmax(vitesse)

velfieldU = fltarr(si_cube(1),si_cube(2))
velfieldU(*,*) = -32768
snramapU = velfieldU
ntotU = velfieldU
NbU = velfieldU
sigmavelU=velfieldU
avgV = velfieldU
qvi = velfieldU
for j=0, si_cube(2)-1 do begin 
    print, j 
    for i=0, si_cube(1)-1 do begin 
        if (bruit(i,j) gt 0.) then begin 
            vev = reform(cube(i,j,*)) 
            vev = vev-median(vev(0:10)) 
;  vevs = median(vev, 5) 
;  vevs = smooth_slice(vev, 5, /median) 
            if keyword_set(maxsnr) then begin 
                ind = maxsnra(vev, bruit(i,j), snra) 
                nbind = n_elements(ind) 
            endif else begin 
                vevs = clean_spectrum(vev, seuil*bruit(i,j), nb)

;if j gt 0 and i gt 2 then begin
;    plot, vev
;    oplot, vevs, col=10
;    stop
;endif
                ind = where(vevs ne -32768., nbind)
;                vevs = smooth(vev, 5, /edge) 
;                ind = where(vevs gt 3*bruit(i,j), nbind) 
            endelse 
            if (nbind gt 0.) then begin 
                velfieldU(i,j) =  total(vitesse(ind)*vev(ind))/total(vev(ind)) 
                ntotU(i,j) =  total(vev(ind)) 
                avgV(i,j) = avg(vitesse(ind))
                NbU(i,j) = n_elements(ind) 
                qvi(i,j) = sqrt( avg( (vitesse(ind) - avgV(i,j))^2 ) )
                snramapU(i,j) = ntotU(i,j)/(sqrt(nbu(i,j))*bruit(i,j)) 
                sigmavelu(i,j) = total((vitesse(ind)-velfieldU(i,j))^2*vev(ind))/total(vev(ind)) 
;                sigmavelu(i,j) = total((vitesse-velfieldU(i,j))^2*vev)/total(vev) 
;  snramapU(i,j) = snra 
            endif 
        endif 
    endfor 
endfor

;dc = 0.91*0.29*Nbu*dv*sqrt(1+(snramapu^2/(snramapu^2-0.91^2))*((V-velfieldu)/(0.29*Nbu*dv))^2)/sqrt(snramapu^2-0.91^2)
;dc = 0.91*0.29*Nbu*dv*sqrt(1+(snramapu^2/(snramapu^2-0.91^2))*((avgV-velfieldu)/(0.29*Nbu*dv))^2)/sqrt(snramapu^2-0.91^2)
dc = 0.91*qvi*sqrt(1+(snramapu^2/(snramapu^2-0.91^2))*((avgV-velfieldu)/(qvi))^2)/sqrt(snramapu^2-0.91^2)

end
