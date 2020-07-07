function fbm2d, exponent, nx, ny, seed, sigma=sigval, avg=avgval, $
                positive=positive, tab_k=tab_k, spec_k=spec_k, minvalue=minvalue, amplitude=amplitude
;+
; NAME:
;         FBM2d
;
; PURPOSE:
;        Produce a fractional Brownian motion (fBm) image with
;        a power law power spectrum.
;;
; CALLING SEQUENCE:
;        image = fbm2d( exponent, nx, ny)
;
; INPUTS:
;       exponent : spectral index of the power spectrum
;       nx: linear size of image (in X)
;       ny: linear size of image (in Y)
;
; OUTPUTS:
;      image: fltarr(nx, ny)
;
; EXAMPLE:
;     image = fbm2d(-3, 256, 256)
;
; MODIFICATION HISTORY:
;    Marc-Antoine Miville-Deschenes 10-01-2003
;-

if not keyword_set(minvalue) then minvalue=0.

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

; PHASE
phase = fltarr( nx, ny )
phase(*) = -32768.
for j=0, ny-1 do begin
    j2 = 2*ny_half - j
    for i=0, nx-1 do begin
        i2 = 2*nx_half - i
        if phase(i,j) eq -32768. then begin
            tempo = 2.0*(!pi)*randomu(seed )-(!pi)
            phase(i,j) = tempo
            if (i2 lt nx and j2 lt ny) then phase(i2,j2) = -1.*tempo
        endif
    endfor
endfor
phase = shift( phase, nx_half+odd_x, ny_half+odd_y )

; KMAT
xmap = fltarr(nx, ny)
ymap = fltarr(nx, ny)
for i=0, nx-1 do xmap(i,*) = ( i - nx_half ) / nx
for i=0, ny-1 do ymap(*,i) = ( i - ny_half ) / ny
kmat = sqrt(xmap^2 + ymap^2)
kmat( nx_half, ny_half ) = 1.
xmap = 0
ymap = 0

; AMPLITUDE
if keyword_set(tab_k) and keyword_set(spec_k) then begin
    amplitude = interpol(sqrt(1.d*spec_k), tab_k, kmat(*)) 
    amplitude = reform(amplitude, nx, ny)
endif else begin
    amplitude = kmat^(exponent/2.)
endelse

amplitude(nx_half, ny_half) = 0.
amplitude = shift( amplitude,  nx_half+odd_x, ny_half+odd_y )

; BACK TO REAL SPACE
imRE = amplitude * cos(phase)
imIM = amplitude * sin(phase)
imfft = complex( imRE, imIM )
image = float( fft(imfft, 1) )

;powspec_k_nosquare, image, 1., k, p
;image = image/p(n_elements(p)-1)
;image = image/sqrt(n_elements(image))

; Normalisation
 if not keyword_set(sigval) then sigval=1.
 if not keyword_set(avgval) then avgval=0.
 image = image/stddev(image)*sigval
; image = image*sigval/sqrt(n_elements(image))
 image = image + avgval

if keyword_set(positive) and min(image) lt minvalue then positive, image, minvalue=minvalue;, skewness=skewness

; if keyword_set(positive) and min(image) lt 0. then begin
;     image = image-min(image)
;     alphanext = 2.^(sigval/avgval)
;     a = avgval/avg(image^alphanext) 
;     dd = 0.05
;     nb = 5.
;     sigvec = fltarr(nb)
;     diff = 1 & diffprevious = 5
;     j=1.
;     while diff gt 0.01 do begin 
;         alphavec = linindgen(nb, alphanext*(1.-dd), alphanext*(1+dd)) 
;         for i=0, nb-1 do sigvec(i) = stdev(a*image^alphavec(i)) 
;         rien = min(abs(sigvec-sigval), wmin)
;         if (wmin(0) ne 0 and wmin(0) ne nb-1) then begin
;             alpha = interpol(alphavec, sigvec, sigval)
;         endif else begin
;             alpha = alphavec(wmin(0))
;         endelse
;         a = avgval/avg(image^alpha) 
;         np = a*image^alpha
;         avgnp = avg(np) 
;         stdnp = stdev(np)
;         diffprevious = diff
;         diff = abs((sigval-stdnp)/sigval) 
;         print, a, alpha, avgnp, avgval, stdnp, sigval, diff, abs(diff-diffprevious)/diff
;         if (diff gt 0.1) then begin
;             alphanext = alpha*alog(sigval)/alog(stdnp)
;             dd = 0.05
;         endif else begin
;             alphanext=alpha
;             dd = 0.005
;         endelse
;     endwhile
;     image = a*image^alpha
; endif

return, image

end
