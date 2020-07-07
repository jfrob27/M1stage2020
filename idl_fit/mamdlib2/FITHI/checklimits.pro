pro checklimits, guess, parinfo

nbcomp = n_elements(guess)
for i=0, nbcomp-1 do begin
    if (guess(i) le parinfo(i).limits(0)) then begin
        guess(i) = parinfo(i).limits(0)*1.01
    endif
    if (guess(i) ge parinfo(i).limits(1)) then begin
        guess(i) = parinfo(i).limits(1)*0.99
    endif
endfor

end
