pro plot_reglin, x, y, dy, xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, _Extra=extra, silent=silent
;+
; NAME:
;   PLOT_REGLIN
;
; PURPOSE:
;  Compute and plot the linear regression Y = a + b*X
;
; CALLING SEQUENCE:
;  plot_reglin, x, y, dy, xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, _Extra=extra, silent=silent
;
; INPUTS:
;  X: 1D vector of X values
;  Y: 1D vector of Y values
;
; OPTIONAL INPUTS:
;  DY: 1D vector of uncertainty of Y values
;
; KEYWORD PARAMETERS:
;  XMIN: minmimum X value consider for the fit
;  XMAX: maximum X value consider for the fit
;  YMIN: minmimum Y value consider for the fit
;  YMAX: maximum Y value consider for the fit
;
; PROCEDURE:
;   REGLIN.PRO
;
; EXAMPLE:
;   plot_reglin, findgen(100), y, dy, xmin=0., xmax=10.
;
; MODIFICATION HISTORY:
;   11/12/2001, MAMD
;-


;------------------------------------------------------
; KEYWORDS

if not keyword_set(xmin) then xmin = min(x)
if not keyword_set(xmax) then xmax = max(x)
if not keyword_set(ymin) then ymin = min(y)
if not keyword_set(ymax) then ymax = max(y)

;------------------------------------------------------
; DISPLAY

plot, x, y, _Extra=extra
if keyword_set(dy) then errplot, x, y-dy, y+dy

;------------------------------------------------------
; Linear regression

ind = where(x le xmax and x ge xmin and y le ymax and y ge ymin, nbind)
if (nbind gt 0) then begin

    if keyword_set(dy) then model = reglin(x(ind), y(ind), dy(ind), coeff=res, dcoeff=dres) else $
      model = reglin(x(ind), y(ind), coeff=res, dcoeff=dres)

    oplot, x(ind), model, color=tcol('red')
    oplot, [min(x(ind)), min(x(ind))], minmax(y(ind)), col=tcol('blue')
    oplot, [max(x(ind)), max(x(ind))], minmax(y(ind)), col=tcol('blue')

    b1 = res(1)+dres(1)
    b2 = res(1)-dres(1)
    a1 = avg(y - b1*x)
    a2 = avg(y - b2*x)
    oplot, x(ind), a1+b1*x(ind), col=tcol('yellow'), linestyle=2
    oplot, x(ind), a2+b2*x(ind), col=tcol('yellow'), linestyle=2

    IF not keyword_set(silent) THEN begin
        print, 'y = a + b*x'
        print, 'a: ', res(0), dres(0)
        print, 'b: ', res(1), dres(1)
    ENDIF

endif else begin
    print, 'No valid point for linear regression'
endelse


end
