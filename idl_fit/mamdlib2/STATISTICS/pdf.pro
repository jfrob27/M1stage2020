pro pdf, image, nb_case=nb_case, xrange=xrange, yrange=yrange, $
         indef=indef, marge=marge, cadre=cadre, xtitle=xtitle, $
         ytitle=ytitle, title=title, bin=bin, lag=lag, incr=incr, $
         psym=psym, gaussian=gaussian, skew=skew, kurt=kurt, color=color, $
         xcharsize=xcharsize, ycharsize=ycharsize, $
         nocadre=nocadre, charsize=charsize, $
         nolegend=nolegend, linestyle=linestyle, pos_skew=pos_skew, $
         pos_kurt=pos_kurt, normal=normal, nolog=nolog, s_image=s_image, $
         position=position, vecteurx=vecteurx, histo=histo, stat=stat
;		nowindow=nowindow, win_number=win_number

;----------------------------------------------------
;
; PDF.PRO
;
; Calcule et affiche la Probability Density Function (mieux connue
; sous le nom d'histogramme) de sous-regions d'une image.
; Le programme affiche egalement une gaussienne ajustee a l'histogramme.
; On peut egalement afficher le 'PDF increment'
; en specifiant le keyword /incr.
;
; CALLING SEQUENCE:
;    pdf, image, nx, ny
;
; INPUT:
;    image: une image de taille quelconque
;    nx: nombre de sous-regions en x
;    ny: nombre de sous-regions en y
;
; EXEMPLE:
;    pdf, residu, 4, 4
;
; KEYWORDS:
;
;	bin:		Valeur du bin de histogram. bin=1. par defaut.
;
;	cadre		Position du cadre dans la marge (en /normal).
;			cadre = 0.04 par defaut.
;
;	gauss:		Permet l'affichage de la gaussienne (curvefit) correspondant
;			a l'histogramme calcule. 
;			Elle est affichee en surimpression.
;
;	incr:		Permet le calcul du 'PDF increment'
;
;	indef:		Valeur des points indefinis du champ de vitesse.
;			indef=-999 par defaut.
;
;	kurt:		Affiche en surimpression du kurtosis de la distribution.
;
;	lag:		Valeur de la distance en pixel utilisee pour le calcul
;			du 'PDF increment'. lag=3 par defaut.
;
;	marge:		Taille de la marge (en /normal). default=0.1 
;
;	noaffi:		Effectue le calcul sans l'afficher
;
;	psym:		Symbole des points de l'histogramme. psym=5 par defaut
;
;	skew:		Affiche en surimpression le skewness de la distribution.
;
;	title:		Titre du graphique. title = '' par defaut
;
;	xrange:		Valeur minimale et maximale consideree par
;
;	xtitle:		Titre en x du graphique. xtitle = 'km/s' par defaut
;
;	yrange:		Valeur minimale et maximale de l'affichage.
;
;	ytitle:		Titre en y du graphique. ytitle = 'pdf' ou 'pdf incr.' par defaut
;
;
; MAMD 6/11/97
;
;
;
;
; POUR RAMENER L'HISTOGRAMME DANS UNE DISTRIBUTION 0,1 ON FAIT
; Z = (X-MU)/SIGMA
;
;
;
;------------------------------------------------------

;--------------------------------------------------------
; KEYWORDS

   if not keyword_set(nb_case) then begin
      nx=1
      ny=1
   endif else begin
      nx=nb_case(0)
      ny=nb_case(1)
   endelse
   if not keyword_set(indef) then indef = -999
   si_image = size(image)
   if keyword_set(s_image) then n_image = image(s_image(0):s_image(2), s_image(1):s_image(3)) $
   else begin
      n_image = image
      s_image = [0, 0, si_image(1)-1, si_image(2)-1]
   endelse
   noindef = where(n_image ne indef)
   if not keyword_set(xrange) then begin
      if not keyword_set(incr) then xrange = minmax(n_image(noindef)) $
      else xrange = [min(n_image(noindef))-max(n_image(noindef)), $
                     max(n_image(noindef))-min(n_image(noindef))]
   endif

   if not keyword_set(yrange) then begin
      if keyword_set(normal) then yrange = [0.001, 2] $
      else begin
         if keyword_set(incr) then yrange=[1, 1.1*n_elements(noindef)] $
         else yrange=[1, 0.2*n_elements(noindef)/float(nx*ny)]
      endelse
   endif

   if not keyword_set(xtitle) then xtitle = ''
   if not keyword_set(ytitle) and not keyword_set(incr) then ytitle = 'pdf'
   if not keyword_set(ytitle) and keyword_set(incr) then ytitle = 'pdf incr.'
   if not keyword_set(title) then title=''
   if not keyword_set(bin) then bin=1.
   if not keyword_set(lag) then lag=3
   if not keyword_set(psym) then psym=0
   if not keyword_set(linestyle) then linestyle=0

   if not keyword_set(xcharsize) then xcharsize=1
   if not keyword_set(ycharsize) then ycharsize=1
   if not keyword_set(charsize) then charsize=1

;if not keyword_set(charsize) then begin
;    xcharsize=1.
;    ycharsize=1.
;endif else begin
;    xcharsize=charsize
;    ycharsize=charsize
;endelsexyouts, -1.8, 0.5, string(3*0.0145, '("!4D!3L = ", F5.2, " pc")')


;print, xcharsize

   if keyword_set(nolegend) then begin
      xcharsize=1.e-6
      ycharsize=1.e-6
      marge = 0.05
   endif
   if not keyword_set(nolog) then ylog=1 else ylog=0

   if not keyword_set(marge) then marge = 0.1
   if not keyword_set(cadre) then cadre = 0.04
;if keyword_set(nocadre) then marge=0.05
   if keyword_set(nocadre) then begin
      cadre = 0.
      if keyword_set(position) then marge = 0.
   endif
   if not keyword_set(position) then begin
      position = [0., 0., 1., 1.]
      erase
   endif else cadre = 0.

   effec_width = [position(2)-position(0), position(3)-position(1)]
   pos_zero = position(0:1)
   if not keyword_set(pos_skew) then pos_skew=[0.5, 0.1]*effec_width+pos_zero
   if not keyword_set(pos_kurt) then pos_kurt=[0.5, 0.3]*effec_width+pos_zero

;------------------------------------------------------------

   taille = size(n_image)

   pasx=1.*(s_image(2)-s_image(0)+1)/float(nx) ; Pas en X (/data)
   pasy=1.*(s_image(3)-s_image(1)+1)/float(ny) ; Pas en Y (/data)

;data_2_pos_x = (1.-2.*cadre-1.5*marge)/taille(1)
;data_2_pos_y = (1.-2.*cadre-1.5*marge)/taille(2)
   data_2_pos_x = (effec_width(0)-2.*cadre-1.5*marge)/taille(1)
   data_2_pos_y = (effec_width(1)-2.*cadre-1.5*marge)/taille(2)

   xr = [-(marge)/data_2_pos_x+s_image(0), (0.5*marge)/data_2_pos_x+s_image(2)]
   yr = [-(marge)/data_2_pos_y+s_image(1), (0.5*marge)/data_2_pos_y+s_image(3)]

;-----------------------------------------
; Affichage du cadre

   if keyword_set(nocadre) then begin
      xs = 4
      ys = 4
   endif else begin
      xs = 1
      ys = 1
   endelse 

   a = [-32768, -32768]         ; vecteur bidon pour afficher le cadre
   basex = pasx*(indgen(nx+1))+s_image(0)
   basey = pasy*(indgen(ny+1))+s_image(1)

; poscadre = [cadre, cadre, 1-cadre, 1-cadre]
   poscadre = [position(0)+cadre, position(1)+cadre, position(2)-cadre, position(3)-cadre]

   plot, a, xticks=nx, yticks=ny, xr=xr, yr=yr,$
    xtickv = basex, ytickv=basey, charsize=charsize, $
;  title=title, xstyle=xs, ystyle=ys, position=poscadre, /normal
   title=title, xstyle=xs, ystyle=ys, position=poscadre, /normal, /noerase

;---------------------------------------
; Affichage des histogrammes

   vecteurx = indgen((xrange(1)-xrange(0))/bin+1)*bin+xrange(0)
   histo = fltarr((xrange(1)-xrange(0))/bin+1)
   stat = fltarr(4)
   dx = pasx*data_2_pos_x
   dy = pasy*data_2_pos_y

   for i=0, nx-1 do begin
      if (i eq 0) then taille_cy = ycharsize else taille_cy = 1.e-10
      for j=0, ny-1 do begin
         if (j eq 0) then taille_cx = xcharsize else taille_cx = 1.e-10
         sregion = n_image(i*pasx:((i+1)*pasx-1),j*pasy:((j+1)*pasy-1))
         indice = where(sregion ne indef, ngood)
         if (ngood gt 10) then begin
            if KEYWORD_SET(incr) then begin
               pdfincr, sregion, lag, histo, stat, indef=indef, xminmax=xrange, bin=bin
            endif else begin
               stat = moment(1.d*(sregion(indice)))
               histo = histogram(sregion, min=xrange(0), max = xrange(1), binsize=bin)
               vecteurx = findgen(n_elements(histo))*bin+xrange(0)
            endelse
            if KEYWORD_SET(normal) then histo = histo/(1.*max(histo))
         endif else begin
            histo = vecteurx & histo(*)=0.
         endelse
         if (max(histo) gt yrange(1)) then yrange(1) = 1.1*max(histo)
         poshisto = [i*dx+cadre+marge+pos_zero(0), j*dy+cadre+marge+pos_zero(1), $
                     (i+1)*dx+cadre+marge+pos_zero(0), (j+1)*dy+cadre+marge+pos_zero(1)]
         plot, vecteurx, histo, ylog=ylog, psym=psym, xcharsize=taille_cx, xtitle=xtitle, $
          xstyle = 1, xr=xrange, ycharsize=taille_cy, $
          yr=yrange, ystyle=1, ytitle=ytitle, /noerase, position=poshisto, /normal
         if KEYWORD_SET(gaussian) and ngood gt 20. then begin
            w = histo
            w(*) = 1.
            a = [max(histo), stat(0), sqrt(stat(1))]
;stop
            f = curvefit(vecteurx(0:n_elements(histo)-1),histo,w,a,sigma_a, function_name='gauss')
            gaussian = a
;      	f = max(histo)*exp(-(1.*vecteurx-stat(0))^2/(2.*stat(1)))
            if keyword_set(color) then oplot, vecteurx, f, color=color, linestyle=linestyle $
            else oplot, vecteurx, f, linestyle=linestyle
         endif
         if KEYWORD_SET(skew) and indice(0) ne -1 then xyouts, poshisto(0)+pos_skew(0)*dx, poshisto(1)+pos_skew(1)*dy, $
          string(stat(2), '("s: ", F6.3)'), alignment=0.5, /normal, charsize=xcharsize
         if KEYWORD_SET(kurt) and indice(0) ne -1 then xyouts, poshisto(0)+pos_kurt(0)*dx, poshisto(1)+pos_kurt(1)*dy, $
          string(stat(3), '("k: ", F6.3)'), alignment=0.5, /normal, charsize=xcharsize
      endfor
   endfor


end



