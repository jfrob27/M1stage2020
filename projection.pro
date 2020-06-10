pro projection

im = readfits("",header)

ratio = 0.00388889/0.00083333333333333

hdproj = header

;Change pixel resolution
crpix1 = sxpar( header, 'CRPIX1' )
crpix2 = sxpar( header, 'CRPIX2' )
naxis1 = sxpar( header, 'NAXIS1' )
naxis2 = sxpar( header, 'NAXIS2' )

sxaddpar,hdproj,'CDELT1',-0.00388889
sxaddpar,hdproj,'CDELT2',0.00388889
sxaddpar,hdproj,'CRPIX1',crpix1/ratio
sxaddpar,hdproj,'CRPIX2',crpix2/ratio
sxaddpar,hdproj,'NAXIS1',fix(naxis1/ratio)
sxaddpar,hdproj,'NAXIS1',fix(naxis2/ratio)

;Rotate the map
sxaddpar,hdproj,'CROTA1',40
sxaddpar,hdproj,'CROTA2',40

;Reprojection
improj = mproj(im,header,hdproj)

;Write files
writefits,"",improj,hdproj

END