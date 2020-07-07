pro mamd_label, position, text, charsize=charsize, color=color

if not keyword_set(charsize) then charsize=1.

mamd_bar, position, clevels=1
posx = (position(0)+position(2))/2.
posy = (position(1)+position(3))/2.
xyouts, 2., 2., 'o', charsize=charsize, width=width, /normal
xyouts, posx, posy-width/2., text, /normal, charsize=charsize, alignment=0.5, width=width, color=color
print, width

end


