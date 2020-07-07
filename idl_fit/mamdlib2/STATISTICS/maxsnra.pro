function maxsnra, spectre, noise, snra0

snra0 = 0.
snra = 0.
toto = max(spectre, indmax)
indmax=indmax(0)
;ind = reverse(sort(spectre))
;i = 0.
;while (snra ge snra0) do begin
;    snra0 = snra
;    snra = total(spectre(ind(0:i)))/(sqrt(i+1)*noise)
;    i = i+1
;endwhile

indgood = spectre
indgood(*) = 0.
indgood(indmax)  =1.
i = 1.
a = indmax
b = indmax
ok = 1
while (ok eq 1) do begin

    a = (a-1)
    if (a lt 0) then oka=0 else begin
        indgood(a) = 1
        ind = where(indgood eq 1., nbind)
        snra = total(spectre(ind))/(sqrt(nbind)*noise)
;print, 'snra A:', snra
        if (snra ge snra0) then begin
            oka=1 
            snra0 = snra
        endif else begin
            oka=0
            indgood(a) = 0.
            a = a+1<indmax
        endelse
    endelse

    b = (b+1)
    if (b gt (n_elements(spectre)-1)) then okb=0 else begin
        indgood(b) = 1
        ind = where(indgood eq 1., nbind)
        snra = total(spectre(ind))/(sqrt(nbind)*noise)
;print, 'snra B:', snra
        if (snra ge snra0) then begin
            okb=1 
            snra0=snra
        endif else begin
            okb=0
            indgood(b) = 0.
            b = b-1>indmax
        endelse
    endelse
    ok = max([oka,okb])
    if (a eq 0 and b eq n_elements(spectre)-1) then ok=0
;print, a, b, oka, okb, ok, snra0
endwhile

;return, ind(0:i-1)
ind = findgen(n_elements(spectre))
return, ind(where(indgood eq 1))

end
