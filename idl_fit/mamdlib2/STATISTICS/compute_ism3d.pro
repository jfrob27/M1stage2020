function compute_ISM3d, exponent, nx, ny, nz, phase=phase, amplitude=amplitude, $
                      powspec=powspec, kvec=kvec, normal=normal, seuil=seuil

   if not keyword_set(normal) then begin
      normal = fltarr(n_elements(exponent))
      normal(*)= 1.
   endif
   if not keyword_set(seuil) then begin
      seuil = fltarr(n_elements(exponent))
      seuil(*)= -32768.
   endif

   if keyword_set(amplitude) then begin
      simap = size(amplitude)
      nx = simap(1)
      ny = simap(1)
   endif
   if keyword_set(phase) then begin
      simap = size(phase)
      nx = simap(1)
      ny = simap(1)
   endif
   if not keyword_set(phase) then begin
      phase = randomu(seed, nx, ny, nz)*2*!pi-!pi
   endif 

   if not keyword_set(amplitude) then begin
      if keyword_set(kvec) and keyword_set(powspec) then begin
         xymap, nx, ny, xmap, ymap
         xmap = xmap-nx/2.
         ymap = ymap-ny/2.
         k_map = sqrt(xmap^2/(1.d*nx)^2 + ymap^2/(1.d*ny)^2)
         amplitude = interpol(1.d*powspec, kvec, k_map(*)) 
         amplitude = reform(amplitude, nx, ny)
         amplitude = sqrt(amplitude>0.)
         amplitude = shift(amplitude,  nx/2., ny/2.)  
         image = compute_cloud(amplitude, phase)
      endif else begin
         IF (n_elements(exponent) GT 1) THEN BEGIN
            image = fltarr(nx, ny)
            for ii=0, n_elements(exponent)-1 do begin 
               amplitude = (shift(dist(nx, ny), nx/2., ny/2.)/(nx/2.))^(exponent(ii)/2.)
               amplitude(nx/2.,ny/2.) = 1.
               amplitude = shift(amplitude,  nx/2., ny/2.)  
               image0 = compute_cloud(amplitude, phase)*normal(ii)
               if seuil(ii) ne -32768 then image0 = image0>seuil(ii)
               image = image+image0
            ENDFOR
         ENDIF ELSE BEGIN
             amplitude = build_kcube(nx, ny, nz)
             amplitude = amplitude^(exponent(0)/2.)
;            amplitude =  fltarr(nx,ny,nz)
;            FOR k=0., nz-1 DO BEGIN 
;               FOR j=0., ny-1 DO BEGIN 
;                  FOR i=0., nx-1 DO BEGIN 
;                     value =  (sqrt((i-nx/2.)^2+(j-ny/2.)^2+(k-nz/2.)^2))^((exponent(0))/2.)
;                     amplitude(i,j,k) =  value
;                  ENDFOR
;               ENDFOR
;            ENDFOR
;stop
            amplitude(nx/2.,ny/2.,nz/2.) = 1.
;            amplitude = amplitude/amplitude(0., ny/2., nz/2.)
            amplitude = shift(amplitude,  nx/2., ny/2., nz/2.)  

               image = compute_cloud(amplitude, phase)*normal(0)
               if seuil(0) ne -32768 then image = image>seuil(0)
         endelse
      endelse
   endif else image = compute_cloud(amplitude, phase)


   return, image

end
