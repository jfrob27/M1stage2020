pro acr2d, image, lag_max, result, nbpoint_out, indef=indef, $
           acrres=acrres, sigma=sigma_out

;---------------------------------------------------
;
; ACR2D.PRO
;
; Calcul de la fonction d'autocorrelation pour une image (2D) quelconque.
; LE CALCUL EST FAIT VECTORIELLEMENT.
; Les points ayant la valeur indef (-32768 par defaut) sont ignores.
;
;
; CALLING SEQUENCE:
;   acr2d, image, lag_max, result, nbpoint2d
;
; INPUTS:
;   image: image 2D (peut importe la dimension)
;   lag_max: la distance maximale a laquelle on calcule
;
; OUTPUTS:
;   result: image 2 dimension de la ACR
;   nbpoint2d: image 2 dimension du nombre de point utilises a 
;		chaque endroit pour calculer ACR
;
;
; MAMD 23/04/98
;
;---------------------------------------------------

if not keyword_set(indef) then indef = -32768

acrres = dblarr(lag_max+1, 2*lag_max+1)
sigma = dblarr(lag_max+1, 2*lag_max+1)
nbpoint2d = fltarr(lag_max+1, 2*lag_max+1)

taille = size(image)

t0 = systime(1)
t1 = t0
dt=0
fait=0
Q=0.
;for j=-lag_max, lag_max do Q = Q + (taille(2)-1-abs(j))
nbfait = 0.

for j=-lag_max, lag_max do begin 
    for i=0, lag_max do begin 
        if (j ge 0) then begin 
            jval1 = [j, taille(2)-1]  
            jval2 = [0, taille(2)-1-j] 
        endif else begin  
            jval1 = [0, taille(2)-1+j] 
            jval2 = [-j, taille(2)-1] 
        endelse 
        im1 = image(i:*,jval1(0):jval1(1)) 
        im2 = image(0:(taille(1)-1-i),jval2(0):jval2(1)) 
        ind = where(im1 ne indef and im2 ne indef, nbpoint) 
        if (nbpoint gt 0) then begin
;            acrres(i, lag_max+j) = abs(total(im1(ind)*im2(ind))) 
            acrres(i, lag_max+j) = total(im1(ind)*im2(ind))
;            acrres(i, lag_max+j) = total(abs(im1(ind)*im2(ind)))
            sigma(i, lag_max+j) = total((im1(ind)*im2(ind))^2)
;            sigma(i, lag_max+j) = total((im1(ind))^2+im2(ind)^2)/2.
            nbpoint2d(i,lag_max+j) = nbpoint 
        endif else nbpoint2d(i,lag_max+j) = 1
    endfor 
;    t2 = systime(1)  
;    nbfait = nbfait+1
;    dt = (t2-t0)/nbfait
;    nbafaire = 2*lag_max-nbfait
;    print, "j: ", j, nbafaire*dt/60., " minutes a faire" , dt, nbfait
    print, "j: ", j
;    t1 = t2 
endfor

result = fltarr(2*lag_max+1, 2*lag_max+1)
result(lag_max:*,*) = acrres/(1.*nbpoint2d)
result(0:lag_max,*) = rotate(result(lag_max:*,*), 2)
nbpoint_out = fltarr(2*lag_max+1, 2*lag_max+1)
nbpoint_out(lag_max:*,*) = 1.*nbpoint2d
nbpoint_out(0:lag_max,*) = rotate(nbpoint_out(lag_max:*,*), 2)
sigma_out = fltarr(2*lag_max+1, 2*lag_max+1)
sigma_out(lag_max:*,*) = 1.*sigma/(1.*nbpoint2d)
sigma_out(0:lag_max,*) = rotate(sigma_out(lag_max:*,*), 2)


print, "temps total: ", systime(1)-t0

end





