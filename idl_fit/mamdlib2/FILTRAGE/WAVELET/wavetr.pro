function ellipse_kernel, si_im, puissance_alpha, teta

xymap, si_im(1), si_im(2), xmap, ymap
xmap = xmap - fix(si_im(1)/2.)
ymap = ymap - fix(si_im(2)/2.)
mat_x=xmap*2.^puissance_alpha
mat_y=ymap*2.^puissance_alpha
x1=1d*((mat_x*cos(teta))+(mat_y*sin(teta)))
y1=1d*(-(mat_x*sin(teta))+(mat_y*cos(teta)))

;re=-(x1^2+y1^2)
;im=(!PI*x1)
;term=complex(1d*re,1d*im)
;noy=1d*exp(term)
;noy = noy*(1.-(x1^2))/cos(!pi*x1)

;----------------
re = (1-x1^2)*exp((-x1^2-y1^2)/2.)
im = sin(!pi*x1)*exp(-x1^2-y1^2)
noy = complex(1d*re, 1d*im)

;noy = noy*2*!pi^(-0.25)/sqrt(3.)

;noy = 2.^((puissance_alpha)/2.)*noy
noy = 2.^(2*(puissance_alpha))*noy

;noy = noy*2.^puissance_alpha
;noy = noy*sqrt(2.)^puissance_alpha

; noy = noy - 1d*!pi*exp(-!pi^2/4.)

;re = float(noy)
;im = imaginary(noy)
; re = re-avg(re)
;noy = complex(1d*re,1d*im)

; noy = 2^(1.*puissance_alpha/2.)*noy

;noy = float(noy)
;noy = noy-avg(noy)
norm = total(abs(noy))
;print, total(noy)
;print, norm
 noy = noy/norm

return, noy

end

function wavetr, image, angle=angle, scale=scale, verb=verb, a_axe=a, b_axe=b, $
                 coeff=coeff, seuil=seuil, maxangle=maxangle, mexican=mexican, noise=noise

;
;----------------------------------
;
; WAVETR
;
; Non-symetric 2D Wavelet Transform
;
; MAMD 24/03/99
;
;---------------------------------
;

if not keyword_set(scale) then scale=0
if not keyword_set(angle) then angle=0.
if not keyword_set(a) then a=1.
if not keyword_set(b) then b=1.

n_scale = n_elements(scale)
n_angle = n_elements(angle)

if keyword_set(mexican) then begin
    n_angle=1
    maxangle = 0
endif

if not keyword_set(seuil) then seuil=0
if n_elements(seuil) ne n_scale then seuil = replicate(seuil(0), n_scale)

si_im = size(image)

IF NOT keyword_set(noise) THEN BEGIN
   noise =  fltarr(si_im(1), si_im(2))
   noise(*,*) =  1.
endif
cube_out = fltarr(si_im(1), si_im(2), n_scale+1, n_angle)
coeff = fltarr(si_im(1), si_im(2), n_scale, n_angle)
maxangle = fltarr(si_im(1), si_im(2))
image0 = fltarr(si_im(1), si_im(2))

for i=0, n_angle-1 do begin
    for j=0, n_scale-1 do begin
        print, i, j
        if keyword_set(mexican) then noy = mexican2(si_im(1), si_im(2), 0., scale(j)) else $
          noy = ellipse_kernel(si_im, scale(j), angle(i))
;        noy = 2.3*(!pi/(1.*n_angle))*noy
;        noy = 2.5*(!pi/(1.*n_angle))*noy
;        noy = !pi*(!pi/(1.*n_angle))*noy
;        tvscl, noy
;        print, total(noy)
;        print, total(abs(noy))
        imfft = fft(image, -1)
        imfft = imfft*si_im(1)*si_im(2)
        noyfft = fft(conj(noy), -1)
        tempo = float(shift(fft(imfft*noyfft, 1), fix(si_im(1)/2.), fix(si_im(2)/2.)))
        tempo0 = tempo
        if keyword_set(seuil(j)) then begin
;            ind = where(abs(tempo) le seuil(j), nbind)
            ind = where(abs(tempo) le seuil(j)*noise, nbind)
            print, 100.*nbind/float(n_elements(tempo))
            if (nbind gt 0) then tempo(ind) = 0.
        endif
        coeff(*,*,j,i) = tempo
        imfft = fft(coeff(*,*,j,i), -1)
        imfft = imfft*si_im(1)*si_im(2)
        imfft0 = fft(tempo0, -1)
        imfft0 = imfft0*si_im(1)*si_im(2)
        noyfft2 = fft(noy, -1)
        if keyword_set(mexican) then begin 
            cube_out(*,*,j,i) = float(shift(fft(imfft*noyfft2, 1), fix(si_im(1)/2.), fix(si_im(2)/2.))) 
            image0 = image0 + float(shift(fft(imfft0*noyfft2, 1), fix(si_im(1)/2.), fix(si_im(2)/2.))) 
        endif else begin
            cube_out(*,*,j,i) = float(shift(fft(imfft*noyfft2, 1), fix(si_im(1)/2.), fix(si_im(2)/2.)))* 4./(1.*n_angle)
            image0 = image0 + float(shift(fft(imfft0*noyfft2, 1), fix(si_im(1)/2.), fix(si_im(2)/2.)))* 4./(1.*n_angle)
; le facteur 4 ajoute ici est arbitraire... L'ondelette utilisee est
; normalisee (total(abs(noy)) = 1.)
        endelse
    endfor
;    cube_out(*,*,n_scale,i) = image - total(cube_out(*,*,0:n_scale-1,i), 3)
    cube_out(*,*,n_scale,i) = image-image0
endfor


;---------------------------------------------------------------
; COMPUTE THE IMAGE WITH THE MAXIMUM FLUX AT EACH SCALE

if keyword_set(maxangle) and n_angle gt 1 then begin
    si_cube = size(cube_out)
    maxangle = fltarr(si_cube(1), si_cube(2))
    for k=0, si_cube(3)-1 do begin
        for j=0, si_cube(2)-1 do begin 
            for i=0, si_cube(1)-1 do begin 
;                vec = reform(coeff(i,j,k,*)) 
                vec = reform(cube_out(i,j,k,*)) 
                maxangle(i,j) = maxangle(i,j) + max(vec)
            endfor 
        endfor
    endfor
;        for j=0, si_cube(2)-1 do begin 
;            for i=0, si_cube(1)-1 do begin 
;                mat = reform(cube_out(i,j,*,*)) 
;                toto = max(mat, wmax) 
;                xy = indtopos(wmax, mat) 
;                maxangle(i,j) = total(mat(*,xy(1)))
;            endfor 
;        endfor
endif 


return, cube_out


end


