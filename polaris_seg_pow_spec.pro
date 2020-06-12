pro polaris_seg_pow_spec


;Read map

im = readfits("/user/workdir/robitaij/fil2star/Herschel/Gould_Belt/HGBS_polaris_cdens_rot_rebin_cut.fits",hd)
reso = sxpar( hd, 'CDELT2' ) *60.

im = find_nan(im)

N = size(im)
na = N[1]
nb = N[2]
print, na, nb

na2 = 950.
nb2 = 950.

tapper = APODIZE(na, nb, 0.97)
im = (im - mean(im))/1e21
im = im * tapper

ralonge,im,imr,na2,nb2,hd

powspec_k_nosquare,imr,reso,tab_k,spec_k

;Create beam
xymap, na, nb, x2, y2
x2 = (x2-fix(na/2.))
y2 = (y2-fix(nb/2.))

mapxy=sqrt(x2^2.+y2^2.)
x2=0.
y2=0.

FWHM = 36.9 / (60.*reso)  ;Beam size at 500 micron
sigma_b = FWHM / (2.*sqrt(2.*alog(2.)))
beam = (1./(2*!pi*(sigma_b)^2))*EXP(-(mapxy)^2/(2*(sigma_b)^2))

ralonge_hdless,beam,beamr,na2,nb2

powspec_k_nosquare,beamr,reso,tab_kb,spec_kb

spec_kb=spec_kb/spec_kb[0]

;Noise
;cdelt = sxpar( hd, 'CDELT2' )
;spec_k = spec_k*(cdelt^2/3.2828e3)*1.e12

Noise = 0.00021203637021067012

;Correct spec_k

;spec_kc = (spec_k-Noise) / spec_kb
spec_kc = (spec_k-Noise) / spec_kb

;Segmentation
wav_k = [0.00451128, 0.00599476, 0.00796607, 0.01058563, 0.0140666, 0.01869225, 0.02483899, 0.03300702, 0.04386101, 0.05828423, 0.07745036, 0.10291907, 0.13676289, 0.18173587, 0.24149773, 0.32091163, 0.42643992, 0.56667004, 0.75301331, 1.00063353, 1.32968095, 1.76693204, 2.34796838, 3.12007219]

Gaussian = [1.10798511e+03, 4.77231193e+02, 2.54495425e+02, 1.84240017e+02, 1.07238011e+02, 1.18717178e+01, 1.42185831e+01, 3.77836954e+00, 1.92510854e+00, 6.29624990e-01, 3.74125218e-01, 1.63147653e-01, 6.18380245e-02, 2.51021443e-02, 1.29541669e-02, 8.46646281e-03, 5.65634973e-03, 5.42786961e-03, 4.64374558e-03, 4.93187843e-03, 4.85884777e-03, -2.56869327e-02, -2.91888555e+00, -2.28733949e+02]

coherent = [0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 1.46437697e+01, 8.14267484e+00, 1.67018417e+01, 9.03247413e+00, 3.69670993e+00, 1.69756011e+00, 9.91035207e-01, 5.23250114e-01, 2.83386368e-01, 1.44541968e-01, 7.23481793e-02, 3.47847812e-02, 1.57447498e-02, 8.10861307e-03, 5.29804560e-03, 6.41415457e-03, 2.56869327e-02, 2.36755195e-01, 1.27949215e+00]

;Fit Gaussian wavelet spectrum
x2 = alog(wav_k[10:15])
y2 = alog(Gaussian[10:15])

junk = reglin(x2 ,y2, coeff=res, dcoeff=dres)

A=[exp(res[0]),res[1],exp(res[0])]
moments = moment(Gaussian)
weights = 1.0/(Gaussian/sqrt(moments[1]))^2

curve_w = CURVEFIT(wav_k[7:19], Gaussian[7:19], weights[7:19], A, sigma, CHISQ=chisq, fita=[1,1,1], FUNCTION_NAME='power_law',itmax=1000)

Wpow_gauss = A[0]*wav_k^(A[1])+A[2]

print, "A = ", A
print,'Sigma :',sigma*sqrt(chisq)

;Fit coherent wavelet spectrum
x2 = alog(wav_k[10:15])
y2 = alog(coherent[10:15])

junk = reglin(x2 ,y2, coeff=res, dcoeff=dres)

A=[exp(res[0]),res[1],exp(res[0])]
moments = moment(coherent)
weights = 1.0/(coherent/sqrt(moments[1]))^2

curve_w = CURVEFIT(wav_k[7:19], coherent[7:19], weights[7:19], A, sigma, CHISQ=chisq, fita=[1,1,1], FUNCTION_NAME='power_law',itmax=1000)

Wpow_cohe = A[0]*wav_k^(A[1])+A[2]

print, "A = ", A
print,'Sigma :',sigma*sqrt(chisq)

;Plot spec_k

load_color_vp
window,0
plot,tab_k,spec_kc,/xlog,/ylog,yrange=[1e-3,2e3]
oplot, wav_k, Gaussian, psym = 4, color=2
oplot, wav_k, coherent, psym = 4, color=4
oplot, wav_k, Wpow_gauss, linestyle= 1, color=2
oplot, wav_k, Wpow_cohe, linestyle= 1, color=2

END
