;-----------------
function multivarlinear, a, XVAL=x, YVAL=y, ERRVAL=err

if not keyword_set(err) then begin
    err = y
    err(*) = 1.
endif

nbx = n_elements(a)-1
model = a[0]
for i=0, nbx-1 do model = model+a[i+1]*reform(x[i,*])
res = (y-model)/err

return, res

end

;----------------------------------------
function mpregress, xval, data, aguess, measure_error=errordata, sigma=perror, const=const, $
                    verbose=verbose, fixed=fixed, limits=limits

if not keyword_set(errordata) then errordata = replicate(1, n_elements(data))
if keyword_set(verbose) then quiet=0 else quiet=1

si = size(xval)
if (si[0] eq 1) then nbx = 1 else nbx = si[1]

if not keyword_set(aguess) then aguess=replicate(1, nbx+1)
if not keyword_set(fixed) then fixed= intarr(n_elements(aguess))

parinfo = replicate({value:0., fixed:0, limited:[0,0], limits:[0.,0], step:0.}, n_elements(aguess))
parinfo.value = aguess
if keyword_set(limits) then begin
   limited = limits
   limited[*] = 1
   parinfo.limits=limits
   parinfo.limited=limited
endif

functargs = {XVAL:xval, YVAL:data, ERRVAL:errordata}

fname='multivarlinear'

aguess = mpfit(fname, functargs=functargs, parinfo=parinfo, quiet=quiet, perror=perror, status=status, errmsg=errmsg) 

if (status le 0.) then print, 'status:', status, ' : ', errmsg

const = aguess[0]
perror = perror[1:*]
return, aguess[1:*]

end
