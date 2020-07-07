pro positive, data, alpha=alpha, minvalue=minvalue

; This routine will modify a fBm image so that it will
; have only positive values while keeping its mean and variance value.
;
; The modified fBm is I' = A*I^alpha + minvalue
;
; minvalue is used to force a minimum value for the result (default is 0).
; alpha returns the alpha value used
;
; Marc-Antoine Miville-Deschenes, 2006/05/03

if not keyword_set(minvalue) then minvalue=0.

data = 1.d*data

avgval = avg(data)
sigval = stddev(data)
data = data-min(data)+minvalue
alpha = 1.
stdnp = sigval
a = avgval/avg(data^alpha) 
dd = 0.05
nb = 5.
sigvec = fltarr(nb)
diff = 1 

while diff gt 0.01 do begin 
    if (n_elements(sigvalvec) lt 3) then begin
        alphanext = alpha*sigval/stdnp
        alphavec = linindgen(nb, alphanext*(1.-dd), alphanext*(1+dd))
        for i=0, nb-1 do sigvec(i) = stddev(a*data^alphavec(i))
        rien = min(abs(sigvec-sigval), wmin)
        if (wmin(0) ne 0 and wmin(0) ne nb-1) then begin
            ind = where(finite(sigvec) eq 1)
            alpha = interpol(alphavec(ind), sigvec(ind), sigval)
        endif else begin
            alpha = alphavec(wmin(0))
        endelse
    endif else begin
        ind = sort(sigvalvec)
        alpha = interpol(alphavalvec(ind), sigvalvec(ind), sigval)
    endelse
    np = data^alpha
    avgnp = avg(np)
    b = ( avg(np)*minvalue - avgval*min(np) ) / (avgnp - min(np) )
    a = ( avgval-b )/avgnp 
    np = a*np
    avgnp = avg(np)
    stdnp = stddev(np)
    diff = abs((sigval-stdnp)/sigval) 
    print, a, alpha, avgnp, avgval, stdnp, sigval, diff
    if n_elements(alphavalvec) gt 0 then alphavalvec = [alphavalvec, alpha] else alphavalvec = alpha
    if n_elements(sigvalvec) gt 0 then sigvalvec = [sigvalvec, stdnp] else sigvalvec = stdnp
endwhile
data = a*data^alpha + b

end
