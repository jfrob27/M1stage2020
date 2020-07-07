function kcube, nx, ny, nz

; CHECK DIMENSIONS ( ODD or EVEN )
if ( nx mod 2 ) ne 0 then begin
    nx_half = (nx-1.)/2.
    odd_x = 1
endif else begin
    nx_half = nx/2.
    odd_x = 0
endelse
if ( ny mod 2 ) ne 0 then begin
    ny_half = (ny-1.)/2.
    odd_y = 1
endif else begin
    ny_half = ny/2.
    odd_y = 0
endelse
if ( nz mod 2 ) ne 0 then begin
    nz_half = (nz-1.)/2.
    odd_z = 1
endif else begin
    nz_half = nz/2.
    odd_z = 0
endelse

; PHASE and WAVE NUMBER (kcube)
kcub = fltarr( nx, ny, nz )
for k=0, nz-1 do begin
    z = ( k - nz_half ) / nz
    for j=0, ny-1 do begin
        y = ( j - ny_half ) / ny
        for i=0, nx-1 do begin
            x = ( i - nx_half ) / nx
            kcub(i,j,k) = sqrt( x^2 + y^2 + z^2 )
        endfor
    endfor
endfor
kcub( nx_half, ny_half, nz_half ) = 1.

return, kcub

end
