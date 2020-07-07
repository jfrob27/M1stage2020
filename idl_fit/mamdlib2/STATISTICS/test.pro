lag_max=30
ccr2d, m1, m1, lag_max, result

result = result/(stdev(m1)*stdev(m2))
r = shift(dist(2*lag_max+1, 2*lag_max+1),lag_max, lag_max)

m = fltarr(lag_max)
l = findgen(lag_max)
for i=0, lag_max-1 do begin & $
  ind = where(r ge l(i)-0.5 and r lt l(i)+0.5, nbind) & $
  if (nbind gt 0) then m(i) = avg(result(ind)) & $
endfor


; URSA
restore, '/home/mamd/idl/ursa/cube_mexican3.idl'
ntot  = la_tot(cube_wave, dim=-1)
ccr2d, ntot, ntot, 50, result
result = result/(la_sigma(ntot))^2

V=19.364
dv=-0.412
vitesse = findgen(64)*dv + V
vdrao = fltarr(450, 310)
for j=0, 309 do begin & $
  print, j & $
  for i=0, 449 do begin & $
  vev = reform(cube_wave(i,j,*)) & $
  ind = where(vev ne -32768, nbind) & $
  if nbind gt 0 then begin & $
  vev = vev-la_median(vev(0:10)) & $
  vdrao(i,j) = total(vitesse(ind)*vev(ind))/total(vev(ind)) & $
  endif & $
  endfor & $
endfor
vdrao(where(vdrao le 0. or vdrao gt 10.)) = -32768.

lag_max = 100
ccr2d, ntot, vdrao, lag_max, resultv
resultv = resultv/(la_sigma(ntot) * la_sigma(vdrao))




r = shift(dist(2*lag_max+1, 2*lag_max+1),lag_max, lag_max)
mv = fltarr(lag_max)
l = findgen(lag_max)
for i=0, lag_max-1 do begin & $
  ind = where(r ge l(i)-0.5 and r lt l(i)+0.5, nbind) & $
  if (nbind gt 0) then mv(i) = avg(resultv(ind)) & $
  endfor
ps, xsize=14, ysize=14, file='/home/mamd/idl/ursa/ccr_n_v.ps'
plot, l, mv, xtitle='!9t!3 (pixels)', ytitle='C(!9t!3)', charsize=1.4
psout
$ghostview ccr_n_v.ps

