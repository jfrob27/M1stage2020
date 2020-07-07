pro mamd_bar, pos_input, clevels=clevels, position=position, $
              grid=grid, imrange=imrange, dchars=dchars, $
              value=value, pleg=pleg, charsize=charsize, $
              ticklen=tick, otherside=otherside, imbar=imbar, invert=invert, format=format, $
              nbvalue=nbvalue, label=label, orientation=orientation
;+
; NAME: mamd_bar
;
; PURPOSE: Display an intensity bar
;
; CATEGORY: IMAGE DISPLAY
;
; CALLING SEQUENCE: mamd_bar, position
;
; INPUTS: 
;        pos_input: fltarr(4) of display position (in NORMAL
;                  coordinate)
;                  position(0): X value of lower left corner
;                  position(1): Y value of lower left corner
;                  position(2): X value of higher right corner
;                  position(3): Y value of higher right corner
;
; KEYWORD PARAMETERS:
;        imrange: fltarr(2)
;                 dynamical display range
;                 [minimum intensity, maximum intensity]
;        format: string
;                 the format of the value displayed.
;        value: fltarr
;                 vector of intensity value to be put as tick
;                 marks.
;        charsize: float 
;                  character size
;        otherside: keyword
;                   put the tick name on the other side of the bar
;        invert: keyword
;                invert the color table
;        ticklen: float
;              length of tick marks
;        clevels: integer
;              number of color levels (default = 256)
;        grid: keyword
;              put a grid between each color levels
;
; OPTIONAL OUTPUTS:
;        imbar: fltarr(2D)
;              the bar image

; COMMON BLOCKS:
;       mamd_var
;
; EXAMPLE:
;         mamd_bar, [0.8,0.1,0.9,0.9], imrange=[20, 50], $
;                       value=[20, 30, 40, 50]
;
;
; MODIFICATION HISTORY:
;  MAMD 22/10/1998
;-


;common mamdvar

; KEYWORDS
if not keyword_set(clevels) then clevels=!MAMDLIB.TOP+1
if not keyword_set(charsize) then charsize=!BAR.charsize
if not keyword_set(tick) then tick=!BAR.ticklen
if not keyword_set(nbvalue) then nbvalue=3
if not keyword_set(orientation) then orientation=!BAR.orientation
if not keyword_set(format) then format=!BAR.format

if keyword_set(pos_input) then position=pos_input

; Calcul de la taille (en pixel) de l'image
x_pos = position(2)-position(0)
y_pos = position(3)-position(1)

case !D.NAME of
    'X': begin
        xsizewin = !D.X_SIZE
        ysizewin = !D.Y_SIZE
    end
    'PS': begin
        xsizewin = !MAMDLIB.cXSIZE
        ysizewin = !MAMDLIB.cYSIZE
    end
    else: begin
        print, 'Device type not supported'
        goto, sortie
    end
endcase

x_dev = 1.*x_pos*xsizewin
y_dev = 1.*y_pos*ysizewin

;if (!D.NAME eq 'X') then begin
;endif else begin
;    if not keyword_set(ps_sizex) then ps_sizex = 1
;    if not keyword_set(ps_sizey) then ps_sizey = 1
;    if not keyword_set(scale) then scale = 1
;    x_dev = ps_sizex*x_pos/(0.001*scale)
;    y_dev = ps_sizey*y_pos/(0.001*scale)
;endelse


; Creation de l'image
;imbar = fltarr(max([x_dev, y_dev]) > 1, min([x_dev, y_dev]) > 1)
imbar = bytarr(max([x_dev, y_dev]) > 1, min([x_dev, y_dev]) > 1)
length_dev = x_dev > y_dev
length_pos = x_pos > y_pos
pas_dev = fix(length_dev/clevels)
for i=0, length_dev-1 do imbar(i,*) = fix(1.*i*(clevels)/(length_dev-1.))
if keyword_set(invert) then imbar = rotate(imbar, 5)
if (x_dev le y_dev) then imbar = rotate(imbar, 4)

; Affichage de l'image
if (!D.NAME eq 'X') then tv, imbar, position(0), position(1), /normal $
else begin
;    if (clevels eq 1) then begin
;        imbar(*,*) = 256.
;        imbar(0,0) = 0.
;    endif
    debutx = position(0) * !MAMDLIB.ps_sizex
    debuty = position(1) * !MAMDLIB.ps_sizey
    xsize = (position(2)-position(0)) * !MAMDLIB.ps_sizex
    ysize = (position(3)-position(1)) * !MAMDLIB.ps_sizey
    TV, imbar, debutx, debuty, /centimeters, xsize=xsize, ysize=ysize
endelse



; Affichage du cadre
plots, position(0), position(1), /normal
plots, [position(0)+x_pos, position(0)+x_pos, position(0), position(0)], $
  [position(1), position(1)+y_pos, position(1)+y_pos, position(1)], $
  /continue,  /normal


; Affichage de la grille
if keyword_set(grid) then begin
    if (x_dev gt y_dev) then coupe = imbar(*,0) else coupe = imbar(0,*)
    ind = where(coupe-shift(coupe,1) ne 0)
    coupe = indgen(length_dev)*length_pos/length_dev
    for i=0, n_elements(ind)-1 do begin
        if (x_dev gt y_dev) then $
          plots, [coupe(ind(i))+position(0), coupe(ind(i))+position(0)], $
          [position(1), position(1)+y_pos], /normal $
        else $
          plots, [position(0), position(0)+x_pos], $
          [coupe(ind(i))+position(1), coupe(ind(i))+position(1)], /normal
    endfor
endif

; Affichage de la legende
if keyword_set(imrange) then begin
    if not keyword_set(value) then begin
        pas = (imrange(1)-imrange(0))/(1.*nbvalue-1.)
        value = findgen(nbvalue)*pas+imrange(0)
;      value = [imrange(0), (imrange(1)+imrange(0))/2., imrange(1)]
    endif
    if (x_dev gt y_dev) then begin
        posbase = position(0) 
        width_base = y_pos
        alignement = 0.5
        if not keyword_set(pleg) then pleg = !BAR.pleg
        if not keyword_set(dchars) then dchars = !BAR.dchars
        if keyword_set(otherside) then begin
            width_base = 0
            tick = -1.*tick
            pleg = -1.*pleg
        endif
    endif else begin
        alignement = 0.
        posbase = position(1)
        width_base = x_pos
        if not keyword_set(pleg) then pleg = !BAR.pleg
        if not keyword_set(dchars) then dchars = !BAR.dchars
        if keyword_set(otherside) then begin
            alignement = 1.0
            pleg = -1.*pleg
            width_base = 0
            tick = -1.*tick
        endif
    endelse
    x = (value-imrange(0))*length_pos/(imrange(1)-imrange(0))+posbase
    for i=0, n_elements(value)-1 do begin  
        if keyword_set(label) then toprint = strc(label(i)) else begin
            if not keyword_set(format) then begin
                if (abs(value(i)) ge 1000 or (abs(value(i)) lt 0.1 and value(i) gt 0.)) then $
                  format0 = '(E8.1)' else format0 = '(f6.2)'
            endif else format0 = '('+format+')'
            toprint = strcompress(string(value(i),format=format0), /rem)
        endelse
        if (x_dev le y_dev) then begin
           if (orientation eq 90) then begin
              case i of
                 0: ali=0
                 n_elements(value)-1: ali=1.0
                 else: ali=0.5
              endcase
           endif else begin
              ali=alignement
           endelse
            plots, [position(0)+width_base, position(0)+width_base+tick], $
              [x(i), x(i)], /normal
            xyouts, position(0)+width_base+pleg, x(i)-dchars, $
              toprint, /normal, charsize=charsize, alignment=ali, orientation=orientation
        endif else begin
           if (orientation eq 0) then begin
              case i of
                 0: ali=0
                 n_elements(value)-1: ali=1.0
                 else: ali=alignement
              endcase
           endif else begin
              ali=0
           endelse
            plots, [x(i), x(i)], $
              [position(1)+width_base, position(1)+width_base+tick], /normal
            xyouts, x(i)-dchars, position(1)+width_base+pleg, $
              toprint, /normal, charsize=charsize, alignment=ali, orientation=orientation
        endelse
    endfor
endif


sortie:

end
