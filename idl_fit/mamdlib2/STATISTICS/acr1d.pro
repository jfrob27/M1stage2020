function acr1d, image, lagmax, indef=indef, acr2dim=acr2dim, dl=dl

;--------------------------------------------------
;
; ACR1D
;
; Calcule la fonction d'autocorrelation 1D.
; La tache principale de acr1d.pro est d'appeler str2d
; et de ramener en une dimension la ACR bidimensionelle.
;
; CALLING SEQUENCE:
;   result = acr1d(image, lagmax, indef=indef)
;
; INPUTS:
;   image: image 2D (peut importe la dimension) (le INDEF est -32768)
;   lagmax:  la distance maximale a laquelle on calcule la ACR
;
; OUPUTS:
;   Le resultat est dans une matrice result(3, nb_pas):
; 	result(0,*) = distance
; 	result(1,*) = fonction d'autocorrelation
; 	result(2,*) = nombre de point dans chaque interval de distance 
;
;
; MAMD 24/04/98
;
;---------------------------------------------------

if not keyword_set(indef) then indef=-32768

taille = 2*lagmax+1

acr2d, image, lagmax, acr2dim, nbpoint2d, indef=indef, sigma=sigma

X = fltarr(taille, taille)
for i=0, taille-1 do X(*,i) = findgen(taille)-lagmax
Y = fltarr(taille, taille)
for i=0, taille-1 do Y(i,*) = findgen(taille)-lagmax
distance = sqrt(X^2 + Y^2)

if keyword_set(dl) then begin
;    lag = findgen(ceil(max(distance)/(1.*dl)))*dl
    lag = findgen(lagmax/(1.*dl))*dl
endif else begin
    dl = 1.e-6
    lag = distance(UNIQ(distance, sort(distance)))
endelse

result = fltarr(4, N_ELEMENTS(lag))
result(0,*) = lag
for i=0, (N_ELEMENTS(lag)-1) do begin
   indice = where(distance gt lag(i)-dl/2. and distance le lag(i)+dl/2. )
   acrref = reform(acr2dim(*,*))
   result(1,i) = total(acrref(indice)*nbpoint2d(indice))
   result(2,i) = total(nbpoint2d(indice))
   result(3,i) = total(sigma(indice)*nbpoint2d(indice))
endfor

;result(1,*) = result(1,*)/result(2,*)
result(1,*) = result(1,*)/(result(2,*))
result(3,*) = result(3,*)/(result(2,*))-(result(1,*))^2
;result(3,*) = result(3,*)/(result(2,*))


return, result

end





