function tequilib_hi, density

; Returns HI equilibrium temperature for a given density.
; This is based on the work of Wolfire et al. (2003) using the 
; Solar Neighborhood properties.
;
; MAMD Jan 17, 2012

restore, !MAMDLIB_DIR+'/FITHI/t_equilibre_hi.idl'
result = interpol(tequilibre, n, density)

return, result

end
