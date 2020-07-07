pro ps2pdf, psfile, pdffile, dir=dir, rmps=rmps

; merge one or several PostScript files in one pdf file
;
; examples : 
; ps2pdf, ['toto.ps', 'allo.ps'], 'result.pdf'
; ps2pdf, "*.ps", 'result.pdf'
;
; requires "gs"
;
; Marc-Antoine Miville-Deschenes, Oct, 6, 2009

spawn, 'which gs', res, err
if not keyword_set(res) then begin
   print, 'ABORT : gs not available. Can not merge postscript files'
   return
endif

if not keyword_set(pdffile) then pdffile = "allps.pdf"

psfile_list = ''
if (n_elements(psfile) gt 1) then begin
   for i=0, n_elements(psfile)-1 do psfile_list = psfile_list + psfile[i] + ' '
endif else begin
   psfile_list = psfile
endelse

if keyword_set(dir) then cd, dir, current=old_dir
spawn, "gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="+pdffile+" "+psfile_list
if keyword_set(rmps) then spawn, 'rm -f '+psfile_list
if keyword_set(dir) then cd, old_dir

end

