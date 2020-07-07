function gauss2d, size, sigval

; Return a 2D Gaussian, properly normalized
;
; MAMD. 7 octobre 2003

r = shift(dist(size, size), fix(size/2.), fix(size/2.))
result = exp(-r^2/(2*sigval^2)) / (2*!pi*sigval^2)

return, result

end

