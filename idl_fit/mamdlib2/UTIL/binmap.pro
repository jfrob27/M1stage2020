function binmap, x, y, xr, yr, nbx=nx, nby=ny

if not keyword_set(nx) then nx=30.
if not keyword_set(ny) then ny=30.
  bin = fltarr(2)
  bin[0] = (xr[1]-xr[0])/(1.*nx)
  bin[1] = (yr[1]-yr[0])/(1.*ny)
  nbx = ceil((xr[1]-xr[0])/bin[0])
  nby = ceil((yr[1]-yr[0])/bin[1])
  tmp = fltarr(nbx, nby)
  xi = round((x-xr[0])/bin[0])
  yi = round((y-yr[0])/bin[1])
  for i=0L, n_elements(xi)-1 do begin
     if (xi[i] ge 0 and xi[i] lt nbx and yi[i] ge 0 and yi[i] lt nby) then $
        tmp[xi[i], yi[i]] = tmp[xi[i], yi[i]] + 1
  endfor

return, tmp

end
