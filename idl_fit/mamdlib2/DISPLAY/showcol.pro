pro showcol

; SHOWCOL shows in a display window 
; all the colors defined in the mamd-color-table.
;
; this colors can be called with the mcol() function

;tvlct, r0, g0, b0, /get

restore, !MAMDLIB_DIR+'/DISPLAY/mamd_col_table.idl', /ver
r(255) = 255
g(255) = 255
b(255) = 255
tvlct, r, g, b

;t = r+g+b
;ind = sort(t)
;ind = sort(b)
ind_r = where(r gt b and r gt g)
ind_g = where(g gt b and g ge r)
ind_b = where(b ge g and b ge r)
ind = [ind_r, ind_g, ind_b]
r = r[ind]
g = g[ind]
b = b[ind]
colorname = colorname[ind]

ind = where(colorname ne 'black', nbind, compl=compl)
nbind = 1.*nbind
nbcol = 5.
nbrow = ceil(nbind/nbcol)

image = fltarr(10,10)
spacex = 0.185
dtext = 0.0
charsize=1.2
pos = multipos( nbcol, nbrow, dx=spacex, dy=0.02, margex=[0.005, spacex], margey=[0.005, 0.005] )

image(*) = ind(0)
imaffi, image, position=pos(*,0), /nocadre, imrange=[0,255], winnumber=10
xyouts, pos(2,0)+dtext, pos(1,0), strcompress(colorname(ind(0))), /normal, charsize=charsize, col=compl[0]
tvlct, r, g, b
for i=1, nbind-1 do begin
    image(*) = ind(i)
    tv, image, pos[0,i], pos[1,i], /normal, true=true
;    imaffi, image, position=pos(0:1,i), /nocadre, imrange=[0,255]
    xyouts, pos(2,i)+dtext, pos(1,i), strcompress(colorname(ind(i))), /normal, charsize=charsize, col=compl[0]
endfor

;tvlct, r0, g0, b0
mamdct, !MAMDLIB.COLTABLE, /silent

end
