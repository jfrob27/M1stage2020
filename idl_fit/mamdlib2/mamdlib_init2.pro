pro mamdlib_init2, coltable, nox=nox, FILE_COLTABLE=file_coltable

if not keyword_set(coltable) then coltable=0
if not keyword_set(file_coltable) then file_coltable = FILEPATH('colors1.tbl', subdir=['resource', 'colors'])

;----------------------------------
; MAMDLIB GLOBAL VARIABLE
MAMDLIB = {X_THICK:1.0, $      ; thickness of plot axis in device=X
           PS_THICK:4.0, $     ; thickness of plot axis in device=PS
           SCALE:0., $
           PS_SIZEX:0., $
           PS_SIZEY:0., $
           cXSIZE:0., $
           cYSIZE:0., $
           PS_FONT:'Helvetica', $
           DEVICE:'X', $
           COLTABLE:coltable, $
           FILECOLTABLE:file_coltable, $
           TOP:253, $
           BACKGROUND:255, $           
           COLOR:254}
defsysv, '!MAMDLIB', MAMDLIB

IMAFFI = {cadrenu:0, $
          rebin:1., $
          charsize:1.}
defsysv, '!IMAFFI', IMAFFI

BAR = {thickbar:0.01, $
       ticklen:0.01, $
       dxbar:0.01, $
       dybar:0.0, $
       pleg:0.02, $
       dchars:0.0, $
       charsize:1.0, $
       orientation:0., $
       alignement:0.5, $
       fraction:1.0, $
       format:'(F5.1)'}
defsysv, '!BAR', BAR

if keyword_set(nox) then begin
    set_plot, 'ps'
    !MAMDLIB.DEVICE = 'PS'
 endif else begin
    set_plot, 'X'
    !MAMDLIB.DEVICE = 'X'
    DEVICE, RETAIN=2, DECOMPOSED=0, set_character_size=[10, 12]
    device, get_visual_depth=depth
    print, 'Display depth: ', depth
    print, 'Color table size: ', !d.table_size
endelse

; SET FONT TO TRUE TYPE
;!P.FONT = 0
device, set_font='Helvetica', /tt_font
mamdct, coltable, background='white', color='black'

!p.background=!MAMDLIB.BACKGROUND
!p.color=!MAMDLIB.COLOR
erase

print, "MAMDLIB Software now available"


end
