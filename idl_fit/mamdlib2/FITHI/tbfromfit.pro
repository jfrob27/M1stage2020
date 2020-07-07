function tbfromfit, result, x, amp=amp, cent=cent, sig=sig

si_result = size(result)
nb_comp = fix(si_result(3)/3)
output = fltarr(si_result(1), si_result(2), n_elements(x))
kvec = findgen(nb_comp)
if not keyword_set(amp) then amp = [0, 1.e6]
if not keyword_set(cent) then cent = [-1.e6, 1.e6]
if not keyword_set(sig) then sig = [0., 1.e6]

for i=0, si_result(1)-1 do begin
   for j=0, si_result(2)-1 do begin
      if (result(i,j,0) ne -32768.) then begin
         a = result(i,j,3*kvec)
         c = result(i,j,(3*kvec+1))
         s = result(i,j,(3*kvec+2))
         ind = where(a ge amp(0) and a le amp(1) and c ge cent(0) and c le cent(1) and s ge sig(0) and s le sig(1), nbind)
         for k=0, nbind-1 do output(i,j,*) = output(i,j,*) + a(ind(k))*exp(-((x-c(ind(k)))/s(ind(k)))^2/2.)      
      endif else begin
         output(i,j,*) = -32768.
      endelse
   endfor
endfor

ind = where(output eq 0.)

return, output

end

