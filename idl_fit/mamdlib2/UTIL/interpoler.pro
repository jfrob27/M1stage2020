;--------------------------------------

pro xymap, xsize, ysize, xima, yima

xima = intarr(xsize, ysize)
yima = intarr(xsize, ysize)

for i=0, xsize-1 do xima(i,*)=i
for i=0, ysize-1 do yima(*,i)=i

end

;--------------------------------------


function interconvol, simage, posx, posy, indef, nb_point_min=nb_point_min, kernel=kernel, use_indef=use_indef

taille = size(simage)
if not keyword_set(nb_point_min) and taille(0) eq 2 then nb_point_min = 10
if not keyword_set(nb_point_min) and taille(0) eq 1 then nb_point_min = 5

nonnul = where(simage ne indef, nbnonnul)
if (N_ELEMENTS(nonnul) gt nb_point_min) then begin
    if not keyword_set(kernel) then A = 3 else A = kernel

    if (taille(1) eq 2) then begin
        x_mat = intarr(taille(1), taille(2))
        y_mat = intarr(taille(1), taille(2))
        x = indgen(taille(1))
        y = indgen(taille(2))
        for i=0, taille(2)-1 do	x_mat(*,i) =  x
        for i=0, taille(1)-1 do	y_mat(i,*) =  y
        distance = fltarr(taille(1),taille(2))
        distance = sqrt((x_mat-posx)^2 + (y_mat-posy)^2)
    endif else begin
        distance = findgen(taille(1)) -posx
    endelse

    gauss_map = exp(-(distance/A)^2/2.) 

    if keyword_set(use_indef) then begin
        value = total(simage*gauss_map)/total(gauss_map)
    endif else begin
        value = total(simage(nonnul)*gauss_map(nonnul))/total(gauss_map(nonnul))
    endelse
    
endif
if (N_ELEMENTS(nonnul) le nb_point_min) then value = indef

return, value

end

;--------------------------------------


function interpoler, imagein, $
                     indef=indef, $
                     dx=dx, $
                     dy=dy, $
                     nb_point_min=nb_point_min, $
                     median=median, $
                     mean=mean, $
                     kernel=kernel, $
                     use_indef=use_indef, $
                     mask=mask
;+
; NAME:
;   INTERPOLER
;
; PURPOSE:
;   interpolate undefined values in a vector or an image using a 
;   Gaussian weight function.
;
;  For all undefined values, the INTERPOLER function returns the
;  convolution of the neighbord points (in a window 2*dx+1 times 2*dy+1
;  centered on the undefined value) with a Gaussian function. The
;  width (sigma) of the Gaussian function is given by the keyword KERNEL.
;
; CALLING SEQUENCE:
;  result = interpoler(image, indef=indef, dx=dx, dy=dy, nb_point_min=nb_point_min, $
;                     median=median, kernel=kernel, $
;                     use_indef=use_indef
;
; INPUTS:
;   - IMAGE:  a 1D or 2D array
;
; KEYWORD PARAMETERS:
;  - INDEF: the value of the undefined value (default = -32768)
;  - DX (DY): X (Y) half size of the window centered on all undefined
;           values (default = 7).
;  - NB_POINT_MIN: Minimum number of points in the window for the
;                convolution to be computed (default = 10).
;  - KERNEL: Width of the Gaussian convolution function (default = 3).
;  - MEAN: Return the mean value of the points in the window instead of
;          doing the convolution.
;  - MEDIAN: Return the median value of the points in the window instead of
;          doing the convolution.
;
; OUTPUTS:
;  - RESULT: an array of the same size as the input array with the
;            interpolated values.
;
; MODIFICATION HISTORY:
;     mamd 24/07/2001  write header
;     mamd october 8 2003 add the possibility to use a mask
;-

taille = size(imagein)

;----------------------------
; KEYWORDS

if not keyword_set(indef) then indef=-32768.
if not keyword_set(kernel) then kernel=3
if not keyword_set(nb_point_min) and taille(0) eq 2 then nb_point_min = 10
if not keyword_set(nb_point_min) and taille(0) eq 1 then nb_point_min = 5
if not keyword_set(dx) then  dx = 7		; demi taille de la fenetre sur laquelle
if not keyword_set(dy) then  dy = 7		; sont calculees moyenne et variance locales
if not keyword_set(use_indef) then  use_indef=0

imageout = imagein
xymap, taille(1), taille(2), x_mat, y_mat

noindef = where(imagein ne indef, nb_noindef)
if (nb_noindef eq 0) then begin
    print, 'No defined value in input map'
    return, imagein
endif
xmin = min(x_mat(noindef))
xmax = max(x_mat(noindef))
ymin = min(y_mat(noindef))
ymax = max(y_mat(noindef))

if not keyword_set(mask) then begin
    indice = where(imagein eq indef, nbind)
endif else begin
    indice = where(mask eq 1, nbind)
endelse

if (nbind gt 0) then begin

for k=0l, N_ELEMENTS(indice)-1 do begin

  if (taille(0) eq 1) then begin
      i = indice(k)
      xxmin = 0 > (i-dx)
      xxmax = (taille(1)-1) < (i+dx)
      simage = imagein(xxmin:xxmax)
  endif else begin
      i = x_mat(indice(k))
      j = y_mat(indice(k))
      xxmin = 0 > (i-dx)
      xxmax = (taille(1)-1) < (i+dx)
      yymin = 0 > (j-dy)
      yymax = (taille(2)-1) < (j+dy)
      simage = imagein(xxmin:xxmax, yymin:yymax)
  endelse
  if keyword_set(median) then begin
      if keyword_set(use_indef) then begin
          imageout(indice(k)) = median(simage)
      endif else begin
          ind = where(simage ne indef, nbgood)
          if (nbgood gt 0) then imageout(indice(k)) = median(simage(ind))
      endelse
  endif 
  if keyword_set(mean) then begin
      if keyword_set(use_indef) then begin
          imageout(indice(k)) = avg(simage)
      endif else begin
          ind = where(simage ne indef, nbgood)
          if (nbgood gt 0) then imageout(indice(k)) = avg(simage(ind))
      endelse
  endif 
  IF NOT keyword_set(median) AND NOT keyword_set(mean) THEN begin
      posx = i-xxmin
      if (taille(0) eq 1) then posy=0 else posy = j-yymin
      imageout(indice(k)) = interconvol(simage,posx,posy,indef,nb_point_min=nb_point_min, kernel=kernel, $
                                        use_indef=use_indef) 
  endif
endfor

endif

return, imageout

end

