pro label, pos, namelist, color=color, linestyle=linestyle, linefraction=linefraction, $
           xmargin=xmargin, linelength=linelength, psym=psym, _Extra=extra

;rectangle, pos
plots, [pos(0), pos(2), pos(2), pos(0), pos(0)], [pos(1), pos(1), pos(3), pos(3), pos(1)], /normal
nb = n_elements(namelist)
if not keyword_set(color) then color=replicate(!MAMDLIB.COLOR, nb)
if not keyword_set(psym) then psym=replicate(0, nb)
if not keyword_set(linestyle) then linestyle=replicate(0, nb)
if keyword_set(linelength) then dx=linelength
if keyword_set(linefraction) then dx = linefraction*(pos(2)-pos(0))
if not keyword_set(dx) then dx=0.02
if not keyword_set(xmargin) then xm=0.01 else xm=xmargin

dy = (pos(3)-pos(1))/(nb+1.)
for i=0, nb-1 do tag, [pos[0]+xm, pos[1]+dy*(i+1), pos[0]+xm+dx, pos[1]+dy*(i+1)], _Extra=extra, $
                      namelist[i], color=color[i], linestyle=linestyle[i], psym=psym[i], /normal;, textcolor=color[i]

end
