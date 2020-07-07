function mcol, input_name

nbcol = n_elements(input_name)
result = intarr(nbcol)
restore, !MAMDLIB_DIR+'/DISPLAY/mamd_col_table.idl'
tvlct, r, g, b

for i=0, nbcol-1 do begin
; Checks if input name corresponds to a colorname in the list
; and return its index. If not, it returns 0
;
   ind = where( colorname eq input_name[i], nbind )
   if nbind ne 0 then begin
      result[i] = ind(0) 
   endif else begin
      print, "Unknown color name; "+input_name[i]+". Return BLACK"
      result[i] = 0
   endelse
endfor
      
return, result

end
