;-----------------
function bg_mpfit, a, XVAL=x, YVAL=y, ERRVAL=err, CCMAPS=CCMAPS, BETAVEC=BETAVEC, TDVEC=TDVEC, REFLAMBDA=REFLAMBDA

if not keyword_set(err) then begin
    err = x
    err(*) = 1.
endif

model = bg(x, a, tdvec=tdvec, betavec=betavec, ccmaps=ccmaps, reflambda=reflambda)

res = (y-model)/err

return, res

end

;-----------------
function bg_log_mpfit, a, XVAL=x, YVAL=y, ERRVAL=err

if not keyword_set(err) then begin
    err = x
    err(*) = 1.
endif

model = bg(x, a)
res = (alog(y)-alog(model))/alog(err)

return, res

end

;----------------------------------------
function fitbg, lambda, data, aguess, errordata=errordata, verbose=verbose, $
                fixed=fixed, perror=perror, log=log, twobeta=twobeta, chi2=chi2, $
                CCMAPS=CCMAPS, BETAVEC=BETAVEC, TDVEC=TDVEC, status=status, model=model, $
                bestnorm=bestnorm, twombb=twombb, reflambda=reflambda

  if not keyword_set(errordata) then errordata = replicate(1, n_elements(data))
  if keyword_set(verbose) then quiet=0 else quiet=1

  ; colour correction keywords
  if not keyword_set(CCMAPS) then CCMAPS=''
  if not keyword_set(BETAVEC) then BETAVEC=''
  if not keyword_set(TDVEC) then TDVEC=''

  if not keyword_set(REFLAMBDA) then REFLAMBDA=1.

  if not keyword_set(aguess) then begin
     aguess = [1., 17.5, 2.]
     if keyword_set(twobeta) then aguess = [1., 17.5, 2., 550., 2.]
     if keyword_set(twombb) then aguess = [1., 17.5, 2., 0., 17.5, 2.]
  endif
  if not keyword_set(fixed) then fixed= intarr(n_elements(aguess))

  if keyword_set(log) then fname = 'bg_log_mpfit' else fname = 'bg_mpfit'

  if keyword_set(betavec) then beta_range = minmax(betavec) else beta_range = [0.5, 5.0]
  if keyword_set(tdvec) then td_range = minmax(tdvec) else td_range = [5., 200.]

  parinfo = {value:aguess, $
             fixed:fixed, $
             limited:[[1,0], [1,1], [1,1]], $
             limits:[[0,0], [td_range], [beta_range]], $
             step:[0.01,0.01,0.01]}
  if keyword_set(twobeta) then $
     parinfo = {value:aguess, $
                fixed:fixed, $
                limited:[[1,0], [1,1], [1,1], [1,1], [1,1]], $
                limits:[[0,0.], [td_range], [beta_range], [300,max(lambda)], [beta_range]], $
                step:[0.01,0.01,0.01,0.01,0.01]}
  if keyword_set(twombb) then $
     parinfo = {value:aguess, $
                fixed:fixed, $
                limited:[[1,0], [1,1], [1,1], [0., 1.e-2], [1,1], [1,1]], $
                limits:[[0,0.], [td_range], [beta_range], [1,1], [td_range], [beta_range]], $
                step:[0.01,0.01,0.01,0.01,0.01,0.01]}

  functargs = {XVAL:lambda, YVAL:data, ERRVAL:errordata, CCMAPS:CCMAPS, BETAVEC:BETAVEC, TDVEC:TDVEC, REFLAMBDA:REFLAMBDA}
  result = mpfit(fname, functargs=functargs, parinfo=parinfo, quiet=quiet, perror=perror, status=status, $
                 errmsg=errmsg, FTOL=1e-20, XTOL=1e-10, bestnorm=bestnorm) 
  if (status le 0.) then print, 'status:', status, ' : ', errmsg

  model = bg(lambda, result, tdvec=tdvec, betavec=betavec, ccmaps=ccmaps, reflambda=reflambda)

  rien = where(fixed eq 0, nbparam)
  nbfree = n_elements(data) - nbparam
  chi2 = total( (data-model)^2 / errordata^2 ) / nbfree

  return, result

end
