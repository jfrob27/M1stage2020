function mirror, map

simap = size(map)
mapm = fltarr(2*simap(1), 2*simap(2))
mapm(0:simap(1)-1, 0:simap(2)-1) = map
mapm(simap(1):*, 0:simap(2)-1) = rotate(map, 5)
mapm(0:simap(1)-1, simap(2):*) = rotate(map, 7)
mapm(simap(1):*, simap(2):*) = rotate(map, 2)

return, mapm

end
