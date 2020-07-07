function histomamd, data, bin=bin, minv=minv, maxv=maxv

if not keyword_set(minv) then minv=min(data)
if not keyword_set(maxv) then maxv=max(data)
if not keyword_set(bin) then bin=1.

ind = where(data ge minv and data le maxv, nbind)
if nbind eq 0 then return, -1

tempo = fix( ( data(ind) - minv ) / bin )
tempo = tempo( sort(tempo) )
ind = uniq( tempo )

result = ind-shift(ind,1)
result(0) = ind(0)+1

return, result

end
