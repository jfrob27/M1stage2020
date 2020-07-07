function cropheader, hin, pixels

; modify header for a subregion

hout = hin

n1 = fix(pixels[2]-pixels[0]+1)
n2 = fix(pixels[3]-pixels[1]+1)

crpix1 = sxpar(hin, 'CRPIX1')-pixels[0]
crpix2 = sxpar(hin, 'CRPIX2')-pixels[1]

sxaddpar, hout, 'CRPIX1', crpix1
sxaddpar, hout, 'CRPIX2', crpix2
sxaddpar, hout, 'NAXIS1', n1
sxaddpar, hout, 'NAXIS2', n2

return, hout

end
