PRO CHANGE_COORDSYS, loni, lati, lono, lato, $
                     coordsys_in = coordsys_in, coordsys_out = coordsys_out, epoch_in = epoch_in, epoch_out = epoch_out

; wrapper to precess and euler
; loni, lati: input longitude and latitude in degrees
; lono, lat: output longitude and latitude in degrees
; coordsys_in and coordsys_out: can be 'C' or 'E', or 'G' (default value 'G')
; epoch_in and epoch_out: floating point value of equinox (default 2000.)

IF NOT KEYWORD_SET(coordsys_in) THEN coordsys_in='G'
IF NOT KEYWORD_SET(coordsys_out) THEN coordsys_out='G'
IF NOT KEYWORD_SET(epoch_in) THEN epoch_in=2000.
IF NOT KEYWORD_SET(epoch_out) THEN epoch_out=2000.

codecase = STRUPCASE(STRTRIM(coordsys_in,2)+STRTRIM(coordsys_out,2))

CASE STRTRIM(codecase,2) OF 
'GG': BEGIN
   lono=loni
   lato=lati
END
'EE': BEGIN
   lono=loni
   lato=lati
END
'CC': BEGIN
   IF epoch_in EQ epoch_out THEN BEGIN
      lono=loni
      lato=lati
   ENDIF ELSE BEGIN
      lono=loni
      lato=lati
      PRECESS, lono, lato, epoch_in, epoch_out
   ENDELSE
END
'CG': BEGIN
   IF epoch_in EQ 2000. THEN EULER, loni, lati, lono, lato, 1
   IF epoch_in EQ 1950. THEN EULER, loni, lati, lono, lato, 1, /FK4
   IF (epoch_in NE 2000.) AND (epoch_in NE 1950.) THEN BEGIN
      lon=loni
      lat=lati
      PRECESS, lon, lat, epoch_in, 2000.
      EULER, lon, lat, lono, lato, 1
   ENDIF
END
'GC': BEGIN
   IF epoch_out EQ 2000. THEN EULER, loni, lati, lono, lato, 2
   IF epoch_out EQ 1950. THEN EULER, loni, lati, lono, lato, 2, /FK4
   IF (epoch_out NE 2000.) AND (epoch_out NE 1950.) THEN BEGIN
      EULER, loni, lati, lono, lato, 2
      PRECESS, lono, lato, 2000., epoch_out
   ENDIF
END
'CE': BEGIN
   IF epoch_in EQ 2000. THEN EULER, loni, lati, lono, lato, 3
   IF epoch_in EQ 1950. THEN EULER, loni, lati, lono, lato, 3, /FK4
   IF (epoch_in NE 2000.) AND (epoch_in NE 1950.) THEN BEGIN
      lon=loni
      lat=lati
      PRECESS, lon, lat, epoch_in, 2000.
      EULER, lon, lat, lono, lato, 3
   ENDIF
END
'EC': BEGIN
   IF epoch_out EQ 2000. THEN EULER, loni, lati, lono, lato, 4
   IF epoch_out EQ 1950. THEN EULER, loni, lati, lono, lato, 4, /FK4
   IF (epoch_out NE 2000.) AND (epoch_out NE 1950.) THEN BEGIN
      EULER, loni, lati, lono, lato, 4
      PRECESS, lono, lato, 2000., epoch_out
   ENDIF
END
'EG': EULER, loni, lati, lono, lato, 5
'GE': EULER, loni, lati, lono, lato, 6

ENDCASE
   

END
