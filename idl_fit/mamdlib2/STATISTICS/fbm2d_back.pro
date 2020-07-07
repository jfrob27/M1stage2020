function fbm2d, exponent, nxi, nyi

if ( nxi mod 2 ) ne 0 then nx = nxi else nx = nxi+1
if ( nyi mod 2 ) ne 0 then ny = nyi else ny = nyi+1

; PHASE
phase = fltarr( nx, ny )
p1 = 2.0*(!pi)*randomu(seed, nx, (ny-1)/2. )-(!pi)
phase(*,(ny-1)/2.+1:*) = p1
phase(*,0:(ny-1)/2.-1) = -1*rotate(p1, 2)
line = 2.0*(!pi)*randomu(seed, (nx-1)/2.+1 )-(!pi)
phase(0:(nx-1)/2., (ny-1)/2.) = line
phase((nx-1)/2.:*, (ny-1)/2.) = -1*reverse(line)
phase = shift( phase,  (nx-1)/2.+1, (ny-1)/2.+1 )

; KMAT
xymap, nx, ny, xmap, ymap
xmap = ( 1.*xmap - (nx - 1)/2. ) / nx
ymap = ( 1.*ymap - (ny - 1)/2.) / ny
kmat = sqrt(xmap^2 + ymap^2)
kmat((nx-1)/2.,(ny-1)/2.) = 1.

; AMPLITUDE
amplitude = kmat^(exponent/2.)
amplitude((nx-1)/2.,(ny-1)/2.) = 0.
amplitude = shift( amplitude,  (nx-1)/2.+1, (ny-1)/2.+1 )

; BACK TO REAL SPACE
imRE = amplitude * cos(phase)
imIM = amplitude * sin(phase)
imfft = complex( imRE, imIM )
image = float( fft(imfft, 1) )

return, image

end
