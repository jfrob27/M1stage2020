pro str2df90, image, lag_max, result2, ordre_max=ordre_max, indef=indef

if not keyword_set(indef) then indef = -32768
if not keyword_set(ordre_max) then ordre_max=2
result = fltarr(lag_max+1, 2*lag_max+1, ordre_max-1)
result2 = fltarr(2*lag_max+1, 2*lag_max+1, ordre_max-1)

; Ecriture dans un fichier

si_image = size(image)
nb=n_elements(image)
fichier = 'imagestr.dat'
openw,1,fichier
printf,1, si_image(1), si_image(2), lag_max, ordre_max, indef
for i=0l, nb-1 do printf, 1, image(i)
close,1


; Appel du program fortran

spawn, 'time /home/mamd/idl/veloce/a.out'   

spawn, 'rm -f imagestr.dat'

; Lecture du resultat

fichier = 'str2d.dat'
openr,1,fichier
for k=0, ordre_max-2 do begin & $
   for j=0, 2*lag_max do begin & $
	for i=0, lag_max do begin & $
		readf, 1, toto & $
		result(i,j,k) = toto & $
	endfor & $
   endfor & $
endfor
close,1

for i=0, ordre_max-2 do begin
	result2(lag_max:*,*,i) = result(*,*,i)	
	result2(0:lag_max,*,i) = rotate(result2(lag_max:*,*,i), 2)
endfor

spawn, 'rm -f str2d.dat'

end
