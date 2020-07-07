function indtopos, ind, matrice

;-------------------------------------
;
; INDTOPOS
;
; Programme qui retourne les indices position (x, [y, [z])
; d'un point dans une matrice (2 ou 3 dimanesions)
; a partir de son indice.
;
; MAMD 21/08/97
;
;-------------------------------------

si_mat = size(matrice)
si_mat = float(si_mat)
ind = float(ind)
if (si_mat(0) gt 1) then result = intarr(si_mat(0), N_ELEMENTS(ind))

if (si_mat(0) eq 0) then begin
	print, "Variable de dimension 0"
	return, -1;
endif	
if (si_mat(0) eq 1) then begin
	return, fix(ind);
endif	

if (si_mat(0) eq 2) then begin
   for i=0, N_ELEMENTS(ind)-1 do begin
      result(1,i) = fix(ind(i)/si_mat(1))
      result(0,i) = ind(i) - result(1,i)*si_mat(1)
    endfor
    return, result
endif      

if (si_mat(0) eq 3) then begin
    si_mat = float(si_mat)
   for i=0., float(N_ELEMENTS(ind)-1) do begin
      result(2,i) = fix(1.*ind(i)/mtotal(si_mat(1:2)))
      result(1,i) = fix((ind(i) - result(2,i)*mtotal(si_mat(1:2)))/si_mat(1))
      result(0,i) = ind(i) - result(2,i)*mtotal(si_mat(1:2))- result(1,i)*si_mat(1)
    endfor
    return, result
endif      

end
