function la_abs, datain, indef=indef

if not keyword_set(indef) then indef=-32768.

data = datain
ind = where(data ne indef and data lt 0., nbind)
if (nbind gt 0) then data(ind) = -1.*data(ind)

return, data

end
