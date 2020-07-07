function sigclip, vector, sigmathresh=thresh, window=si_window, $
                      interpolate=interpolate, indef=indef, $
                      abs=abs, silent=silent, fraction=fraction, $
                      min=min, mask=mask, contrast=contrast, nbiteration=nbiteration, level=level
;+
; NAME:
;          CLIP_SOURCE
;
; PURPOSE:
;          To extract point sources from fields with a lot of
;          structure in the diffuse emission (like IRAS/DIRBE maps).
;
; CALLING SEQUENCE:
;          result = clip_source( map, contrast=, sigmathresh=,
;          window=, /interpolate, indef=, level=, /abs, /silent,
;          fraction=, min=)
;
; INPUTS:
;          map : 2D array.
;
; OPTIONAL INPUTS:
;
;         SIGMATHRESH: Pixels with a flux higher than
;         SIGMATHRESH*STDEV(small scale fluctuations) are
;         clipped.  Default is 10.
;
;         WINDOW: size of the smoothing window. Default is 6
;
;         INDEF: the undefined value in the map. Default is -32768.
;
;         MIN: minimum small scale fluctuation level under
;         which no pixels are removed. Default is 0.
;
; KEYWORD PARAMETERS:
;
;         ABS: if set the fluctuations are treated absolute
;         values. The default is to clip only positive fluctuations.
;
;         INTERPOLATE: If set the clipped pixels are interpolated.
;
; OUTPUTS:
;         RESULT : a 1D array with deviant values replace by indef
;
; OPTIONAL OUTPUTS:
;         FRACTION : the fraction of defined pixels that were clipped
;
; PROCEDURE:
;       smooth_slice, interpoler
;
; MODIFICATION HISTORY:
;         October 8 2003, MAMD; creation
;-


;===================== INPUTS ============================
if (size(vector))(0) ne 1 then begin
    print, 'Syntax - result = sigclip( vector, thresh, size_window, [/interpolate, $ '
    print, '                     indef=, /abs, min=, mask=, percent=, /silent, fraction=])'
    mapout = -1
    GOTO, CLOSING
endif


if not keyword_set(level) then level=0.1
if not keyword_set(nbiteration) then nbiteration=1
if not keyword_set(indef) then indef=-32768.
if not keyword_set(thresh) then thresh=10
if not keyword_set(si_window) then si_window=6.
if not keyword_set(min) then min=0.
if not keyword_set(mask) then begin 
    mask = vector
    mask(*) = 0
endif

result = vector
i_iteration = 0
while (i_iteration lt nbiteration) do begin

if not keyword_set(silent) then print, 'iteration nb ', i_iteration+1

;====== CHECK FOR DEFINED VALUES ===============
    ind_good = where(result ne indef, nbindef)
    if nbindef eq 0 then begin
        if not keyword_set(silent) then PRINT, 'NO DEFINED VALUES IN INPUT VECTOR'
        RESULT = -1
        GOTO, CLOSING
    endif

;====== COMPUTE SMOOTH MAP =====================
    SmoothVector = smooth_slice(result, si_window, indef=indef, /median)
    SmoothVector = SmoothVector(ind_good)
 
;======= IDENTIFY PIXELS TO CLIP==================

        residu = result(ind_good) - SmoothVector
        ind = sort(residu)
        nx = n_elements(ind)
        seuil = thresh*stdev(residu(ind(0.1*nx:0.9*nx)))
        if keyword_set(abs) then residu = abs(residu)
        ind = where(residu gt (seuil > min), nbind)
        if nbind gt 0 then begin
            result(ind_good(ind)) = indef
            mask(ind_good(ind)) = 1
        endif
        fraction = 1.*nbind/(n_elements(ind_good))
 

;======== GET OUT IF NO PIXELS IDENTIFIED ==============
    if (fraction eq 0) then begin 
        if not keyword_set(silent) then PRINT, 'NO PIXELS IDENTIFIED'
        GOTO, CLOSING
    endif
    if not keyword_set(silent) then print, fraction*100., ' percent of defined pixels are flagged'

    i_iteration = i_iteration+1

endwhile

;============= CLOSING ================
CLOSING:
return, result

end
