function index_spectrum, spectrum_out, undef=undef

if not keyword_set(undef) then undef=-32768.

si_spectrum = size(spectrum_out)
index=fltarr(si_spectrum(1))
k = 0
index(0) = k
if spectrum_out(0) eq undef then yesundef=1 else yesundef=0
for i=1, si_spectrum(1)-1 do begin
    if ((spectrum_out(i) eq undef and  yesundef eq 1) or (spectrum_out(i) ne undef and yesundef eq 0)) then begin
        index(i) = k
    endif else begin
        k = k+1
        index(i) = k
        if spectrum_out(i) eq undef then yesundef=1 else yesundef=0
    endelse
endfor

return, index

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function clean_spectrum, spectrum_in, threshold, nbmin, undef=undef

if not keyword_set(undef) then undef=-32768.

si_spectrum = size(spectrum_in)
spectrum_out = spectrum_in
ind = where(spectrum_in lt threshold, nbind)
if nbind gt 0 then spectrum_out(ind) = undef else goto, closing

change=1
while (change eq 1) do begin
    change=0
    index =  index_spectrum(spectrum_out, undef=undef)
    nbstruc = max(index)
    for i=0, nbstruc do begin 
        ind = where(index eq i, nbind)
        if (median(spectrum_out(ind)) ne -32768 and nbind lt nbmin) then begin
            spectrum_out(ind) = -32768
            change=1
        endif
    endfor
endwhile


change=1
while (change eq 1) do begin
    change=0
    index =  index_spectrum(spectrum_out, undef=undef)
    nbstruc = max(index)
    for i=0, nbstruc do begin 
        ind = where(index eq i, nbind)
        if (median(spectrum_out(ind)) eq -32768 and nbind lt nbmin) then begin
            spectrum_out(ind) = spectrum_in(ind)
            change=1
        endif
    endfor
endwhile


closing: 

return, spectrum_out



end
    
