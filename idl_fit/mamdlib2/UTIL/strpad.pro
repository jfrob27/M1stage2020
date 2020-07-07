function strpad, strin, len, pad, first=first, last=last

if not keyword_set(last) then first=1
if not keyword_set(pad) then pad=' '

nb = len-strlen(strin)

strout = strin
for i=0, nb-1 do begin 
   if keyword_set(first) then strout = pad+strout else strout = strout+pad
endfor

return, strout

end

   
