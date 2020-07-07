PRO jpb_plotsym, psym, psize, fill=fill, rotation=rotation, thick=thick

;+
; NAME:
;	JPB_PLOTSYM
; PURPOSE:
;	Define useful plotting symbols not in the standard !PSYM definitions.
; EXPLANATION:
;	After symbol has been defined with PLOTSYM, a plotting command should
;	follow with either PSYM = 8 or !P.PSYM = 8 (see USERSYM)
;
; CALLING SEQUENCE:
;	JPB_PLOTSYM, symbol,[ size, /FILL]
;
; INPUTS:
;    symbol = character string giving type of symbol:
;        circle, arrow, star, triangle, square
;	Arrows are defined such that their base begins at their origin.
;
; OPTIONAL INPUTS:
;	size   = Size of the plotting symbol in multiples of the default size
;		    (default PSIZE=1).  Does not need to be an integer
;
; OPTIONAL INPUT KEYWORD:
;	fill     = Generate filled symbols, if set (default=0)
;    rotation = rotation angle around the center.
; OUTPUTS:
;	None
;
; EXAMPLES:
;    jpb_plotsym,'triangle',2,/fill,rotation=45.
;	plot,[0,1,2],[0,1,2],PSYM=8
; METHOD:
;	Appropriate X,Y vectors are used to define the symbol and passed to the
;	usersym.pro
;     Uses usersym.pro
; REVISION HISTORY
;    written J.Ph. Bernard Aug 31 1998 (from plotsym, by W. Landsman)
;-

On_error,2

IF N_elements(psym) LT 1 THEN BEGIN
     print,'jpb_plotsym, symbol[,size][, /FILL][,rotation=]'
     print,'  accepted values for symbol are:'
     print,'    circle,star,arrow,triangle,square'
     return
ENDIF

IF ( N_elements(psize) LT 1 ) THEN psize = 1 ELSE psize = psize

IF NOT keyword_set(FILL) THEN fill = 0
IF NOT keyword_set(thick) THEN thick=0

CASE psym OF
  'circle':  BEGIN
      ang = 2*!PI*findgen(49)/48.     ;Get position every 5 deg
      xarr = psize*cos(ang)  &  yarr = psize*sin(ang)
  END
  'arrow':  BEGIN                                     ;Up arrow
      xarr = [0,0,.5,0,-.5]*psize
      yarr = [0,2,1.4,2,1.4]*psize
      fill = 0
  END
  'star':  BEGIN                                     ;Star
      r = psize
      ang = (720. / 5*findgen(6) + 45) / !RADEG  ;Define star angles every 144 deg
      xarr = r*cos(ang)  & yarr = r*sin(ang)
    END
  'triangle':  BEGIN                                     ;Triangle
      xarr = [-1,0,1,-1]*psize
      yarr = [-1,1,-1,-1]*psize
    END
  'square':  BEGIN                                     ;Square
      xarr = [-1,-1,1, 1,-1] * psize
      yarr = [-1, 1,1,-1,-1] * psize
    END
   ELSE: BEGIN
      message,'Unknown plotting symbol :'+psym,/continue
      goto,sortie
   ENDELSE
 ENDCASE

IF keyword_set(rotation) THEN BEGIN
  mat_rot=fltarr(2,2)
  mat_rot(0,0)=-sin(rotation/180.*!pi)
  mat_rot(0,1)=cos(rotation/180.*!pi)
  mat_rot(1,0)=cos(rotation/180.*!pi)
  mat_rot(1,1)=sin(rotation/180.*!pi)
  nxarr=xarr*mat_rot(0,1)+yarr*mat_rot(1,1)
  nyarr=xarr*mat_rot(0,0)+yarr*mat_rot(1,0)
  xarr=nxarr
  yarr=nyarr
ENDIF

 usersym, xarr, yarr, FILL = fill, thick=thick

sortie:
RETURN
END


;------------------------------------------------------------

pro display_overlay, overlay, size_coef, h0, connect=connect

COMMON proj_common,mat,rota,proj,coord, $
naxis1,naxis2,crpix1,crpix2,cdelt1,cdelt2,crval1,crval2,projtype,equinox, $
ctype1,ctype2,projp1,longpole

h2pix,h0

;=============== Plot the Overlaid symbols
N_set=n_tags(overlay)
FOR i=0,N_set-1 DO BEGIN
    overx=overlay.(i).coo1
    overy=overlay.(i).coo2
; modif MAMD 21/09/2001
    coo2pix2,overx,overy,xpix,ypix,silent=1
;    xpix = overx
;    ypix = overy
; end modif
    si=size(overx)
    if si(0) eq 0 then Npoints=1 else Npoints=si(1)
    FOR j=0,Npoints-1 DO BEGIN
        name=overlay.(i).label(j)
;        IF name EQ '' THEN BEGIN
            rotsym=overlay.(i).sym_angle(j)
            psym=overlay.(i).sym_type(j)
            fill=overlay.(i).sym_fill(j)
            double=overlay.(i).sym_double(j)
            csize=size_coef*overlay.(i).sym_size(j) 
            color=mcol( overlay.(i).sym_color(j) )
            thick=overlay.(i).sym_thick(j)
            jpb_plotsym,psym,csize,fill=fill,rotation=rotsym,thick=thick

            if keyword_set(connect) then continu=1 else continu=0
            if (j eq 0) then $
              plots, [xpix(j)],[ypix(j)],color=color,thick=thick, /data, psym=-8 $
            else plots, [xpix(j)],[ypix(j)],color=color,thick=thick, /data, continu=continu, psym=-8

            IF double NE 0 THEN BEGIN
                color2=color+244/2.
                jpb_plotsym,psym,csize-csize/2,fill=fill,rotation=rotsym,thick=thick
                if keyword_set(connect) then begin
                    if (j eq 0) then $
                      plots, [xpix(j)],[ypix(j)],color=color2,thick=thick, /data, psym=-8 $
                    else plots, [xpix(j)],[ypix(j)],color=color2,thick=thick, /data, /continu, psym=-8
                endif else oplot, [xpix(j)],[ypix(j)],color=color2,thick=thick, psym=8
            ENDIF
;        ENDIF ELSE BEGIN
        IF name NE '' THEN BEGIN
            csize=overlay.(i).label_size(j)
            color=overlay.(i).label_color(j)
            thick=overlay.(i).label_thick(j)
;stop
            xyouts,xpix(j),ypix(j),name,charsize=csize,color=mcol(color), $
              charthick=thick,align=0.5
        ENDIF
;        ENDELSE
    ENDFOR
ENDFOR

end
