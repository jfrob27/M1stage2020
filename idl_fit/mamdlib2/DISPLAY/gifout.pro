pro gifout, filename, image, imrange=imrange

common mamdvar
ntab = num_table

if not keyword_set(image) then begin
    image_out = bytscl(tvrd())
    set_plot, 'ps' 
    loadct, ntab
    tvlct, r, g, b, /get  
    WRITE_GIF, filename, image_out, r, g, b
    set_plot, 'x'
endif else begin
    if not keyword_set(imrange) then imrange=[min(image), max(image)]
    si_image = size(image)
    if (si_image(0) eq 3) then begin
        for i=0, si_image(3)-2 do begin
            image_out = bytscl(image(*,*,i), min=imrange(0), max=imrange(1))
            set_plot, 'ps' 
            loadct, ntab
            tvlct, r, g, b, /get  
            WRITE_GIF, filename, image_out, r, g, b, /multi
            set_plot, 'x' 
        endfor
        image_out = bytscl(image(*,*,si_image(3)-1), min=imrange(0), max=imrange(1))
        set_plot, 'ps' 
        loadct, ntab
        tvlct, r, g, b, /get  
        WRITE_GIF, filename, image_out, image_out, r, g, b, /multi, /close
        set_plot, 'x' 
    endif else begin
        image_out = bytscl(image, min=imrange(0), max=imrange(1))
        set_plot, 'ps' 
        loadct, ntab
        tvlct, r, g, b, /get  
        WRITE_GIF, filename, image_out, r, g, b
        set_plot, 'x' 
    endelse
endelse


end
