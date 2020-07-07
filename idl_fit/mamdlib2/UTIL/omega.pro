function omega, beam

; return the solid angle of a beam (given in degrees)

result = !pi^3 / 4. / 180.^2 * beam^2

return, result

end
