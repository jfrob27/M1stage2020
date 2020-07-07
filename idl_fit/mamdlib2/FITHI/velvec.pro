function velvec, h, dv=dv, vunit=cunits3, axis=axis

if not keyword_set(axis) then axis=3

v = findgen(sxpar(h, 'NAXIS'+strc(fix(axis)))) - sxpar(h, 'CRPIX'+strc(fix(axis)))

if not keyword_set(cunits3) then cunits3 = strc(sxpar(h, 'CUNIT'+strc(fix(axis))))
if (cunits3 eq 'M/S') then begin
    v0 = sxpar(h, 'CRVAL'+strc(fix(axis))) / 1000.
    dv =  sxpar(h, 'CDELT'+strc(fix(axis))) / 1000. ; pour mettre en km/s
    v = v*dv + v0
endif else begin
    c = 299792.458              ; km/s
    f0 = sxpar(h, 'RESTFREQ')
    v0 = ( f0 - sxpar(h, 'CRVAL'+strc(fix(axis))) ) * c / f0
    dv =  sxpar(h, 'CDELT'+strc(fix(axis))) * c / f0
    v = v*(-1*dv) + v0
endelse

return, v

end
