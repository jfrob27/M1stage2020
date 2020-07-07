function map_properties, freq, dataversion=dataversion, _Extra=extra

if not keyword_set(dataversion) then dataversion='DX9'  ; DX9 is default

freq_planck = [100, 143, 217, 353, 545, 857]
ind_planck_freq = where(freq_planck eq freq)
if (ind_planck_freq ne -1) then begin
   case dataversion of
      'DX9': str = map_properties_DX9(freq, _Extra=extra)
      'DX11': str = map_properties_DX11(freq, _Extra=extra)
      'DX11c': str = map_properties_DX11(freq, _Extra=extra)
      else : str = -1
   endcase
endif else begin
   str = map_properties_iras_dirbe(freq, _Extra=extra)
endelse

return, str

end

