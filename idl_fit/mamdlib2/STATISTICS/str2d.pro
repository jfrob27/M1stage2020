pro str2d, image, lag_max, result, nbpoint_out, ordre_max=ordre_max, $
           indef=indef, strres=strres, sigmap=sigmap, ressig=ressig, resmoy=resmoy

;---------------------------------------------------
;
; STR2D.PRO
;
; Calcul de la fonction de structure pour une image (2D) quelconque.
; LE CALCUL EST FAIT VECTORIELLEMENT.
; Les points ayant la valeur indef (-32768 par defaut) sont ignores.
;
;
; CALLING SEQUENCE:
;   str2d, image, lag_max, result, nbpoint2d
;
; INPUTS:
;   image: image 2D (peut importe la dimension)
;   lag_max: la distance maximale a laquelle on calcule
;
; OUTPUTS:
;   result: image 2 dimension de la STR
;   nbpoint2d: image 2 dimension du nombre de point utilises a 
;		chaque endroit pour calculer STR
;
;
; MAMD 27/03/98
;
;---------------------------------------------------

if not keyword_set(indef) then indef = -32768
if not keyword_set(ordre_max) then ordre_max=2

strres = dblarr(lag_max+1, 2*lag_max+1, ordre_max-1)
strsig = dblarr(lag_max+1, 2*lag_max+1, ordre_max-1)
ssig = dblarr(lag_max+1, 2*lag_max+1)
smoy = dblarr(lag_max+1, 2*lag_max+1)
nbpoint2d = fltarr(lag_max+1, 2*lag_max+1)

taille = size(image)

for j=-lag_max, lag_max do begin
    print, j
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
        nbpoint2d(i,lag_max+j) = nbpoint
        for k=2, ordre_max do begin 
;            strres(i, lag_max+j, k-2) = abs(total((im1(ind)-im2(ind))^k))
            strres(i, lag_max+j, k-2) = total((im1(ind)-im2(ind))^k)
        endfor
    endfor
endfor

result = fltarr(2*lag_max+1, 2*lag_max+1, ordre_max-1)
;ressig = fltarr(2*lag_max+1, 2*lag_max+1)
;resmoy = fltarr(2*lag_max+1, 2*lag_max+1)
;sigmap = fltarr(2*lag_max+1, 2*lag_max+1, ordre_max-1)

for i=0, ordre_max-2 do begin
    result(lag_max:*,*,i) = strres(*,*,i)/(1.*nbpoint2d)
    result(0:lag_max,*,i) = rotate(result(lag_max:*,*,i), 2)
;    sigmap(lag_max:*,*,i) = strsig(*,*,i)/(1.*nbpoint2d)
;    sigmap(0:lag_max,*,i) = rotate(sigmap(lag_max:*,*,i), 2)
endfor
;ressig(lag_max:*,*) = ssig(*,*)/(1.*nbpoint2d)
;ressig(0:lag_max,*) = rotate(ressig(lag_max:*,*), 2)
;resmoy(lag_max:*,*) = smoy(*,*)/(1.*nbpoint2d)
;resmoy(0:lag_max,*) = rotate(resmoy(lag_max:*,*), 2)


nbpoint_out = fltarr(2*lag_max+1, 2*lag_max+1)
nbpoint_out(lag_max:*,*) = 1.*nbpoint2d
nbpoint_out(0:lag_max,*) = rotate(nbpoint_out(lag_max:*,*), 2)

end





