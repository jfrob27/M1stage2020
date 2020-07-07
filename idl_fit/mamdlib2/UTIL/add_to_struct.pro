pro add_to_struct, struct_in, param_name, param_value

;----------------------------------------------------------
; Add the field (param_name) of value (param_value) 
; to a structure (struct_in).
;
; The structure is created if empty
;
; MAMD 19/09/2001
;-------------------------------------------------------

value_use = param_value

if keyword_set(struct_in) then begin
    tnames = tag_names(struct_in)
    ind_tnames = where(strcmp(tnames, param_name, /fold_case) eq 1, nbind)
; if the Field exists already, append the value to it
    if (nbind gt 0) then begin
        tempo = [ struct_in.(ind_tnames(0)) ]
        tempo = reform( tempo, n_elements(tempo) )
        value_use = [ tempo, param_value  ]
        nb = 1.*n_elements(param_value)
        if (nb gt 1.) then value_use = reform( value_use, nb, n_elements(value_use)/nb )
        rm_from_struct, struct_in, param_name
    endif 
endif

if n_tags(struct_in) gt 0 then $
  struct_in = create_struct(struct_in, param_name, value_use) else $
  struct_in = create_struct(param_name, value_use)

end

        
    

