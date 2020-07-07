function range, data, percent, indef=indef, margin=margin;, highonly=highonly, lowonly=lowonly

if not keyword_set(percent) then percent=0.
if not keyword_set(indef) then indef=-32768.
if (n_elements(percent) eq 1) then percent_used = [percent, percent] else percent_used = percent

ind = where(data ne indef, nbind)

if nbind gt 0 then begin
    input = data(ind)
    nb = n_elements(input)
    i0 = nb*( percent_used[0] / 100.)
    i1 = nb - nb*( percent_used[1] / 100.) -1
    ind = sort(input)
;    if keyword_set(highonly) then i0=0
;    if keyword_set(lowonly) then i1 = nb-1
    result = minmax(input(ind(i0:i1)))
    if keyword_set(margin) then begin
       dd = result[1]-result[0]
       result[0] = result[0]-margin*dd
       result[1] = result[1]+margin*dd
    endif
endif else result = -1

return, result

end
