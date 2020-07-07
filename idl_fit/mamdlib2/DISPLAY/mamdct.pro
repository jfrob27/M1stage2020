pro mamdct, coltable, background=background, color=color, silent=silent

if (n_elements(coltable) eq 0) then coltable=!MAMDLIB.COLTABLE
if not keyword_set(silent) then silent=0
;ctable = fix(coltable)>0<40
ctable=fix(coltable)
!MAMDLIB.COLTABLE=ctable
loadct, ctable, ncolors=!MAMDLIB.TOP+1, /silent, file=!MAMDLIB.FILECOLTABLE
tvlct, r0, g0, b0, /get
loadct, ctable, silent=silent, file=!MAMDLIB.FILECOLTABLE

r1 = r0
g1 = g0
b1 = b0

restore, !MAMDLIB_DIR+'/DISPLAY/mamd_col_table.idl'

if not keyword_set(background) then background='white'
ind = where( colorname eq background, nbind )
if (nbind ne 0) then begin
   r1(!MAMDLIB.background) = r(ind(0))
   g1(!MAMDLIB.background) = g(ind(0))
   b1(!MAMDLIB.background) = b(ind(0))
endif

if not keyword_set(color) then color='black'
ind = where( colorname eq color, nbind )
if (nbind ne 0) then begin
   r1(!MAMDLIB.color) = r(ind(0))
   g1(!MAMDLIB.color) = g(ind(0))
   b1(!MAMDLIB.color) = b(ind(0))
endif

tvlct, r1, g1, b1

end
