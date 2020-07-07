function wiener, map, noise, object

if not keyword_set(object) then object = map

fftmap = fft(map)
fftnoise = fft(noise)
fftobject = fft(object)

filter = abs(fftobject) / (abs(fftobject) + abs(fftnoise))

result = filter*fftmap

return, float(fft(result, 1))

end



