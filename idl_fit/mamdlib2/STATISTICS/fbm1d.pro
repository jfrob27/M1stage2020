;+
; NAME:
;    FBM1d
;
; PURPOSE:
;    Produce a fractional Brownian motion (fBm) image with
;    a power law power spectrum.
;;
; CALLING SEQUENCE:
;    image = fbm1d( exponent, nx )
;
; INPUTS:
;    exponent : spectral index of the power spectrum
;    nx: size of vector
;
; OUTPUTS:
;    image: fltarr(nx)
;
; EXAMPLE:
;    image = fbm1d(-3./5, 10000)
;
; MODIFICATION HISTORY:
;    From Marc-Antoine Miville-Deschenes fbm2d
;    Alexis Lavabre 25-05-2007
;    20070525-11:38 : before adding cut and cell_size key_words
;    20070529-11:21 : before adding the shift of image to avoid
;    buggy behaviour (product of 2 call of fbm1d shows low frequencies)
;-

function fbm1d, exponent, nx, sigma=sigval, avg=avgval, cutlow=cutlow, $
                cuthigh=cuthigh, cell_size=cell_size

if ( nx mod 2 ) ne 0 then begin
    nx_half = (nx-1.)/2.
    odd_x = 1
endif else begin
    nx_half = nx/2.
    odd_x = 0
endelse

; PHASE
phase = fltarr( nx )
phase(*) = -32768.
for i=0UL, nx-1 do begin
    i2 = 2*nx_half - i
    if phase(i) eq -32768. then begin
        tempo = 2.0*(!pi)*randomu(seed )-(!pi)
        phase(i) = tempo
        if (i2 lt nx) then phase(i2) = -1.*tempo
    endif
endfor
phase = shift( phase, nx_half+odd_x )

; K VECTOR
if not (n_elements(cell_size) gt 0) then cell_size = 1.
nx_size = nx * cell_size
kvect = fltarr(nx)
kvect = (ulindgen(nx)-nx_half)/nx_size
kvect = abs(kvect)
kvect( nx_half ) = 1.

; AMPLITUDE
amplitude = fltarr(nx)
amplitude = kvect^(exponent/2.)
if (n_elements(cutlow) gt 0) then begin
    del = where((kvect lt cutlow), count)
    if(count gt 0) then amplitude(del) = 0.
endif
if keyword_set(cuthigh) then begin
    del = where((kvect gt cuthigh), count)
    if(count gt 0) then amplitude(del) = 0.
endif
amplitude(nx_half) = 0.

amplitude = shift( amplitude,  nx_half+odd_x )

; BACK TO REAL SPACE
imRE = amplitude * cos(phase)
imIM = amplitude * sin(phase)
imfft = complex( imRE, imIM )
image = float( fft(imfft, 1) )

; Normalisation
if not keyword_set(sigval) then sigval=1.
if not keyword_set(avgval) then avgval=0.
image = image/stddev(image)*sigval
image = image + avgval

image = shift(image, randomu(seed)*nx+400)

return, image

end
