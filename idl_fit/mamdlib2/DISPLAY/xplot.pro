;---------------------------
pro xplot_update, id, x, y, xrange=xrange, yrange=yrange, xtitle=xtitle, ytitle=ytitle, title=title, charsize=charsize, $
                  position=position, xsize=xsize, ysize=ysize

widget_control, id, get_uvalue=infoptr
info = *infoptr

if keyword_set(xrange) then info.xrange=xrange
if keyword_set(yrange) then info.yrange=yrange
if keyword_set(xtitle) then info.xtitle=xtitle
if keyword_set(ytitle) then info.ytitle=ytitle
if keyword_set(title) then info.title=title
if keyword_set(position) then info.position=position
if keyword_set(charsize) then info.charsize=charsize
if keyword_set(xsize) then widget_control, info.drawid, draw_xsize = xsize
if keyword_set(ysize) then widget_control, info.drawid, draw_ysize = ysize

if keyword_set(x) and not keyword_set(y) then *info.yptr = x
if keyword_set(y) and keyword_set(x) then begin
    *info.xptr = x
    *info.yptr = y
endif

*infoptr = info
xplot_plot, info

end

;--------------------------------------
pro xplot_xytoij, x, y, i, j, info

wset, info.wid
xsize = !d.x_size
ysize = !d.y_size

i = ( ( 1.*x / xsize ) - info.position(0) ) * ( info.xrange(1)- info.xrange(0) ) / (info.position(2)-info.position(0))+ info.xrange(0)
i = i > info.xrange(0) < info.xrange(1)
j = ( ( 1.*y / ysize ) - info.position(1) ) * ( info.yrange(1)- info.yrange(0) ) / (info.position(3)-info.position(1))+ info.yrange(0)
j = j > info.yrange(0) < info.yrange(1)

end

;---------------------------------------
pro xplot_clean, id

widget_control, id, get_uvalue=infoptr
ptr_free, (*infoptr).xptr
ptr_free, (*infoptr).yptr
ptr_free, infoptr

end 

;##################################################
pro xplot_plot, info

wset, info.wid

plot, *info.xptr, *info.yptr, psym=10, position=info.position, /normal, /xs, /ys, charsize=info.charsize, yr=info.yrange, $
  title=info.title, xtitle=info.xtitle, ytitle=info.ytitle, xr=info.xrange

end

;---------------------------------------
pro xplot_event, event

widget_control, event.id, get_uvalue=eventval
widget_control, event.top, get_uvalue=infoptr
info = *infoptr

case eventval of
    'draw': begin
        if event.press gt 0 then begin
            info.tempo = [ event.x, event.y ]
            *infoptr = info
        endif
;------ LEFT BUTTON --- XRANGE ------------
        if event.release eq 1 and abs( event.x - info.tempo(0) ) gt 5 then begin
            xplot_xytoij, event.x, event.y, xval, yval, info
            xplot_xytoij, info.tempo(0), info.tempo(1), x0, y0, info
            minv = min([ xval, x0] )
            maxv = max([ xval, x0] )
            info.xrange(0) = minv
            info.xrange(1) = maxv
            xplot_plot, info
            *infoptr = info
        endif

;------ RIGHT BUTTON --- YRANGE ------------
        if event.release eq 4 and abs( event.y - info.tempo(1) ) gt 5 then begin
            xplot_xytoij, event.x, event.y, xval, yval, info
            xplot_xytoij, info.tempo(0), info.tempo(1), x0, y0, info
            minv = min([ yval, y0] )
            maxv = max([ yval, y0] )
            info.yrange(0) = minv
            info.yrange(1) = maxv
            xplot_plot, info
            *infoptr = info
        endif

;------ MIDDLE BUTTON --- BACK TO MAX ------------
        if event.release eq 2 then begin
            info.xrange = [0., n_elements(*info.yptr)-1]
            info.yrange = minmax( *info.yptr )
            xplot_plot, info
            *infoptr = info
        endif
    end
endcase

end

;------------------------
pro xplot, x, y, xrange=xrange, yrange=yrange, indef=indef, xtitle=xtitle, ytitle=ytitle, title=title, id=base, $
           xsize=xsize, ysize=ysize, charsize=charsize

if not keyword_set(y) then begin
    yptr = ptr_new(x)
    xaxis = findgen(n_elements(x))
    xptr = ptr_new(xaxis)
endif else begin
    xptr = ptr_new(x)
    yptr = ptr_new(y)
endelse

if not keyword_set(indef) then indef=-32768.
ind_good = where(*yptr ne indef, nbind)
;if nbind eq 0 then begin
;    print, 'No defined values'
;    goto, CLOSING
;endif

if not keyword_set(yrange) then yrange = compute_range(*yptr, indef=indef)
if not keyword_set(xrange) then xrange = [0., n_elements(*yptr)-1]
if not keyword_set(xtitle) then xtitle=' '
if not keyword_set(ytitle) then ytitle=' '
if not keyword_set(title) then title=' '
if not keyword_set(charsize) then charsize=1.

;------- LAYOUT WIDGET ----------------
base = widget_base(title='Xplot', /column)
if not keyword_set(xsize) then xsize = 300
if not keyword_set(ysize) then ysize = 300
drawid = widget_draw(base, xsize=xsize, ysize=ysize, uvalue='draw', /button_event, retain=2)

;-------- REALIZE WIDGET--------------
widget_control, base, /realize

;---------SET STRUCTURE----------------
widget_control, drawid, get_value=wid
info = {wid:wid, position:[0.15,0.15,0.9,0.9], yrange:yrange, xrange:xrange, drawid:drawid, $
        xtitle:xtitle, ytitle:ytitle, title:title, charsize:charsize, xptr:xptr, yptr:yptr, tempo:[0, 0]}

infoptr = ptr_new( info )
widget_control, base, set_uvalue=infoptr

;------ DISPLAY HISTO --------------
xplot_plot, info

xmanager, 'xplot', base, /no_block, cleanup='xplot_clean'

CLOSING:

end
