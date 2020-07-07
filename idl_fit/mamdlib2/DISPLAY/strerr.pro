function strerr, data, error, notex=notex

if (error ne 0.) then begin
   t = alog10(error)
   nbdigit = floor(t)
;   test = error/10.^(nbdigit)
   nbdigit = abs(nbdigit)
;   if (fix(test) eq 1) then nbdigit=nbdigit+1

   format = '(F20.'+strc(nbdigit)+')'
   d = strc(data, format=format)

;   nbdigit=nbdigit+1     ; add an extra digit for the uncertainty
   format = '(F20.'+strc(nbdigit)+')'
   e = strc(error, format=format)
   
   if keyword_set(notex) then result = d + ';' + e else result = '$'+d + ' \pm ' + e+'$'

endif else begin
   result = '---'
endelse

return, result

end
