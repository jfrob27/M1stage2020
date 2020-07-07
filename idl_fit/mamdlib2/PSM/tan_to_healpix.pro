FUNCTION TAN_TO_HEALPIX, tan_map, tan_hdr, hpx_hdr, method=method, double=double, kernel=kernel

; implemented methods: 
;   'forward-binning' : average input pixel values in corresponding output pixels.
;                       default when the input map is more densely sampled than the output map
;                       (drawback: undefined values when less input pixels than output pixels in area)
;   'forward-trigrid' : compute x and y for input map pixels, and interpolate onto output grid using TRIGRID 
;                       (drawback: no binning, and hence output may be more noisy than necessary when no less output than input pixels in area)
;   'forward-kernel'  : average, on the output map, kernels centred on the images of the pixels of the input map.
;                       this permits to interpolate between pixel images to fill gaps (at the price of some extra smoothing) 
;                       the kernel can be user-specified (or obtained as output) using the 'kernel' keyword. It must be have odd dimensions.
;                       the default kernel is a cone, of base diameter the typical distance between pixels of the input map
;   'backward-reading': compute coordinates of output map pixels in healpix map coordinate system, and read pixel values
;                       (drawback: uses only one healpix pixel per output map pixel, independent of pixel sizes)
;                       default when the output map is more densely sampled than the input map


IF NOT KEYWORD_SET(double) THEN dtor=!dtor ELSE dtor = !dpi/180d0

nside = SXPAR(hpx_hdr,'NSIDE')
ordering = STRTRIM(SXPAR(hpx_hdr,'ORDERING'),2)
;fields = STRTRIM(SXPAR(hpx_hdr,'FIELDS')) ;not used yet

;find coordinate system of input healpix map
hpx_coordsys = STRTRIM(SXPAR(hpx_hdr,'COORDSYS',count=match_hpx),2)
IF match_hpx EQ 0 THEN BEGIN
   PRINT, "HEALPIX_TO_TAN: COORDINATE SYSTEM not found for HEALPIX MAP, assuming 'G'"
   hpx_coordsys = 'G'
ENDIF
hpx_epoch = SXPAR(hpx_hdr,'EPOCH',count=match_hpx)
IF match_hpx EQ 0 THEN BEGIN
   IF hpx_coordsys EQ 'C' THEN PRINT, 'HEALPIX_TO_TAN: EPOCH not found for HEALPIX MAP, assuming 2000.'
   hpx_epoch = 2000.
ENDIF

; compute maximum extent of gnomic map (useful for 'forward' methods)
naxis1 = SXPAR(tan_hdr,'NAXIS1')
naxis2 = SXPAR(tan_hdr,'NAXIS2')
crpix1 = SXPAR(tan_hdr,'CRPIX1')
crpix2 = SXPAR(tan_hdr,'CRPIX2')
xcorner = [0,0,naxis1-1,naxis1-1]
ycorner = [0,naxis2-1,0,naxis1-1]
XYAD, tan_hdr, xcorner, ycorner, acorner, dcorner
XYAD, tan_hdr, crpix1, crpix2, aref, dref
GCIRC, 0, acorner*dtor, dcorner*dtor, aref*dtor, dref*dtor, dis
maxdis = MAX(dis)

;if not set, define method from relative pixel sizes
IF NOT KEYWORD_SET(method) THEN BEGIN
   cdelt1 = SXPAR(tan_hdr,'CDELT1')
   cdelt2 = SXPAR(tan_hdr,'CDELT2')
   tan_pixarea = ABS(cdelt1*cdelt2)
   hpx_pixarea = (4*!dpi)/dtor/dtor/NSIDE2NPIX(nside)
   IF hpx_pixarea GT tan_pixarea THEN method = 'forward-binning' ELSE method = 'backward-reading'
ENDIF

;extract method keywords
meth_key = STRSPLIT(method,'-', /extract)

;find coordinate system of gnomic map
ctype1 = SXPAR(tan_hdr,'CTYPE1')
first4 = STRMID(ctype1,0,4)
tan_epoch = SXPAR(tan_hdr,'EPOCH',count=match_tan)
IF match_tan EQ 0 THEN BEGIN
   PRINT, 'HEALPIX_TO_TAN: EPOCH not found for GNOMIC MAP, assuming 2000.'
   tan_epoch = 2000.
ENDIF

;rotate [aref,dref] onto coord system of healpix map if needed
IF first4 EQ 'RA--' THEN tan_coordsys = 'C'
IF first4 EQ 'ELON' THEN tan_coordsys = 'E'
IF first4 EQ 'GLON' THEN tan_coordsys = 'G'

CHANGE_COORDSYS, aref, dref, nlon, nlat, coordsys_in=tan_coordsys, coordsys_out=hpx_coordsys, epoch_in=tan_epoch, epoch_out=hpx_epoch
aref=nlon & dref=nlat

;compute x, y and z for reference point (useful for 'forward' methods)
xref = ((COS(aref*dtor)*COS(dref*dtor)) < 1) >(-1)
yref = ((SIN(aref*dtor)*COS(dref*dtor)) < 1) >(-1)
zref = ((SIN(dref*dtor)) < 1) >(-1)
vref = [xref,yref,zref]

CASE meth_key[0] OF
   ;=======================================================================================
   'forward':BEGIN
      ;get coordinates of all pixels in the gnomic map
      IF KEYWORD_SET(double) NE 0 THEN BEGIN
         x = DINDGEN(naxis1)#REPLICATE(1D0,naxis2)
         y = REPLICATE(1D0,naxis1)#DINDGEN(naxis2)
      ENDIF ELSE BEGIN
         x = FINDGEN(naxis1)#REPLICATE(1.,naxis2)
         y = REPLICATE(1.,naxis1)#FINDGEN(naxis2)
      ENDELSE
      npix_in = N_ELEMENTS(x)
      x = REFORM(TEMPORARY(x),npix_in)
      y = REFORM(TEMPORARY(y),npix_in)
      XYAD, tan_hdr, x, y, a, d

      ;precess and rotate coordinates if needed
      cc = hpx_coordsys+tan_coordsys

      needed = (hpx_coordsys NE tan_coordsys) OR ((cc EQ'CC') AND (hpx_epoch NE tan_epoch))
      IF needed THEN BEGIN
         CHANGE_COORDSYS, a, d, lon, lat, $
                          coordsys_in=tan_coordsys, coordsys_out=hpx_coordsys, epoch_in=tan_epoch, epoch_out=hpx_epoch
      ENDIF ELSE BEGIN
         lon=TEMPORARY(a)
         lat=TEMPORARY(d)
      ENDELSE
      theta = (90.-lat)*dtor
      phi = lon*dtor

      IF ordering EQ 'RING' THEN ANG2PIX_RING, nside, theta, phi, opix
      IF ordering EQ 'NEST' THEN ANG2PIX_NEST, nside, theta, phi, opix

      ;-------------------------------------------------------------------------------------
      CASE meth_key[1] OF

         ;simple binning--------------------------------------------------------------------
         'binning': BEGIN   
            
            blankvalue = SXPAR(hpx_hdr,'BLANK', count=defined_blank)
            IF defined_blank EQ 0 THEN BEGIN
               blankvalue = !healpix.bad_value
               SXADDPAR, tan_hdr, 'BLANK', blankvalue
            ENDIF

            nel=npix_in
            hpx_pix=opix(UNIQ(opix,SORT(opix)))
            npix_out = N_ELEMENTS(hpx_pix)
            mapout = REPLICATE(blankvalue*1D0,nside2npix(nside))
            mapout[opix]=0D
            count = LONARR(npix_out)

            ;bin input data into healpix map pixels
            FOR i=0L,nel-1 DO BEGIN
               mapout(opix(i)) = tan_map(x(i),y(i)) + mapout(opix(i))
               ind = WHERE(hpx_pix EQ opix(i),nwh)
               count(ind[0]) = count(ind[0]) + 1L
            ENDFOR

            whn0 = WHERE(count NE 0,nwh)
            IF nwh NE 0 THEN mapout(hpx_pix(whn0)) = mapout(hpx_pix(whn0))/count(whn0)
            ;wh0 = WHERE(count EQ 0,nwh)
            ;IF nwh NE 0 THEN mapout(wh0) = blankvalue
         END

 
     
      ENDCASE
   END
   ;===========================================================================================
   'backward': BEGIN
      ;compute lon and lat for all pixels close to the map
      IF STRTRIM(STRUPCASE(ordering),2) EQ 'NEST' THEN BEGIN
         QUERY_DISC, nside, vref, 1.1*maxdis, pix, /nest
         PIX2ANG_NEST, nside, pix, lat, lon
      ENDIF
      IF STRTRIM(STRUPCASE(ordering),2) EQ 'RING' THEN BEGIN
         QUERY_DISC, nside, vref, 1.1*maxdis, pix
         PIX2ANG_RING, nside, pix, lat, lon
      ENDIF
      lon = TEMPORARY(lon)/dtor
      lat = 90. - TEMPORARY(lat)/dtor

      ;precess and rotate coordinates if needed
      cc = hpx_coordsys+tan_coordsys
      needed = (hpx_coordsys NE tan_coordsys) OR ((cc EQ'CC') AND (hpx_epoch NE tan_epoch))
      IF needed THEN BEGIN
         CHANGE_COORDSYS, lon, lat, newlon, newlat, $
                          coordsys_in=hpx_coordsys, coordsys_out=tan_coordsys, epoch_in=hpx_epoch, epoch_out=tan_epoch
         lon = newlon & lat = newlat
         newlon = 0 & newlat = 0
      ENDIF

      ;compute x and y using adxy
      ADXY, tan_hdr, lon, lat, x, y



            x = ROUND(x) & y=ROUND(y)
            
            blankvalue = SXPAR(hpx_hdr,'BLANK', count=defined_blank)
            IF defined_blank EQ 0 THEN BEGIN
               blankvalue = !healpix.bad_value
               SXADDPAR, hpx_hdr, 'BLANK', blankvalue
            ENDIF

            mapout = REPLICATE(blankvalue,nside2npix(nside))

            ;restrict range of output data
            restrict = WHERE((x GE 0) AND (x LE naxis1-1) AND (y GE 0) AND (y LE naxis2-1))
            x=x(restrict)
            y=y(restrict)
            pix=pix(restrict)
            nel = N_ELEMENTS(pix)

            ;bin input data into healpix map pixels
            FOR i=0L,nel-1 DO BEGIN
               mapout(pix(i)) = tan_map(x(i),y(i))
            ENDFOR
   END

ENDCASE

RETURN, mapout
END
