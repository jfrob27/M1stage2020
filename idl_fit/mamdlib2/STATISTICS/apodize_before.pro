FUNCTION apodize, na, R

IF (R GE 1.) THEN R =  0.9999
IF (R LT 0.) THEN R =  0.

;nx =  fix(R*na/2.)
;x =  findgen(nx)/(nx-1.)*!pi / 2.
;tap1d =  fltarr(na)
;tap1d(*) =  1.
;tap1d(na-nx:*) =  cos(x)
;tap1d(0:nx-1) =  rotate(cos(x), 3)
;        tapper=FLTARR(na, na)
;        FOR i=0, na-1 DO tapper(*,i) =tap1d
;        FOR i=0, na-1 DO tapper(i,*) =tapper(i,*)*tap1d
;tapper =  tapper > 0.
;
;return, tapper

radius =  na/2.*R
rmap =  shift(dist(na, na), fix(na/2.), fix(na/2.))
ind =  where(rmap LE radius)
rmap(ind) =  0.
ind =  where(rmap GE radius)
rmap(ind) =  (rmap(ind)-radius)
rmap =  rmap * !pi / 2. / max(rmap)

result =  cos(rmap)

return, result

END


