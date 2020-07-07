function regress_iter, x, y, nbiter, const=oao, thresh=thresh, sigma=sigma, _Extra=extra

  if not keyword_set(thresh) then thresh=3
  if not keyword_set(nbiter) then nbiter=1
  sim = size(x)
  nbsample = n_elements(y)
  if (sim[0] eq 1) then begin
     nb_dimx = 1 
     x_use = fltarr(1,nbsample)
     x_use[0,*] = x
  endif else begin
     nb_dimx = sim[1]
     x_use = x
  endelse

  ind = lindgen(nbsample)
  result = regress(x_use[*,ind], y[ind], const=oao, sigma=sigma, _Extra=extra)
  for i=0, nbiter-1 do begin
     diff = y
     for j=0, nb_dimx-1 do diff = diff-result[j]*reform(x_use[j,*])
     diff = diff-oao
     stat = statmamd(diff, 5)
     med = median(diff)
     sigval = sqrt(stat(1))
     ind = where(abs(diff-med) lt thresh*sigval, nbind)
;     stop
     result = regress(x_use[*,ind], y[ind], const=oao, sigma=sigma, _Extra=extra)
  endfor

return, result

end

