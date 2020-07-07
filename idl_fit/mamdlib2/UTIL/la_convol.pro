function la_convol, image, kernel, indef=indef, _Extra=extra

;-----------------------------------------------------------------
; Function that does a convolution of an image by a kernel, 
; taking into account undefined values.
;
; If no undefined values are present, the usual IDL CONVOL
; function is used.
;
; MAMD 21/11/2002
; MAMD 25/11/2003 ; compute the convolution only for pixels with
; defined values. Make sure that undefined values in the original
;    maps are still undefined in the result
;-----------------------------------------------------------------

;------- PARAMETER CHECK-----------------------
si_image = size(image)
si_kernel = size(kernel)
if (si_image(0) ne 2 or si_kernel(0) ne 2) then begin
    print, 'LA_CONVOL: image and kernel must be 2D'
    return, -1
endif
if ( si_image(1) le si_kernel(1) ) or ( si_image(2) le si_kernel(2) ) then begin
    print, 'LA_CONVOL: image must be of greater size than kernel'
    return, -1
endif
;---------------------------------------------------


; Check if there are undefined values
if not keyword_set(indef) then indef=-32768.
ind_indef = where(image eq indef, nbind_indef)

if (nbind_indef eq 0) then begin
    ; if all values are defines, use the IDL CONVOL function
    result = convol( image, kernel, _Extra=extra )
endif else begin

    result  = fltarr( si_image(1), si_image(2) )
    result(*) = indef

    ; make sure the kernel has an odd number of pixel in each direction
    if si_kernel(1) mod 2 eq 0 then sikx = si_kernel(1)+1 else sikx=si_kernel(1)
    if si_kernel(2) mod 2 eq 0 then siky = si_kernel(2)+1 else siky=si_kernel(1)
    kernel_use = congrid( kernel, sikx, siky )
    norm_kernel = total( kernel_use )
    dx = (sikx-1.)/2
    dy = (siky-1.)/2
    for j=0, si_image(2)-1 do begin
       print, j, si_image(2)-1
        j1 = ( j-dy ) > 0.
        j2 = ( j+dy ) < (si_image(2)-1)
        jk1 = dy - (j - j1)
        jk2 = dy + (j2 - j)
        for i=0, si_image(1)-1 do begin 
            if (image(i,j) ne indef) then begin
                i1 = ( i-dx ) > 0.
                i2 = ( i+dx ) < (si_image(1)-1)
                ik1 = dx - (i - i1)
                ik2 = dx + (i2 - i)
                simage = image( i1:i2, j1:j2 )
                skernel = kernel_use( ik1:ik2, jk1:jk2 ) 
                ind = where( simage ne indef, nbind )
                surface_factor = total( skernel(ind) ) / norm_kernel
                result( i, j ) = total( simage(ind) * skernel(ind) ) / surface_factor 
            endif
        endfor
    endfor
endelse

return, result

end    
