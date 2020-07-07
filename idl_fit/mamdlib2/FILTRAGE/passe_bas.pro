function passe_bas, spectre, frequence

;--------------------------------------------
;
; PASSE_BAS
;
; Effectue un filtrage passe bas d'un
; vecteur. 
; 
; MAMD 17/11/97
;
;--------------------------------------------

si_spectre = size(spectre)


if (si_spectre(0) eq 1) then begin
    tf = fft(spectre, -1)
    amplitude = abs(tf)
    phase = atan(imaginary(tf),float(tf)) & $
      
    filtre = fltarr(si_spectre(1))
    filtre(*) = 1.
    filtre(0:(frequence-1)) = 0.
    filtre((si_spectre(1)-frequence):(si_spectre(1)-1)) = 0.
    filtre(frequence-3:frequence+1) = sin([0.05, 0.1, !pi/6., 3*!pi/8., 5*!pi/12.])
    filtre(si_spectre(1)-frequence-2:si_spectre(1)-frequence+2) = sin([5*!pi/12., 3*!pi/8., !pi/6., 0.1, 0.05])
;    filtre(frequence-1:frequence+1) = -32768
;    filtre(si_spectre(1)-frequence-1:si_spectre(1)-frequence+1) = -32768
;    ind1 = where(filtre eq -32768)
;    ind2 = where(filtre ne -32768)
;    filtre(ind1) = interpol(filtre(ind2), ind2, ind1)
; plot, filtre, yr=[-0.2, 1.2], ystyl=1
;    amplitude(0:(frequence-1))=median(amplitude) & $
;    amplitude((si_spectre(1)-frequence):(si_spectre(1)-1))=median(amplitude) & $
    amplitude = amplitude*filtre

    reel = amplitude/(sqrt(1+(tan(phase))^2)) & $
    ind = where(abs(phase) gt !pi/2., nbphase) & $
    if (nbphase gt 0) then reel(ind) = reel(ind)*(-1.) & $
    imag = reel*tan(phase) & $
    tfb = complex(reel, imag) & $
    spectreb = float(fft(tfb,1)) & $
    result = spectre-spectreb & $
endif 

if (si_spectre(0) eq 2) then begin
    tf = fft(spectre, -1)
    amplitude = abs(tf)
    phase = atan(imaginary(tf),float(tf)) & $
    amplitude = shift(amplitude, si_spectre(1)/2, si_spectre(2)/2)
    xymap, si_spectre(1), si_spectre(2), xmap, ymap
    distance = sqrt((xmap-si_spectre(1)/2)^2 + (ymap-si_spectre(2)/2)^2)
    ind = where(distance le frequence)
    amplitude(ind) = median(amplitude)
;    amplitude(0:(frequence-1))=median(amplitude) & $
;    amplitude((si_spectre(1)-frequence):(si_spectre(1)-1))=median(amplitude) & $
    
    amplitude = shift(amplitude, si_spectre(1)/2, si_spectre(2)/2)
    reel = amplitude/(sqrt(1+(tan(phase))^2)) & $
    ind = where(abs(phase) gt !pi/2., nbphase) & $
    if (nbphase gt 0) then reel(ind) = reel(ind)*(-1.) & $
    imag = reel*tan(phase) & $
    tfb = complex(reel, imag) & $
    spectreb = float(fft(tfb,1)) & $
    result = spectre-spectreb & $
endif
	
return, result

end
