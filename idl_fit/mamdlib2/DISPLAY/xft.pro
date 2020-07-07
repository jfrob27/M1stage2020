;----------------------------------------------------
pro set_median, id

widget_control, id.top, get_uvalue=infoptr
if (*infoptr).median eq 0 then (*infoptr).median=1 else (*infoptr).median=0

end

;----------------------------------------------------
pro redisplay, id

widget_control, id.top, get_uvalue=infoptr
display_all, infoptr

end

;_______________________________________________________________
pro display_all, infoptr

; get values of SEUIL and APODIZE
widget_control, (*(*infoptr).cwidptr)[0], get_value=seuil0
widget_control, (*(*infoptr).cwidptr)[1], get_value=seuil1
widget_control, (*(*infoptr).cwidptr)[2], get_value=apod
widget_control, (*(*infoptr).cwidptr)[3], get_value=noise

; Apply apodization to map
map = *(*infoptr).mapptr
si_map = size(map)
if apod(0) ne 0 then tapper = APODIZE(si_map(1), si_map(2), apod) else tapper=1.
map = map*tapper

; Compute amplitude
mfft = fft(map, 1)
amplitude = shift(abs(mfft), fix(si_map(1) / 2.), fix(si_map(2) / 2.))

; display map
widget_control,  (*(*infoptr).drawidptr)[0], get_value=winvalue
wset, winvalue
erase
imaffi, map, position=[0.05,0.05], title='map', /bar, rebin = (*infoptr).rebin

; display amplitude
widget_control,  (*(*infoptr).drawidptr)[1], get_value=winvalue
wset, winvalue
erase
ind = where(amplitude gt 0.)
imrange = minmax(alog(amplitude(ind)))
imaffi, alog(amplitude), position=[0.05,0.05], /cadrenu, title='amplitude', /bar, imrange=imrange, $
  rebin = (*infoptr).rebin

; plot power spectrum
widget_control,  (*(*infoptr).drawidptr)[2], get_value=winvalue
wset, winvalue
plot_ps, *(*infoptr).mapptr, tab_k, spec_k, $
  title='Power spectrum of map', seuil=[seuil0(0), seuil1(0)], apod=apod(0), /xs, psym=1, $
  expo=slope, norm=norm, xtitle='k (pixel!E-1!N)', median=(*infoptr).median
if noise ne 0. then oplot, tab_k, spec_k-noise, col=50

widget_control, (*(*infoptr).cwidptr)[4], set_value=slope
widget_control, (*(*infoptr).cwidptr)[5], set_value=norm

end

;_______________________________________________________________
pro xft_cleanup, id

widget_control, id, get_uvalue=infoptr
ptr_free, (*infoptr).mapptr
ptr_free, (*infoptr).drawidptr
ptr_free, (*infoptr).cwidptr
ptr_free, infoptr

end

;_______________________________________________________________
pro xft, map, median=median, seuil=seuil, apod=apod

size_map = size(map)
xsize = 400
rebin = 0.7*xsize/size_map(1)
ysize = 0.9*xsize

; KEYWORDS
if not keyword_set(median) then median=0
if not keyword_set(seuil) then seuil=[0.,1]
if n_elements(seuil) eq 1 then seuil = [0., seuil]
if not keyword_set(apod) then apod=0

; Create widget BASE
base = widget_base(mbar=mbar, title='XFT', tlb_frame_attr=1, /column)

; Create DRAW widgets
drawid = lonarr(3)
cwid = lonarr(6)
basetop = widget_base(base, /row)
drawid(0) = widget_draw(basetop, xsize=xsize, ysize=ysize, /frame, retain=2)
drawid(1) = widget_draw(basetop, xsize=xsize, ysize=ysize, /frame, retain=2)
basebottom = widget_base(base, /row)
drawid(2) = widget_draw(basebottom, xsize=1.5*xsize, ysize=300, /frame, retain=2)

buttonid = widget_base(basebottom, /column)
compute = widget_button(buttonid, value='Compute', uvalue='Compute', event_pro='redisplay')
cwid(0) = cw_field(buttonid, xsize=14, value=seuil(0), title= 'seuil0', /float)
cwid(1) = cw_field(buttonid, xsize=14, value=seuil(1), title= 'seuil1', /float)
cwid(2) = cw_field(buttonid, xsize=14, value=apod, title= 'apodize', /float)
cwid(3) = cw_field(buttonid, xsize=14, value=0., title= 'noise', /float)
cwid(4) = cw_field(buttonid, xsize=14, value=0., title= 'slope', /noedit)
cwid(5) = cw_field(buttonid, xsize=14, value=0., title= 'normal', /noedit)
base_toggle = widget_base(buttonid, /column, /nonexclusive)
median_toggle = widget_button(base_toggle, value='median', uvalue='median', event_pro='set_median')

quit = widget_button(buttonid, value='Quit', uvalue='Quit', event_pro='widget_exit')

; Realize widget
widget_control, base, /realize

; Create and store information structure
mapptr = ptr_new(map)
drawidptr = ptr_new(drawid)
cwidptr = ptr_new(cwid)

info = {drawidptr:drawidptr, cwidptr:cwidptr, mapptr:mapptr, rebin:rebin, median:median}
infoptr = ptr_new(info)
widget_control, base, set_uvalue=infoptr

if keyword_set(median) then widget_control, median_toggle, /set_button

display_all, infoptr

; Start managing events
xmanager, 'xft', base, cleanup='xft_cleanup', /no_block

end
