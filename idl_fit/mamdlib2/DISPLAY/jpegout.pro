pro jpegout, filename, image, r, g, b, imrange=imrange

if not keyword_set(image) then image = bytscl(tvrd())

si_image = size(image)
image_out = bytarr(si_image(1), si_image(2), 3)

if (si_image(0) ne 3) then begin
    if not keyword_set(r) then tvlct, r, g, b, /get  
    color = [[r], [g], [b]]
    if not keyword_set(imrange) then range=[min(image), max(image)] else range=imrange
    tempo = bytscl(image, min=range(0), max=range(1))
    tempo = reform(tempo, n_elements(tempo))
    for i=0, 2 do begin
        col_i = color(*,i)
        image_out(*,*,i) = bytscl(reform(col_i(tempo), si_image(1), si_image(2)))
    endfor
endif else begin
    for i=0, 2 do begin
        if not keyword_set(imrange) then range=[min(image(*,*,i)), max(image(*,*,i))] else range=imrange
        image_out(*,*,i) = bytscl(image(*,*,i), min=range(0), max=range(1))
    endfor
endelse


WRITE_JPEG, filename, image_out, QUALITY=100, TRUE=3
    

end
