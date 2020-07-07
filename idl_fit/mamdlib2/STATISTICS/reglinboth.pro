function reglinboth, x, y, coeff=coeff, dcoeff=dcoeff, plot=plot, _Extra=extra


m1 = reglin(x, y, coeff=coeff1)
m2 = reglin(y, x, coeff=coeff2)

slope = (coeff1(1)+1./coeff2(1))/2.
dslope = abs(coeff1(1)-slope)

oao = ( coeff1(0) - coeff2(0)/coeff2(1) )/2.
doao = abs( coeff1(0)-oao )

coeff = [oao, slope]
dcoeff = [doao, dslope]

model = x*slope+oao

if keyword_set(plot) then begin
    plot, x, y, _Extra=extra
    oplot, x, x*coeff1(1)+coeff1(0)
    oplot, x, x/coeff2(1) - coeff2(0)/coeff2(1)
endif

return, model

end
