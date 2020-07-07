pro pdfincr_im, image, lag, imagemoy, imagemax, erreur_out, $
                indef=indef, erreur_in=erreur_in, imagemed=imagemed

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
if not keyword_set(erreur_in) then begin
    erreur_in = image
    erreur_in(*) = 0.
endif
erreur_out = erreur_in

imagemoy = image
imagemoy(*,*) = indef
imagemax = image
imagemax(*,*) = indef
imagemed = imagemax

si_image = size(image)
;distance = fltarr(si_image(1), si_image(2))
;xymap, si_image(1), si_image(2), xmap, ymap

;distance = fltarr(4*lag+1, 4*lag+1)
xymap, si_image(1), si_image(2), xmap, ymap
;xymap, 4*lag+1, 4*lag+1, xmap, ymap
;distance = sqrt((xmap-2*lag)^2+(ymap-2*lag)^2)

;for j=lag, si_image(2)-lag do begin
for j=0, si_image(2)-1 do begin
    print, 1.*j/si_image(2)
    b1 = j-(lag+1)>0.
    b2 = j+(lag+1)<(si_image(2)-1)
;    for i=lag, si_image(1)-lag do begin
    for i=0, si_image(1)-1 do begin
        if (image(i,j) ne indef) then begin
            a1 = i-(lag+1)>0.
            a2 = i+(lag+1)<(si_image(1)-1)
            simage = image(a1:a2,b1:b2)
            serreur = erreur_in(a1:a2,b1:b2)
            sxmap = xmap(a1:a2,b1:b2)
            symap = ymap(a1:a2,b1:b2)
            distance = sqrt((sxmap-i)^2+(symap-j)^2)
            indice = where((distance ge lag-0.5) and (distance lt lag+0.5) and $
                         (simage ne indef), nbindice)
            if (nbindice gt 0) then begin
                imagemoy(i,j) = total(abs(simage(indice)-image(i,j)))/(1.*nbindice)
;                imagemoy(i,j) = total((simage(indice)-image(i,j)))/(1.*nbindice)
                imagemed(i,j) = median(abs(simage(indice)-image(i,j)))
                erreur_out(i,j) = sqrt( total( (serreur(indice))^2 )/(1.*nbindice) + (erreur_in(i,j))^2 )
                imagemax(i,j) = max(abs(simage(indice)-image(i,j)))
            endif
      endif
  endfor
endfor

end



