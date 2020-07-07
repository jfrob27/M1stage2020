pro ellipse_healpix, position, thick=thick

if not keyword_set(thick) then thick=6

a = 393d
b = 195d
n=400
xvec = findgen(n)*2*a/(n-1.)-a
yvec = b*sqrt(1-xvec^2/a^2)
plot, [xvec, reverse(xvec)], [yvec,reverse(-1*yvec)],pos=position, /noerase, xr=[-400, 400], xs=5, yr=[-200,200], ys=5,thick=thick

end
