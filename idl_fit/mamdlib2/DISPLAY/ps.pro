pro ps, file=file, eps=eps, xsize=xsize, ysize=ysize, $
        xoffset=xoffset, yoffset=yoffset, landscape=landscape, bits=bits, ratio=ratio, true=true

; current size of the window display
cXSIZE = !D.X_SIZE
cYSIZE = !D.Y_SIZE
!MAMDLIB.cXSIZE = cXSIZE
!MAMDLIB.cYSIZE = cYSIZE

xsize_max = 18.5
ysize_max = 25.

if not keyword_set(bits) then bits=4
if not keyword_set(num_table) then num_table = 0
if not keyword_set(file) then file='idl.ps'
if not keyword_set(eps) then eps=0

; LANDSCAPE
if keyword_set(landscape) then begin
    if not keyword_set(xsize) then xsize = 25.
    if not keyword_set(ysize) then ysize = 18.5
    if keyword_set(ratio) then begin
        xsize = (cXSIZE * ysize / cYSIZE ) < ysize_max
        ysize = cYSIZE * xsize / cXSIZE
    endif
    if not keyword_set(xoffset) then xoffset = (21.-ysize)/2.
    if not keyword_set(yoffset) then yoffset = xsize + (29.7-xsize)/2.
endif else begin

; PORTRAIT
    landscape=0
    if not keyword_set(xsize) then xsize = 18.5
    if not keyword_set(ysize) then ysize = 25.
    if keyword_set(ratio) then begin
        ysize = (cYSIZE * xsize / cXSIZE) < ysize_max
        xsize = cXSIZE * ysize / cYSIZE
    endif       
    if not keyword_set(xoffset) then xoffset = (21.-xsize)/2.
    if not keyword_set(yoffset) then yoffset = (29.7-ysize)/2.
endelse

!MAMDLIB.ps_sizex = xsize
!MAMDLIB.ps_sizey = ysize

set_plot,'ps', /copy, /interpolate
!P.COLOR = !MAMDLIB.COLOR
!P.BACKGROUND = !MAMDLIB.BACKGROUND

;if (num_table ne 0 or keyword_set(true)) then color=1 else color=0
;color=1
set_font = !MAMDLIB.PS_FONT

device, /color, file=file, encapsulated=eps, xoffset=xoffset, $
	yoffset=yoffset, xsize=xsize, ysize=ysize, landscape=landscape, bits=bits, $
        set_font=set_font

;; if keyword_set(true) then loadct, 0 else begin
;;    if (!d.table_size lt 256) then loadct, numtab, /silent
;; endelse
;; if keyword_set(coltable) then begin
;;     r = coltable(*,0)
;;     g = coltable(*,1)
;;     b = coltable(*,2)
;; endif else tvlct, r, g, b, /get
;; tvlct, r, g, b
;; if (bits eq 4) then begin
;;     tvlct, r, g, b, /get
;;     r(240:*) = r(255)
;;     g(240:*) = g(255)
;;     b(240:*) = b(255)
;;     tvlct, r, g, b
;; endif

; THICK
!X.THICK = !MAMDLIB.PS_THICK
!Y.THICK = !MAMDLIB.PS_THICK

end
