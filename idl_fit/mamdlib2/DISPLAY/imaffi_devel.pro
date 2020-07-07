;---------------------------------------------------------------
pro imaffi, image, imcontour=imcontour, levels=levels, imrange=imrange, $
            rebin_factor=rebin_factor, winnumber=winnumber, indef=indef, nsigma=nsigma, percent=percent, $
            s_image=s_image, xtitle=xtitle, ytitle=ytitle, $
            title=title, axe=axe, xticks=xticks, yticks=yticks, $
            charsize=charsize, postscript=postscript, $
            ppsscale=ppsscale, eps=eps, xstyle=xstyle, ystyle=ystyle, $
            sample=sample, position=position, header=header, invert=invert, $
            xcharsize=xcharsize, ycharsize=ycharsize, bits=bits, nocadre=nocadre, $
            landscape=landscape, grid=grid, display_size=display_size, no_xtitle=no_xtitle, $
            no_ytitle=no_ytitle, connect=connect, ticklen=ticklen, $
            dxbar = dxbar, dybar=dybar, thickbar=thickbar, bar=bar, $
            formatbar=formatbar, valuebar=valuebar, unitsbar=unitsbar, charbar=charbar, $
            label=label, poslabel=poslabel, charlabel=charlabel, nbvaluebar=nbvaluebar, $
            overlay=overlay, cadrenu=cadrenu, maxval=maxval, minval=minval, $
            nlevels=nlevels, nested=nested_online

;-----------------------------------------------------------
;
; IMAFFI
;
; Programme d'affichage d'image avec des axes en mode "X"
; et "PS". IMAFFI permet d'ajuster automatiquement les 
; parametres du Postscript (taille et "scale" du postscript)
; de telle sorte que c'est WYSIWYG (What you see is what you get)
; i.e. ce qui est afficher a l'ecran est parfaitement reproduit
; sur le postscript.
; On ferme le postscript avec le programme PSOUT
;
; INPUT:  image
;
; OUPUT:  aucun
;
; KEYWORDS:
;
;            axe:            [xmin, ymin, xmax, ymax]; permet de
;                            modifier les valeurs d'axe (pixel de
;                            l'image par defaut).
;            bits:           Le nombre de bit sur lequel l'image est codee
;            charsize:       Taille du caractere
;            display_size:   fltarr(2): taille en cm de la zone
;                            d'affichage.
;                            display_size(0) = taille en X (19 cm par defaut)
;                            display_size(1) = taille en Y (27 cm par defaut)
;            eps:            Fabrique un encapsulated postscript 
;            header:         Permet de calculer les axes a partir d'un
;                            header
;            imcontour:      fltarr(2D); Superpose les contours d'une
;                            image (utiliser LEVELS pour ajuster les
;                            niveaux de contour).
;            imrange:        fltarr(2); Interval dynamique de l'affichage
;            indef:          Valeur indefinie - permet de mettre les
;                                               points indefinis en
;                                               blanc dans le
;                                               postscript
;            invert:         keyword; permet d'inverser la table de
;                            couleur.
;            landscape:      keyword; permet de mettre en landscape
;            levels:         fltarr; Niveaux des contours (a utliser
;                            avec imcontour)
;            nocadre:        keyword; supprime completement le cadre
;            position:       fltarr(4); vecteur position classique qui
;                            determine la position de l'image dans la fenetre (ou dans
;                            le postscript). IMAFFI calcule automatiquement la taille
;                            de la fenetre (ou du postscript).
;            postscript:      Nom du fichier postscript a creer.
;            ppsscale:       Ajustement fin du scale du postscript (ne devrait pas etre utilise)
;            rebin_factor:   fltarr(2) ou float(1); facteur de rebin
;            sample:         rebin en mode SAMPLE
;            s_image:        fltarr(4); selectionne une sous_image
;                            (coordonnees en pixel).
;            title:          titre
;            winnumber:      numero de la fenetre d'affichage (9 par defaut)
;            xticks:         nombre de ticks en X
;            xtitle:         titre de l'axe des X
;            yticks:         nombre de ticks en X
;            ytitle:         titre de l'axe des Y
;
;
; MAMD 25/9/98
;
;---------------------------------------------------------

;---------------------------------------------------
; 

; parameters check

IF N_PARAMS() eq 0 or not keyword_set(image) THEN BEGIN
    PRINT, 'CALLING SEQUENCE: imaffi, image, imcontour=imcontour, levels=levels, imrange=imrange, $'
    print, '    rebin_factor=rebin_factor, winnumber=winnumber, indef=indef, $'
    print, '    s_image=s_image, xtitle=xtitle, ytitle=ytitle, $'
    print, '    title=title, axe=axe, xticks=xticks, yticks=yticks, $'
    print, '    charsize=charsize, postscript=postscript, $'
    print, '    ppsscale=ppsscale, eps=eps, xstyle=xstyle, ystyle=ystyle, $'
    print, '    sample=sample, position=position, header=header, invert=invert, $'
    print, '    xcharsize=xcharsize, ycharsize=ycharsize, bits=bits, nocadre=nocadre, $'
    print, '    landscape=landscape, grid=grid, display_size=display_size, no_xtitle=no_xtitle, $'
    print, '    no_ytitle=no_ytitle, connect=connect, ticklen=ticklen, $'
    print, '    dxbar = dxbar, dybar=dybar, thickbar=thickbar, bar=bar, $'
    print, '    formatbar=formatbar, valuebar=valuebar, unitsbar=unitsbar, charbar=charbar, $'
    print, '    label=label, poslabel=poslabel, charlabel=charlabel, $'
    print, '    overlay=overlay, nbvaluebar=nbvaluebar'
    GOTO, sortie
ENDIF

;---------------------------------
pbackground = !P.BACKGROUND
pcolor = !P.COLOR
tvlct, pr, pg, pb, /get

; reserve first two colors for black and white
curr_r = pr
curr_g = pg
curr_b = pb
curr_r(1) = 0 & curr_g(1) = 0 & curr_b(1) = 0
curr_r(0) = 255 & curr_g(0) = 255 & curr_b(0) = 255
tvlct, curr_r, curr_g, curr_b
!p.background = 0
!p.color = 1

image2 = image    ; back up original
si_image = size(image2)

;---------- IMRANGE ---------
if not keyword_set(imrange) then imrange=compute_range(image2, nsigma=nsigma, percent=percent, indef=indef)
if keyword_set(maxval) then imrange(1) = maxval
if keyword_set(minval) then imrange(0) = minval

;------- Undefined values --------------
if not keyword_set(indef) then indef = -32768.
if (keyword_set(postscript) or !D.NAME eq 'PS') then begin
    ind = where(image2 eq indef, nbindef)
    if (nbindef gt 0) then image2(ind) = 32768
endif

;------ Invert the Image ----------
if keyword_set(invert) then begin
    image2 = max(imrange)-image2+min(imrange)
    imrange = max(imrange)-imrange+min(imrange)
    imrange = rotate(imrange,2)
endif else invert=0

;--------- check for TRUE image (RGB) ------------
if (si_image(0) eq 3 and si_image(3) eq 3) then true=3 else true=0

;-------- check for Healpix vector ----------------
if (si_image(0) eq 1) then begin
   defsysv, '!healpix', exists = exists
   if (exists ne 1) then init_healpix
   loadsky                      ; cgis package routine, define rotation matrices

   loaddata_healpix, image2, select_in, data, pol_data, pix_type, pix_param, do_conv, do_rot, coord_in, $
                     coord_out, eul_mat, title_display, sunits, $
                     ONLINE=1, NESTED=nested_online, ERROR=error
   if error NE 0 then return
;stop
;print, !p.background, !p.color
   data2moll, data, pol_data, pix_type, pix_param, do_conv, do_rot, coord_in, coord_out, $
              eul_mat, image2, PXSIZE=pxsize, min=imrange(0), max=imrange(1)
;print, !p.background, !p.color
   si_image = size(image2)
   nocadre=1
endif else begin
   ; ICI il faut liberer 3 valeurs pour blanc, gris et noir.
   image2 = BYTSCL( temporary(image2), MIN=imrange(0), MAX=imrange(1))
endelse

;-------- default margin values ----------------
margex = [0.1, 0.1]
margey = [0.1, 0.1]

;-------- POSITION VECTOR --------------
if (keyword_set(postscript) and not keyword_set(position)) then position=[margex(0), margey(0), 1.-margex(1), 1.-margey(1)]

;----- Rebin the image-------------
if not keyword_set(s_image) then s_image = [0, 0, si_image(1)-1, si_image(2)-1]
if not keyword_set(position) and not keyword_set(postscript) and not keyword_set(rebin_factor) then begin
    sizex = !d.x_size*(1.-total(margex))
    sizey = !d.y_size*(1.-total(margey))
    sx_image = (s_image(2)-s_image(0)+1)
    sy_image = (s_image(3)-s_image(1)+1)
    reb = min( [sizex/sx_image, sizey/sy_image] )

    dx = 1.- reb*sx_image / !d.x_size
    if dx gt total(margex) then begin
        posx2 = dx/2.>margex(1)
        posx1 = dx-posx2
    endif else posx1 = margex(0)
    
    dy = 1.- reb*sy_image / !d.y_size
    if dy gt total(margey) then begin
        posy2 = dy/2.>margey(1)
        posy1 = dy-posy2
    endif else posy1 = margey(0)
    position = [posx1, posy1]
    rebin_factor = reb
endif
if not keyword_set(rebin_factor) then rebin_factor=1
if (n_elements(rebin_factor) eq 1) then rebin_factor=[rebin_factor, rebin_factor]

A = rebin_factor(0)*(s_image(2)-s_image(0)+1)
B = rebin_factor(1)*(s_image(3)-s_image(1)+1)
if keyword_set(true) then $
   image2 = congrid( temporary(image2(s_image(0):s_image(2), s_image(1):s_image(3), *) ), A, B, 3) else $
      image2 = congrid( temporary(image2(s_image(0):s_image(2), s_image(1):s_image(3))), A, B)
taille = size(image2)


;-----------------------------------------------------------------------
; Determination de la taille de la region d'affichage (MODE "X" ou "PS").
; Affichage de l'image.

if (N_ELEMENTS(position) eq 4) then begin
    if (position(2) eq 0. and position(3) eq 0.) then position = position(0:1)
    dpx = position(2)-position(0)
    dpy = position(3)-position(1)
    pix_per_position = [taille(1)/dpx, taille(2)/dpy]
    tx = pix_per_position(0)    ; taille du champ en DEVICE
    ty = pix_per_position(1)    ; taille du champ en DEVICE
    if (not keyword_set(postscript)) then begin
        if not keyword_set(winnumber) then winnumber = 9
        window, winnumber, xs=tx, ys=ty, xpos=100, ypos=100, ret=2
        TV, image2,  position(0), position(1), /normal, true=true
    endif else begin
        if not keyword_set(eps) then eps=0
        if not keyword_set(bits) then bits=8
        if keyword_set(display_size) then begin
            xdisplay_size = display_size(0)
            ydisplay_size = display_size(1)
        endif else begin
            xdisplay_size = 19.
            ydisplay_size = 27.
        endelse
        if keyword_set(landscape) then begin
            xsize_psdev = ydisplay_size*1000.
            ysize_psdev = xdisplay_size*1000.
        endif else begin
            xsize_psdev = xdisplay_size*1000.
            ysize_psdev = ydisplay_size*1000.
        endelse
        if not keyword_set(ppsscale) then scale = min([fix(xsize_psdev/float(tx)), $
                                                       fix(ysize_psdev/float(ty))]) $
        else scale = ppsscale
        xsize = taille(1)*0.001*scale ; taille de l'image en cm
        ysize = taille(2)*0.001*scale ; taille de l'image en cm
        ps_sizex = tx*0.001*scale ; taille du champ PS en cm
        ps_sizey = ty*0.001*scale ; taille du champ PS en cm
        !MAMDLIB.SCALE = scale
        !MAMDLIB.PS_SIZEX = ps_sizex
        !MAMDLIB.PS_SIZEY = ps_sizey
        if keyword_set(landscape) then begin
            xoffset = (21.-ps_sizey)/2.
            yoffset = ps_sizex+(29.-ps_sizex)/2.
        endif else begin
            xoffset = (21.-ps_sizex)/2.
            yoffset = (29.-ps_sizey)/2.
        endelse
        if string(strcompress(postscript, /remove_all)) eq '1' then begin
            file='idl.ps'
            eps=0
        endif else file = postscript
;        PSFILE = file
print, !p.background, !p.color
        ps, file=file, xsize=ps_sizex, ysize=ps_sizey, $
          eps=eps, xoffset=xoffset, yoffset=yoffset, bits=bits, landscape=landscape, true=true
        debutx = (position(0))*pix_per_position(0)*scale*0.001
        debuty = (position(1))*pix_per_position(1)*scale*0.001

!p.background = 0
!p.color = 1

print, !p.background, !p.color

        TV, image2, debutx, debuty, /centimeters, xsize=xsize, ysize=ysize, true=true
;        TV, BYTSCL(image(s_image(0):s_image(2), s_image(1):s_image(3), *), MIN=imrange(0), MAX=imrange(1)), $
;          debutx, debuty, /centimeters, xsize=xsize, ysize=ysize, true=true
    endelse
endif else begin
    if (!D.NAME eq 'X') then begin
        if not keyword_set(position) then begin
            erase
            position = [0.1, 0.1, 0., 0.]
        endif
        if (n_elements(position) eq 2) then position = [position, 0, 0]
        tx = !D.X_SIZE
        ty = !D.Y_SIZE
        position(2) = position(0)+1.*taille(1)/tx
        position(3) = position(1)+1.*taille(2)/ty
        TV, image2, position(0), position(1), /normal, true=true
    endif else begin
        if not keyword_set(position) then position = [0.1, 0.1, 0., 0.]
        if (n_elements(position) eq 2) then position = [position, 0, 0]
        scale = !MAMDLIB.SCALE
        ps_sizex = !MAMDLIB.PS_SIZEX
        ps_sizey = !MAMDLIB.PS_SIZEY
        xsize = taille(1)*0.001*scale ; taille de l'image en cm
        ysize = taille(2)*0.001*scale ; taille de l'image en cm
        position(2) = position(0)+1.*xsize/ps_sizex
        position(3) = position(1)+1.*ysize/ps_sizey
        debutx = (position(0))*ps_sizex
        debuty = (position(1))*ps_sizey
        TV, image2, debutx, debuty, /centimeters, xsize=xsize, ysize=ysize, true=true
    endelse
endelse


;---------------- CONTOUR -------------------------

if keyword_set(imcontour) then begin
    if n_elements(imcontour) eq 1 then imcontour = image2
    if keyword_set(nlevels) then begin
        dimrange = ( imrange(1)-imrange(0) ) / (1.*nlevels +1.)
        levels = (findgen(nlevels)+1.)*dimrange+imrange(0)
    endif
    if not keyword_set(levels) then levels=[10]
    xr = [s_image(0), s_image(2)]
    yr = [s_image(1), s_image(3)]
    contour, imcontour, /normal, /noerase, pos=position, $
      levels=levels, xs=5, ys=5, xrange=xr, yrange=yr, $
      c_colors=c_colors , c_thick=c_thick 
endif


;-----------------------------------------------------------------
; Determination et Affichage des axes et de la grille

if not keyword_set (charsize) then charsize = 1
if not keyword_set(xcharsize) then xcharsize=charsize
if not keyword_set(ycharsize) then ycharsize=charsize
if not keyword_set(ticklen) then ticklen=0
if not keyword_set(xstyle) then xstyle=1
if not keyword_set(ystyle) then ystyle=1
if not keyword_set(title) then title='' 
if not keyword_set(xtitle) then xtitle='' 
if not keyword_set(ytitle) then ytitle='' 

if keyword_set(nocadre) then begin
    xstyle=4
    ystyle=4
endif

if keyword_set(axe) then begin 
    axeb=axe
    if keyword_set(s_image) then begin
        dx = float(si_image(1))/float(axeb(2)-axeb(0))
        dy = float(si_image(2))/float(axeb(3)-axeb(1))
        tmp = [s_image(0)/dx+axeb(0), s_image(1)/dy+axeb(1), $
               (s_image(2)+1)/dx+axeb(0), (s_image(3)+1)/dy+axeb(1)]
        axeb = tmp
    endif
    xaxe = [axeb(0), axeb(2)]
    yaxe = [axeb(1), axeb(3)]
endif else begin
    xaxe = [s_image(0), s_image(2)]
    yaxe = [s_image(1), s_image(3)]
endelse

if keyword_set(header) then begin ; Calcul automatique des axes
    IF keyword_set(grid) then create_coo2,header,coo1,coo2
    equinoxe = sxpar(header, 'EPOCH')
    if not keyword_set(equinoxe) then equinoxe = sxpar(header, 'EQUINOX')
    ctype1 = sxpar(header, 'CTYPE1')
    IF (ctype1 EQ 'GLON-TAN' or ctype1 EQ 'GLON-CAR') THEN BEGIN
        xtitle = 'l (degree)'
        ytitle = 'b (degree)'
    ENDIF ELSE begin
        if (equinoxe eq 2000) then begin
            xtitle = 'J2000 R. A.' ; '!9a!3!i2000!n (hr)'
            ytitle = 'J2000 Dec.' ;'!9d!3!i2000!n (degree)'
        endif
        if (equinoxe eq 1950) then begin
            xtitle = 'B1950 R. A.' ;'!9a!3!i1950!n (hr)'
            ytitle = 'B1950 Dec.' ;'!9d!3!i1950!n (degree)'
        ENDIF
    endelse
    if keyword_set(no_xtitle) then xtitle='!3'
    if keyword_set(no_ytitle) then ytitle='!3'
    huse = header
    crpix1 = sxpar(header, 'CRPIX1')
    crpix2 = sxpar(header, 'CRPIX2')
    sxaddpar, huse,'CRPIX1',crpix1-s_image(0)
    sxaddpar, huse,'CRPIX2',crpix2-s_image(1)
    sxaddpar, huse,'NAXIS1',s_image(2)-s_image(0)+1
    sxaddpar, huse,'NAXIS2',s_image(3)-s_image(1)+1
    if keyword_set(xticks) then !x.ticks = xticks
    if keyword_set(yticks) then !y.ticks = yticks
    IF (ctype1 EQ 'GLON-TAN') THEN Begin 
        prj_header_coo, huse, al, del
        ; check if we cross the al=0 line
        maxdiff = max(abs(al-shift(al, 1, 0)))
        if (maxdiff gt 300) then begin
            ind180 = where(al gt 180, nb180)
            if (nb180 gt 0) then al(ind180) = al(ind180)-360.
        endif
        plot,xaxe-s_image(0),yaxe-s_image(1),/normal,/nodata,/noerase,$
          xs=xstyle,ys=xstyle, pos=position,$
          xtitle=xtitle,ytitle=ytitle, $
          xrange=[max(al), min(al)], yrange=minmax(del), $
          xcharsize=xcharsize, ycharsize=ycharsize, $
          xticklen=ticklen, yticklen=ticklen, charsize=charsize
    endif else begin
        mk_grid_val,huse,xpos,ypos,vv,aa,nmx,nmy,l_grid,b_grid,gridx,gridy,coo1,coo2, $
          grid=grid,silent=silent,no_x_label=no_x_label, $
          no_y_label=no_y_label,position_x='low',position_y='low', $
          ra_grid=ra_grid,dec_grid=dec_grid
        plot,xaxe-s_image(0),yaxe-s_image(1),/normal,/nodata,/noerase,$
          xs=xstyle,ys=xstyle, pos=position,$
          xtitle=xtitle,ytitle=ytitle,xtickname=vv, ytickname=aa, $
          xtickv=xpos, ytickv=ypos, yticks=n_elements(ypos)-1, xticks=n_elements(xpos)-1, $
          xcharsize=xcharsize, ycharsize=ycharsize, $
          xticklen=ticklen, yticklen=ticklen, charsize=charsize
    endelse
;=============== Plot the grid
    IF keyword_set(grid) THEN BEGIN
        !x.ticklen=1.e-3
        !y.ticklen=1.e-3
        l_grid=ra_grid*!radeg
        b_grid=dec_grid*!radeg
        coo=coo1
        ind=where(l_grid LT 0,count)
        IF count NE 0 THEN l_grid(ind)=l_grid(ind)+360.
        sl=sort(l_grid) & sb=sort(b_grid)
        all_lev=l_grid(sl) & si=size(all_lev) & Nlev=si(1)
        IF Nlev LT 30 THEN BEGIN
            contour,coo,levels=all_lev,/noerase,xstyle=5,ystyle=5,title=' ', $
              pos=position
        ENDIF ELSE BEGIN
            ncou=Nlev/30
            FOR i=0,ncou do begin
                deb=i*30 & fin=(deb+29)<(Nlev-1)
                levs=all_lev(deb:fin)
                contour,coo,levels=levs,/noerase,xstyle=5,ystyle=5,title=' ', $
                  pos=position
            ENDFOR
        ENDELSE
        coo=coo2
        contour,coo,levels=b_grid(sb),/noerase,xstyle=5,ystyle=5,title=' ', $
          pos=position
    ENDIF

endif else begin
    if keyword_set(grid) then begin
        !x.ticklen=0.5
        !y.ticklen=0.5
    endif else begin
        !x.ticklen=0.02 
        !y.ticklen=0.02
    endelse
    if keyword_set(cadrenu) then begin
       plots, [position(0), position(2), position(2), position(0), position(0)], $
              [position(1), position(1), position(3), position(3), position(1)], /normal, color=!p.color
     endif else begin
        plot,xaxe,yaxe,/normal,/nodata,/noerase,xs=xstyle,ys=ystyle, pos=position, $
             xtitle=xtitle,ytitle=ytitle, xcharsize=xcharsize, xticks=xticks, yticks=yticks, color=!p.color, $
             xrange=xaxe, yrange=yaxe, ycharsize=ycharsize, xticklen=ticklen, yticklen=ticklen, charsize=charsize
     endelse
endelse

;----------- TITLE ----------------------
if keyword_set(title) then begin
   dpx = position(2)-position(0)
   xyouts, position(0)+dpx/2., position(3)+0.01, title, /normal, align=0.5, charsize=charsize, color=!p.color
endif

;-------------------------------------------------------
; OVERLAY DISPLAY (en utilisant la methode JPB).
if keyword_set(overlay) then begin
    reset_plot_env_var
    cdelt1=sxpar(huse,'CDELT1')
    IF (!D.NAME eq 'X') THEN begin
        size_coef = (1./6.)*rebin_factor(1)/(abs(cdelt1))
    endif else begin
        fudge = 2.*scale/64.    ; fudge factor to get the right size on printer !
        size_coef = (1./7.)*rebin_factor(1)*fudge/abs(cdelt1) 
    endelse
    if not keyword_set(connect) then connect=0
    display_overlay, overlay, size_coef, huse, connect=connect
;    loadct, ntab, /silent
endif

;----------------------------------------------
; LABEL DISPLAY
if keyword_set(label) then begin
    if not keyword_set(charlabel) then charlabel=charsize
    if not keyword_set(poslabel) then poslabel=[-0.05, 0.95]
    dxlabel=poslabel(0)
    dylabel=poslabel(1)
    if (dxlabel eq 0 or dylabel eq 0) then goto, sortie
    posl=fltarr(4)
    if (dxlabel le 0.) then begin
        posl(0) = position(0)+dxlabel
        posl(2) = position(0)
    endif
    if (dxlabel gt 0. and dxlabel lt 0.5) then begin
        posl(0) = position(0)
        posl(2) = position(0)+dxlabel
    endif
    if (dxlabel gt 0.5 and dxlabel lt 1.) then begin
        posl(0) = position(2)-(1.-dxlabel)
        posl(2) = position(2)
    endif
    if (dxlabel gt 1.) then begin
        posl(0) = position(2)
        posl(2) = position(2)+(dxlabel-1.)
    endif

    if (dylabel le 0.) then begin
        posl(1) = position(1)+dylabel
        posl(3) = position(1)
    endif
    if (dylabel gt 0. and dylabel lt 0.5) then begin
        posl(1) = position(1)
        posl(3) = position(1)+dylabel
    endif
    if (dylabel gt 0.5 and dylabel lt 1.) then begin
        posl(1) = position(3)-(1.-dylabel)
        posl(3) = position(3)
    endif
    if (dylabel gt 1.) then begin
        posl(1) = position(3)
        posl(3) = position(3)+(dylabel-1.)
    endif
    mamd_label, posl, label, charsize=charlabel, color=!p.color
endif


;--------------------------------
; reload original color table
!P.BACKGROUND = pbackground & !P.COLOR = pcolor
tvlct, pr, pg, pb   

;-----------------------------
; BAR DISPLAY

if not keyword_set(nbvaluebar) then nbvaluebar=3

if (keyword_set(dxbar) or keyword_set(dybar) or keyword_set(thickbar) or keyword_set(formatbar) $
    or keyword_set(valuebar) or keyword_set(unitsbar)) then bar=1

if keyword_set(bar) then begin
    otherside = 0
    if not keyword_set(formatbar) then formatbar = 0
    if not keyword_set(valuebar) then valuebar = 0
    if not keyword_set(thickbar) then thickbar = 0.02
    if not keyword_set(dxbar) and not keyword_set(dybar) then dxbar = 0.02
    if keyword_set(dxbar) then begin
        if (dxbar gt 0) then begin
            posbar = [position(2)+dxbar, position(1), position(2)+thickbar+dxbar, position(3)]
        endif else begin
            posbar = [position(0)-thickbar+dxbar, position(1), position(0)+dxbar, position(3)]
            otherside=1
        endelse
        posunits = [posbar(0), posbar(3)+0.04]
    endif
    if keyword_set(dybar) then begin
        if (dybar gt 0) then begin
            posbar = [position(0), position(3)+dybar, position(2), position(3)+dybar+thickbar]
        endif else begin
            posbar = [position(0), position(1)+dybar-thickbar, position(2), position(1)+dybar]
            otherside=1
        endelse
        posunits = [posbar(2)+0.02, (posbar(3)+posbar(1))/2.]
    endif
    if not keyword_set(charbar) then charbar=charsize
    mamd_bar, posbar, imrange=imrange, value=valuebar, otherside=otherside, format=formatbar, charsize=charbar, $
      nbvalue=nbvaluebar, invert=invert, ticklen=ticklen
    if not keyword_set(unitsbar) and keyword_set(header) then unitsbar = sxpar(huse, 'BUNIT')
    if keyword_set(unitsbar) then xyouts, posunits(0), posunits(1), unitsbar, /normal, charsize=charbar
endif


;-------------------------------------------------------
; SORTIE

sortie:
reset_plot_env_var

end




