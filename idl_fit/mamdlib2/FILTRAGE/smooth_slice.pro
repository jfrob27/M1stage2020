function smooth_slice, array_in, factor, indef=indef, median=median, edge_truncate=edge_truncate
;+
; NAME: SMOOTH_SLICE
;
; PURPOSE: Smoothing (like IDL SMOOTH function) function that takes
;          into account edges and indef values. It can be applied
;          on 1D vector or 2D matrix.
;
; CALLING SEQUENCE:
;          result = smooth_slice(array_in, smooth_factor, indef=-32768)
;
; INPUTS:
;          array_in: input array (1D or 2D)
;          factor: smoothing window (integer or intarr(2))
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;          indef: indef value
;          median: use the median value instead of average
;          edge_truncate : use the edge_truncate keyword of smooth
;
; OUTPUTS:
;          result: smoothed array
;
; MODIFICATION HISTORY:
; 
;  - MAMD 19/11/1998
;  - MAMD October 7 2003; use the usual smooth function when there is
;    no undefined value
;  - MAMD November 24 2003: add edge_truncate

;-----------------------------------------------
; KEYWORDS

if not keyword_set(indef) then indef=-32768
if not keyword_set(edge_truncate) then edge_truncate = 0

;----------------------------------------------
; MAIN FUNCTION

ind = where(array_in eq indef, nbind)
if nbind eq 0 and not keyword_set(median) then begin
    result = smooth(array_in, factor, edge_truncate=edge_truncate)
endif else begin

; SIZE ARRAY
    si_arr = size(reform(array_in))
    result = array_in
;    stdevres = array_in

; VECTOR CASE
    if si_arr(0) eq 1 then begin
        dx = float(factor(0))/2.
        dx = fix(dx)
        for i=0L, si_arr(1)-1 do begin 
            ibegin = max([0,i-dx])
            iend = min([i+dx,si_arr(1)-1])
            svec = array_in(ibegin:iend)
            ind = where(svec ne indef, nbindef)
            if (nbindef gt 0) then begin
                if keyword_set(median) then result(i) = median(svec(ind)) $
                else result(i) = avg(svec(ind))
            endif
        endfor
    endif

; MATRIX CASE
    if si_arr(0) eq 2 then begin
        if n_elements(factor eq 1) then factor = [factor, factor]
        dx = float(factor(0))/2.
        dx = fix(dx)
        dy = float(factor(1))/2.
        dy = fix(dy)
        for j=0, si_arr(2)-1 do begin 
            for i=0, si_arr(1)-1 do begin 
                ibegin = max([0,i-dx])
                iend = min([i+dx,si_arr(1)-1])
                jbegin = max([0,j-dy])
                jend = min([j+dy,si_arr(2)-1])
                svec = array_in(ibegin:iend, jbegin:jend)
                ind = where(svec ne indef, nbindef)
                if (nbindef gt 0) then begin
                    if keyword_set(median) then result(i,j) = median(svec(ind)) $
                    else result(i,j) = avg(svec(ind))
                endif
            endfor
        endfor
    endif

endelse

return, result

end

