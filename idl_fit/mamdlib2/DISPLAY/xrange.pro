pro xrange_plot, info

current_window = !d.window
widget_control, info.drawid, get_value=winid
wset, winid
plot, info.xvec, info.histo, /xs, /ys
wset, current_window


end ;###########################################

pro xrange_notify, info

; Are there widgets to notify?

s = SIZE(info.notifyID)
IF s(0) EQ 1 THEN count = 0 ELSE count = s(2)-1
FOR j=0,count DO BEGIN
   colorEvent = {XRANGE_LOAD, $            ;
                  ID:info.notifyID(0,j), $   ;
                  TOP:info.notifyID(1,j), $
                  HANDLER:0L, $
                  RANGE:info.range}
   IF Widget_Info(info.notifyID(0,j), /Valid_ID) THEN $
      Widget_Control, info.notifyID(0,j), Send_Event=colorEvent
ENDFOR

end ;##################################################

pro xrange_clean, id

widget_control, id, get_uvalue=infoptr
ptr_free, (*infoptr).imageptr
ptr_free, (*infoptr).orderptr
ptr_free, infoptr

end ;##################################################

pro xrange_done, event

widget_control, event.top, get_uvalue=infoptr
range = (*infoptr)
widget_control, range.min_id, get_value=xm & range.range(0)=xm
widget_control, range.max_id, get_value=xm & range.range(1)=xm

xrange_notify, range

WIDGET_CONTROL, /destroy, event.top

end ;##################################################


pro reset_range, wrange

imrange=wrange.range 
print, imrange
widget_control, wrange.min_id, set_value=imrange(0)
widget_control, wrange.max_id, set_value=imrange(1)
widget_control, wrange.slide_min_id, SET_VALUE=imrange(0)
widget_control, wrange.slide_min_id, SET_SLIDER_MAX=imrange(1)
widget_control, wrange.slide_min_id, SET_SLIDER_MIN=0.5*imrange(0) > wrange.minmax(0)
widget_control, wrange.slide_max_id, SET_SLIDER_MIN=imrange(0)
widget_control, wrange.slide_max_id, SET_SLIDER_MAX=2.*imrange(1) < wrange.minmax(1)
widget_control, wrange.slide_max_id, SET_VALUE=imrange(1)

end ;##################################################


pro xrange_event, event

widget_control, event.id, get_uvalue=eventval
widget_control, event.top, get_uvalue=infoptr
range = (*infoptr)

case eventval of

    'minmax': begin
        range.mode = 0
        widget_control, range.percent_id, get_value=xm & percent = xm
        range.range =  compute_range(*range.imageptr, percent=percent)
    end

    'med_sigma': begin
        range.mode=1
        widget_control, range.nsigma_id, get_value=xm & nsigma = xm
        widget_control, range.percent_id, get_value=xm & percent = xm
        range.range =  compute_range(*range.imageptr, percent=percent, nsigma=nsigma)
    end

    'manual': begin
        range.mode=2
        widget_control, range.min_id, get_value=xm & range.range(0)=xm
        widget_control, range.max_id, get_value=xm & range.range(1)=xm
    end

    'nsigma': begin
        widget_control, range.med_sigma_id, set_button=1
        widget_control, range.nsigma_id, get_value=xm & nsigma = xm
        widget_control, range.percent_id, get_value=xm & percent = xm
        range.range =  compute_range(*range.imageptr, percent=percent, nsigma=nsigma)
    end

    'percent': begin
        widget_control, range.percent_id, get_value=xm & percent = xm
        range.range =  compute_range(*range.imageptr, percent=percent, order=*range.orderptr)
    end

    '995': begin
        range.percent_id = 0.5
        range.range =  compute_range(*range.imageptr, percent=range.percent, order=*range.orderptr)
    end

    '99': begin
        range.percent_id = 1.
        range.range =  compute_range(*range.imageptr, percent=range.percent, order=*range.orderptr)
    end

    '98': begin
        range.percent_id = 2.
        range.range =  compute_range(*range.imageptr, percent=range.percent, order=*range.orderptr)
    end

    '97': begin
        range.percent_id = 3.
        range.range =  compute_range(*range.imageptr, percent=range.percent, order=*range.orderptr)
    end

    '95': begin
        range.percent_id = 5.
        range.range =  compute_range(*range.imageptr, percent=range.percent, order=*range.orderptr)
    end

    '90': begin
        range.percent_id = 10.
        range.range =  compute_range(*range.imageptr, percent=range.percent, order=*range.orderptr)
    end

    'range_min_slider': begin
        widget_control, range.manual_id, set_button=1
        range.mode=2
        widget_control, range.slide_min_id, get_value=xm & range.range(0)=xm
    end

    'range_max_slider': begin
        widget_control, range.manual_id, set_button=1
        range.mode=2
        widget_control, range.slide_max_id, get_value=xm & range.range(1)=xm
    end

    'apply': begin
        widget_control, range.min_id, get_value=xm & range.range(0)=xm
        widget_control, range.max_id, get_value=xm & range.range(1)=xm
    end

    else: begin
        print, 'Rien de prevu pour l''instant'
    end

endcase

reset_range, range
(*infoptr) = range
widget_control, event.top, set_uvalue=infoptr
xrange_notify, range


end ;##################################################

pro xrange, image, base_id, indef_val=indef_val, drag=drag, notifyID=notifyID

if not keyword_set(indef_val) then indef_val = -32768.
if not keyword_set(drag) then drag=0
IF N_Elements(notifyID) EQ 0 THEN notifyID = [-1L, -1L]

ind = where(image ne indef_val)
immin = min(image(ind))
immax = max(image(ind))
imrange=[immin, immax]

base_id= widget_base(title='Dynamical Range Selector', /column)
base1 = widget_base(base_id, /column, /exclusive)

;minmax_id = widget_button(base1, value='minmax', uvalue='minmax', /no_release)
;med_sigma_id = widget_button(base1, value='median +/- nsigma', uvalue='med_sigma', /no_release)
;manual_id = widget_button(base1, value='manual entry', uvalue='manual', /no_release)

base1a = widget_base(base_id, /row)
junk = widget_button(base1a, value='99.5%', uvalue='995')
junk = widget_button(base1a, value='99%', uvalue='99')
junk = widget_button(base1a, value='98%', uvalue='98')
junk = widget_button(base1a, value='97%', uvalue='97')
junk = widget_button(base1a, value='95%', uvalue='95')
junk = widget_button(base1a, value='90%', uvalue='90')

junk = widget_label(base_id, value='________________________________________')

base2 = widget_base(base_id, /row)

nsigma_id = widget_slider(base2, minimum=0, maximum=10,  uvalue='nsigma', value=2, scroll=1, $
                              title='nsigma')
percent_id = widget_slider(base2, minimum=0, maximum=10,  uvalue='percent', value=0, scroll=1, $
                              title='low/high percent')

junk = widget_label(base_id, value='________________________________________')

scroll = (imrange(1)-imrange(0)) / 256.
scroll=1.
base3 = widget_base(base_id, /row)
min_id = cw_field(base3, xsize=12, value=imrange(0), $
                     title= 'min ', /float)
slide_min_id = widget_slider(base3, minimum=immin, maximum=imrange(1),  uvalue='range_min_slider', $
                     value=imrange(0), scroll=scroll, drag=drag)

base4 = widget_base(base_id, /row)
max_id = cw_field(base4, xsize=12, value=imrange(1), $
                     title= 'max ', /float)
slide_max_id = widget_slider(base4, minimum=imrange(0), maximum=immax,  uvalue='range_max_slider', $
                     value=imrange(1), scroll=scroll, drag=drag)

base5 = widget_base(base_id, /row)
redraw = widget_button(base5, value='Apply', uvalue='apply')
;cancel = widget_button(base5, value='Cancel', uvalue='cancel')
;propagate = widget_button(base5, value='Set for all', uvalue='propagate')
junk = widget_button(base5, value='Done', uvalue='done', event_pro='xrange_done')

drawid = widget_draw(base_id, xsize=300, ysize=200, uvalue='plot', retain=2, /button_event, /motion_events)

widget_control, base_id, /realize

widget_control, minmax_id, set_button=1

order = sort(image)

bin = (immax-immin) / 256.
histo = histogram(image, min=immin, max=immax, bin=bin)  
xvec = findgen(256)*bin+immin

range = {base_id:base_id, $
         minmax_id:minmax_id, $
         med_sigma_id:med_sigma_id, $
         manual_id:manual_id, $
         nsigma_id:nsigma_id, $
         percent_id:percent_id, $
         min_id:min_id, $
         max_id:max_id, $
         slide_min_id:slide_min_id, $
         slide_max_id:slide_max_id, $
         drawid:drawid, $
         range:imrange, $
         minmax:imrange, $
         histo:histo, $
         xvec:xvec, $
         mode:0, $
         imageptr:ptr_new(image), $
         orderptr:ptr_new(order), $
         indef:indef_val, $
         notifyID:notifyID}

infoptr = ptr_new(range)
widget_control, base_id, set_uvalue=infoptr
xmanager, 'xrange', base_id, cleanup='xrange_clean', /no_block

xrange_plot, range

end ;##################################################
