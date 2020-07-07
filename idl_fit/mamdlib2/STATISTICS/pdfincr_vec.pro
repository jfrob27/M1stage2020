pro pdfincr_vec, image, lag, vecpdf, erreur_out, $
                indef=indef, erreur_in=erreur_in

;------------------------------------------
; KEYWORDS

if not keyword_set(indef) then indef = -32768
if not keyword_set(erreur_in) then begin
    erreur_in = image
    erreur_in(*) = 0.
endif
erreur_out = [0.]
vecpdf = [0.]

si_image = size(image)
xymap, si_image(1), si_image(2), xmap, ymap

for j=lag, si_image(2)-lag do begin
    print, 1.*j/si_image(2)
    b1 = j-(lag+1)>0.
    b2 = j+(lag+1)<(si_image(2)-1)
    for i=lag, si_image(1)-lag do begin
        if (image(i,j) ne indef) then begin
            a1 = i-(lag+1)>0.
            a2 = i+(lag+1)<(si_image(1)-1)
;            simage = image((i-2*lag):(i+2*lag),(j-2*lag):(j+2*lag))
            simage = image(a1:a2,b1:b2)
            serreur = erreur_in(a1:a2,b1:b2)
            sxmap = xmap(a1:a2,b1:b2)
            symap = ymap(a1:a2,b1:b2)
            distance = sqrt((sxmap-i)^2+(symap-j)^2)
            indice = where((distance ge lag-0.5) and (distance lt lag+0.5) and $
                         (simage ne indef), nbindice)
            if (nbindice gt 0) then begin
                vecpdf = [simage(indice)-image(i,j), vecpdf]
                erreur_out = [sqrt( (serreur(indice))^2 + (erreur_in(i,j))^2 ), erreur_out]
            endif
      endif
  endfor
endfor

vecpdf = vecpdf(1:*)
erreur_out = erreur_out(1:*)

end



