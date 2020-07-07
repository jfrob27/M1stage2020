function fitexp, x, y, yfit=yfit

  ; Fit A*exp(x^B/C)
  guess = [1.,1.,-1.]

  ; FILL STRUCTURE FOR MPFIT
  parinfo = replicate({value:0., fixed:0, limited:[0,0], limits:[0.,0.], step:0.}, n_elements(guess))
;  parinfo.limits(0) = minguess
;  parinfo.limits(1) = maxguess
  parinfo(*).value = guess
  functargs = {XVAL:X, YVAL:Y} 

  ; COMPUTE FIT
  a = mpfit("fitexp_model", functargs=functargs, parinfo=parinfo, /quiet, perror=perror) 
  yfit =  a[0]*exp(x^a[1]/a[2])

  return, a

end
