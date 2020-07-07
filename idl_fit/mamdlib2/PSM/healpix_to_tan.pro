FUNCTION HEALPIX_TO_TAN, hpx_map, hpx_hdr, tan_hdr, method=method, double=double, kernel=kernel

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
fields = STRTRIM(SXPAR(hpx_hdr,'FIELDS')) ;not used yet

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
   IF tan_pixarea GT hpx_pixarea THEN method = 'forward-binning' ELSE method = 'backward-reading'
ENDIF

;extract method keywords
meth_key = STRSPLIT(method,'-', /extract)

;find coordinate system of gnomic map
ctype1 = SXPAR(tan_hdr,'CTYPE1')
first4 = STRMID(ctype1,0,4)
tan_epoch = SXPAR(tan_hdr,'EPOCH',count=match_tan)

;rotate [aref,dref] onto coord system of healpix map if needed
IF first4 EQ 'RA--' THEN tan_coordsys = 'C'
IF first4 EQ 'ELON' THEN tan_coordsys = 'E'
IF first4 EQ 'GLON' THEN tan_coordsys = 'G'

IF match_tan EQ 0 THEN BEGIN
   IF tan_coordsys EQ 'C' THEN PRINT, 'HEALPIX_TO_TAN: EPOCH not found for GNOMIC MAP, assuming 2000.'
   tan_epoch = 2000.
ENDIF

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

      ;-------------------------------------------------------------------------------------
      CASE meth_key[1] OF

         ;simple binning--------------------------------------------------------------------
         'binning': BEGIN   
            x = ROUND(x) & y=ROUND(y)
            
            blankvalue = SXPAR(tan_hdr,'BLANK', count=defined_blank)
            IF defined_blank EQ 0 THEN BEGIN
               blankvalue = -32768
               SXADDPAR, tan_hdr, 'BLANK', blankvalue
            ENDIF

            value_0 = 0*hpx_map(0)
            mapout = REPLICATE(value_0,naxis1,naxis2)
            count = LONARR(naxis1,naxis2)

            ;restrict range of input data
            restrict = WHERE((x GE 0) AND (x LE naxis1-1) AND (y GE 0) AND (y LE naxis2-1))
            x=x(restrict)
            y=y(restrict)
            pix=pix(restrict)
            nel = N_ELEMENTS(pix)

            ;bin input data into gnomic map pixels
            FOR i=0L,nel-1 DO BEGIN
               mapout(x(i),y(i)) = mapout(x(i),y(i)) + hpx_map(pix(i))
               count(x(i),y(i)) = count(x(i),y(i)) + 1L
            ENDFOR

            whn0 = WHERE(count NE 0,nwh)
            IF nwh NE 0 THEN mapout(whn0) = mapout(whn0)/count(whn0)
            wh0 = WHERE(count EQ 0,nwh)
            IF nwh NE 0 THEN mapout(wh0) = blankvalue
         END

         ;kernel averaging (for interpolation)-----------------------------------------------
         'kernel': BEGIN
            x = ROUND(x) & y=ROUND(y)

            blankvalue = SXPAR(tan_hdr,'BLANK', count=defined_blank)
            IF defined_blank EQ 0 THEN BEGIN
               blankvalue = -32768
               SXADDPAR, tan_hdr, 'BLANK', blankvalue
            ENDIF

            ;get the kernel
            IF defined(kernel) EQ 0 THEN BEGIN
               cdelt1 = SXPAR(tan_hdr, 'CDELT1')
               cdelt2 = SXPAR(tan_hdr, 'CDELT2')
               zone_map = WHERE((x GE 0) AND (x LE naxis1-1) AND (y GE 0) AND (y LE naxis2-1),nwh)
               area = ABS(naxis1*cdelt1) * ABS(naxis2*cdelt2)
               dist_betw_pix = SQRT(area/nwh)
               nxkern = 2*FIX(ABS(dist_betw_pix/cdelt1))+1
               nykern = 2*FIX(ABS(dist_betw_pix/cdelt2))+1
               kernel = FLTARR(nxkern,nykern)
               xc = nxkern/2
               yc = nykern/2
               xkern = (FINDGEN(nxkern)) # REPLICATE(1.,nykern)
               ykern = (REPLICATE(1.,nxkern)) # (FINDGEN(nykern))
               dx = ABS(xkern - xc) 
               dy = ABS(ykern - yc) 
               distance = SQRT((dx*cdelt1)^2 + (dy*cdelt2)^2)
               kernel = (1 - distance/dist_betw_pix) > 0
            ENDIF ELSE BEGIN
               nxkern = N_ELEMENTS(kernel[*,0])
               nykern = N_ELEMENTS(kernel[0,*])
               xc = nxkern/2
               yc = nykern/2
            ENDELSE

            ;restrict range of input data
            restrict = WHERE((x GE -xc) AND (x LE naxis1-1+xc) AND (y GE -yc) AND (y LE naxis2-1+yc))
            x=x(restrict)
            y=y(restrict)
            pix=pix(restrict)
            nel = N_ELEMENTS(pix)

            ;define a larger map for easy and accurate kernel "convolution"
            value_0 = 0*hpx_map(0)
            mapout = REPLICATE(value_0,naxis1+2*nxkern,naxis2+2*nykern)
            count = FLOAT(mapout)

            ;bin input data into gnomic map pixels
            x=x+xc
            y=y+yc
            FOR i=0L,nel-1 DO BEGIN
               mapout(x(i):x(i)+nxkern-1,y(i):y(i)+nykern-1) = mapout(x(i):x(i)+nxkern-1,y(i):y(i)+nykern-1) + hpx_map(pix(i))*kernel
               count(x(i):x(i)+nxkern-1,y(i):y(i)+nykern-1) = count(x(i):x(i)+nxkern-1,y(i):y(i)+nykern-1) + kernel
            ENDFOR

            whn0 = WHERE(count NE 0,nwh)
            IF nwh NE 0 THEN mapout(whn0) = mapout(whn0)/count(whn0)
            wh0 = WHERE(count EQ 0,nwh)
            IF nwh NE 0 THEN mapout(wh0) = blankvalue

            mapout = mapout[2*xc:2*xc+naxis1-1,2*xc:2*xc+naxis2-1]

         END

         ;interpolation using TRIGRID---------------------------------------------------------
         'trigrid': BEGIN

            ;restrict range of input data
            restrict = WHERE((x GE -5) AND (x LE naxis1+4) AND (y GE -5) AND (y LE naxis2+4))
            x=x(restrict)
            y=y(restrict)
            pix=pix(restrict)
            nel = N_ELEMENTS(pix)

            TRIANGULATE, x, y, triangles;, TOLERANCE=1.e-20*max([x,y])
            mapout = TRIGRID(x,y,hpx_map(pix),triangles,[1.,1.],[0.,0.,naxis1-1,naxis2-1], /quintic)
         END   
     
      ENDCASE
   END
   ;===========================================================================================
   'backward': BEGIN
      ;get coordinates of all pixels in the gnomic map
      IF KEYWORD_SET(double) NE 0 THEN BEGIN
         x = DINDGEN(naxis1)#REPLICATE(1D0,naxis2)
         y = REPLICATE(1D0,naxis1)#DINDGEN(naxis2)
      ENDIF ELSE BEGIN
         x = FINDGEN(naxis1)#REPLICATE(1.,naxis2)
         y = REPLICATE(1.,naxis1)#FINDGEN(naxis2)
      ENDELSE
      npix_out = N_ELEMENTS(x)
      x = REFORM(TEMPORARY(x),npix_out)
      y = REFORM(TEMPORARY(y),npix_out)
      XYAD, tan_hdr, x, y, a, d

      ;precess and rotate coordinates if needed
      cc = hpx_coordsys+tan_coordsys
      needed = (hpx_coordsys NE tan_coordsys) OR ((cc EQ'CC') AND (hpx_epoch NE tan_epoch))
      IF needed THEN $
         CHANGE_COORDSYS, a, d, lon, lat, $
                          coordsys_in=tan_coordsys, coordsys_out=hpx_coordsys, epoch_in=tan_epoch, epoch_out=hpx_epoch $
      ELSE BEGIN
         lon=a
         lat=d
      END
      theta = (90.-lat)*dtor
      phi = lon*dtor
      CASE ordering OF
         'RING' : ANG2PIX_RING, nside, theta, phi, ipix
         'NESTED' : ANG2PIX_NEST, nside, theta, phi, ipix
      ENDCASE
      mapout = REFORM(hpx_map(ipix),naxis1,naxis2)
   END

ENDCASE

RETURN, mapout
END
