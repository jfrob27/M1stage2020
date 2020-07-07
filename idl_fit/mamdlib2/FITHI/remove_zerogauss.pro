pro remove_zerogauss, result

si = size(result)
nbgauss = si(3)/3.
sigvec = findgen(nbgauss)*3+2
centvec = findgen(nbgauss)*3+1
ampvec = findgen(nbgauss)*3
allsig = result(*,*,sigvec)
allcent = result(*,*,centvec)
allamp = result(*,*,ampvec)

ind = where(allamp eq 0, nbzero)
print, 'removing ' + strc(nbzero) + ' Gaussian'
if (nbzero gt 0) then begin
   allamp(ind) = -32768.
   allsig(ind) = -32768.
   allcent(ind) = -32768.
   result(*,*,ampvec) = allamp
   result(*,*,centvec) = allcent
   result(*,*,sigvec) = allsig
endif

end
