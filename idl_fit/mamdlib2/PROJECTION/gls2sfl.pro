pro gls2sfl, h1

cvec = ['CTYPE1', 'CTYPE2']
for i=0, 1 do begin
  ctype = sxpar(h1, cvec(i))
  b = strmid(ctype, 0, 4)
  t = strmid(ctype, 5, 3)
  if (strmid(ctype, 5, 3) eq 'GLS') then t = 'SFL'
  result = b + '-' + t
  sxaddpar, h1, cvec(i), result
endfor

end
