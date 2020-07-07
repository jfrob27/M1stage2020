function str1d, image, lagmax, ordre_max=ordre_max, indef=indef, $
                str2dim=str2dim, sigmap=sigmap, erreur=erreur, ssigma=sigma, dl=dl

;--------------------------------------------------
;
; STR1D
;
; Permet de calculer en 1D 
; les fonctions de structure d'une image. STR1D calcule
; les fonctions statistiques de facon vectorielle a
; l'aide de STR2D.pro. 
; La tache principale de str1d.pro est d'appeler str2d
; et de ramener en une dimension la STR bidimensionelle.
;
; CALLING SEQUENCE:
;   result = str1d(image, lagmax, ordre_max=ordre_max)
;
; INPUTS:
;   image: image 2D (peut importe la dimension) (le INDEF est -32768)
;   lagmax:  la distance maximale a laquelle on calcule les fonct. stat.
;   ordre_max: l'ordre maximum des functions de structure calculees (2 par default)
;
; OUPUTS:
;   Le resultat est dans une matrice result(4, nb_pas):
; 	result(0,*) = distance
; 	result(1,*) = fonction de structure d'ordre 2
;	....
;	result(ordre_max-1,*) = fonction de structure d'ordre_max
; 	result(ordre_max,*) = nombre de point dans chaque interval de distance 
;
; EXEMPLE:
;
;   IDL> result = str1d(image, 20, ordre_max=4)
;
;   Pour afficher la fonction de structure d'ordre 3 on a simplement a taper:
;   IDL> plot, result(0,*), result(2,*), /xlog
;
;
; MAMD 13/11/97
;
;---------------------------------------------------

if not keyword_set(ordre_max) then ordre_max=2
if not keyword_set(indef) then indef=-32768

taille = 2*lagmax+1

str2d, image, lagmax, str2dim, nbpoint2d, ordre_max=ordre_max, indef=indef, sigmap=sigmap, ressig=ssig, resmoy=smoy

X = fltarr(taille, taille)
for i=0, taille-1 do X(*,i) = findgen(taille)-lagmax
Y = fltarr(taille, taille)
for i=0, taille-1 do Y(i,*) = findgen(taille)-lagmax
distance = sqrt(X^2 + Y^2)

if keyword_set(dl) then begin
    lag = findgen(lagmax/(1.*dl))*dl
endif else begin
    lag = distance(UNIQ(distance, sort(distance)))
endelse

result = fltarr(ordre_max+1, N_ELEMENTS(lag))
;erreur = fltarr(ordre_max, N_ELEMENTS(lag))
;sigma = fltarr(N_ELEMENTS(lag))
;moyenne = fltarr(N_ELEMENTS(lag))
result(0,*) = lag
;erreur(0,*) = lag

;stop
for i=0, (N_ELEMENTS(lag)-1) do begin 
    if keyword_set(dl) then indice = where(distance gt lag(i)-dl/2. and distance le lag(i)+dl/2. , nbind) else $
      indice = where(distance eq lag(i), nbind)
    if (nbind gt 0) then begin 
        for j=1, ordre_max-1 do begin 
            strref = reform(str2dim(*,*,j-1)) 
            result(j,i) = total(strref(indice)*nbpoint2d(indice)) 
        endfor 
        result(ordre_max,i) = total(nbpoint2d(indice)) 
    endif else result(ordre_max,i) = 1. 
endfor

for j=1, ordre_max-1 do begin 
    result(j,*) = result(j,*)/result(ordre_max,*) 
;    erreur(j,*) = erreur(j,*)/result(ordre_max,*) - (result(j,*))^2 
endfor
;erreur = sqrt(erreur/result(ordre_max,*))

return, result

end





