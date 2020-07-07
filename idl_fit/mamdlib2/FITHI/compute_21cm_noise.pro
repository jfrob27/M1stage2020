function compute_21cm_noise, c, result, perc=perc

if not keyword_set(perc) then perc=1

si = size(c)
x = findgen(si[3])
model = tbfromfit(result, x)
diff = la_sub(c, model)

noise = fltarr(si[1], si[2])
noise[*] = -32768.
for j=0, si[2]-1 do begin
   for i=0, si[1]-1 do begin
      data = diff[i,j,*]
      if (max(data) ne -32768.) then begin
         tmp = statmamd(data, perc)
         noise[i,j] = sqrt(tmp[1])
      endif
   endfor
endfor


return, noise

end
