function multipos, nx, ny, margex=margex, margey=margey, dx=dx, dy=dy, top=top, reverse=reverse, $
                   column=column

position = fltarr(4, nx*ny)

;---------------------------------------------------
; X and Y interspace

if not keyword_set(dx) then dx=0.05
if not keyword_set(dy) then dy=0.05
ddx = (nx-1.)*dx
ddy = (ny-1.)*dy

;---------------------------------------------------
; X and Y margin

if not keyword_set(margex) then margex=[0.15, 0.05]
if not keyword_set(margey) then margey=[0.15, 0.05]
mx = margex
my = margey
if n_elements(mx) eq 1 then mx = [mx, mx]
if n_elements(my) eq 1 then my = [my, my]

; X and Y space of each item
px = (1.0 - ddx - total(mx))/(1.*nx)
py = (1.0 - ddy - total(my))/(1.*ny)

n=0
if keyword_set(reverse) or keyword_set(top) then begin
    jdebut = ny-1
    jfin = 0
    jincrement = -1
endif else begin
    jdebut = 0
    jfin = ny-1
    jincrement = 1
endelse

if keyword_set(column) then begin
    for i=0, nx-1 do begin 
        for j=jdebut, jfin, jincrement do begin
            position(*, n) = [mx(0)+i*(px+dx), my(0)+j*(py+dy), mx(0)+i*(px+dx)+px, my(0)+j*(py+dy)+py]  
            n = n+1
        endfor
    endfor
endif else begin
    for j=jdebut, jfin, jincrement do begin
        for i=0, nx-1 do begin 
            position(*, n) = [mx(0)+i*(px+dx), my(0)+j*(py+dy), mx(0)+i*(px+dx)+px, my(0)+j*(py+dy)+py]  
            n = n+1
        endfor
    endfor
endelse

return, position

end


