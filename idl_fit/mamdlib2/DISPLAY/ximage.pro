function ximage_spectrum, info

nb = n_elements(info.dataptr)
result = fltarr( nb )
for i=0, nb-1 do result(i) = (*info.dataptr[i])(info.i, info.j)

return, result

end

;---------------------------
pro set_reb_position, info

wset, info.imageid
size_image = [!d.x_size, !d.y_size]
xmarge_image = info.xmarge
ymarge_image = info.ymarge
si_map = [0., info.simage(2)-info.simage(0)+1, info.simage(3)-info.simage(1)+1]
margex = xmarge_image / size_image(0)
margey = ymarge_image / size_image(1)
sizex = size_image(0) - total(xmarge_image)
sizey= size_image(1) - total(ymarge_image)
reb = min( [1.*sizex/si_map(1), 1.*sizey/si_map(2)] )
dx = 1.- reb*si_map(1) / size_image(0)
if dx gt total(margex) then begin
    posx2 = dx/2.>margex(1)
    posx1 = dx-posx2
endif else begin
    posx1 = margex(0)
    posx2 = 1- (posx1 + reb*si_map(1)/size_image(0))
endelse
dy = 1.- reb*si_map(2) / size_image(1)
if dy gt total(margey) then begin
    posy2 = dy/2.>margey(1)
    posy1 = dy-posy2
endif else begin
    posy1 = margey(0)
    posy2 = 1- (posy1 + reb*si_map(2)/size_image(1))
endelse
pos_image = [posx1, posy1, 1-posx2, 1-posy2]
info.reb = ( pos_image(2)-pos_image(0) )*size_image(0) / si_map(1)
info.pos_image = pos_image

end

;-------------------------

pro xytoij, x, y, info, i, j

i = fix( ( x - info.pos_image(0)*info.size_image(0) ) / info.reb) + info.simage(0)
j = fix( ( y - info.pos_image(1)*info.size_image(1) ) / info.reb) + info.simage(1)

end

;-------------------------------------
pro ximage_clean, id

widget_control, id, get_uvalue=infoptr
ptr_free, (*infoptr).dataptr
ptr_free, infoptr

end 

;-----------------------------------------------
pro ximage_update, id

widget_control, id, get_uvalue=infoptr
info = *infoptr

simage = info.simage
data = (*info.dataptr[info.plane])(simage(0):simage(2),simage(1):simage(3))

bad_id = 0L
widget_control, info.ximrangeid , bad_id=bad_id
if bad_id eq 0 then begin
    ximrange_update, info.ximrangeid, data
endif else begin
    info.imrange = compute_range( data, percent=info.percent, nsigma=info.nsigma, indef=info.indef )
    *infoptr = info
    ximage_displayall, id
endelse

end

;------------------------------
pro ximage_displayall, id, param

widget_control, id, get_uvalue=infoptr
info = *infoptr
if keyword_set(param) then begin
    info.imrange = param.imrange
    info.percent = param.percent
    info.nsigma = param.nsigma
endif

info.erase = 1
ximage_image, info
ximage_plot, info
ximage_value, info
info.erase = 0
*infoptr = info

end

;---------------------------------------
pro ximage_image, info

wset, info.imageid
map = *info.dataptr[info.plane]
set_reb_position, info
reb = info.reb
position = info.pos_image
width_bar = 15./info.size_image(0)
space_bar = 5./info.size_image(0)

if info.erase ne 0 then erase

imaffi, map, header=info.header, imrange=info.imrange, position=position(0:1), reb=reb, s_image=info.simage

if info.erase eq 0 then begin
    dx = ( 1- position(2) ) * info.size_image(0) 
    dy = ( position(3) - position(1) ) *info.size_image(1) + 20.
    black = fltarr(dx, dy )
    imaffi, black, position = [position(2)+width_bar+space_bar+0.01, position(1)], /nocadre
endif
mamd_bar, [position(2)+space_bar, position(1), position(2)+width_bar+space_bar, position(3) ], imrange=info.imrange

end

;------------------------------------------------
pro ximage_plot, info, pi, pj

if not keyword_set(pi) then pi = info.i
if not keyword_set(pj) then pj = info.j

xrange = [info.simage(0), info.simage(2)]
yrange = [info.simage(1), info.simage(3)]

;--- plot column ---
if ( info.showcol ne 0 ) then begin
    wset, info.plotcolid
    col = (*info.dataptr[info.plane])( info.i, *)
    y = findgen(n_elements(col))
    pos_col = [info.pos_plot(0), info.pos_image(1), info.pos_plot(2), info.pos_image(3)]
    if info.erase eq 0 then begin
        if pi ne info.i then begin
            pcol = (*info.dataptr[info.plane])( pi, *)
            plot, pcol, y, xrange=info.imrange, yrange=yrange, ys=5, position=pos_col, xs=5, /noerase, col=0, psym=10
        endif
    endif  else erase
    plot, col, y, xrange=info.imrange, yrange=yrange, ys=1, position=pos_col, xs=1, /noerase, psym=10
endif

; --- plot row ----
if ( info.showrow ne 0 ) then begin
    wset, info.plotrowid
    row = (*info.dataptr[info.plane])(*,info.j)
    pos_row = [info.pos_image(0), info.pos_plot(1), info.pos_image(2), info.pos_plot(3)]
    if info.erase eq 0 then begin
        if pj ne info.j then begin
            prow = (*info.dataptr[info.plane])( *, pj)
            plot, prow, xrange=xrange, yrange=info.imrange, ys=5, position=pos_row, xs=5, /noerase, col=0, psym=10
        endif
    endif else erase
    plot, row, yrange=info.imrange, xrange=xrange, ys=1, position=pos_row, xs=1, /noerase, psym=10
endif

;----- plot spectrum -----
bad_id = 0L
widget_control, info.xplotid , bad_id=bad_id
if bad_id eq 0 then begin    
    title = "i: " + strcompress(string(fix(info.i)), /rem) + ", j: " + strcompress(string(fix(info.j)), /rem)
    xplot_update, info.xplotid, ximage_spectrum( info ), yrange=info.imrange, title=title
    widget_control, info.xplotid, get_uvalue=info_xplot
    wset, (*info_xplot).wid
    tvlct, r, g, b, /get
    plots, [info.plane, info.plane], (*info_xplot).yrange, col=mcol("lime")
    tvlct, r, g, b
endif

;----- plot cut -----

bad_id = 0L
widget_control, info.xcutid , bad_id=bad_id
if bad_id eq 0 then begin    
    xrange = [info.simage(0), info.simage(2)]
    yrange = [info.simage(1), info.simage(3)]
    xcut_update, info.xcutid, (*info.dataptr[info.plane])(*,info.j), (*info.dataptr[info.plane])(info.i,*), $
      imrange=info.imrange, xrange=xrange, yrange=yrange, erase=info.erase
endif

end

;-------------------------------------------
pro ximage_value, info

widget_control, info.iid, set_value='x='+strcompress(string(fix(info.i)), /rem)
widget_control, info.jid, set_value='y='+strcompress(string(fix(info.j)), /rem)
val = (*info.dataptr[info.plane])(info.i, info.j)
widget_control, info.valid, set_value='value='+strcompress(string(val), /rem)

end

;---------------------------------------
pro ximage_event, event

widget_control, event.id, get_uvalue=eventval
widget_control, event.top, get_uvalue=infoptr
info = *infoptr

case eventval of
    'image': begin
        pi = info.i
        pj = info.j
        xytoij, event.x, event.y, info, current_i, current_j
        if info.freeze eq 0 then begin
            info.i = current_i > info.simage(0) < info.simage(2)
            info.j = current_j > info.simage(1) < info.simage(3)
        endif
;        if info.freeze eq 0 and ( pi ne info.i or pj ne info.j) then begin
        if ( pi ne info.i or pj ne info.j) then begin
            ximage_plot, info, pi, pj
            ximage_value, info
        endif
        *infoptr = info
;--------- LEFT BUTTON ------        
        ; click set anchor position
        if (event.press eq 1) then begin
            info.zi = current_i
            info.zj = current_j
            *infoptr = info
        endif
        ; release produces zoom
        if (event.release eq 1) then begin
            xpos = [ min( [ info.zi, current_i ] ), max( [ info.zi, current_i ] )]
            ypos = [ min( [ info.zj, current_j ] ), max( [ info.zj, current_j ] )]
            ; zoom on sub-region if position after
            ; drag is far enough (5 in x and 5 in y) from the anchor position
            if (xpos(1) -xpos(0) gt 5 and ypos(1)-ypos(0) gt 5) then begin
                info.simage = [xpos(0), ypos(0), xpos(1), ypos(1)]
                info.erase = 1
                *infoptr = info
                ximage_update, event.top
            ; zoom in by a factor 2
            endif else begin
                si_map = info.size_map
                dx = fix( (info.simage(2)-info.simage(0)) / 4. )
                dy = fix( (info.simage(3)-info.simage(1)) / 4. )
                xmin = current_i-dx > 0
                xmax = (xmin+2*dx) < (si_map(1)-1)
                xmin = xmax - 2*dx
                ymin = current_j-dy > 0
                ymax = (ymin+2*dy) < (si_map(2)-1)
                ymin = ymax - 2*dy
                info.simage = [ xmin, ymin, xmax, ymax ]
                info.erase = 1
                *infoptr = info
                ximage_update, event.top
            endelse
        endif
;--------- RIGHT BUTTON ------        
        if (event.press eq 4) then begin
            ;gets back to full image if double-click
            if ( event.clicks eq 2) then begin
                si_map = info.size_map
                info.simage = [0, 0, si_map(1)-1, si_map(2)-1]
                info.erase = 1
                *infoptr = info
                ximage_update, event.top
            endif else begin
                si_map = info.size_map
                dx = fix( info.simage(2)-info.simage(0)+1 )
                dy = fix( info.simage(3)-info.simage(1)+1 )
                if dx lt si_map(1) or dy lt si_map(2) then begin
                    xmin = current_i-dx > 0
                    xmax = (xmin+2*dx) < (si_map(1)-1)
                    xmin = ( xmax - 2*dx ) > 0
                    ymin = current_j-dy > 0
                    ymax = (ymin+2*dy) < (si_map(2)-1)
                    ymin = ( ymax - 2*dy ) > 0
                    info.simage = [ xmin, ymin, xmax, ymax ]
                    info.erase = 1
                    *infoptr = info
                    ximage_update, event.top
                endif
            endelse
        endif
;--------- MIDDLE BUTTON --------------
        if (event.press eq 2) then begin
            if info.freeze eq 0 then info.freeze = 1 else begin
                info.freeze = 0
                info.erase = 1
                ximage_plot, info
                info.erase = 0
                ximage_value, info
            endelse
            *infoptr = info
        endif
    end
    'quit': begin
        bad_id = 0L
        widget_control, info.xplotid , bad_id=bad_id
        if bad_id eq 0 then widget_control, info.xplotid, /destroy
        widget_control, info.ximrangeid , bad_id=bad_id
        if bad_id eq 0 then widget_control, info.ximrangeid, /destroy
        widget_control, info.xcutid , bad_id=bad_id
        if bad_id eq 0 then widget_control, info.xcutid, /destroy
        WIDGET_CONTROL, /destroy, event.top
    end
    'spectrum': begin
        bad_id = 0L
        widget_control, info.xplotid , bad_id=bad_id
        if bad_id ne 0 then begin
            title = "i: " + strcompress(string(fix(info.i)), /rem) + ", j: " + strcompress(string(fix(info.j)), /rem)
            xplot, ximage_spectrum( info ), id=id, title=title, yrange=info.imrange
            if keyword_set( id ) then begin
                info.xplotid = id
                *infoptr = info
            endif
        endif else widget_control,  info.xplotid, /destroy
    end
    'cut': begin
        bad_id = 0L
        widget_control, info.xcutid , bad_id=bad_id
        if bad_id ne 0 then begin            
            xrange = [info.simage(0), info.simage(2)]
            yrange = [info.simage(1), info.simage(3)]
            xcut, (*info.dataptr[info.plane])(*,info.j), (*info.dataptr[info.plane])(info.i,*), $
              info.i, info.j, id=id, xrange=xrange, yrange=yrange, imrange=info.imrange, $
              xsize=info.size_image(0), ysize=info.size_image(1)
            if keyword_set( id ) then begin
                info.xcutid = id
                *infoptr = info
            endif
        endif else widget_control,  info.xcutid, /destroy
    end
    'column': begin
        if info.showcol eq 1 then begin
            widget_control, info.colid, draw_xsize=1. 
            info.showcol=0
        endif else begin
            widget_control, info.colid, draw_xsize=info.width_plot
            info.showcol = 1
            ximage_plot, info
        endelse
        *infoptr = info
    end
    'row': begin
        if info.showrow eq 1 then begin
            widget_control, info.rowid, draw_ysize=1. 
            info.showrow=0
        endif else begin
            widget_control, info.rowid, draw_ysize=info.width_plot
            info.showrow = 1
            ximage_plot, info
       endelse
        *infoptr = info
    end
    'imrange': begin
        bad_id = 0L
        widget_control, info.ximrangeid , bad_id=bad_id
        if bad_id ne 0 then begin
            simage = info.simage
            data = (*info.dataptr[info.plane])(simage(0):simage(2),simage(1):simage(3))
            ximrange, data, info.imrange, percent=info.percent, nsigma=info.nsigma, topid=event.top, indef=info.indef, $
              title='ximage', event_pro='ximage_displayall', id=ximrangeid
            info.ximrangeid = ximrangeid
            *infoptr=info
        endif else widget_control,  info.ximrangeid, /destroy
    end
    'image_name': begin
        widget_control, event.id, get_value=tempo
        ind = where(info.image_name eq tempo)
        info.plane = ind(0)
        widget_control, info.sliderid, set_value=ind(0)
        *infoptr = info
        ximage_update, event.top         
    end
    'slider': begin
         widget_control, event.id, get_value=tempo
         info.plane = tempo
         *infoptr = info
         ximage_update, event.top
    end
    else: begin

    end
endcase

end

;-----------------------------------------
;-----------------------------------------
;------- |              XIMAGE                | ------------
;-----------------------------------------
;-----------------------------------------
pro ximage, map1, map2, map3, map4, map5, $
            header=header, indef=indef, image_name=image_name, $
            resfit=resfit, imrange=imrange, units=units, $
            percent=percent, title=title, reb=reb

if not keyword_set(percent) then percent=0.
if not keyword_set(header) then header=0
if not keyword_set(indef) then indef=-32768.
if not keyword_set(units) then units=['pixels', 'pixels', 'plane', 'intensity']
if not keyword_set(resfit) then resfit=0
if not keyword_set(image_name) then image_name = 0
!p.multi=0                   
mamdct, !MAMDLIB.COLTABLE, /silent
;!p.font=1

;-------- parameters check ------------
IF N_PARAMS() eq 0 or N_PARAMS() gt 5 THEN BEGIN
    PRINT, 'CALLING SEQUENCE: ximage, cube_map, [map2], [map3], [map4], [map5], $'
    print, '    image_name=image_name, header=header, units=units, title=title, $'
    print, '    indef=indef, resfit=resfit, imrange=imrange, percent=percent'
    GOTO, CLOSING
ENDIF

;------- check size of input data --------
nbimages = N_PARAMS()
si_previous = size(map1)
nbframe = intarr(nbimages)
for i=0, nbimages-1 do begin
    case i of
        0: tempo = ptr_new(map1)
        1: tempo = ptr_new(map2)
        2: tempo = ptr_new(map3)
        3: tempo = ptr_new(map4)
        4: tempo = ptr_new(map5)
    endcase
    si_map = size(*tempo)
    if (si_map(0) lt 2) then begin
        print, 'Input variable is not a 2D array'
        GOTO, CLOSING
    endif
    if si_map(1) ne si_previous(1) or si_map(2) ne si_previous(2) then begin
        print, 'All images must have same size'
        GOTO, CLOSING
    endif
    if si_map(0) gt 2 then nbframe(i) = si_map(3) else nbframe(i)=1
    si_previous = si_map
    ptr_free, tempo
endfor

;------- allocate pointer for input data ------------
dataptr = ptrarr(total(nbframe), /allocate_heap) 
k = 0
for i=0, nbimages-1 do begin
    case i of
        0: tempo = ptr_new(map1)
        1: tempo = ptr_new(map2)
        2: tempo = ptr_new(map3)
        3: tempo = ptr_new(map4)
        4: tempo = ptr_new(map5)
    endcase
    for j=0, nbframe(i)-1 do begin 
        *dataptr[k] = (*tempo)(*,*,j)
        k = k+1
    endfor
    ptr_free, tempo
endfor

;-----DETERMINE SIZE OF XIMAGE -----------
SCRSIZE = GET_SCREEN_SIZE()
xmarge_screen = fix(0.1*scrsize(0))
ymarge_screen = fix(0.1*scrsize(1))
width_plot = 50
if keyword_set(header) then begin
    xmarge_image = [ 80., 150. ]
    ymarge_image = [ 80., 50. ]
endif else begin
    xmarge_image = [ 50., 80. ]
    ymarge_image = [ 40., 20. ]
endelse
pos_plot = [0.15,0.1,0.9,0.9]
size_image = [ scrsize(0) - width_plot - xmarge_screen, scrsize(1) - width_plot - ymarge_screen]

xsize_max = scrsize(0) - xmarge_screen - width_plot - total(xmarge_image)
ysize_max = scrsize(1) - ymarge_screen - width_plot - total(ymarge_image)
si_map = size( map1 )
if not keyword_set(reb) then reb = min( [ 1.*xsize_max / si_map(1), 1.*ysize_max / si_map(2) ] )
size_image = [ reb*si_map(1)+total(xmarge_image), reb*si_map(2)+TOTAL(ymarge_image) ]

;------ LAYOUT DEFINITION ----------
if not keyword_set(title) then tite='XIMAGE'
ximage = widget_base(title=title, /column)

top = widget_base(ximage, /row)
quitID = widget_button(top, xsize=60, ysize=20, uvalue='quit', value='Close')
imrangeID = widget_button(top, xsize=60, ysize=20, uvalue='imrange', value='Imrange')
rien = widget_button(top, xsize=60, ysize=20, uvalue='column', value='column')
rien = widget_button(top, xsize=60, ysize=20, uvalue='row', value='row')
rien = widget_button(top, xsize=60, ysize=20, uvalue='cut', value='Cut')
if total(nbframe) gt 1 then rien = widget_button(top, xsize=60, ysize=20, uvalue='spectrum', value='Spectrum')

if total(nbframe) gt 1 and keyword_set(image_name) then begin
    menu = widget_button(top, value='Image', uvalue='image_name', /MENU, xsize=width_plot, ysize=20)
    for i=0, nbimages-1 do name = widget_button(menu, value=image_name(i), uvalue='image_name')
endif

top_value = widget_base(top, /row, /frame)
iID = widget_label(top_value, value='x=0', /dynamic_resize)
jID = widget_label(top_value, value='y=0', /dynamic_resize)
valID = widget_label(top_value, value='value='+strcompress(string(map1(0)), /rem), /dynamic_resize)

base = widget_base( ximage, /row)

base_left = widget_base(base, /column)
imageID = widget_draw(base_left, xsize=size_image(0), ysize=size_image(1), frame=0, $
                       uvalue='image', /button_event, retain=2, /motion_events)
rowID = widget_draw(base_left, ysize=1, xsize=size_image(0), frame=0, $
                        uvalue='plotrow', /button_event, retain=2)

if total(nbframe) gt 1 then begin
    base_middle = widget_base(base, /column)
    sliderID = widget_slider(base_middle, minimum=0, maximum=total(nbframe)-1,  uvalue='slider', $
                                               value=0, scroll=1, /vertical, ysize=size_image(1))
endif else sliderid=0

base_right = widget_base(base, /column)
colID = widget_draw(base_right, xsize=1, ysize=size_image(1), frame=0, $
                        uvalue='plotcol', /button_event, retain=2)


;-------- REALIZE WIDGET--------------
widget_control, base, /realize

;---------SET STRUCTURE----------------
if not keyword_set(imrange) then imrange = compute_range(map1(*,*,0), indef=indef, percent=percent)
si_input = size(map1)

widget_control, imageID, get_value=image_wid
widget_control, colID, get_value=plotcol_wid
widget_control, rowID, get_value=plotrow_wid
widget_control, imrangeID, get_value=imrange_wid

info = {imageID:image_wid, plotcolID:plotcol_wid, plotrowID:plotrow_wid, iid:iid, jid:jid, valid:valid, $
        size_image:size_image, pos_image:[0.,0.,1.,1.], pos_plot:pos_plot, $
        imrange:imrange, percent:percent, nsigma:0., i:0., j:0., zi:0, zj:0, plane:0., simage:[0.,0.,si_map(1)-1,si_map(2)-1], $
        width_plot:width_plot, header:header, dataptr:dataptr, reb:0., indef:indef, xmarge:xmarge_image, $
        ymarge:ymarge_image, ximrangeid:-1, image_name:image_name, size_map:si_input, sliderid:sliderid, $
        freeze:0, colid:colid, rowid:rowid, showcol:0, showrow:0., xplotid:-1, xcutid:-1, erase:0}

set_reb_position, info
infoptr = ptr_new( info )
widget_control, ximage, set_uvalue=infoptr

;--------- FIRST DISPLAY----------
ximage_displayall, ximage

xmanager, 'ximage', ximage, /no_block, cleanup='ximage_clean'

closing:

end
