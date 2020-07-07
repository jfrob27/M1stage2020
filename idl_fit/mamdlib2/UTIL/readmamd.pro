function readmamd, filename, delimiter, indef=indef, regex=regex

if not keyword_set(indef) then indef=0.
if not keyword_set(delimiter) then delimiter=' '

; OPEN FILE
openr, inunit,  filename, /get_lun

; INITIALIZE
value = ' '
nb_value = 0

; READ FILE
line = '' & READF, inunit, line
WHILE NOT EOF(inunit) DO BEGIN
   if (strmid(line, 0, 1) ne '#') then begin      
      line = strtrim(line,2) ; remove leading and trailing blank
      tempo = strsplit(line, delimiter, /extract, regex=regex)
      nb_value = [nb_value, n_elements(tempo)]
      value = [value, tempo]
   endif
   READF, inunit, line
;   print, n_elements(nb_value)
ENDWHILE
tempo = strsplit(line, delimiter, /extract, regex=regex)
nb_value = [nb_value, n_elements(tempo)]
value = [value, tempo]
nb_value = nb_value(1:*)
value = value(1:*)
free_lun, inunit

; BUILD OUTPUT MATRIX
nbcol = max(nb_value)
nbline = n_elements(nb_value)
result = strarr(nbcol, nbline)
result(*) = string(indef)
i0=0.
for i=0L, nbline-1 do begin & $
    i1 = i0 + nb_value(i)-1 & $
    result(0:nb_value(i)-1, i) = value(i0:i1) & $
    i0 = i1+1 & $
endfor

return, result

end
