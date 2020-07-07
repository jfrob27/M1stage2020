pro rm_from_struct, struct_in, param_name, param_value

;----------------------------------------------------------
; Extract the value (param_value) of a field (param_name) 
; in a structure (struct_in)
;
; The structure is returned with the corresponding field removed
;
; MAMD 19/09/2001
;-------------------------------------------------------

key_names = tag_names(struct_in)

; Find the value of the given parameter
ind= where(strcmp(key_names, param_name, /fold_case) eq 1, nbind)
if (nbind gt 0) then param_value = struct_in.(ind(0)) else param_value = ''

; Remove the corresponding field in the structure
ind2= where(strcmp(key_names, param_name, /fold_case) eq 0, nbind2)
if (nbind2 gt 0) then begin
    for i=0, nbind2-1 do begin
        if (i eq 0) then struct_out = create_struct(key_names(ind2(i)), struct_in.(ind2(i))) else $
          struct_out = create_struct(struct_out, key_names(ind2(i)), struct_in.(ind2(i)))
    endfor
    struct_in = struct_out
endif else struct_in = ''

sortie:

end

