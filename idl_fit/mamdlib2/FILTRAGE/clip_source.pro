function clip_source, map0, sigmathresh=thresh, window=si_window, $
  interpolate=interpolate, indef=indef, $
  abs=abs, silent=silent, fraction=fraction, $
  min=min, mask=mask, nbiteration=nbiteration, level=level
;+
; NAME:
;          CLIP_SOURCE
;
; PURPOSE:
;          To extract point sources from fields with a lot of
;          structure in the diffuse emission (like IRAS/DIRBE maps).
;
; CALLING SEQUENCE:
;          result = clip_source( map, sigmathresh=, window=, /interpolate, indef=, level=, /abs, /silent,
;          fraction=, min=)
;
; INPUTS:
;          map : 2D array.
;
; OPTIONAL INPUTS:
;         LEVEL : The regions with a brightness higher than LEVEL will
;                 be processed with the CONTRAST algorithm. Regions with
;                 brightness under LEVEL will be processed with the usual
;                 sigma clipping. If not set, the usual sigma clipping method is used everwhere.
;
;         SIGMATHRESH : Clipping threshold.
;                       Sigma clipping method: Pixels with a fluxfluctuation higher than
;                       SIGMATHRESH*STDEV(small scale fluctuations) are clipped.
;                       Contrast method : Pixels with a contrast higher than SIGMATHRESH*STDEV(small scale contrast)
;
;         WINDOW: size of the smoothing window. Default is 6
;
;         INDEF: the undefined value in the map. Default is -32768.
;
;         MIN: minimum small scale fluctuation level under
;              which no pixels are removed. Default is 0.
;
; KEYWORD PARAMETERS:
;
;         ABS: if set the fluctuations are treated as absolute
;              values - negative and positive fluctuations are treated equally. 
;              If not set (the default) only positive fluctuations are clipped.
;
;         INTERPOLATE: If set the clipped pixels are interpolated.
;
; OUTPUTS:
;         RESULT : a 2D array of same size as input map with sources removed.
;
; OPTIONAL OUTPUTS:
;         FRACTION : the fraction of defined pixels that were clipped
;
;         MASK : a 2D array of same size as input map with value=1 where 
;                sources were identified (and zero elsewhere)
;
; PROCEDURE:
;       smooth_slice, interpoler
;
; MODIFICATION HISTORY:
;         October 8 2003, MAMD; creation
;         May 22 2006, MAMD; remove contrast keyword - if Level is set, use contrast method
;-


;===================== INPUTS ============================
if (size(map0))(0) ne 2 then begin
    print, 'Syntax - result = clip_source( map, [sigmathresh=, window=, /interpolate, $ '
    print, '                     indef=, /abs, min=, mask=, percent=, /silent, fraction=, nbiteration=, level=])'
    mapout = -1
    GOTO, CLOSING
endif


if not keyword_set(level) then level = 1.1d*max(map0)
if not keyword_set(nbiteration) then nbiteration=1
if not keyword_set(indef) then indef=-32768.
if not keyword_set(thresh) then thresh=10
if not keyword_set(si_window) then si_window=6.
if not keyword_set(min) then min=0.
if not keyword_set(mask) then begin 
    mask = map0
    mask(*) = 0
endif

mapout = map0
i_iteration = 0
while (i_iteration lt nbiteration) do begin

    if not keyword_set(silent) then print, 'iteration nb ', i_iteration+1

;====== CHECK FOR DEFINED VALUES ===============
    ind_good = where(mapout ne indef, nbindef)
    if nbindef eq 0 then begin
        if not keyword_set(silent) then PRINT, 'NO DEFINED VALUES IN INPUT MAPS'
        MAPOUT = -1
        GOTO, CLOSING
    endif

;====== COMPUTE SMOOTH MAP =====================
    SmoothMap = smooth_slice(mapout, si_window, indef=indef, /median)
    SmoothMap = SmoothMap(ind_good)
    ind_low = where(SmoothMap le level, nb_low, complement=ind_high, ncomplement=nb_high)

;======= IDENTIFY PIXELS TO CLIP==================

;------ Standard sigma-clipping method -----------------
    if (nb_low gt 1) then begin
        residu = mapout(ind_good(ind_low)) - SmoothMap(ind_low)
        ind = sort(residu)
        nx = n_elements(ind)
        seuil = thresh*stddev(residu(ind(0.1*nx:0.9*nx)))
        if keyword_set(abs) then residu = abs(residu)
        ind = where(residu gt (seuil > min), nbind)
        if nbind gt 0 then begin
            mapout(ind_good(ind_low(ind))) = indef
            mask(ind_good(ind_low(ind))) = 1
        endif
        fraction_low = 1.*nbind/(n_elements(ind_good))
    endif else fraction_low=0.

;------ Contrast method -----------------------
    if (nb_high gt 1) then begin
        residu = (mapout(ind_good(ind_high)) - SmoothMap(ind_high)) / SmoothMap(ind_high)
        ind = sort(residu)
        nx = n_elements(ind)
        seuil = thresh*stddev(residu(ind(0.1*nx:0.9*nx)))
        if keyword_set(abs) then residu = abs(residu)
        ind = where(residu gt (seuil > min), nbind)
        if (nbind gt 0) then begin
            mapout(ind_good(ind_high(ind))) = indef
            mask(ind_good(ind_high(ind))) = 1
        endif
        fraction_high = 1.*nbind/(n_elements(ind_good))
    endif else fraction_high=0.

    fraction = fraction_high + fraction_low

;======== GET OUT IF NO PIXELS IDENTIFIED ==============
    if (fraction eq 0) then begin 
        if not keyword_set(silent) then PRINT, 'NO PIXELS IDENTIFIED'
        GOTO, CLOSING
    endif

;=========== PUT FLAGGED PIXELS TO INDEF ==============
    if not keyword_set(silent) then print, fraction*100., ' percent of defined pixels are flagged', fraction_low*100, fraction_high*100

;========= INTERPOLATE DATA ONLY IN FLAGGED REGIONS ==============
    if keyword_set(interpolate) then begin
        ind_bad = where(mapout eq indef and mask eq 1, nbind)
        nn=0
        while (nbind gt 0 and nn lt 20) do begin 
;            mapout = interpoler(mapout, kernel=1, dx=2, dy=2, nb=1, mask=mask) 
            mapout = interpoler(mapout, /median, dx=si_window(0)/2., dy=si_window(1)/2., nb=1, mask=mask) 
            ind_bad = where(mapout eq -32768 and mask eq 1, nbind) 
            nn = nn  +1
        endwhile
    endif 

    i_iteration = i_iteration+1

endwhile

;============= CLOSING ================
CLOSING:
return, mapout

end
