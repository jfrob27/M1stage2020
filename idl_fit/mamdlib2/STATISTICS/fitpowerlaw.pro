;-----------------
function powlaw_mpfit, a, XVAL=x, YVAL=y, ERRVAL=err

if not keyword_set(err) then begin
    err = x
    err(*) = 1.
endif

model = a[0]*x^a[1]
res = (y-model)/err

return, res

end

;----------------------------------------
function fitpowerlaw, xval, data, aguess, errordata=errordata, verbose=verbose, fixed=fixed, perror=perror

if not keyword_set(errordata) then errordata = replicate(1, n_elements(data))
if keyword_set(verbose) then quiet=0 else quiet=1

if not keyword_set(aguess) then aguess=[1., 1.]
if not keyword_set(fixed) then fixed= intarr(n_elements(aguess))

parinfo = {value:aguess, $
           fixed:fixed, $
           limited:[[1,0], [0,0]], $
           limits:[[0,0], [0,0]], $
           step:[0,0]}

functargs = {XVAL:xval, YVAL:data, ERRVAL:errordata}

fname='powlaw_mpfit'

aguess = mpfit(fname, functargs=functargs, parinfo=parinfo, quiet=quiet, perror=perror, status=status, errmsg=errmsg) 

if (status le 0.) then print, 'status:', status, ' : ', errmsg

return, aguess

end
