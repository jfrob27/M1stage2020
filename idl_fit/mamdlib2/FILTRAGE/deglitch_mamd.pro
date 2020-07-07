function deglitch_mamd, spectre_in, seuil, space, nointerpol=nointerpol, back=back

if not keyword_set(space) then space=1.
spectre =reform(spectre_in)
si_spectre = size(spectre)
;IF NOT keyword_set(back) THEN back = smooth(spectre, 2*space)
spectre = spectre-back
diff1 = spectre - shift(spectre, 1) 
diff2 = spectre - shift(spectre, -1) 

result = spectre
;diff1 =  convol(spectre, [-0.5, 1., -0.5])
;diff2 =  convol(spectre, [0.5, -1., 0.5])

;ind = where((diff1 gt seuil and diff2 gt seuil) or (diff1 lt -1*seuil and diff2 lt -1*seuil), nbind) 
;if (nbind gt 0) then begin 
;    result(ind) = -32768. 
;    ind0 = where(result ne -32768.) 
;    result(ind) = interpol(result(ind0), ind0, ind) 
;    result(0)=spectre(0) 
;    result(si_spectre(1)-1) = spectre(si_spectre(1)-1) 
;endif

;stop

ind1 = where(diff1 gt seuil, nbind)
ind2 = where(diff1 lt -1.*seuil, nbind2)
if (nbind gt 0 and nbind2 gt 0.) then begin
    for i=0, nbind-1 do begin
        ind21 = where(abs(ind2-ind1(i)) le space, nbind21)
        if(nbind21 gt 0) then begin
;            a = ind1(i)
;            b =  ind2(ind21(nbind21-1))
            a = min([ind2(ind21), ind1(i)])
            b = max([ind2(ind21), ind1(i)])
            result(a:b-1) = -32768.
;            if a lt b then result(a:b-1) = -32768 else result(b:a-1) =-32768
        endif
    endfor
endif

result = la_add(result, back)

if not keyword_set(nointerpol) then begin
    ind = where(result eq -32768, nbind)
    if (nbind gt 0.) then begin
        ind0 = where(result ne -32768.) 
        result(ind) =interpol(result(ind0), ind0, ind) 
;        result(0)=spectre(0) 
;        result(si_spectre(1)-1) = spectre(si_spectre(1)-1) 
    endif
endif


return, result

end


