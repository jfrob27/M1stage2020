function overlay, ra, dec, color=color, angle=angle, sizesym=sizesym, $
                  thick=thick, fill=fill, connect=connect, type=type, $
                  label_text=label_text, label_color=label_color, $
                  label_size=label_size

n_values = n_elements(ra)
if not keyword_set(type) then type='circle'
if not keyword_set(sizesym) then sizesym = 0.
if not keyword_set(color) then color = 255
if not keyword_set(angle) then angle= 0.
if not keyword_set(thick) then thick=1.
if not keyword_set(fill) then fill=0
if not keyword_set(label_text) then label_text=''
if not keyword_set(label_size) then label_size=1
if not keyword_set(label_color) then label_color=0

if n_elements(sizesym) ne n_values then sym_size= replicate(float(sizesym(0)), n_values) else sym_size=sizesym
if n_elements(type) ne n_values then sym_type= replicate(string(type(0)), n_values) else sym_type=type
if n_elements(color) ne n_values then sym_color= replicate( color(0), n_values) else sym_color = color
if n_elements(thick) ne n_values then sym_thick= replicate(float(thick(0)), n_values) else sym_thick=thick
if n_elements(angle) ne n_values then sym_angle= replicate(float(angle(0)), n_values) else sym_angle=angle
if n_elements(fill) ne n_values then sym_fill= replicate(nint(fill(0)), n_values) else sym_fill=fill
if n_elements(label_text) ne n_values then label_text = replicate(label_text(0), n_values)
if n_elements(label_size) ne n_values then label_size = replicate(label_size(0), n_values)
if n_elements(label_color) ne n_values then label_color = replicate(label_color(0), n_values)

overlay_struct = create_struct('coo1', ra)
overlay_struct = create_struct(overlay_struct, 'coo2', dec)
overlay_struct = create_struct(overlay_struct, 'sym_type', sym_type)
overlay_struct = create_struct(overlay_struct, 'sym_size', sym_size)
overlay_struct = create_struct(overlay_struct, 'sym_color', sym_color)
overlay_struct = create_struct(overlay_struct, 'sym_thick', sym_thick)
overlay_struct = create_struct(overlay_struct, 'sym_angle', sym_angle)
overlay_struct = create_struct(overlay_struct, 'sym_fill', sym_fill)
overlay_struct = create_struct(overlay_struct, 'sym_double', replicate(0, n_values))
overlay_struct = create_struct(overlay_struct, 'label', label_text)
overlay_struct = create_struct(overlay_struct, 'label_size', label_size)
overlay_struct = create_struct(overlay_struct, 'label_color', label_color)
overlay_struct = create_struct(overlay_struct, 'label_thick', replicate(1, n_values))
overlay_struct = create_struct(overlay_struct, 'label_angle', replicate(0., n_values))

overlay_out = create_struct('set0', overlay_struct)

return, overlay_out

end
