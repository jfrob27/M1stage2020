pro pdfincr, image, lag, histo, stat, xminmax=Xminmax, indef=indef,  bin=bin, vecfin=vecfin, $
             err_in=err_in, err_out=err_out

;----------------------------------------------------------
;
; PDFINCR.PRO
;
; Calcule le PDF des differences de vitesse
; des points separes par un lag +/- 0.5 pixel.
;
; L'affichage s'effectue avec le programme pdf.pro
; avec le keyowrd /incr
;
; CALLING SEQUENCE:
;   pdfincr, image, lag, histo, stat
;
; INPUTS:
;  image: champ de vitesse 2D de dimension quelconque
;  lag: separation entre les pixels
;  
; OUTPUTS:
;  histo: le vecteur histogramme (utilise entre autre par pdf.pro)
;  stat: les moments de la distribution (utilise par pdf.pro)
;
; KEYWORDS:
;
;	bin:		Valeur du bin de histogram. bin=0.2 par defaut.
;
;
;	indef:		Valeur des points indefinis du champ de vitesse.
;			indef=-999 par defaut.
;
;	Xminmax:	Valeur minimale et maximale consideree par
;			histogram.
;
;
; MAMD 6/11/97
;
;------------------------------------------

;------------------------------------------
; KEYWORDS

if not keyword_set(indef) then indef = -32768
noindef = where(image ne indef)
if not keyword_set(Xminmax) then $ 
	xminmax = [min(image(noindef))-max(image(noindef)),max(image(noindef))-min(image(noindef))]
if not keyword_set(bin) then bin=1.

;----------------------------------------

taille = size(image)

vecfin = [0]
err_out = [0]
X = fltarr(taille(1), 2*taille(2))
for i=0, 2*taille(2)-1 do X(*,i) = findgen(taille(1))
Y = fltarr(taille(1), 2*taille(2))
for i=0, taille(1)-1 do Y(i,*) = findgen(2*taille(2))-taille(2)
distance = sqrt(X^2 + Y^2)

indice = where((distance ge lag-0.5) and (distance lt lag+0.5))
if (indice(0) ne -1) then begin
  ou = 0.
  for k=0, N_ELEMENTS(indice)-1 do begin
	i = X(indice(k))
	j = Y(indice(k))
	if (j ge 0) then begin
		jval1 = [j, taille(2)-1] 
		jval2 = [0, taille(2)-1-j]
	endif else begin 
		jval1 = [0, taille(2)-1+j]
		jval2 = [-j, taille(2)-1]
	endelse
	im1 = image(i:*,jval1(0):jval1(1))
	im2 = image(0:(taille(1)-1-i),jval2(0):jval2(1))
	ind = where(im1 ne indef and im2 ne indef, nbpoint)
	diff = im1(ind)-im2(ind)
        nonnul = where(diff ne 0., nb_nonnul)
        if (nb_nonnul gt 0) then begin
            vecfin = [vecfin, diff(nonnul)]
            if keyword_set(err_in) then begin
                er1 = err_in(i:*,jval1(0):jval1(1))
                er2 = err_in(0:(taille(1)-1-i),jval2(0):jval2(1))
                er1 = er1(ind)
                er2 = er2(ind)
                err_out = [err_out, sqrt(er1(nonnul)^2 + er2(nonnul)^2)]
            endif
    endif
  endfor
endif

histo = histogram(vecfin, min=xminmax(0), max=xminmax(1), binsize=bin)
stat = moment(1.d*vecfin)

end



