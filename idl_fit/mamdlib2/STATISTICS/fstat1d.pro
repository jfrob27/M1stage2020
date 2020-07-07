function fstat1d, image, lagmax, ordre_max=ordre_max, indef=indef, $
	stat2d=stat2d

;--------------------------------------------------
;
; FSTAT1D
;
; Permet de calculer en 1D la fonction d'autocorrelation et
; les fonctions de structure d'une image. FSTAT1D calcule
; les fonctions statistiques de facon vectorielle a
; l'aide de FSTAT2D.pro. 
; La tache principale de fstat1d.pro est d'appeler fstat2d
; et de ramener en une dimension l'ACR et la STR bidimensionelle.
;
; CALLING SEQUENCE:
;   result = fstat1d(image, lagmax, ordre_max=ordre_max)
;
; INPUTS:
;   image: image 2D (peut importe la dimension) (le INDEF est -999)
;   lagmax:  la distance maximale a laquelle on calcule les fonct. stat.
;   ordre_max: l'ordre maximum des functions de structure calculees (2 par default)
;
; OUPUTS:
;   Le resultat est dans une matrice result(4, nb_pas):
; 	result(0,*) = distance
;	result(1,*) = fonction d'autocorrelation
; 	result(2,*) = fonction de structure d'ordre 2
;	....
;	result(ordre_max,*) = fonction de structure d'ordre_max
; 	result(ordre_max+1,*) = nombre de point dans chaque interval de distance 
;
; EXEMPLE:
;
;   IDL> result = fstat1d(residu, 20, ordre_max=4)

;   Pour afficher la fonction d'autocorrelation on a simplement a taper:
;   IDL> plot, result(0,*), result(1,*), /xlog
;
;   Pour afficher la fonction de structure d'ordre 3 on a simplement a taper:
;   IDL> plot, result(0,*), result(3,*), /xlog
;
;
; MAMD 13/11/97
;
;---------------------------------------------------

if not keyword_set(ordre_max) then ordre_max=2
if not keyword_set(indef) then indef=-999

taille = 2*lagmax+1

fstat2d, image, lagmax, acr2d, str2d, nbpoint2d, ordre_max=ordre_max, indef=indef

X = fltarr(taille, taille)
for i=0, taille-1 do X(*,i) = findgen(taille)-lagmax
Y = fltarr(taille, taille)
for i=0, taille-1 do Y(i,*) = findgen(taille)-lagmax
distance = sqrt(X^2 + Y^2)
;distance(*,0:lagmax)=indef

lag = distance(UNIQ(distance, sort(distance)))
;ind = where(lag ne indef)
;lag = lag(ind)

result = fltarr(ordre_max+2, N_ELEMENTS(lag))
result(0,*) = lag
for i=0, (N_ELEMENTS(lag)-1) do begin
   indice = where(distance eq lag(i))
   result(1,i) = total(acr2d(indice)*nbpoint2d(indice))
   for j=2, ordre_max do begin
	str = reform(str2d(*,*,j-2))
   	result(j,i) = total(str(indice)*nbpoint2d(indice))
   endfor
   result(ordre_max+1,i) = total(nbpoint2d(indice))
endfor

result(1,*) = result(1,*)/result(ordre_max+1,*)
for j=2, ordre_max do result(j,*) = result(j,*)/result(ordre_max+1,*)

stat2d = fltarr(taille, taille, ordre_max)
stat2d(*,*,0) = acr2d
stat2d(*,*,1:*) = str2d

return, result

end





