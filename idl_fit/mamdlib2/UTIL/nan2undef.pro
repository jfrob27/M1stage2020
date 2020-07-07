pro nan2undef, data, undef=undef, indef=indef

; put all the NAN values of the input array to undefine value
;
; Marc-Antoine Miville-Deschenes, 17/05/2004

if keyword_set(indef) then undef=indef
if not keyword_set(undef) then undef=-32768.

ind = where(finite(data) ne 1, nbind)
if (nbind gt 0) then data(ind) = undef

end
