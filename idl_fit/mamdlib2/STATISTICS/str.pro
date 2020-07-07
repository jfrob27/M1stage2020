function str, image, lagmax, ordre=ordre, indef=indef

;--------------------------------------------------
;
; STR
;
; Permet de calculer en 1D
; la fonction de structure d'une image. 
; La tache principale de STR.pro est d'appeler STR2D
; et de ramener en une dimension la STR bidimensionelle.
;
; CALLING SEQUENCE:
;   result = str(image, lagmax, ordre=ordre, indef=indef)
;
; INPUTS:
;   image: image 2D (peut importe la dimension) (le INDEF est -32768)
;   lagmax:  la distance maximale a laquelle on calcule la fonction de structure
;
; KEYWORDS:
;   ordre: l'ordre de la function de structure calculee (2 par default)
;
; OUPUTS:
;   Le resultat est dans une matrice result(3, nb_pas):
; 	result(0,*) = distance
; 	result(1,*) = fonction de structure
; 	result(2,*) = nombre de point dans chaque interval de distance 
;
;
; MAMD 20/11/97
;
;---------------------------------------------------

if not keyword_set(ordre) then ordre=2
if not keyword_set(indef) then indef=-32768

taille = 2*lagmax+1

structure = str2d(image, lagmax, nbpoint2d=nbpoint2d, ordre=ordre, indef=indef)

X = fltarr(taille, taille)
for i=0, taille-1 do X(*,i) = findgen(taille)-lagmax
Y = fltarr(taille, taille)
for i=0, taille-1 do Y(i,*) = findgen(taille)-lagmax
distance = sqrt(X^2 + Y^2)

lag = distance(UNIQ(distance, sort(distance)))

result = fltarr(3, N_ELEMENTS(lag))
result(0,*) = lag
for i=0, (N_ELEMENTS(lag)-1) do begin
   indice = where(distance eq lag(i))
   result(1,i) = total(structure(indice)*nbpoint2d(indice))
   result(2,i) = total(nbpoint2d(indice))
endfor

result(1,*) = result(1,*)/result(2,*)

return, result

end





