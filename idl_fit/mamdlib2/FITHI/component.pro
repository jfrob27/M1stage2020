function component, result

si_result = size(result)

nb_comp = fix(si_result(3)/3)
output = fltarr(si_result(1), si_result(2), nb_comp)

for k=0, nb_comp-1 do begin
    amp = result(*,*,3*k)
    sig = result(*,*,3*k+2)
    ind = where(amp ne -32768. and sig ne -32768., nbind)
    if (nbind gt 0) then begin
        amp(ind) = sqrt(2*!pi)*amp(ind)*sig(ind)
        output(*,*,k) = amp
    endif else output(*,*,k) = -32768.
endfor

return, output

end

