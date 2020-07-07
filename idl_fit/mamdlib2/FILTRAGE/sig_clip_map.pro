function sig_clip_map, map0, thresh, si_window, interpolate=interpolate, indef=indef, $
                       abs=abs, min=min, mask=masque, percent=percent, silent=silent, fraction=fraction, $
                       ratio=ratio

; PROCEDURE
; Uses smooth_slice
;
; MAMD October 8 2003 ; deal with undefined values. Put comments


;===================== INPUTS ============================
if (size(map0))(0) ne 2 then begin
    print, 'Syntax - result = sig_clip_map( map, thresh, size_window, [/interpolate, $ '
    print, '                     indef=, /abs, min=, masque=, percent=, /silent, fraction=])'
    mapout = -1
    GOTO, CLOSING
endif

if not keyword_set(indef) then indef=-32768.
if not keyword_set(thresh) then begin
    if keyword_set(ratio) then thresh=0.15 else thresh=10.
endif
if not keyword_set(si_window) then si_window=6.
IF NOT keyword_set(percent) THEN percent =  100.
if not keyword_set(min) then min=0
IF NOT keyword_set(masque) THEN BEGIN
    masque = map0
    masque(*) = 1.
endif

;====== CHECK FOR DEFINED VALUES ===============
ind_good = where(map0 ne indef, nbindef)
if nbindef eq 0 then begin
    if not keyword_set(silent) then PRINT, 'NO DEFINED VALUES IN INPUT MAPS'
    MAPOUT = -1
    GOTO, CLOSING
endif

;====== COMPUTE RESIDU MAP =====================
SmoothMap = smooth_slice(map0, si_window, indef=indef)
residu = map0 - SmoothMap
residu = residu(ind_good)

;======= IDENTIFY PIXELS TO CLIP==================
if keyword_set(ratio) then begin
    seuil = SmoothMap 
endif else begin
    ind = sort(residu)
    nx = n_elements(ind)
    seuil = stdev(residu(ind(0.1*nx:0.9*nx)))
endelse
SmoothMap = 0
if keyword_set(abs) then begin
    ind = where(abs(residu) gt (thresh*seuil > min) AND masque EQ 1., nbind)
endif else begin
    ind = where(residu gt (thresh*seuil > min) AND masque EQ 1., nbind)
endelse

;======== GET OUT IF NO PIXELS IDENTIFIED ==============
if (nbind eq 0) then begin 
    if not keyword_set(silent) then PRINT, 'NO PIXELS IDENTIFIED
    mapout=map0
    GOTO, CLOSING
endif

;========== MAKE SURE THE NUMBER OF FLAGGED PIXELS ============
;================= DO NOT EXCEED percent =====================
IF (1.*nbind/(n_elements(residu))*100. GT percent) THEN BEGIN
    nout =  fix(n_elements(residu) * percent/100.)
    if keyword_set(abs) then ind2 =  reverse(sort(abs(residu(ind)))) else $
      ind2 =  reverse(sort((residu(ind))))
    ind2 =  ind2(0:nout)
    ind =  ind(ind2)
endif

;=========== PUT FLAGGED PIXELS TO INDEF ==============
mapout = map0
mapout(ind_good(ind)) = indef
fraction = 1.*n_elements(ind)/(n_elements(residu))
if not keyword_set(silent) then print, fraction*100., ' percent of defined pixels are flagged'

;========= INTERPOLATE DATA ONLY IN FLAGGED REGIONS ==============
if keyword_set(interpolate) then begin
    masque(*) = 0
    masque(ind_good(ind)) = 1
    ind_bad = where(mapout eq indef and masque eq 1, nbind)
    nn=0
    while (nbind gt 0 and nn lt 20) do begin 
        mapout = interpoler(mapout, kernel=1, dx=2, dy=2, nb=1, mask=masque) 
        ind_bad = where(mapout eq -32768 and masque eq 1, nbind) 
        nn = nn  +1
    endwhile
    ind_bad = where(map0 eq indef, nbind)
    if (nbind gt 0) then mapout(ind_bad) = indef
endif 


;============= CLOSING ================
CLOSING:
return, mapout

end
