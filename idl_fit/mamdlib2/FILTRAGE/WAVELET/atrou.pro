
function atrou, data, nscale, silent=silent, last=last
;+
; NAME:  ATROU
;
; PURPOSE:
;
; Compute the "a trou" wavelet transform of an image.
; The result is a cube with each plane has the same dimension
; as the original image.
;
; CALLING SEQUENCE: result = atrou(map, nscale)
;
; INPUTS:
;  map: 2D array
;  nscale: number of scales
;
; OUTPUTS:
;  a cube with a scale by plane
;
; SIDE EFFECTS: none
;
; RESTRICTIONS: does not work on complex array
;
; MODIFICATION HISTORY:
; mamd 24/4/2001
;
;-

if not keyword_set(nscale) then nscale = 3
if keyword_set(last) then sres = nscale+1 else sres=nscale

sid = size(data)
case sid[0] of
    1: begin
        kernel_val = [1./16, 1./4., 3./8., 1./4., 1./16.]
        result = fltarr(sid(1), sres)
        tempo = data
        for i=0, nscale-1 do begin 
            if not keyword_set(silent) then print, i
            n = fix(4*(2^i)+1) 
            kernel = fltarr(n) 
            indice = indgen(5)*2^i
            kernel(indice) = kernel_val
            tsmooth = convol(tempo, kernel, /edge_truncate)  
            result(*,i) = tempo - tsmooth  
            tempo = tsmooth  
        endfor
        if keyword_set(last) then begin
            if (nscale gt 1) then result(*,nscale) = data-total(result(*,0:nscale-1),2) $
            else result(*,nscale) = data-result(*,0)
        endif
    end
    2: begin
        kernel_val = [1./16, 1./8., 1./16., 1./8., 1./4., 1./8., 1./16., 1./8, 1./16]
        result = dblarr(sid(1), sid(2), sres)
        tempo = data
        for i=0, nscale-1 do begin 
            if not keyword_set(silent) then print, i
            n = fix(2*(2^i)+1) 
            kernel = fltarr(n, n) 
            dx = (n-1)/2. 
            lc = (n^2-n)/2. 
            indice = [0, dx, 2*dx, lc, lc+dx, lc+2*dx, 2*lc, 2*lc+dx, 2*(lc+dx)] 
            kernel(indice) = kernel_val 
            tsmooth = convol(tempo, kernel, /edge_truncate)  
            result(*,*,i) = tempo - tsmooth  
            tempo = tsmooth  
        endfor
        if keyword_set(last) then begin
            if (nscale gt 1) then result(*,*,nscale) = data-total(result(*,*,0:nscale-1),3) $
            else result(*,*,nscale) = data-result(*,*,0)
        endif
    end
    else: begin
        print, 'Input data must be 1D or 2D'
        result = -1
    end
endcase

return, result

end
