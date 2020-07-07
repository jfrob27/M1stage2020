pro compute_centroid, spectre, bruit, centroid, snra, ntot, nb, dc, sigmavel, dv=dv, V=V, maxsnr=maxsnr, seuil=seuil

si_spectre = n_elements(spectre)
if not keyword_set(seuil) then seuil = 2.                            
if not keyword_set(dv) then dv = 1.                                  ;dv=-0.412
if not keyword_set(V) then V = 0.              ;V=19.364

centroid=-32768.
snra=-32768.
ntot=-32768.
nb=-32768. 
dc=-32768. 
sigmavel=-32768.

vitesse = findgen(si_spectre)*dv + V

if keyword_set(maxsnr) then begin 
    ind = maxsnra(spectre, bruit, snra) 
    nbind = n_elements(ind) 
endif else begin 
    vevs = clean_spectrum(spectre, seuil*bruit, 5.)
    ind = where(vevs ne -32768., nbind)
endelse 

if (nbind gt 0.) then begin 
    centroid =  total(vitesse(ind)*spectre(ind))/total(spectre(ind)) 
    ntot = total(spectre(ind)) 
    avgV = avg(vitesse(ind))
    Nb = n_elements(ind) 
    qvi = sqrt( avg( (vitesse(ind) - avgV)^2 ) )
    snra = ntot/(sqrt(nb)*bruit) 
    sigmavel = total((vitesse(ind)-centroid)^2*spectre(ind))/total(spectre(ind)) 
    dc = 0.91*qvi*sqrt(1+(snra^2/(snra^2-0.91^2))*((avgV-centroid)/(qvi))^2)/sqrt(snra^2-0.91^2)
endif 

;dc = 0.91*0.29*Nbu*dv*sqrt(1+(snramapu^2/(snramapu^2-0.91^2))*((V-velfieldu)/(0.29*Nbu*dv))^2)/sqrt(snramapu^2-0.91^2)
;dc = 0.91*0.29*Nbu*dv*sqrt(1+(snramapu^2/(snramapu^2-0.91^2))*((avgV-velfieldu)/(0.29*Nbu*dv))^2)/sqrt(snramapu^2-0.91^2)


end
