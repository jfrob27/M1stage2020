pro fstat2d, image, lag_max, acr2d, str2d, nbpoint2d, ordre_max=ordre_max, $
	indef=indef

;---------------------------------------------------
;
; FSTAT2D.PRO
;
; Calcul de la fonction d'autocorrelation et de la
; fonction de structure pour une image (2D) quelconque.
; LE CALCUL EST FAIT VECTORIELLEMENT.
; Les points ayant la valeur -999 sont ignores.
;
; POUR CALCULER LES FONCTIONS STATISTIQUES EN 1D, VOIR FSTAT1D
;
; CALLING SEQUENCE:
;   fstat2d, image, lag_max, acr2d, str2d, nbpoint2d
;
; INPUTS:
;   image: image 2D (peut importe la dimension) (le INDEF est -999)
;   lag_max: la distance maximale a laquelle on calcule les fonct. stat.
;
; OUTPUTS:
;   acr2d: image 2 dimension de l'ACR
;   str2d: image 2 dimension de la STR
;   nbpoint2d: image 2 dimension du nombre de point utilises a 
;		chaque endroit pour calculer ACR et STR
;
;
; MAMD 10/1/97
;
;---------------------------------------------------

if not keyword_set(indef) then indef = -999

if not keyword_set(ordre_max) then ordre_max=2

acr2d = fltarr(2*lag_max+1, 2*lag_max+1)
str2d = fltarr(2*lag_max+1, 2*lag_max+1, ordre_max-1)
nbpoint2d = fltarr(2*lag_max+1, 2*lag_max+1)

taille = size(image)

non_nul = where(image ne indef)
binaire = intarr(taille(1),taille(2))
binaire(non_nul) = 1
stat = moment(image(non_nul))

image1 = fltarr(3*taille(1), 3*taille(2))
image1(taille(1):(2*taille(1)-1),taille(2):(2*taille(2)-1)) = image-stat(0)
binaire1 = fltarr(3*taille(1), 3*taille(2))
binaire1(taille(1):(2*taille(1)-1),taille(2):(2*taille(2)-1)) = binaire

t1 = systime(1)
dt=0
for i=0, lag_max do begin
   print, i
   for j=-1*lag_max, lag_max do begin
	image2 = shift(image1, i, j)
	binaire2 = shift(binaire1, i, j)
	acr = image1*image2*(binaire1*binaire2)
	acr2d(lag_max+i,lag_max+j) = total(acr)
	acr2d(lag_max-i,lag_max-j) = total(acr)
	nbpoint2d(lag_max+i,lag_max+j) = 1.*total(binaire1*binaire2)
	nbpoint2d(lag_max-i,lag_max-j) = 1.*total(binaire1*binaire2)
	for k=2, ordre_max do begin
	   str = (image1-image2)^k*(binaire1*binaire2)
	   reste = k mod 2
	   if ((j lt 0) and (reste eq 1)) then fac=-1. else fac=1. 
	   str2d(lag_max+i,lag_max+j,k-2) = fac*total(str)
	   str2d(lag_max-i,lag_max-j,k-2) = fac*total(str)
	endfor
   endfor
   t2 = systime(1)
   dt = dt+(t2-t1)
   print, (lag_max-i)*(dt/float(i+1))/60., " minutes a faire"
   t1 = t2
endfor

acr2d = acr2d/(nbpoint2d*stat(1))
for i=0, ordre_max-2 do str2d(*,*,i) = str2d(*,*,i)/(1.*nbpoint2d)

end





