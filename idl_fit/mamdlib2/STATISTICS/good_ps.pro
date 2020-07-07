pro good_ps, a_in, powerspec, kvec, reso=reso, median=powerspec_med, removecross=removecross, p2=p2, $
             allscale=allscale

;+
; NAME: 
;
;
;
; PURPOSE:
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
; 
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;	
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-

if not keyword_set(reso) then reso = 1. ; the size of one pixel (resolution)
si_im = size(a_in)

if si_im(0) eq 1 then begin

;-----------------------------------------------------------------------------
; 1D case:
;---------
; The FFT program of IDL normalizes (division) the direct Fourier Transform
; by N (the number of elements of the vector).
;
; When the FTT is multiplied by N, the Parseval theorem is satisfied:
; sum (h(x))^2 = sum (H(k))^2 / N
;
;-----------------------------------------------------------------------------

    nb = si_im(1)/2.

; Compute the FFT and renormalise it
    imfft = fft(a_in, -1)*si_im(1)

; Compute the Power spectrum
; The factor 2 is to take into account the negative frequencies
    p2 = 2*(abs(imfft))^2       
    powerspec = p2(0:nb-1)

; Compute the wave vector
    pas_k = 1./(2*(nb-1))
    kvec = findgen(nb)*pas_k/reso

endif else begin

;-----------------------------------------------------------------------------
; 2D case:
;---------
; In 2D the normalisation factor is sqtr(N1*N2) where N1 and N2 are
; the length of each axis of the image.
;
; Again the 2D Parseval theorem is also satisfied (note that the 1/N
; factor of the 1D Parseval theorem disapeared):
; sum (h(x,y))^2 = sum (H(kx,ky))^2
;
;-----------------------------------------------------------------------------


; Compute the FFT of the cross and remove it from the FFT of the image
; Remove a plnae from the original image (to get rid of the cross in
; the FFT)

    if keyword_set(removecross) then begin
        cross = a_in
        slope_x = (a_in(*,si_im(2)-1)-a_in(*,0))/si_im(2)
        slope_y = (a_in(si_im(1)-1,*)-a_in(0,*))/si_im(1)
        res = poly_fit(findgen(n_elements(slope_x)), slope_x, 3, yfit)
        slope_x = yfit
        res = poly_fit(findgen(n_elements(slope_y)), slope_y, 3, yfit)
        slope_y = yfit
        valX = median(reform(a_in(*,0)))
        valY = median(reform(a_in(0,*)))
        x = findgen(si_im(2))
        y = findgen(si_im(1))
        for i=0, si_im(1)-1 do cross(i,*) = valX+slope_x(i)*x
        for i=0, si_im(2)-1 do cross(*,i) = cross(*,i)+valY+slope_y(i)*y
        a = a_in-cross+avg(cross)
;        crossfft = shift(abs(fft(cross, -1)), si_im(1)/2, si_im(2)/2)*sqrt(si_im(1)*si_im(2))
;        zero = imfft(si_im(1)/2.,si_im(2)/2.)
;        imfft = imfft-crossfft
;        imfft(si_im(1)/2.,si_im(2)/2.) = zero
    endif else a = a_in

; Compute the FFT and renormalise it

    imfft = shift(abs(fft(a, -1)), si_im(1)/2, si_im(2)/2)*sqrt(si_im(1)*si_im(2))

; Compute the Power spectrum

    p2 = (imfft)^2

;stop

; Compute the map of the wave vector (k)

    xymap, si_im(1), si_im(2), xmap, ymap
    xmap = xmap-si_im(1)/2.
    ymap = ymap-si_im(2)/2.
    k_map = sqrt(xmap^2/si_im(1)^2 + ymap^2/si_im(2)^2)

; Compute the theta map

    xmap = xmap-si_im(1)/2.
    ymap = ymap-si_im(2)/2.
    theta = abs(atan(ymap, xmap))
    theta(where(theta gt !pi/2.)) = (!pi-theta(where(theta gt !pi/2.)))
    theta(where(theta gt !pi/4.)) = (!pi/2.-theta(where(theta gt !pi/4.)))

; Compute the mean power at each scale - azymutal average

    nb = min(si_im(1:2))/2.
    if keyword_set(allscale) then pas_k = max(k_map)/(nb-1.) else pas_k = 1./(2*(nb-1))
    kvec = findgen(nb)*pas_k
    powerspec = fltarr(nb)
    powerspec_med = fltarr(nb)
    powerspec(0) = imfft(si_im(1)/2, si_im(2)/2)
    powerspec_med(0) = imfft(si_im(1)/2, si_im(2)/2)
    for i=1, nb-1 do begin
;        ind = where(k_map gt kvec(i)-pas_k/2. and k_map le kvec(i)+pas_k/2., nbind)
        ind = where(k_map gt kvec(i)-pas_k/2. and k_map le kvec(i)+pas_k/2. and theta gt !pi/4.2, nbind)
        if (nbind gt 0) then begin
            powerspec(i) = avg(p2(ind))
            powerspec_med(i) = median(p2(ind))
        endif
    endfor
    kvec = kvec/reso

endelse

end
