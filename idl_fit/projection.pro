pro projection

im = readfits("/user/workdir/albouyg/HOBYS/monr2/monr2_coldens_cf_r500_medsmo3.fits",header)

ratio = 0.00388889/0.00083333333333333

hdproj = header

;Change pixel resolution
crpix1 = sxpar( header, 'CRPIX1' )
crpix2 = sxpar( header, 'CRPIX2' )
naxis1 = sxpar( header, 'NAXIS1' )
naxis2 = sxpar( header, 'NAXIS2' )
cd1_1 = sxpar( header, 'CD1_1')
cd1_2 = sxpar( header, 'CD1_2')
cd2_1 = sxpar( header, 'CD2_1')
cd2_2 = sxpar( header, 'CD2_2')

sxaddpar,hdproj,'CDELT1',-0.00388889
sxaddpar,hdproj,'CDELT2',0.00388889
sxaddpar,hdproj,'CRPIX1',crpix1/ratio
sxaddpar,hdproj,'CRPIX2',crpix2/ratio
sxaddpar,hdproj,'NAXIS1',fix(naxis1/ratio)
sxaddpar,hdproj,'NAXIS2',fix(naxis2/ratio)
sxaddpar,hdproj,'CD1_1',cd1_1*ratio
sxaddpar,hdproj,'CD1_2',cd1_2*ratio
sxaddpar,hdproj,'CD2_1',cd2_1*ratio
sxaddpar,hdproj,'CD2_2',cd2_2*ratio

;Rotate the map
sxaddpar,hdproj,'CROTA1',323.1808
sxaddpar,hdproj,'CROTA2',323.1808

;Reprojection
improj = mproj(im,header,hdproj)

;Write files
writefits,"/user/workdir/albouyg/HOBYS/dr21/dr21_coldens_cf_r500_medsmo3_rebin_rot.fits",improj,hdproj

END