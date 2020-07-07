function dsmooth, map0, scale, indef=indef

   if not keyword_set(scale) then scale = 4

   si_map = size(map0)
   map1=map0
   mapcube = fltarr(si_map(1),si_map(2),scale+1)

   IF keyword_set(indef) THEN BEGIN
      for i=0, scale-1 do begin 
         mapi = la_sub(map1,smooth_slice(map1, 2^(i+1)+1) )
         mapcube(*,*,i) = mapi 
         map1 = la_sub(map1,mapi)
      ENDFOR
   ENDIF ELSE begin
      for i=0, scale-1 do begin 
         mapi = map1 - smooth(map1, 2^(i+1)+1, /edge) 
         mapcube(*,*,i) = mapi 
         map1 = map1-mapi
      ENDFOR
   endelse
   mapcube(*,*,scale) = map1

   return, mapcube

end
