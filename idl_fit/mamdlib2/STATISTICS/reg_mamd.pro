function reg_mamd, x, y, indef=indef, error=error, bootstrap=bootstrap, moy2=moy2, percent_remove=percent_remove, $
                   nb_iteration=nb_iteration

if not keyword_set(indef) then indef=-32768.
if not keyword_set(nb_iteration) then nb_iteration=100.
if not keyword_set(percent_remove) then percent_remove = 0.5



result = fltarr(2)
result(*) = -1.
error = result

ind = where(x ne indef and y ne indef, nbgood)
if (nbgood eq 0) then goto, closing

w = x
w(*) = 1.
result =  polyfitw(x(ind),y(ind),w(ind),1)


if keyword_set(moy2) then begin
    result1 =  result
    result2 =  polyfitw(y(ind),x(ind),w(ind),1)
    result(0) = (result1(0)+1./result2(0))/2.
    error(0) =  (result1(0)-1./result2(0))/2.
    result(1) = (result(1) -  result(1)/result(0))/2.
    error(1) =  (result(1) +  result(1)/result(0))/2.
    goto, closing
endif

if keyword_set(bootstrap) then begin
    nb_remove = fix(percent_remove*nbgood)
    print, nb_remove, nbgood
    ok = 0
    sig_before = 0.
    rel_sig = 1.e-4
    xx = x(ind)
    yy = y(ind)
    w = xx
    w(*) = 1.
    ii = 1.
    a = [result(1)]
    b = [result(0)]
    for ii = 1., nb_iteration do begin
        random_vec = randomu(seed, nbgood)
        ind = sort(random_vec)
        result =  polyfitw(xx(ind(nb_remove:*)), yy(ind(nb_remove:*)), w(ind(nb_remove:*)), 1)
        a = [a, result(1)]
        b = [b, result(0)]
    endfor
    result(1) = avg(a)
    result(0) = avg(b)
    error(1) = stdev(a)
    error(0) = stdev(b)

    goto, closing
endif


closing: 

return, result

end
