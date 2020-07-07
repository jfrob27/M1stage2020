pro writeheader, header, filename
;+
; NAME:
;       WRITEHEADER
; PURPOSE:
;       Write a header in a text file
;
; CALLING SEQUENCE:
;       writeheader, header, filename
; 
; INPUTS:
;       header: the header to be writen (string array)
;       filename: the name of the file (string)
;
; MODIFICATION HISTORY:
;       Marc-Antoine Miville-Deschenes, 1/2/2000
;-

openw, 1, filename
for i=0, n_elements(header)-1 do begin
    printf, 1, header(i)
endfor
close, 1

end
