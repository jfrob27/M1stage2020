function mtotal, matrice

;---------------------------------------
;
; MTOTAL
;
; Fonctionne comme TOTAL mais fait une multiplication
; de tous les termes de matrice
;
; MAMD 21/08/97
;
;---------------------------------------

mtot = 1.
for i=0, n_elements(matrice)-1 do mtot = mtot*matrice(i)

return, mtot

end
