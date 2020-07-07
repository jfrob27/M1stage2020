;


-rw-r--r-- 1 tghosh ias 201335040 Apr 25 10:46 co10_type1_gnilc.fits
-rw-r--r-- 1 tghosh ias 201335040 Apr 25 10:46 co21_type1_gnilc.fits
-rw-r--r-- 1 tghosh ias 201335040 Apr 25 10:46 co32_type1_gnilc.fits

dir = '/data/glx-mistic/data1/tghosh/DX11c/fg_templates'
read_fits_map, dir+'/co10_type1_gnilc.fits', co
read_fits_map, dir+'/co10_type1_gnilc_withDame.fits', co
ORDER='RING'
co_resolution = 9.65  ; arcmin
common_res = 15.  ; arcmin
fwhm2 = (common_res^2 - co_resolution^2)
ismoothing, co, co_15, fwhm_arcmin=sqrt(fwhm2), ordering=order
