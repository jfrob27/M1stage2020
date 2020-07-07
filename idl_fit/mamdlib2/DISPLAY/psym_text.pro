;pro psym_text, posx, posy, text, psym=psym, color=color, charsize=charsize, symsize=symsize, dx=dx, dy=dy, linestyle=linestyle
pro psym_text, posx, posy, text, color=color, _extra=Extra, dx=dx, dy=dy

if not keyword_set(dx) then dx=0. ;dx=0.01
if not keyword_set(dy) then dy=0 ;dy=-0.008

if keyword_set(color) then plots, posx, posy, color=color, _extra=Extra else plots, posx, posy, _extra=Extra

xyouts, max(posx)+dx, max(posy)+dy, text, _extra=Extra

end

