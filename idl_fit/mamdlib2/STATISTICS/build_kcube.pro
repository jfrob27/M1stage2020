function build_kcube, na, nb, nc

kcube = fltarr(na, nb, nc)

im = fix(na/2.)
jm = fix(nb/2.)
km = fix(nc/2.)

for k=0., nc-1 do begin 
    z = ( k - km ) / nc
    for j=0., nb-1 do begin 
        y = ( j - jm ) / nb
        for i=0., na-1 do begin 
            x = ( i - im ) / na
            kcube(i,j,k) = sqrt( x^2 + y^2 + z^2 )
        endfor
    endfor
endfor

return, kcube

end
