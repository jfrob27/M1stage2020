pro ccr2d, image1, image2, lag_max, result, nbpoint_out, indef=indef

;---------------------------------------------------
;
; CCR2D.PRO
;
; Calcul de la fonction de cross-correlation entre deux images.
; LE CALCUL EST FAIT VECTORIELLEMENT.
; Les points ayant la valeur indef (-32768 par defaut) sont ignores.
;
;
; CALLING SEQUENCE:
;   ccr2d, image1, image2, lag_max, result, nbpoint2d
;
; INPUTS:
;   image1 et image2: the two images (must have same size)
;   lag_max: la distance maximale a laquelle on calcule
;
; OUTPUTS:
;   result: image 2 dimension de la ACR
;   nbpoint2d: image 2 dimension du nombre de point utilises a 
;		chaque endroit pour calculer ACR
;
;
; MAMD 04/03/2002
;
;---------------------------------------------------

if not keyword_set(indef) then indef = -32768

acrres = dblarr(2*lag_max+1, 2*lag_max+1,2*lag_max+1)
nbpoint2d = fltarr(2*lag_max+1, 2*lag_max+1,2*lag_max+1)
taille = size(image1)

ind = where(image1 ne indef)
moy1 = avg(image1(ind))
ind = where(image2 ne indef)
moy2 = avg(image2(ind))

for k=-lag_max, lag_max do begin 
    for j=-lag_max, lag_max do begin 
        for i=-lag_max, lag_max do begin
        if (i ge 0) then begin 
            ival1 = [i, taille(1)-1]  
            ival2 = [0, taille(1)-1-i] 
        endif else begin  
            ival1 = [0, taille(1)-1+i] 
            ival2 = [-i, taille(1)-1] 
        endelse 
        if (j ge 0) then begin 
            jval1 = [j, taille(2)-1]  
            jval2 = [0, taille(2)-1-j] 
        endif else begin  
            jval1 = [0, taille(2)-1+j] 
            jval2 = [-j, taille(2)-1] 
        endelse 
        if (k ge 0) then begin 
            kval1 = [k, taille(3)-1]  
            kval2 = [0, taille(3)-1-k] 
        endif else begin  
            kval1 = [0, taille(3)-1+k] 
            kval2 = [-k, taille(3)-1] 
        endelse 
        im1 = image1(ival1(0):ival1(1),jval1(0):jval1(1),kval1(0):kval1(1)) 
        im2 = image2(ival2(0):ival2(1),jval2(0):jval2(1),kval2(0):kval2(1)) 
        ind = where(im1 ne indef and im2 ne indef, nbpoint) 
        if (nbpoint gt 0) then begin
            acrres(lag_max+i, lag_max+j, lag_max+k) = total( (im1(ind) - moy1)* (im2(ind) - moy2) )
            nbpoint2d(lag_max+i,lag_max+j, lag_max+k) = nbpoint 
        endif else nbpoint2d(lag_max+i,lag_max+j, lag_max+k) = 1
    endfor 
    print, "j: ", j
endfor

result = acrres/(1.*nbpoint2d)
nbpoint_out = 1.*nbpoint2d

end





