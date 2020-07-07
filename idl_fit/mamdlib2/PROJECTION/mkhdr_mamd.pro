function mkhdr_mamd, image, _Extra=extra

mkhdr, header, image

if keyword_set( extra ) then begin
    fieldname = tag_names( extra )
    for i=0, n_tags( extra )-1 do sxaddpar, header, fieldname( i ), extra.( i )
endif

return, header

end
