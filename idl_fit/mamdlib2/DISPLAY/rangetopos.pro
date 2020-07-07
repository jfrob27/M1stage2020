function rangetopos, pos, xr, yr, dataxr, datayr

result = fltarr(4)
dpx = pos(2)-pos(0)
dpy = pos(3)-pos(1)
dxr = xr(1)-xr(0)
dyr = yr(1)-yr(0)

result(0) = (dataxr(0)-xr(0))*dpx/dxr + pos(0)
result(1) = (datayr(0)-yr(0))*dpy/dyr + pos(1)
result(2) = (dataxr(1)-xr(0))*dpx/dxr + pos(0)
result(3) = (datayr(1)-yr(0))*dpy/dyr + pos(1)

return, result

end
