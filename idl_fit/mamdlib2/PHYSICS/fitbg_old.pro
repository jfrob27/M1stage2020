function bg, x, a

E_bg = a[0]
T_bg = a[1]
beta = a[2]

model = 1.e20*E_bg*x^(-1*Beta)*bnu_planck(x, T_bg)

if (n_elements(a) gt 3) then begin
   gamma = a[3]
   xref = 3.e5/545.    ; reference wavelength
   ind = where(x gt xref, nbind)
   model_ref = interpol(model, x, xref)
   model[ind] = model_ref[0]*(x[ind]/xref)^(-1.*gamma)
endif


return, model

end

;-----------------
function bg_mpfit, a, XVAL=x, YVAL=y, ERRVAL=err

if not keyword_set(err) then begin
    err = x
    err(*) = 1.
endif

model = bg(x, a)
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
res = (alog(y)-alog(model))/err

return, res

end

;----------------------------------------
function fitbg, lambda, data, aguess, errordata=errordata, verbose=verbose, $
                fixed=fixed, perror=perror, log=log, powerlaw=powerlaw

if not keyword_set(aguess) then begin
   if keyword_set(powerlaw) then aguess=[1., 17.5, 2., 2.] else aguess=[1., 17.5, 2.]
endif
if not keyword_set(errordata) then errordata = replicate(1, n_elements(data))
if keyword_set(verbose) then quiet=0 else quiet=1
if not keyword_set(fixed) then fixed= intarr(n_elements(aguess))

if keyword_set(powerlaw) then begin
   parinfo = {value:aguess, $
              fixed:fixed, $
              limited:[[1,0], [1,1], [1,1], [1,1]], $
              limits:[[0,0], [0,200], [0,5], [0,5]], $
              step:[0,0,0,0]}
endif else begin
   parinfo = {value:aguess, $
              fixed:fixed, $
              limited:[[1,0], [1,1], [1,1]], $
              limits:[[0,0], [0,200], [0,5]], $
              step:[0,0,0]}
endelse
functargs = {XVAL:lambda, YVAL:data, ERRVAL:errordata}

if keyword_set(log) then fname = 'bg_log_mpfit' else fname='bg_mpfit'
aguess = mpfit(fname, functargs=functargs, parinfo=parinfo, quiet=quiet, perror=perror, status=status, errmsg=errmsg) 

if (status le 0.) then print, 'status:', status, ' : ', errmsg
;model = bg(lambda, aguess)

return, aguess

end
