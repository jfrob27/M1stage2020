pro daitoff, map, object=object, position=position, noerase=noerase, nolabel=nolabel, $
             grid=grid, symsize=symsize, align=align,l0=l0, _Extra=extra

; get color table (to restore it at the end)
tvlct, lctr, lctg, lctb, /get

if not keyword_set(position) then position=[0.1,0.1,0.9,0.9]
if keyword_set(noerase) then pos = position(0:1,*) else pos=position
if keyword_set(grid) and not keyword_set(gridcolor) then gridcolor='white'
if not keyword_set(symsize) then symsize=2
if not keyword_set(align) then align=0.
if not keyword_set(l0) then l0=0

imaffi, map, position=pos, /nocadre, _Extra=extra

; if keyword_set(imcontour) then contour, imcontour, level=level, position=position

xr=[180, -180]
yr=[-90,90]
plot, [-32768, -32768], [-32768, -32768], xr=xr, yr=yr, xs=5, ys=5, psym=3, position=position, $
  /noerase, xticks=18, yticks=9

; PLOT GRID
if keyword_set(gridcolor) then begin
   l = fltarr(180)
   b = findgen(180)-90.
    for i=0, 18 do begin 
        l(*) = 180-i*20
        aitoff, l, b, x, y 
        oplot, x, y, col=mcol(gridcolor) 
    endfor
    l = findgen(180)*2.-180.
    b = fltarr(180)
    for i=0, 7 do begin 
        b(*) = 70-i*20 
        aitoff, l, b, x, y 
        oplot, x, y, col=mcol(gridcolor) 
    endfor
; PLOT TICK LABELS
    l = indgen(17)*20-160
    b= fltarr(17)
    aitoff, l, b, x, y
    for i=0, 16 do xyouts, x(i), y(i), strcompress(string(l(i)+l0), /rem), chars=chars, $
      align=0.5, col=mcol(gridcolor)
    b = indgen(8)*20-70
    l= fltarr(8)
    aitoff, l, b, x, y
    for i=0, 7 do xyouts, x(i), y(i), strcompress(string(b(i)), /rem), chars=chars, $
      align=0.5, col=mcol(gridcolor)
endif


; OVERLAY OBJECTS
if keyword_set(object) then begin
    alpha = object.alpha
    delta = object.delta
    sym_size = object.sym_size
    sym_type = object.sym_type
    sym_fill = object.sym_fill
    sym_thick = object.sym_thick
    sym_color = object.sym_color
    label_text = object.label_text
    label_size = object.label_size
    label_color = object.label_color

    nbobj = n_elements(alpha)

    for i=0, nbobj-1 do begin 

        case sym_type(i) of
            'circle': plotsym, 0, sym_size(i), fill=sym_fill(i), thick=sym_thick(i)
            'downarrow': plotsym, 1, sym_size(i), fill=sym_fill(i), thick=sym_thick(i)
            'uparrow': plotsym, 2, sym_size(i), fill=sym_fill(i), thick=sym_thick(i)
            'star': plotsym, 3, sym_size(i), fill=sym_fill(i), thick=sym_thick(i)
            'triangle': plotsym, 4, sym_size(i), fill=sym_fill(i), thick=sym_thick(i)
            'downtriangle': plotsym, 5, sym_size(i), fill=sym_fill(i), thick=sym_thick(i)
            'leftarrow': plotsym, 6, sym_size(i), fill=sym_fill(i), thick=sym_thick(i)
            'rightarrow': plotsym, 7, sym_size(i), fill=sym_fill(i), thick=sym_thick(i)
            'square': plotsym, 8, sym_size(i), fill=sym_fill(i), thick=sym_thick(i)
            else:  plotsym, 0, sym_size(i), fill=sym_fill(i), thick=sym_thick(i)
        endcase

        aitoff, alpha(i)-l0, delta(i), x, y
        plots, x, y, psym=8, col=mcol(sym_color(i))

;        Display label
        if not keyword_set(nolabel) then begin
            if label_size(i) eq 0 then chars=1.e-6 else chars=label_size(i)
            xyouts, x, y, label_text(i), charsize=chars, col=mcol(label_color(i)), $
              align=align
        endif
    endfor
endif



; load back the original color table
tvlct, lctr, lctg, lctb

end
