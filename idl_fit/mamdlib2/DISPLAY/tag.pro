PRO tag, position, tagname, normal=normal, device=device, data=data, $
         linestyle=linestyle, noline=noline, thick=thick, $
         charsize=charsize, voffset=voffset, hoffset=hoffset, textcolor=textcolor, $
         radius=radius, backcolor=backcolor, color=color, psym=psym

IF NOT keyword_set(normal) THEN normal = 0
IF NOT keyword_set(device) THEN device =  0
IF NOT keyword_set(data) THEN data = 0
IF (data EQ 0 AND normal EQ 0 AND device EQ 0) THEN data =  1
IF NOT keyword_set(charsize) THEN charsize = 1.
IF NOT keyword_set(hoffset) THEN hoffset = 0.01
IF NOT keyword_set(backcolor) THEN backcolor = !MAMDLIB.BACKGROUND
IF NOT keyword_set(color) THEN color = !MAMDLIB.COLOR
IF NOT keyword_set(textcolor) THEN textcolor = !MAMDLIB.COLOR
IF NOT keyword_set(linestyle) THEN linestyle = 0
IF NOT keyword_set(thick) THEN thick = 1

if (size(color, /type) eq 7) then col=mcol(color) else col=color
if (size(textcolor, /type) eq 7) then tcol=mcol(textcolor) else tcol=textcolor

IF NOT keyword_set(noline) THEN begin
   if keyword_set(psym) then begin
      xvec = (position[0]+position[2])/2.
      yvec = position[1]
   endif else begin
      xvec = [position(0), position(2)]
      yvec = [position(1), position(3)]
   endelse
   plots, xvec, yvec, data=data, normal=normal, device=device, $
          color=col, linestyle=linestyle, thick=thick, psym=psym
endif 

; DISPLAY CIRCLE and TEXT INSIDE
IF keyword_set(radius) THEN begin
   IF NOT keyword_set(voffset) THEN voffset = 1.
   A =  findgen(36) * (!pi*2/35)
   usersym, radius*cos(a), radius*sin(a), /fill
   plots, position(2), position(3), psym=8, data=data, normal=normal, device=device, col=backcolor
   usersym, radius*cos(a), radius*sin(a)
   plots, position(2), position(3), psym=8, data=data, normal=normal, device=device, color=col
   xyouts, position(2), voffset*position(3), tagname, data=data, normal=normal, device=device, align=0.5, $
    color=textcolor, charsize=charsize
ENDIF ELSE BEGIN
   IF NOT keyword_set(voffset) THEN voffset = 0.
   xyouts, position(2)+hoffset, position(3)-voffset, tagname, data=data, normal=normal, device=device, align=0, $
    color=tcol, charsize=charsize
endelse

mamdct, /silent

end
