function median_edge, map, window_size
;+
; NAME:
;   MEDIAN_EDGE
;
; PURPOSE:
;   Compute the median filtering of an image by taking edge into account
;
; CALLING SEQUENCE:
;    result = median_edge(map, window_size)
;
; INPUTS:
;   map: image
;   window_size: the size of the median window
;
; OUTPUTS:
;   result: the image smooted using median statistics
; 
; EXAMPLE:
;    result = median_edge(map, 10)
;
; MODIFICATION HISTORY:
;    24/04/2002 - MAMD, creation
;-

dx = fix(window_size/2.)
size_map = size(map)
result = fltarr(size_map(1), size_map(2))
for j=0, size_map(2)-1 do begin
    y0 = (j-dx) > 0
    y1 = (j+dx) < (size_map(2)-1)
    for i=0, size_map(1)-1 do begin
        x0 = (i-dx) > 0
        x1 = (i+dx) < (size_map(1)-1)
        result(i,j) = median(map(x0:x1,y0:y1))
    endfor
endfor

return, result

end
