function hdrnewres, hin, newcdelt

hout = hin

cdelt1 = sxpar(hin, 'CDELT1')

factor = abs(cdelt1)/abs(newcdelt)
cdelt1 = sxpar(hin, 'CDELT1')/factor
cdelt2 = sxpar(hin, 'CDELT2')/factor

crpix1 = sxpar(hin, 'CRPIX1')*factor
crpix2 = sxpar(hin, 'CRPIX2')*factor

naxis1 = sxpar(hin, 'NAXIS1')*factor
naxis2 = sxpar(hin, 'NAXIS2')*factor

sxaddpar, hout, 'CDELT1', cdelt1
sxaddpar, hout, 'CDELT2', cdelt2
sxaddpar, hout, 'CRPIX1', crpix1
sxaddpar, hout, 'CRPIX2', crpix2
sxaddpar, hout, 'NAXIS1', fix(naxis1)
sxaddpar, hout, 'NAXIS2', fix(naxis2)

return, hout

end
