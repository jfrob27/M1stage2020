;-----------------
function pk_mpfit, a, XVAL=x, YVAL=y, ERRVAL=err

if not keyword_set(err) then begin
    err = x
    err(*) = 1.
endif

psf_gauss = exp(-x^2/(2*a[2]^2))
psf_gauss = psf_gauss/max(psf_gauss)
model = psf_gauss*a[0]*x^a[1] + a[3]
res = ( alog(y) - alog(model) )/err

return, res

end

;----------------------------------------
function fitpk, xval, data, aguess, errordata=errordata, verbose=verbose, fixed=fixed, perror=perror, fwhmrange=fwhmrange

if keyword_set(fwhmrange) then psfkrange = 1./(fwhmrange/2.354*2*!pi*sqrt(2.)) $
   else psfkrange=[0.,1.]

psfkrange = minmax(psfkrange)
psfkmid = total(psfkrange)/2.
if not keyword_set(errordata) then errordata = replicate(1, n_elements(data))
if keyword_set(verbose) then quiet=0 else quiet=1

psfkmid = 0.03
if not keyword_set(aguess) then aguess=[1., -3., psfkmid, 1.]
if not keyword_set(fixed) then fixed= intarr(n_elements(aguess))

parinfo = {value:aguess, $
           fixed:fixed, $
;           limited:[[1,0], [1,1], [1,1], [1,0]], $
;           limits:[[0.,0.], [-10.,0.], psfkrange, [0.,0.]], $
           limited:[[1,0], [1,1], [1,1], [1,0]], $
           limits:[[0.,0.], [-10.,0.], [0,1], [0.,0.]], $
           step:[0,0,0,0]}

functargs = {XVAL:xval, YVAL:data, ERRVAL:errordata}

fname='pk_mpfit'

aguess = mpfit(fname, functargs=functargs, parinfo=parinfo, quiet=quiet, perror=perror, status=status, errmsg=errmsg) 

if (status le 0.) then print, 'status:', status, ' : ', errmsg

return, aguess

end
