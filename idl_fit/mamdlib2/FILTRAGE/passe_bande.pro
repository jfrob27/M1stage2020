function passe_bande, spectre, frequence

;--------------------------------------------
;
; PASSE_BAS
;
; Effectue un filtrage passe bande d'un
; vecteur. On conserve toutes les frequences
; entre frequence(0) et frequence(1)
;
; MAMD 17/11/97
;
;--------------------------------------------

si_spectre = size(spectre)

tf = fft(spectre, -1)
amplitude = abs(tf)
phase = atan(imaginary(tf),float(tf)) & $

if (si_spectre(0) eq 1) then begin
;    amplitude(0:(frequence-1))=median(amplitude)
;
;    amplitude((si_spectre(1)-frequence):(si_spectre(1)-1))=median(amplitude)
;    samplitude = smooth(amplitude, 5)
    amplitude(frequence(0):(frequence(1)-1)) = median(amplitude)
    amplitude((si_spectre(1)-frequence(1)):(si_spectre(1)-1-frequence(0))) = median(amplitude)
endif
if (si_spectre(0) eq 2) then begin
    xs = si_spectre(1)/2.
    ys = si_spectre(2)/2.
    amps = shift(amplitude, xs, ys)
    amps((xs-frequence):(xs+frequence), $
              (ys-frequence):(ys+frequence))=median(amplitude)
    amplitude = shift(amps, xs, ys)
endif

reel = amplitude/(sqrt(1+(tan(phase))^2)) & $
ind = where(abs(phase) gt !pi/2., nbphase) & $
if (nbphase gt 0) then reel(ind) = reel(ind)*(-1.) & $
imag = reel*tan(phase) & $
tfb = complex(reel, imag) & $
spectreb = float(fft(tfb,1)) & $
result = spectre-spectreb & $
	
return, result

end
