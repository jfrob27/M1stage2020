;---------------------------------------
; IMAGE RANDOM DISTRIBUTION NORMALE
;
; moyenne = 0.
; variance = 1.0
;
;

image_n = randomn(seed,100,100)
result_n = fstat1d(image_n, 10)

window, 0, retain=2
!p.multi = [0,2,2]
x = findgen(81)*0.1-4.
plot, x, histogram(image_n, bin=0.1, min=-4, max=4), xtitle='Intensite', ytitle='Nombre', $
	title='Champ aleatoire - distribution normale'
plot, result_n(3,*), result_n(0,*), xtitle='Lag (pixel)', ytitle='ACR', $
	title='Fonction d''autocorrelation', yr=[-0.1,0.1]
plot, result_n(3,*), result_n(1,*), xtitle='Lag (pixel)', ytitle='STR', $
	title='Fonction de structure', yr=[1.8,2.2]
plot, result_n(3,*), result_n(2,*), xtitle='Lag (pixel)', ytitle='Nombre de point', $
	title='Nombre de point'

;--------------------------------------
; IMAGE RANDOM DISTRIBUTION UNIFORME
;
; nombre aleatoire entre 0 et 1
;

image_u = randomu(seed,100,100)
result_u = fstat1d(image_u, 10)

window, 0, retain=2
!p.multi = [0,2,2]
x = findgen(101)*0.01
plot, x, histogram(image_u, bin=0.01, min=0, max=1), xtitle='Intensite', ytitle='Nombre', $
	title='Champ aleatoire - distribution uniforme'
plot, result_u(3,*), result_u(0,*), xtitle='Lag (pixel)', ytitle='ACR', $
	title='Fonction d''autocorrelation', yr=[-0.1,0.1]
plot, result_u(3,*), result_u(1,*), xtitle='Lag (pixel)', ytitle='STR', $
	title='Fonction de structure', yr=[0.15,0.18]
plot, result_u(3,*), result_u(2,*), xtitle='Lag (pixel)', ytitle='Nombre de point', $
	title='Nombre de point'

save, file='random_field.idl'


;------------------------------------------
; GRADIENT ET BRUIT (DISTRIBUTION NORMALE)
;
; nombre aleatoire entre 0 et 1
;

a = 3.
b = 3.
image_gn = fltarr(100,100)
for i=0, 99 do begin & $
  for j=0, 99 do begin & $
    image_gn(i,j) = 1-((i-20.)/100.)^2/a^2 - ((j-20.)/100.)^2/b^2 & $
  endfor & $
endfor 
image_gn = image_gn+image_n/10.+sqrt(image_gn)

result_gn = fstat1d(image_gn, 20)

window, 0, retain=2
!p.multi = [0,2,2]
x = findgen(101)*0.01
plot, x, histogram(image_gn, bin=0.01, min=1.4, max=2.4), xtitle='Intensite', ytitle='Nombre', $
	title='Gradient et bruit normal'
plot, result_gn(3,*), result_gn(0,*), xtitle='Lag (pixel)', ytitle='ACR', $
	title='Fonction d''autocorrelation', yr=[0,0.2]
plot, result_gn(3,*), result_gn(1,*), xtitle='Lag (pixel)', ytitle='STR', $
	title='Fonction de structure'
plot, result_gn(3,*), result_gn(2,*), xtitle='Lag (pixel)', ytitle='Nombre de point', $
	title='Nombre de point'

openw, 1, 'gradient.txt'
for i=0, 99 do begin & $
  for j=0, 99 do begin & $
	printf, 1, i, j, image_gn(i,j) & $
  endfor & $
endfor
close, 1

;---------------------------------
; PROGRAM C

openf, 'gradient_result.txt', 4, 9,result_c
openf, 'gradient_result2.txt', 4,64,result_c2

 


;------------------------------------
; POWER SPECTRUM KOLMOGOROV



