pro starhopper_event, event

;------------------------------------------------
;
; STARHOPPER_EVENT
;
; Procedure qui gere les evenements
;
;-----------------------------------------------

;-------------------------------------------
; Definition des variables globales
;-------------------------------------------

common bo, widgval, n, graphic_file, screen

;-------------------------------------------
; Pompage de l'uvalue de l'evenement
;-------------------------------------------

widget_control, event.id, get_uvalue=eventval, /draw_motion_events

;-------------------------------------------
; Reaction a l'evenement
;-------------------------------------------

case eventval of

; Deal with mouse position (change slide)
    'imaffi': begin
        if event.press eq 1 then begin
            if event.clicks eq 1 then begin
                n = n+1
                call_procedure, graphic_file, n
            endif else begin
                wdelete, 4
                WIDGET_CONTROL, /destroy, event.top
            endelse
        endif
        if event.press eq 4 then begin
            if event.clicks eq 2 then begin
                erase
                loadct, 20
            endif
            if event.clicks eq 1 then begin
                n = n-1
                call_procedure, graphic_file, n
            endif
        endif
        if event.press eq 2 then begin
            if event.clicks eq 1 then begin
                zoom
            endif 
        endif
    end

endcase

end


pro starhopper, file, noload=noload, xsize=xsize, ysize=ysize

;-------------------------------------------------------
;
; PRESENT
;
;-------------------------------------------------------

;----------------------------
; Common definition

common bo, widgval, n, graphic_file, screen


;----------------------------
; Global variable definition

load_file = strcompress(file, /rem) + '_load'
graphic_file = strcompress(file, /rem) + '_graphic'
n = 0
screen = get_screen_size() 
if keyword_set(xsize) then screen(0) = xsize
if keyword_set(ysize) then screen(1) = ysize

;-------------------------
; EXECUTE LOADING

if not keyword_set(noload) then begin
    tempo = findfile(load_file+'.pro', count=count)
    if (count gt 0) then call_procedure, load_file
endif

;---------------------------------------
; STRUCTURE DEFINITION

widgval = {imaffi:0L}

;-------------------------------------------
;  DEFINITION DE L'ENVIRONNEMENT GRAPHIQUE
; ------------------------------------------

base = widget_base(title='starHOPPER', /column)
widgval.imaffi = widget_draw(base, xsize=screen(0), ysize=screen(1), /frame, /motion_events, $
                             uvalue='imaffi', /button_event)
widget_control, base, /realize

call_procedure, graphic_file, n

xmanager, 'starhopper', base

closing:

end










