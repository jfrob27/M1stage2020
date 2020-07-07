function fitexp_model, a, XVAL=x, YVAL=y, ERRVAL=err

if not keyword_set(err) then begin
    err = x
    err(*) = 1.
endif

model = a[0]*exp(x^a[1]/a[2])
res = (y-model)/err
return, res

end
