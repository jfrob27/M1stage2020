function bnu_planck, lambda, temp

; lambda : wavelength vector in MICRON
; temp : Temperature vector in KELVIN
;
; spectrum : brightness array in W/m^2/sr/Hz
;

c = 1d*3.0e14  ; light speed in micron/sec

sizel = size(lambda)
sizet = size(temp)
if (sizel(0) gt 0) then nbl = sizel(1) else nbl=1
if (sizet(0) gt 0) then nbt = sizet(1) else nbt=1
spectrum = fltarr(nbl, nbt)

for i=0L, nbt-1 do begin
    nubnu_planck, lambda*1.e-6, temp(i), tempo
    spectrum(*,i) = tempo*lambda/c
endfor

spectrum = reform(spectrum)

return, spectrum

end
