pro str2df90, image, lag_max, result, ordre_max=ordre_max, indef=indef

if not keyword_set(indef) then indef = -32768
if not keyword_set(ordre_max) then ordre_max=2
result = fltarr(2*lag_max+1, 2*lag_max+1, ordre_max-2)

; Ecriture dans un fichier

nb=n_elements(image)
fichier = 'imagefstr.data'
openw,1,fichier
printf,1, lag_max, ordre_max, indef
for i=0l, nb-1 do printf, 1, image(i)
close,1


; Appel du program fortran

spawn, 'str2d.f90'   


; Lecture du resultat

fichier = 'str2d.data'
openr,1,fichier
for k=0, ordre_max-2 do begin
   for j=0, 2*lag_max do begin
	for i=0, 2*lag_max do readf, 1, result(i,j,k)
   endfor
endfor
close,1

end
