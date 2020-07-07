function la_minmax, data

datamin = la_min(data)
datamax = la_max(data)

result = [datamin, datamax]

return, result

end
