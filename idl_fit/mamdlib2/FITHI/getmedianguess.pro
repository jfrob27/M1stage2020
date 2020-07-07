pro getmedianguess, result, perror, chi2, guess, limits, chi2max=chi2max, $
                    damplitude=damplitude, dcentroid=dcentroid, dsigma=dsigma

; estime le guess median a partir des valeurs qui ont
; un chi2 < chi2max.
;
; La routine calcule aussi les limits pour chaque parametres
; a partir de l'incertitude si elle est superieure aux marges
; donnees par damplitude, dcentroid et dsigma.
;
; MAMD, 20/12/2007

sires = size(result)
nbparam = sires(3)
guess = fltarr(nbparam)
errguess = fltarr(nbparam)
limits = fltarr(2, nbparam)

if not keyword_set(chi2max) then chi2max = 1.e6
ind = where(chi2 lt chi2max and chi2 ne 32768., nbind)
if (nbind eq 0) then ind = where(chi2 eq min(chi2))
; gerer le cas de nbind = 0

for i=0, nbparam-1 do begin
   tres = result(*,*,i)
   terr = perror(*,*,i)
   guess(i) = median(tres(ind))
   comp = i mod 3
   case comp of
      0: errguess(i) = median(terr(ind)) > guess(i)*(damplitude-1.)
      1: errguess(i) = median(terr(ind)) > dcentroid
      2: errguess(i) = median(terr(ind)) > guess(i)*(dsigma-1.)
   endcase
endfor

limits(0,*) = guess-errguess
limits(1,*) = guess+errguess


end




