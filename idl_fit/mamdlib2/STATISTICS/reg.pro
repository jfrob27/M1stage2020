pro reg, x, y, _Extra=extra, nbiteration=nbiteration, dpente=dpente, doao=doao, $
         pente=pente, oao=oao, dy=dy, $
         xseuil=xseuil, yseuil=yseuil, silent=silent, onlyone=onlyone, $
         xlog=xlog, ylog=ylog, thresh=thresh

if not keyword_set(nbiteration) then nbiteration=0
if not keyword_set(xseuil) then xseuil=[la_min(x), la_max(x)]
if not keyword_set(yseuil) then yseuil=[la_min(y), la_max(y)]
if not keyword_set(dy) then dy=0
if not keyword_set(thresh) then thresh=3

ind = where(x ne -32768 and y ne -32768, nbind)
ind2 = where(x ge xseuil(0) and x le xseuil(1) and $
             y ge yseuil(0) and y le yseuil(1))
if (nbind gt 1) then begin
    result = reglin(x(ind2), y(ind2), dy, coeff=coeff, dcoeff=dcoeff)
; take care of deviant points
    for i=0, nbiteration-1 do begin
        diff = la_sub(y, la_add(la_mul(x, coeff(1)), coeff(0)))
        stat = statmamd(diff, 5)
        med = median(diff)
        sigval = sqrt(stat(1))
        ind3 = where(abs(la_sub(diff, med)) lt thresh*sigval and diff ne -32768., nbind)
        result = reglin(x(ind3), y(ind3), dy, coeff=coeff, dcoeff=dcoeff)
    endfor

; compute regression in the other direction (X(Y) instead of Y(X))
    if not keyword_set(onlyone) then begin
        result = reglin(y(ind2), x(ind2), coeff=coeff2, dcoeff=dcoeff2)
; take care of deviant points
        for i=0, nbiteration-1 do begin
            diff = la_sub(x, la_add(la_mul(y, coeff2(1)), coeff2(0)))
            stat = statmamd(diff, 5, median=med)
            sigval = sqrt(stat(1))
            ind3 = where(abs(la_sub(diff, med)) lt thresh*sigval and diff ne -32768., nbind)
            result = reglin(y(ind3), x(ind3), coeff=coeff2, dcoeff=dcoeff2)
        endfor
        oao = ( coeff(0) + (-1*coeff2(0)/coeff2(1)) )/2.
        pente = ( coeff(1) + 1./coeff2(1) )/2.
        dpente = max([abs(coeff(1)-pente), dcoeff(1), dcoeff2(1)])
        doao = max([abs(coeff(0)-oao), dcoeff(0), dcoeff2(0)])
    endif else begin
        pente = coeff(1)
        dpente = dcoeff(1)
        oao = coeff(0)
        doao = dcoeff(0)
    endelse

    if not keyword_set(silent) then begin
       plot, x(ind), y(ind), xlog=xlog, ylog=ylog, _Extra=extra
        print, 'OaO: ', oao, doao
        print, 'pente: ', pente, dpente
        if keyword_set(xlog) or keyword_set(ylog) then $
           ox = logindgen(100, xseuil(0), xseuil(1)) else ox = xseuil
        oy = oao+ox*pente
        oplot, ox, oy, col=10
    endif

endif else print, 'no valid point'

end
