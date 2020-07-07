function apodize, na, nb, radius

; na : X size of the image
; nb : Y size of the image
; radius: value between 0 and 1

;-----------------------------------------
; CHECK INPUT PARAMETERS

IF N_PARAMS() lt 2 THEN BEGIN
    print, 'APODIZE, na, [nb], radius'
    return, 0
endif

IF N_PARAMS() eq 2 THEN BEGIN
    radius = nb
    nb = na
endif

if radius ge 1 or radius le 0. then begin
    print, 'radius must be lower than 1 and greater than 0.'
    return, 1
endif


ni = fix(radius*na)
dni = na-ni
nj = fix(radius*nb)
dnj = nb-nj

tap1d_x = fltarr(na)
tap1d_x(*) = 1.
tap1d_y = fltarr(nb)
tap1d_y(*) = 1.

tap1d_x(0:dni-1) = (COS(3*!PI/2.+!PI/2.*(1.*INDGEN( dni )/(dni-1)) ))
tap1d_x(na-dni:*) = (COS(0.+!PI/2.*(1.*INDGEN( dni )/(dni-1)) ))
tap1d_y(0:dnj-1) = (COS(3*!PI/2.+!PI/2.*(1.*INDGEN( dnj )/(dnj-1)) ))
tap1d_y(nb-dnj:*) = (COS(0.+!PI/2.*(1.*INDGEN( dnj )/(dnj-1)) ))

tapper=FLTARR(na, nb)
FOR i=0, nb-1 DO tapper(*,i) =tap1d_x
FOR i=0, na-1 DO tapper(i,*) = tapper(i,*)*tap1d_y

return, tapper

end
