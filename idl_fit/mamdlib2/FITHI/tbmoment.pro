function tbmoment, cube, x

si = size(cube)
if not keyword_set(x) then x = findgen(si(3))

output = fltarr(si(1), si(2), 3)
output(*) = -32768.
output(*,*,0) = la_tot(cube, dim=-1)

for i=0, si(1)-1 do begin
   for j=0, si(2)-1 do begin
      if (output(i,j,0) ne 0.) then begin
         s = reform(cube(i,j,*))
         ind = where(s ne -32768., nbind)
         if (nbind gt 0) then begin
            output(i,j,1) = total(x(ind)*s(ind))/total(s(ind))
            output(i,j,2) = sqrt(total(x(ind)^2*s(ind))/total(s(ind)) - output(i,j,1)^2)
         endif
      endif
   endfor
endfor

return, output

end

