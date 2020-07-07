function hicolumndensity, cube, tspin=tspin, dv=dv, limit_tspin=limit_tspin

; limit_tspin : if set the spin temperature of a given spectrum 
; can not be lower than the maximum brightness temperature

if not keyword_set(dv) then dv=1.

f = dv*1.823e18/1.e20
if not keyword_set(tspin) then begin
   map = la_tot(cube, dim=-1)
   map = la_mul(map, f)
endif else begin
   ctempo = la_div(cube, tspin)
   ind = where(ctempo ne -32768.)
   if keyword_set(limit_tspin) then ctempo[ind] = ctempo[ind]<0.999
   ctempo[ind] = -1.*alog(1-ctempo[ind])
   map = la_mul(la_tot(ctempo, dim=-1), tspin)
   map = la_mul(map, f)
endelse

return, map

end
