function statmamd, data, percent, median=med, indef=indef

;------------------------------------
; STATMAMD
;
; Compute the statistics of an input variable
; without the PERCENT % highest and lowest values.
;
; MAMD 01/02/02
;------------------------------------

if not keyword_set(percent) then percent=0.
if not keyword_set(indef) then indef=-32768.

ind = where(data ne indef, nbind)

if nbind gt 0 then begin
    input = data(ind)
    nb =n_elements(input)
    i0 = nb*( percent / 100.)
    i1 = nb - i0 -1
    ind = sort(input)
    result = moment(input(ind(i0:i1)))
;    result(1) = sqrt(result(1))
    if keyword_set(med) then med = median(input(ind(i0:i1)))
endif else result = -1

return, result

end

