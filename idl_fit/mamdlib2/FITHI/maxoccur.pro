function maxoccur, data, nbmax

mind = min(data)
t = histogram(data, min=mind, bin=1)
nbmax = max(t, wmax)
result = wmax+mind

return, result

end
