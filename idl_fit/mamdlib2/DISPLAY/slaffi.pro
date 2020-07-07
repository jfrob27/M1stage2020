;--------------------------------
function compute_sl_range, i

common bo, data, widgval, indef_val, range

image = data.image(*,*,data.current_image)
range_out = [0., 0.]
ind = where(image ne indef_val, nbindef)
if nbindef eq 0 then return, range_out
image = image(ind)

case i of
    0: begin
         range_out = minmax(image)
    end
    1: begin
        med = median(image)
        tempo = moment(image)
        xsigma = sqrt(tempo(1))
        range_out = [med-1*xsigma, med+1*xsigma]
    end
    2: begin
        med = median(image)
        tempo = moment(image)
        xsigma = sqrt(tempo(1))
        range_out = [med-2*xsigma, med+2*xsigma]
    end

    3: begin
        med = median(image)
        tempo = moment(image)
        xsigma = sqrt(tempo(1))
        range_out = [med-3*xsigma, med+3*xsigma]
    end

    4: begin
        pourcent = 0.05
        order = sort(image)
        nlimit = pourcent*nbindef
        range_out = minmax(image(order(nlimit:(nbindef-nlimit))))
    end

    5: begin
        pourcent = 0.1
        order = sort(image)
        nlimit = pourcent*nbindef
        range_out = minmax(image(order(nlimit:(nbindef-nlimit))))
    end

    else: begin
        range_out = data.imrange(*,data.current_image)
    end
endcase

return, range_out

end

;----------------------------------------------------
pro select_images

common bo, data, widgval, indef_val, range

ysize=25
nbimages = data.si_cube(3)
nbcol = ceil(nbimages/20.)
base_vec = fltarr(nbcol)

widgval.base_select = widget_base(title='Select Images', /column)
base_up = widget_base(widgval.base_select, /row)
for i=0, nbcol-1 do base_vec(i) = widget_base(base_up, /col, /nonexclusive)
i=0
for kk=0, nbimages-1 do begin
    widgval.select(kk) = widget_button(base_vec(i), value=data.image_name(kk), uvalue=string(kk), ysize=ysize)
    tempo = (kk+1.) mod 20.
    if (tempo eq 0.) then i=i+1
endfor

junk = widget_button(widgval.base_select, value='Unselect All', uvalue='unselectall', ysize=ysize)
junk = widget_button(widgval.base_select, value='Select All', uvalue='selectall', ysize=ysize)
junk = widget_button(widgval.base_select, value='OK', uvalue='OK', ysize=ysize)

widget_control, widgval.base_select, /realize

ind = where(data.indtoggle eq 1., nbind)
for i=0, nbind-1 do widget_control, widgval.select(ind(i)), set_button=1

xmanager, 'select_images', widgval.base_select

end

;---------------------------------------------

pro select_images_event, event

;------------------------------------------------
;
; SELECT_IMAGES_EVENT
;
; Procedure qui gere les evenements
;
;-----------------------------------------------

;-------------------------------------------
; Definition des variables globales
;-------------------------------------------

common bo, data, widgval, indef_val, range

;-------------------------------------------
; Pompage de l'uvalue de l'evenement
;-------------------------------------------

widget_control, event.id, get_uvalue=eventval

;-------------------------------------------
; Reaction a l'evenement
;-------------------------------------------

case eventval of

    'OK': begin
        WIDGET_CONTROL, /destroy, event.top
        widgval.base_select = 0.
    end

    'unselectall': begin
        data.indtoggle(*) = 0
        for i=0, data.si_cube(3)-1 do widget_control, widgval.select(i), set_button=0
    end

    'selectall': begin
        data.indtoggle(*) = 1
        for i=0, data.si_cube(3)-1 do widget_control, widgval.select(i), set_button=1
    end

    else: begin
        kk = float(eventval)
        if data.indtoggle(kk) eq 0 then data.indtoggle(kk) = 1 else data.indtoggle(kk) = 0
    end
endcase

end
;----------------------------------


;----------------------------------------------------
pro dotoggle

common bo, data, widgval, indef_val, range

i=0
tempo = data.indtoggle
ind = where(tempo eq 1., nbtodo)
tempo = ind-data.current_image
tempo = min(abs(tempo), i)    
while data.stoptoggle eq 0 do begin
    data.current_image = ind(i)
    if keyword_set(data.image_name) then data.title=data.image_name(data.current_image)
    data.imrange(*,data.current_image) = compute_sl_range(data.current_range)
    widget_control, widgval.slider, set_value=data.current_image
    dis_image_sl
    wait, data.dtime
    Result = WIDGET_EVENT(widgval.base_toggle, /nowait)   
    i = i+1
    if i eq n_elements(ind) then i=0
endwhile


end


;----------------------------------------------------
pro xtoggle

common bo, data, widgval, indef_val, range

ysize=35
xsize = 90

widgval.base_toggle = widget_base(title='Toggle', /column)
base_toggle1 = widget_base(widgval.base_toggle, /row)
base_toggle2 = widget_base(widgval.base_toggle, /row)
base_toggle3 = widget_base(widgval.base_toggle, /row, /align_right)

select = widget_button(base_toggle1, value='Select images', uvalue='select', /no_release, ysize=ysize, xsize=xsize)
widgval.dtime = cw_field(base_toggle2, xsize=12, value=data.dtime, $
                         title= 'Time between display ', /float)
junk = widget_button(base_toggle1, value='Go', uvalue='go', ysize=ysize, xsize=xsize)
junk = widget_button(base_toggle1, value='Stop', uvalue='stop', ysize=ysize, xsize=xsize)
widgval.xtoggle_done = widget_button(base_toggle3, value='done', uvalue='done')

widget_control, widgval.base_toggle, /realize

xmanager, 'xtoggle', widgval.base_toggle

end

;---------------------------------------------
pro xtoggle_event, event

;------------------------------------------------
;
; XTOGGLE_EVENT
;
; Procedure qui gere les evenements
;
;-----------------------------------------------

;-------------------------------------------
; Definition des variables globales
;-------------------------------------------

common bo, data, widgval, indef_val, range

;-------------------------------------------
; Pompage de l'uvalue de l'evenement
;-------------------------------------------

widget_control, event.id, get_uvalue=eventval

;-------------------------------------------
; Reaction a l'evenement
;-------------------------------------------

case eventval of

    'select': begin
        select_images
    end

    'go': begin
        ind = where(data.indtoggle eq 1, nbind)
        if nbind eq 0 then Rien = DIALOG_MESSAGE('No image selected') else begin 
            data.stoptoggle=0
            widget_control, widgval.dtime, get_value=xm & data.dtime=xm
            widget_control, widgval.xtoggle_done, sensitive=0
            dotoggle
        endelse
    end

    'stop': begin
        data.stoptoggle=1
        widget_control, widgval.xtoggle_done, sensitive=1
    end

    'done': begin
        data.stoptoggle=1
        WIDGET_CONTROL, /destroy, event.top
        widgval.base_toggle = 0.
    end

endcase

end
;----------------------------------



;-----------------------------------------
pro xpostcript

common bo, data, widgval, indef_val, range

widgval.base_post = widget_base(title='Postcript', /column)
widgval.filename = cw_field(widgval.base_post, xsize=25, value=data.filename, title= 'Filename ', /string)
base_post_toggle = widget_base(widgval.base_post, /column, /nonexclusive)
junk = widget_button(base_post_toggle, value='eps', uvalue='eps', /no_release)
junk = widget_button(base_post_toggle, value='landscape', uvalue='landscape', /no_release)
junk = widget_button(widgval.base_post, value='OK', uvalue='OK')
junk = widget_button(widgval.base_post, value='Cancel', uvalue='cancel')
widget_control, widgval.base_post, /realize

xmanager, 'xpostcript', widgval.base_post

end
;------------------------------

pro xpostcript_event, event

;------------------------------------------------
;
; XPOSTCRIPT_EVENT
;
; Procedure qui gere les evenements
;
;-----------------------------------------------

;-------------------------------------------
; Definition des variables globales
;-------------------------------------------

common bo, data, widgval, indef_val, range

;-------------------------------------------
; Pompage de l'uvalue de l'evenement
;-------------------------------------------

widget_control, event.id, get_uvalue=eventval

;-------------------------------------------
; Reaction a l'evenement
;-------------------------------------------

case eventval of

    'cancel': begin
        WIDGET_CONTROL, /destroy, event.top
        widgval.base_post = 0.
    end

    'eps': data.eps=1

    'landscape': data.landscape=1

    'OK': begin
        widget_control, widgval.filename, get_value=xm & data.filename=xm
        WIDGET_CONTROL, /destroy, event.top
        widgval.base_post = 0.
        dis_image_sl
    end

endcase

end
;----------------------------------

pro xprop

common bo, data, widgval, indef_val, range

widgval.base_pref = widget_base(title='Properties', /column)
widgval.xtitle = cw_field(widgval.base_pref, xsize=25, value=data.xtitle, title= 'xtitle ', /string)
widgval.ytitle = cw_field(widgval.base_pref, xsize=25, value=data.ytitle, title= 'ytitle ', /string)
widgval.title = cw_field(widgval.base_pref, xsize=25, value=data.title, title= 'title ', /string)
widgval.units = cw_field(widgval.base_pref, xsize=25, value=data.units(3), title= 'units ', /string)
widgval.charsize = cw_field(widgval.base_pref, xsize=12, value=data.charsize, title= 'charsize ', /float)
widgval.indef = cw_field(widgval.base_pref, xsize=12, value=indef_val, title= 'indef ', /float)
widgval.sample = cw_field(widgval.base_pref, xsize=4, value=data.sample, title= 'sample ', /integer)
widgval.xticks = cw_field(widgval.base_pref, xsize=4, value=data.xticks, title= 'xticks ', /integer)
widgval.yticks = cw_field(widgval.base_pref, xsize=4, value=data.yticks, title= 'yticks ', /integer)
widgval.nbvalue = cw_field(widgval.base_pref, xsize=4, value=data.nbvalue, title= 'nb BAR value ', /integer)
junk = widget_button(widgval.base_pref, value='OK', uvalue='OK')
junk = widget_button(widgval.base_pref, value='Cancel', uvalue='cancel')
widget_control, widgval.base_pref, /realize

xmanager, 'xprop', widgval.base_pref

end

;----------------------------------------------------
pro xprop_event, event

;------------------------------------------------
;
; XPROP_EVENT
;
; Procedure qui gere les evenements
;
;-----------------------------------------------

;-------------------------------------------
; Definition des variables globales
;-------------------------------------------

common bo, data, widgval, indef_val, range

;-------------------------------------------
; Pompage de l'uvalue de l'evenement
;-------------------------------------------

widget_control, event.id, get_uvalue=eventval

;-------------------------------------------
; Reaction a l'evenement
;-------------------------------------------

case eventval of

    'cancel': begin
        WIDGET_CONTROL, /destroy, event.top
        widgval.base_pref = 0.
    end

    'OK': begin
        widget_control, widgval.xtitle, get_value=xm & data.xtitle=xm
        widget_control, widgval.ytitle, get_value=xm & data.ytitle=xm
        widget_control, widgval.title, get_value=xm & data.title=xm
        data.image_name(data.current_image)=xm
        if data.si_cube(0) eq 3 then widget_control, widgval.name(data.current_image), set_value=xm(0)
        widget_control, widgval.units, get_value=xm & data.units(3)=xm
        widget_control, widgval.charsize, get_value=xm & data.charsize=xm
        widget_control, widgval.indef, get_value=xm & indef_val=xm
        widget_control, widgval.sample, get_value=xm & data.sample=xm
        widget_control, widgval.xticks, get_value=xm & data.xticks=xm
        widget_control, widgval.yticks, get_value=xm & data.yticks=xm
        widget_control, widgval.nbvalue, get_value=xm & data.nbvalue=xm
        WIDGET_CONTROL, /destroy, event.top
        widgval.base_pref = 0.
        dis_image_sl
        replot_all
    end

endcase

end



;----------------------------------------------------
pro xrange

common bo, data, widgval, indef_val, range

range.previous = data.current_range
range.tag = 1
imrange=data.imrange(*,data.current_image)
ysize=35

widgval.base_range = widget_base(title='IMRANGE', /row)
base_range1 = widget_base(widgval.base_range, /column)
base_range2_0 = widget_base(widgval.base_range, /column)
base_range2 = widget_base(base_range2_0, /column, /exclusive)

junk = widget_button(base_range1, value='All data', uvalue='alldata', ysize=ysize)
junk = widget_button(base_range1, value='Median +/- 1 sigma', uvalue='median1', ysize=ysize)
junk = widget_button(base_range1, value='Median +/- 2 sigma', uvalue='median2', ysize=ysize)
junk = widget_button(base_range1, value='Median +/- 3 sigma', uvalue='median3', ysize=ysize)
junk = widget_button(base_range1, value='Without 5%', uvalue='without5', ysize=ysize)
junk = widget_button(base_range1, value='Without 10%', uvalue='without10', ysize=ysize)

alldata = widget_button(base_range2, value='Set this mode for all images', uvalue='alldataT', /no_release, ysize=ysize)
median1 = widget_button(base_range2, value='Set this mode for all images', uvalue='median1T', /no_release, ysize=ysize)
median2 = widget_button(base_range2, value='Set this mode for all images', uvalue='median2T', /no_release, ysize=ysize)
median3 = widget_button(base_range2, value='Set this mode for all images', uvalue='median3T', /no_release, ysize=ysize)
without5 = widget_button(base_range2, value='Set this mode for all images', uvalue='without5T', /no_release, ysize=ysize)
without10 = widget_button(base_range2, value='Set this mode for all images', uvalue='without10T', /no_release, ysize=ysize)
fixedvalue = widget_button(base_range2, value='Individual range', uvalue='fixedvalueT', /no_release, ysize=ysize)
base_range2b = widget_base(base_range2_0, /row)
redraw = widget_button(base_range2b, value='Set this RANGE', uvalue='redraw')
propagate = widget_button(base_range2b, value='Set for all', uvalue='propagate')

range.min = cw_field(base_range1, xsize=12, value=imrange(0), $
                     title= 'min ', /float)
range.max = cw_field(base_range1, xsize=12, value=imrange(1), $
                     title= 'max ', /float)
junk = widget_button(base_range1, value='Done', uvalue='done')

widget_control, widgval.base_range, /realize
case data.current_range of
    0: widget_control, alldata, set_button=1
    1: widget_control, median1, set_button=1
    2: widget_control, median2, set_button=1
    3: widget_control, median3, set_button=1
    4: widget_control, without5, set_button=1
    5: widget_control, without10, set_button=1
    6: widget_control, fixedvalue, set_button=1
endcase

xmanager, 'xrange', widgval.base_range

end

;----------------------------------------------------
pro xrange_event, event

;------------------------------------------------
;
; XRANGE_EVENT
;
; Procedure qui gere les evenements
;
;-----------------------------------------------

;-------------------------------------------
; Definition des variables globales
;-------------------------------------------

common bo, data, widgval, indef_val, range

;-------------------------------------------
; Pompage de l'uvalue de l'evenement
;-------------------------------------------

widget_control, event.id, get_uvalue=eventval

;-------------------------------------------
; Reaction a l'evenement
;-------------------------------------------

case eventval of

    'alldata': begin
        data.imrange(*,data.current_image) =  compute_sl_range(0)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'median1': begin
        data.imrange(*,data.current_image) =  compute_sl_range(1)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'median2': begin
        data.imrange(*,data.current_image) =  compute_sl_range(2)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'median3': begin
        data.imrange(*,data.current_image) =  compute_sl_range(3)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'without5': begin
        data.imrange(*,data.current_image) =  compute_sl_range(4)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'without10': begin
        data.imrange(*,data.current_image) =  compute_sl_range(5)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'alldataT': begin
        data.current_range = 0
        data.imrange(*,data.current_image) =  compute_sl_range(0)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'median1T': begin
        data.current_range = 1
        data.imrange(*,data.current_image) =  compute_sl_range(1)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'median2T': begin
        data.current_range = 2
        data.imrange(*,data.current_image) =  compute_sl_range(2)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'median3T': begin
        data.current_range = 3
        data.imrange(*,data.current_image) =  compute_sl_range(3)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'without5T': begin
        data.current_range = 4
        data.imrange(*,data.current_image) =  compute_sl_range(4)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'without10T': begin
        data.current_range = 5
        data.imrange(*,data.current_image) =  compute_sl_range(5)
        dis_image_sl
        xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
        xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
    end

    'fixedvalueT': begin
        data.current_range = 6
    end

    'propagate': begin
        widget_control, range.min, get_value=xm & data.imrange(0,data.current_image)=xm
        widget_control, range.max, get_value=xm & data.imrange(1,data.current_image)=xm
        data.imrange(0,*) = data.imrange(0,data.current_image)
        data.imrange(1,*) = data.imrange(1,data.current_image)
        dis_image_sl
    end

    'redraw': begin
        widget_control, range.min, get_value=xm & data.imrange(0,data.current_image)=xm
        widget_control, range.max, get_value=xm & data.imrange(1,data.current_image)=xm
        dis_image_sl
    end

    'done': begin
        widget_control, range.min, get_value=xm & data.imrange(0,data.current_image)=xm
        widget_control, range.max, get_value=xm & data.imrange(1,data.current_image)=xm
        WIDGET_CONTROL, /destroy, event.top
        widgval.base_range=0
        dis_image_sl
        range.tag=0
    end

endcase

end


;--------------------------------------------
pro replot_all

common bo, data, widgval, indef_val, range

widget_control, widgval.pos_i, get_value=xm
if (xm lt 0) then xm = 0
if (xm ge data.si_cube(1)) then xm = data.si_cube(1)-1
data.pos_i = xm
widget_control, widgval.pos_i, set_value=xm

widget_control, widgval.pos_j, get_value=xm
if (xm lt 0) then xm = 0
if (xm ge data.si_cube(2)) then xm = data.si_cube(2)-1
data.pos_j = xm
widget_control, widgval.pos_j, set_value=xm

if keyword_set(data.plotrowcol) then plot_col_lin, data.pos_i, data.pos_j
if data.si_cube(0) eq 3 then plot_spectrum, data.pos_i, data.pos_j, resfit=data.resfit

end

;--------------------------------


;-----------------------------------------------------

pro print_value

common bo, data, widgval, indef_val, range

xm = data.pos_i & widget_control, widgval.pos_i, set_value=xm
xm = data.pos_j & widget_control, widgval.pos_j, set_value=xm
xm = data.image(data.pos_i, data.pos_j,data.current_image) & widget_control, widgval.val, set_value=xm

end

;-----------------------------------------------------

pro plot_spectrum, i, j, resfit=resfit

common bo, data, widgval, indef_val, range

wset, 4
if keyword_set(resfit) then plotresfit, data.third_axe, data.image(i,j,*), resfit(i,j,*), $
  yr=data.imrange(*,data.current_image), $
  xr=minmax(data.third_axe), xtitle=data.units(2), ytitle=data.units(3), title=string(i, j, '("spectrum", I5, I5)'), $
  charsize=data.charsize $
else $
  plot, data.third_axe, data.image(i,j,*),  /ys, yr=data.imrange(*,data.current_image), /xs, $
  xr=minmax(data.third_axe), xtitle=data.units(2), ytitle=data.units(3), $
  title=string(i, j, '("spectrum", I5, I5)'), charsize=data.charsize, psym=10
plots, [data.third_axe(data.current_image), data.third_axe(data.current_image)], $
  data.imrange(*,data.current_image), col=50
end

;-----------------------------------------------------

pro plot_col_lin, i, j

common bo, data, widgval, indef_val, range

widget_control, get_value=index, widgval.plotcol
wset, index
plot, data.image(i,*,data.current_image), indgen(data.si_cube(2)), /xs, xr=data.imrange(*,data.current_image), $
  /ys, yr=[0, data.si_cube(2)-1], $
  position = [0.2, data.position(1), 0.9, data.position(3)], xtitle=data.units(3), $
  ytitle=data.units(1), title=string(i, '("Column", I5)'), charsize=data.charsize
widget_control, get_value=index, widgval.plotlig
wset, index
plot, indgen(data.si_cube(1)), data.image(*,j,data.current_image),  /ys, yr=data.imrange(*,data.current_image), $
  /xs, xr=[0, data.si_cube(1)-1], $
  position = [data.position(0), 0.2, data.position(2), 0.9], xtitle=data.units(0), ytitle=data.units(3), $
  title=string(j, '("Line", I5)'), charsize=data.charsize
end

;--------------------------------------

pro dis_image_sl

common bo, data, widgval, indef_val, range

image = data.image(*,*,data.current_image)

if (data.imrange(0,data.current_image) eq 0. and data.imrange(1,data.current_image) eq 0) then $
  data.imrange(*,data.current_image) = compute_sl_range(0.)
widget_control, get_value=index, widgval.imaffi
wset, index
if not keyword_set(data.filename) then begin
    erase
    position = data.position(0:1)
endif else position = data.position

imaffi, image, indef=indef_val, header=data.header, position=position, rebin=data.rebin_factor, $
  sample=data.sample, imrange=data.imrange(*,data.current_image), xtitle=data.xtitle, ytitle=data.ytitle, $
  title=data.title, charsize=data.charsize, xticks=data.xticks, yticks=data.yticks, postscript=data.filename, $
  eps=data.eps, landscape=data.landscape

mamd_bar, [data.position(2), data.position(1), data.position(2)+0.03, data.position(3)], $
  imrange=data.imrange(*,data.current_image), charsize=data.charsize, nbvalue=data.nbvalue
xyouts, data.position(2), data.position(1)-0.05, data.units(3), /normal, charsize=data.charsize

if keyword_set(data.filename) then begin
    psout
    data.filename = ''
    data.eps=0
    data.landscape=0
endif

if keyword_set(data.plotrowcol) then plot_col_lin, data.pos_i, data.pos_j
if data.si_cube(0) eq 3 then plot_spectrum, data.pos_i, data.pos_j, resfit=data.resfit

end


;------------------------------------


pro xy2ij, x, y, i, j

common bo, data, widgval, indef_val, range

;----------------------
;
; Permet de passer des coordonees DEVICE (x,y)
; en corrdonee DATA de l'image
;
;---------------------

pos = data.position
reb_f = data.rebin_factor
si_map = data.si_cube

point_zero = [pos(0)*si_map(1)*reb_f(0)/(pos(2)-pos(0)), $
              pos(1)*si_map(2)*reb_f(1)/(pos(3)-pos(1))]

i = fix((x - point_zero(0))/reb_f(0)) > 0 < (si_map(1)-1)
j = fix((y - point_zero(1))/reb_f(1)) > 0 < (si_map(2)-1)

end

;--------------------------------------------


pro slaffi_event, event

;------------------------------------------------
;
; SLAFFI_EVENT
;
; Procedure qui gere les evenements
;
;-----------------------------------------------

;-------------------------------------------
; Definition des variables globales
;-------------------------------------------

common bo, data, widgval, indef_val, range

;-------------------------------------------
; Pompage de l'uvalue de l'evenement
;-------------------------------------------

widget_control, event.id, get_uvalue=eventval, /draw_motion_events

;-------------------------------------------
; Reaction a l'evenement
;-------------------------------------------

case eventval of

    'quit': begin
        window, 4
        wdelete, 4
        if keyword_set(widgval.base_range) then WIDGET_CONTROL, /destroy, widgval.base_range
        if keyword_set(widgval.base_select) then WIDGET_CONTROL, /destroy, widgval.base_select
        if keyword_set(widgval.base_post) then WIDGET_CONTROL, /destroy, widgval.base_post
        if keyword_set(widgval.base_pref) then WIDGET_CONTROL, /destroy, widgval.base_pref
        if keyword_set(widgval.base_toggle) then WIDGET_CONTROL, /destroy, widgval.base_toggle
        WIDGET_CONTROL, /destroy, event.top
    end

    'xloadct': begin
        xloadct
    end

    'Prop.': begin
        xprop
    end

    'zoom': begin
        widget_control, get_value=index, widgval.imaffi
        wset, index
        zoom_24
    end

    'imrange': begin
        xrange
    end

    'cinema': begin
        xtoggle
    end

    'slider': begin
        widget_control, event.id, get_value=image_number
        data.current_image = image_number
        if keyword_set(data.image_name) then data.title=data.image_name(data.current_image)
        if (data.current_range eq 6) then begin
            imrange = data.imrange(*,data.current_image)
            if imrange(0) eq 0 and imrange(1) eq 0 then begin
                image = data.image(*,*,data.current_image)
                ind = where(image ne indef_val, nbindef)
                if nbindef ne 0 then $
                  data.imrange(*,data.current_image) = minmax(image(ind))
            endif
        endif else begin
            data.imrange(*,data.current_image) = compute_sl_range(data.current_range)
        endelse
        if range.tag eq 1 then begin
            xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
            xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
        endif
        dis_image_sl
    end

    'PS': begin
        xpostcript
    end


; New image selected (display image - imaffi)
    'image': begin
        widget_control, event.id, get_value=image_name
        tempo = ''
        i = 0
        while tempo ne image_name do begin
            tempo = data.image_name(i)
            i = i+1
        endwhile
        data.current_image = i-1
        data.title=data.image_name(data.current_image)
        if (data.current_range eq 6) then begin
            imrange = data.imrange(*,data.current_image)
            if imrange(0) eq 0 and imrange(1) eq 0 then begin
                image = data.image(*,*,data.current_image)
                ind = where(image ne indef_val, nbindef)
                if nbindef ne 0 then $
                  data.imrange(*,data.current_image) = minmax(image(ind))
            endif
        endif else begin
            data.imrange(*,data.current_image) = compute_sl_range(data.current_range)
        endelse
        if range.tag eq 1 then begin
            xm=data.imrange(0,data.current_image) & widget_control, range.min, set_value=xm
            xm=data.imrange(1,data.current_image) & widget_control, range.max, set_value=xm
        endif
        dis_image_sl
        widget_control, widgval.slider, set_value=data.current_image
    end

; Deal with mouse position (plot graph)
    'imaffi': begin
        xy2ij, event.x, event.y, i, j
        if event.press eq 4 then begin
            if data.lockplot eq 0 then data.lockplot=1 else data.lockplot=0
        endif
        if (data.lockplot eq 0 or (data.lockplot eq 1 and event.press)) then begin
            data.pos_i = i
            data.pos_j = j
            if keyword_set(data.plotrowcol) then plot_col_lin, i, j
            if data.si_cube(0) eq 3 then plot_spectrum, i, j, resfit=data.resfit
            print_value
        endif
    end
endcase

end

;-------------------------------------------------------------------
;-------------------------------------------------------------------
;-------------------------------------------------------------------
;-------------------------------------------------------------------

pro slaffi, cube_map, map2, map3, map4, map5, $
            image_name=image_name, header=header, rebin_factor=rebin_factor, sample=sample, units=units, $
            indef=indef, third_axe=third_axe, resfit=resfit, plotrowcol=plotrowcol, imrange=imrange

;-------------------------------------------------------
;
; SLAFFI
;
;-------------------------------------------------------

common bo, data, widgval, indef_val, range

!p.multi=0                      ; Pour que l'affichage des coupes horizontale et verticale se passe bien
!p.font=-1

; parameters check

IF N_PARAMS() eq 0 or N_PARAMS() gt 5 THEN BEGIN
    PRINT, 'CALLING SEQUENCE: slaffi, cube_map, [map2], [map3], [map4], [map5], $'
    print, '    image_name=image_name, header=header, rebin_factor=rebin_factor, sample=sample, units=units, $'
    print, '    indef=indef, third_axe=third_axe, resfit=resfit, plotrowcol=plotrowcol, $'
    print, '    imrange=imrange'
    GOTO, CLOSING
ENDIF

si_input = size(cube_map)
if (si_input(0) lt 2) then begin
    print, 'Input variable is not a 2D array'
    GOTO, CLOSING
endif

if N_PARAMS() gt 5 then begin
    print, 'SLAFFI only allows to display 5 different images or a data cube'
    GOTO, CLOSING
endif

if N_PARAMS() gt 1 then begin
    nmap = N_PARAMS()<5
    for i=1, nmap-1 do begin
        case i of
            0: begin
                if not keyword_set(cube_map) then begin
                    print, 'First map is undefined'
                    GOTO, CLOSING
                endif
            end
            1: begin
                if not keyword_set(map2) then begin
                    print, 'Second map is undefined'
                    GOTO, CLOSING
                endif
            end
            2: begin
                if not keyword_set(map3) then begin
                    print, 'Third map is undefined'
                    GOTO, CLOSING
                endif
            end
            3: begin
                if not keyword_set(map4) then begin
                    print, 'Fourth map is undefined'
                    GOTO, CLOSING
                endif
            end
            4: begin
                if not keyword_set(map5) then begin
                    print, 'Fifth map is undefined'
                    GOTO, CLOSING
                endif
            end
        endcase
    endfor
    map1 = cube_map
    cube_map = fltarr(si_input(1), si_input(2), nmap)
    cube_map(*,*,0) = map1
    for i=1, nmap-1 do begin
        case i of
            1: maptempo = map2
            2: maptempo = map3
            3: maptempo = map4
            4: maptempo = map5
        endcase
        si_tempo = size(maptempo)
        if (si_input(1) eq si_tempo(1) and si_input(2) eq si_tempo(2)) then begin
            cube_map(*,*,i) = maptempo
        endif else begin
            print, 'All images must have the same dimensions'
            cube_map = map1
            goto, CLOSING
        endelse
    endfor
    maptempo = 0
endif

si_cube = size(cube_map)

;----------------------------------------
; KEYWORDS

if si_cube(0) eq 3 then nbimages = si_cube(3) else nbimages = 1
if keyword_set(image_name) then nbi = n_elements(image_name) else nbi=0
if nbi ne nbimages then begin
    tempo_name = strarr(nbimages)
    for i=0, nbimages-1 do tempo_name(i) = strcompress('Image'+string(i), /remove_all)
    if keyword_set(image_name) then image_name = [image_name(0:n_elements(image_name)-1), $
                                                  tempo_name(n_elements(image_name):*)] $
    else image_name=tempo_name
endif
image_name(0) = image_name(0)+'     '

if not keyword_set(header) then header=0
if not keyword_set(rebin_factor) then rebin_factor=0
if rebin_factor(0) gt 0 and n_elements(rebin_factor) eq 1 then rebin_factor=[rebin_factor, rebin_factor]
if not keyword_set(sample) then sample=1
if sample eq -1 then sample=0
if not keyword_set(units) then units=['pixels', 'pixels', 'plane', 'intensity']
if not keyword_set(indef) then indef_val = -32768 else indef_val = indef
if not keyword_set(third_axe) then third_axe = indgen(si_cube(3))
if not keyword_set(resfit) then resfit=0
if not keyword_set(plotrowcol) then plotrowcol=1
if plotrowcol lt 0. then plotrowcol = 0
if not keyword_set(imrange) then imrange=fltarr(2, nbimages)
if (n_elements(imrange) ne 2*nbimages) then begin
    tempo = imrange
    imrange = fltarr(2, nbimages)
    for i=0, nbimages-1 do imrange(*,i) = tempo(0:1)
endif
imrange = reform(imrange, 2, nbimages)

if si_cube(0) eq 3 then window, 4, xs=400, ys=400

;-----------------------------------------
; DETERMINE SIZE OF SLAFFI ON THE SCREEN

SCRSIZE = GET_SCREEN_SIZE()
xmarge = [60, 85] 
ymarge = [50, 30]
if keyword_set(plotrowcol) then begin
    spacex = scrsize(0)-250.-total(xmarge)
    spacey = scrsize(1)-250.-total(ymarge)
endif else begin
    spacex = scrsize(0)-10.-total(xmarge)
    spacey = scrsize(1)-80.-total(ymarge)
endelse
if not keyword_set(rebin_factor) then begin
;    rebf = [floor(spacex/si_cube(1)), floor(spacey/si_cube(2))]
;    rebin_factor = [min(rebf)>1, min(rebf)>1]
    rebf = [1.*spacex/si_cube(1), 1.*spacey/si_cube(2)]
    rebin_factor = [min(rebf), min(rebf)]
endif
xtot = total(xmarge)+si_cube(1)*rebin_factor(0)
ytot = total(ymarge)+si_cube(2)*rebin_factor(1)
imaffi_pos = [xmarge(0)/xtot, ymarge(0)/ytot, 1-xmarge(1)/xtot, 1-ymarge(1)/ytot]

display_size = fix([si_cube(1)*rebin_factor(0)/(imaffi_pos(2)-imaffi_pos(0)), $
                    si_cube(2)*rebin_factor(1)/(imaffi_pos(3)-imaffi_pos(1))])

;---------------------------------------
; STRUCTURE DEFINITION
;--------------------------------------

data = {image:cube_map, $
        image_name:image_name, $
        si_cube:si_cube, $
        current_image:0, $
        header:header, $
        position:imaffi_pos, $
        rebin_factor:rebin_factor, $
        sample:sample, $
        imrange:imrange, $
        units:units, $
        current_range:0, $
        third_axe:third_axe, $
        resfit:resfit, $
        plotrowcol:plotrowcol, $
        pos_i:0, $
        pos_j:0, $
        lockplot:0, $
        xtitle:units(0), $
        ytitle:units(1), $
        title:'', $
        charsize:1., $
        xticks:0L, $
        yticks:0L, $
        filename:'', $
        nbvalue:3, $
        dtime:0.2, $
        stoptoggle:0, $
        indtoggle:fltarr(nbimages), $
        eps:0, $
        landscape:0}

widgval = {imaffi:0L, $
           plotlig:0L, $
           plotcol:0L, $
           slider:0L, $
           pos_i:0L, $
           pos_j:0L, $
           val:0L, $
           xtitle:0L, $
           ytitle:0L, $
           title:0L, $
           charsize:0L, $
           units:0L, $
           sample:0L, $
           indef:0L, $
           rebin:0L, $
           xticks:0L, $
           yticks:0L, $
           filename:0L, $
           nbvalue:0L, $
           dtime:0L, $
           base_toggle:0L, $
           base_range:0L, $
           base_pref:0L, $
           base_post:0L, $
           base_select:0L, $
           xtoggle_done:0L, $
           select:fltarr(nbimages), $
           name:strarr(nbimages)}

range = {min:0L, $
         max:0L, $
         previous:0L, $
         tag:0L}

;-------------------------------------------
;  DEFINITION DE L'ENVIRONNEMENT GRAPHIQUE
; ------------------------------------------

base = widget_base(title='SLAFFI - SLICE Image Viewer', /column)
base_down = widget_base(base, /row)


if keyword_set(plotrowcol) then begin
    xsize_button = 70
    ysize_button = 25
    left = widget_base(base_down, /column)
    widgval.imaffi = widget_draw(left, xsize=display_size(0), ysize=display_size(1), /frame, /motion_events, $
                                 uvalue='imaffi', /button_event, retain=2)
    widgval.plotlig = widget_draw(left, xsize=display_size(0), ysize=200, /frame, retain=2)


    middle = widget_base(base_down, /row)

    right = widget_base(base_down, /column)
    widgval.plotcol = widget_draw(right, xsize=200, ysize=display_size(1), /frame, retain=2)

    right_bottom1 = widget_base(right, /row)
    widgval.pos_i = cw_field(right_bottom1, xsize=4, value=data.pos_i, title= 'X ', /integer, /noedit)
    widgval.pos_j = cw_field(right_bottom1, xsize=4, value=data.pos_j, title= 'Y ', /integer, /noedit)
    quit = widget_button(right_bottom1, value='QUIT', uvalue='quit', xsize=1*xsize_button, ysize=ysize_button)
    right_bottom2 = widget_base(right, /row)
    widgval.val = cw_field(right_bottom2, xsize=14, value=data.image(data.pos_i, data.pos_j), title= 'VAL ', /noedit)

    right_bottom3 = widget_base(right, /row)

    button_imrange = widget_button(right_bottom3, value='imrange', uvalue='imrange', xsize=xsize_button, $
                                   ysize=ysize_button)
    xloadct = widget_button(right_bottom3, value='xloadct', uvalue='xloadct', xsize=xsize_button, ysize=ysize_button)
    if nbimages gt 1 then begin
        widgval.slider = widget_slider(middle, minimum=0, maximum=nbimages-1,  uvalue='slider', $
                                       value=data.current_image, scroll=1, /vertical)
        menu = widget_button(right_bottom2, value='Image', uvalue='image', /MENU, xsize=xsize_button, $
                             ysize=ysize_button)
        for i=0, nbimages-1 do widgval.name(i) = widget_button(menu, value=data.image_name(i), uvalue='image')
        cinema = widget_button(right_bottom3, value='cinema', uvalue='cinema', $
                               xsize=xsize_button, ysize=ysize_button)
    endif
    right_bottom4 = widget_base(right, /row)
    junk = widget_button(right_bottom4, value='Prop.', uvalue='Prop.', xsize=xsize_button, ysize=ysize_button)
    junk = widget_button(right_bottom4, value='PS', uvalue='PS', xsize=xsize_button, ysize=ysize_button)
    zoom = widget_button(right_bottom4, value='zoom', uvalue='zoom', xsize=xsize_button, ysize=ysize_button)

    right_bottom5 = widget_base(right, /row)

endif else begin
    xsize_button = 50
    ysize_button = 25
    command = widget_base(base, /row, /align_right)
    bottom = widget_base(base, /row)

    quit = widget_button(command, value='QUIT', uvalue='quit', xsize=xsize_button, ysize=ysize_button)
    widgval.pos_i = cw_field(command, xsize=4, value=data.pos_i, title= 'X ', /integer, /noedit)
    widgval.pos_j = cw_field(command, xsize=4, value=data.pos_j, title= 'Y ', /integer, /noedit)
    widgval.val = cw_field(command, xsize=14, value=data.image(data.pos_i, data.pos_j), title= 'VAL ', /noedit)

    widgval.imaffi = widget_draw(bottom, xsize=display_size(0), ysize=display_size(1), /frame, /motion_events, $
                                 uvalue='imaffi', /button_event, retain=2)
    if nbimages gt 1 then begin
        widgval.slider = widget_slider(bottom, minimum=0, maximum=nbimages-1,  uvalue='slider', $
                                       value=data.current_image, scroll=1, /vertical)
        menu = widget_button(command, value='Image', uvalue='image', /MENU, xsize=xsize_button, $
                             ysize=ysize_button)
        for i=0, nbimages-1 do widgval.name(i) = widget_button(menu, value=data.image_name(i), uvalue='image')
    endif

    button_imrange = widget_button(command, value='imrange', uvalue='imrange', xsize=xsize_button, $
                                   ysize=ysize_button)

    junk = widget_button(command, value='Prop.', uvalue='Prop.', xsize=xsize_button, ysize=ysize_button)
    junk = widget_button(command, value='PS', uvalue='PS', xsize=xsize_button, ysize=ysize_button)


    xloadct = widget_button(command, value='xloadct', uvalue='xloadct', xsize=xsize_button, ysize=ysize_button)
    zoom = widget_button(command, value='zoom', uvalue='zoom', xsize=xsize_button, ysize=ysize_button)

endelse

widget_control, base, /realize

; DISPLAY FIRST IMAGE

data.indtoggle(*) = 1
if keyword_set(data.image_name) then data.title=data.image_name(data.current_image)
dis_image_sl
data.current_range=6
data.pos_i = fix(si_cube(1)/2.)
data.pos_j = fix(si_cube(2)/2.)
if keyword_set(plotrowcol) then plot_col_lin, data.pos_i, data.pos_j
if si_cube(0) eq 3 then plot_spectrum, data.pos_i, data.pos_j, resfit=resfit
print_value

xmanager, 'slaffi', base

if N_PARAMS() gt 1 and N_PARAMS() le 5 then cube_map = map1
data.imrange(*)=0.

closing:

end










