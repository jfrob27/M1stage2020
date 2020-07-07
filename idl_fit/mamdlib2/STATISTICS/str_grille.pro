pro str_grille, image, lagmax, ordre=ordre, s_image=s_image, xrange=xrange, yrange=yrange, $
		indef=indef, marge=marge, cadre=cadre, xtitle=xtitle, $
		ytitle=ytitle, title=title, $
		xcharsize=xcharsize, ycharsize=ycharsize, nocadre=nocadre, $
		nolegend = nolegend, ps=ps, nb_case=nb_case
		
;-------------------------------------------------------
;
; STR_GRILLE.PRO
;
;
;------------------------------------------------------

taille = size(image)
if keyword_set(s_image) then begin
	int_x = [s_image(0), s_image(2)]
	int_y = [s_image(1), s_image(3)]
endif else begin
	int_x = [0, taille(1)-1]
	int_y = [0, taille(2)-1]
endelse

if not keyword_set(nb_case) then begin
	nx=1	
	ny=1
	bin_size=[int_x(1)-int_x(0)+1, int_y(1)-int_y(0)+1]
endif else begin
	nx=nb_case(0)
	ny=nb_case(1)
	bin_size=[(int_x(1)-int_x(0)+1)/float(nx), (int_y(1)-int_y(0)+1)/float(ny)]
endelse

;--------------------------------------------------------
; KEYWORDS

if not keyword_set(ordre) then ordre=2
if not keyword_set(indef) then indef = -32768.0
if not keyword_set(yrange) then begin
;	simage = image(int_x(0):int_x(1),int_y(0):int_y(1))
;	stat = moment(simage)
	yrange = [1e-2, 30]
endif
if not keyword_set(marge) then marge = 0.1
if not keyword_set(cadre) then cadre = 0.04
if not keyword_set(xtitle) then xtitle = ''
if not keyword_set(ytitle) then ytitle = ''
if not keyword_set(title) then title=''
if not keyword_set(xcharsize) then xcharsize=1
if not keyword_set(ycharsize) then ycharsize=1
if keyword_set(nolegend) then begin
	xcharsize=1.e-6
	ycharsize=1.e-6
	marge = 0.06
endif

if not keyword_set(win_number) then win_number=6

if not keyword_set(ps) then $
	window, win_number, xpos=400, ypos=400 $
else begin
	if keyword_set(color) then ps, /color else ps
endelse

;-----------------------------------------
; Affichage du cadre

if keyword_set(nocadre) then begin
 xs = 4
 ys = 4
endif else begin
 xs = 1
 ys = 1
endelse 

a = [-32768, -32768]			; vecteur bidon pour afficher le cadre
pasx=(1.-2*cadre-1.5*marge)/(nx*bin_size(0))			; Pas en X 
pasy=(1.-2*cadre-1.5*marge)/(ny*bin_size(1))			; Pas en Y 
xr = [int_x(0)-marge/pasx, int_x(0)+0.5*marge/pasx+nx*bin_size(0)]
yr = [int_y(0)-marge/pasy, int_y(0)+0.5*marge/pasy+ny*bin_size(1)]
basex=	int_x(0)+indgen(nx+1)*bin_size(0)	; vecteur contenant les ticks du cadre en X
basey=	int_y(0)+indgen(ny+1)*bin_size(1)	; vecteur contenant les ticks du cadre en Y
xticks = nx
yticks = ny

!p.position = [cadre, cadre, 1-cadre, 1-cadre]
plot, a, xticks=xticks, yticks=yticks, xr=xr, $
	xtickv = basex, ytickv=basey,  yr=yr, $
	title=title, xstyle=xs, ystyle=ys

;---------------------------------------
; Affichage des fonctions de structure

spectre = fltarr(taille(3))
for i=0, nx-1 do begin
  if (i eq 0) then taille_cy = ycharsize else taille_cy = 1.e-10
  for j=0, ny-1 do begin
     if (j eq 0) then taille_cx = xcharsize else taille_cx = 1.e-10
     x = [int_x(0)+i*bin_size(0), int_x(0)+(i+1)*bin_size(0)-1]
     y = [int_y(0)+j*bin_size(1), int_y(0)+(j+1)*bin_size(1)-1]
     result = str(image(x(0):x(1),y(0):y(1)), lagmax, ordre=ordre, indef=indef)
     if not keyword_set(xrange) then xrange = [0.1, max(result(0,*))]
     !p.position = [i*pasx*bin_size(0)+cadre+marge, j*pasy*bin_size(1)+cadre+marge, $
	(i+1)*pasx*bin_size(0)+cadre+marge, (j+1)*pasy*bin_size(1)+cadre+marge]
     plot, result(0,*), result(1,*), /noerase, xr=xrange, yr=yrange, xstyle=1, ystyle=1, min_value=min_value, $
     xcharsize=taille_cx, ycharsize=taille_cy, xtitle=xtitle, ytitle=ytitle, /xlog, /ylog
    endfor
endfor   

if keyword_set(ps) then psout

!p.multi=0
!p.position = 0
end



