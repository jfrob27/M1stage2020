function fbm3d, exponent, nx, ny, nz, avg=avgval, sigma=sigval, positive=positive

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
kcube = fltarr( nx, ny, nz )
phase = fltarr( nx, ny, nz )
phase(*) = -32768.
for k=0, nz-1 do begin
    z = ( k - nz_half ) / nz
    k2 = 2*nz_half - k
    for j=0, ny-1 do begin
        y = ( j - ny_half ) / ny
        j2 = 2*ny_half - j
        for i=0, nx-1 do begin
            x = ( i - nx_half ) / nx
            i2 = 2*nx_half - i
            kcube(i,j,k) = sqrt( x^2 + y^2 + z^2 )
            if phase(i,j,k) eq -32768. then begin
                tempo = 2.0*(!pi)*randomu(seed )-(!pi)
                phase(i,j,k) = tempo
                if (i2 lt nx and j2 lt ny and k2 lt nz) then phase(i2,j2,k2) = -1.*tempo
            endif
        endfor
    endfor
endfor
phase = shift( phase, nx_half+odd_x, ny_half+odd_y, nz_half+odd_z )
kcube( nx_half, ny_half, nz_half ) = 1.

; AMPLITUDE
amplitude = kcube^(exponent/2.)
amplitude( nx_half, ny_half, nz_half ) = 0.
amplitude = shift( amplitude,  nx_half+odd_x, ny_half+odd_y, nz_half+odd_z )
kcube = 0

; BACK TO REAL SPACE
imRE = amplitude * cos(phase)
imIM = amplitude * sin(phase)
imfft = complex( imRE, imIM )
imRE = 0
imIM = 0
amplitude = 0
phase = 0
cube = float( fft(imfft, 1) )


; Normalisation
if not keyword_set(sigval) then sigval=1.
if not keyword_set(avgval) then avgval=0.
cube = cube/stddev(cube)*sigval
;cube = cube*sigval/sqrt(n_elements(cube))
cube = cube + avgval

if keyword_set(positive) and min(cube) lt 0. then positive, cube

return, cube

end
