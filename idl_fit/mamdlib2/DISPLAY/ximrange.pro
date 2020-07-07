pro ximrange_update, id, data

widget_control, id, get_uvalue=infoptr
info = *infoptr
ptr_free, info.dataptr
info.dataptr = ptr_new(data)
info.imrange = compute_range(data, indef=info.indef, nsigma=info.nsigma, percent=info.percent)
ximrange_setinfo, info

*infoptr = info

end

;--------------------------

pro ximrange_setinfo, info

widget_control, info.minvid, set_value='  min: '+strcompress(string(info.imrange(0)), /rem)
widget_control, info.maxvid, set_value='      max: '+strcompress(string(info.imrange(1)), /rem)
widget_control, info.percentid, set_value=info.percent
widget_control, info.nsigmaid, set_value=info.nsigma
ximrange_histo, info
if info.topid ge 0 then begin
    if ( info.event_pro ne ' ' ) then begin
        param = {imrange:info.imrange, percent:info.percent, nsigma:info.nsigma}
        call_procedure, info.event_pro, info.topid, param
    endif
endif

end

;---------------------------------------
pro ximrange_clean, id

widget_control, id, get_uvalue=infoptr
ptr_free, (*infoptr).dataptr
ptr_free, infoptr

end 

;##################################################
pro ximrange_histo, info

wset, info.wid
data = *(info.dataptr)

ind = where(data ne info.indef)
bin = ( info.imrange(1)-info.imrange(0) ) / 100.
histov = histomamd(data(ind), bin=bin, min=info.imrange(0), max=info.imrange(1))
xv = findgen(n_elements(histov))*bin+info.imrange(0)
plot, xv, histov, psym=10, position=info.position, /normal, /xs, /ys, charsize=1.; , yr=[0., 1.]

end

;---------------------------------------
pro ximrange_event, event

widget_control, event.id, get_uvalue=eventval
widget_control, event.top, get_uvalue=infoptr
info = *infoptr

case eventval of

    'percent': begin
        widget_control, event.id, get_value=tempo
        info.percent = tempo
        info.imrange = compute_range(*(info.dataptr), indef=info.indef, nsigma=info.nsigma, percent=info.percent)
        ximrange_setinfo, info
        *infoptr = info
    end
    'nsigma': begin
        widget_control, event.id, get_value=tempo
        info.nsigma = tempo
        info.imrange = compute_range(*(info.dataptr), indef=info.indef, nsigma=info.nsigma, percent=info.percent)
        ximrange_setinfo, info
        *infoptr = info
    end
    'draw': begin
        if event.press eq 1 then begin
            xval = ( ( 1.*event.x / info.xsize ) - info.position(0) ) * ( info.imrange(1)- info.imrange(0) ) / (info.position(2)-info.position(0))+ info.imrange(0)
            info.tempo = xval > info.imrange(0) < info.imrange(1)
            *infoptr = info
        endif
        if event.release eq 1 then begin
            xval = ( ( 1.*event.x / info.xsize ) - info.position(0) ) * ( info.imrange(1)- info.imrange(0) ) / (info.position(2)-info.position(0))+ info.imrange(0)
            xval = xval > info.imrange(0) < info.imrange(1)
            minv = min([ xval, info.tempo] )
            maxv = max([ xval, info.tempo] )
            info.imrange(0) = minv
            info.imrange(1) = maxv
            info.percent = 0
            info.nsigma = 0
            ximrange_setinfo, info
            *infoptr = info
        endif
        if event.press eq 4 then begin
            info.nsigma=0
            info.percent=0
            info.imrange = compute_range(*(info.dataptr), indef=info.indef, nsigma=info.nsigma, percent=info.percent)
            ximrange_setinfo, info
            *infoptr = info
        endif
    end
    'ok': begin
        WIDGET_CONTROL, /destroy, event.top
    end
endcase

end

;------------------------
pro ximrange, data, imrange, percent=percent, nsigma=nsigma, $
              topid=topid, event_pro=event_pro, indef=indef, title=title, id=base

if not keyword_set(topid) then topid = -1
if not keyword_set(event_pro) then event_pro = ' '
if not keyword_set(indef) then indef=-32768.
ind_good = where(data ne indef, nbind)
if nbind eq 0 then begin
    print, 'No defined values'
    goto, CLOSING
endif
if not keyword_set(percent) then percent = 0
if not keyword_set(nsigma) then nsigma = 0

if not keyword_set(imrange) then imrange = compute_range(data, indef=indef, nsigma=nsigma, percent=percent)
if imrange(0) eq 0 and imrange(1) eq 0 then imrange = compute_range(data, indef=indef, nsigma=nsigma, percent=percent)

;------- LAYOUT WIDGET ----------------
if not keyword_set(title) then title='ximrange'
xsize = 300
base = widget_base(title=title, /column)
base_top = widget_base( base, /row )
base_middle = widget_base( base, /row )
minvID = widget_label(base_top, value='  min: '+strcompress(string(imrange(0)), /rem), /dynam)
maxvID = widget_label(base_top, value='      max: '+strcompress(string(imrange(1)), /rem), /dynam)
percentID = widget_slider(base_middle, minimum=0, maximum=20,  uvalue='percent', $
                        value=percent, scroll=1, title='percent', xsize=xsize/2.)
nsigmaID = widget_slider(base_middle, minimum=0., maximum=10.,  uvalue='nsigma', $
                        value=nsigma, scroll=1., title='nsigma', xsize=xsize/2.)
draw = widget_draw(base, xsize=xsize, ysize=xsize, frame=1, $
                       uvalue='draw', /button_event, retain=2)
ok = widget_button(base, xsize=xsize, ysize=20, uvalue='ok', value='Close')

;-------- REALIZE WIDGET--------------
widget_control, base, /realize

;---------SET STRUCTURE----------------
widget_control, draw, get_value=wid
dataptr = ptr_new(data)
info = {wid:wid, dataptr:dataptr, imrange:imrange, percent:percent, nsigma:nsigma, $
        indef:indef, minvid:minvid, maxvid:maxvid, percentid:percentid, nsigmaid:nsigmaid, $
        topid:topid, event_pro:event_pro, tempo:0., position:[0.15,0.15,0.9,0.9], xsize:xsize}
infoptr = ptr_new( info )
widget_control, base, set_uvalue=infoptr

;------ DISPLAY HISTO --------------
ximrange_histo, info


xmanager, 'ximrange', base, /no_block, cleanup='ximrange_clean'

CLOSING:

end
