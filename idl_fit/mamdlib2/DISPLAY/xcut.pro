;---------------------------
pro xcut_update, id, x, y, xrange=xrange, yrange=yrange, imrange=imrange, $
                 charsize=charsize, position=position, xsize=xsize, ysize=ysize, erase=erase

widget_control, id, get_uvalue=infoptr
info = *infoptr

if keyword_set(xrange) then info.xrange=xrange
if keyword_set(yrange) then info.yrange=yrange
if keyword_set(imrange) then info.imrange=imrange
if keyword_set(position) then info.position=position
if keyword_set(charsize) then info.charsize=charsize
if keyword_set(xsize) then widget_control, info.drawid, draw_xsize = xsize
if keyword_set(ysize) then widget_control, info.drawid, draw_ysize = ysize
if not keyword_set(erase) then erase=0

if keyword_set(x) and not keyword_set(y) then *info.yptr = x
if keyword_set(y) and keyword_set(x) then begin
    *info.xptr = x
    *info.yptr = y
endif

xcut_plot, info, erase=erase
*infoptr = info

end

;---------------------------------------
pro xcut_clean, id

widget_control, id, get_uvalue=infoptr
ptr_free, (*infoptr).xptr
ptr_free, (*infoptr).yptr
ptr_free, infoptr

end 

;##################################################
pro xcut_plot, info, erase=erase

wset, info.wid

case info.mode of
    0: pos_row = info.position
    1: pos_col = info.position
    2: begin
        pos_row = [info.position(0), info.position(1), info.position(2)*0.45, info.position(3)]
        pos_col = [info.position(2)*0.5, info.position(1), info.position(2), info.position(3)]
    end
endcase

row_range = [  [info.xrange], [info.imrange] ]
col_range = [  [info.imrange], [info.yrange] ]
row_title = [ 'pixels', info.units ]
col_title = [ info.units, 'pixels' ]

; ERASE PREVIOUS
if keyword_set(erase) then erase else begin
    row = *info.xbeforeptr
    col = *info.ybeforeptr
    nrow = findgen(n_elements(row))
    ncol = findgen(n_elements(col))
    if info.mode eq 0 or info.mode eq 2 then plot, nrow, row, psym=10, position=pos_row, $
      /normal, xs=5, ys=5, charsize=info.charsize, $
      yr=row_range(*,1), xr=row_range(*,0), /noerase, col=0
    if info.mode eq 1 or info.mode eq 2 then plot, col, ncol, psym=10, position=pos_col, $
      /normal, xs=5, ys=5, charsize=info.charsize, $
      yr=col_range(*,1), xr=col_range(*,0), /noerase, col=0
endelse


; PLOT CURRENT
row = *info.xptr
col = *info.yptr
nrow = findgen(n_elements(row))
ncol = findgen(n_elements(col))
if info.mode eq 0 or info.mode eq 2 then plot, nrow, row, psym=10, position=pos_row, $
  /normal, xs=1, ys=1, charsize=info.charsize, $
  yr=row_range(*,1), xr=row_range(*,0), /noerase, xtitle=row_title(0), ytitle=row_title(1)
if info.mode eq 1 or info.mode eq 2 then plot, col, ncol, psym=10, position=pos_col, $
  /normal, xs=1, ys=1, charsize=info.charsize, $
  yr=col_range(*,1), xr=col_range(*,0), /noerase, xtitle=col_title(0), ytitle=col_title(1)


info.xbeforeptr = ptr_new( *info.xptr )
info.ybeforeptr = ptr_new( *info.yptr )

end

;---------------------------------------
pro xcut_event, event

widget_control, event.id, get_uvalue=eventval
widget_control, event.top, get_uvalue=infoptr
info = *infoptr

case eventval of
    'col':begin
        info.mode = 0
        widget_control, info.drawid, draw_xsize=info.zsize, draw_ysize=info.ysize
        xcut_plot, info, /erase
        *infoptr = info
    end
    'row':begin
        info.mode = 1
        widget_control, info.drawid, draw_xsize=info.xsize, draw_ysize=info.zsize
        xcut_plot, info, /erase
        *infoptr = info
    end
    'both':begin
        info.mode = 2
        widget_control, info.drawid, draw_xsize=2*info.zsize, draw_ysize=info.zsize
        xcut_plot, info, /erase
        *infoptr = info
    end
    'close':begin
        widget_control, event.top, /destroy
    end

endcase

end

;------------------------
pro xcut, x, y, i, j, xrange=xrange, yrange=yrange, imrange=imrange, indef=indef,  id=base, $
           xsize=xsize, ysize=ysize, zsize=zsize, charsize=charsize, units=units

xptr = ptr_new(reform(x))
yptr = ptr_new(reform(y))
xbeforeptr = ptr_new(reform(x))
ybeforeptr = ptr_new(reform(y))

if not keyword_set(units) then units=''
if not keyword_set(indef) then indef=-32768.
if not keyword_set(xrange) then xrange = [0., n_elements(*xptr)-1]
if not keyword_set(yrange) then yrange = [0., n_elements(*yptr)-1]
if not keyword_set(imrange) then imrange = compute_range([*yptr, *xptr], indef=indef)
if not keyword_set(charsize) then charsize=1.

;------- LAYOUT WIDGET ----------------
base = widget_base(title='Xcut', /column)
button_base = widget_base( base, /row )
b1 = widget_button( button_base, xsize=60, ysize=20, uvalue='row', value='Row')
b2 = widget_button( button_base, xsize=60, ysize=20, uvalue='col', value='Column')
b3 = widget_button( button_base, xsize=60, ysize=20, uvalue='both', value='Both')
b4 = widget_button( button_base, xsize=60, ysize=20, uvalue='close', value='Close')
if not keyword_set(xsize) then xsize = 300
if not keyword_set(ysize) then ysize = 300
if not keyword_set(zsize) then zsize = 300
drawid = widget_draw(base, xsize=xsize, ysize=zsize, uvalue='draw', retain=2)

;-------- REALIZE WIDGET--------------
widget_control, base, /realize

;---------SET STRUCTURE----------------
widget_control, drawid, get_value=wid
info = {wid:wid, position:[0.18,0.15,0.9,0.9], yrange:yrange, xrange:xrange, imrange:imrange, drawid:drawid, $
        charsize:charsize, xptr:xptr, yptr:yptr, xbeforeptr:xbeforeptr, ybeforeptr:ybeforeptr, units:units, mode:0, $
        xsize:xsize, ysize:ysize, zsize:zsize}

infoptr = ptr_new( info )
widget_control, base, set_uvalue=infoptr

;------ DISPLAY CUT --------------
xcut_plot, info

xmanager, 'xcut', base, /no_block, cleanup='xcut_clean'

CLOSING:

end
