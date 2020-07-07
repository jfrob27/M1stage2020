pro rectangle, pos_input, col_index, nocadre=nocadre

;+
; NAME: rectangle
;
; PURPOSE: Display a rectangle of a given color
;
; CATEGORY: IMAGE DISPLAY
;
; CALLING SEQUENCE: rectangle, position, color
;
; INPUTS: 
;        position: fltarr(4) of display position (in NORMAL
;                  coordinate)
;                  position(0): X value of lower left corner
;                  position(1): Y value of lower left corner
;                  position(2): X value of higher right corner
;                  position(3): Y value of higher right corner
;        color: int -> color code
;
; KEYWORD PARAMETERS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;  MAMD 11/10/2002
;-

;common mamdvar

; KEYWORDS

position=pos_input

mamdct, !MAMDLIB.COLTABLE, /silent

; Calcul de la taille (en pixel) de l'image
x_pos = position(2)-position(0)
y_pos = position(3)-position(1)

case !D.NAME of
    'X': begin
        xsizewin = !D.X_SIZE
        ysizewin = !D.Y_SIZE
    end
    'PS': begin
        xsizewin = !MAMDLIB.CXSIZE
        ysizewin = !MAMDLIB.CYSIZE
    end
    else: begin
        print, 'Device type not supported'
        goto, sortie
    end
endcase

x_dev = 1.*x_pos*xsizewin
y_dev = 1.*y_pos*ysizewin

; Creation de l'image
;imbar = bytarr(max([x_dev, y_dev]) > 1, min([x_dev, y_dev]) > 1)
if not keyword_set(col_index) then col_index=!MAMDLIB.BACKGROUND
imbar = bytarr(x_dev > 1, y_dev > 1)
imbar(*) = col_index
;length_dev = x_dev > y_dev
;length_pos = x_pos > y_pos

; Affichage de l'image
if (!D.NAME eq 'X') then begin
    tv, imbar, position(0), position(1), /normal
    print, position(0), position(1)
endif else begin
   ps_sizex = !MAMDLIB.PS_SIZEX
   ps_sizey = !MAMDLIB.PS_SIZEY
    debutx = position(0) * ps_sizex
    debuty = position(1) * ps_sizey
    xsize = (position(2)-position(0)) * ps_sizex
    ysize = (position(3)-position(1)) * ps_sizey
    TV, imbar, debutx, debuty, /centimeters, xsize=xsize, ysize=ysize
endelse

; Affichage du cadre
if not keyword_set(nocadre) then cadre, position

sortie:

end
