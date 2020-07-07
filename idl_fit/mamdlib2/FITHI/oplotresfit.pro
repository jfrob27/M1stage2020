pro oplotresfit, x, result_in, color=color, posx=posx, posy=posy,  $
                 nodecompose=nodecompose, indef=indef, noplotsum=noplotsum, $
                 linestyle=linestyle, thick=thick

result = result_in
if not keyword_set(color) then color=10
if not keyword_set(indef) then indef=-32768
if not keyword_set(linestyle) then linestyle=0

result = reform(result)
si_result = size(result)
if (si_result(0) ne 1) then begin
    if not keyword_set(posx) then posx=1
    if not keyword_set(posy) then posy=1
    result = reform(result(posx, posy, *))
    si_result = size(result)
endif 

ind = where(result ne indef, nbind)
if (nbind gt 0) then begin
    xx = indgen(n_elements(x))
    a = result(ind)
    nb_cpn = fix(n_elements(a)/3.)
;    if keyword_set(sinc) then begin
;        nb_to_add = 4-nb_cpn
;        for ii=0, nb_to_add-1 do a = [a, [0,0,1]]
;        a = [a, 0.]
;        f = gauss_sinc_mpfit(a, XVAL=xx, /model_out)
;    endif else begin
       f = mgauss(xx, a)
;    endelse
    if not keyword_set(noplotsum) then begin
        if keyword_set(color) then oplot, x, f, color=mcol('red'), linestyle=linestyle, thick=thick $
        else oplot, x, f, linestyle=linestyle, thick=thick
;        if keyword_set(color) then oplot, x, f+result(si_result(1)-3), color=50, linestyle=linestyle $
;        else oplot, x, f+result(si_result(1)-3), linestyle=linestyle
    endif

    if ((nb_cpn gt 1) and not keyword_set(nodecompose)) then begin
        for i=0, nb_cpn-1 do begin
;            if keyword_set(sinc) then begin
;                a = result(i*3:(i+1)*3-1)
;                a = [a, 0., 0., 1., 0., 0., 1., 0., 0., 1., 0.]
;                f = gauss_sinc_mpfit(a, XVAL=xx, /model_out)
;            endif else begin
                f = mgauss(xx, a(3*i:(3*i+2)))
;            endelse
            if keyword_set(color) then oplot, x, f, $
              linestyle=linestyle, color=color, thick=thick $
            else oplot, x, f, linestyle=linestyle, thick=thick
;            if keyword_set(color) then oplot, x, f+result(si_result(1)-3), $
;              linestyle=linestyle, color=color $
;            else oplot, x, f+result(si_result(1)-3), linestyle=linestyle
        endfor
    endif
endif else print, 'Aucun FIT a afficher'

end
