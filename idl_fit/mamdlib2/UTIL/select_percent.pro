function select_percent, input, percent, indef=indef

if not keyword_set(indef) then indef=-32768.
if n_elements(percent) eq 1 then percent_use = [percent, percent] else percent_use=percent

ind = where(input ne indef, nbind)
if nbind eq 0 then begin
    return, -1 
endif else begin
    ind2 = sort(input(ind))
    i1 = fix(nbind * percent_use(0) / 100.)
    i2 = nbind - fix(nbind * percent_use(1) / 100.) -1
    return, ind(ind2(i1:i2))
endelse

end

